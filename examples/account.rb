$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

ws = XRBP::WebSocket::Connection.new "wss://s2.ripple.com:443"
ws.add_plugin :command_dispatcher
ws.connect

puts XRBP::Model::Account.new(:id => "rDsbeomae4FXwgQTJp9Rs64Qg9vDiTCdBv").info(:connection => ws)
