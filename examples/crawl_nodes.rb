$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

connection = XRBP::WebClient::Connection.new
connection.timeout = 3

Signal.trap("INT") {
  connection.force_quit!
}

connection.on :precrawl do |node|
  puts "Crawling: #{node.url}"
end

connection.on :crawlerr do |node|
  puts "Could not Crawl: #{node.url}"
end

connection.on :postcrawl do |node|
  puts "Done Crawling: #{node.url}"
end

connection.on :peers do |node, peers|
  puts "#{node.url}: #{peers.size} peers"
end

connection.on :peer do |node, peer|
  puts " #{peer.url}"
end

XRBP::Model::Node.crawl("wss://s1.ripple.com:51235",
                        :connection => connection)
