require 'sqlite3'

module XRBP
  module NodeStore
    # Wraps sqlite3 database created/maintianed by rippled. Allows client
    # to query for data stored in sql database.
    class SQLDB

      # SQL DB intializer
      #
      # @param dir [String] directory containing binary nodestore. For consistency
      #   with other nodestore paths this should be set to the directory containing
      #   the actual 'nudb' or 'rocksdb' datafiles, as the sqlite3 databases will be
      #   inferred from the parent directory.
      def initialize(dir)
        @dir = dir
      end

      def ledger_db
        @ledger_db ||= SQLite3::Database.new File.join(@dir, "..", "ledger.db")
      end

      def tx_db
        @ledger_db ||= SQLite3::Database.new File.join(@dir, "..", "transaction.db")
      end

      def ledgers
        @ledgers ||= Ledgers.new(self)
      end

      class Ledgers
        include Enumerable

        def initialize(sql_db)
          @sql_db = sql_db
        end

        def between(before, after)
          @sql_db.ledger_db.execute("select * from ledgers where ClosingTime >= ? and ClosingTime <= ?",
                                                                                     before.to_xrp_time,
                                                                                      after.to_xrp_time)
                           .collect { |row| from_db(row) }
        end

        def hash_for_seq(seq)
          @sql_db.ledger_db.execute("select LedgerHash from ledgers where LedgerSeq = ?", seq).first.first
        end

        def size
          @sql_db.ledger_db.execute("select count(*) from ledgers").first.first
        end

        alias :count :size

        def each
          all.each do |row|
            yield row
          end
        end

        def last
          all.last
        end

        # TODO: remove memoization, define first(n), last(n) methods
        def all
          @all ||= @sql_db.ledger_db.execute("select * from ledgers order by LedgerSeq asc")
                                    .collect { |row| from_db(row) }
        end

        private

        def from_db(row)
          {:hash              => row[0],
           :seq               => row[1],
           :prev_hash         => row[2],
           :total_coins       => row[3],
           :closing_time      => row[4].from_xrp_time,
           :prev_closing_time => row[5].from_xrp_time,
           :close_time_res    => row[6],
           :close_flags       => row[7],
           :account_set_hash  => row[8],
           :trans_set_hash    => row[9]}
        end
      end # class Ledgers
    end # class SQLDB
  end # module NodeStore
end # module XRBP
