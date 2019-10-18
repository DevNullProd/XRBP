require 'sqlite3'

module XRBP
  module NodeStore
    class SQLDB
      def initialize(dir)
        @dir = dir
      end

      def ledger_db
        @ledger_db ||= SQLite3::Database.new File.join(@dir, "ledger.db")
      end

      def tx_db
        @ledger_db ||= SQLite3::Database.new File.join(@dir, "transaction.db")
      end

      def ledger_hash_for_seq(seq)
        ledger_db.execute("select LedgerHash from ledgers where LedgerSeq = ?", seq).first.first
      end
    end # class SQLDB
  end # module NodeStore
end # module XRBP
