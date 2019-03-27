$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

puts XRBP::Model::Account.latest(:connection => XRBP::WebClient::Connection.new)
