# frozen_string_literal: true

require 'discordrb'
require 'logger'
require_relative 'bot'

# Discord bot specific functionality.
class DiscordBot < Bot
  attr_reader :bot

  # Initializes the DiscordBot
  def initialize(token, commands, unknown_command_handler = nil)
    super(token, commands, 'discord', unknown_command_handler)
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

  # Handles unknown commands.
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

  # Extracts the user from the event (Discord).
  #
  # @param event [Discordrb::Events::MessageEvent] The event containing the message and user information.
  # @return [Discordrb::User] The user object representing the sender.
  def take_event_user(event)
    event.user
  end
end
