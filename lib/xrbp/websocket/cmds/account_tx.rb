module XRBP
  module WebSocket
    module Cmds
      # The account_tx method retrieves a list of transactions
      # that involved the specified account.
      #
      # https://developers.ripple.com/account_tx.html
      class AccountTx < Command
        attr_accessor :account, :args

        def initialize(account, args={})
          @account = account
          @args = args
          super(to_h)
        end

        def to_h
          args.merge(:command => :account_tx,
                     :account => account)
        end
      end # class AccountLines
    end # module Cmds
  end # module WebSocket
end # module Wipple
