module XRBP
  class SHAMap
    class Node
      def self.make(node, seq, format, key, valid)
        node_id = NodeID.new
        # ...
      end

      def inner?
        false
      end

      def tree_node?
        false
      end
    end # class Node
  end # class SHAMap
end # module XRBP
