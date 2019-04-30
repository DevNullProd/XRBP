require 'base58'

module XRBP
  module Crypto
    def self.node(key=nil)
      pub = nil
      if key == :secp256k1 || key.nil?
        key = Key::secp256k1
        key[:type] = :secp256k1
        pub = key[:public]

      elsif key.is_a?(Hash)
        pub = key[:public]

      else
        pub = key
        key = {:public => pub}
      end

       sha256 = OpenSSL::Digest::SHA256.new
      node_id = [Key::TOKEN_TYPES[:node_public]].pack("C") + [pub].pack("H*")
       chksum = sha256.digest(sha256.digest(node_id))[0..3]

      { :node => Base58.binary_to_base58(node_id + chksum, :ripple) }.merge(key)
    end
  end # module Crypto
end # module XRBP
