$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

connection = XRBP::WebClient::Connection.new
connection.add_plugin :autoretry
connection.url = "https://devnull.network"
puts connection.perform
