require 'xrbp/nodestore/backends/nudb'

require_relative "./db_access"
#require_relative "./db_iterator_access"
#require_relative "./db_decompression"
require_relative "./db_parser"

describe XRBP::NodeStore::Backends::NuDB do
  before(:each) do
    Camcorder.intercept_constructor ::RuDB::Store
  end

  after(:each) do
    Camcorder.deintercept_constructor ::RuDB::Store
  end

  let(:db) {
    XRBP::NodeStore::Backends::NuDB.new("/var/lib/rippled/nudb")
  }

  it_provides "database access"
#  it_provides "database iterator access"
#  it_provides "database decompression"
  it_provides "a database parser"
end
