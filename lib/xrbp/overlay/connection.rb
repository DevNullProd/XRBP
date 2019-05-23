module XRBP
  # The Overlay is the Peer-to-Peer (P2P) network established
  # by rippled node instances to each other. It is what is used
  # to relay transactions and network state as the consensus
  # process is executed.
  #
  # This module facilitates communication with the Overlay P2P
  # network from Ruby.
  module Overlay

    # Primary Overlay Connection Interface, use Connection
    # to send and receive Peer-To-Peer data over the Overlay.
    #
    # @example establishing a connection, reading frames
    #   overlay = XRBP::Overlay::Connection.new "127.0.0.1", 51235
    #   overlay.connect
    #
    #   overlay.read_frames do |frame|
    #     puts "Message: #{frame.type_name} (#{frame.size} bytes)"
    #   end
    class Connection
      attr_reader :host, :port
      attr_accessor :node

      def initialize(host, port)
        @host = host
        @port = port
        @node = Crypto.node
      end

      # @private
      def socket
        @socket ||= TCPSocket.open(host, port)
      end

      # Indicates if the connection is closed
      def closed?
        socket.closed?
      end

      # @private
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

      # @private
      def handshake
        @handshake ||= Handshake.new self
      end

      ###

      # Initiate new connection to peer
      def connect
        ssl_socket.connect
        handshake.execute!
      end

      # Close the connection to peer
      def close!
        ssl_socket.close
      end

      alias :close :close!

      # Send raw data  via this connection
      def write(data)
        ssl_socket.puts(data)
      end

      # Read raw data from connection
      def read
        ssl_socket.gets
      end

      # Read frames from connection until closed, invoking
      # passed block with each.
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
