require 'base58'
require 'openssl'

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
          encoding = encoding[1..-1]
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

      ###

      def parse_fields(fields)
        parsed = {}
        until fields == "" || fields.nil?
          encoding, fields = parse_encoding(fields)
          return parsed if encoding.first.nil?

          e = Format::ENCODINGS[encoding]
          value, fields = parse_field(fields, encoding)
          break unless value
          parsed[e] = value
        end

        return parsed
      end

      def parse_field(data, encoding)
        length = encoding.first

        case length
        when :uint8
          return data.unpack("C").first, data[1..-1]
        when :uint16
          return data.unpack("S").first, data[2..-1]
        when :uint32
          return data.unpack("L").first, data[4..-1]
        when :uint64
          return data.unpack("Q").first, data[8..-1]
        when :hash128
          return data.unpack("H32").first, data[16..-1]
        when :hash160
          return data.unpack("H40").first, data[20..-1]
        when :hash256
          return data.unpack("H64").first, data[32..-1]

        when :amount
          amount = data[0..7].unpack("Q>").first
             xrp = amount < 0x8000000000000000
          return  (amount & 0x3FFFFFFFFFFFFFFF), data[8..-1] if xrp

          sign = (amount & 0x4000000000000000) >> 62 # 0 = neg / 1 = pos
           exp = (amount & 0x3FC0000000000000) >> 54
          mant = (amount & 0x003FFFFFFFFFFFFF)

          data = data[8..-1]
          currency = Format::CURRENCY_CODE.decode(data)

          data = data[Format::CURRENCY_CODE.size..-1]
          issuer, data = parse_account(data, 20)

          # TODO calculate value
          return { :sign => sign,
                    :exp => exp,
               :mantissa => mant,
               :currency => currency,
                 :issuer => issuer }, data

        when :vl
          vl, offset = parse_vl(data)
          return data[offset..vl+offset-1], data[vl+offset..-1]

        when :account
          return parse_account(data)

        when :array
          e = Format::ENCODINGS[encoding]
          return nil, data if e == :end_of_array

          array = []
          until data == "" || data.nil?
            aencoding, data = parse_encoding(data)
            break if aencoding.first.nil?

            e = Format::ENCODINGS[aencoding]
            break if e == :end_of_array

            value, data = parse_field(data, aencoding)
            break unless value
            array << value
          end

          return array, data

        when :object
          e = Format::ENCODINGS[encoding]
          case e
          when :end_of_object
            return nil, data

          when :signer, :signer_entry, :majority, :memo
            # TODO instantiate corresponding classes
            return parse_fields(data)

          #else:
          end

          # TODO prev, new, final fields
          #      modified, deleted, created nodes

        when :pathset
          pathset = []
          until data == "" || data.nil?
            segment = data.unpack("C").first
            data = data[1..-1]
            return pathset, data if segment == 0x00 # end of path

            if segment == 0xFF # path boundry
              pathset << []
            else
              if segment & 0x01 # path account
                issuer, data = parse_account(data, 20)
              end

              if segment & 0x02 # path currency
                currency = Format::CURRENCY_CODE.decode(data)
                data = data[Format::CURRENCY_CODE.size..-1]
              end

              if segment & 0x03 # path issuer
                issuer, data = parse_account(data, 20)
              end
            end
          end

          return pathset, data

        when :vector256
          vl, offset = parse_vl(data)
          return data[offset..vl+offset-1], data[vl+offset..-1]

        end

        raise
      end

      def parse_vl(data)
         data = data.bytes
        first = data.first.to_i
        return first, 1 if first <= 192

        data = data[1..-1]
        second = data.first.to_i
        if first <= 240
          return (193+(first-193)*256+second), 2

        elsif first <= 254
          data = data[1..-1]
          third = data.first.to_i
          return (12481 + (first-241)*65536 + second*256 + third), 3
        end

        raise
      end

      def parse_account(data, vl=nil)
        unless vl
          vl,offset = parse_vl(data)
          data = data[offset..-1]
        end

          acct = "\0" + data[0..vl-1]
        sha256 = OpenSSL::Digest::SHA256.new
        digest = sha256.digest(sha256.digest(acct))[0..3]
        acct  += digest
        return Base58.binary_to_base58(acct, :ripple), data[vl..-1]
      end

      ###

      def parse_tx(tx)
                obj = Format::TYPE_INFER.decode(tx)
          node_type = Format::NODE_TYPES[obj["node_type"]]
        hash_prefix = Format::HASH_PREFIXES[obj["hash_prefix"].upcase]
        raise unless   node_type == :tx_node &&
                     hash_prefix == :tx_node

        # discard node type, and hash prefix
        tx = tx[13..-1]

        # get node length
        vl, offset = parse_vl(tx)
        node, _tx = tx.bytes[offset..vl+offset-1], tx.bytes[vl+offset..-1]
        node = parse_fields(node.pack("C*"))

        # get meta length
        vl, offset = parse_vl(_tx.pack("C*"))
        meta, index = _tx[offset..vl+offset-1], _tx[vl+offset..-1]
        # meta = parse_fields(meta.pack("C*")) # TODO

        {  :node =>  node,
           :meta =>  meta.pack("C*"),
          :index => index.pack("C*").unpack("H*").first.upcase }
      end

      def parse_inner_node(node)
        # verify parsability
                obj = Format::TYPE_INFER.decode(node)
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
