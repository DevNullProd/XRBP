$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

ws = XRBP::WebSocket::Connection.new "wss://s1.ripple.com:443"

ws.on :connecting do
  puts "Connecting"
end

ws.on :open do
  puts "Opened"
end

ws.on :close do
  puts "Closed"
end

ws.on :error do |e|
  puts "Err #{e}"
end

ws.add_plugin :autoconnect, :connection_timeout
ws.connection_timeout = 3
sleep(20)
