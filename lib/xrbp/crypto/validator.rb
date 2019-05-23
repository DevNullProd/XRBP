module XRBP
  module Crypto
    # Generate a new XRPL validator. Takes same params as {#node}
    def self.validator(key=nil)
      return node(key)
    end

    def self.parse_validator(validator)
      return parse_node(validator)
    end

    def self.validator?(validator)
      return node?(validator)
    end
  end # module Crypto
end # module XRBP
