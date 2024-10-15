# frozen_string_literal: true
require_relative '../../commands/commands'
require_relative 'services/list_websites'
require_relative 'services/remove_website'
require_relative 'services/add_website'

# Bot commands implementation for website availability use case
class WebsiteBotCommands < BotCommands
  attr_reader :user_data

  MAX_USER_LIMIT = 2
  COMMANDS = %w[add_website list_websites remove_website].freeze
  START = 'Hello! Use any of the available commands:'
  ADD_WEBSITE = 'Please send the URL of the website you want to add.'
  WEBSITE_ADDED = 'Thanks! The website has been added. You will be notified if the domain is down'
  INVALID = 'Invalid URL. Please enter a valid website.'
  INSTRUCTION = 'Send /add_website to add a website.'
  LIMIT_EXCEEDED = 'The website can not be saved. You exceeded the maximum amount'
  NO_WEBSITES = 'You dont have websites saved'
  REMOVE_INSTRUCTION = 'Send the number of the website you want to remove'
  WEBSITE_REMOVED = 'The website was removed!'
  PROCESSING = 'Processing... 🏃‍♂️'

  def initialize(db_connection)
    super()
    @user_data = {}
    @db_connection = db_connection
    define_commands
  end

  def define_commands
    add_command(name:'/start', description:'send the options', action:
    proc do |event, message, user, instance|
      start(event, message, user, instance)
    end
      )
      add_command( name: '/add_website',
      description: 'return the websites associated to the user',
      action: proc do |event, message, user, instance|
        add_website(event, message, user, instance)
      end)
      add_command( name: '/list_websites',
      description: 'return the websites associated to the user',
      action: proc do |event, message, user, instance|
        list_websites(event, message, user, instance)
      end)
      add_command(name: '/remove_website',
      description: 'delete a website',
      action: proc do |event, message, user, instance|
        remove_website(event, message, user, instance)
      end)
  end

  public
  def start(event, message, user, instance)
    commands = COMMANDS.map { |command| "- /#{command} " }
    message = "#{START}\n#{commands.join("\n")}"

    instance.send_message(user,message)
  end

  def custom_handler(event, message, user, instance)
    instance.send_message(user, PROCESSING)
    if user_data[user.id] == :awaiting_url
      validate_website(event, message, user, instance)
    elsif user_data[user.id] == :awaiting_remove_url
      validate_remove_option(event, message, user, instance)
    else
      instance.send_message(user,INSTRUCTION)
    end
  end

  def validate_website(event, message, user, bot_instance)
    if valid_url(message)
      add_new_website(event, message, user, bot_instance)
    else
      bot_instance.send_message(user,INVALID)
    end
  end

  def add_new_website(event, message, user, bot_instance)
    user_data[user.id] = nil

    if user_websites(user).size < MAX_USER_LIMIT
      save_website(event,message, user, bot_instance)
      bot_instance.send_message(user,WEBSITE_ADDED)
    else
      bot_instance.send_message(user,LIMIT_EXCEEDED)
    end
  end

  def valid_url(message)
    message.start_with?('http://', 'https://') ? message : "https://#{message}"
  end

  def save_website(event, message, user, _bot_instance)
    config = { connection: @db_connection, chat_id: user.id, url: valid_url(message) }
    Services::AddWebsite.new(config).execute
  end

  def add_website(_event, _message, user, bot_instance)
    bot_instance.send_message(user, ADD_WEBSITE)
    @user_data[user.id] = :awaiting_url
  end

  def remove_options(user)
    websites_options(user).map { |index, website| "- #{index} : \"#{website}\"" }.join("\n")
  end

  def websites_options(user)
    Hash[user_websites(user).each_with_index.map { |website, index| [index.to_s, website] }]
  end

  def user_websites(user)
    config = { connection: @db_connection, chat_id: user.id }
    Services::ListWebsites.new(config).execute
  end

  def list_websites(_event, _message, user, bot_instance)
    bot_instance.send_message(user,PROCESSING)

    websites = user_websites(user).map { |website| "- #{website}" }

    message = !websites.empty? ? "Your websites are: \n#{websites.join("\n")}" : NO_WEBSITES

    bot_instance.send_message(user, message)
  end

  def remove_website(event, message, user, bot_instance)
    bot_instance.send_message(user,PROCESSING)

    if !user_websites(user).empty?
      user_data[user.id] = :awaiting_remove_url
      bot_instance.send_message(user, REMOVE_INSTRUCTION)

      new_message = "Active websites: \n#{remove_options(user)}"

      bot_instance.send_message(user, new_message)
    else
      bot_instance.send_message(user,NO_WEBSITES)
    end
  end

  def validate_remove_option(event, message, user, bot_instance)
    if websites_options(user)[message].nil?
      remove_website(event, message, user, bot_instance)
    else
      delete_website(websites_options(user)[message], user)
      bot_instance.send_message(user,WEBSITE_REMOVED)
    end
  end

  def delete_website(website, user)
    config = { connection: @db_connection, website:, chat_id: user.id }
    Services::RemoveWebsite.new(config).execute
  end

end
