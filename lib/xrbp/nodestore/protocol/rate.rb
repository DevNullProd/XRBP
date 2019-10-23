module XRBP
  module NodeStore
    class Rate
      attr_reader :rate

      def initialize(rate=nil)
        @rate = rate
      end

      # Rate signifying a 1:1 exchange
      def self.parity
        @parity ||= Rate.new(QUALITY_ONE)
      end

      def to_amount
        STAmount.new :issue    => Issue.no_issue,
                     :mantissa => rate,
                     :exponent =>   -9
      end
    end # class Rate
  end # module NodeStore
end # module XRBP
