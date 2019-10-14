shared_examples "a database parser" do |opts={}|
  let(:ledger_key) { ["516F940640172099A89F9733B8E69F2A56720E67C53EE7E0F3022BB6E55E6986"].pack("H*") }
  let(:ledger) { {"nt_ledger"=>1, "hp_ledger_master"=>"4c575200", "index"=>47508432, "total_coins"=>18248035087498961665, "parent_hash"=>"C4FAD6EB19F6A6089E7AEBC73AF596DB471305BC0EBB99D9D1414BD4DB8C9D43", "tx_hash"=>"934A5E57C598F0505664F9349DA87FD32AFBE1C315A2CB6CFB5B690AECC6B1A3", "account_hash"=>"FEA269DAAA66C820978AC95F0399ECACA7A3ABAC91402C9FC7961A53D053332F", "parent_close_time"=>Time.parse("2019-05-25T20:12:20Z").utc, "close_time"=>Time.parse("2019-05-25T20:12:21Z").utc, "close_time_resolution"=>10, "close_flags"=>0} }

  let(:tx_key) { ["003b960d5e30ff91a91f7c900509a99a8a6b89441b76158e5ed295ad1d27b0e7"].pack("H*") }
  let(:tx) { {:node=>{:transaction_type=>:payment, :flags=>2147942400, :sequence=>3366484, :last_ledger_sequence=>47713577, :amount=>XRBP::NodeStore::STAmount.new(:mantissa => 1000000000000000, :exponent => 86, :issue => XRBP::NodeStore::Issue.new("XCN", "rPFLkxQk6xUGdGYEykqe7PR25Gr7mLHDc8")), :fee=>XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore.xrp_issue, :mantissa => 11), :send_max=>XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore.xrp_issue, :mantissa => 10000000000), :signing_pub_key=>"030ac4f2ba6e1ff86beb234b639918dafdf0675032ae264d2b39641503822373fe", :txn_signature=>"304402207ac9c62a6e8a876e67945edebcd3f6c71c36c95fbbb0ce05a85871d0794b1b8c0220297fe7195beb083a78ff9de4d822b5e4cb42be7e5a8662bcbc2f42c737e264bf", :account=>"rKLpjpCoXgLQQYQyj13zgay73rsgmzNH13", :destination=>"rKLpjpCoXgLQQYQyj13zgay73rsgmzNH13", :paths=>[[{:currency=>"CNY", :issuer=>"rKiCet8SdvWxPXnAgYarFUXMh1zCPz432Y"}, {:currency=>"USD", :issuer=>"rhub8VRN55s94qWKDv6jmDy1pUykJzF3wq"}, {:currency=>"\x00\x00\x00"}, {:currency=>"XCN", :issuer=>"rPFLkxQk6xUGdGYEykqe7PR25Gr7mLHDc8"}], [{:currency=>"USD", :issuer=>"rhub8VRN55s94qWKDv6jmDy1pUykJzF3wq"}, {:currency=>"CNY", :issuer=>"rKiCet8SdvWxPXnAgYarFUXMh1zCPz432Y"}, {:currency=>"\x00\x00\x00"}, {:currency=>"XCN", :issuer=>"rPFLkxQk6xUGdGYEykqe7PR25Gr7mLHDc8"}], [{:currency=>"CNY", :issuer=>"rKiCet8SdvWxPXnAgYarFUXMh1zCPz432Y"}, {:currency=>"CNY", :issuer=>"razqQKzJRdB4UxFPWf5NEpEG3WMkmwgcXA"}, {:currency=>"\x00\x00\x00"}, {:currency=>"XCN", :issuer=>"rPFLkxQk6xUGdGYEykqe7PR25Gr7mLHDc8"}], [{:currency=>"CNY", :issuer=>"razqQKzJRdB4UxFPWf5NEpEG3WMkmwgcXA"}, {:currency=>"CNY", :issuer=>"rKiCet8SdvWxPXnAgYarFUXMh1zCPz432Y"}, {:currency=>"\x00\x00\x00"}, {:currency=>"XCN", :issuer=>"rPFLkxQk6xUGdGYEykqe7PR25Gr7mLHDc8"}], [{:currency=>"CNY", :issuer=>"rKiCet8SdvWxPXnAgYarFUXMh1zCPz432Y"}, {:currency=>"EUR", :issuer=>"rhub8VRN55s94qWKDv6jmDy1pUykJzF3wq"}, {:currency=>"\x00\x00\x00"}, {:currency=>"XCN", :issuer=>"rPFLkxQk6xUGdGYEykqe7PR25Gr7mLHDc8"}], [{:currency=>"EUR", :issuer=>"rhub8VRN55s94qWKDv6jmDy1pUykJzF3wq"}, {:currency=>"CNY", :issuer=>"rKiCet8SdvWxPXnAgYarFUXMh1zCPz432Y"}, {:currency=>"\x00\x00\x00"}, {:currency=>"XCN", :issuer=>"rPFLkxQk6xUGdGYEykqe7PR25Gr7mLHDc8"}]]}, :meta=>{:transaction_index=>30, :affected_nodes=>[{:ledger_entry_type=>:account_root, :previous_txn_lgr_seq=>47713575, :previous_txn_id=>"2e397e516ccde852e829d36eb7d0d195dd9a974a188e213ad256c3ae3c131e58", :ledger_index=>"792ba4e4659c27cf3b63f96b34f158748b081cf532f6746a1e3ebd07acba1a0e", :previous_fields=>{:sequence=>3366484, :balance=>XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore.xrp_issue, :mantissa => 1920887273)}, :final_fields=>{:flags=>0, :sequence=>3366485, :owner_count=>5, :balance=>XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore.xrp_issue, :mantissa => 1920887262), :account=>"rKLpjpCoXgLQQYQyj13zgay73rsgmzNH13"}}], :transaction_result=>128}, :index=>"5C28E293E88CCEEFBBAB3EF58C1F8C1C02A5194F42A42349597DDCBC86BFEB0D"} }

  let(:ledger_entry_key) { ["002989b414eff398027fce4045f643d68aca440aeea11518a950550ca02c18dd"].pack("H*") }
  let(:ledger_entry) { {:type=>:account_root, :index=>"9A34C6D1C46168ECE90EB867C78AB2BECE80FAF5D86D09082017E2C89BD68E56", :fields=>{:flags=>0, :sequence=>2, :previous_txn_lgr_seq=>45017187, :owner_count=>0, :previous_txn_id=>"3133839f2401cc9a719778f53319486d11e7ad7ec7891ac083e2aa7eb924516a", :balance=>XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore.xrp_issue, :mantissa => 20000000), :account=>"r4HW4bomLvvzA22dACJwUq95ZRr8ZAcXXs"}} }

  let(:inner_node_key) { ["001b46daaea7a40d9dcdc30f83918db8c8f9110c22e1207bcd8f9145dbe032dd"].pack("H*") }
  # XXX - see: https://github.com/ripple/rippled/issues/2960
  let(:inner_node_type) { described_class == XRBP::NodeStore::Backends::NuDB ? :unknown : :account_node }
  let(:inner_node) { {"node_type"=>inner_node_type, "hp_inner_node"=>"4d494e00", "child0"=>"0000000000000000000000000000000000000000000000000000000000000000", "child1"=>"0000000000000000000000000000000000000000000000000000000000000000", "child2"=>"0000000000000000000000000000000000000000000000000000000000000000", "child3"=>"0000000000000000000000000000000000000000000000000000000000000000", "child4"=>"0000000000000000000000000000000000000000000000000000000000000000", "child5"=>"0000000000000000000000000000000000000000000000000000000000000000", "child6"=>"0000000000000000000000000000000000000000000000000000000000000000", "child7"=>"0000000000000000000000000000000000000000000000000000000000000000", "child8"=>"0000000000000000000000000000000000000000000000000000000000000000", "child9"=>"0000000000000000000000000000000000000000000000000000000000000000", "child10"=>"0000000000000000000000000000000000000000000000000000000000000000", "child11"=>"0000000000000000000000000000000000000000000000000000000000000000", "child12"=>"0000000000000000000000000000000000000000000000000000000000000000", "child13"=>"0000000000000000000000000000000000000000000000000000000000000000", "child14"=>"0000000000000000000000000000000000000000000000000000000000000000", "child15"=>"666a34c47ed2890eab999536b6c0f728b3b2d616080bd38837f7c9f509b55204", "child16"=>"", "child17"=>"", "child18"=>"", "child19"=>"", "child20"=>"", "child21"=>"", "child22"=>"", "child23"=>"", "child24"=>"", "child25"=>"", "child26"=>"", "child27"=>"", "child28"=>"", "child29"=>"", "child30"=>"", "child31"=>""} }

  it "returns ledger" do
    actual = db.ledger(ledger_key)
    expect(actual).to eq(ledger)
  end

  it "returns transaction" do
    actual = db.tx(tx_key)
    expect(actual).to eq(tx)
  end

  # TODO test other transaction types

  it "returns ledger entry" do
    actual = db.ledger_entry(ledger_entry_key)
    expect(actual).to eq(ledger_entry)
  end

  ## TODO test other ledger entry types

  it "returns inner node" do
    actual = db.inner_node(inner_node_key)
    expect(actual).to eq(inner_node)
  end
end
