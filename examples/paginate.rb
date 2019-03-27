$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

ws = XRBP::WebSocket::Connection.new "wss://s1.ripple.com:443"

ws.connect
ws.add_plugin :command_dispatcher, :command_paginator
ws.cmd(XRBP::WebSocket::Cmds::AccountObjects.new("rhub8VRN55s94qWKDv6jmDy1pUykJzF3wq", :paginate => true)) do |r|
  puts r
  ws.close!
end

ws.wait_for_close
