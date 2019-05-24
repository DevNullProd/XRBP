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

      # @return [Hash] new secp256k1 key pair (both public and private components)
      def self.secp256k1(seed=nil)
          # XXX: the bitcoin secp256k1 implementation (which rippled pulls in / vendors)
          #      has alot of nuances which require special configuration in openssl. For
          #      the time being, mitigate this by pulling in & using the ruby
          #      btc-secp256k1 bindings:
          #        https://github.com/cryptape/ruby-bitcoin-secp256k1
          #
          #      Perhaps at some point, we can look into implementing this logic in pure-ruby:
          #        https://medium.com/coinmonks/introduction-to-blockchains-bedrock-the-elliptic-curve-secp256k1-e4bd3bc17d
          require 'secp256k1'

          spk = Secp256k1::PrivateKey.new

          sd, pk = nil
          if seed
            sd,pk = seed,seed

          else
            sd = Crypto.seed[:seed]
            pk = Crypto.parse_seed(sd)
          end

          # FIXME: rippled & ripple-keypairs (& by extension ripple-lib) repeatedly
          #        hash seed until certain it is less than the order of the
          #        curve, we should do this as well (for security)
          #
          #        https://github.com/ripple/rippled/blob/develop/src/ripple/crypto/impl/GenerateDeterministicKey.cpp
          #        https://github.com/ripple/ripple-keypairs/blob/master/src/secp256k1.js
          #
          #        Also look into if setting raw key here has same effect as
          #        secp256k1.mul (as invoked in keypairs)
          sha512 = OpenSSL::Digest::SHA512.new
          pk = sha512.digest(pk)[0..31]

          spk.set_raw_privkey pk

          {  :public => spk.pubkey.serialize.unpack("H*").first,
            :private => spk.send(:serialize),
               :seed => sd,
               :type => :secp256k1 }
      end

      # @return [Hash] new ed25519 key pair (both public and private components)
      def self.ed25519
        # XXX openssl 1.1.1 needed for EdDSA support:
        #     https://www.openssl.org/blog/blog/2018/09/11/release111/
        #     Until then use this:
        require "ed25519"

        sd = Crypto.seed[:seed]
        pk = Crypto.parse_seed(sd)

        sha512 = OpenSSL::Digest::SHA512.new
        pk = sha512.digest(pk)[0..31]

        key = Ed25519::SigningKey.new(pk)
        {  :public => key.verify_key.to_bytes.unpack("H*").first.upcase,
          :private => key.to_bytes.unpack("H*").first.upcase,
             :seed => sd,
             :type => :ed25519 }
      end

      ###

      # Sign the digest using the specified key, returning the result
      #
      # @param key [Hash] key to sign digest with
      # @param data [String] data to sign (must be exactly 32 bytes long!)
      # @return [String] signed digest
      def self.sign_digest(key, data)
        raise "unknown key" unless key.is_a?(Hash) && key[:type] && key[:private]
        raise "invalid data" unless data.length == 32

        if key[:type] == :secp256k1
          require 'secp256k1'

          pk = Secp256k1::PrivateKey.new
          pk.set_raw_privkey [key[:private]].pack("H*")
          sig_raw = pk.ecdsa_sign data, raw: true
          return pk.ecdsa_serialize sig_raw

        elsif key[:type] == :ed25519
          require "ed25519"

          sd = key[:seed]
          pk = Crypto.parse_seed(sd)

          sha512 = OpenSSL::Digest::SHA512.new
          pk = sha512.digest(pk)[0..31]

          pk = Ed25519::SigningKey.new(pk)
          return pk.sign(data)
        end

        raise "unknown key type"
      end

      # Returns bool indicating if data is the result of
      # signing expected value with given key.
      #
      # @param key [Hash] key to use to verify digest
      # @param data [String] signed data
      # @param expected [String] original unsigned data
      # @return [Bool] indicating if signed digest matches
      #   original data
      def self.verify(key, data, expected)
        if key[:type] == :secp256k1
          require 'secp256k1'

          pb = Secp256k1::PublicKey.new :pubkey => [key[:public]].pack("H*"),
                                           :raw => true
          pv = Secp256k1::PrivateKey.new

          return pb.ecdsa_verify expected,
                 pv.ecdsa_deserialize(data), raw: true

        elsif key[:type] == :ed25519
          require "ed25519"

          pk = Ed25519::VerifyKey.new([key[:public]].pack("H*"))
          begin
            return pk.verify(data, expected)
          rescue Ed25519::VerifyError
            return false
          end
        end

        raise "unknown key type"
      end
    end # module Key
  end # module Crypto
end # module XRBP
