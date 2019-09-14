module XRBP
  class SHAMap
    class NodeID
      def initialize(args={})
        @depth ||= args[:depth]
        @key   ||= args[:key]
      end

      MASK_SIZE = 64

      def mask
        masks = Array.new(MASK_SIZE)

        i = 0
        selector = 0
        while(i < MASK_SIZE-1)
          masks[i] = selector
          selector[i / 2] = 0xF0
          masks[i+1] = selector
          selector[i / 2] = 0xFF
          i += 2
        end
        masks[MASK_SIZE-1] = selector;

        masks[depth]
      end

      def select_branch(branch)
        #if RIPPLE_VERIFY_NODEOBJECT_KEYS
        raise if depth > 64
        raise if branch & mask != key
        #end

        br = branch[depth / 2]

        if (depth & 1)
          br &= 0xf
        else
          br >>= 4
        end

        raise unless (br >= 0) && (br < 16)
        br
      end

      def child_node_id(branch)
        raise unless branch >= 0 && branch < 16
        raise unless depth < 64

        child = key
        child[depth/2] |= (depth & 1) ? branch : (branch << 4)

        SHAMapNodeID.new :depth => (depth + 1), :key => child
      end
    end # class NodeID
  end # class SHAMap
end # module XRBP
