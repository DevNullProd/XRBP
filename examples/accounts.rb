$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

connection = XRBP::WebClient::Connection.new
connection.on :account do |acct|
  puts acct
end

Signal.trap("INT") {
  connection.force_quit!
}

XRBP::Model::Account.all(:connection => connection)
