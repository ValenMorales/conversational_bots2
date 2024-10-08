
require 'telegram/bot'
require 'logger' # Para registrar errores

module TelegramBot
  class WebAvailability
    def initialize(token, connection, commands)
      @commands = commands
      @processed_commands = {}
      @bot = Telegram::Bot::Client.new(token)
      @connection = connection
      @user_data = {}
    end

    def start
      @commands.each do |command_key, command_info|
        add_command(command_info[:description], command_info[:message])
      end
      listen 
    end

    def add_command(command_description, command_message)
      @processed_commands[command_description] = command_message
    end

    def listen
      @bot.listen do |message|
        if @processed_commands.key?(message.text) 
          send_message(message.chat.id, @processed_commands[message.text])
        else
          handle_unknown_command(message)
        end
      rescue StandardError => e
        Logger.new($stdout).error("Error: #{e.message}")
      end
    end

    def handle_unknown_command(message)
      send_message(message.chat.id, "Comando desconocido: #{message.text}")
    end

    def send_message(chat_id, text)
      @bot.api.send_message(chat_id: chat_id, text: text)
    end
  end
end