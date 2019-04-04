module XRBP
  module WebSocket
    module Plugins
      # Dispatch messages & wait for responses (w/ optional timeout).
      # This module allows the client to track messages sent to the server,
      # waiting for responses up to a maximum time. An overridable callback
      # method is provided to match responses to messages. Most often the
      # end-user will not use this plugin directly but rather through
      # CommandDispatcher which inherits it / extends it to issue and
      # track structured commands.
      #
      # @see CommandDispatcher
      class MessageDispatcher < PluginBase
        include Terminatable
        include HasResultParsers

        DEFAULT_TIMEOUT = 10

        def parsing_plugins
          connection.plugins
        end

        attr_reader :messages
        attr_accessor :message_timeout

        def initialize(connection)
          super(connection)
          @message_timeout = DEFAULT_TIMEOUT
          @messages = []
        end

        def added
          plugin = self

          connection.define_instance_method(:message_timeout=) do |t|
            plugin.message_timeout = t

            connections.each{ |c|
              c.plugin(MessageDispatcher)
               .message_timeout = t
            } if self.kind_of?(MultiConnection)
          end

          connection.define_instance_method(:msg) do |msg, &bl|
            return next_connection.msg msg, &bl if self.kind_of?(MultiConnection)

            msg = Message.new(msg) unless msg.kind_of?(Message)
            msg.connection = self
            msg.time = Time.now
            msg.bl = bl if bl

            unless self.open?
              if plugin.try_next(msg)
                return nil if bl
                       msg.wait
                return msg.result

              else
                msg.bl.call nil if bl
                return nil
              end
            end

            plugin.messages << msg

            send_data msg.to_s

            return nil if bl
            msg.wait
            msg.result
          end

          connection.on :close do
            plugin.cancel_all_messages
          end unless connection.kind_of?(MultiConnection)
        end

        # Should be overridden in subclass return
        # request message & formatted response
        # given raw response
        def match_message(msg)
          nil
        end

        # Return bool if message,response is read to be unlocked / returned to client.
        # Allows other plugins to block message unlocking
        def unlock!(req, res)
          !connection.plugins.any? { |plg|
            plg != self && plg.respond_to?(:unlock!) && !plg.unlock!(req, res)
          }
        end

        def message(res)
          req, res = match_message(res)
          return unless req
          messages.delete(req)

          return unless unlock!(req, res)

          begin
            res = parse_result(res, req)
          rescue Exception => e
            if try_next(req)
              return

            else
              res = nil
            end
          end

          req.bl.call(res)
        end

        def try_next(msg)
          conn = connection.next_connection(msg.connection)
          return false unless !!conn
          messages.delete(msg)
          conn.msg(msg, &msg.bl)
          true
        end

        # FIXME: I *believe* there is issue causing deadlock at process
        #        termination where subsequent pages in paginated cmds
        #        are timing out. Since when retrieving messages
        #        synchronously, the first message block will be used
        #        to wait for the results and on timeout cancel_message
        #        will be called with the _latest_ message, the wait
        #        block never gets unlocked.
        def cancel_message(msg)
          connection.state_mutex.synchronize {
            messages.delete(msg)
            msg.signal
          }
        end

        def cancel_all_messages
          messages.each { |msg|
            cancel_message(msg)
          }
        end

        public

        def opened
          connection.add_work do
            # XXX remove force_quit? condition check from this loop,
            #     so we're sure messages always timeout, even on force quit.
            #     Always ensure close! is called after websocket is no longer
            #     being used!
            until terminate? || connection.closed?
              now = Time.now
              tmsgs = Array.new(messages)
              tmsgs.each { |msg|
                if now - msg.time > @message_timeout
                  connection.emit :timeout, msg

                  cancel_message(msg) unless try_next(msg)

                  # XXX manually close the connection as
                  #     a broken pipe will not stop websocket polling
                  connection.async_close!
                end
              }

              connection.rsleep(0.1)
            end
          end
        end

        def closed
          terminate!
        end
      end # class MessageDispatcher

      WebSocket.register_plugin :message_dispatcher, MessageDispatcher
    end # module Plugins
  end # module WebSocket
end # module XRBP
