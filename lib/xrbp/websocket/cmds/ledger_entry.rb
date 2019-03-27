module XRBP
  module WebSocket
    module Cmds
      # The ledger_entry method returns a single ledger object
      # from the XRP Ledger in its raw format
      #
      # https://developers.ripple.com/ledger_entry.html
      class LedgerEntry < Command
        def initialize(args={})
          @args = args
          super(to_h)
        end

        def to_h
          @args.merge('command' => 'ledger_entry')
        end
      end
    end # module Cmds
  end # module WebSocket
end # module Wipple
