require 'securerandom'

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

      def self.priv
        seed = SecureRandom.random_bytes(32)
        OpenSSL::Digest::SHA256.new.digest(seed)
      end

      # TODO: look into a builtin implementation (?)
      #       https://medium.com/coinmonks/introduction-to-blockchains-bedrock-the-elliptic-curve-secp256k1-e4bd3bc17d
      def self.secp256k1
            pk = priv
         ecgrp = OpenSSL::PKey::EC::Group.new('secp256k1')
        ecpriv = OpenSSL::PKey::EC.new("secp256k1")
         ecpub = ecgrp.generator.mul(pk.to_bn)

        {  :public => ecpub.to_bn(:compressed).to_s(16),
          :private => priv.unpack("H*").first.upcase}
      end

      def self.ed25519
        # XXX openssl 1.1.1 needed for EdDSA support:
        #     https://www.openssl.org/blog/blog/2018/09/11/release111/
        #     Until then use this:
        require "ed25519"

        # FIXME: this works for now (eg generates valid keys),
        #        but we should do this in the same way rippled does and secp256k1
        #        does above: generate private key, then generate corresponding
        #        Ed25519 public key
        key = Ed25519::SigningKey.generate
        {  :public => key.to_bytes.unpack("H*").first.upcase,
          :private => key.verify_key.to_bytes.unpack("H*").first.upcase }
      end
    end
  end # module Crypto
end # module XRBP
