# frozen_string_literal: true

require 'telegram/bot'
require 'logger'
require_relative 'bot'  # Make sure to have the base class 'Bot'

class TelegramBot < Bot
  attr_reader :bot

  def initialize(token, commands, unknown_command_handler = nil)
    super(commands, unknown_command_handler)
    @bot = Telegram::Bot::Client.new(token)
  end

  def start
    @commands.each_value do |command_info|
      if valid_command?(command_info)
        add_command(command_info[:description], command_info[:message], command_info[:action])
      end
    end
    listen
  end

  def listen
    @bot.listen do |message|
      command = @processed_commands[message.text]
      if command
        handle_command(command, message)
      else
        handle_unknown_command(message)
      end
    rescue StandardError => e
      Logger.new($stdout).error("Error: #{e.message}")
    end
  end

  # This method has been adjusted to handle various types of chat.
  def send_message(chat, text)
    chat_id = extract_chat_id(chat)
    if chat_id
      @bot.api.send_message(chat_id: chat_id, text: text)
    else
      Logger.new($stdout).error("Chat object does not have a valid ID.")
    end
  end

  def valid_command?(command_info)
    command_info[:type].nil? || command_info[:type] == 'telegram'
  end

  # Helper method to extract the chat ID regardless of the chat type.
  def extract_chat_id(chat)
    if chat.respond_to?(:id)
      chat.id
    elsif chat.respond_to?(:chat) && chat.chat.respond_to?(:id)
      chat.chat.id
    else
      nil
    end
  end
end
