module XRBP
  module DSL
    # Default websocket endpoints. Override to specify
    # different ones.
    def websocket_endpoints
      ["wss://s1.ripple.com:443", "wss://s2.ripple.com:443"]
    end

    # Client which may be used to access websocket endpoints.
    #
    # By default a RoundRobin strategy will be used to cycle
    # through specified endpoints.
    def websocket
      @websocket ||= WebSocket::RoundRobin.new *websocket_endpoints
    end

    # Register a callback to be invoked when messages are received
    # via websocket connections
    def websocket_msg(&bl)
      websocket.on :message, &bl
    end

    # Block until all websocket connections are closed
    def websocket_wait
      websocket.wait_for_close
    end
  end # module DSL
end # module XRBP
