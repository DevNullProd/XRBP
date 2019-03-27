require_relative './parsers/market'
require_relative './parsers/quote'

module XRBP
  module Model
    class Market < Base
      extend Base::ClassMethods
      # TODO plugabble system to pull in markets from other sources

      # Retrieve list of markets via WebClient::Connection
      #
      # @param opts [Hash] options to retrieve market list with
      # @option opts [WebClient::Connection] :connection Connection
      #   to use to retrieve market list
      def self.all(opts={})
        set_opts(opts)
        connection.url = "https://api.cryptowat.ch/assets/xrp"

        connection.add_plugin :result_parser  unless connection.plugin?(:result_parser)
        connection.add_plugin Parsers::Market unless connection.plugin?(Parsers::Market)

        connection.perform
      end

      attr_accessor :route

      def initialize(opts={})
        set_opts(opts)
      end

      def set_opts(opts={})
        super opts
        @route = opts[:route] if opts[:route]
      end

      # Retrieve list of quotes for market via WebClient::Connection
      #
      # @param opts [Hash] options to retrieve quotes with
      # @option opts [WebClient::Connection] :connection Connection
      #   to use to retrieve quotes
      def quotes(opts={})
        set_opts(opts)
        connection.url = self.route

        connection.add_plugin :result_parser unless connection.plugin?(:result_parser)
        connection.add_plugin Parsers::Quote unless connection.plugin?(Parsers::Quote)

        connection.perform
      end
    end # class Market
  end # module Model
end # module XRBP
