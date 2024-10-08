# frozen_string_literal: true

require 'logger'
require 'discordrb'
require_relative 'add_review'

module DiscordBot
  ##
  # Discord bot to process chat commands to add availability websites
  #
  class WebAvailability 
    attr_reader :bot, :connection
    attr_accessor :user_data

    START = 'Hello! Use /add_website to add a new website.'
    ADD_WEBSITE = 'Please send the URL of the website you want to add.'
    WEBSITE_ADDED = 'Thanks! The website has been added. You will be notified if the domain is down.'
    INVALID = 'Invalid URL. Please enter a valid website.'
    INSTRUCTION = 'Send /add_website to add a website.'

    COMMANDS = {
      '/start' => :start,
      '/add_website' => :add_website
    }.freeze

    def initialize(token, connection)
      @bot = Discordrb::Bot.new token: token
      @connection = connection
      @user_data = {}
    end

    def execute
      bot.message do |event|
        # Si el mensaje comienza con un comando (/start, /add_website), procesa el comando
        if event.content.start_with?('/')
          process_command(event)
        else
          # Si no es un comando, procesa la entrada como una posible URL u otro input
          process_user_input(event)
        end
      rescue StandardError => e
        Logger.new($stdout).error(e.message)
      end

      bot.run
    end

    private

    def process_command(event)
      command = event.content.split.first
      action = COMMANDS[command]

      action ? send(action, event) : send_message(event, "Unknown command: #{command}")
    end

    def start(event)
      send_message(event, START)
    end

    def add_website(event)
      send_message(event, ADD_WEBSITE)
      # Cambiar el estado del usuario a :awaiting_url para que sepa que está esperando una URL
      user_data[event.user.id] = :awaiting_url
    end

    def process_user_input(event)
      # Revisar si el usuario está en estado de "esperando URL"
      if user_data[event.user.id] == :awaiting_url
        validate_website(event)
      else
        send_message(event, INSTRUCTION)
      end
    end

    def validate_website(event)
      if valid_url?(event.content)
        # Si es una URL válida, limpia el estado y guarda el sitio
        user_data[event.user.id] = nil
        save_website(event)
        send_message(event, WEBSITE_ADDED)
      else
        # Si no es válida, solicita una URL nuevamente
        send_message(event, INVALID)
      end
    end

    def valid_url?(url)
      # Comprobación básica de si la entrada parece ser una URL válida
      url.start_with?('http://', 'https://')
    end

    def save_website(event)
      config = { connection: @connection, owner: event.user.id, url: event.content }
      Utils::AddReview.new(config).execute
    end

    def send_message(event, text)
      event.respond text
    end
  end
end
