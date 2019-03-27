require 'curb'
require_relative '../thread_registry'

module XRBP
  module WebClient
    # HTTP interface, use Connection to perform web requests.
    #
    # @example retrieve data from the web
    #   connection = WebClient::Connection.new
    #   connection.url = "https://devnull.network"
    #   connection.perform
    class Connection
      include EventEmitter
      include HasPlugin
      include HasResultParsers
      include ThreadRegistry

      DELEGATED_METHODS = [:url=,
                           :timeout=,
                           :ssl_verify_peer=,
                           :ssl_verify_host=]

      # @private
      def plugin_namespace
        WebClient
      end

      # @private
      def parsing_plugins
        plugins
      end

      # Return current url
      def url
        c.url
      end

      # delegated methods
      DELEGATED_METHODS.each { |m|
        define_method(m) do |v|
          c.send(m, v)
        end
      }

      def initialize(url=nil)
        self.url = url
        @force_quit = false

        yield self if block_given?
      end

      def force_quit?
        @force_quit
      end

      # Immediate terminate outstanding requests
      def force_quit!
        @force_quit = true
        wake_all
        # TODO immediate terminate outstanding requests
      end

      private

      def c
        @curl ||= Curl::Easy.new
      end

      def handle_error
        plugins.select { |plg|
          plg.respond_to?(:handle_error)
        }.last&.handle_error
      end

      public

      # Execute web request, retrieving results and returning
      def perform
        # TODO fault tolerance plugins:
        #        configurable timeout,
        #        round-robin urls,
        #        redirect handling, etc
        begin
          c.perform
        rescue => e
          emit :error, e
          return handle_error
        end

        if c.response_code != 200
          emit :http_error, c.response_code
          return handle_error
        end

        emit :success, c.body_str
        parse_result(c.body_str, c)
      end
    end # class Connection
  end # module WebClient
end # module XRBP
