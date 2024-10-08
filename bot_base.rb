module Bot
  class Base
    attr_reader :read_options, :process_options, :write_options
    attr_accessor :read_response, :process_response, :write_response

    def initialize(config)
      @read_options = config[:read_options] || {}
      @process_options = config[:process_options] || {}
      @write_options = config[:write_options] || {}
    end

    # Execute the bot's main workflow
    def execute
      @read_response = read

      write_read_response_in_process

      @process_response = process
      raise Utils::Exceptions::InvalidProcessResponse unless process_response.is_a?(Hash)

      write_read_response_processed

      @write_response = write
    end

    protected

    # Method to read data (to be implemented by subclasses)
    def read
      raise Utils::Exceptions::FunctionNotImplemented
    end

    # Method to process data (to be implemented by subclasses)
    def process
      raise Utils::Exceptions::FunctionNotImplemented
    end

    # Method to write data (to be implemented by subclasses)
    def write
      raise Utils::Exceptions::FunctionNotImplemented
    end

    private

    # Update the status of the read response to "in process"
    def write_read_response_in_process
      return if read_options[:avoid_process].eql?(true) || read_response.id.nil?

      options = { params: { stage: "in process" }, conditions: "id=#{read_response.id}" }

      Write::PostgresUpdate.new(read_options.merge(options)).execute
    end

    # Update the status of the read response to "processed"
    def write_read_response_processed
      return if read_options[:avoid_process].eql?(true) || read_response.id.nil?

      options = { params: { stage: "processed" }, conditions: "id=#{read_response.id}" }

      Write::PostgresUpdate.new(read_options.merge(options)).execute
    end
  end
end
