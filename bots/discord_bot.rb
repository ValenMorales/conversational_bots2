# frozen_string_literal: true

require 'discordrb'
require 'logger'

class DiscordBot
  attr_reader :bot, :commands, :processed_commands, :unknown_command_handler

  def initialize(token, commands, unknown_command_handler = nil)
    @bot = Discordrb::Bot.new token: token
    @commands = commands
    @processed_commands = {}
    @unknown_command_handler = unknown_command_handler
  end

  # Starts the bot and registers the commands
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

  # Adds a command to the bot
  def add_command(command_description, command_message = nil, command_action = nil)
    @processed_commands[command_description] = {
      message: command_message,
      action: command_action
    }
  end

  # Reads and processes incoming messages
  def read
    @bot.message do |event|
      process_message(event)
    rescue StandardError => e
      Logger.new($stdout).error("Error: #{e.message}")
    end

    @bot.run
  end

  # Processes the received message
  def process_message(event)
    command = event.content.split.first
    if @processed_commands.key?(command)
      command_data = @processed_commands[command]
      validate_command_type(command_data, event)
    else
      handle_unknown_command(event)  # Handle unknown commands here
    end
  end

  # Validates the type of command and executes the action or sends a message
  def validate_command_type(command_data, event)
    if command_data[:message]
      send_message(event.user, command_data[:message])
    elsif command_data[:action]
      execute_action(command_data[:action], event)
    end
  end

  # Executes a specific action if valid
  def execute_action(action, event)
    if action.is_a?(Proc)
      action.call(event, event.content, event.user, self)
    else
      send_message(event.user, 'Invalid or non-executable action.')
    end
  end

  # Handles an unknown command
  def handle_unknown_command(event)
    return unless @unknown_command_handler

    @unknown_command_handler.call(event, event.content, event.user, self)
  end

  # Sends a direct message to a user
  def send_message(user, text)
    user.pm(text)  # Change to dm if necessary
  rescue StandardError => e
    Logger.new($stdout).error("Error: Could not send message, user object does not support dm. #{e.message}")
  end
end
