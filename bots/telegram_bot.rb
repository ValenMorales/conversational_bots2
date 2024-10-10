# frozen_string_literal: true

require 'telegram/bot'
require 'logger'

# The TelegramBot class represents a Telegram bot that handles predefined commands
# and performs specific actions or sends predefined messages when certain commands
# are triggered.
class TelegramBot
  attr_reader :bot

  # Initializes a new instance of the Telegram bot.
  #
  # @param token [String] the bot's authentication token for Telegram.
  # @param commands [Hash] a hash containing the bot's commands, where the key is the command description
  #   and the value is a hash with the message or action.
  # @param unknown_command_handler [Proc, nil] an optional handler to be executed when an unknown command is received.
  def initialize(token, commands, unknown_command_handler = nil)
    @commands = commands
    @processed_commands = {}
    @bot = Telegram::Bot::Client.new(token)
    @unknown_command_handler = unknown_command_handler
  end

  # Starts the bot and registers the commands defined in the @commands hash.
  #
  # This method iterates over the commands, filtering out those that are either not type-specific
  # or are meant for Telegram, and adds them to the bot's command list.
  def start
    @commands.each_value do |command_info|
      if command_info[:type].nil? || command_info[:type] == 'telegram'
        add_command(command_info[:description], command_info[:message], command_info[:action])
      end
    end
    listen
  end

  # Adds a command to the bot, storing it in the @processed_commands hash.
  #
  # @param command_description [String] the description or name of the command.
  # @param command_message [String, nil] the message to be sent when the command is received (optional).
  # @param command_action [Proc, nil] the action (code block) to be executed when the command is received (optional).
  def add_command(command_description, command_message = nil, command_action = nil)
    @processed_commands[command_description] = {
      message: command_message,
      action: command_action
    }
  end

  # Listens and processes incoming messages sent to the Telegram bot.
  #
  # Whenever a message is received, the corresponding command is processed, either executing an action
  # or sending a predefined message.
  def listen
    @bot.listen do |message|
      command = @processed_commands[message.text]
      if command
        handle_command(command, message)
      else
        handle_unknown_command(message)
      end
    rescue StandardError => e
      Logger.new($stdout).error("Error: #{e.message}")
    end
  end

  # Handles the execution of a command by either running an action or sending a message.
  # @param command [Hash] The command containing either an action or a message.
  # @param message [Object] The message object from the Telegram bot.
  def handle_command(command, message)
    if command[:action]
      execute_action(command[:action], message)
    else
      send_message(message.chat, command[:message])
    end
  end

  # Handles an unknown command by invoking the unknown command handler if defined,
  # or sending a default unknown command message.
  #
  # @param message [Telegram::Bot::Types::Message] the message event containing the unknown command.
  def handle_unknown_command(message)
    if @unknown_command_handler
      @unknown_command_handler.call(message, message.text, message.chat, self)
    else
      send_message(message.chat, "Unknown command: #{message.text}")
    end
  end

  # Executes a command action if it is a valid Proc.
  #
  # @param action [Proc] the action to be executed.
  # @param message [Telegram::Bot::Types::Message] the message event data to be passed to the action.
  def execute_action(action, message)
    return unless action.is_a?(Proc)

    action.call(message, message.text, message.chat, self)
  end

  # Sends a message to a specific chat in Telegram.
  #
  # @param chat_id [Integer] the ID of the chat where the message will be sent.
  # @param text [String] the text of the message to send.
  def send_message(chat, text)
    @bot.api.send_message(chat_id: chat.id, text: text)
  end
end
