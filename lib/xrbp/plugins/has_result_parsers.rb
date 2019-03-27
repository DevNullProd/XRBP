module XRBP
  # Helper mixing providing result parser management capabilities.
  #
  # @private
  module HasResultParsers
    def parsing_plugins
      raise
    end

    def parse_result(res, req)
      _res = res

      prioritized = parsing_plugins.select { |p|
        p != self && p.respond_to?(:parse_result)

      }.sort { |p1, p2|
        (p1.respond_to?(:parser_priority) ? p1.parser_priority : 1) <=>
        (p2.respond_to?(:parser_priority) ? p2.parser_priority : 1)
      }

      prioritized.each { |plg|
        _res = plg.parse_result(_res, req)
      }
      _res
    end
  end # module HasResultParsers
end # module XRBP
