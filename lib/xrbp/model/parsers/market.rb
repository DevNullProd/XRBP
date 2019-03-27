module XRBP
  module Model
    # @private
    module Parsers
      # Market List data parser
      #
      # @private
      class Market < PluginBase
        def parser_priority
          0
        end

        def parse_result(res, req)
          j = JSON.parse(res)
          return res unless j["result"] &&
                            j["result"]["markets"] &&
                            j["result"]["markets"]["base"]
          j["result"]["markets"]["base"]
              .collect { |market|
            {:exchange => market["exchange"],
             :currency => market["pair"][3..-1],
             :route    => market["route"]}
          }
        end
      end
    end # module Parsers
  end # module Model
end # module XRBP
