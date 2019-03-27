module XRBP
  module DSL
    # Return ledger object for the specified id
    #
    # @param id [Integer] id of the ledger to query
    # @return [Hash, nil] the ledger object retrieved or nil otherwise
    def ledger(id=nil)
      websocket.add_plugin :autoconnect unless websocket.plugin?(:autoconnect)
      websocket.add_plugin :command_dispatcher unless websocket.plugin?(:command_dispatcher)
      websocket.cmd(WebSocket::Cmds::Ledger.new(id))
    end

    # Subscribed to the ledger stream.
    #
    # After calling this, :ledger events will be emitted via the
    # websocket connection object.
    def subscribe_to_ledgers
      websocket.add_plugin :autoconnect unless websocket.plugin?(:autoconnect)
      websocket.add_plugin :command_dispatcher unless websocket.plugin?(:command_dispatcher)
      websocket.cmd(WebSocket::Cmds::Subscribe.new(:streams => ["ledger"]))
    end
  end # module DSL
end # module XRBP
