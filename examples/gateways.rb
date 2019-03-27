$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

connection = XRBP::WebClient::Connection.new
XRBP::Model::Gateway.all(:connection => connection)
                    .each do |gw|
  puts "#{gw[:id]} #{gw[:names].join(",")} (#{gw[:currencies].join(",")})"
end
