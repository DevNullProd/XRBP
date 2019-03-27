module XRBP
  # Result Parser plugin base class, allows request results
  # to be converted before returning / invoking callback.
  class ResultParserBase < PluginBase
    attr_accessor :parser

    def added
      plugin = self
      connection.define_instance_method(:parse_results) do |&bl|
        plugin.parser = bl
      end
    end

    def parse_result(res, req)
      return res unless parser
      parser.call(res, req)
    end
  end # class ResultParserBase
end # module XRBP
