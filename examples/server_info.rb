$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

ws = XRBP::WebSocket::Connection.new "wss://s2.ripple.com:443"
ws.add_plugin :command_dispatcher
ws.connect

puts XRBP::Model::Node.new.server_info(:connection => ws)
