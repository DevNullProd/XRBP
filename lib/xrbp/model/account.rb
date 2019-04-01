require 'fileutils'
require_relative './parsers/account'

module XRBP
  module Model
    class Account < Base
      extend Base::ClassMethods

      DATE_FORMAT = "%Y-%m-%dT%H:%M:%SZ"

      attr_accessor :id

      # Local data cache location
      def self.cache
        @cache ||= File.expand_path("~/.xrbp/accounts/")
      end

      # All cached accounts
      def self.cached
        Dir.glob("#{cache}/*").sort.collect { |f|
          next nil if f == "#{cache}marker" ||
                      f == "#{cache}start"
          begin
            JSON.parse(File.read(f))
                .collect { |acct|
                  # convert string keys to symbols
                  Hash[acct.map { |k,v| [k.intern, v] }]
                }
          rescue
            nil
          end
        }.flatten.compact
      end

      # TODO invoke gen account command via websocket
      #def self.create(opts={})
      #end

      # TODO 'parallel accounts' method,
      #   - split period between Genesis and Time.now into
      #     N-segments (of configurable length: hours, days,
      #     months, etc)
      #   - parallel retrieve segments specifying start param
      #     & following markers until data is no longer
      #     in-domain
      #   - emit :account signal w/ each account during process
      #     & reassemble complete set after

      # Retrieve all accounts via WebClient::Connection
      #
      # @param opts [Hash] options to retrieve accounts with
      # @option opts [WebClient::Connection] :connection Connection
      #   to use to retrieve accounts
      def self.all(opts={})
        set_opts(opts)
        FileUtils.mkdir_p(cache) unless File.exist?(cache)

        cached.each { |acct|
          break if connection.force_quit?
          connection.emit :account, acct
        } if opts[:replay]

        # start at last marker
        marker = File.exist?("#{cache}/marker") ?
                   File.read("#{cache}/marker") : nil

        # load start time, if set
        start = File.exist?("#{cache}/start") ?
                  File.read("#{cache}/start") :
           GENESIS_TIME.strftime(DATE_FORMAT)

        # Parse results
        connection.add_plugin :result_parser       unless connection.plugin?(:result_parser)
        connection.add_plugin Parsers::AccountInfo unless connection.plugin?(Parsers::AccountInfo)

        # Retrieve data until complete
        accounts = []
        finished = false
        until finished || connection.force_quit?
          # HTTP request
          connection.url = "https://data.ripple.com/v2/accounts/?"\
                             "start=#{start}&limit=1000&marker=#{marker}"
          res = connection.perform

          # Cache data
          cache_file = "#{cache}/#{marker || "genesis"}"
          File.write(cache_file, res[:accounts].to_json)

          # Emit signal
          res[:accounts].each { |acct|
            break if connection.force_quit?
            connection.emit :account, acct
          }

          break if connection.force_quit?

          marker = res[:marker]
          accounts += res[:accounts]

          # Store state, eval exit condition
          File.write("#{cache}/marker", marker.to_s)
          finished = !marker
        end

        # Store state for next run
        File.write("#{cache}/start",
                   accounts.last[:inception]) unless marker

        accounts
      end

      # Retrieve latest account using specified WebClient::Connection
      #
      # @param opts [Hash] options to retrieve account with
      # @option opts [WebClient::Connection] :connection Connection
      #   to use to retrieve account
      def self.latest(opts={})
        set_opts(opts)

        connection.add_plugin :result_parser       unless connection.plugin?(:result_parser)
        connection.add_plugin Parsers::AccountInfo unless connection.plugin?(Parsers::AccountInfo)

        connection.url = "https://data.ripple.com/v2/accounts/?"\
                           "descending=true&limit=1000"
        res = connection.perform
        res[:accounts].first
      end

      ###

      # Initialize new Account instance
      #
      # @param opts [Hash] options to initialize account with
      # @option opts [String] :id id of account
      #   to use to retrieve account
      def initialize(opts={})
        @id = opts[:id]
        super(opts)
      end

      # Retrieve account info via WebSocket::Connection
      #
      # @param opts [Hash] options to retrieve account info with
      # @option opts [WebSocket::Connection] :connection Connection
      #   to use to retrieve account info
      def info(opts={}, &bl)
        set_opts(opts)
        connection.cmd(WebSocket::Cmds::AccountInfo.new(id, full_opts), &bl)
      end

      # Retrieve account objects via WebSocket::Connection
      #
      # @param opts [Hash] options to retrieve account objects with
      # @option opts [WebSocket::Connection] :connection Connection
      #   to use to retrieve account objects
      def objects(opts={}, &bl)
        set_opts(opts)
        connection.cmd(WebSocket::Cmds::AccountObjects.new(id, full_opts), &bl)
      end

      # Retrieve account username via WebClient::Connection
      #
      # @param opts [Hash] options to retrieve account username with
      # @option opts [WebClient::Connection] :connection Connection
      #   to use to retrieve account username
      def username(opts={}, &bl)
        set_opts(opts)
        connection.url = "https://id.ripple.com/v1/authinfo?username=#{id}"

        connection.add_plugin :result_parser           unless connection.plugin?(:result_parser)
        connection.add_plugin Parsers::AccountUsername unless connection.plugin?(Parsers::AccountUsername)

        connection.perform
      end
    end # class Account
  end # module Model
end # module XRBP
