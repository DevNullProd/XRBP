describe XRBP::NodeStore::Amendments do
  describe "#fix1141?" do
    context "specified time is > fix1141_time" do
      it "returns true"
    end

    context "specified time is <= fix1141_time" do
      it "returns false"
    end
  end
end
