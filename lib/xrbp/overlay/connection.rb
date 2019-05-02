module XRBP
  module Overlay
    class Connection
      attr_reader :host, :port
      attr_accessor :node

      def initialize(host, port)
        @host = host
        @port = port
        @node = Crypto.node
      end

      def socket
        @socket ||= TCPSocket.open(host, port)
      end

      def ssl_socket
        @ssl_socket ||= begin
          ssl_context = OpenSSL::SSL::SSLContext.new
          ssl_context.ssl_version = :SSLv23
          ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE

          _ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
          _ssl_socket.sync_close = true

          _ssl_socket
        end
      end

      def handshake
        @handshake ||= Handshake.new self
      end

      ###

      def connect
        ssl_socket.connect
        ssl_socket.puts(handshake.data)
        # ... wait for & handle response
      end

      def close
        ssl_socket.close
      end

      def write(data)
        ssl_socket.puts(data)
      end

      def read
        ssl_socket.gets
      end
    end # class Connection
  end # module WebClient
end # module XRBP
