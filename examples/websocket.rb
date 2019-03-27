$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

ws = XRBP::WebSocket::Connection.new "wss://s1.ripple.com:443"

ws.on :open do
  puts "Opened"
  ws.close!
end

ws.on :close do
  puts "Closed"
end

ws.on :error do |e|
  puts "Err #{e}"
end

ws.connect
ws.wait_for_close
