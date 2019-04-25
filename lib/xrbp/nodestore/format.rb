require "bistro"

module XRBP
  module NodeStore
    module Format
      NODE_TYPES = {
        1 => :ledger,
        2 => :tx,
        3 => :account_node,
        4 => :tx_node
      }

      HASH_PREFIXES = {
        "54584E00" => :tx_id,
        "534E4400" => :tx_node,
        "4D4C4E00" => :leaf_node,
        "4D494E00" => :inner_node,
        "4C575200" => :ledger_master,
        "53545800" => :tx_sign,
        "56414C00" => :validation,
        "50525000" => :proposal
      }

      LEDGER = Bistro.new([
         'H16', nil, # unused
           'c', 'nt_ledger',
          'H8', 'hp_ledger_master',
           'N', 'index',
           'Q', 'total_coins',
         'H64', 'parent_hash',
         'H64', 'tx_hash',
         'H64', 'account_hash',
           'N', 'parent_close_time',
           'N', 'close_time',
           'C', 'close_time_resolution',
           'C', 'close_flags',
      ])
    end # module Format
  end # module NodeStore
end # module XRBP
