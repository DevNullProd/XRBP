describe XRBP::NodeStore::STAmount do
  it "provides access to #zero amount"

  it "returns amount from quality"

  context "quality rate = 0" do
    it "returns default STAmount"
  end

  describe "default STAmount" do
    describe "issue" do
      it "is nil"
    end

    describe "mantissa" do
      it "is zero"
    end

    describe "exponent" do
      it "is zero"
    end

    it "is not negative"
  end

  it "canonicalizes data"

  describe "#native?" do
    context "native issuer" do
      it "returns true"
    end

    context "non native issuer" do
      it "returns false"
    end
  end

  describe "zero?" do
    context "mantissa is zero" do
      it "returns true"
    end

    context "mantissa is not zero" do
      it "returns false"
    end
  end
end # describe XRBP::NodeStore::STAmount
