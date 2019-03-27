$: << File.expand_path('../../../lib', __FILE__)
require 'xrbp'

include XRBP::DSL

Signal.trap("INT") {
  Thread.new {
    websocket.force_quit!
    websocket.close!
  }
}

websocket_msg do |c, msg|
  puts msg
end

subscribe_to_ledgers
websocket_wait
