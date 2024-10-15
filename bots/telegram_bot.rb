# frozen_string_literal: true

require 'telegram/bot'
require_relative 'bot'

# TelegramBot specific functionalities.
class TelegramBot < Bot
  attr_reader :bot

  # Initializes the Telegram bot with token, commands, and optional unknown command handler.
  #
  # @param token [String] Authentication token for Telegram.
  # @param commands [Hash] Command hash where the key is the command and the value is the message or action.
  # @param unknown_command_handler [Proc, nil] Optional handler for unknown commands.
  def initialize(token, commands, unknown_command_handler = nil)
    super(token, commands, 'telegram', unknown_command_handler)
    @bot = Telegram::Bot::Client.new(token)
  end

  # Listens and processes incoming messages.
  def start
    @bot.listen do |message|
      process_command(message)
    rescue StandardError => e
      Logger.new($stdout).error("Error: #{e.message}")
    end
  end

  # Processes the command from the received message.
  #
  # @param event [Telegram::Bot::Types::Message] The incoming message event.
  def process_command(event)
    command = event.text.split.first # Extracts the command from the message text.
    evaluate_command(command, event)
  end

  # Extracts the user (chat) from the event.
  #
  # @param event [Telegram::Bot::Types::Message] Message containing user/chat info.
  # @return [Telegram::Bot::Types::Chat] The chat object representing the user.
  def take_event_user(event)
    event.chat
  end

  # Executes an action for a command if it is a valid Proc.
  #
  # @param action [Proc] Action to execute.
  # @param event [Telegram::Bot::Types::Message] The message event data passed to the action.
  def execute_action(action, event)
    return unless action.is_a?(Proc)

    action.call(event, event.text, event.chat, self)
  end

  # Handles unknown commands, invoking the unknown command handler if defined.
  #
  # @param event [Telegram::Bot::Types::Message] Message object for the unknown command.
  def handle_unknown_command(event)
    return unless @unknown_command_handler

    @unknown_command_handler.call(event, event.text, event.chat, self)
  end

  # Sends a message to the chat.
  #
  # @param chat [Telegram::Bot::Types::Chat] Chat where the message will be sent.
  # @param text [String] Text of the message to send.
  def send_message(chat, text)
    @bot.api.send_message(chat_id: chat.id, text: text)
  rescue StandardError => e
    Logger.new($stdout).error("Error: Could not send message. #{e.message}")
  end
end
