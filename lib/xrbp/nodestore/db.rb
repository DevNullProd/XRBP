require 'base58'
require 'openssl'

require_relative './parser'

module XRBP
  # The NodeStore is the Key/Value DB which rippled persistent stores
  # ledger data. Implemented via a backend configured at run time,
  # the NodeStore is used to store the tree-like structures that
  # consistute the XRP ledger.
  #
  # The Keys and Values stored in the NodeStore are custom binary
  # encodings of tree-node IDs and data. See this module
  # and the others in this directory for specifics on how keys & values
  # are stored and extracted.
  module NodeStore

    # Base NodeStore DB module, the client will use this class through
    # specific DB-type subclass.
    #
    # Subclasses should define the <b>[  ]</b> (index) method taking key to
    # lookup, returning corresponding NodeStore value and *each* method,
    # iterating over nodestore values (see existing subclasses for
    # implementation details)
    class DB
      include Enumerable
      include EventEmitter

      # NodeStore Parser
      include Parser

      # Return the NodeStore Ledger for the given lookup hash
      def ledger(hash)
        val = self[hash]
        return nil if val.nil?
        parse_ledger(val)
      end

      # Return the NodeStore Account for the given lookup hash
      def account(hash)
        ledger_entry(hash)
      end

      # Return the NodeStore Ledger Entry for the given lookup hash
      def ledger_entry(hash)
        val = self[hash]
        return nil if val.nil?
        parse_ledger_entry(val)
      end

      # Return the NodeStore Transaction for the given lookup hash
      def tx(hash)
        val = self[hash]
        return nil if val.nil?
        parse_tx(val)
      end

      # Return the NodeStore InnerNode for the given lookup hash
      def inner_node(hash)
        val = self[hash]
        return nil if val.nil?
        parse_inner_node(val)
      end
    end # class DB
  end # module NodeStore
end # module XRBP
