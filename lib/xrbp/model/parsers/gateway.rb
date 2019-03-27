module XRBP
  module Model
    # @private
    module Parsers
      # Gateway list data parser
      #
      # @private
      class Gateway < PluginBase
        def parser_priority
          0
        end

        def parse_result(res, req)
          gateways = []

          j = JSON.parse(res)
          j.each_key { |currency|
            j[currency].each { |currency_gateway|
              id   = currency_gateway["account"]
              name = currency_gateway["name"]
              gateway = gateways.find { |gw| gw[:id] == id }
              if gateway
                gateway[:currencies] << "#{currency}"
                gateway[:names]      << "#{name}" unless gateway[:names].include?(name)

              else
                gateways << {:id          => id,
                             :names       => [name],
                             :currencies  => [currency],
                             :start_date  => currency_gateway["start_date"]}
              end
            }
          }

          gateways
        end
      end # class GatewayParser
    end # module Parsers
  end # module Model
end # module XRBP
