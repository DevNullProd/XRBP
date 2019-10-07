module XRBP
  class SHAMap
    # Binary data blog stored in DB w/ key
    class Item
      attr_reader :key
      attr_reader :data

      def initialize(args = {})
        @key  = args[:key]
        @data = args[:data]
      end
    end # class Item
  end # class SHAMap
end # module XRBP
