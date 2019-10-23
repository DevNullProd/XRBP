module XRBP
  module NodeStore
    # Serialized Amount Representation.
    class STAmount
      # see: https://github.com/ripple/rippled/blob/b53fda1e1a7f4d09b766724274329df1c29988ab/src/ripple/protocol/STAmount.h#L67
      MIN_VAL = 1000000000000000

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

        # FIXME: XXX: we subtract 97 in iou_amount on the fly below,
        #             whereas in rippled it is subtracted when
        #             parsing a serialized STAmount instance:
        #             https://github.com/ripple/rippled/blob/fccb7e1c70549d2cf47800f9942171fb681b5648/src/ripple/protocol/impl/STAmount.cpp#L127
        #
        #             In other non-serialized-parsing cases such as here
        #             we should store exponent as is but since we subtract
        #             97 below, we need to add it here.
        #
        #             This should be changed to match rippled where the
        #             mantissa and exponent are properly set in all cases
        #             and the iou_amount method is updated to match rippled
        exponent = (rate >> (64 - 8)).to_int32 - 100 + 97

        return STAmount.new(:issue    => NodeStore.no_issue,
                            :mantissa => mantissa,
                            :exponent => exponent)
      end

      def initialize(args={})
        @issue    = args[:issue]
        @mantissa = args[:mantissa] || 0
        @exponent = args[:exponent] || 0
        @neg      = !!args[:neg]
      end

      def native?
        @issue.xrp?
      end

      def zero?
        @mantissa == 0
      end

      def clear
        # see: https://github.com/ripple/rippled/blob/b53fda1e1a7f4d09b766724274329df1c29988ab/src/ripple/protocol/STAmount.h#L224
        @exponent = native? ? 0 : -100

        @neg = false
        @mantissa = 0
      end

      def negate!
        return if zero?
        @neg = !@neg
      end

      def sn_value
        neg ? (-mantissa) : mantissa
      end

      ###

      # In drops!
      def xrp_amount
        neg ? (-value) : value
      end

      alias :drops :xrp_amount

      def iou_amount
        (neg ? -1 : 1) * mantissa * 10 ** (exponent-97)
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

      ###

      def +(v)
        e1 = exponent
        e2 = v.exponent

        m1 = mantissa
        m2 = v.mantissa

        m1 *= -1 if   neg
        m2 *= -1 if v.neg

        while e1 < e2
          m1 /= 10
          e1 += 1
        end

        while e2 < e1
          m2 /= 10
          e2 += 1
        end

        m = m1 + m2
        return STAmount.new :issue => issue if m >= -10 && m <= 10
        return STAmount.new :mantissa => m,
                            :exponent => e1,
                            :issue    => issue if m >= 0
        return STAmount.new :mantissa => -m,
                            :exponent => e1,
                            :issue    => issue
      end

      def -(v)
        self + (-v)
      end

      def /(v)
        if v.is_a?(Rate)
          return self if v == Rate.parity
          return self / v.to_amount
        end

        raise "divide by zero" if v.zero?
        return STAmount.new :issue => issue

        nm = mantissa
        dm = v.mantissa

        ne = exponent
        de = v.exponent

        if native?
          while nm < MIN_VAL
            nm *= 10
            ne -= 1
          end
        end

        if v.native?
          while dm < MIN_VAL
            dm *= 10
            de -= 1
          end
        end

        # see note: https://github.com/ripple/rippled/blob/b53fda1e1a7f4d09b766724274329df1c29988ab/src/ripple/protocol/impl/STAmount.cpp#L1075
        STAmount.new :issue => issue,
                     :mantissa => (nm * 10**17)/dm,
                     :exponent => (ne - de - 17),
                     :neg      => (neg != v.neg)
      end

      def *(o)
        return STAmount.new :issue => issue if zero? || o.zero?

        if native?
          min = sn_value < o.sn_value ?   sn_value : o.sn_value
          max = sn_value < o.sn_value ? o.sn_value :   sn_value

          return STAmount.new :mantissa => min * max
        end

        m1 =   mantissa
        m2 = o.mantissa
        e1 =   exponent
        e2 = o.exponent

        if native?
          while nm < MIN_VAL
            m1 *= 10
            e1 -= 1
          end
        end

        if o.native?
          while dm < MIN_VAL
            m2 *= 10
            e2 -= 1
          end
        end

        # see note: https://github.com/ripple/rippled/blob/b53fda1e1a7f4d09b766724274329df1c29988ab/src/ripple/protocol/impl/STAmount.cpp#L1131
        STAmount.new :issue => issue,
                     :mantissa => (m1 * m2)/(10**14),
                     :exponent => (e1 + e2 + 14),
                     :neg      => (neg != o.neg)
      end

      def -@
        STAmount.new(:mantissa => mantissa,
                     :exponent => exponent,
                     :issue    => issue,
                     :neg      => !neg)
      end

      def <(o)
        return neg if neg && !o.neg
        if mantissa == 0
          return false if o.neg
          return o.mantissa != 0
        end

        return false if o.mantissa == 0
        return  neg  if exponent > o.exponent
        return !neg  if exponent < o.exponent
        return  neg  if mantissa > o.mantissa
        return !neg  if mantissa < o.mantissa

        return false
      end

      def >=(o)
        !(self < o)
      end

      def >(o)
        self >= o && self != o
      end

      def ==(o)
             neg == o.neg      &&
        mantissa == o.mantissa &&
        exponent == o.exponent
      end

      def <=>(o)
        return  0 if self == o
        return -1 if self  < o
        return  1 if self  > o
      end
    end # class STAmount
  end # module NodeStore
end # module XRBP
