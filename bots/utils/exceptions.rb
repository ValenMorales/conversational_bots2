module Utils
  module Exceptions
    class FunctionNotImplemented < StandardError
      def initialize(msg = 'This function has not been implemented yet')
        super(message)
      end
    end
  end
end
