describe XRBP::SHAMap::InnerNode do
  context "no branches" do
    it "is empty"

    it "always returns true empty_branch?"

    it "always returns nil child hash"

    it "always returns nil child"
  end

  context "child branches" do
    before(:each) do
    end

    it "is not empty"

    context "querying for non-empty child" do
      it "returns false empty_branch?"

      it "it returns child hash"

      it "returns child"
    end

    context "querying for empty child" do
      it "returns true empty_branch?"

      it "returns nil child hash"

      it "returns nil child"
    end

    context "querying for invalid branch" do
      it "always return true empty_child?"

      it "raises error when retrieving child hash"

      it "raises error when retrieving child"
    end
  end

  it "updates hash"
end # describe XRBP::SHAMap::InnerNode
