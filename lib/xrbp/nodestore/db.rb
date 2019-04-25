module XRBP
  module NodeStore
    class DB
      include Enumerable
      include EventEmitter

      def ledger(hash)
        obj = self[hash]
        obj = Format::LEDGER.decode(obj)
               obj['close_time'] = XRBP::from_xrp_time(obj['close_time']).utc
        obj['parent_close_time'] = XRBP::from_xrp_time(obj['parent_close_time']).utc
        obj['parent_hash'].upcase!
        obj['tx_hash'].upcase!
        obj['account_hash'].upcase!
        obj
      end
    end # class DB
  end # module NodeStore
end # module XRBP
