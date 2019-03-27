module XRBP
  module WebSocket
    module Cmds
      # The account_info command retrieves information about an
      # account, its activity, and its XRP balance.
      #
      # https://developers.ripple.com/account_info.html
      class AccountInfo < Command
        attr_accessor :account, :args

        def initialize(account, args={})
          @account = account
          @args = args
          super(to_h)
        end

        def to_h
          args.merge(:command => :account_info,
                     :account => account)
        end
      end # class AccountInfo
    end # module Cmds
  end # module WebSocket
end # module Wipple
