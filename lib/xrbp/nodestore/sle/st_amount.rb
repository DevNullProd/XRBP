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

      private

      def canonicalize
        if native?
          if @mantissa == 0
            @exponent = 0
            @neg = false
            return
          end

          while @exponent < 0
            @mantissa /= 10
            @exponent += 1
          end

          while @exponent > 0
            @mantissa *= 10
            @exponent -= 1
          end

          raise if @mantissa > MAX_NATIVE
          return
        end

        if @mantissa == 0
          @exponent = -100
          @negative = false
          return
        end

        while ((@mantissa < MIN_VAL) && (@exponent > MIN_OFFSET))
          @mantissa *= 10;
          @exponent -= 1
        end

        while (@mantissa > MAX_VAL)
          raise "value overflow" if (@exponent >= MAX_OFFSET)

          @mantissa /= 10
          @exponent += 1
        end

        if @exponent < MIN_OFFSET || @mantissa < MIN_VAL
          @mantissa = 0;
          @neg      = false;
          @exponent = -100;
          return
        end

        raise "value overflow" if (@exponent > MAX_OFFSET)

        raise unless @mantissa == 0 || (@mantissa >= MIN_VAL    && @mantissa <= MAX_VAL)
        raise unless @mantissa == 0 || (@exponent >= MIN_OFFSET && @exponent <= MAX_OFFSET)
        raise unless @mantissa != 0 ||  @exponent != -100
      end

      public

      ###

      def native?
        @issue && @issue.xrp?
      end

      def zero?
        @mantissa == 0
      end

      def clear
        # From rippled docs:
        #   The -100 is used to allow 0 to sort less than a small positive values
        #   which have a negative exponent.
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
        (neg ? -1 : 1) * mantissa * 10 ** exponent
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
        return STAmount.new :issue => issue if zero?

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
                     :mantissa => (nm * 10**17)/dm + 5,
                     :exponent => (ne - de - 17),
                     :neg      => (neg != v.neg)
      end

      def *(o)
        return STAmount.new :issue => issue if zero? || o.zero?

        if native? && o.native?
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
                     :mantissa => (m1 * m2)/(10**14) + 7,
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
