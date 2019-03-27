$: << File.expand_path('../../../lib', __FILE__)
require 'xrbp'

include XRBP::DSL

puts ledger
puts ledger(45918932)
