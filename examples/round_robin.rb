$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

ws = XRBP::WebSocket::RoundRobin.new "wss://s1.ripple.com:443",
                                     "wss://s2.ripple.com:443"

ws.add_plugin :command_dispatcher
ws.connect

puts ws.cmd(XRBP::WebSocket::Cmds::ServerInfo.new)
puts ws.cmd(XRBP::WebSocket::Cmds::ServerInfo.new)
