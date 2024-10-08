# frozen_string_literal: true

require 'discordrb'
require_relative 'bot_base'  # Ensure to require bot_base

module DiscordBot
  class WebAvailability < Bot::Base
    def initialize(token, connection)
      super(read_options: {}, process_options: {}, write_options: {})  # Call the superclass
      @bot = Discordrb::Bot.new token: token
      @connection = connection
      @user_data = {}
    end

    # Implement the read method
    def read
      @bot.message do |event|
        process_message(event)
      rescue StandardError => e
        Logger.new($stdout).error(e.message)
      end

      @bot.run
    end

    # Implement the process method
    def process
      if @user_data.dig(:user_id) == :awaiting_url
        { status: 'processing' }
      else
        { status: 'not_processing' }
      end
    end

    # Implement the write method
    def write
      # Here we save to the database or perform the desired action
      config = { connection: @connection, owner: @user_data[:user_id], url: @user_data[:url] }
      Utils::AddReview.new(config).execute
    end

    private

    def process_message(event)
      if event.content.start_with?('/')
        process_command(event)
      else
        process_input(event.user.id, event.content)
      end
    end

    def process_command(event)
      case event.content.split.first
      when '/start'
        send_message(event, "Hello! Use /add_website to add a new website.")
      when '/add_website'
        send_message(event, "Please send the URL of the website you want to add.")
        @user_data[event.user.id] = :awaiting_url
      end
    end

    def process_input(user_id, input)
      if @user_data[user_id] == :awaiting_url
        validate_website(user_id, input)
      else
        send_message(user_id, "Send /add_website to add a website.")
      end
    end

    def validate_website(user_id, url)
      if url.start_with?('http://', 'https://')
        @user_data[user_id] = { url: url, user_id: user_id }
        send_message(user_id, "Website added. You'll be notified if it's down.")
      else
        send_message(user_id, "Invalid URL. Please enter a valid website.")
      end
    end

    def send_message(user_id, text)
      @bot.send_message(user_id, text)
    end
  end
end
