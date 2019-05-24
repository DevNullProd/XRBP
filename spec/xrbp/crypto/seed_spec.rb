describe XRBP::Crypto do
  it "generates valid seed" do
    seed = described_class.seed
    expect(described_class.seed?(seed[:seed])).to be(true)
  end
end
