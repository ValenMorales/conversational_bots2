# frozen_string_literal: true

require_relative 'base'

module Services
  ##
  # This class is an implementation of the Write::Base interface, specifically designed
  # to wtite to a PostgresDB used as <b>common storage</b>.
  #
  class AddWebsite < Services::Base
    # Execute the Postgres utility to write data in the <b>common storage</b>
    #
    def execute
      website_id = process_website
      chat_id = process_chat

      insert_relation(website_id, chat_id)
    end

    private

    def process_website
      insert_item(WEBSITE_TABLE, WEBSITE_URL, config[:url])

      website = query_item(WEBSITE_TABLE, WEBSITE_URL, config[:url])

      website.values.first.first
    end

    def process_chat
      insert_item(CHATS_IDS_TABLE, CHATS_IDS_ID, config[:chat_id])

      chat = query_item(CHATS_IDS_TABLE, CHATS_IDS_ID, config[:chat_id])

      chat[0]['id']
    end

    def insert_relation(website_id, chat_id)
      query = "INSERT INTO #{RELATION_TABLE} (website_id, telegram_chat_id) VALUES (#{website_id}, #{chat_id});"

      execute_query(query)
    end
  end
end
