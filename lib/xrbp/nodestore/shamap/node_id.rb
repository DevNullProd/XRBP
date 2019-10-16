module XRBP
  class SHAMap
    # Encapsulates node key to allow for tree traversal
    class NodeID
      attr_reader :depth, :key

      def initialize(args={})
        @depth ||= args[:depth] || 0
        @key   ||= args[:key]   || NodeStore.uint256
      end

      MASK_SIZE = 64

      # Masks corresponding to each tree level.
      # Used to calculate inner node hash for
      # tree level:
      #   inner node = lookup key & mask
      def masks
        @masks ||= begin
          masks = Array.new(MASK_SIZE)

          i = 0
          selector = NodeStore.uint256
          while(i < MASK_SIZE-1)
            masks[i] = String.new(selector)
            selector[i / 2] = 0xF0.chr
            masks[i+1] = String.new(selector)
            selector[i / 2] = 0xFF.chr
            i += 2
          end
          masks[MASK_SIZE-1] = selector

          masks
        end
      end

      def mask
        @mask ||= masks[depth]
      end

      def select_branch(hash)
        #if RIPPLE_VERIFY_NODEOBJECT_KEYS
        raise if depth >= 64
        raise if (hash.to_bn & mask.to_bn) != key.to_bn
        #end

        br = hash[depth / 2].ord

        if (depth & 1) == 1
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

        child = key.unpack("C*")
        child[depth/2] |= ((depth & 1) == 1) ? branch : (branch << 4)

        NodeID.new :depth => (depth + 1),
                   :key   => child.pack("C*")
      end
    end # class NodeID
  end # class SHAMap
end # module XRBP
