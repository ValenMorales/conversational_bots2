# frozen_string_literal: true

# The BotCommands class defines a set of commands and behaviors
# for a bot to interact with users
class BotCommands
  attr_reader :commands

  def initialize
    @commands = {}
  end

  def custom_handler(event, message, user, bot_instance); end

  def add_command(command)
    @commands[command[:name]] = {
      name: command[:name],
      description: command[:description],
      message: command[:message],
      action: command[:action],
      type: command[:type]
    }
  end
end
