require_relative './st_amount_arithmatic'
require_relative './st_amount_comparison'
require_relative './st_amount_conversion'

module XRBP
  module NodeStore
    # Serialized Amount Representation.
    #
    # From rippled docs:
    #   Internal form:
    #     1: If amount is zero, then value is zero and offset is -100
    #     2: Otherwise:
    #        legal offset range is -96 to +80 inclusive
    #        value range is 10^15 to (10^16 - 1) inclusive
    #        amount = value * [10 ^ offset]
    #
    #   Wire form:
    #     High 8 bits are (offset+142), legal range is, 80 to 22 inclusive
    #     Low 56 bits are value, legal range is 10^15 to (10^16 - 1) inclusive
    class STAmount
      include Arithmatic
      include Comparison
      include Conversion

      # DEFINES FROM STAmount.h

      MIN_OFFSET = -96;
      MAX_OFFSET = 80;

      MIN_VAL    = 1000000000000000
      MAX_VAL    = 9999999999999999
      NOT_NATIVE = 0x8000000000000000
      POS_NATIVE = 0x4000000000000000
      MAX_NATIVE = 100000000000000000

      attr_reader :mantissa, :exponent, :neg
      attr_accessor :issue

      alias :value  :mantissa
      alias :offset :exponent

      def self.zero(args={})
        STAmount.new args.merge({:mantissa => 0})
      end

      def self.from_quality(rate)
        return STAmount.new(:issue => NodeStore.no_issue) if rate == 0

        mantissa = rate & ~(255 << (64 - 8))

        exponent = (rate >> (64 - 8)).to_int32 - 100

        return STAmount.new(:issue    => NodeStore.no_issue,
                            :mantissa => mantissa,
                            :exponent => exponent)
      end

      def initialize(args={})
        @issue    = args[:issue]
        @mantissa = args[:mantissa] || 0
        @exponent = args[:exponent] || 0
        @neg      = !!args[:neg]

        canonicalize
      end

      ###

      def native?
        @issue && @issue.xrp?
      end

      def zero?
        @mantissa == 0
      end

      def inspect
        return "0" if zero?

        i = issue.inspect
        i = i == '' ? '' : "(#{i})"
        (native? ? xrp_amount : iou_amount.to_f).to_s +
        (native? ?         "" : i)
      end

      def to_s
        inspect
      end
    end # class STAmount
  end # module NodeStore
end # module XRBP
