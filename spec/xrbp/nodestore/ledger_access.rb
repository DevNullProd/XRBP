shared_examples "ledger access" do |opts={}|
  let(:ledger_hash) { ["32E073D7E4D722D956F7FDE095F756FBB86DC9CA487EB0D9ABF5151A8D88F912"].pack("H*") }
  let(:ledger) { XRBP::NodeStore::Ledger.new(:db => db, :hash => ledger_hash) }

  let(:issuer) { 'rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B' }
  let(:iou1) { {:currency => 'USD', :account => issuer} }
  let(:iou2) { {:currency => 'EUR', :account => issuer} }

  let(:order1) { { :ledger_entry_type=>:offer, :flags=>131072, :sequence=>219, :previous_txn_lgr_seq=>47926685, :book_node=>0, :owner_node=>0, :previous_txn_id=>"e43add1bd4ac2049e0d9de6bc279b7fd95a99c8de2c4694a4a7623f6d9aaae29", :book_directory=>"7e5f614417c2d0a7cefeb73c4aa773ed5b078de2b5771f6d56038d7ea4c68000", :taker_pays=>XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore::Issue.new("USD", "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B"), :mantissa => 2459108753792364, :exponent => 83), :taker_gets => XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore::Issue.new("EUR", "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B"), :mantissa => 2459108753792364, :exponent => 82), :account=>"rnixnrMHHvR7ejMpJMRCWkaNrq3qREwMDu", :taker_gets_funded=> XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore::Issue.new("USD", "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B")), :taker_pays_funded => XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore::Issue.new("EUR", "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B")) } }
  let(:order2) { { :ledger_entry_type=>:offer, :flags=>131072, :sequence=>19, :previous_txn_lgr_seq=>43166305, :book_node=>0, :owner_node=>0, :previous_txn_id=>"b63b2ecd124fe6b02bc2998929517266bd221a02fee51dde4992c1bcb7e86cd3", :book_directory=>"7e5f614417c2d0a7cefeb73c4aa773ed5b078de2b5771f6d56038d7ea4c68000", :taker_pays=>XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore::Issue.new("USD", "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B"), :mantissa => 3520000000000000, :exponent => 83), :taker_gets => XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore::Issue.new("EUR", "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B"), :mantissa => 3520000000000000, :exponent => 82), :account=>"rKwjWCKBaASEvtHCxtvReNd2i9n8DxSihk", :taker_gets_funded=>XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore::Issue.new("USD", "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B")), :taker_pays_funded => XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore::Issue.new("EUR", "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B")) }  }
  let(:order_book) { [order1, order2] }

  it "provides access to order book" do
    actual = ledger.order_book(iou1, iou2)
    expect(actual).to eq(order_book)
  end
end
