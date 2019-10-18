require 'ostruct'

# requires rrudb gem
require "rudb"

require_relative './decompressor'

module XRBP
  module NodeStore
    module Backends
      # NuDB nodestore backend, faciliates accessing XRP Ledger data
      # in a NuDB database. This module accommodates for compression
      # used in rippled's NuDB nodestore backend implementation
      #
      # @example retrieve data from NuDB backend
      #   require 'nodestore/backends/nudb'
      #   nudb = NodeStore::Backends::NuDB.new '/var/lib/rippled/db/nudb'
      #   puts nudb.ledger('B506ADD630CB707044B4BFFCD943C1395966692A13DD618E5BD0978A006B43BD')
      class NuDB < DB
        include Decompressor

        attr_reader :path

        KEY_SIZE = 32

        def initialize(path)
          @path = path
          create!
          open
        end

        # Retrieve database value for the specified key
        #
        # @param key [String] binary key to lookup
        # @return [String] binary value
        def [](key)
          fetched = @store.fetch(key)[0]
          return nil if fetched.empty?
          decompress(fetched)
        end

        # Iterate over each database key/value pair,
        # invoking callback. During iteration will
        # emit signals specific to the DB types being
        # parsed
        #
        # @example iterating over NuDB entries
        #   nudb.each do |iterator|
        #     puts "Key/Value: #{iterator.key}/#{iterator.value}"
        #   end
        #
        # @example handling ledgers via event callback
        #   nudb.on(:ledger) do |hash, ledger|
        #     puts "Ledger #{hash}"
        #     pp ledger
        #   end
        #
        #   # Any Enumerable method that invokes #each will
        #   # have intended effect
        #   nudb.to_a
        def each
          dat = File.join(path, "nudb.dat")

          RuDB::each(dat) do |key, val|
            val = decompress(val)
            type, obj = infer_type(val)

            if type
              emit type, key, obj
            else
              emit :unknown, key, val
            end

            # 'mock' iterator
            iterator = OpenStruct.new(:key   => key,
                                      :value => val)
            yield iterator
          end

          return self
        end

        private

        # Create database if it does not exist
        #
        # @private
        def create!
          dat = File.join(path, "nudb.dat")
          key = File.join(path, "nudb.key")
          log = File.join(path, "nudb.log")

          RuDB::create :dat_path    => dat,
                       :key_path    => key,
                       :log_path    => log,
                       :app_num     =>   1,
                       :salt        => RuDB::make_salt,
                       :key_size    => KEY_SIZE,
                       :block_size  => RuDB::block_size(key),
                       :load_factor => 0.5
        end

        # Open existing database
        #
        # @private
        def open
          dat = File.join(path, "nudb.dat")
          key = File.join(path, "nudb.key")
          log = File.join(path, "nudb.log")

          @store = RuDB::Store.new
          @store.open(dat, key, log)
        end
      end # class NuDB
    end # module Backends
  end # module NodeStore
end # module XRBP
