$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'
require 'xrbp/nodestore/backends/rocksdb'

db = XRBP::NodeStore::Backends::RocksDB.new "/var/lib/rippled/rocksdb/rippledb.0899"

#ledger = "B506ADD630CB707044B4BFFCD943C1395966692A13DD618E5BD0978A006B43BD"
#ledger = [ledger].pack("H*")
#puts db.ledger(ledger)

account = "0001bf7468341666f1f47a95e0f4d88e68b5fc7d20d77437cb22954fbbfe6127"
account = [account].pack("H*")
puts db.account(account).unpack("H*")
