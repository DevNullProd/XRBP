$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

ws = XRBP::WebSocket::Connection.new "wss://s1.ripple.com:443"
ws.add_plugin :command_dispatcher
ws.connect

puts XRBP::Model::Ledger.new.sync(:connection => ws)

XRBP::Model::Ledger.new.sync(:connection => ws) do |l|
  puts l
  ws.close!
end

ws.wait_for_close
