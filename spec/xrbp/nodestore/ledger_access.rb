shared_examples "ledger access" do |opts={}|
  let(:ledger_hash) { ["32E073D7E4D722D956F7FDE095F756FBB86DC9CA487EB0D9ABF5151A8D88F912"].pack("H*") }
  let(:ledger) { XRBP::NodeStore::Ledger.new(:db => db, :hash => ledger_hash) }

  let(:issuer) { 'rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B' }
  let(:iou1) { {:currency => 'USD', :account => issuer} }
  let(:iou2) { {:currency => 'EUR', :account => issuer} }

  let(:order1) { {
    :ledger_entry_type=>:offer,
    :flags=>131072,
    :sequence=>219,
    :previous_txn_lgr_seq=>47926685,
    :book_node=>0,
    :owner_node=>0,
    :previous_txn_id=>"e43add1bd4ac2049e0d9de6bc279b7fd95a99c8de2c4694a4a7623f6d9aaae29",
    :book_directory=>"7e5f614417c2d0a7cefeb73c4aa773ed5b078de2b5771f6d56038d7ea4c68000",
    :taker_pays=>XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore::Issue.new("USD", "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B"), :mantissa => 2459108753792364, :exponent => -14),
    :taker_gets => XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore::Issue.new("EUR", "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B"), :mantissa => 2459108753792364, :exponent => -15),
    :account=>"rnixnrMHHvR7ejMpJMRCWkaNrq3qREwMDu",
    :owner_funds => XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore::Issue.new("EUR", XRBP::Crypto.no_account), :mantissa => 2872409153061363, :exponent => -15),
    :quality => XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore.no_issue, :mantissa => 1000000000000000, :exponent => -14),
  } }

  let(:order2) { {
    :ledger_entry_type=>:offer,
    :flags=>131072,
    :sequence=>19,
    :previous_txn_lgr_seq=>43166305,
    :book_node=>0,
    :owner_node=>0,
    :previous_txn_id=>"b63b2ecd124fe6b02bc2998929517266bd221a02fee51dde4992c1bcb7e86cd3",
    :book_directory=>"7e5f614417c2d0a7cefeb73c4aa773ed5b078de2b5771f6d56038d7ea4c68000",
    :taker_pays=>XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore::Issue.new("USD", "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B"), :mantissa => 3520000000000000, :exponent => -14),
    :taker_pays_funded=>XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore::Issue.new("USD", "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B"), :mantissa => 3516160294182094, :exponent => -14),
    :taker_gets => XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore::Issue.new("EUR", "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B"), :mantissa => 3520000000000000, :exponent => -15), :account=>"rKwjWCKBaASEvtHCxtvReNd2i9n8DxSihk",
    :taker_gets_funded => XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore::Issue.new("EUR", XRBP::Crypto.no_account), :mantissa => 3516160294182094, :exponent => -15), :account=>"rKwjWCKBaASEvtHCxtvReNd2i9n8DxSihk",
    :owner_funds => XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore::Issue.new("EUR", XRBP::Crypto.no_account), :mantissa => 3523192614770459, :exponent => -15),
    :quality => XRBP::NodeStore::STAmount.new(:issue => XRBP::NodeStore.no_issue, :mantissa => 1000000000000000, :exponent => -14),
  } }

  let(:order_book) { [order1, order2] }

  it "provides access to ledger state map"

  it "provides access to ledger tx map"

  it "provides access to ledger info"

  describe "#global_frozen?" do
    context "account globally frozen in ledger" do
      it "returns true"
    end

    context "account not globally frozen in ledger" do
      it "returns false"
    end
  end

  describe "#frozen?" do
    context "account trust line frozen" do
      it "returns true"
    end

    context "account trust line not frozen" do
      it "returns false"
    end
  end

  describe "#account_holds" do
    it "returns balance of account iou trust line"

    context "currency == 'XRP'" do
      it "returns liquid xrp"
    end
  end

  describe "#xrp_liquid" do
    context "account not found" do
      it "returns zero amount minus reserve"
    end

    it "returns xrp account balance minus reserve"

    context "fix1141 in effect" do
      it "confines owner account"
    end
  end

  describe "#confine_owner_account" do
    it "adjusts and returns amount"
  end

  describe "#transfer_rate" do
    it "returns transfer rate for specified issuer"
  end

  it "provides access to order book" do
    actual = ledger.order_book(iou1, iou2)
    expect(actual).to eq(order_book)
  end
end
