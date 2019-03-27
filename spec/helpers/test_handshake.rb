module XRBP
  # XXX need to manually set handshake,
  #     else will be different each time,
  #     messing up recordings
  class TestHandshake
    def version
      13
    end

    def to_s
      "GET / HTTP/1.1\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nHost: s1.ripple.com:443\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Key: 0tTEDtzkyx8JPC2rIYYIzA==\r\n\r\n"
    end

    def finished?
      true
    end

    def <<(r)
    end
  end

  module WebSocket
    class Client
      def stub_handshake!
        @handshake = XRBP::TestHandshake.new
      end
    end # class Client
  end # module WebSocket
end # module XRBP
