module XRBP
  module WebClient
    module Plugins
      # Plugin to automatically parse and convert webclient results,
      # before returning.
      #
      # @example parse json
      #   connection = WebClient::Connection.new
      #   connection.add_plugin :result_parser
      #
      #   connection.parse_results do |res|
      #     JSON.parse(res)
      #   end
      #
      #   connection.url = "https://data.ripple.com/v2/gateways"
      #   connection.perform
      class ResultParser < ResultParserBase
      end

      WebClient.register_plugin :result_parser, ResultParser
    end # module Plugins
  end # module WebClient
end # module XRBP
