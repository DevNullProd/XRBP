# XXX this module requires the openssl-ruby gem with the following patches:
#     https://github.com/ruby/openssl/pull/250
#
#     Otherwise the ssl_socket#finished and #peer_finished methods will
#     not be available
#
#     Currently the only way to apply this is to checkout openssl-ruby, apply
#     the patches, and then rebuild/reinstall the gem locally!

require 'base64'
require 'openssl'

module XRBP
  module Overlay
    class Handshake
      attr_reader :connection

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
          sf = socket.finished
          pf = socket.peer_finished
          sf = sha512.digest(sf)
          pf = sha512.digest(pf)
          shared = sf.to_bn ^ pf.to_bn
          shared = shared.bytes.reverse.pack("C*")
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
    end # class Handshake
  end # module WebClient
end # module XRBP
