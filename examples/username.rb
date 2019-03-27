$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

connection = XRBP::WebClient::Connection.new
puts XRBP::Model::Account.new(:id => "rJe12wEAmGtRw44bo3jQqQUMTVFSLPewCS",
                              :connection => connection)
                         .username

puts XRBP::Model::Account.new(:id => "rfexLLNpC6dqyLagjV439EyvfqdYNHsWSH",
                              :connection => connection)
                         .username

