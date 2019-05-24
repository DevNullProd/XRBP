module XRBP
  module Crypto
    # Generate a new XRPL validator. Takes same params as {Crypto#node}
    def self.validator(key=nil)
      return node(key)
    end

    # Extract Validator ID from Address.
    # Takes same params as {Crypto#parse_node}
    def self.parse_validator(validator)
      return parse_node(validator)
    end

    # Return bool indicating if Validator is valid.
    # Takes same params as {Crypto#node?}
    def self.validator?(validator)
      return node?(validator)
    end
  end # module Crypto
end # module XRBP
