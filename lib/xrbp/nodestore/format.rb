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

      ###

      TYPE_INFER = Bistro.new([
         'H16', nil, # unused
           'c', 'node_type',
          'H8', 'hash_prefix',
          'H*', 'node'
      ])

      INNER_NODE = Bistro.new([
         'H16', nil, # unused
           'c', 'node_type', # can be one of NODE_TYPES for: 'account_node' or 'tx_node'
          'H8', 'hp_inner_node',
         'H64', 'child0',
         'H64', 'child1',
         'H64', 'child2',
         'H64', 'child3',
         'H64', 'child4',
         'H64', 'child5',
         'H64', 'child6',
         'H64', 'child7',
         'H64', 'child8',
         'H64', 'child9',
         'H64', 'child10',
         'H64', 'child11',
         'H64', 'child12',
         'H64', 'child13',
         'H64', 'child14',
         'H64', 'child15',
         'H64', 'child16',
         'H64', 'child17',
         'H64', 'child18',
         'H64', 'child19',
         'H64', 'child20',
         'H64', 'child21',
         'H64', 'child22',
         'H64', 'child23',
         'H64', 'child24',
         'H64', 'child25',
         'H64', 'child26',
         'H64', 'child27',
         'H64', 'child28',
         'H64', 'child29',
         'H64', 'child30',
         'H64', 'child31'
      ])

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
