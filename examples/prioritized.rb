$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

ws = XRBP::WebSocket::Prioritized.new "wss://s1.ripple.com:443",
                                      "wss://s2.ripple.com:443"

ws.add_plugin :command_dispatcher, :result_parser
ws.parse_results { |res|
  res["result"]["ledger"]
}
ws.connect

puts ws.cmd(XRBP::WebSocket::Cmds::Ledger.new(28327070))
