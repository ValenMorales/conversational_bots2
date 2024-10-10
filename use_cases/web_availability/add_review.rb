# frozen_string_literal: true

require_relative 'request'

{
  host: ENV['DB_HOST'],
  adapter: 'postgresql',
  encoding: 'utf-8',
  database: ENV['POSTGRES_DB'],
  schema_search_path: 'public'
}

module Utils
  ##
  # This class is an implementation of the Write::Base interface, specifically designed
  # to wtite to a PostgresDB used as <b>common storage</b>.
  #
  class AddReview
    attr_reader :config

    def initialize(config)
      @config = config
    end

    # Execute the Postgres utility to write data in the <b>common storage</b>
    #
    def execute
      Utils::Postgres::Request.execute(params)
    end

    private

    def params
      {
        connection: config[:connection],
        query: build_query
      }
    end

    def build_query
      query = 'INSERT INTO websites (owner, url) VALUES ($1, $2);'
      params = [config[:owner], config[:url]]

      [query, params]
    end
  end
end
