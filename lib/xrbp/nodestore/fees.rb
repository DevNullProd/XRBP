module XRBP
  module NodeStore
    class Fees
      # FIXME where do these get updated in rippled?
      attr_reader :base, :units, :reserve, :increment

      def initialize
        @base      = 0
        @units     = 0
        @reserve   = 0
        @increment = 0
      end

      def account_reserve(owner_count)
        STAmount.new :mantissa => reserve + owner_count + increment
      end
    end # class Fees
  end # module NodeStore
end # module XRBP
