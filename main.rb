require_relative 'telegram_bot'
require_relative 'discord_bot'

require 'dotenv'
Dotenv.load

TELEGRAM_BOT_TOKEN = ENV['TELEGRAM_TOKEN']
DISCORD_BOT_TOKEN = ENV['DISCORD_TOKEN']

# Variable común para la conexión a la base de datos
db_connection = ENV['DB_HOST']

# Instanciar bots para Telegram y Discord
telegram_bot = TelegramBot::WebAvailability.new(TELEGRAM_BOT_TOKEN, db_connection)
discord_bot = DiscordBot::WebAvailability.new(DISCORD_BOT_TOKEN, db_connection)

# Ejecutar ambos bots de manera concurrente
threads = []
#telegram_bot.execute
threads << Thread.new { telegram_bot.execute }
threads << Thread.new { discord_bot.execute }

# Esperar que ambos bots finalicen
threads.each(&:join)
