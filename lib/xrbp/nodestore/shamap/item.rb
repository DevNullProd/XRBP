module XRBP
  class SHAMap
    class Item
      attr_reader :key
      attr_reader :data

      def initialize(key, data)
        @key = key
        @data = data
      end
    end # class Item
  end # class SHAMap
end # module XRBP
