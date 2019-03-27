module XRBP
  module WebSocket
    module Cmds
      # The subscribe method requests periodic notifications
      # from the server when certain events happen
      #
      # https://developers.ripple.com/subscribe.html
      class Subscribe < Command
        attr_accessor :args

        def initialize(args={})
          @args = args
          super(to_h)
        end

        def to_h
          args.merge(:command => :subscribe)
        end
      end # class Subscribe
    end # module Cmds
  end # module WebSocket
end # module Wipple
