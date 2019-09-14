module XRBP
  class SHAMap
    class InnerNode < Node
      attr_reader :depth, :common

      def initialize(args={})
        @v2    = args[:v2]
        @depth = args[:depth]

        @common    = []
        @hashes    = []
        @children  = []
        @is_branch = false
      end

      def v2?
        @v2
      end

      def inner?
        true
      end

      def common_prefix?(key)
        hd = depth/2
        0.upto(hd) do |d|
          return false if common[d] != key[d]
        end

        return (common[hd] & 0xF0) &&
               (key[hd]    & 0xF0) if depth & 1

        return true
      end

      def empty_branch?(branch)
        # ...
      end

      def child_hash(branch)
        # ...
      end
    end # class InnerNode
  end # class SHAMap
end # module XRBP
