module XRBP
  module WebSocket
    # MultiConnection strategy where connections are tried
    # sequentially until one succeeds
    class Prioritized < MultiConnection
      def next_connection(prev=nil)
        return nil if prev == connections.last
        return super if prev.nil?
        connections[connections.index(prev)+1]
      end
    end # class Prioritized
  end # module WebSocket
end # module XRBP
