$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

connection = XRBP::WebClient::Connection.new
XRBP::Model::Validator.all(:connection => connection)
                      .each do |v|
  puts v
end
