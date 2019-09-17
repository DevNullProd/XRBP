module XRBP
  class SHAMap
    class InnerNode < Node
      attr_reader :depth, :common

      def initialize(args={})
        @v2    = args[:v2]
        @depth = args[:depth]

        @common    = {}
        @hashes    = {}
        @children  = []
        @is_branch = 0
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

      def empty?
        is_branch == 0
      end

      def empty_branch?(branch)
        (is_branch & (1 << branch)) == 0
      end

      def child_hash(branch)
        raise ArgumentError unless branch >= 0 &&
                                   branch < 16
        hashes[branch]
      end
    end # class InnerNode
  end # class SHAMap
end # module XRBP
