require 'websocket'

module XRBP
  module WebSocket
    # Managed socket connection lifecycle and read/write operations
    #
    # @private
    class Client
      include EventEmitter
      include Terminatable

      attr_reader :url, :options

      def initialize(url, options={})
        @url = url
        @options = options

        @handshaked = false
        @closed = true
        @completed = true
      end

      def connect
        emit_signal :connecting

        @closed = false
        @completed = false
        socket.connect
        handshake!

        start_read

        self
      end

      # Add job to internal thread pool.
      def add_work(&bl)
        pool.post &bl
      end

      ###

      def open?
        handshake.finished? and !closed?
      end

      def closed?
        !!@closed
      end

      def completed?
        !!@completed
      end

      # Allow close to be run via seperate thread so
      # as not to block caller
      def async_close(err=nil)
        Thread.new { close(err)  }
      end

      def close(err=nil)
        return if closed?

        # XXX set closed true first incase callbacks need to check this
        @closed = true
        @handshake = nil
        @handshaked = false

        terminate!

        send_data nil, :type => :close unless socket.pipe_broken
        emit_signal :close, err

        socket.close if socket
        @socket = nil

        pool.shutdown
        pool.wait_for_termination
        @pool = nil

        @completed = true
        emit :completed
        self
      end

      private

      ###

      def socket
        @socket ||= Socket.new self
      end

      def pool
        @pool ||= Concurrent::CachedThreadPool.new
      end

      ###

      def handshake
        @handshake ||= ::WebSocket::Handshake::Client.new :url => url,
                                                      :headers => options[:headers]
      end

      def handshaked?
        !!@handshaked
      end

      def handshake!
        socket.write handshake.to_s

        until handshaked?
          socket.read_next handshake
          @handshaked = handshake.finished?
        end
      end

      ###

      def data_frame(data, type)
        ::WebSocket::Frame::Outgoing::Client.new(:data => data,
                                                 :type => type,
                                              :version => handshake.version)
      end

      public

      def send_data(data, opt={:type => :text})
        return if !handshaked? || closed?

        begin
          frame = data_frame(data, opt[:type])
          socket.write_nonblock(frame.to_s)

        rescue Errno::EPIPE, OpenSSL::SSL::SSLError => e
          async_close(e)
        end
      end

      private

      def start_read
        add_work do
          frame = ::WebSocket::Frame::Incoming::Client.new
          emit_signal :open

          cl = trm = eof = false
          until (trm = terminate?) || (cl = closed?) do
            begin
              socket.read_next(frame)

              if msg = frame.next
                emit_signal :message, msg
                frame = ::WebSocket::Frame::Incoming::Client.new
              end

            rescue EOFError => e
              emit_signal :error, e
              eof = e

            rescue => e
              emit_signal :error, e
            end
          end

          # ... is this right?:
          async_close(eof) if !!eof && !cl && !trm
        end
      end

      def emit_signal(*args)
        # TODO add args to queue, and in add_work task, pull 1 item off queue
        #      & emit it (to enforce signal order)
        begin
          add_work do
            emit *args
          end

          # XXX: handle race condition where connection is closed
          #      between calling emit_signal and pool.post (handle
          #      error, otherwise a mutex would be needed)
        rescue Concurrent::RejectedExecutionError => e
          raise e unless closed?
        end
      end
    end # class Client
  end # module WebSocket
end # module XRBP
