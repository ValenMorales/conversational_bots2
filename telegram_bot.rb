# frozen_string_literal: true

require 'telegram/bot'
require_relative 'bot_base'  # Ensure to require bot_base

module TelegramBot
  class WebAvailability < Bot::Base
    def initialize(token, connection)
      super(read_options: {}, process_options: {}, write_options: {})  # Call the superclass
      @bot = Telegram::Bot::Client.new(token)
      @connection = connection
      @user_data = {}
    end

    # Implement the read method
    def read
      @bot.listen do |message|
        process_message(message)
      rescue StandardError => e
        Logger.new($stdout).error(e.message)
      end
    end

    # Implement the process method
    def process
      if @user_data.dig(:chat_id) == :awaiting_url
        { status: 'processing' }
      else
        { status: 'not_processing' }
      end
    end

    # Implement the write method
    def write
      # Here we save to the database or perform the desired action
      config = { connection: @connection, owner: @user_data[:chat_id], url: @user_data[:url] }
      Utils::AddReview.new(config).execute
    end

    private

    def process_message(message)
      case message.text
      when '/start' then start(message)
      when '/add_website' then add_website(message)
      else process_input(message.chat.id, message.text)
      end
    end

    def start(message)
      send_message(message.chat.id, "Hello! Use /add_website to add a new website.")
    end

    def add_website(message)
      send_message(message.chat.id, "Please send the URL of the website you want to add.")
      @user_data[message.chat.id] = :awaiting_url
    end

    def process_input(chat_id, input)
      if @user_data[chat_id] == :awaiting_url
        validate_website(chat_id, input)
      else
        send_message(chat_id, "Send /add_website to add a website.")
      end
    end

    def validate_website(chat_id, url)
      if url.start_with?('http://', 'https://')
        @user_data[chat_id] = { url: url, chat_id: chat_id }
        send_message(chat_id, "Website added. You'll be notified if it's down.")
      else
        send_message(chat_id, "Invalid URL. Please enter a valid website.")
      end
    end

    def send_message(chat_id, text)
      @bot.api.send_message(chat_id: chat_id, text: text)
    end
  end
end
