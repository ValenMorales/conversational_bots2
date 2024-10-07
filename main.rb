require_relative 'bots/telegram_bot' 
require_relative 'bots/discord_bot' 

require 'dotenv'
Dotenv.load
token = ENV['TELEGRAM_TOKEN']

TELEGRAM_BOT_TOKEN = token
DISCORD_BOT_TOKEN = ENV['DISCORD_TOKEN']

bot = Bots::WebAvailability.new(TELEGRAM_BOT_TOKEN, ENV['DB_HOST'])

bot.execute
