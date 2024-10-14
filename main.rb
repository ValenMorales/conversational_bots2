# frozen_string_literal: true

require_relative 'bots/telegram_bot'
require_relative 'bots/discord_bot'
require_relative 'use_cases/web_availability/commands'

require 'dotenv'
Dotenv.load

TELEGRAM_BOT_TOKEN = ENV['TELEGRAM_TOKEN']
DISCORD_BOT_TOKEN = ENV['DISCORD_TOKEN']
db_connection = ENV['DB_HOST']

bot_commands = WebsiteBotCommands.new(db_connection)

telegram_bot = TelegramBot.new(TELEGRAM_BOT_TOKEN, bot_commands.commands,
                               bot_commands.method(:custom_handler))
discord_bot = DiscordBot.new(DISCORD_BOT_TOKEN, bot_commands.commands,
                             bot_commands.method(:custom_handler))

threads = []
threads << Thread.new { telegram_bot.start }
threads << Thread.new { discord_bot.start }

threads.each(&:join)

puts 'Bots stopped, exiting program.'
