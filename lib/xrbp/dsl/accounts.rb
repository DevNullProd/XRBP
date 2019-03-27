module XRBP
  module DSL
    # Return info for the specified account id
    #
    # @param id [String] account id to query
    # @return [Hash, nil] the account info or nil otherwise
    def account_info(id)
      websocket.add_plugin :autoconnect unless websocket.plugin?(:autoconnect)
      websocket.add_plugin :command_dispatcher unless websocket.plugin?(:command_dispatcher)
      websocket.cmd(WebSocket::Cmds::AccountInfo.new(id))
    end
  end # module DSL
end # module XRBP
