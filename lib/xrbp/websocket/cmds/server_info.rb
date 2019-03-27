module XRBP
  module WebSocket
    module Cmds
      # The server_info command asks the server for a human-readable version
      # of various information about the rippled server being queried.
      #
      # https://developers.ripple.com/server_info.html
      class ServerInfo < Command
        def initialize
          super({'command' => 'server_info'})
        end
      end
    end # module Cmds
  end # module WebSocket
end # module Wipple
