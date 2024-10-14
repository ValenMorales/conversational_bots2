# frozen_string_literal: true

require_relative 'add_review'

# The BotCommands class defines a set of commands and behaviors
# for a bot to interact with users. The bot allows users to add websites
# and receive notifications if the website's domain is down.
class BotCommands
  attr_reader :user_data

  START = 'Hello! Use /add_website to add a new website.'
  ADD_WEBSITE = 'Please send the URL of the website you want to add.'
  WEBSITE_ADDED = 'Thanks! The website has been added. You will be notified if the domain is down.'
  INVALID = 'Invalid URL. Please enter a valid website.'
  INSTRUCTION = 'Send /add_website to add a website.'

  def initialize(db_connection)
    @user_data = {}
    @db_connection = db_connection
  end

  def custom_handler(event, message, user, bot_instance)
    owner = user.id
    if @user_data[owner] == :awaiting_url
      validate_website(event, message, user, bot_instance)
    else
      bot_instance.send_message(user, INSTRUCTION)
    end
  end

  def validate_website(_event, message, user, bot_instance)
    if message.start_with?('http://', 'https://')
      save_website(message, user, bot_instance)
      bot_instance.send_message(user, WEBSITE_ADDED)
    else
      bot_instance.send_message(user, INVALID)
    end
  end

  def save_website(message, user, _bot_instance)
    config = { connection: @db_connection, owner: user.id, url: message }
    Utils::AddReview.new(config).execute
  end

  def add_website(_event, _message, user, bot_instance)
    bot_instance.send_message(user, ADD_WEBSITE)
    @user_data[user.id] = :awaiting_url
  end

  # Método separado para cada comando
  def start_command
    {
      description: '/start',
      message: START
    }
  end

  def add_website_command
    {
      description: '/add_website',
      action: proc do |event, message, user, bot_instance|
        add_website(event, message, user, bot_instance)
      end
    }
  end

  # Definir los comandos en un método más pequeño
  def commands
    {
      'start' => start_command,
      'add_website' => add_website_command
    }
  end
end
