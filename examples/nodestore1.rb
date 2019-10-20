$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'

# for rocksdb:
require 'xrbp/nodestore/backends/rocksdb'
db = XRBP::NodeStore::Backends::RocksDB.new "/var/lib/rippled/rocksdb/rippledb.0899"

# for nudb:
#require 'xrbp/nodestore/backends/nudb'
#db = XRBP::NodeStore::Backends::NuDB.new "/var/lib/rippled/nudb/"

ledger = "32E073D7E4D722D956F7FDE095F756FBB86DC9CA487EB0D9ABF5151A8D88F912"
ledger = [ledger].pack("H*")
puts db.ledger(ledger)

gw1 = 'razqQKzJRdB4UxFPWf5NEpEG3WMkmwgcXA'
iou1 = {:currency => 'XRP', :account => XRBP::Crypto.xrp_account}
iou2 = {:currency => 'CNY', :account => gw1}
nledger = XRBP::NodeStore::Ledger.new(:db => db, :hash => ledger)
puts nledger.order_book iou1, iou2
puts nledger.txs

require 'xrbp/nodestore/sqldb'
sql = XRBP::NodeStore::SQLDB.new("/var/lib/rippled/nudb")
puts sql.ledgers.hash_for_seq(49340234)
puts sql.ledgers.count
