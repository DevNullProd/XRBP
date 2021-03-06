# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: ripple.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "protocol.TMManifest" do
    optional :stobject, :bytes, 1
  end
  add_message "protocol.TMManifests" do
    repeated :list, :message, 1, "protocol.TMManifest"
    optional :history, :bool, 2
  end
  add_message "protocol.TMProofWork" do
    optional :token, :string, 1
    optional :iterations, :uint32, 2
    optional :target, :bytes, 3
    optional :challenge, :bytes, 4
    optional :response, :bytes, 5
    optional :result, :enum, 6, "protocol.TMProofWork.PowResult"
  end
  add_enum "protocol.TMProofWork.PowResult" do
    value :POWROK, 0
    value :POWRREUSED, 1
    value :POWREXPIRED, 2
    value :POWRTOOEASY, 3
    value :POWRINVALID, 4
    value :POWRDISCONNECT, 5
  end
  add_message "protocol.TMHello" do
    optional :protoVersion, :uint32, 1
    optional :protoVersionMin, :uint32, 2
    optional :nodePublic, :bytes, 3
    optional :nodeProof, :bytes, 4
    optional :fullVersion, :string, 5
    optional :netTime, :uint64, 6
    optional :ipv4Port, :uint32, 7
    optional :ledgerIndex, :uint32, 8
    optional :ledgerClosed, :bytes, 9
    optional :ledgerPrevious, :bytes, 10
    optional :nodePrivate, :bool, 11
    optional :proofOfWork, :message, 12, "protocol.TMProofWork"
    optional :testNet, :bool, 13
    optional :local_ip, :uint32, 14
    optional :remote_ip, :uint32, 15
    optional :local_ip_str, :string, 16
    optional :remote_ip_str, :string, 17
  end
  add_message "protocol.TMClusterNode" do
    optional :publicKey, :string, 1
    optional :reportTime, :uint32, 2
    optional :nodeLoad, :uint32, 3
    optional :nodeName, :string, 4
    optional :address, :string, 5
  end
  add_message "protocol.TMLoadSource" do
    optional :name, :string, 1
    optional :cost, :uint32, 2
    optional :count, :uint32, 3
  end
  add_message "protocol.TMCluster" do
    repeated :clusterNodes, :message, 1, "protocol.TMClusterNode"
    repeated :loadSources, :message, 2, "protocol.TMLoadSource"
  end
  add_message "protocol.TMGetShardInfo" do
    optional :hops, :uint32, 1
    optional :lastLink, :bool, 2
    repeated :peerchain, :uint32, 3
  end
  add_message "protocol.TMShardInfo" do
    optional :shardIndexes, :string, 1
    optional :nodePubKey, :bytes, 2
    optional :endpoint, :string, 3
    optional :lastLink, :bool, 4
    repeated :peerchain, :uint32, 5
  end
  add_message "protocol.TMLink" do
    optional :nodePubKey, :bytes, 1
  end
  add_message "protocol.TMGetPeerShardInfo" do
    optional :hops, :uint32, 1
    optional :lastLink, :bool, 2
    repeated :peerChain, :message, 3, "protocol.TMLink"
  end
  add_message "protocol.TMPeerShardInfo" do
    optional :shardIndexes, :string, 1
    optional :nodePubKey, :bytes, 2
    optional :endpoint, :string, 3
    optional :lastLink, :bool, 4
    repeated :peerChain, :message, 5, "protocol.TMLink"
  end
  add_message "protocol.TMTransaction" do
    optional :rawTransaction, :bytes, 1
    optional :status, :enum, 2, "protocol.TransactionStatus"
    optional :receiveTimestamp, :uint64, 3
    optional :deferred, :bool, 4
  end
  add_message "protocol.TMStatusChange" do
    optional :newStatus, :enum, 1, "protocol.NodeStatus"
    optional :newEvent, :enum, 2, "protocol.NodeEvent"
    optional :ledgerSeq, :uint32, 3
    optional :ledgerHash, :bytes, 4
    optional :ledgerHashPrevious, :bytes, 5
    optional :networkTime, :uint64, 6
    optional :firstSeq, :uint32, 7
    optional :lastSeq, :uint32, 8
  end
  add_message "protocol.TMProposeSet" do
    optional :proposeSeq, :uint32, 1
    optional :currentTxHash, :bytes, 2
    optional :nodePubKey, :bytes, 3
    optional :closeTime, :uint32, 4
    optional :signature, :bytes, 5
    optional :previousledger, :bytes, 6
    optional :checkedSignature, :bool, 7
    repeated :addedTransactions, :bytes, 10
    repeated :removedTransactions, :bytes, 11
    optional :hops, :uint32, 12
  end
  add_message "protocol.TMHaveTransactionSet" do
    optional :status, :enum, 1, "protocol.TxSetStatus"
    optional :hash, :bytes, 2
  end
  add_message "protocol.TMValidation" do
    optional :validation, :bytes, 1
    optional :checkedSignature, :bool, 2
    optional :hops, :uint32, 3
  end
  add_message "protocol.TMGetPeers" do
    optional :doWeNeedThis, :uint32, 1
  end
  add_message "protocol.TMIPv4Endpoint" do
    optional :ipv4, :uint32, 1
    optional :ipv4Port, :uint32, 2
  end
  add_message "protocol.TMPeers" do
    repeated :nodes, :message, 1, "protocol.TMIPv4Endpoint"
  end
  add_message "protocol.TMEndpoint" do
    optional :ipv4, :message, 1, "protocol.TMIPv4Endpoint"
    optional :hops, :uint32, 2
  end
  add_message "protocol.TMEndpoints" do
    optional :version, :uint32, 1
    repeated :endpoints, :message, 2, "protocol.TMEndpoint"
    repeated :endpoints_v2, :message, 3, "protocol.TMEndpoints.TMEndpointv2"
  end
  add_message "protocol.TMEndpoints.TMEndpointv2" do
    optional :endpoint, :string, 1
    optional :hops, :uint32, 2
  end
  add_message "protocol.TMIndexedObject" do
    optional :hash, :bytes, 1
    optional :nodeID, :bytes, 2
    optional :index, :bytes, 3
    optional :data, :bytes, 4
    optional :ledgerSeq, :uint32, 5
  end
  add_message "protocol.TMGetObjectByHash" do
    optional :type, :enum, 1, "protocol.TMGetObjectByHash.ObjectType"
    optional :query, :bool, 2
    optional :seq, :uint32, 3
    optional :ledgerHash, :bytes, 4
    optional :fat, :bool, 5
    repeated :objects, :message, 6, "protocol.TMIndexedObject"
  end
  add_enum "protocol.TMGetObjectByHash.ObjectType" do
    value :OTUNKNOWN, 0
    value :OTLEDGER, 1
    value :OTTRANSACTION, 2
    value :OTTRANSACTION_NODE, 3
    value :OTSTATE_NODE, 4
    value :OTCAS_OBJECT, 5
    value :OTFETCH_PACK, 6
  end
  add_message "protocol.TMLedgerNode" do
    optional :nodedata, :bytes, 1
    optional :nodeid, :bytes, 2
  end
  add_message "protocol.TMGetLedger" do
    optional :itype, :enum, 1, "protocol.TMLedgerInfoType"
    optional :ltype, :enum, 2, "protocol.TMLedgerType"
    optional :ledgerHash, :bytes, 3
    optional :ledgerSeq, :uint32, 4
    repeated :nodeIDs, :bytes, 5
    optional :requestCookie, :uint64, 6
    optional :queryType, :enum, 7, "protocol.TMQueryType"
    optional :queryDepth, :uint32, 8
  end
  add_message "protocol.TMLedgerData" do
    optional :ledgerHash, :bytes, 1
    optional :ledgerSeq, :uint32, 2
    optional :type, :enum, 3, "protocol.TMLedgerInfoType"
    repeated :nodes, :message, 4, "protocol.TMLedgerNode"
    optional :requestCookie, :uint32, 5
    optional :error, :enum, 6, "protocol.TMReplyError"
  end
  add_message "protocol.TMPing" do
    optional :type, :enum, 1, "protocol.TMPing.pingType"
    optional :seq, :uint32, 2
    optional :pingTime, :uint64, 3
    optional :netTime, :uint64, 4
  end
  add_enum "protocol.TMPing.pingType" do
    value :PTPING, 0
    value :PTPONG, 1
  end
  add_enum "protocol.MessageType" do
    value :MTZero, 0
    value :MTHELLO, 1
    value :MTMANIFESTS, 2
    value :MTPING, 3
    value :MTPROOFOFWORK, 4
    value :MTCLUSTER, 5
    value :MTGET_PEERS, 12
    value :MTPEERS, 13
    value :MTENDPOINTS, 15
    value :MTTRANSACTION, 30
    value :MTGET_LEDGER, 31
    value :MTLEDGER_DATA, 32
    value :MTPROPOSE_LEDGER, 33
    value :MTSTATUS_CHANGE, 34
    value :MTHAVE_SET, 35
    value :MTVALIDATION, 41
    value :MTGET_OBJECTS, 42
    value :MTGET_SHARD_INFO, 50
    value :MTSHARD_INFO, 51
    value :MTGET_PEER_SHARD_INFO, 52
    value :MTPEER_SHARD_INFO, 53
  end
  add_enum "protocol.TransactionStatus" do
    value :TSZERO, 0
    value :TSNEW, 1
    value :TSCURRENT, 2
    value :TSCOMMITED, 3
    value :TSREJECT_CONFLICT, 4
    value :TSREJECT_INVALID, 5
    value :TSREJECT_FUNDS, 6
    value :TSHELD_SEQ, 7
    value :TSHELD_LEDGER, 8
  end
  add_enum "protocol.NodeStatus" do
    value :NSZERO, 0
    value :NSCONNECTING, 1
    value :NSCONNECTED, 2
    value :NSMONITORING, 3
    value :NSVALIDATING, 4
    value :NSSHUTTING, 5
  end
  add_enum "protocol.NodeEvent" do
    value :NEZERO, 0
    value :NECLOSING_LEDGER, 1
    value :NEACCEPTED_LEDGER, 2
    value :NESWITCHED_LEDGER, 3
    value :NELOST_SYNC, 4
  end
  add_enum "protocol.TxSetStatus" do
    value :TSsZERO, 0
    value :TSHAVE, 1
    value :TSCAN_GET, 2
    value :TSNEED, 3
  end
  add_enum "protocol.TMLedgerInfoType" do
    value :LIBASE, 0
    value :LITX_NODE, 1
    value :LIAS_NODE, 2
    value :LITS_CANDIDATE, 3
  end
  add_enum "protocol.TMLedgerType" do
    value :LTACCEPTED, 0
    value :LTCURRENT, 1
    value :LTCLOSED, 2
  end
  add_enum "protocol.TMQueryType" do
    value :QTINDIRECT, 0
  end
  add_enum "protocol.TMReplyError" do
    value :REZERO, 0
    value :RENO_LEDGER, 1
    value :RENO_NODE, 2
  end
