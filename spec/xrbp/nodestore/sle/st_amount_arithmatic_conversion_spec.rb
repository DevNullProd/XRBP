describe XRBP::NodeStore::STAmount do
  it "is negatable"

  context "canonicalize" do
    context "native amount" do
      context "zero mantissa" do
        it "zeros exponent"
        it "is not negative"
      end

      it "zeros exponent"
    end

    context "zero mantissa" do
      it "sets exponent to -100"
      it "is not negative"
    end

    it "increases mantissa to >= MIN_VAL"
    it "increases mantissa to <= MAX_VAL"

    it "increases exponent to >= MIN_OFFSET"
    it "descreases exponent to <= MAX_OFFSET"

    context "offset cannot be set appropriately" do
      it "raises value overflow"
    end

    context "manitssa out of bounds" do
      it "raises error"
    end

    context "exponent out of bounds" do
      it "raises error"
    end

    context "invalid mantissa / exponent combination" do
      it "raises error"
    end
  end # describe #canoncialize

  it "clears amount"

  it "returns sn_value"
  it "returns xrp_amount"
  it "returns iou_amount"
end # describe XRBP::NodeStore::STAmount
