require 'telegram/bot'
require 'logger' 

module TelegramBot
  class WebAvailability

    def initialize(token, commands, custom_handler = nil)
      @commands = commands
      @processed_commands = {}
      @bot = Telegram::Bot::Client.new(token)
      @user_data = {}
      @custom_handler = custom_handler || method(:default_unknown_command_handler)
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
      @custom_handler.call(message, message.text, message.chat.id, self)
    end

    def default_unknown_command_handler(message, bot_instance)
      bot_instance.send_message(message.chat.id, "Comando desconocido: #{message.text}")
    end

    def send_message(chat_id, text)
      @bot.api.send_message(chat_id: chat_id, text: text)
    end
  end
end
