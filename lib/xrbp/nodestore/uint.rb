module XRBP
  module NodeStore
    def self.uint256
      Array.new(32) { 0 }.pack("C*")
    end
  end # module NodeStore
end # module XRBP
