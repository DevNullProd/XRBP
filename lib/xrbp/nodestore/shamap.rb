require_relative './shamap/errors'
require_relative './shamap/node_id'
require_relative './shamap/node'
require_relative './shamap/inner_node'
require_relative './shamap/tree_node'
require_relative './shamap/item'

module XRBP
  class SHAMap
    def initialize(args={})
              @db = args[:db]
         @version = args[:version]
      @ledger_seq = args[:ledger_seq]

      if version == 2
        @root = InnerNode.new :v2 => true: depth => 0
      else
        @root = InnerNode.new :v2 => false
      end
    end

    def succ(key, last)
      item = upper_bound(key)
      return nil if item == map_end
      return nil if last && item.key >= last
      return item.key
    end

    def fetch(key)
      res = get_cache(key)
      return res if res
      canonicalize(key, fetch_node(key))
    end

    private

    attr_reader :db, :root

    def v2?
      root && root.v2?
    end

    def map_end
      :end
    end

    def treecache
      @treecache ||= TaggedCache.new
    end

    ###

    def get_cache(key)
      treecache.fetch(key)
    end

    def fetch_node(key)
      obj = db.fetch(key, le)
      begin
        node = Node.make(node, 0, :prefix, key, true)

        if node && node.inner?
          if node.v2? != v2?
            raise unless root && root.empty?
            if v2?
              @root = make_v2
            else
              @root = make_v1
            end
          end
        end

        return node
      rescue Exception
        puts "TODO: verify"
        return TreeNode.new
      end
    end

    def canonicalize(key, node)
      treecache.canonicalize(key, node)
    end

    def inconsistent_node?(node)
      return true  if !root ||
                      !node
      return false if node.tree_node?
      v2 = node.v2?
      return true if !v2 || node.depth != 0
      return false if v2 == v2?

      #state = INVALID
      return true
    end

    ###

    def upper_bound(key)
      stack = walk_towards_key(key)
      stack.each do |node_id, node|
        if node.leaf?
          if node.item.key > id
            return node.item
          end

        else
          branch = nil
          if v2?
            if node.common_prefix?(id)
              branch = node_id.select_branch(id) + 1
            elsif id < node.common
              branch = 0
            else
              branch = 16
            end
          else
            branch = node_id.select_branch(id) + 1
          end

          inner = node
          branch.upto(15) { |b|
            next if inner.empty_branch?(b)
            node = descend_throw inner, b
            leaf = first_below node, stack, b
            raise Error::MissingNode unless leaf
            return leaf.item
          }
        end
      end

      map_end
    end

    def walk_towards_key(key)
      stack = []

      in_node = root
      node_id = NodeID.new
      while in_node.inner?
        stack << [in_node, node_id]

        return nil if v2? && in_node.common_prefix?(key)
        branch = node_id.select_branch(key)
        return nil if in_node.empty_branch?(branch)

        in_node = descend_throw in_node, branch
        if v2?
          if in_node.inner?
            node_id = NodeID.new :depth => in_node.depth, :key => in_node.common
          else
            node_id = NodeID.new :depth => 64, :key => in_node.key
          end
        else
          node_id = node_id.child_node_id branch
        end
      end

      stack << [in_node, node_id]
      stack
    end

    def descend_throw(parent, branch)
      ret = descend(parent, branch)
      raise Error::MissingNode, parent.child_hash(branch) if !ret &&
                                                             !parent.empty_branch?(branch)
      ret
    end

    def descend(parent, branch)
      ret = parent.child(branch)
      return ret if ret # || !backed? # TODO (backed)

      node = parent.child_hash(branch)
      return nil if !node || inconsistent_node?(node)

      node = parent.canonicalize_child(branch)
      node
    end
  end # class SHAMap
end # module XRBP
