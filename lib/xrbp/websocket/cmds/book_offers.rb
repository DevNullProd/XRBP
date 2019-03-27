module XRBP
  module WebSocket
    module Cmds
      # The book_offers method retrieves a list of offers, also known as
      # the order book , between two currencies
      #
      # https://developers.ripple.com/book_offers.html
      class BookOffers < Command
        include Paginated

        def page_title
          "offers"
        end

        attr_accessor :args

        def initialize(args={})
          @args = args
          parse_paginate(args)
          super(to_h)
        end

        def self.from_h(h)
           new Hash[h]
        end

        def sanitized_args
          sa = Hash[args_without_paginate]

          sa[:taker_gets].delete(:issuer) if sa[:taker_gets][:currency] == "XRP"
          sa[:taker_pays].delete(:issuer) if sa[:taker_pays][:currency] == "XRP"

          sa
        end

        def to_h
          sanitized_args.merge(:command => :book_offers)
        end
      end # class BookOffers
    end # module Cmds
  end # module WebSocket
end # module Wipple
