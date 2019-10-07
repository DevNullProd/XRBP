require_relative './shamap/errors'
require_relative './shamap/node_id'
require_relative './shamap/node'
require_relative './shamap/inner_node'
require_relative './shamap/tree_node'
require_relative './shamap/item'
require_relative './shamap/tagged_cache'

module XRBP
  class SHAMap
    def initialize(args={})
            @db = args[:db]
       @version = args[:version]

      if @version == 2
        @root = InnerNode.new :v2    => true,
                              :depth => 0
      else
        @root = InnerNode.new :v2 => false
      end
    end

    def succ(key, last)
      item = upper_bound(key)
      return nil if item == map_end
      return nil if last && item.key.to_bn >= last.to_bn
      return item.key
    end

    def read(key)
      raise if key.zero?
      item = peek_item(key)
       sle = NodeStore::SLE.new :item => item,
                                :key  => key
      #return nil unless key.check?(sle)
       sle
    end

    ###

    def peek_item(key)
      leaf = find_key(key)
      return nil unless leaf
      leaf.peek_item
    end

    def fetch_node(key)
      node = fetch_node_nt(key)
      raise unless node
      node
    end

    # nt = no throw
    def fetch_node_nt(key)
      res = get_cache(key)
      return res if res
      canonicalize(key, fetch_node_from_db(key))
    end

    def fetch_root(key)
      return true if key == root.hash

      root = fetch_node_nt(key)
      return false unless root

      @root = root
      return true
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

    def find_key(key)
      leaf, stack = walk_towards_key(key)
      return nil if leaf && leaf.peek_item.key != key
      leaf
    end

    def fetch_node_from_db(key)
      # XXX: shorthand object decoding by removing unused & type fields
      obj = db[key][9..-1]

      begin
        node = Node.make(obj, 0, :prefix, key, true)

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
      return true unless !v2 || node.depth != 0
      return false if v2 == v2?

      #state = INVALID
      return true
    end

    ###

    def upper_bound(key)
      leaf, stack = walk_towards_key(key)
      until stack.empty?
        node, node_id = *stack.last

        if node.leaf?
          if node.item.key.to_bn > key.to_bn
            return node.item
          end

        else
          branch = nil
          if v2?
            if node.common_prefix?(key)
              branch = node_id.select_branch(key) + 1
            elsif key.to_bn < node.common.to_bn
              branch = 0
            else
              branch = 16
            end
          else
            branch = node_id.select_branch(key) + 1
          end

          inner = node
          branch.upto(15) { |b|
            next if inner.empty_branch?(b)
            node = descend_throw inner, b
            leaf, stack = first_below node, stack, b
            raise Error::MissingNode unless leaf
            return leaf.item
          }
        end

        stack.pop
      end

      map_end
    end

    def walk_towards_key(key)
      stack = []

      in_node = root
      node_id = NodeID.new
      while in_node.inner?
        stack.push [in_node, node_id]

        return nil, stack if v2? && in_node.common_prefix?(key)
        branch = node_id.select_branch(key)
        return nil, stack if in_node.empty_branch?(branch)

        in_node = descend_throw in_node, branch
        if v2?
          if in_node.inner?
            node_id = NodeID.new :depth => in_node.depth,
                                 :key   => in_node.common
          else
            node_id = NodeID.new :depth => 64,
                                 :key   => in_node.key
          end

        else
          node_id = node_id.child_node_id branch
        end
      end

      stack.push [in_node, node_id]
      return in_node, stack
    end

    def descend_throw(parent, branch)
      ret = descend(parent, branch)
      raise Errors::MissingNode, parent.child_hash(branch) if !ret &&
                                                              !parent.empty_branch?(branch)
      ret
    end

    def descend(parent, branch)
      ret = parent.child(branch)
      return ret if ret # || !backed? # TODO (backed)

      node = fetch_node_nt(parent.child_hash(branch))
      return nil if !node || inconsistent_node?(node)

      node = parent.canonicalize_child(branch, node)
      node
    end

    def first_below(node, stack, branch)
      if node.leaf?
        stack.push [node, node.peek_item.key]
        return node, stack
      end

      if stack.empty?
        stack.push [node, NodeID.new]

      else
        if v2?
          stack.push [node, NodeID.new(:depth => node.depth,
                                       :key   => node.common)]

        else
          stack.push [node, stack.last.last.child_node_id(branch)]
        end
      end

      i = 0
      while i < 16
        if !node.empty_branch?(i)
          node = descend_throw(node, i)
          raise if stack.empty?

          if node.leaf?
            stack.push [node, node.peek_item.key]
            return node, stack
          end

          if v2?
            stack.push [node, NodeID.new(:depth => node.depth,
                                         :key   => node.common)]

          else
            stack.push [node, stack.last.last.child_node_id(branch)]
          end

          i = 0 # scan all 16 branches of this new node

        else
          i += 1
        end
      end

      return nil, stack
    end

    public

    def cdir_first(root_index)
      node = read(root_index)
      raise unless node # never probe for dirs
      cdir_next(root_index, node, 0)
    end

    def cdir_next(root_index, node, dir_entry)
      indexes = node.field(:vector256, :indexes)
      raise unless dir_entry <= indexes.size

      if dir_entry >= indexes.size
        nxt = node.field(:uint64, :index_next)
        return nil unless nxt

        nxt = shamap.read(root_index, nxt)
        return nil unless nxt

        return cdir_next(root_index, nxt, 0)
      end

      return indexes[dir_entry], (dir_entry + 1)
    end
  end # class SHAMap
end # module XRBP
