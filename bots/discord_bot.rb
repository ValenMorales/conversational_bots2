# frozen_string_literal: true

require 'discordrb'
require 'logger'

# The DiscordBot class represents a Discord bot that handles predefined commands
# and allows the execution of specific actions or sends messages when certain commands
# are received.
class DiscordBot
  attr_reader :bot

  # Initializes a new instance of the Discord bot.
  #
  # @param token [String] the bot's authentication token for Discord.
  # @param commands [Hash] a hash containing the bot's commands, where the key is the command description
  #   and the value is a hash with the message or action.
  # @param unknown_command_handler [Proc, nil] an optional handler to be executed when an unknown command is received.
  def initialize(token, commands, unknown_command_handler = nil)
    @bot = Discordrb::Bot.new token: token
    @commands = commands
    @processed_commands = {}
    @unknown_command_handler = unknown_command_handler
  end

  # Starts the bot and registers the commands defined in the @commands hash.
  #
  # This method iterates over the commands, filtering out those that are either not type-specific
  # or are meant for Discord, and adds them to the bot.
  def start
    @commands.each_value do |command_info|
      if command_info[:type].nil? || command_info[:type] == 'discord'
        if command_info[:action]
          add_command(command_info[:description], nil, command_info[:action])
        else
          add_command(command_info[:description], command_info[:message])
        end
      end
    end

    read
  end

  # Adds a command to the bot, storing it in the @processed_commands hash.
  #
  # @param command_description [String] the description or name of the command.
  # @param command_message [String, nil] the message to be sent when the command is received (optional).
  # @param command_action [Proc, nil] the action (code block) to be executed when the command is received (optional).
  def add_command(command_description, command_message = nil, command_action = nil)
    @processed_commands[command_description] = if command_action
                                                 { action: command_action }
                                               else
                                                 { message: command_message }
                                               end
  end

  # Listens and processes messages sent to the Discord bot. Whenever a message is received,
  # the `process_message` method is called.
  def read
    @bot.message do |event|
      process_message(event)
    rescue StandardError => e
      Logger.new($stdout).error("Error: #{e.message}")
    end

    @bot.run
  end

  # Processes a received message by attempting to execute a corresponding command.
  #
  # @param event [Discordrb::Events::MessageEvent] the message event containing the message data.
  def process_message(event)
    process_command(event)
  end

  # Processes a command extracted from a message, executing its action or sending a message response.
  #
  # @param event [Discordrb::Events::MessageEvent] the event triggered by the message,
  # containing the content and user data.

  def process_command(event)
    command = event.content.split.first
    if @processed_commands.key?(command)
      command_data = @processed_commands[command]
      validate_command_type(command_data, event)
    else
      handle_unknown_command(event)
    end
  end

  # Validates the command type by checking if it's a message or an action.
  # @param command_data [Hash] The data related to the command (message or action).
  # @param event [Object] The event object that triggered the command.
  def validate_command_type(command_data, event)
    if command_data[:message]
      send_message(event.user, command_data[:message])
    elsif command_data[:action]
      execute_action(command_data[:action], event)
    end
  end

  # Executes a command action if it is a valid Proc.
  #
  # @param action [Proc] the action to be executed.
  # @param event [Discordrb::Events::MessageEvent] the event data to be passed to the action.
  def execute_action(action, event)
    if action.is_a?(Proc)
      action.call(event, event.content, event.user, self)
    else
      send_message(event.user, 'Invalid or non-executable action.')
    end
  end

  # Handles an unknown command by calling the unknown command handler, if defined.
  #
  # @param event [Discordrb::Events::MessageEvent] the event data for the unknown command.
  def handle_unknown_command(event)
    return unless @unknown_command_handler

    @unknown_command_handler.call(event, event.content, event.user, self)
  end

  # Sends a private message to a specific user.
  #
  # @param user [Discordrb::User] the user who will receive the message.
  # @param text [String] the message text to be sent.
  def send_message(user, text)
    user.pm(text)
  end
end
