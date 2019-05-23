describe XRBP::Crypto do
  it "generates valid node" do
    node = described_class.node
    expect(described_class.node?(node[:node])).to be(true)
  end
end
