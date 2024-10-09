require 'discordrb'
require 'logger' 

module DiscordBot
  class WebAvailability
    attr_reader :bot

    def initialize(token, commands, unknown_command_handler = nil)
      @bot = Discordrb::Bot.new token: token
      @commands = commands
      @processed_commands = {} 
      @unknown_command_handler = unknown_command_handler
    end

    def start
      @commands.each do |command_key, command_info|
        if command_info[:type].nil? || command_info[:type] == "discord" 
          if command_info[:action]
            add_command(command_info[:description], nil, command_info[:action])
          else
            add_command(command_info[:description], command_info[:message])
          end
        end
      end

      read
    end

    def add_command(command_description, command_message = nil, command_action = nil)
      if command_action
        @processed_commands[command_description] = { action: command_action }
      else
        @processed_commands[command_description] = { message: command_message }
      end
    end

    def read
      @bot.message do |event|
        process_message(event)
      rescue StandardError => e
        Logger.new($stdout).error("Error: #{e.message}")
      end

      @bot.run
    end

    def process_message(event)
        process_command(event)
    end

    def process_command(event)
      command = event.content.split.first
      puts @processed_commands.keys
      if @processed_commands.key?(command)
        command_data = @processed_commands[command]

        if command_data[:message] # Si hay un mensaje predefinido
          send_message(event.user, command_data[:message])
        elsif command_data[:action] # Si hay una acción definida
          execute_action(command_data[:action], event)
        end
      else
        handle_unknown_command(event)
      end
    end

    def execute_action(action, event)
      if action.is_a?(Proc)
        action.call(event, event.content, event.user, self) 
      else
        send_message(event.user, "Acción no válida o no ejecutable.")
      end
    end

    def handle_unknown_command(event)
      if @unknown_command_handler
        @unknown_command_handler.call(event, event.content, event.user, self)
      end 
    end

    # Envía un mensaje a un usuario específico
    def send_message(user, text)
      user.pm(text)  
    end
  end
end