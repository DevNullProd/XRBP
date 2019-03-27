module XRBP
  # The DSL namespace can be *included* in client logic to provide
  # an easy-to-use mechanism to read and write XRP data.
  #
  # @example Retrieve ledger, subscribe to updates
  #   include XRBP::DSL
  #
  #   puts "Genesis ledger: "
  #   puts ledger(32570)
  #
  #   websocket_msg do |msg|
  #     puts "Ledger received:"
  #     puts msg
  #   end
  #
  #   subscribe_to_ledgers
  module DSL
  end # module DSL
end # module XRBP

require_relative './dsl/websocket'
require_relative './dsl/webclient'
require_relative './dsl/accounts'
require_relative './dsl/ledgers'
require_relative './dsl/validators'
