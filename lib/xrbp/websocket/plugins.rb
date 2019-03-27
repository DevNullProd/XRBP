module XRBP
  module WebSocket
    include PluginRegistry
  end # module WebSocket
end # module XRPB

require_relative './plugins/autoconnect'
require_relative './plugins/connection_timeout'
require_relative './plugins/message_dispatcher'
require_relative './plugins/command_dispatcher'
require_relative './plugins/command_paginator'
require_relative './plugins/result_parser'
