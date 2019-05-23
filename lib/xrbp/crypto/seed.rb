require 'base58'
require 'securerandom'

module XRBP
  module Crypto
    def self.seed(key=nil)
      prefix = nil
      if key == :secp256k1 || key.nil?
        prefix = [Key::TOKEN_TYPES[:family_seed]]
        key = { :type => :secp256k1 }

      elsif key == :ed25519
        prefix = [0x01, 0xE1, 0x4B]
        key = { :type => :ed25519 }

      else
        raise ArgumentError, key
      end

      sha256 = OpenSSL::Digest::SHA256.new
      base = SecureRandom.random_bytes(16)
      pref = (prefix + base.bytes).pack("C*")
      chk = sha256.digest(sha256.digest(pref))[0..3]
      { :seed => Base58.binary_to_base58(pref + chk, :ripple) }.merge(key)
    end

    def self.parse_seed(seed)
      bin = Base58.base58_to_binary(seed, :ripple)
      typ = bin[0]
      chk = bin[-4..-1]
      bin = bin[1...-4]

      # TODO also permit ED25519 prefix (?)
      return nil unless typ.unpack("C*").first == Key::TOKEN_TYPES[:family_seed]

      sha256 = OpenSSL::Digest::SHA256.new
      return nil unless sha256.digest(sha256.digest(typ + bin))[0..3] == chk

      return nil unless bin.size == 16

      return bin
    end

    def self.seed?(seed)
      parse_seed(seed) != nil
    end
  end # module Crypto
end # module XRBP
