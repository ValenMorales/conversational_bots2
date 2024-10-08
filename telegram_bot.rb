# frozen_string_literal: true

require 'logger'
require 'telegram/bot'

require_relative 'add_review'

module Bots
  ##
  # Telegram base bot to process chat commands to add availability websites
  # check requests# frozen_string_literal: true
  #
  class WebAvailability 
    attr_reader :bot, :user_message, :connection
    attr_accessor :user_data

    START = 'Hello! Use /add_website to add a new website.'
    ADD_WEBSITE = 'Please send the URL of the website you want to add.'
    WEBSITE_ADDED = 'Thanks! The website has been added. You will be notified if the domain is down'
    INVALID = 'Invalid URL. Please enter a valid website.'
    INSTRUCTION = 'Send /add_website to add a website.'

    def initialize(token, connection)
      @bot = Telegram::Bot::Client.new(token)
      @connection = connection
      @user_data = {}
    end

    def execute
      bot.listen do |message|
        process_message(message)
      rescue StandardError => e
        Logger.new($stdout).error(e.message)
      end
    end

    private

    def process_message(message)
      @user_message = message

      case message.text
      when '/start' then start
      when '/add_website' then add_website
      else input_response
      end
    end

    def start
      send_message(START)
    end

    def add_website
      send_message(ADD_WEBSITE)
      user_data[user_message.chat.id] = :awaiting_url
    end

    def input_response
      if user_data[user_message.chat.id] == :awaiting_url
        validate_website
      else
        send_message(INSTRUCTION)
      end
    end

    def validate_website
      if user_message.text.start_with?('http://', 'https://')
        user_data[user_message.chat.id] = nil
        save_website
        send_message(WEBSITE_ADDED)
      else
        send_message(INVALID)
      end
    end

    def save_website
      config = { connection:, owner: user_message.chat.id, url: user_message.text }
      Utils::AddReview.new(config).execute
    end

    def send_message(text)
      bot.api.send_message(chat_id: user_message.chat.id, text:)
    end
  end
end
