require 'base58'

module XRBP
  module Crypto
    # Generate a new XRPL node.
    #
    # @param key [Symbol, Hash] key type to generate or key itself (optional)
    # @return [Hash] node details containing id and pub/priv key pair
    def self.node(key=nil)
      pub = nil
      if key == :secp256k1 || key.nil?
        key = Key::secp256k1
        pub = key[:public]

      elsif key.is_a?(Hash)
        key = Key::secp256k1(key[:seed]) if key[:seed]
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

    # Extract Node ID from Address.
    #
    # @param node [String] Base58 encoded node address
    # @return [String, nil] unique node id or nil if input
    #   if not an node
    def self.parse_node(node)
      begin
        bin = Base58.base58_to_binary(node, :ripple)
      rescue ArgumentError
        return nil
      end

      typ = bin[0]
      chk = bin[-4..-1]
      bin = bin[1...-4]

      return nil unless typ.unpack("C*").first == Key::TOKEN_TYPES[:node_public]

      sha256 = OpenSSL::Digest::SHA256.new
      return nil unless sha256.digest(sha256.digest(typ + bin))[0..3] == chk

      return bin
    end

    # Return boolean indicating if the specified node is valid
    def self.node?(node)
      parse_node(node) != nil
    end
  end # module Crypto
end # module XRBP
