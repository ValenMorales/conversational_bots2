require 'telegram/bot'
require 'logger' 

module TelegramBot
  class WebAvailability

    attr_reader :bot

    def initialize(token, commands, unknown_command_handler = nil)
      @commands = commands
      @processed_commands = {}
      @bot = Telegram::Bot::Client.new(token)
      @unknown_command_handler = unknown_command_handler 
    end

    def start
      @commands.each do |command_key, command_info|
        if command_info[:type].nil? || command_info[:type] == "telegram"
          add_command(command_info[:description], command_info[:message], command_info[:action])
        end
      end
      listen
    end

    def add_command(command_description, command_message = nil, command_action = nil)
      @processed_commands[command_description] = {
        message: command_message,
        action: command_action
      }
    end

    def listen
      @bot.listen do |message|
        command = @processed_commands[message.text]
        if command
          if command[:action] # Si hay una acción definida
            execute_action(command[:action], message)
          else
            send_message(message.chat.id, command[:message]) # Enviar mensaje predefinido
          end
        else
          handle_unknown_command(message)
        end
      rescue StandardError => e
        Logger.new($stdout).error("Error: #{e.message}")
      end
    end

    def handle_unknown_command(message)
      if @unknown_command_handler
        @unknown_command_handler.call(message, message.text, message.chat.id, self) 
      else
        send_message(message.chat.id, "Comando desconocido: #{message.text}") 
      end
    end

    def execute_action(action, message)
      if action.is_a?(Proc)
        action.call(message,message.text, message.chat.id, self) 
      end
    end

    def send_message(chat_id, text)
      @bot.api.send_message(chat_id: chat_id, text: text)
    end
  end
end
