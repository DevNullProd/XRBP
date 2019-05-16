require 'ostruct'

# requires rrudb gem
require "rudb"

require_relative './decompressor'

module XRBP
  module NodeStore
    module Backends
      class NuDB < DB
        include Decompressor

        attr_reader :path

        KEY_SIZE = 32

        def initialize(path)
          @path = path
          create!
          open
        end

        def [](key)
          decompress(@store.fetch(key)[0])
        end

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
        end

        private

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
