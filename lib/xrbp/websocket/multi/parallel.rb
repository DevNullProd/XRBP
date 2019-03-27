module XRBP
  module WebSocket
    # MultiConnection strategy where requests are sent to
    # all connections in parallel.
    class Parallel < MultiConnection
      class All
        attr_accessor :connections

        def initialize(connections)
          @connections = connections
        end

        def method_missing(m, *args, &bl)
          connections.collect { |c|
            c.send(m, *args, &bl) if c.open?
          }
        end
      end # class All

      def next_connection(prev=nil)
        return nil unless prev.nil?
        All.new connections
      end
    end # class RoundRobin
  end # module WebSocket
end # module XRBP
