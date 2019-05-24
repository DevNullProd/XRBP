module XRBP
  module Overlay
    # Map of Protocol Message Type to Class
    #
    # See {https://github.com/ripple/rippled/blob/develop/src/ripple/overlay/impl/ProtocolMessage.h ProtocolMessage.h}
    MESSAGES = {
      :MTHELLO                => Protocol::TMHello,
      :MTMANIFESTS            => Protocol::TMManifests,
      :MTPING                 => Protocol::TMPing,
      :MTCLUSTER              => Protocol::TMCluster,
      :MTGET_SHARD_INFO       => Protocol::TMGetShardInfo,
      :MTSHARD_INFO           => Protocol::TMShardInfo,
      :MTGET_PEER_SHARD_INFO  => Protocol::TMGetPeerShardInfo,
      :MTGET_PEERS            => Protocol::TMGetPeers,
      :MTPEERS                => Protocol::TMPeers,
      :MTENDPOINTS            => Protocol::TMEndpoints,
      :MTTRANSACTION          => Protocol::TMTransaction,
      :MTGET_LEDGER           => Protocol::TMGetLedger,
      :MTLEDGER_DATA          => Protocol::TMLedgerData,
      :MTPROPOSE_LEDGER       => Protocol::TMProposeSet,
      :MTSTATUS_CHANGE        => Protocol::TMStatusChange,
      :MTHAVE_SET             => Protocol::TMHaveTransactionSet,
      :MTVALIDATION           => Protocol::TMValidation,
      :MTGET_OBJECTS          => Protocol::TMGetObjectByHash
    }

    def self.create_msg(hash)
      # ...
    end
  end # module Overlay
end # module XRBP
