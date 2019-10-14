require 'xrbp/nodestore/backends/rocksdb'

require_relative "./db_access"
#require_relative "./db_iterator_access"
#require_relative "../db_parser"

describe XRBP::NodeStore::Backends::RocksDB do
  before(:each) do
    Camcorder.intercept_constructor ::RocksDB::DB
  end

  after(:each) do
    Camcorder.deintercept_constructor ::RocksDB::DB
  end

  let(:db) {
    XRBP::NodeStore::Backends::RocksDB.new("/var/lib/rippled/rocksdb/")
  }

  it_provides "database access"
  #it_provides "database iterator access"
  #it_provides "a database parser"
end
