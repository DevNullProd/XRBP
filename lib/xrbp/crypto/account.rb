require 'base58'

module XRBP
  module Crypto
    # Generate and new XRPL account.
    #
    # @param key [Symbol, Hash] key type to generate or key itself (optional)
    # @return [Hash] account details containing id and pub/priv key pair
    def self.account(key=nil)
      pub = nil
      if key == :secp256k1 || key.nil?
        key = Key::secp256k1
        key[:type] = :secp256k1
        pub = key[:public]

      elsif key == :ed25519
        key = Key::ed25519
        key[:type] = :ed25519
        pub = "\xED" + key[:public]

      elsif key.is_a?(Hash)
        pub = key[:public]

      else
        pub = key
        key = {:public => pub}
      end

          sha256 = OpenSSL::Digest::SHA256.new
       ripemd160 = OpenSSL::Digest::RIPEMD160.new
      account_id = [Key::TOKEN_TYPES[:account_id]].pack("C") + ripemd160.digest(sha256.digest([pub].pack("H*")))
          chksum = sha256.digest(sha256.digest(account_id))[0..3]

      { :account => Base58.binary_to_base58(account_id  + chksum, :ripple) }.merge(key)
    end

    def self.parse_account(account)
      bin = Base58.base58_to_binary(account, :ripple)
      typ = bin[0]
      chk = bin[-4..-1]
      bin = bin[1...-4]

      return nil unless typ.unpack("C*").first == Key::TOKEN_TYPES[:account_id]

      sha256 = OpenSSL::Digest::SHA256.new
      return nil unless sha256.digest(sha256.digest(typ + bin))[0..3] == chk

      return bin
    end

    def self.account?(account)
      parse_account(account) != nil
    end
  end # module Crypto
end # module XRBP
