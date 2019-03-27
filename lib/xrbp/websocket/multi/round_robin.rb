module XRBP
  module WebSocket
    # MultiConnection strategy where connections selected in
    # a circular-round robin manner, where the next connection
    # is always used for the next request even if the current
    # one succeeds.
    class RoundRobin < MultiConnection
      def initialize(*urls)
        super(*urls)
        @current = 0
      end

      def next_connection(prev=nil)
        return nil unless prev.nil?

        c = connections[@current]
        @current += 1
        @current  = 0 if @current >= connections.size
        c
      end
    end # class RoundRobin
  end # module WebSocket
end # module XRBP
