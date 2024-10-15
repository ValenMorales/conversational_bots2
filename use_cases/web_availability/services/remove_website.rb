# frozen_string_literal: true

require_relative 'base'

module Services
  ##
  # Telegram service to remove association between users and domains
  # when the user execute the /remove_webiste command
  #
  class RemoveWebsite < Services::Base
    def execute
      delete_website(website_id, chat_id)
    end

    private

    def website_id
      website = query_item(WEBSITE_TABLE, WEBSITE_URL, config[:website])

      website.first['id']
    end

    def chat_id
      chat = query_item(CHATS_IDS_TABLE, CHATS_IDS_ID, config[:chat_id])

      chat.first['id']
    end

    def delete_website(website_id, chat_id)
      query = "DELETE FROM websites_telegram_chats WHERE website_id = #{website_id} AND telegram_chat_id = #{chat_id};"

      execute_query(query)
    end
  end
end
