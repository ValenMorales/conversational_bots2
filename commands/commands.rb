# frozen_string_literal: true

# The BotCommands class defines a set of commands and behaviors
# for a bot to interact with users
class BotCommands
  attr_reader :commands

  def initialize
    @commands = {}
  end

  def custom_handler(event, message, user, bot_instance)
  end

  def add_command(description, message= nil, action= nil, type= nil)
    @commands[description] = {
      description: description,
      message: message,
      action: action,
      type: type
    }
  end
end
