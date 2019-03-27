module XRBP
  module WebSocket
    module Cmds
      # The account_objects command returns the raw ledger format for
      # all objects owned by an account
      #
      # https://developers.ripple.com/account_objects.html
      class AccountObjects < Command
        include Paginated

        def page_title
          "account_objects"
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
          args_without_paginate.merge(:command => :account_objects,
                                      :account => account)
        end
      end # class AccountLines
    end # module Cmds
  end # module WebSocket
end # module Wipple
