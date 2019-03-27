require_relative './parsers/validator'

module XRBP
  module Model
    class Validator < Base
      extend Base::ClassMethods

      # Retrieve list of validators via WebClient::Connection
      #
      # @param opts [Hash] options to retrieve validator list with
      # @option opts [WebClient::Connection] :connection Connection
      #   to use to retrieve validator list
      def self.all(opts={})
        set_opts(opts)
        connection.url = "https://data.ripple.com/v2/network/validators/"

        connection.add_plugin :result_parser     unless connection.plugin?(:result_parser)
        connection.add_plugin Parsers::Validator unless connection.plugin?(Parsers::Validator)

        connection.perform
      end
    end # class Validator
  end # module Model
end # module XRBP
