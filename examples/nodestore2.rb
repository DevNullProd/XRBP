$: << File.expand_path('../../lib', __FILE__)
require 'xrbp'
require 'xrbp/nodestore/backends/rocksdb'

db = XRBP::NodeStore::Backends::RocksDB.new "/var/lib/rippled/rocksdb/rippledb.0899"

db.on :unknown do |hash, node|
  puts "Unknown #{hash}: #{node}"
end

db.on :inner_node do |hash, node|
  #puts "Inner Node #{hash}"
end

db.on :ledger do |hash, ledger|
  puts "Ledger #{ledger['index']}"
end

db.on :tx do |hash, tx|
  #puts "Tx #{hash} #{tx}"
end

db.on :account do |hash, account|
  #puts "Account #{hash} #{account}"
end

###

tallys = {}

# object iterator invokes event emitters
db.each do |node|
          obj = XRBP::NodeStore::Format::TYPE_INFER.decode(node.value)
    node_type = XRBP::NodeStore::Format::NODE_TYPES[obj["node_type"]]
  hash_prefix = XRBP::NodeStore::Format::HASH_PREFIXES[obj["hash_prefix"].upcase]

  type = node_type.to_s + "/" + hash_prefix.to_s
  tallys[type] ||= 0
  tallys[type]  += 1
end

puts tallys
