require_relative 'telegram_bot'
require_relative 'discord_bot'

require 'dotenv'
Dotenv.load

# Load environment variables for bot tokens and database connection
TELEGRAM_BOT_TOKEN = ENV['TELEGRAM_TOKEN']
DISCORD_BOT_TOKEN = ENV['DISCORD_TOKEN']
db_connection = ENV['DB_HOST']

# Initialize Telegram and Discord bots with their respective tokens and a shared database connection
telegram_bot = TelegramBot::WebAvailability.new(TELEGRAM_BOT_TOKEN, db_connection)
discord_bot = DiscordBot::WebAvailability.new(DISCORD_BOT_TOKEN, db_connection)

# Create threads to run both bots concurrently
threads = []
threads << Thread.new { telegram_bot.execute }
threads << Thread.new { discord_bot.execute }

# Wait for both threads to finish execution
threads.each(&:join)
