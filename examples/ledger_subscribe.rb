$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

ws = XRBP::WebSocket::Connection.new "wss://s1.ripple.com:443"
ws.add_plugin :command_dispatcher
ws.connect

i = 0
ws.on :ledger do |ledger|
  puts ledger

  i += 1
  ws.close! if i > 5
end

XRBP::Model::Ledger.subscribe(:connection => ws)

ws.wait_for_close
