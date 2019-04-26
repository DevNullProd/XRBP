require 'base58'

module XRBP
  module NodeStore
    class DB
      include Enumerable
      include EventEmitter

      def ledger(hash)
        parse_ledger(self[hash])
      end

      def account(hash)
        parse_ledger_entry(self[hash])
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

      def parse_encoding(encoding)
            enc = encoding.unpack("C").first
           type = enc >> 4
          field = enc  & 0xF
        encoding = encoding[1..-1]

        if type == 0
          type = encoding.unpack("C").first
          encoding = encoding[1..-1]
        end

        if field == 0
          field = encoding.unpack("C").first
        end

        type = Format::SERIALIZED_TYPES[type]
        [[type, field], encoding]
      end

      def parse_ledger_entry(ledger_entry)
        # validate parsability
                obj = Format::TYPE_INFER.decode(ledger_entry)
          node_type = Format::NODE_TYPES[obj["node_type"]]
        hash_prefix = Format::HASH_PREFIXES[obj["hash_prefix"].upcase]
        raise unless   node_type == :account_node &&
                     hash_prefix == :leaf_node

        # discard node type, and hash prefix
        ledger_entry = ledger_entry[13..-1]

        # verify encoding
        encoding, ledger_entry = parse_encoding(ledger_entry)
        raise "Invalid Ledger Entry" unless Format::ENCODINGS[encoding] == :ledger_entry_type
        ledger_entry = ledger_entry.bytes

        # first byte after encoding is ledger entry type prefix
        prefix = ledger_entry[0..1].pack("C*")

        # last 32 bytes is entry index
        index  = ledger_entry[-32..-1].pack("C*")
                                      .unpack("H*")
                                      .first
                                      .upcase

        # remaining bytes are serialized object
        fields = parse_fields(ledger_entry[2...-32].pack("C*"))

        # TODO instantiate class corresponding to prefix &
        #      populate attributes w/ fields

        { :prefix => prefix,
          :index  => index,
          :fields => fields }
      end

      def parse_fields(fields)
        parsed = {}
        until fields == ""
          encoding, fields = parse_encoding(fields)
          return parsed if encoding.first.nil?

          e = Format::ENCODINGS[encoding]
          value, fields = parse_length(fields, encoding)
          parsed[e] = value if value
        end

        return parsed
      end

      def parse_length(data, encoding)
        length = encoding.first

        # TODO verify end_of_array, end_of_object
        #      edge cases below are correct

        case length
        when :uint16
          return data.unpack("S").first, data[2..-1]
        when :uint32
          return data.unpack("L").first, data[4..-1]
        when :uint64
          return data.unpack("Q").first, data[8..-1]
        when :hash128
          return data.unpack("H32").first, data[16..-1]
        when :hash256
          return data.unpack("H64").first, data[32..-1]
        when :account
          return Base58.binary_to_base58(data[0..19], :ripple), data[20..-1]
        when :array
          e = Format::ENCODINGS[encoding]
          return if e == :end_of_array

          array = []
          until data == ""
            aencoding, data = parse_encoding(data)
            break if aencoding.first.nil?

            e = Format::ENCODINGS[aencoding]
            break if e == :end_of_array
            break if e == :end_of_object

            value, fields = parse_length(fields, encoding)
            array << value if value
          end

          return array, data

        when :object
          e = Format::ENCODINGS[aencoding]
          return if e == :end_of_object
          # ... prev, new, final fields
          #     modified, deleted, created nodes
          #     signerentry, majority, memo
        end

        # TODO: implement all encoding types
        raise
      end

      def parse_tx(tx)
        # TODO
        tx
      end

      def parse_inner_node(node)
        # verify parsability
                obj = Format::TYPE_INFER.decode(ledger_entry)
        hash_prefix = Format::HASH_PREFIXES[obj["hash_prefix"].upcase]
        raise unless hash_prefix == :inner_node

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
          return :account, parse_ledger_entry(value)

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
