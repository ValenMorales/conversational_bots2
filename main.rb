require_relative 'telegram_bot'
require_relative 'discord_bot'

require 'dotenv'
Dotenv.load

# Load environment variables for bot tokens and database connection
TELEGRAM_BOT_TOKEN = ENV['TELEGRAM_TOKEN']
DISCORD_BOT_TOKEN = ENV['DISCORD_TOKEN']
db_connection = ENV['DB_HOST']

START = 'Hello! Use /add_website to add a new website.'
ADD_WEBSITE = 'Please send the URL of the website you want to add.'
WEBSITE_ADDED = 'Thanks! The website has been added. You will be notified if the domain is down'
INVALID = 'Invalid URL. Please enter a valid website.'
INSTRUCTION = 'Send /add_website to add a website.'

commands = {
  "start" => {
    description: "/start",
    message: START
  },
  "add_website" => {
    description: "/add_website",
    message: ADD_WEBSITE
  }
}

telegram_bot = TelegramBot::WebAvailability.new(TELEGRAM_BOT_TOKEN, db_connection, commands)

# Inicia el bot
discord_bot = DiscordBot::WebAvailability.new(DISCORD_BOT_TOKEN, db_connection, commands)

# Create threads to run both bots concurrently
threads = []
threads << Thread.new { telegram_bot.start }
threads << Thread.new { discord_bot.execute }

# Wait for both threads to finish execution
threads.each(&:join)
