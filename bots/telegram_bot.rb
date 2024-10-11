# frozen_string_literal: true

require 'telegram/bot'
require 'logger'
require_relative 'bot'

# The TelegramBot class represents a Telegram bot that handles predefined commands
# and performs specific actions or sends predefined messages when certain commands
# are triggered.
class TelegramBot < Bot
  attr_reader :bot

  # Initializes a new instance of the Telegram bot.
  #
  # @param token [String] the bot's authentication token for Telegram.
  # @param commands [Hash] a hash containing the bot's commands, where the key is the command description
  #   and the value is a hash with the message or action.
  # @param unknown_command_handler [Proc, nil] an optional handler to be executed when an unknown command is received.
  def initialize(token, commands, unknown_command_handler = nil)
    super(token, commands, unknown_command_handler, 'telegram')
    @bot = Telegram::Bot::Client.new(token)
  end

  # Listens and processes incoming messages sent to the Telegram bot.
  #
  # Whenever a message is received, the corresponding command is processed, either executing an action
  # or sending a predefined message.
  def read
    @bot.listen do |message|
      process_command(message)
    rescue StandardError => e
      Logger.new($stdout).error("Error: #{e.message}")
    end
  end

  # Processes the command from the incoming message.
  #
  # @param event [Telegram::Bot::Types::Message] the message event from Telegram.
  def process_command(event)
    command = event.text.split.first  # Extract the command from the message text
    evaluate_command(command, event)  # Evaluate the command
  end

  # Extracts the user from the event (in this case, the chat).
  #
  # @param event [Telegram::Bot::Types::Message] the event containing user/chat information.
  # @return [Telegram::Bot::Types::Chat] The chat object representing the user.
  def take_event_user(event)
    event.chat
  end

  # Handles unknown commands by invoking the unknown command handler, if defined.
  #
  # @param message [Telegram::Bot::Types::Message] the message object for the unknown command.
  def handle_unknown_command(message)
    return unless @unknown_command_handler

    @unknown_command_handler.call(message, message.text, message.chat, self)
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
  # @param chat [Telegram::Bot::Types::Chat] the chat where the message will be sent.
  # @param text [String] the text of the message to send.
  def send_message(chat, text)
    @bot.api.send_message(chat_id: chat.id, text: text)
  end
end
