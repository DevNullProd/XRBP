module XRBP
  module NodeStore
    #  Represents a transfer rate.
    #
    # The percent of an amount sent that is charged
    # to the sender and paid to the issuer.
    #
    # https://xrpl.org/transfer-fees.html
    #
    # From rippled docs:
    #   Transfer rates are specified as fractions of 1 billion.
    #   For example, a transfer rate of 1% is represented as
    #     1,010,000,000.
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
        STAmount.new :issue    => NodeStore.no_issue,
                     :mantissa => rate,
                     :exponent =>   -9
      end
    end # class Rate
  end # module NodeStore
end # module XRBP
