module XRBP
  module Model
    class Ledger < Base
      extend Base::ClassMethods

      attr_accessor :id

      def initialize(opts={})
        @id = opts[:id]
        super(opts)
      end

      # Retreive specified ledger via WebSocket::Connection
      #
      # @param opts [Hash] options to retrieve ledger with
      # @option opts [WebSocket::Connection] :connection Connection
      #   to use to retrieve ledger
      def sync(opts={}, &bl)
        set_opts(opts)
        connection.cmd(WebSocket::Cmds::Ledger.new(id, full_opts.except(:id)), &bl)
      end

      # Subscribe to ledger stream via WebSocket::Connection
      #
      # @param opts [Hash] options to subscribe to ledger stream with
      # @option opts [WebSocket::Connection] :connection Connection
      #   to use to subscribe to ledger stream
      def self.subscribe(opts={}, &bl)
        set_opts(opts)
        conn = connection
        conn.cmd(WebSocket::Cmds::Subscribe.new(:streams => ["ledger"]), &bl)
        conn.on :message do |*args|
          c,msg = args.size > 1 ? [args[0], args[1]] :
                                  [nil,     args[0]]

          begin
            i = JSON.parse(msg.to_s)
            if i["ledger_hash"] &&
               i["ledger_index"]
              if c
                conn.emit :ledger, c, i
              else
                conn.emit :ledger, i
                conn.parent.emit :ledger, conn, i if conn.parent
              end
            end
          rescue
          end
        end
      end
    end # class Ledger
  end # module Model
end # module XRBP
