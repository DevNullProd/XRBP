module XRBP
  module WebSocket
    module Cmds
      # Retrieve information about the public ledger
      #
      # https://developers.ripple.com/ledger.html
      class Ledger < Command
        attr_accessor :ledger_index, :args

        def initialize(ledger_index=nil, args={})
          @ledger_index = ledger_index
          @args = args
          super(to_h)
        end

        def ledger_index?
          !!ledger_index
        end

        def to_h
          h = args.merge(:command => :ledger)
          h['ledger_index'] = ledger_index if ledger_index?
          return h
        end
      end
    end # module Cmds
  end # module WebSocket
end # module Wipple
