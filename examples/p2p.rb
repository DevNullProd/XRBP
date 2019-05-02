gem 'openssl', '2.1.3'

$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

overlay = XRBP::Overlay::Connection.new "127.0.0.1", 51235
overlay.connect
puts overlay.handshake.response

overlay.read_frames do |frame|
  puts "Message: #{frame.type_name} (#{frame.size} bytes)"
end

overlay.close
