describe XRBP::NodeStore::Rate do
  it "is convertable to an amount" do
    rate = described_class.new 2000000000
    amount = rate.to_amount

    amount.issue.should be(XRBP::NodeStore.no_issue)
    amount.mantissa.should eq(2000000000000000)
    amount.exponent.should eq(-15)

    amount.iou_amount.should eq(2)
  end
end
