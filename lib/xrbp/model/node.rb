require 'uri'
require 'resolv'

require_relative './parsers/node'

module XRBP
  module Model
    class Node < Base
      extend Base::ClassMethods

      DEFAULT_CRAWL_PORT = 51235

      attr_accessor :ip, :port
      attr_accessor :addr, :version, :uptime, :type, :ledgers

      # Return unique node id
      def id
        "#{ip}:#{port}"
      end

      # Return node url
      def url
        "https://#{ip}:#{port}/crawl"
      end

      # Return bool indicating if this node is valid for crawling
      def valid?
        return false unless ip && port

        # ensure no parsing errs
        begin
          # FIXME URI.parse is limiting our ability to traverse entire node-set,
          #       some nodes are represented as IPv6 addresses which is throwing
          #       things off.
          URI.parse(url)
        rescue
          false
        end

        true
      end

      def ==(o)
        ip == o.ip && port == o.port
      end

      # Return new node from the specified url
      #
      # @param url [String] node url
      # @return [Node] new node instance
      def self.parse_url(url)
        n = new

        uri    = URI.parse(url)
        n.ip   = Resolv.getaddress(uri.host)
        n.port = uri.port

        n
      end

      # Return new node from the specified peer object
      #
      # @param p [Hash] peer data
      # @return [Node] new node instance
      def self.from_peer(p)
        n = new

        n.addr    = p["public_key"]
        n.ip      = p["ip"]
        n.port    = p["port"] || DEFAULT_CRAWL_PORT
        n.version = p["version"].split("-").last
        n.uptime  = p["uptime"]
        n.type    = p["type"]
        n.ledgers = p["complete_ledgers"]

        n
      end

      # Crawl nodes via WebClient::Connection
      #
      # @param opts [Hash] options to crawl nodes with
      # @option opts [WebSocket::Connection] :connection Connection
      #   to use to crawl nodes
      # @option opts [Integer] :delay optional delay to wait between
      #   crawl iterations
      def self.crawl(start, opts={})
        set_opts(opts)
        delay = opts[:delay] || 1

        queue = Array.new
        queue << start

        connection.add_plugin :result_parser     unless connection.plugin?(:result_parser)
        connection.add_plugin Parsers::NodePeers unless connection.plugin?(Parsers::NodePeers)

        connection.ssl_verify_peer = false
        connection.ssl_verify_host = false

        until connection.force_quit?
          node = queue.shift
          node = parse_url node unless node.is_a?(Node)

          connection.emit :precrawl, node
          connection.url = node.url

          peers = connection.perform
          if peers.nil? || peers.empty?
            queue << node
            connection.emit :crawlerr, node
            connection.rsleep(delay) unless connection.force_quit?
            next
          end

          connection.emit :peers, node, peers
          peers.each { |peer|
            break if connection.force_quit?

            peer = Node.from_peer peer
            next unless peer.valid? # skip unless valid

            connection.emit :peer, node, peer
            queue << peer unless queue.include?(peer)
          }

          queue << node
          connection.emit :postcrawl, node
          connection.rsleep(delay) unless connection.force_quit?
        end
      end
    end
  end # module Model
end # module XRBP
