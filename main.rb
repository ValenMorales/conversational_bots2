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
WEBSITE_ADDED = 'Thanks! The website has been added. You will be notified if the domain is down.'
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

# Function to generate the commands hash from user input
def generate_commands
  commands = {}
  puts "Welcome to the Command Generator. Enter the command details below."

  loop do
    puts "\nEnter command name (or type 'exit' to finish):"
    command_name = gets.chomp.downcase
    break if command_name == 'exit'

    puts "Enter description for '#{command_name}':"
    description = gets.chomp

    puts "Enter message for '#{command_name}' (leave blank if not applicable):"
    message = gets.chomp

    puts "Is this a Discord-specific command? (yes/no)"
    is_discord = gets.chomp.downcase == 'yes'

    # Action block, optional for commands with specific actions
    action = nil
    if is_discord
      puts "Do you want to add a custom action for this command? (yes/no)"
      add_action = gets.chomp.downcase == 'yes'
      if add_action
        puts "Custom action will be added. Example actions will be included in your bot logic."
        action = Proc.new { |event|
          puts "Executing custom action for #{command_name}..."
          event.user.pm("#{command_name.capitalize} action executed!")
        }
      end
    end

    # Building the command hash
    commands[command_name] = {
      description: "/#{command_name}",
      message: message.empty? ? nil : message,
      type: is_discord ? "discord" : nil,
      action: action
    }.compact

    puts "Command '#{command_name}' added!"
  end

  commands
end

# Generate the commands hash by calling the function
generated_commands = generate_commands
puts "\nGenerated Commands JSON:"
puts generated_commands

# Instantiate the bots
telegram_bot = TelegramBot::WebAvailability.new(TELEGRAM_BOT_TOKEN, generated_commands, custom_handler)
discord_bot = DiscordBot::WebAvailability.new(DISCORD_BOT_TOKEN, generated_commands, custom_handler)

# Create threads to run both bots concurrently
threads = []
threads << Thread.new { telegram_bot.start }
threads << Thread.new { discord_bot.start }

# Monitor for 'exit' input to gracefully exit the program
Thread.new do
  loop do
    input = gets.chomp
    if input.downcase == 'exit'
      puts 'Exiting the program...'
      exit 0  # Exit the program immediately
    end
  end
end

# Wait for both threads to finish execution
threads.each(&:join)

puts 'Bots stopped, exiting program.'
