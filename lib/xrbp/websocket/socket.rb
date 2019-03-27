require 'uri'
require 'socket'
require 'openssl'

module XRBP
  module WebSocket
    # Low level wrapper around TCPSocket operations, providing
    # mechanisms to negotiate base websocket connection.
    #
    # @private
    class Socket
      DEFAULT_PORTS = {:ws    => 80,
                       :http  => 80,
                       :wss   => 443,
                       :https => 443}


      attr_reader :pipe_broken

      attr_accessor :client

      private

      attr_reader :socket

      public

      def options
        client.options
      end

      def initialize(client)
        @client      = client
        @pipe_broken = false
      end

      def connect
        uri = URI.parse client.url
        host = uri.host
        port = uri.port || DEFAULT_PORTS[uri.scheme.intern]

        @socket = TCPSocket.new(host, port)
        socket.setsockopt(::Socket::IPPROTO_TCP, ::Socket::TCP_NODELAY, 1)

        init_ssl_socket if ['https', 'wss'].include? uri.scheme
        nil
      end

      private

      def init_ssl_socket
        ssl_context = options[:ssl_context] || begin
          ctx = OpenSSL::SSL::SSLContext.new
          ctx.ssl_version = options[:ssl_version] || 'SSLv23'

          # use VERIFY_PEER for verification:
          ctx.verify_mode = options[:verify_mode] ||
                              OpenSSL::SSL::VERIFY_NONE

          cert_store = OpenSSL::X509::Store.new
          cert_store.set_default_paths
          ctx.cert_store = cert_store

          ctx
        end

        @socket = ::OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
        socket.connect
      end

      ###

      public

      def close
        socket.close if socket
      end

      def write(data)
        socket.write data
      end

      def write_nonblock(data)
        begin
          socket.write_nonblock(data)

        rescue IO::WaitReadable
          IO.select([socket]) # OpenSSL needs to read internally
          retry

        rescue IO::WaitWritable, Errno::EINTR
          IO.select(nil, [socket])
          retry

        rescue Errno::EPIPE => e
          @pipe_broken = true
          raise

        rescue OpenSSL::SSL::SSLError => e
          @pipe_broken = true
          raise
        end
      end

      def read_next(dest)
        begin
          read_sockets, _, _ = IO.select([socket], nil, nil, 0.1)

          if read_sockets && read_sockets[0]
            dest << socket.read_nonblock(1024)

            if socket.respond_to?(:pending) # SSLSocket
              dest << socket.read(socket.pending) while socket.pending > 0
            end
          end
        rescue IO::WaitReadable
          # No op

        rescue IO::WaitWritable
          IO.select(nil, [socket])
          retry
        end
      end
    end # class Socket
  end # module WebSocket
end # module XRBP
