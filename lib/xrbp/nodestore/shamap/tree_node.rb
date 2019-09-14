module XRBP
  class SHAMap
    class TreeNode < Node
      attr_reader :item

      def initialize(args={})
        @item = args[:item]
      end

      def tree_node?
        true
      end
    end # class TreeNode
  end # class SHAMap
end # module XRBP
