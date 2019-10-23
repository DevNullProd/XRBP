module XRBP
  module NodeStore
    class STAmount
      module Conversion
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
