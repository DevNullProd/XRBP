module XRBP
  module Model
    # @private
    module Parsers
      # Node Peers data parser
      #
      # @private
      class NodePeers < PluginBase
        def parser_priority
          0
        end

        def parse_result(res, req)
          JSON.parse(res)["overlay"]["active"]
        end
      end
    end # module Parsers
  end # module Model
end # module XRBP
