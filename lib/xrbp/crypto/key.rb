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
      def self.secp256k1
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

          # XXX: I'd like to generate the private key first & set,
          #      but for some reason this doesn't work. When the
          #      keys are loaded for signing/verification later
          #      the public key is not able to verify the signature
          #      generated from the private key set in this way.
          # TODO: Investigate
          #pk = Crypto.parse_seed(Crypto.seed[:seed])
          #spk.set_raw_privkey [pk].pack("H*")

          {  :public => spk.pubkey.serialize.unpack("H*").first,
            :private => spk.send(:serialize) }
      end

      # @return [Hash] new ed25519 key pair (both public and private components)
      def self.ed25519
        # XXX openssl 1.1.1 needed for EdDSA support:
        #     https://www.openssl.org/blog/blog/2018/09/11/release111/
        #     Until then use this:
        require "ed25519"

        # FIXME: this works for now (eg generates valid keys),
        #        but we should do this in the same way rippled does:
        #        Generate private key, then generate corresponding
        #        Ed25519 public key
        key = Ed25519::SigningKey.generate
        {  :public => key.to_bytes.unpack("H*").first.upcase,
          :private => key.verify_key.to_bytes.unpack("H*").first.upcase }
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
          # XXX: see note about this library above
          require 'secp256k1'

          pk = Secp256k1::PrivateKey.new
          pk.set_raw_privkey [key[:private]].pack("H*")
          #pk.pubkey.deserialize [key[:public]].pack("H*")
          sig_raw = pk.ecdsa_sign data, raw: true
          return pk.ecdsa_serialize sig_raw

        #elsif key[:type] == :ed25519
          # TODO
        end

        raise "unknown key type"
      end

      # Returns bool indicating if data is the result of
      # signing expected value with given key.
      def self.verify(key, data, expected)
        if key[:type] == :secp256k1
          # XXX: see note about this library above
          require 'secp256k1'

          pb = Secp256k1::PublicKey.new :pubkey => [key[:public]].pack("H*"),
                                           :raw => true
          pv = Secp256k1::PrivateKey.new

          return pb.ecdsa_verify expected,
                 pv.ecdsa_deserialize(data), raw: true

        #elsif key[:type] == :ed25519
          # TODO
        end

        raise "unknown key type"
      end
    end # module Key
  end # module Crypto
end # module XRBP
