module XRBP
  module NodeStore
    class STAmount
      module Comparison
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
      end # module Comparison
    end # class STAmount
  end # module NodeStore
end # module XRBP
