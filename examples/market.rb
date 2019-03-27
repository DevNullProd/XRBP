$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

connection = XRBP::WebClient::Connection.new
markets = XRBP::Model::Market.all(:connection => connection)
markets.each do |market|
  puts market.inspect
end

connection = XRBP::WebClient::Connection.new
puts XRBP::Model::Market.new(:connection => connection,
                             :route => markets.sample[:route] + "/ohlc?periods=60")
                        .quotes
