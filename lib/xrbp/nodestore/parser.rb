module XRBP
  module NodeStore
    module Parser
      protected

      # Parsers binary ledger representation into structured ledger.
      #
      # @protected
      def parse_ledger(ledger)
        obj = Format::LEDGER.decode(ledger)
               obj['close_time'] = XRBP::from_xrp_time(obj['close_time']).utc
        obj['parent_close_time'] = XRBP::from_xrp_time(obj['parent_close_time']).utc
        obj['parent_hash'].upcase!
        obj['tx_hash'].upcase!
        obj['account_hash'].upcase!
        obj
      end

      # Certain data types are prefixed with an 'encoding' header
      # consisting of a field and/or type. Field, type, and remaining
      # bytes are returned
      #
      # @protected
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

      # Parses binary ledger entry into hash. Data returned
      # in hash includes ledger entry type prefix, index,
      # and array of parsed fields.
      #
      # @protected
      def parse_ledger_entry(ledger_entry)
        # validate parsability
                obj = Format::TYPE_INFER.decode(ledger_entry)
          node_type = Format::NODE_TYPE_CODES[obj["node_type"]]
        hash_prefix = Format::HASH_PREFIX_CODES[obj["hash_prefix"].upcase]
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
        fields, remaining = parse_fields(ledger_entry[2...-32].pack("C*"))
        raise unless remaining.empty?

        # TODO return STLedgerEntry object

        { :type   => Format::LEDGER_ENTRY_TYPE_CODES[prefix[1]],
          :index  => index,
          :fields => fields }
      end

      ###

      # Parse and return series of fields from binary data.
      #
      # @protected
      def parse_fields(fields)
        parsed = {}
        until fields == "" || fields == "\0" || fields.nil?
          encoding, fields = parse_encoding(fields)
          return parsed if encoding.first.nil?

          e = Format::ENCODINGS[encoding]
          value, fields = parse_field(fields, encoding)
          break unless value
          parsed[e] = convert_field(encoding, value)
        end

        return parsed, fields
      end

      # Parse single field of specified encoding from data.
      # Dispatches to corresponding parsing method when appropriate.
      #
      # @protected
      def parse_field(data, encoding)
        length = encoding.first

        case length
        when :uint8
          return data.unpack("C").first, data[1..-1]
        when :uint16
          return data.unpack("S>").first, data[2..-1]
        when :uint32
          return data.unpack("L>").first, data[4..-1]
        when :uint64
          return data.unpack("Q>").first, data[8..-1]
        when :hash128
          return data.unpack("H32").first, data[16..-1]
        when :hash160
          return data.unpack("H40").first, data[20..-1]
        when :hash256
          return data.unpack("H64").first, data[32..-1]
        when :amount
          return parse_amount(data)
        when :vl
          vl, offset = parse_vl(data)
          return data[offset..vl+offset-1], data[vl+offset..-1]
        when :account
          return parse_account(data)
        when :array
          return parse_array(data, encoding)
        when :object
          return parse_object(data, encoding)
        when :pathset
          return parse_pathset(data)
        when :vector256
          vl, offset = parse_vl(data)

          # split into array of 256-bit (= 32 byte = 4 chars) strings
          return data[offset..vl+offset-1].chunk(32),
                 data[vl+offset..-1]
        end

        raise
      end

      def convert_field(encoding, value)
        e = Format::ENCODINGS[encoding]

        if encoding.first == :vl
          return value.unpack("H*").first

        elsif e == :transaction_type
          return Format::TX_TYPES[value]

        elsif e == :transaction_result
          return Format::TX_RESULTS[value]

        elsif e == :ledger_entry_type
          return Format::LEDGER_ENTRY_TYPE_CODES[value.chr]
        end

        value
      end

      # Parse variable length header from data buffer. Returns length
      # extracted from header and the number of bytes in header.
      #
      # @protected
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

      # Parse 'Amount' data type from binary data.
      #
      # Stored internally in 64 bits:
      # - Bit 1 = 0 for XRP, 1 for IOU
      # - Bit 2 = sign, 0 for negative, 1 for positive
      #
      # For XRP:
      # - Remaining bits = value in drops
      #
      # For IOU:
      # - Next 8 bits = Exponent
      # - Next 54 bits = Mantissa
      # Where value = mantissa * (10 ^ exponent)
      # Note: 97 is added to exponent when serializing and subtracted when parsing so
      #       that effective nominal exponent is always in range of -96 to 80
      #
      # @see https://developers.ripple.com/currency-formats.html
      # @see STAmount(SerialIter& sit, SField const& name);
      # @see {STAmount#from_wire}
      #
      # @protected
      def parse_amount(data)
        amount = data[0..7].unpack("Q>").first

        # native eg, xrp
        is_xrp = (amount & STAmount::NOT_NATIVE) == 0
        if is_xrp
          is_pos = (amount & STAmount::POS_NATIVE) != 0
          return STAmount.new(:issue    => NodeStore.xrp_issue,
                              :mantissa => amount & ~STAmount::POS_NATIVE), data[8..-1] if is_pos

          return STAmount.new(:issue    => NodeStore.xrp_issue,
                              :mantissa => amount,
                              :neg      => true), data[8..-1]
        end

        data = data[8..-1]
        currency = Format::CURRENCY_CODE.decode(data)
        currency = currency["iso_code"].pack("C*")

        data = data[Format::CURRENCY_CODE.size..-1]
        issuer, data = parse_account(data, 20)

        issue = Issue.new(currency, issuer)

         exp = (amount >> (64 - 10)).to_int
        mant = (amount & ~(1023 << (64 - 10)))

        if mant
          neg = (exp & 256) == 0
          exp = (exp & 255) - 97

          sle = STAmount.new(:issue    => issue,
                             :neg      => neg,
                             :mantissa => mant,
                             :exponent => exp)

          return sle, data
        end

        raise unless exp == 512
        return STAmount.new(:issue => issue)
      end

      # Parse 'Account' data type from binary data.
      #
      # @protected
      def parse_account(data, vl=nil)
        unless vl
          vl,offset = parse_vl(data)
          data = data[offset..-1]
        end

          acct = "\0" + data[0..vl-1]
        sha256 = OpenSSL::Digest::SHA256.new
        digest = sha256.digest(sha256.digest(acct))[0..3]
        acct  += digest
        acct.force_encoding(Encoding::BINARY) # required for Base58 gem

        # TODO return STAccount
        return Base58.binary_to_base58(acct, :ripple), data[vl..-1]
      end

      # Parse array of fields from binary data.
      #
      # @protected
      def parse_array(data, encoding)
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
      end

      # Parse Object consisting of multiple fields from binary data.
      #
      # @protected
      def parse_object(data, encoding)
        e = Format::ENCODINGS[encoding]
        case e
        when :end_of_object
          return nil, data

        when :signer,   :signer_entry,
             :majority, :memo,
             :modified_node, :created_node, :deleted_node,
             :previous_fields, :final_fields, :new_fields
          # TODO return STObject
          return parse_fields(data)

        #else:
        end

        raise "unknown object type: #{e}"
      end

      # Parse PathSet from binary data.
      #
      # @protected
      def parse_pathset(data)
        pathset = [[]]
        until data == "" || data.nil?
          segment = data.unpack("C").first
          data = data[1..-1]
          return pathset, data if segment == 0x00 # end of path

          if segment == 0xFF # path boundry
            pathset << []
          else
            account, current, issuer = nil

            path = {}

            if (segment & 0x01) != 0 # path account
              account, data = parse_account(data, 20)
              path[:account] = account
            end

            if (segment & 0x10) != 0 # path currency
              currency = Format::CURRENCY_CODE.decode(data)
              currency = currency["iso_code"].pack("C*")
              data = data[Format::CURRENCY_CODE.size..-1]
              path[:currency] = currency
            end

            if (segment & 0x20) != 0 # path issuer
              issuer, data = parse_account(data, 20)
              path[:issuer] = issuer
            end

            pathset.last << path
          end
        end

        # TODO return STPathSet
        return pathset, data
      end

      ###

      # Parse Transaction from binary data
      #
      # @protected
      def parse_tx(tx)
                obj = Format::TYPE_INFER.decode(tx)
          node_type = Format::NODE_TYPE_CODES[obj["node_type"]]
        hash_prefix = Format::HASH_PREFIX_CODES[obj["hash_prefix"].upcase]
        raise unless   node_type == :tx_node &&
                     hash_prefix == :tx_node

        # discard node type, and hash prefix
        tx = tx[13..-1]

        parse_tx_inner(tx)
      end

      # Parse Inner Transaction from binary data
      #
      # @protected
      def parse_tx_inner(tx)
        # get node length
        vl, offset = parse_vl(tx)
        node, _tx = tx.bytes[offset..vl+offset-1], tx.bytes[vl+offset..-1]
        node, _remaining = parse_fields(node.pack("C*"))

        # get meta length
        vl, offset = parse_vl(_tx.pack("C*"))
        meta, index = _tx[offset..vl+offset-1], _tx[vl+offset..-1]
        meta, _remaining = parse_fields(meta.pack("C*"))

        # TODO return STTx
        {  :node =>  node,
           :meta =>  meta,
          :index => index.pack("C*").unpack("H*").first.upcase }
      end

      # Parse InnerNode from binary data.
      #
      # @protected
      def parse_inner_node(node)
        # verify parsability
                obj = Format::TYPE_INFER.decode(node)
        hash_prefix = Format::HASH_PREFIX_CODES[obj["hash_prefix"].upcase]
        raise unless hash_prefix == :inner_node

        node = Format::INNER_NODE.decode(node)
        node['node_type'] = Format::NODE_TYPE_CODES[node['node_type']]
        node
      end

      # Return type and extracted structure from binary data.
      #
      # @protected
      def infer_type(value)
                obj = Format::TYPE_INFER.decode(value)
          node_type = Format::NODE_TYPE_CODES[obj["node_type"]]
        hash_prefix = Format::HASH_PREFIX_CODES[obj["hash_prefix"].upcase]

        if hash_prefix == :inner_node
          return :inner_node, parse_inner_node(value)

        elsif node_type == :account_node
          return :ledger_entry, parse_ledger_entry(value)

        elsif node_type == :tx_node
          return :tx, parse_tx(value)

        elsif node_type == :ledger
          return :ledger, parse_ledger(value)
        end

        return nil
      end
    end # module Parser
  end # module NodeStore
end # module XRBP
