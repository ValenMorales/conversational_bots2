# frozen_string_literal: true

require_relative 'add_review'
require_relative '../../commands/commands'

# Bot commands implementation for website availability use case
class WebsiteBotCommands < BotCommands
  attr_reader :user_data

  START = 'Hello! Use /add_website to add a new website.'
  ADD_WEBSITE = 'Please send the URL of the website you want to add.'
  WEBSITE_ADDED = 'Thanks! The website has been added. You will be notified if the domain is down.'
  INVALID = 'Invalid URL. Please enter a valid website.'
  INSTRUCTION = 'Send /add_website to add a website.'

  def initialize(db_connection)
    super()
    @user_data = {}
    @db_connection = db_connection
    define_commands
  end

  def define_commands
    add_command('/start')
    add_command('/add_website', nil,
                proc do |event, message, user, instance|
                  add_website(event, message, user, instance)
                end)
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
end
