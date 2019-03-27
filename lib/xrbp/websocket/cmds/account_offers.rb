module XRBP
  module WebSocket
    module Cmds
      # The account_offers method retrieves a list of offers made
      # by a given account that are outstanding as of a particular
      # ledger version.
      #
      # https://developers.ripple.com/account_offers.html
      class AccountOffers < Command
        include Paginated

        def page_title
          "offers"
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
          args_without_paginate.merge(:command => :account_offers,
                                      :account => account)
        end
      end # class AccountLines
    end # module Cmds
  end # module WebSocket
end # module Wipple
