require "rocksdb"

module XRBP
  module NodeStore
    module Backends
      class RocksDB < DB
        # cap max open files for performance
        MAX_OPEN_FILES = 200

        def initialize(path)
          @db = ::RocksDB::DB.new path,
                  {:readonly => true,
             :max_open_files => MAX_OPEN_FILES}
        end

        def [](key)
          @db[key]
        end

        def each
          iterator = rocksdb.new_iterator
          iterator.seek_to_first

          while(iterator.valid)
            yield iterator
            iterator.next
          end

          iterator.close
        end
      end # class RocksDB
    end # module Backends
  end # module NodeStore
end # module XRBP
