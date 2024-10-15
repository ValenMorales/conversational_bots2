# frozen_string_literal: true

require_relative 'base'

module Services
  ##
  # Telegram service to list websites associated to a user
  # when a user execute the /list_websites command.
  #
  class ListWebsites < Services::Base
    def execute
      user_websites.values.flatten
    end

    private

    def user_websites
      query = "SELECT url FROM telegram_chats JOIN websites_telegram_chats ON telegram_chats.id = telegram_chat_id JOIN websites ON websites.id = website_id WHERE chat_id = '#{config[:chat_id]}';" # rubocop:disable Layout/LineLength

      execute_query(query)
    end
  end
end
