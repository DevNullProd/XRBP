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

      def closed?
        socket.closed?
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
        handshake.execute!
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

      def read_frames
        frame = nil
        remaining = nil
        while !closed?
          read_sockets, _, _ = IO.select([ssl_socket], nil, nil, 0.1)
          if read_sockets && read_sockets[0]
            out = ssl_socket.read_nonblock(1024)

            if frame.nil?
              type = Frame::TYPE_INFER.decode(out)
              frame = Frame.new type["type"], type["size"]
              out = out[Frame::TYPE_INFER.size..-1]
            end

            _, remaining = frame << out
            if frame.complete?
              # TODO extra specific protobuf data structure
              #      from data, set on frame
              yield frame
              frame = nil
            end

            # XXX: doesn't feel right to just
            #      discard remaining, look into this
          end
        end
      end
    end # class Connection
  end # module WebClient
end # module XRBP
