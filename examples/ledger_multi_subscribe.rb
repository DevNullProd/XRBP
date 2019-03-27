$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

ws = XRBP::WebSocket::Parallel.new "wss://s1.ripple.com:443",
                                   "wss://s2.ripple.com:443"
ws.add_plugin :command_dispatcher
ws.connect

l = 0
ws.on :message do |connection,msg|
  msg = JSON.parse(msg.data)
  next unless msg["ledger_index"] && msg["ledger_index"] > l
          l = msg["ledger_index"]
  puts msg
end

XRBP::Model::Ledger.subscribe(:connection => ws)

#ws.wait_for_close
sleep(1) while true
