module XRBP
  module WebSocket
    module Plugins
      # Automatically connects on instantiation and reconnects
      # on close events.
      #
      # @example autoconnecting
      #   connection = WebSocket::Connection.new "wss://s1.ripple.com:443"
      #   connection.add_plugin :autoconnect
      #   connection.open? # => true
      class AutoConnect < PluginBase
        attr_accessor :reconnect_delay

        def initialize(connection)
          super(connection)
          @reconnect_delay = nil
        end

        def added
          plugin = self

          connection.define_instance_method(:reconnect_delay=) do |d|
            plugin.reconnect_delay = d

            connections.each{ |c|
              c.plugin(AutoConnect)
               .reconnect_delay = d
            } if self.kind_of?(MultiConnection)
          end

          return if connection.kind_of?(MultiConnection)

          conn = connection
          connection.on :completed do
            connected = false
            until conn.force_quit? || connected
              conn.rsleep(plugin.reconnect_delay) if plugin.reconnect_delay
              next if conn.force_quit?

              begin
                conn.connect
                connected = true
              rescue
                conn.rsleep(3)
              end
            end
          end

          until connection.force_quit? || connection.open?
            begin
              connection.connect
            rescue
              connection.rsleep(3)
            end
          end
        end
      end # class AutoConnect

      WebSocket.register_plugin :autoconnect, AutoConnect
    end # module Plugins
  end # module WebSocket
end # module XRBP
