require 'telegram/bot'

class TelegramBot
  def initialize(token)
    @bot = Telegram::Bot::Client.new(token)
    @commands = {}
  end

  def add_command(command, &block)
    @commands[command] = block
  end

  def start
    @bot.listen do |message|
      if @commands.key?(message.text)
        @commands[message.text].call(message)
      else
        handle_unknown_command(message)
      end
    end
  end

  def handle_unknown_command(message)
    @bot.api.send_message(chat_id: message.chat.id, text: "Comando no reconocido.")
  end
end
