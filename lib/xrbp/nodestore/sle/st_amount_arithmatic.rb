module XRBP
  module NodeStore
    class STAmount
      module Arithmatic
        def +(v)
          return self + STAmount.new(:mantissa => v) if v.kind_of?(Numeric)

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
          return self / STAmount.new(:mantissa => v) if v.kind_of?(Numeric)

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
          return self * STAmount.new(:mantissa => o) if o.kind_of?(Numeric)

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
      end # module Arithmatic
    end # class STAmount
  end # module NodeStore
end # module XRBP
