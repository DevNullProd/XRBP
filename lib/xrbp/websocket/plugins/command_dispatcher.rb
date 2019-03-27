module XRBP
  module WebSocket
    module Plugins
      # Dispatch commands (based on message dispatcher)
      #
      # @example dispatching server info command
      #   connection = WebSocket::Connection.new "wss://s1.ripple.com:443"
      #   connection.add_plugin :command_dispatcher
      #   puts connection.cmd(WebSocket::Cmds::ServerInfo.new)
      class CommandDispatcher < MessageDispatcher
        def added
          super

          plugin = self

          connection.define_instance_method(:cmd) do |cmd, &bl|
            return next_connection.cmd cmd, &bl if self.kind_of?(MultiConnection)

            cmd = Command.new(cmd) unless cmd.kind_of?(Command)
            msg(cmd, &bl)
          end
        end

        def match_message(msg)
          begin
            return nil if msg.data == ""
            parsed = JSON.parse(msg.data)

          rescue => e
            return nil
          end

          id = parsed['id']
          msg = messages.find { |msg| msg.kind_of?(Command) && msg.id == id }

          return nil unless msg
          [msg, parsed]
        end
      end # class CommandDispatcher

      WebSocket.register_plugin :command_dispatcher, CommandDispatcher
    end # module Plugins
  end # module WebSocket
end # module XRBP
