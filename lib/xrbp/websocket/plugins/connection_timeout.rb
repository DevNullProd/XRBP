module XRBP
  module WebSocket
    module Plugins
      # Automatic disconnection if no server data in certain time
      #
      # @example timed out connection
      #   connection = WebSocket::Connection.new "wss://s1.ripple.com:443"
      #   connection.add_plugin :connection_timeout
      #   connection.connection_timeout = 3
      #   connection.connect
      #   sleep(3)
      #   connection.closed? # => true
      class ConnectionTimeout < PluginBase
        include Terminatable

        attr_accessor :connection_timeout

        DEFAULT_TIMEOUT = 10

        def initialize(connection)
          super(connection)
          @connection_timeout = DEFAULT_TIMEOUT
        end

        def timeout?
          Time.now - @last_msg > @connection_timeout
        end

        def added
          plugin = self
          connection.define_instance_method(:connection_timeout=) do |t|
            plugin.connection_timeout = t

            connections.each{ |c|
              c.plugin(ConnectionTimeout)
               .connection_timeout = t
            } if self.kind_of?(MultiConnection)
          end
        end

        def message(msg)
          @last_msg = Time.now
        end

        def opened
          connection.add_work do
            @last_msg = Time.now
            until terminate?             ||
                  connection.force_quit? ||
                  connection.closed?
              connection.async_close! if timeout?
              connection.rsleep(0.1)
            end
          end
        end

        def closed
          terminate!
        end
      end # class ConnectionTimeout

      WebSocket.register_plugin :connection_timeout, ConnectionTimeout
    end # module Plugins
  end # module WebSocket
end # module XRBP
