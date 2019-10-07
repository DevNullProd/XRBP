require_relative '../parser'

module XRBP
  module NodeStore
    # Seralized Type containing fields associated with ids
    class STObject
      # NodeStore Parser
      include Parser

      attr_reader :item, :fields

      def initialize(args={})
        @item = args[:item]

        @fields, remaining = parse_fields(item.data)
        raise unless remaining.size == 0
      end

      def flags
        @flags ||= fields[:flags]
      end

      def flag?(flag)
        flag = NodeStore::Format::SERIALIZED_FLAGS[flag] if flag.is_a?(Symbol)
        flags & flag == flag
      end

      def field?(id)
        fields.key?(id)
      end

      def field(type, id)
        fields[id]
        # type should already be converted in parsing process (TODO verify?)
      end

      def amount(field)
        field(STAmount, field)
      end

      def account_id(field)
        field(STAccount, field)
      end
    end # class STObject
  end # module NodeStore
end # module XRBP
