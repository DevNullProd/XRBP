describe XRBP::SHAMap do
  describe "#each" do
    it "iterates over all SHAMap items"
  end

  describe "#succ" do
    it "returns next key in tree greater than specified one"

    context "next item is map end" do
      it "returns nil"
    end

    context "next item is >= last" do
      it "returns nil"
    end
  end

  describe "#read" do
    it "returns SLE read from database"

    context "specified key is zero" do
      it "raises error"
    end

    context "not found" do
      it "returns nil"
    end
  end

  describe "#peek_item" do
    it "returns item corresponding to database key"

    context "item not found" do
      it "returns nil"
    end
  end

  describe "#peek_first_item" do
    it "returns first item below root and stack"

    context "no item" do
      it "returns nil"
    end
  end

  describe "#peek_next_item" do
    it "returns next item in map"

    context "specified stack is empty" do
      it "raises error"
    end

    context "top of stack is not leaf" do
      it "raises error"
    end
  end

  describe "#fetch_node" do
    it "retrieves node from db"

    context "node not found" do
      it "raises error"
    end
  end

  describe "#fetch_node_nt" do
    it "retrieves node from db"

    context "node not found" do
      it "does not raise error"
    end
  end

  describe "#fetch_root" do
    it "sets @root database node and returns true"

    context "root already set" do
      it "returns true"
    end

    context "node not found" do
      it "returns false"
    end
  end

  describe "#find_key" do
    it "finds node corresponding to key in map"

    context "key not found" do
      it "returns nil"
    end
  end

  describe "#fetch_node_from_db" do
    it "retrieves key from nodestore"
    it "creates corresponding node"
  end

  describe "#upper_bound" do
    it "returns first item in tree with key > given key"
  end

  describe "#walk_towards_key" do
    it "returns path stack of node traversal to key"
  end

  describe "#descend_throw" do
    it "descends to parent branch"

    context "could not descend to non-empty branch" do
      it "raises error"
    end
  end

  describe "#descend" do
    it "retrieve cached child node at parent branch"

    context "parent branch child node not set" do
      it "fetches and returns node"

      context "not not able to be retrieved" do
        it "returns nil"
      end

      context "node is inconsistent" do
        it "returns nil"
      end

      it "stores child in parent"
    end
  end

  describe "#first_below" do
    it "returns first leaf node at or below the specified node"
  end

  describe "#cdir_first" do
    it "returns the first directory index in the node specified by index"
  end

  describe "#cdir_next" do
    it "returns the next directory index in the node specified by index"
  end
end # describe XRBP::SHAMap
