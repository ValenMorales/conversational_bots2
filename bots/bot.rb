# frozen_string_literal: true

require 'logger'

# The Bot class serves as a base class for different types of bots (e.g., Telegram, Discord).
# It handles the registration and execution of commands, including handling unknown commands.
class Bot
  attr_reader :commands, :unknown_command_handler

  # Initializes a new instance of the bot.
  #
  # @param token [String] The bot's authentication token.
  # @param commands [Hash] A hash containing the bot's commands. The key is the command description,
  #   and the value is a hash with either a message or an action to be executed.
  # @param unknown_command_handler [Proc, nil] An optional handler for unknown commands.
  # @param type [String] The type of bot (e.g., 'discord', 'telegram') to filter commands specific to that type.
  def initialize(token, commands, type, unknown_command_handler = nil)
    @token = token
    @commands = commands
    @processed_commands = {}
    @unknown_command_handler = unknown_command_handler
    @type = type
  end

  # Starts the bot and registers the commands defined in the @commands hash.
  #
  # This method iterates over the commands, filtering out those that are either not type-specific
  # or are meant for the specific bot type, and adds them to the bot.
  def start
    @commands.each_value do |command_info|
      if valid_command?(command_info)
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
  # @param command_description [String] The description or name of the command.
  # @param command_message [String, nil] The message to be sent when the command is received (optional).
  # @param command_action [Proc, nil] The action (code block) to be executed when the command is received (optional).
  def add_command(command_description, command_message = nil, command_action = nil)
    @processed_commands[command_description] = if command_action
                                                 { action: command_action }
                                               else
                                                 { message: command_message }
                                               end
  end

  # Abstract method to be implemented in subclasses.
  # Listens and processes messages sent to the bot.
  def read
    raise Utils::Exceptions::FunctionNotImplemented
  end

  # Processes a command extracted from a message, executing its action or sending a message response.
  #
  # @param event [Object] The event object representing the message or event.
  def evaluate_command(command, event)
    if @processed_commands.key?(command)
      command_data = @processed_commands[command]
      validate_command_type(command_data, event)
    else
      handle_unknown_command(event)
    end
  end

  # Validates the command type by checking if it's a message or an action.
  #
  # @param command_data [Hash] The data related to the command (message or action).
  # @param event [Object] The event object that triggered the command.
  def validate_command_type(command_data, event)
    if command_data[:message]
      send_message(take_event_user(event), command_data[:message])
    elsif command_data[:action]
      execute_action(command_data[:action], event)
    end
  end

  # Abstract method to be implemented in subclasses.
  # Extracts the user from the event.
  #
  # @param event [Object] The event object.
  # @return [Object] The user extracted from the event.
  def take_event_user(_event)
    raise Utils::Exceptions::FunctionNotImplemented
  end

  # Handles an unknown command by calling the unknown command handler, if defined.
  #
  # @param message [Object] The message object for the unknown command.
  def handle_unknown_command(event)
    return unless @unknown_command_handler

    @unknown_command_handler.call(event)
  end

  # Executes a command action if it is a valid Proc.
  #
  # @param action [Proc] The action to be executed.
  # @param event [Object] The event data to be passed to the action.
  def execute_action(_action, _event)
    raise Utils::Exceptions::FunctionNotImplemented
  end

  # Sends a private message to a specific user.
  #
  # @param user [Object] The user who will receive the message.
  # @param text [String] The message text to be sent.
  def send_message(_user, _text)
    raise Utils::Exceptions::FunctionNotImplemented
  end

  # Validates if the command is applicable to the current bot type.
  #
  # @param command_info [Hash] The data related to the command.
  # @return [Boolean] true if the command is valid for the bot type, false otherwise.
  def valid_command?(command_info)
    command_info[:type].nil? || command_info[:type] == @type
  end
end
