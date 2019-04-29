module XRBP
  module Crypto
    module Key
      TOKEN_TYPES = {
        :none             =>  1, # unused
        :node_public      => 28,
        :node_private     => 32,
        :account_id       =>  0,
        :account_public   => 35,
        :account_secret   => 34,
        :family_generator => 41,
        :family_seed      => 33
      }

      ###

      def self.secp256k1
        key = OpenSSL::PKey::EC.new("secp256k1")
                               .generate_key
        {  :public => key.public_key.to_bn.to_s(16),
          :private => key.private_key.to_s(16)}
      end

      def self.ed25519
        # XXX openssl 1.1.1 needed for EdDSA support:
        #     https://www.openssl.org/blog/blog/2018/09/11/release111/
        #     Until then use this:
        require "ed25519"
        key = Ed25519::SigningKey.generate
        {  :public => key.to_bytes.unpack("H*").first.upcase,
          :private => key.verify_key.to_bytes.unpack("H*").first.upcase }
      end
    end
  end # module Crypto
end # module XRBP
