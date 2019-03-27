module XRBP
  module WebSocket
    module Cmds
      # Retrieve information about the public ledger
      #
      # https://developers.ripple.com/ledger.html
      class Ledger < Command
        attr_accessor :id, :args

        def initialize(id=nil, args={})
          @id = id
          @args = args
          super(to_h)
        end

        def id?
          !!id
        end

        def to_h
          h = args.merge(:command => :ledger)
          h['ledger_index'] = id if id?
          return h
        end
      end
    end # module Cmds
  end # module WebSocket
end # module Wipple
