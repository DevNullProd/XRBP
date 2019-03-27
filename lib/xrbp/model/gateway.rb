require_relative './parsers/gateway'

module XRBP
  module Model
    class Gateway < Base
      extend Base::ClassMethods

      # Retrieve list of gateways provided WebClient::Connection.
      #
      # @param opts [Hash] options to retrieve gateway list with
      # @option opts [WebClient::Connection] :connection Connection
      #   to use to retrieve gateway list
      def self.all(opts={})
        set_opts(opts)
        connection.url = "https://data.ripple.com/v2/gateways"

        connection.add_plugin :result_parser   unless connection.plugin?(:result_parser)
        connection.add_plugin Parsers::Gateway unless connection.plugin?(Parsers::Gateway)

        connection.perform
      end
    end # class Gateway
  end # module Model
end # module XRBP
