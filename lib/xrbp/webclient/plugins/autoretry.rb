module XRBP
  module WebClient
    module Plugins
      # Plugin to automatically retry WebClient Connection requests
      # multiple times.
      # 
      # If no max_tries are specified, requests will be tried indefinitely.
      # Optionally configured interval to wait between retries.
      #
      # @example retrying request:
      #   connection = WebClient::Connection.new
      #   connection.add_plugin :autoretry
      #
      #   connection.max_tries = 3
      #   connection.interval  = 1
      #   connection.timeout   = 1
      #
      #   connection.url = "http://doesnt.exist"
      #   connection.perform
      class AutoRetry < PluginBase
        attr_accessor :interval, :max_tries

        def initialize(connection)
          super(connection)
          @interval   = 3
          @max_tries  = nil
          @retry_num  = 0
        end

        def added
          plugin = self
          connection.define_instance_method(:retry_interval=) do |i|
            plugin.interval = i
          end

          connection.define_instance_method(:max_retries=) do |i|
            plugin.max_tries = i
          end
        end

        def handle_error
          @retry_num += 1
          return nil if connection.force_quit? ||
                        (!@max_tries.nil? && @retry_num > @max_tries)

          connection.rsleep(@interval)
          connection.perform
        end
      end # class AutoRetry

      WebClient.register_plugin :autoretry, AutoRetry
    end # module Plugins
  end # module WebClient
end # module XRBP
