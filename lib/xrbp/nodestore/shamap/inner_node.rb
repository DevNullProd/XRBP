module XRBP
  class SHAMap
    # A DB entry which may contain references of up to 16-child
    # nodes, facilitating abstract tree-like traversal.
    #
    # This class simply encapsulates children w/ hashes
    class InnerNode < Node
      attr_accessor :depth, :common, :hashes, :is_branch

      def initialize(args={})
        @v2    = args[:v2]
        @depth = args[:depth] || 0

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

      # Returns true if node has no children
      def empty?
        is_branch == 0
      end

      # Return true if specified branch is empty,
      # else false
      def empty_branch?(branch)
        (is_branch & (1 << branch)) == 0
      end

      # Returns hash of child on given branch
      def child_hash(branch)
        raise ArgumentError unless branch >= 0 &&
                                   branch < 16
        hashes[branch]
      end

      # Returns child containing in given branch
      def child(branch)
        raise ArgumentError unless branch >= 0 &&
                                   branch < 16
        @children[branch]
      end

      # Canonicalize and store child node at branch
      def canonicalize_child(branch, node)
        raise ArgumentError unless branch >= 0 &&
                                   branch < 16
        raise unless node
        raise unless node.hash == hashes[branch]

        if @children[branch]
          return @children[branch]
        else
          return @children[branch] = node
        end
      end

      # Update this node's hash from child hashes
      def update_hash
        nh = nil

        if is_branch != 0
          sha512 = OpenSSL::Digest::SHA512.new
          sha512 << HASH_+PREFIXES[:inner_node]
          hashes.each { |k,h|
            sha512 << v
          }
          nh = sha512.digest
        end

        return false if nh == self.hash
        self.hash = nh
        return true
      end
    end # class InnerNode
  end # class SHAMap
end # module XRBP
