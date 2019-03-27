module XRBP
  module Model
    # @private
    module Parsers
      # Validator list data parser
      #
      # @private
      class Validator < PluginBase
        def parser_priority
          0
        end

        def parse_result(res, req)
          JSON.parse(res)["validators"].collect { |v|
            id = v["validation_public_key"]
            next nil unless id

            {:id     => id,
             :domain => v["domain"]}
          }.compact
        end
      end # class ValidatorParser
    end # module Parsers
  end # module Model
end # module XRBP
