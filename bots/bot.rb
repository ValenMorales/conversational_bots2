# frozen_string_literal: true

require 'bas/utils/exceptions/function_not_implemented'

# Base class for different types of bots.
# Handles the registration and execution of commands, including unknown commands.
class Bot
  attr_reader :commands, :unknown_command_handler

  # Initializes a new bot instance.
  #
  # @param token [String] The bot's authentication token.
  # @param commands [Hash] A hash containing the bot's commands. The key is the command description,
  #   and the value is a hash with either a message or an action to be executed.
  # @param type [String] The type of bot (e.g., 'discord', 'telegram') to filter commands specific to that type.
  # @param unknown_command_handler [Proc, nil] An optional handler for unknown commands.
  def initialize(token, commands, type, unknown_command_handler = nil)
    @token = token
    @commands = commands
    @unknown_command_handler = unknown_command_handler
    @type = type
  end

  # Reads and processes incoming messages by listening events.
  def start
    raise Utils::Exceptions::FunctionNotImplemented
  end

  # Evaluates the type of a command.
  #
  # @param event [Object] The event object representing the message or event.
  def evaluate_command(command, event)
    if @commands.key?(command)
      validate_command_type(@commands[command], event)
    else
      handle_unknown_command(event)
    end
  end

  # Determines whether to send a message or execute an action.
  #
  # @param command_data [Hash] Command data (message or action).
  # @param event [Object] Event triggering the command.
  def validate_command_type(command_data, event)
    if command_data[:message]
      send_message(take_event_user(event), command_data[:message])
    elsif command_data[:action]
      execute_action(command_data[:action], event)
    end
  end

  # Extracts the user from the event.
  #
  # @param event [Object] The event object.
  # @return [Object] The user extracted from the event.
  def take_event_user(_event)
    raise Utils::Exceptions::FunctionNotImplemented
  end

  # Handles unknown commands, invoking the unknown command handler if defined.
  #
  # @param message [Object] The message object for the unknown command.
  def handle_unknown_command(event)
    @unknown_command_handler&.call(event)
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
end
