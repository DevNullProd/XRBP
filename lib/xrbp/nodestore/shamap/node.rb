require_relative './node_factory'

module XRBP
  class SHAMap
    # Base Node class, all entries stored in tree structures
    # in nodestore DB inherit from this class
    class Node
      extend NodeFactory

      attr_accessor :hash

      TYPES = {
        :error          => 0,
        :infer          => 1,
        :transaction_nm => 2,
        :transaction_md => 3,
        :account_state  => 4
      }

      LEAF_TYPES = [
        :transaction_nm,
        :transaction_md,
        :account_state
      ]

      def initialize(args={})
        @hash = args[:hash]
        @type = args[:type]
        @seq  = args[:seq]
      end

      def leaf?
        LEAF_TYPES.include?(@type)
      end

      def inner?
        false
      end

      def tree_node?
        false
      end

      def update_hash
        raise "abstract: must be called on a subclass"
      end
    end # class Node
  end # class SHAMap
end # module XRBP
