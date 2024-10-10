## Overview

This tool is designed to simplify the process of generating and customizing bots. It provides a unified codebase that allows the creation of multiple bot instances with consistent functionality while enabling flexibility in the customization of commands and actions.

## Access to Attributes

Each function executed within the bot framework has access to the following attributes:

- **event**: The specific event returned by the bot’s API.
- **message**: The message sent by the user.
- **user**: The user who sent the message.
- **instance**: The current instance of the bot, allowing actions like sending messages using `send_message`.

## Commands

Each command within the bot framework must follow this structure:

1. **description**: A brief explanation of the command.
2. **message**: If provided, the bot will respond to the command with this predefined message.
3. **action**: If defined, the bot will execute this function when the command is triggered.
4. **type**: If a type is provided, the command logic will be specific to the bot type (e.g., Telegram, Discord).

### Command Structure Example

```ruby
'start' => {
  description: '/start',
  message: 'Welcome to the bot! Use /help for more information.'
},
'add_website' => {
  description: '/add_website',
  action: proc do |event, message, user, instance|
    instance.send_message(user, 'Please provide the URL of the website you want to add.')
  end
}

