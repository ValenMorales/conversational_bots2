# frozen_string_literal: true

require 'discordrb'
require 'logger'
require_relative 'bot'

# DiscordBot class inherits from Bot and implements Discord-specific functionality.
class DiscordBot < Bot
  attr_reader :bot

  # Initializes the DiscordBot with token, commands, and an optional unknown command handler.
  #
  # @param token [String] The bot's authentication token for Discord.
  # @param commands [Hash] A hash containing the bot's commands.
  # @param unknown_command_handler [Proc, nil] An optional handler for unknown commands.
  def initialize(token, commands, unknown_command_handler = nil)
    super(token, commands, unknown_command_handler, 'discord')
    @bot = Discordrb::Bot.new(token: token)
  end

  # Reads and processes incoming messages by listening to Discord events.
  def read
    @bot.message do |event|
      process_command(event)
    rescue StandardError => e
      Logger.new($stdout).error("Error: #{e.message}")
    end

    @bot.run
  end

  # Processes the received command from the event.
  #
  # @param event [Discordrb::Events::MessageEvent] The event containing the message and user information.
  def process_command(event)
    command = event.content.split.first
    evaluate_command(command, event)
  end

  # Executes a command's action if it is a valid Proc.
  #
  # @param action [Proc] The action to be executed.
  # @param event [Discordrb::Events::MessageEvent] The event containing the message and user information.
  def execute_action(action, event)
    if action.is_a?(Proc)
      action.call(event, event.content, event.user, self)
    else
      send_message(event.user, 'Invalid or non-executable action.')
    end
  end

  # Handles unknown commands by invoking the unknown command handler if defined.
  #
  # @param event [Discordrb::Events::MessageEvent] The event containing the message and user information.
  def handle_unknown_command(event)
    @unknown_command_handler&.call(event, event.content, event.user, self)
  end

  # Sends a private message to a user.
  #
  # @param user [Discordrb::User] The user who will receive the message.
  # @param text [String] The message text to be sent.
  def send_message(user, text)
    user.pm(text)
  rescue StandardError => e
    Logger.new($stdout).error("Error: Could not send message. #{e.message}")
  end
end
