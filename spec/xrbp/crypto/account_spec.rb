describe XRBP::Crypto do
  let(:account) { "rDbWJ9C7uExThZYAwV8m6LsZ5YSX3sa6US" }
  let(:account_id) { 788735140293854337814932116604999410196843811141 }
  let(:parsed) { [0x8a, 0x28, 0x1b, 0x5e, 0x46, 0xb0, 0x27, 0xc3, 0x70, 0x26, 0xe3, 0x8d, 0xbc, 0x5f, 0x9a, 0xa1, 0x4c, 0x37, 0x51, 0x45].pack("C*") }

  it "generates valid account" do
    acct = described_class.account
    expect(described_class.account?(acct[:account])).to be(true)
  end

  it "returns account id for account" do
    expect(described_class.account_id(account).to_bn).to eq(account_id)
  end

  it "parses account" do
    a = described_class.parse_account(account)
    expect(a).to_not be_nil
    expect(a).to eq(parsed)
  end

  it "does not parse invalid account" do
    expect(described_class.parse_account("invalid")).to be_nil
  end

  it "verifies account" do
    expect(described_class.account?(account)).to be(true)
    expect(described_class.account?("invalid")).to be(false)
  end
end
