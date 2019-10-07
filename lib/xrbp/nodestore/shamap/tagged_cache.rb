module XRBP
  class SHAMap
    # Internal node caching mechanism.
    #
    # TODO timeout mechanism, metrics
    class TaggedCache
      def initialize
        @cache = {}
      end

      def fetch(key)
        @cache[key]
      end

      def canonicalize(key, node)
        @cache[key] = node
      end
    end # class TaggedCache
  end # class SHAMap
end # module XRBP
