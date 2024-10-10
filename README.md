## Overview

This tool is designed to simplify the process of generating and customizing bots. It provides a unified codebase that allows the creation of multiple bot instances with consistent functionality while enabling flexibility in the customization of commands and actions.

## Bot Initialization

To initialize a bot, the primary required elements are:

1. **Token**: The unique token provided by the platform (e.g., Telegram, Discord) to authenticate and authorize the bot's actions.
2. **Commands**: A set of defined commands that dictate how the bot responds to user inputs. Commands are customizable and structured to define specific behaviors.

### Initialization Example

```ruby

commands = {
'start' => {
  description: '/start',
  message: 'Welcome to the bot! Use /help for more information.'
},
}

bot = Bot.new(token: 'YOUR_BOT_TOKEN', commands)

```

## Commands

Each command must include a detailed description and follow a defined structure, utilizing Procs for dynamic and reusable logic. The commands are parameterized as follows:

1. **description**: A brief explanation of the command.
2. **message**: If provided, the bot will respond to the command with this predefined message.
3. **action**: If defined, the bot will execute this function when the command is triggered.
4. **type**: If a type is provided, the command logic will be specific to the bot type (e.g., Telegram, Discord).

## Attribute Access

Each function that is executed can access the following attributes via **Procs** to handle dynamic behavior:

- **event**: The specific event returned by the API.
- **message**: The message sent by the user.
- **user**: The user or user ID who sent the message.
- **instance**: The bot instance used to execute actions (e.g., calling `send_message`).

### Command Structure Example

```ruby
# Generic command that sends a message when the user types /help
'help' => {
  description: '/help',
  message: 'Write your question, I will help you.'
},

# Command using bot instance methods to send a message
'message' => {
  description: '/message',
  action: proc do |event, message, user, instance|
    instance.send_message(user, 'Hi user')
  end
},

# Discord-specific command that sends a private message using Discord API
'private_message' => {
  description: '/private_message',
  type: 'discord',
  action: proc do |event, message, user, instance|
    user.pm(user, 'Hi user')
  end
}


