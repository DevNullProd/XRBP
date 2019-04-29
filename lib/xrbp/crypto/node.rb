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

      # trim key to 33 bytes
      pub = pub[0..65]
      bpub = [pub].pack("H*")
      raise unless bpub.size == 33

       sha256 = OpenSSL::Digest::SHA256.new
      node_id = [Key::TOKEN_TYPES[:node_public]].pack("C") + bpub
       chksum = sha256.digest(node_id)[0..3]

      { :node => Base58.binary_to_base58(node_id + chksum, :ripple) }.merge(key)
    end
  end # module Crypto
end # module XRBP
