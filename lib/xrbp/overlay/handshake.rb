require 'base64'
require 'openssl'

module XRBP
  module Overlay

    # Overlay Connection Handshake, the first message sent from connection
    # initiator to remote endpoint establishing session. Once connection
    # is successfully established subsequent messages will be encapsulated
    # Frames.
    #
    # XXX this module requires the openssl-ruby gem with the following patches:
    #     https://github.com/ruby/openssl/pull/250
    #
    #     Otherwise the ssl_socket#finished_message and #peer_finished_message
    #     methods will not be available
    #
    #     Currently the only way to apply this is to checkout openssl-ruby, apply
    #     the patches, and then rebuild/reinstall the gem locally!
    #
    # @private
    class Handshake
      attr_reader :connection, :response

      def initialize(connection)
        @connection = connection
      end

      def socket
        connection.ssl_socket
      end

      def node
        connection.node
      end

      ###

      def shared
        @shared ||= begin
          sha512 = OpenSSL::Digest::SHA512.new
          sf = socket.finished_message
          pf = socket.peer_finished_message
          sf = sha512.digest(sf)
          pf = sha512.digest(pf)
          shared = sf.to_bn ^ pf.to_bn
          shared = shared.byte_string
          shared = sha512.digest(shared)[0..31]

          shared = Crypto::Key.sign_digest(node, shared)
          Base64.strict_encode64(shared)
        end
      end

      def data
        @data ||=
"GET / HTTP/1.1\r
User-Agent: rippled-1.1.2\r
Upgrade: RTXP/1.2, RTXP/1.3\r
Connection: Upgrade\r
Connect-As: Leaf, Peer\r
Public-Key: #{node[:node]}\r
Session-Signature: #{shared}\r
\r\n"
      end

      ###

      def execute!
        socket.puts(data)

        @response = ""
        until connection.closed? # || connection.force_quit?
          read_sockets, _, _ = IO.select([socket], nil, nil, 0.1)

          if read_sockets && read_sockets[0]
            begin
              out = socket.read_nonblock(1024)
              @response += out.strip
              break if out[-4..-1] == "\r\n\r\n"
            rescue OpenSSL::SSL::SSLErrorWaitReadable
            end
          end
        end
      end
    end # class Handshake
  end # module WebClient
end # module XRBP
