module XRBP
  module WebSocket
    module Cmds
      # The account_lines method returns information about an
      # account's trust lines, including balances in all non-XRP
      # currencies and assets
      #
      # https://developers.ripple.com/account_lines.html
      class AccountLines < Command
        include Paginated

        def page_title
          "account_lines"
        end

        attr_accessor :account, :args

        def initialize(account, args={})
          @account = account
          @args = args
          parse_paginate(args)
          super(to_h)
        end

        def self.from_h(h)
          _h = Hash[h]
           a = _h.delete(:account)
           new a, _h
        end

        def to_h
          args_without_paginate.merge(:command => :account_lines,
                                      :account => account)
        end
      end # class AccountLines
    end # module Cmds
  end # module WebSocket
end # module Wipple
