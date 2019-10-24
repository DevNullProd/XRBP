describe XRBP::SHAMap::Node do
  it "is not a tree_node?" do
    expect(described_class.new).to_not be_a_tree_node
  end

  it "is not an inner?" do
    expect(described_class.new).to_not be_an_inner
  end

  it "does not allow hash to be updated" do
    expect { described_class.new.update_hash }.to raise_error("abstract: must be called on a subclass")
  end

  context "leaf type" do
    it "is a leaf?" do
      expect(described_class.new(:type => :transaction_nm)).to be_a_leaf
    end
  end

  context "non leaf type" do
    it "is not a leaf?" do
      expect(described_class.new(:type => :infer)).to_not be_a_leaf
    end
  end
end # describe XRBP::SHAMap::Node
