describe XRBP::NodeStore::Indexes do
  it "returns quality for base" do
    base = 57159940697819848473151736347809673846048755675063285491534159019684120657920.byte_string
    described_class.get_quality(base).should eq(6197953087261802496)
  end

  it "returns next quality for base" do
    base = 57159940697819848473151736347809673846048755675063285491534159019684120657920.byte_string
     nxt = 57159940697819848473151736347809673846048755675063285491552605763757830209536
    described_class.get_quality_next(base).to_bn.should eq(nxt)
  end

  it "returns directory node index"

  it "returns page index"

  it "returns account index" do
    account = "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B"
    described_class.account(account).to_bn.should eq(83149858826312963445632044328430706857892442949720032032422519427184563347763)
  end

  context "account > issuer" do
    it "returns trust line index" do
      account = "rnixnrMHHvR7ejMpJMRCWkaNrq3qREwMDu"
          iou = {:currency=>"EUR", :account=>"rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B"}
      described_class.line(account, iou).to_bn.should eq(45370088078399581796930875479259405419767996706903582207576813674682296859050)
    end
  end

  context "account < issuer" do
    it "returns trust line index" do
      account = "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B"
          iou = {:currency=>"EUR", :account=>"rnixnrMHHvR7ejMpJMRCWkaNrq3qREwMDu"}
      described_class.line(account, iou).to_bn.should eq(45370088078399581796930875479259405419767996706903582207576813674682296859050)
    end
  end

  it "returns order book index" do
     input = {:currency=>"USD", :account=>"rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B"}
    output = {:currency=>"EUR", :account=>"rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B"}
    described_class.order_book(input, output).to_bn.should eq(57159940697819848473151736347809673846048755675063285491527961066596858855424)
  end
end
