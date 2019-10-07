module XRBP
  module NodeStore
    # Special type of Serialized Object whose type is identified
    # through the 'ledger_entry_type' field
    class STLedgerEntry < STObject
      attr_reader :key

      def initialize(args={})
        super
        @key = args[:key]
      end

      def type_code
        @type_code ||= field(:uint16, :ledger_entry_type)
      end

      def type
        @type ||= Format::LEDGER_ENTRY_TYPE_CODES[type_code]
      end
    end # class STLedgerEntry

    SLE = STLedgerEntry
  end # module NodeStore
end # module XRBP
