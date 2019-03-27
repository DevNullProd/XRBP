module XRBP
  module Model
    # @private
    module Parsers
      # Account Info data parser
      #
      # @private
      class AccountInfo < PluginBase
        def parser_priority
          0
        end

        def parse_result(res, req)
          j = JSON.parse(res)
          # return res unless j.key?("accounts")

          accts = (j["accounts"] || []).collect { |a|
                    {:id        => a["account"],
                     :inception => a["inception"],
                     :parent_id => a["parent"]}
                  }

          {:marker   => j["marker"],
           :accounts => accts}
        end
      end

      # Account Username data parser
      #
      # @private
      class AccountUsername < PluginBase
        def parser_priority
          0
        end

        def parse_result(res, req)
          j = JSON.parse(res)
          # return res unless j.key?("exists")
          j["exists"] ? j["username"] : nil
        end
      end
    end # module Parsers
  end # module Model
end # module XRBP
