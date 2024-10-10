# frozen_string_literal: true

require_relative 'add_review'

# The BotCommands class defines a set of commands and behaviors for a bot to interact with users.
# The bot allows users to add websites and receive notifications if the website's domain is down.
class BotCommands
  attr_reader :user_data

  START = 'Hello! Use /add_website to add a new website.'
  ADD_WEBSITE = 'Please send the URL of the website you want to add.'
  WEBSITE_ADDED = 'Thanks! The website has been added. You will be notified if the domain is down.'
  INVALID = 'Invalid URL. Please enter a valid website.'
  INSTRUCTION = 'Send /add_website to add a website.'

  # Initializes the bot with user data and database connection.
  #
  # @param db_connection [Object] an object representing a database connection for storing user data and websites.
  def initialize(db_connection)
    @user_data = {}
    @db_connection = db_connection
  end

  # Custom command handler for managing the bot's interaction with the user.
  #
  # @param event [Object] the event data associated with the command (not used here).
  # @param message [String] the message text sent by the user.
  # @param user [Object, Integer] the user sending the message. This can be
  # either a user object or an integer representing the user's ID.
  # @param bot_instance [Object] the bot instance responsible for sending and receiving messages.
  #
  # If the user is in the state of awaiting a URL, it validates the website; otherwise, it sends instructions.
  def custom_handler(event, message, user, bot_instance)
    owner = user.id
    if @user_data[owner] == :awaiting_url
      validate_website(event, message, user, bot_instance)
    else
      bot_instance.send_message(user, INSTRUCTION)
    end
  end

  # Validates the website URL sent by the user.
  #
  # @param _event [Object] the event data associated with the command (not used here).
  # @param message [String] the website URL provided by the user.
  # @param user [Object, Integer] the user sending the message.
  # @param bot_instance [Object] the bot instance responsible for sending and receiving messages.
  #
  # If the URL is valid (starts with 'http://' or 'https://'), the website is saved;
  # otherwise, an invalid URL message is sent.

  def validate_website(_event, message, user, bot_instance)
    if message.start_with?('http://', 'https://')
      save_website(message, user, bot_instance)
      bot_instance.send_message(user, WEBSITE_ADDED)
    else
      bot_instance.send_message(user, INVALID)
    end
  end

  # Saves the website URL to the database.
  #
  # @param message [String] the website URL to be saved.
  # @param user [Object, Integer] the user sending the message.
  # @param _bot_instance [Object] the bot instance (not used in this method).
  #
  # This method creates a configuration hash with the connection, owner ID, and URL,
  # and passes it to the AddReview utility for saving.
  def save_website(message, user, _bot_instance)
    config = { connection: @db_connection, owner: user.id, url: message }
    Utils::AddReview.new(config).execute
  end

  # Sends a message prompting the user to add a website, and updates the user's state to awaiting a URL.
  #
  # @param _event [Object] the event data associated with the command (not used here).
  # @param _message [String] the message text sent by the user (not used here).
  # @param user [Object, Integer] the user sending the message.
  # @param bot_instance [Object] the bot instance responsible for sending and receiving messages.
  #
  # This method changes the user's state to :awaiting_url, so the bot knows they are waiting for a URL.
  def add_website(_event, _message, user, bot_instance)
    bot_instance.send_message(user, ADD_WEBSITE)
    @user_data[user.id] = :awaiting_url
  end

  # Defines the available commands for the bot.
  #
  # @return [Hash] a hash where the keys are the command names, and the values
  # contain descriptions and actions for each command.
  #
  # Two commands are defined:
  #  - 'start': Displays a welcome message when the bot starts.
  #  - 'add_website': Prompts the user to add a website and sets their state to awaiting a URL.
  def commands
    {
      'start' => {
        description: '/start',
        message: START
      },
      'add_website' => {
        description: '/add_website',
        action: proc do |event, message, user, bot_instance|
          add_website(event, message, user, bot_instance)
        end
      }
    }
  end
end
