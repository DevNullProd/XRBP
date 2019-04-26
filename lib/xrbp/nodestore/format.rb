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

      SERIALIZED_TYPES = {
         1 => :uint16,
         2 => :uint32,
         3 => :uint64,
         4 => :hash128,
         5 => :hash256,
         6 => :amount,
         7 => :vl,
         8 => :account,
        14 => :object,
        15 => :array,
        16 => :uint8,
        17 => :hash160,
        18 => :pathset,
        19 => :vector256
      }

      ENCODINGS = {
        # 16-bit unsigned integers (common)
        [:uint16,  1] => :ledger_entry_type,
        [:uint16,  2] => :transaction_type,
        [:uint16,  3] => :signer_weight,

        # 32-bit unsigned integers (common)
        [:uint32,  2] => :flags,
        [:uint32,  3] => :source_tag,
        [:uint32,  4] => :sequence,
        [:uint32,  5] => :previous_txn_lgr_seq,
        [:uint32,  6] => :ledger_sequence,
        [:uint32,  7] => :close_time,
        [:uint32,  8] => :parent_close_time,
        [:uint32,  9] => :signing_time,
        [:uint32, 10] => :expiration,
        [:uint32, 11] => :transfer_rate,
        [:uint32, 12] => :wallet_size,
        [:uint32, 13] => :owner_count,
        [:uint32, 14] => :destination_tag,

        # 32-bit unsigned integers (uncommon)
        [:uint32, 16] => :high_quality_in,
        [:uint32, 17] => :high_quality_out,
        [:uint32, 18] => :low_quality_in,
        [:uint32, 19] => :low_quality_out,
        [:uint32, 20] => :quality_in,
        [:uint32, 21] => :quality_out,
        [:uint32, 22] => :stamp_escrow,
        [:uint32, 23] => :bond_amount,
        [:uint32, 24] => :load_fee,
        [:uint32, 25] => :offer_sequence,

        [:uint32, 26] => :first_ledger_sequence,
        [:uint32, 27] => :last_ledger_sequence,

        [:uint32, 28] => :transaction_index,
        [:uint32, 29] => :operation_limit,

        [:uint32, 30] => :reference_fee_units,
        [:uint32, 31] => :reserve_base,
        [:uint32, 32] => :reserve_increment,
        [:uint32, 33] => :set_flag,
        [:uint32, 34] => :clear_flag,
        [:uint32, 35] => :signer_quorum,
        [:uint32, 36] => :cancel_after,
        [:uint32, 37] => :finish_after,
        [:uint32, 38] => :signer_list_id,
        [:uint32, 39] => :settle_delay,

        # 64-bit unsigned integers (common)
        [:uint64,  1] => :index_next,
        [:uint64,  2] => :index_previous,
        [:uint64,  3] => :book_node,
        [:uint64,  4] => :owner_node,
        [:uint64,  5] => :base_fee,
        [:uint64,  6] => :exchange_rate,
        [:uint64,  7] => :low_node,
        [:uint64,  8] => :high_node,

        # 128-bit (common)
        [:hash128,  1] => :email_hash,

        # 256-bit (common)
        [:hash256,  1] => :ledger_hash,
        [:hash256,  2] => :parent_hash,
        [:hash256,  3] => :tx_hash,
        [:hash256,  4] => :account_hash,
        [:hash256,  5] => :previous_txn_id,
        [:hash256,  6] => :ledger_index,
        [:hash256,  7] => :wallet_locator,
        [:hash256,  8] => :root_index,
        [:hash256,  9] => :account_txn_id,

        # 256-bit (uncommon)
        [:hash256,  16] => :book_directory,
        [:hash256,  17] => :invoice_id,
        [:hash256,  18] => :nickname,
        [:hash256,  19] => :amendment,
        [:hash256,  20] => :ticket_id,
        [:hash256,  21] => :digest,
        [:hash256,  22] => :channel,
        [:hash256,  24] => :check_id,

        # currency amount (common)
        [:amount,   1] => :amount,
        [:amount,   2] => :balance,
        [:amount,   3] => :limit_amount,
        [:amount,   4] => :taker_pays,
        [:amount,   5] => :taker_gets,
        [:amount,   6] => :low_limit,
        [:amount,   7] => :high_limit,
        [:amount,   8] => :fee,
        [:amount,   9] => :send_max,
        [:amount,  10] => :deliver_min,

        # currency amount (uncommon)
        [:amount,  16] => :minimum_offer,
        [:amount,  17] => :ripple_escrow,
        [:amount,  18] => :delivered_amount,

        # variable length (common)
        [:vl,       1] => :public_key,
        [:vl,       2] => :message_key,
        [:vl,       3] => :signing_pub_key,
        [:vl,       4] => :txn_signature,
        [:vl,       5] => :generator,
        [:vl,       6] => :signature,
        [:vl,       7] => :domain,
        [:vl,       8] => :fund_code,
        [:vl,       9] => :remove_code,
        [:vl,      10] => :expire_code,
        [:vl,      11] => :create_code,
        [:vl,      12] => :memo_type,
        [:vl,      13] => :memo_data,
        [:vl,      14] => :memo_format,

        # variable length (uncommon)
        [:vl,      16] => :fulfillment,
        [:vl,      17] => :condition,
        [:vl,      18] => :master_signature,

        # account
        [:account,  1] => :account,
        [:account,  2] => :owner,
        [:account,  3] => :destination,
        [:account,  4] => :issuer,
        [:account,  7] => :target,
        [:account,  8] => :regular_key,

        # inner object
        [:object,  1] => :end_of_object,
        [:object,  2] => :transaction_metadata,
        [:object,  3] => :created_node,
        [:object,  4] => :deleted_node,
        [:object,  5] => :modified_node,
        [:object,  6] => :previous_fields,
        [:object,  7] => :final_fields,
        [:object,  8] => :new_fields,
        [:object,  9] => :template_entry,
        [:object, 10] => :memo,
        [:object, 11] => :signer_entry,

        # inner object (uncommon)
        [:object, 16] => :signer,
        [:object, 18] => :majority,

        # array of objects
        [:array,   1] => :end_of_array,
        [:array,   2] => :signing_accounts,
        [:array,   3] => :signers,
        [:array,   4] => :signer_entries,
        [:array,   5] => :template,
        [:array,   6] => :necessary,
        [:array,   7] => :sufficient,
        [:array,   8] => :affected_nodes,
        [:array,   9] => :memos,

        # array of objects (uncommon)
        [:array,  16] => :majorities,

        # 8-bit unsigned integers (common)
        [:uint8,   1] => :close_resolution,
        [:uint8,   2] => :method,
        [:uint8,   3] => :transaction_result,

        # 8-bit unsigned integers (uncommon)
        [:uint8,  16] => :tick_size,

        # 160-bit (common)
        [:hash160, 1] => :taker_pays_currency,
        [:hash160, 2] => :taker_pays_issuer,
        [:hash160, 3] => :taker_gets_currency,
        [:hash160, 4] => :taker_gets_issuer,

        # path set
        [:pathset, 1] => :paths,

        # vector of 256-bit
        [:vector256, 1] => :indexes,
        [:vector256, 2] => :hashes,
        [:vector256, 3] => :amendments,
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

      CURRENCY_CODE = Bistro.new([
        'C',   'type_code',
        'C11', 'reserved1',
        'C3',  'iso_code',
        'C5',  'reserved2'
      ])
    end # module Format
  end # module NodeStore
end # module XRBP
