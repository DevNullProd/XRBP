module XRBP
  module Model
    # @private
    module Parsers
      # Market quotes data parser
      #
      # @private
      class Quote < PluginBase
        def parser_priority
          0
        end

        def parse_result(res, req)
          return [] unless res && res != ''

          j = JSON.parse(res)
          return [] unless j["result"]

          j["result"].collect { |p, quotes|
            next nil unless quotes
            quotes.collect { |q|
              t   = q[0]
              o   = q[1]
              h   = q[2]
              l   = q[3]
              c   = q[4]
              vol = q[5]

              # discard invalid data
              # (some exchanges periodically
              #  return '0's for some timestamps,
              #  perhaps for periods with no trades?)
              next nil if o.zero? || h.zero? || l.zero? || c.zero? || vol.zero?

              {:timestamp => Time.at(t).to_datetime,
               :open      => o,
               :high      => h,
               :low       => l,
               :close     => c,
               :volume    => vol}
            }
          }.flatten.compact
        end
      end
    end # module Parsers
  end # module Model
end # module XRBP
