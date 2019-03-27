module XRBP
  module WebSocket
    # Base class facilitating transparent multiple
    # connection dispatching. This provides mechanism which
    # to instantiate multiple WebSocket::Connection instances
    # proxying requests to them depending on the *next_connection*
    # selected.
    #
    # This class provides all the common logic to manage
    # multiple connections. Subclasses should override and
    # implement *next_connection* specifying the strategy
    # used to select the connection to use for any given
    # request.
    class MultiConnection
      include EventEmitter
      include HasPlugin

      def plugin_namespace
        WebSocket
      end

      attr_reader :connections

      # MultiConnection initializer taking list of urls which
      # to connect to
      #
      # @param urls [Array<String>] list of urls which to establish
      #   connections to
      def initialize(*urls)
        @connections = []

        urls.each { |url|
          @connections << Connection.new(url)
        }

        connections.each { |c| c.parent = self }

        yield self if block_given?
      end

      # Force terminate all connections
      def force_quit!
        connections.each { |c| c.force_quit! }
      end

      # Close all connections
      def close!
        connections.each { |c| c.close! }
      end

      # Block until all connections are openend
      def wait_for_open
        connections.each { |c| c.wait_for_open }
      end

      # Block until all connections are closed
      def wait_for_close
        connections.each { |c| c.wait_for_close }
      end

      # Block until all connections are completed
      def wait_for_completed
        connections.each { |c| c.wait_for_completed }
      end

      alias :_add_plugin :add_plugin

      def add_plugin(*plg)
        connections.each { |c|
          c.add_plugin *plg
        }

        _add_plugin(*plg)
      end

      # Always return first connection by default,
      # override in subclasses
      def next_connection(prev=nil)
        return nil unless prev.nil?
        @connections.first
      end

      def connect
        @connections.each { |c|
          c.connect
        }
      end
    end # class MultiConnection
  end # module WebSocket
end # module XRBP
