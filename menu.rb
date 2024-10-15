# frozen_string_literal: true

require_relative 'use_cases/web_availability/add_review'
require_relative 'bots/telegram_bot'
require_relative 'bots/discord_bot'
require_relative 'use_cases/web_availability/commands'

require 'dotenv'
Dotenv.load
# menu
class Menu
  TELEGRAM_BOT_TOKEN = ENV['TELEGRAM_TOKEN']
  DISCORD_BOT_TOKEN = ENV['DISCORD_TOKEN']

  attr_reader :user_data, :custom_commands, :db_connection

  START = 'Hello! Use /add_data to add new data.'
  ADD_DATA = 'Please send the data you want to add.'
  DATA_ADDED = 'Thanks! The data has been added successfully.'
  INVALID = 'Invalid data. Please enter valid input.'
  INSTRUCTION = 'Send /add_data to add data.'

  def initialize
    @db_connection = ENV['DB_HOST']
    @user_data = {}
    @custom_commands = {}
  end

  def custom_handler(event, message, user, bot_instance)
    owner = user.id
    if @user_data[owner] == :awaiting_data
      validate_data(event, message, user, bot_instance)
    else
      bot_instance.send_message(user, INSTRUCTION)
    end
  end

  def validate_data(_event, message, user, bot_instance)
    if message.strip.empty?
      bot_instance.send_message(user, INVALID)
    else
      save_data(message, user)
      bot_instance.send_message(user, DATA_ADDED)
    end
  end

  def save_data(message, user)
    config = { connection: @db_connection, owner: user.id, data: message }
    Utils::AddReview.new(config).execute # Cambiar según la implementación general
  end

  def add_data(_event, _message, user, bot_instance)
    bot_instance.send_message(user, ADD_DATA)
    @user_data[user.id] = :awaiting_data
  end

  def generate_commands
    puts 'Welcome to the Command Generator. Enter the command details below.'

    loop do
      puts "\nEnter command name (or type 'exit' to finish):"
      command_name = gets.chomp.downcase
      break if command_name == 'exit'

      puts "Enter description for '#{command_name}':"
      gets.chomp

      puts 'Do you want the bot to respond with a message or execute a function? (message/function)'
      action_type = gets.chomp.downcase

      if action_type == 'message'
        puts "Enter the message for '#{command_name}':"
        message = gets.chomp
        @custom_commands[command_name] = {
          description: "/#{command_name}",
          message: message
        }
      elsif action_type == 'function'
        puts "Enter the name of the function for '#{command_name}':"
        function_name = gets.chomp
        @custom_commands[command_name] = {
          description: "/#{command_name}",
          action: proc do |event, message, user, bot_instance|
            send(function_name, event, message, user, bot_instance)
          end
        }
      else
        puts "Invalid choice. Please choose 'message' or 'function'."
      end

      puts "Command '#{command_name}' added!"
    end
  end

  # Ejecutar los bots
  def run_bots
    default_commands = {
      'start' => {
        description: '/start',
        message: START
      },
      'add_data' => {
        description: '/add_data',
        action: proc do |event, message, user, bot_instance|
          add_data(event, message, user, bot_instance)
        end
      }
    }

    all_commands = default_commands.merge(@custom_commands)

    telegram_bot = TelegramBot.new(TELEGRAM_BOT_TOKEN, all_commands, method(:custom_handler))
    discord_bot = DiscordBot.new(DISCORD_BOT_TOKEN, all_commands, method(:custom_handler))

    threads = []
    threads << Thread.new { telegram_bot.start }
    threads << Thread.new { discord_bot.start }

    threads.each(&:join)
  end
end

menu = Menu.new
menu.generate_commands
menu.run_bots
