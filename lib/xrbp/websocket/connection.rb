require_relative '../thread_registry'

module XRBP
  module WebSocket
    # Primary websocket interface, use Connection to perform
    # websocket requests.
    #
    # @example retrieve data via a websocket
    #   connection = WebSocket::Connection.new "wss://s1.ripple.com:443"
    #   puts connection.send_data('{"command" : "server_info"}')
    class Connection
      include EventEmitter
      include HasPlugin
      include ThreadRegistry

      def plugin_namespace
        WebSocket
      end

      attr_reader :url
      attr_accessor :parent

      def initialize(url)
        @url        = url
        @force_quit = false

        yield self if block_given?
      end

      ###

      # Initiate new client connection
      def connect
        client.connect
      end

      # Return next connection of parent if applicable
      #
      # @private
      def next_connection(prev)
        return nil unless !!parent
        parent.next_connection(prev)
      end

      # Add work to the internal client thread pool
      #
      # @private
      def add_work(&bl)
        client.add_work &bl
      end

      # Indicates the connection is  initialized
      def initialized?
        !!@client
      end

      # Indicates the connection is open
      def open?
        initialized? && client.open?
      end

      # Indicates the connection is closed
      # (may not be completed)
      def closed?
        !open?
      end

      # Indicates if connection is completely
      # closed and cleaned up
      def completed?
        client.completed?
      end

      # Close the connection, blocking until completed
      def close!
        client.close if open?
      end

      # Close in a non-blocking way, and immediately return.
      def async_close!
        client.async_close if open?
      end

      # Send raw data via this connection
      def send_data(data)
        client.send_data(data)
      end

      ###

      def force_quit?
        @force_quit
      end

      # Immediately terminate the connection and all related operations
      def force_quit!
        @force_quit = true
        wake_all
        # TODO immediate terminate socket connection
      end

      ###

      # Block until connection is open
      def wait_for_open
        return unless initialized?

        state_mutex.synchronize {
          open_cv.wait(state_mutex, 0.1)
        } until force_quit? || open?
      end

      # Block until connection is closed
      def wait_for_close
        return unless initialized?

        state_mutex.synchronize {
          close_cv.wait(state_mutex, 0.1)
        } while !force_quit? && open?
      end

      # Block until connection is completed
      def wait_for_completed
        return unless initialized?

        state_mutex.synchronize {
          completed_cv.wait(state_mutex, 0.1)
        } while !force_quit? && !completed?
      end

      def state_mutex
        @state_mutex ||= Mutex.new
      end

      def open_cv
        @open_cv ||= ConditionVariable.new
      end

      def close_cv
        @close_cv ||= ConditionVariable.new
      end

      def completed_cv
        @completed_cv ||= ConditionVariable.new
      end

      ###

      # @private
      def client
        @client ||= begin
          client = Client.new(@url)
          conn = self

          client.on :connecting do
            conn.emit :connecting
            conn.parent.emit :connecting, conn if conn.parent
          end

          client.on :open do
            conn.emit :open
            conn.parent.emit :open, conn if conn.parent

            conn.state_mutex.synchronize {
              conn.open_cv.signal
            }

            conn.plugins.each { |plg|
              plg.opened if plg.respond_to?(:opened)
            }
          end

          client.on :close do
            conn.emit :close
            conn.parent.emit :close, conn if conn.parent

            conn.state_mutex.synchronize {
              conn.close_cv.signal
            }

            conn.plugins.each { |plg|
              plg.closed if plg.respond_to?(:closed)
            }
          end

          client.on :completed do |err|
            conn.emit :completed
            conn.parent.emit :completed, conn if conn.parent

            conn.state_mutex.synchronize {
              conn.completed_cv.signal
            }

            conn.plugins.each { |plg|
              plg.completed if plg.respond_to?(:completed)
            }
          end

          client.on :error do |err|
            conn.emit :error, err
            conn.parent.emit :error, conn, err if conn.parent

            conn.plugins.each { |plg|
              plg.error err if plg.respond_to?(:error)
            }
          end

          client.on :message do |msg|
            conn.emit :message, msg
            conn.parent.emit :message, conn, msg if conn.parent

            conn.plugins.each { |plg|
              plg.message msg if plg.respond_to?(:message)
            }
          end

          client
        end
      end
    end # class Connection
  end # module WebSocket
end # module XRBP
