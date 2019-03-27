$: << File.expand_path('../../../lib', __FILE__)
require 'xrbp'

include XRBP::DSL

validators.each { |v|
  puts v["validation_public_key"] + ": " + v["domain"].to_s
}
