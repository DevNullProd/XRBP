module XRBP
  class SHAMap
    module NodeFactory
      # See rippled::SHAMapAbstractNode::make
      def make(node, seq, format, hash, hash_valid)
        node_id = NodeID.new

        if format == :wire
          # TODO

        elsif format == :prefix
          raise if node.size < 4

          prefix   = node[0].ord
          prefix <<= 8
          prefix  |= node[1].ord
          prefix <<= 8
          prefix  |= node[2].ord
          prefix <<= 8
          prefix  |= node[3].ord
          prefix = prefix.to_s(16).upcase

          s = node[4..-1]

          if prefix == NodeStore::Format::HASH_PREFIXES[:tx_id]
            sha512  = OpenSSL::Digest::SHA512.new
            sha512 <<  NodeStore::Format::HASH_PREFIXES[:tx_id]
            sta512 << node
               key  = sha512.digest[0..31]

            item = Item.new(:key => key,
                           :data => node)

            tree_node = {:item => item,
                         :seq  =>  seq,
                         :type => :transaction_nm}
              tree_node[:hash] = hash if hash_valid

            return TreeNode.new(tree_node)

          elsif prefix == NodeStore::Format::HASH_PREFIXES[:leaf_node]
            raise "short PLN node" if s.size < 32

            u = s[-32..-1]
            s = s[0..-33]
            raise "invalid PLN node" if u.zero?

            item = Item.new(:key => u,
                           :data => s)

            tree_node = {:item => item,
                         :seq  => seq,
                         :type => :account_state}
              tree_node[:hash] = hash if hash_valid

            return TreeNode.new(tree_node)

          elsif (prefix == NodeStore::Format::HASH_PREFIXES[:inner_node]) ||
                (prefix == NodeStore::Format::HASH_PREFIXES[:inner_node_v2])
            len = s.size
            isv2 = prefix == NodeStore::Format::HASH_PREFIXES[:inner_node_v2]

            raise "invalid PIN node" if len < 512    ||
                             (!isv2 && (len != 512)) ||
                             ( isv2 && (len == 512))

            ret = InnerNode.new :v2 => isv2

            0.upto(15)  { |i|
              ret.hashes[i] = s[i*32...(i+1)*32]
              ret.is_branch |= (1 << i) unless ret.hashes[i].zero?
            }

            if isv2
              ret.depth = s[512]
              n = (ret.depth + 1)/2
              raise "invalid PIN node" if len != 512 + 1 + n

              0.upto(n-1) { |i|
                ret.common << s[512+1+i]
              }
            end

            if hash_valid
              ret.hash = hash
            else
              ret.update_hash
            end

            return ret

          elsif prefix == NodeStore::Format::HASH_PREFIXES[:tx_node]
            # transaction with metadata
            raise "short TXN node" if s.size < 32

            tx_id = s[-32..-1]
                # XXX: tx_id is last field in binary transaction, keep so
                # it can be parsed w/ other fields later:
                #s = s[0..-33]

            item = Item.new(:key => tx_id,
                           :data => s)

            tree_node = {:item => item,
                         :seq  => seq,
                         :type => :transaction_md}
              tree_node[:hash] = hash if hash_valid

            return TreeNode.new(tree_node)

          else
            raise "Unknown prefix #{prefix}"
          end
        end

        raise "Unknown format"
      end
    end # module NodeFactory
  end # class SHAMap
end # module XRBP
