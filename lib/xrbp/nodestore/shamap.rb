require_relative './shamap/errors'
require_relative './shamap/node_id'
require_relative './shamap/node'
require_relative './shamap/inner_node'
require_relative './shamap/tree_node'
require_relative './shamap/item'
require_relative './shamap/tagged_cache'

module XRBP
  class SHAMap
    include Enumerable

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

    # Invoke callback block w/ each sequential SHAMap item
    # Implements Enumerable interface.
    def each
      current, stack = *peek_first_item
      until current.nil?
        yield current.item
        current, stack = *peek_next_item(current.item.key, stack)
      end

      return self
    end

    # Return the next key in tree greater than
    # specified one and less than last
    def succ(key, last)
      item = upper_bound(key)
      return nil if item == map_end
      return nil if last && item.key.to_bn >= last.to_bn
      return item.key
    end

    # Read Key from database and return
    # corresponding SLE
    def read(key)
      raise if key.zero?
      item = peek_item(key)
      return nil unless item
       sle = NodeStore::SLE.new :item => item,
                                :key  => key
      #return nil unless key.check?(sle)
       sle
    end

    ###

    # Return node corresponding to key
    # or nil if not found
    def peek_item(key)
      leaf = find_key(key)
      return nil unless leaf
      leaf.peek_item
    end

    # Return node corresponding to first item in map
    def peek_first_item
      stack = []
      node, stack = *first_below(@root, stack)
      return nil unless node
      return node, stack
    end

    # Return node corresponding to next sequential
    # item in map
    def peek_next_item(id, stack)
      raise if stack.empty?
      raise unless stack.last.first.leaf?
      stack.pop

      until stack.empty?
        node, node_id = *stack.last
        raise if node.leaf?

        # Select next higher tree branch
        inner = node
        (node_id.select_branch(id) + 1).upto(15) { |b|
          next if inner.empty_branch?(b)
          node = descend_throw(inner, b)
          leaf, stack = *first_below(node, stack, b)
          raise unless leaf && leaf.leaf?
          return leaf, stack
        }

        stack.pop
      end

      return nil
    end

    # Fetch node from database raising
    # error if it is not found
    def fetch_node(key)
      node = fetch_node_nt(key)
      raise unless node
      node
    end

    # Retrieve node from db.
    # nt = no throw
    def fetch_node_nt(key)
      res = get_cache(key)
      return res if res
      canonicalize(key, fetch_node_from_db(key))
    end

    # Fetch key from database and assign
    # result as root element
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

    # Used to cache nodes by key
    def treecache
      @treecache ||= TaggedCache.new
    end

    ###

    # Return node in cache corresponding to key
    def get_cache(key)
      treecache.fetch(key)
    end

    # Return node in tree corresponding to key, else nil
    def find_key(key)
      leaf, stack = walk_towards_key(key)
      return nil if leaf && leaf.peek_item.key != key
      leaf
    end

    # Retreive specified key from database and
    # create new Node-subclass instance corresponding
    # to record type.
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

    # Canonicalize/cache key/node in treecache
    def canonicalize(key, node)
      treecache.canonicalize(key, node)
    end

    # Return bool indicating if node is
    # inconsistent with this tree
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

    # Return first item in tree _after_ given
    # key (eg whose key is > given key).
    #
    # Given item does not need to be in tree.
    def upper_bound(key)
      # Return traversal stack to key
      leaf, stack = walk_towards_key(key)

      # Pop the stack until empty
      until stack.empty?
        node, node_id = *stack.last

        # If current item is leaf, return if
        # item.key > key
        if node.leaf?
          if node.item.key.to_bn > key.to_bn
            return node.item
          end

        # If inner node, select next higher
        # branch to traverse
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

          # Start traversal from selected branch
          # on up, returning first node below
          # non-empty branches
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

      # If no items > this one, return map_end
      map_end
    end

    # Descends Inner Tree Nodes in NodeStore
    # until we reach non-inner-node.
    #
    # Return complete stack of walk.
    def walk_towards_key(key)
      stack = []

      # Start with root node
      in_node = root
      node_id = NodeID.new

      # Iterate until node is no longer inner
      while in_node.inner?
        stack.push [in_node, node_id]

        return nil, stack if v2? && in_node.common_prefix?(key)

        # Select tree branch which has key
        # we are looking for, ensure it is not empty
        branch = node_id.select_branch(key)
        return nil, stack if in_node.empty_branch?(branch)

        # Descend to branch node
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
          # Get ID of branch node
          node_id = node_id.child_node_id branch
        end
      end

      # Push final node (assumably corresponding to key)
      stack.push [in_node, node_id]

      # Return final node (corresponding to key) and stack
      return in_node, stack
    end

    # Descend to specified branch in parent,
    # throw exception if we cannot
    def descend_throw(parent, branch)
      ret = descend(parent, branch)
      raise Errors::MissingNode, parent.child_hash(branch) if !ret &&
                                                              !parent.empty_branch?(branch)
      ret
    end

    # Retreive node from nodestore corresponding to
    # specified branch of parent.
    def descend(parent, branch)
      ret = parent.child(branch)
      return ret if ret # || !backed? # TODO (backed)

      node = fetch_node_nt(parent.child_hash(branch))
      return nil if !node || inconsistent_node?(node)

      node = parent.canonicalize_child(branch, node)
      node
    end

    # Returns first leaf node at or below the specified
    # node.
    #
    # @param node to evaluation
    # @param stack ancestor node stack
    # @param branch this node is on
    def first_below(node, stack, branch=0)
      # Return node if node is a leaf
      if node.leaf?
        stack.push [node, node.peek_item.key]
        return node, stack
      end

      # Append node to ancestry stack for traversal
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

      # Iterate over non-empty branches
      i = 0
      while i < 16
        if !node.empty_branch?(i)
          # descend into branch
          node = descend_throw(node, i)
          raise if stack.empty?

          # Return first leaf
          if node.leaf?
            stack.push [node, node.peek_item.key]
            return node, stack
          end

          # Continue tree descent at new level
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

      # No node found, return nil and the stack
      return nil, stack
    end

    public

    # Returns first directory index in the specified root index
    #
    # @see cdir_next below
    def cdir_first(root_index)
      node = read(root_index)
      raise unless node # never probe for dirs
      cdir_next(root_index, node, 0)
    end

    # Returns the key of the index in the the node's
    # "indexes" field corresponding to 'dir_entry'.
    #
    # Also returns directory node which contains
    # key of the node being returned.
    #
    # Also returns dir_entry index of next record in
    # directory node.
    #
    # This method handles the special case where dir_entry
    # is greater than the local indexes size but the
    # 'index_next' is also set. In this case, index
    # traversal will continue on the next SLE node
    # whose lookup key is calculated from the root
    # index and 'index_next' value. In this case
    # the directory node and next dir_entry will be
    # set appropriately and returned.
    #
    # @param root_index top level index of the tree
    #   being traversed.
    # @param node SLE containing 'indexes' field from
    #   which the 'dir_entry'th index will be returned
    # @param dir_entry numerical array index to return
    #   from 'indexes'
    def cdir_next(root_index, node, dir_entry)
      indexes = node.field(:vector256, :indexes)
      raise unless dir_entry <= indexes.size

      if dir_entry >= indexes.size
        nxt = node.field(:uint64, :index_next)
        return nil unless nxt

        nxt = read(NodeStore::Indexes::page(root_index, nxt))
        return nil unless nxt

        return cdir_next(root_index, nxt, 0)
      end

      return indexes[dir_entry], node, (dir_entry + 1)
    end
  end # class SHAMap
end # module XRBP