end

module Protocol
  TMManifest = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMManifest").msgclass
  TMManifests = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMManifests").msgclass
  TMProofWork = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMProofWork").msgclass
  TMProofWork::PowResult = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMProofWork.PowResult").enummodule
  TMHello = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMHello").msgclass
  TMClusterNode = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMClusterNode").msgclass
  TMLoadSource = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMLoadSource").msgclass
  TMCluster = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMCluster").msgclass
  TMGetShardInfo = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMGetShardInfo").msgclass
  TMShardInfo = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMShardInfo").msgclass
  TMLink = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMLink").msgclass
  TMGetPeerShardInfo = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMGetPeerShardInfo").msgclass
  TMPeerShardInfo = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMPeerShardInfo").msgclass
  TMTransaction = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMTransaction").msgclass
  TMStatusChange = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMStatusChange").msgclass
  TMProposeSet = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMProposeSet").msgclass
  TMHaveTransactionSet = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMHaveTransactionSet").msgclass
  TMValidation = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMValidation").msgclass
  TMGetPeers = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMGetPeers").msgclass
  TMIPv4Endpoint = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMIPv4Endpoint").msgclass
  TMPeers = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMPeers").msgclass
  TMEndpoint = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMEndpoint").msgclass
  TMEndpoints = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMEndpoints").msgclass
  TMEndpoints::TMEndpointv2 = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMEndpoints.TMEndpointv2").msgclass
  TMIndexedObject = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMIndexedObject").msgclass
  TMGetObjectByHash = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMGetObjectByHash").msgclass
  TMGetObjectByHash::ObjectType = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMGetObjectByHash.ObjectType").enummodule
  TMLedgerNode = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMLedgerNode").msgclass
  TMGetLedger = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMGetLedger").msgclass
  TMLedgerData = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMLedgerData").msgclass
  TMPing = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMPing").msgclass
  TMPing::PingType = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMPing.pingType").enummodule
  MessageType = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.MessageType").enummodule
  TransactionStatus = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TransactionStatus").enummodule
  NodeStatus = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.NodeStatus").enummodule
  NodeEvent = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.NodeEvent").enummodule
  TxSetStatus = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TxSetStatus").enummodule
  TMLedgerInfoType = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMLedgerInfoType").enummodule
  TMLedgerType = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMLedgerType").enummodule
  TMQueryType = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMQueryType").enummodule
  TMReplyError = Google::Protobuf::DescriptorPool.generated_pool.lookup("protocol.TMReplyError").enummodule
end
