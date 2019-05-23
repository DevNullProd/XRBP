describe XRBP::Crypto do
  it "generates valid account" do
    acct = described_class.account
    expect(described_class.account?(acct[:account])).to be(true)
  end
end
