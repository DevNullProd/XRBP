module XRBP
  module NodeStore
    class DB
      include Enumerable
      include EventEmitter

      def ledger(hash)
        parse_ledger(self[hash])
      end

      def account(hash)
        parse_account(self[hash])
      end

      def tx(hash)
        parse_tx(self[hash])
      end

      def inner_node(hash)
        parse_inner_node(self[hash])
      end

      ###

      private

      def parse_ledger(ledger)
        obj = Format::LEDGER.decode(ledger)
               obj['close_time'] = XRBP::from_xrp_time(obj['close_time']).utc
        obj['parent_close_time'] = XRBP::from_xrp_time(obj['parent_close_time']).utc
        obj['parent_hash'].upcase!
        obj['tx_hash'].upcase!
        obj['account_hash'].upcase!
        obj
      end

      def parse_account(account)
        # ...
        account
      end

      def parse_tx(tx)
        # ...
        tx
      end

      def parse_inner_node(node)
        Format::INNER_NODE.decode(node)
      end

      protected

      def infer_type(value)
                obj = Format::TYPE_INFER.decode(value)
          node_type = Format::NODE_TYPES[obj["node_type"]]
        hash_prefix = Format::HASH_PREFIXES[obj["hash_prefix"].upcase]

        if hash_prefix == :inner_node
          return :inner_node, parse_inner_node(value)

        elsif node_type == :account_node
          return :account, parse_account(value)

        elsif node_type == :tx_node
          return :tx, parse_tx(value)

        elsif node_type == :ledger
          return :ledger, parse_ledger(value)
        end

        return nil
      end
    end # class DB
  end # module NodeStore
end # module XRBP
