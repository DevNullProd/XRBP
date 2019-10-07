module XRBP
  class SHAMap
    # Terminating tree node referencing concrete data
    class TreeNode < Node
      attr_reader :item

      def initialize(args={})
        super
        @item = args[:item]
      end

      def tree_node?
        true
      end

      def peek_item
        item
      end
    end # class TreeNode
  end # class SHAMap
end # module XRBP
