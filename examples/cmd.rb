$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

ws = XRBP::WebSocket::Connection.new "wss://s1.ripple.com:443"

ws.connect
ws.add_plugin :command_dispatcher
ws.cmd(XRBP::WebSocket::Cmds::ServerInfo.new) do |r|
  puts r
  ws.close!
end

ws.wait_for_close
