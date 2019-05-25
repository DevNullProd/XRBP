shared_examples "a database parser" do |opts={}|
  let(:key) { ["516F940640172099A89F9733B8E69F2A56720E67C53EE7E0F3022BB6E55E6986"].pack("H*") }
  let(:ledger) { {"nt_ledger"=>1, "hp_ledger_master"=>"4c575200", "index"=>47508432, "total_coins"=>18248035087498961665, "parent_hash"=>"C4FAD6EB19F6A6089E7AEBC73AF596DB471305BC0EBB99D9D1414BD4DB8C9D43", "tx_hash"=>"934A5E57C598F0505664F9349DA87FD32AFBE1C315A2CB6CFB5B690AECC6B1A3", "account_hash"=>"FEA269DAAA66C820978AC95F0399ECACA7A3ABAC91402C9FC7961A53D053332F", "parent_close_time"=>Time.parse("2019-05-25T20:12:20Z").utc, "close_time"=>Time.parse("2019-05-25T20:12:21Z").utc, "close_time_resolution"=>10, "close_flags"=>0} }

  it "returns ledger" do
    actual = db.ledger(key)
    expect(actual).to eq(ledger)
  end
end
