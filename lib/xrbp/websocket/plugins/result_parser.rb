module XRBP
  module WebSocket
    module Plugins
      # Plugin to automatically parse and convert websocket results,
      # before returning.
      #
      # @example parse json
      #   connection = WebClient::Connection.new "wss://s1.ripple.com:443"
      #   connection.add_plugin :command_dispatcher, :result_parser
      #
      #   connection.parse_results do |res|
      #     JSON.parse(res)
      #   end
      #
      #   puts connection.cmd(WebSocket::Cmds::ServerInfo.new)["result"]["info"]["build_version"]
      class ResultParser < ResultParserBase
        def parser=(p)
          super(p)

          self.connection.connections.each { |conn|
            conn.parse_results &p
          } if self.connection.kind_of?(MultiConnection)

          p
        end
      end # class ResultParser

      WebSocket.register_plugin :result_parser, ResultParser
    end # module Plugins
  end # module WebSocket
end # module XRBP
