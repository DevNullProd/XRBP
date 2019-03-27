module XRBP
  module WebClient
    include PluginRegistry
  end # module WebClient
end # module XRPB

require_relative './plugins/result_parser'
require_relative './plugins/autoretry'
