module XRBP
  module WebSocket
    # MultiConnection strategy where connections are tried sequentially
    # until one is found that is open & succeeds
    class Fallback < MultiConnection
      def next_connection(prev=nil)
        unless prev.nil?
          return nil if connections.last == prev
          return connections[(connections.index(prev) + 1)..-1].find { |c| !c.closed? }
        end

        connections.find { |c| !c.closed? }
      end
    end # class Fallback
  end # module WebSocket
end # module XRBP
