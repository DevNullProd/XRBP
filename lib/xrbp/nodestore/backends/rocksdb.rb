# requires rocksdb-ruby gem
require "rocksdb"

module XRBP
  module NodeStore
    module Backends
      # RocksDB nodestore backend, faciliates accessing XRP Ledger data
      # in a RocksDB database.
      #
      # @example retrieve data from RocksDB backend
      #   require 'nodestore/backends/rocksdb'
      #   rocksdb = NodeStore::Backends::RocksDB.new '/var/lib/rippled/db/rocksdb'
      #   puts rocksdb.ledger('B506ADD630CB707044B4BFFCD943C1395966692A13DD618E5BD0978A006B43BD')
      class RocksDB < DB
        # cap max open files for performance
        MAX_OPEN_FILES = 2000

        def initialize(path)
          @db = ::RocksDB::DB.new path,
                  {:readonly => true,
             :max_open_files => MAX_OPEN_FILES}
        end

        # Retrieve database value for the specified key
        #
        # @param key [String] binary key to lookup
        # @return [String] binary value
        def [](key)
          @db[key]
        end

        # Iterate over each database key/value pair,
        # invoking callback. During iteration will
        # emit signals specific to the DB types being
        # parsed
        #
        # @example iterating over RocksDB entries
        #   rocksdb.each do |iterator|
        #     puts "Key/Value: #{iterator.key}/#{iterator.value}"
        #   end
        #
        # @example handling account via event callback
        #   rocksdb.on(:account) do |hash, account|
        #     puts "Account #{hash}"
        #     pp account
        #   end
        #
        #   # Any Enumerable method that invokes #each will
        #   # have intended effect
        #   rocksdb.to_a
        def each
          iterator = @db.new_iterator
          iterator.seek_to_first

          while(iterator.valid)
            type, obj = infer_type(iterator.value)

            if type
              emit type, iterator.key, obj
            else
              emit :unknown, iterator.key,
                             iterator.value
            end

            yield iterator
            iterator.next
          end

          iterator.close
          return self
        end
      end # class RocksDB
    end # module Backends
  end # module NodeStore
end # module XRBP
