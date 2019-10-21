module XRBP
  class SHAMap
    # Encapsulates node key to allow for tree traversal.
    #
    # Provides branch extraction/generation logic.
    # Since branch is between 0-15, only a nibble (4bits)
    # are needed to store. Thus each char (8bits) can describe
    # 2 tree branches
    class NodeID
      attr_reader :depth, :key

      def initialize(args={})
        @depth ||= args[:depth] || 0
        @key   ||= args[:key]   || NodeStore.uint256
      end

      MASK_SIZE = 65

      # Masks corresponding to each tree level.
      # Used to calculate inner node hash for
      # tree level:
      #   inner node = lookup key & mask
      def self.masks
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

      # Return mask for current tree depth
      def mask
        @mask ||= self.class.masks[depth]
      end

      # Return branch number of specified hash.
      def select_branch(hash)
        #if RIPPLE_VERIFY_NODEOBJECT_KEYS
        raise if depth >= 64
        raise if (hash.to_bn & mask.to_bn) != key.to_bn
        #end

        # Extract hash byte at local node depth
        br = hash[depth / 2].ord

        # Reduce to relevant nibble
        if (depth & 1) == 1
          br &= 0xf
        else
          br >>= 4
        end

        raise unless (br >= 0) && (br < 16)
        br
      end

      # Return NodeID for specified branch under this one.
      def child_node_id(branch)
        raise unless branch >= 0 && branch < 16
        raise unless depth < 64

        # Copy local key and assign branch number to
        # nibble in byte at local depth
        child = key.unpack("C*")
        child[depth/2] |= ((depth & 1) == 1) ? branch : (branch << 4)

        NodeID.new :depth => (depth + 1),
                   :key   => child.pack("C*")
      end
    end # class NodeID
  end # class SHAMap
end # module XRBP
