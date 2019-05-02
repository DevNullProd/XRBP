$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

overlay = XRBP::Overlay::Connection.new "r.ripple.com", 51235
overlay.connect

while line = overlay.read
  puts line
end

overlay.close
