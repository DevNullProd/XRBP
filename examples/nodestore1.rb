$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'
require 'xrbp/nodestore/backends/rocksdb'

ledger = "B506ADD630CB707044B4BFFCD943C1395966692A13DD618E5BD0978A006B43BD"
ledger = [ledger].pack("H*")

db = XRBP::NodeStore::Backends::RocksDB.new "/var/lib/rippled/rocksdb/rippledb.0899"
puts db.ledger ledger
