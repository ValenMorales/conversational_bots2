# frozen_string_literal: true

require 'rspec'
require_relative '../bots/bot'

RSpec.describe Bot do
  let(:commands) do
    {
      start: { description: '/start', message: 'Welcome!', type: 'telegram' },
      help: { description: '/help', action: proc { |_event, _text, _user, _bot| 'Help!' }, type: 'discord' }
    }
  end

  let(:unknown_handler) { proc { |_event| 'Unknown command!' } }
  let(:bot) { Bot.new('dummy_token', commands, 'telegram', unknown_handler) }

  describe '#initialize' do
    it 'initializes with token, commands, and unknown command handler' do
      expect(bot.instance_variable_get(:@token)).to eq('dummy_token')
      expect(bot.commands).to eq(commands)
      expect(bot.unknown_command_handler).to eq(unknown_handler)
    end
  end

  describe '#valid_command?' do
    it 'returns true for valid command type' do
      expect(bot.valid_command?(commands[:start])).to be true
    end

    it 'returns false for invalid command type' do
      expect(bot.valid_command?(commands[:help])).to be false
    end
  end

  describe '#add_command' do
    it 'adds a command to processed_commands' do
      bot.add_command('new_command', 'New command added')
      processed_commands = bot.instance_variable_get(:@processed_commands)
      expect(processed_commands).to have_key('new_command')
      expect(processed_commands['new_command'][:message]).to eq('New command added')
    end
  end

  describe '#handle_unknown_command' do
    it 'calls unknown command handler' do
      event = double('event')
      result = bot.handle_unknown_command(event)
      expect(result).to eq('Unknown command!')
    end
  end

  describe '#evaluate_command' do
    context 'when command is known' do
      it 'calls validate_command_type' do
        event = double('event')
        bot.add_command('known_command', 'Known command executed')
        expect(bot).to receive(:validate_command_type)
        bot.evaluate_command('known_command', event)
      end
    end

    context 'when command is unknown' do
      it 'handles unknown command' do
        event = double('event')
        expect(bot.handle_unknown_command(event)).to eq('Unknown command!')
      end
    end
  end
end
# frozen_string_literal: true

# spec/bot_spec.rb
require_relative '../bot'

RSpec.describe Bot do
  let(:commands) do
    {
      start: { description: '/start', message: 'Welcome!', type: 'telegram' },
      help: { description: '/help', action: proc { |_event, _text, _user, _bot| 'Help!' }, type: 'discord' }
    }
  end

  let(:unknown_handler) { proc { |_event| 'Unknown command!' } }
  let(:bot) { Bot.new('dummy_token', commands, 'telegram', unknown_handler) }

  describe '#initialize' do
    it 'initializes with token, commands, and unknown command handler' do
      expect(bot.instance_variable_get(:@token)).to eq('dummy_token')
      expect(bot.commands).to eq(commands)
      expect(bot.unknown_command_handler).to eq(unknown_handler)
    end
  end

  describe '#valid_command?' do
    context 'when the command type is valid' do
      it 'returns true for valid command type' do
        expect(bot.valid_command?(commands[:start])).to be true
      end
    end

    context 'when the command type is invalid' do
      it 'returns false for invalid command type' do
        expect(bot.valid_command?(commands[:help])).to be false
      end
    end
  end

  describe '#add_command' do
    it 'adds a command to processed_commands' do
      bot.add_command('new_command', 'New command added')
      processed_commands = bot.instance_variable_get(:@processed_commands)
      expect(processed_commands).to have_key('new_command')
      expect(processed_commands['new_command'][:message]).to eq('New command added')
    end
  end

  describe '#handle_unknown_command' do
    it 'calls unknown command handler' do
      event = double('event')
      result = bot.handle_unknown_command(event)
      expect(result).to eq('Unknown command!')
    end
  end
end
