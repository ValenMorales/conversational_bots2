# frozen_string_literal: true

# The BotCommands class defines a set of commands and behaviors
# for a bot to interact with users. It allows adding commands
# with associated messages and actions and provides a custom handler
# for cases where the input from the user does not match any defined command.
class BotCommands
  # @commands stores the set of available commands for the bot, where
  # each command is identified by its name and contains additional metadata.
  attr_reader :commands

  def initialize
    @commands = {}
  end

  # Custom handler to execute when the input from the user does not match
  # any known command. This can be customized to handle unknown input,
  def custom_handler; end

  # Adds a new command to the bot's command set.
  # Validates that the command has either a `message` or `action` attribute,
  #
  # @param [Hash] command A hash containing the command details:
  #   - :name (String) Name of the command.
  #   - :description (String) Description of the command's function.
  #   - :message (String, optional) A message to send when the command is executed.
  #   - :action (Proc, optional) An action (function) to execute when the command is invoked.
  #   - :platform (String, optional) The platform where the command is available.
  #
  # @raise [ArgumentError] If neither `message` nor `action` is provided.
  def add_command(command)
    if command[:message].nil? && command[:action].nil?
      raise ArgumentError, 'Invalid command: must have either a message or an action.'
    end

    @commands[command[:name]] = {
      name: command[:name],
      description: command[:description],
      message: command[:message],
      action: command[:action],
      platform: command[:platform]
    }
  end
end
