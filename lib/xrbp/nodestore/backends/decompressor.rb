# requires lz4-ruby gem
require 'lz4-ruby'

module XRBP
  module NodeStore
    module Backends
      # XRP Ledger Nodestore Decompressor. Currently only the NuDB backend
      # employs compression but decompression is required to read those entries.
      #
      # Ported from:
      # {https://github.com/ripple/rippled/blob/develop/src/ripple/nodestore/impl/codec.h codec.h}
      module Decompressor
        protected
          # Principle decompression interface, extracts compression type (if any)
          # from data and decompresses accordingly.
          def decompress(data)
            type, remaining = read_varint(data)
            case(type)
            when 0
                                              remaining # uncompressed
            when 1
                               decompress_lz4 remaining
            when 2
               decompress_compressed_v1_inner remaining
            when 3
                     decompress_full_v1_inner remaining
            when 5
               decompress_compressed_v2_inner remaining
            when 6
                     decompress_full_v2_inner remaining

            else
              raise "nodeobject codec: bad type=#{type}"
            end
          end

        private
          # This is a custom type/size prefix preprended onto
          # nodestore values.
          #
          # See: {https://github.com/ripple/rippled/blob/develop/src/ripple/nodestore/impl/varint.h varint.h}
          #
          # @param data [String] binary nodestore data
          # @return value prefix and remaining data
          #
          # @private
          def read_varint(data)
            bytes = data.bytes

            t = 0
            n = 0
            while(bytes[n] & 0x80) != 0
              n += 1
              if n >= bytes.size
                return t, data
              end
            end

            if (n += 1) >= bytes.size
              return t, data
            end

            if n == 1 && bytes[0] == 0
              return t, data[1..-1]
            end

            used = n
            while(n -= 1) >= 0
              d   = bytes[n]
              t0  = t
               t *= 127
               t += d & 0x7F
               if t <= t0 # overflow
                 return t, data
               end
            end

            return t, data[used..-1]
          end

          ###

          # Decompresses a LZ4-compressed value
          #
          # @private
          def decompress_lz4(data)
            size, remaining = read_varint(data)
            LZ4::Raw::decompress(remaining, size)[0]
          end

          ###

          # Decompresses a Compressed Inner Node (Version 1).
          # Inner nodes may contain up to 16 32-byte hashes,
          # though whens stored on disk-the compression algorithm
          # employs a hash-mask to skip storage of unpopulated hashes.
          #
          # @private
          def decompress_compressed_v1_inner(data)
            raise if data.size < 34

            out = [0, 0, 0, 0,
                   0, 0, 0, 0,
                   Format::NODE_OBJ_TYPES[:unknown]] +
                  [Format::HASH_PREFIXES.invert[:inner_node]].pack("H*")
                                                             .unpack("C*")

            # extract mask indicating which hashes are set
            bytes = data.bytes
             mask = bytes[0..1].pack("C*").unpack("S").first
            bytes = bytes[2..-1]

            raise "nodeobject codec v1: empty inner node" if mask == 0

            # iterate over hashes...
            bit = 0x8000
              i = 16
            while i > 0
              i -= 1

              # ...if set in mask, extract from data...
              if (mask & bit) != 0
                raise "nodeobject codec v1: short inner node" if bytes.size < 32

                out  += bytes[0..31]
                bytes = bytes[32..-1]

              # ...otherwise just set to 0
              else
                out += Array.new(32) { 0 }
              end

              bit  = bit >> 1
            end

            out.pack("C*")
          end

          # Decompresses a Compressed Inner Node (Version 2).
          # Similar to Version 1 but contains additional
          # variable length data appended onto the result bytes.
          #
          # @private
          def decompress_compressed_v2_inner(data)
            raise if data.size < 67

            out = [0, 0, 0, 0,
                   0, 0, 0, 0,
                   Format::NODE_OBJ_TYPES[:unknown]] +
                  [Format::HASH_PREFIXES.invert[:inner_node_v2]].pack("H*")
                                                                .unpack("C*")

            # Same mask / hash extraction as V1

            bytes = data.bytes
             mask = bytes[0..1].pack("C*").unpack("S").first
            bytes = bytes[2..-1]

            raise "nodeobject codec v2: empty inner node" if mask == 0

            depth = bytes[0]
            bytes = bytes[1..-1]

            bit = 0x8000
              i = 16
            while i > 0
              i -= 1

              if (mask & bit) != 0
                raise "nodeobject codec v1: short inner node" if bytes.size < 32

                out  += bytes[0..31]
                bytes = bytes[32..-1]

              else
                out += Array.new(32) { 0 }
              end

              bit  = bit >> 1
            end

            ###

            # Append extra variable-length data onto result

            out << depth

             copy = (depth + 1)/2
            raise "nodeobject codec v2: short inner node" if bytes.size < copy
             out += bytes[0...copy]
            bytes = bytes[copy..-1]
            raise "nodeobject codec v2: long inner node" if bytes.size > 0

             out.pack("C*")
          end

          ###

          # Decompresses a Full (Uncompressed) Inner Node (Version 1).
          #
          # @private
          def decompress_full_v1_inner(data)
            raise if data.size != 512 # 16 32-bit hashes

            out = [0, 0, 0, 0,
                   0, 0, 0, 0,
                   Format::NODE_OBJ_TYPES[:unknown]] +
                  [Format::HASH_PREFIXES.invert[:inner_node]].pack("H*").unpack("C*")
            (out + data[0...512].bytes).pack("C*")
          end

          # Decompresses a Full (Uncompressed) Inner Node (Version 2).
          #
          # @private
          def decompress_full_v2_inner(data)
            bytes = data.bytes
            depth = bytes[0]
            bytes = bytes[1..-1]
             copy = (depth + 1)/2

            raise if bytes.size != 512 + copy # 16 32-bit hashes + copy

            out = [0, 0, 0, 0,
                   0, 0, 0, 0,
                   Format::NODE_OBJ_TYPES[:unknown]] +
                  [Format::HASH_PREFIXES.invert[:inner_node_v2]].pack("H*").unpack("C*")

             out += bytes[0..511]
            bytes = bytes[512..-1]
             out << depth
             out += bytes[0...copy]

            out.pack("C*")
          end
      end # module Decompressor
    end # module Backends
  end # module NodeStore
end # module XRBP
