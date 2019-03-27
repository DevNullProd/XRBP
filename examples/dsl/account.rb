$: << File.expand_path('../../../lib', __FILE__)
require 'xrbp'

include XRBP::DSL

# override endpoints
#def websocket_endpoints
#  ["wss://s1.ripple.com:443", "wss://s2.ripple.com:443"]
#end

# override websocket
#def websocket
#  @websocket ||= WebSocket::Prioritized.new *websocket_endpoints
#end

puts account_info("rhub8VRN55s94qWKDv6jmDy1pUykJzF3wq")
