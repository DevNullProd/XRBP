module XRBP
  module NodeStore
    class STAmount
      module Conversion
        module ClassMethods
          # @see {NodeStore::Parser::parse_amount}
          def from_wire(data)
            native = (data &  STAmount::NOT_NATIVE) == 0
               neg = (data & ~STAmount::NOT_NATIVE &  STAmount::POS_NATIVE) == 0
             value = (data & ~STAmount::NOT_NATIVE & ~STAmount::POS_NATIVE)

            if native
              STAmount.new :issue => NodeStore.xrp_issue,
                           :neg   => neg,
                           :mantissa => value
            else
               exp = (value >> 54) - 97
              mant = value & 0x3fffffffffffff
              STAmount.new :neg => neg,
                      :exponent => exp,
                      :mantissa => mant
            end
          end

          # Convert string to STAmount
          #
          # @see STAmount#amountFromString (in rippled)
          def parse(str, issue=nil)
            match = "^"+                      # the beginning of the string
                    "([-+]?)"+                # (optional) + or - character
                    "(0|[1-9][0-9]*)"+        # a number (no leading zeroes, unless 0)
                    "(\\.([0-9]+))?"+         # (optional) period followed by any number
                    "([eE]([+-]?)([0-9]+))?"+ # (optional) E, optional + or -, any number
                    "$"
            match = Regexp.new(match)
            match = str.match(match)
            raise "Number '#{str}' is not valid" unless match

            # Match fields:
            #
            #   0 = whole input
            #   1 = sign
            #   2 = integer portion
            #   3 = whole fraction (with '.')
            #   4 = fraction (without '.')
            #   5 = whole exponent (with 'e')
            #   6 = exponent sign
            #   7 = exponent number
            raise "Number '#{str}' is overlong" if (match[2].length +
                                                    match[4].length) > 32

            neg = !!match[1] && match[1] == '-'

            raise "XRP must be specified in integral drops" if issue && issue.xrp? && !!match[3]

            mantissa = 0
            exponent = 0

            if !match[4]
              # integral only
              mantissa = match[2].to_i

            else
              # integer and fraction
              mantissa = (match[2] + match[4]).to_i
              exponent = -(match[4].length)
            end

            if !!match[5]
              # exponent
              if match[6] && match[6] == '-'
                exponent -= match[7].to_i
              else
                exponent += match[7].to_i
              end
            end

            return STAmount.new :issue => issue,
                             :mantissa => mantissa,
                             :exponent => exponent,
                                  :neg => neg
          end
        end

        def self.included(base)
          base.extend(ClassMethods)
        end

        # Encode STAmount into binary format
        def to_wire
          xrp_bit = ((native? ? 0 : 1) << 63)
          neg_bit = ((   neg  ? 0 : 1) << 62)
          value_bits = native? ? mantissa :
                    (((exponent+97) << 54) + mantissa)

          xrp_bit + neg_bit + value_bits
        end

        ###

        def to_h
          {:mantissa => mantissa,
           :exponent => exponent,
           :neg      => neg,
           :issue    => issue.to_h}
        end

        def negate!
          return if zero?
          @neg = !@neg
        end

        ###

        protected

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

        def clear
          # From rippled docs:
          #   The -100 is used to allow 0 to sort less than a small positive values
          #   which have a negative exponent.
          @exponent = native? ? 0 : -100

          @neg = false
          @mantissa = 0
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
      end # module Conversion
    end # class STAmount
  end # module NodeStore
end # module XRBP
