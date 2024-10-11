# frozen_string_literal: true

class Bot
  attr_reader :commands, :unknown_command_handler

  # Initializes a new instance of the Bot class.
  #
  # @param commands [Hash] a hash containing the commands for the bot.
  # @param unknown_command_handler [Proc, nil] an optional handler to be executed when an unknown command is received.
  def initialize(commands, unknown_command_handler = nil)
    @commands = commands
    @unknown_command_handler = unknown_command_handler
    @processed_commands = {}
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

  # Handles the received command and executes its action or sends a message response.
  #
  # @param command [Hash] the command data containing its action or message.
  # @param message [Object] the message object containing the text and other relevant information.
  def handle_command(command, message)
    if command[:action]
      execute_action(command[:action], message)
    else
      send_message(message, command[:message])
    end
  end

  # Handles an unknown command by calling the unknown command handler, if defined.
  #
  # @param message [Object] the message object for the unknown command.
  def handle_unknown_command(message)
    if @unknown_command_handler
      @unknown_command_handler.call(message, message.text, message.chat, self)
    else
      send_message(message, "Unknown command: #{message.text}")
    end
  end

  # Executes a command action if it is a valid Proc.
  #
  # @param action [Proc] the action to be executed.
  # @param message [Object] the message object to be passed to the action.
  def execute_action(action, message)
    action.call(message, message.text, message.chat, self) if action.is_a?(Proc)
  end

  # Validates the command by checking its type.
  #
  # @param command_info [Hash] The data related to the command.
  # @return [Boolean] true if the command is valid, false otherwise.
  def valid_command?(command_info)
    command_info[:type].nil?
  end
end
