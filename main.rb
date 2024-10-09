require_relative 'telegram_bot'
require_relative 'discord_bot'
require_relative 'add_review'

require 'dotenv'
Dotenv.load

TELEGRAM_BOT_TOKEN = ENV['TELEGRAM_TOKEN']
DISCORD_BOT_TOKEN = ENV['DISCORD_TOKEN']
db_connection = ENV['DB_HOST']

START = 'Hello! Use /add_website to add a new website.'
ADD_WEBSITE = 'Please send the URL of the website you want to add.'
WEBSITE_ADDED = 'Thanks! The website has been added. You will be notified if the domain is down'
INVALID = 'Invalid URL. Please enter a valid website.'
INSTRUCTION = 'Send /add_website to add a website.'

custom_handler = Proc.new do |event, message, user, bot_instance|
  if message.start_with?('http://', 'https://')
    save_website(event, message, user, bot_instance)
    bot_instance.send_message(user, WEBSITE_ADDED)
  else
    bot_instance.send_message(user, INVALID)
  end
end

def save_website(event, message, user, bot_instance)
  owner = user.is_a?(Integer) ? user : user.id
  
  config = { connection: db_connection, owner: owner, url: message }
  Utils::AddReview.new(config).execute
end


commands = {
  "start" => {
    description: "/start",
    message: START
  },
  "add_website" => {
    description: "/add_website",
    message: ADD_WEBSITE,
  },
  "/check_status" => {
    description: "/check_status",
    type:"discord",
    action: Proc.new { |event| 
      puts "Chequeando el estado del sistema..."
      event.user.pm("El sistema está funcionando correctamente.")
    }
  },
}


telegram_bot = TelegramBot::WebAvailability.new(TELEGRAM_BOT_TOKEN, commands, custom_handler)

# Inicia el bot
discord_bot = DiscordBot::WebAvailability.new(DISCORD_BOT_TOKEN, commands, custom_handler)

# Create threads to run both bots concurrently
threads = []
threads << Thread.new { telegram_bot.start }
threads << Thread.new { discord_bot.start }

# Wait for both threads to finish execution
threads.each(&:join)
