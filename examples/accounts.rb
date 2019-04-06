$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

connection = XRBP::WebClient::Connection.new
connection.on :account do |acct|
  puts acct
end

Signal.trap("INT") {
  connection.force_quit!
}

# XRBP::Model::Account.all(:connection => connection, :replay     => true)

acc = XRBP::Model::Account.new(id: 'rn1EBe15wNK5737xxw79PLJwNeEyipMiVH')
p acc.set_opts(limit: 15)
p acc.full_opts
