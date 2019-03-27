module XRBP
  module WebSocket
    # Raw data which to write to websocket and mechanisms
    # which to track and manage response state.
    class Message
      attr_reader :result
      attr_accessor :time, :connection

      def initialize(data)
        @data = data
        @result = nil
        @cv = ConditionVariable.new
        @signalled = false
        @time = Time.now
      end

      def to_s
        @data
      end

      def signal
        @signalled = true
        @cv.signal
        self
      end

      def wait
        connection.state_mutex.synchronize {
          # only wait if we haven't received response
          @cv.wait(connection.state_mutex) unless connection.closed? || @signalled
        }
      end

      attr_writer :bl

      def bl
        @bl ||= proc { |res|
          @result = res
          signal
        }
      end
    end # class Message
  end # module WebSocket
end # module XRBP
