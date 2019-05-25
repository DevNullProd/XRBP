describe XRBP::Crypto do
  let(:node) { "n9Kgda1F7evck24hJUqFsn8m6pNERJd6UkjwLuNBSUJ6Ykm76NdJ" }
  let(:expected) { [0x2, 0x96, 0x24, 0xe4, 0x37, 0x80, 0xeb, 0xcc, 0xf2, 0x77, 0x67, 0x48, 0x4d, 0x42, 0xc5, 0x54, 0xbe, 0x7b, 0xaa, 0x28, 0x78, 0x82, 0x7e, 0x91, 0x2f, 0x4e, 0x66, 0x94, 0xbf, 0x64, 0xa4, 0x55, 0x80].pack("C*") }

  it "generates valid node" do
    node = described_class.node
    expect(described_class.node?(node[:node])).to be(true)
  end

  it "parses node" do
    n = described_class.parse_node(node)
    expect(n).to_not be_nil
    expect(n).to eq(expected)
  end

  it "does not parse invalid node" do
    expect(described_class.parse_node("invalid")).to be_nil
  end

  it "verifies node" do
    expect(described_class.node?(node)).to be(true)
    expect(described_class.node?("invalid")).to be(false)
  end
end
