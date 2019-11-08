describe XRBP::NodeStore::STAmount do
  it "is negatable"

  it "is convertable to/from wire format" do
    v = 1000000000000
    s = described_class.new(:mantissa => v)
    expect(described_class.from_wire(s.to_wire).to_h).to eq(s.to_h)

    s = described_class.new(:mantissa => v,
                               :issue => XRBP::NodeStore.xrp_issue)
    expect(described_class.from_wire(s.to_wire).to_h).to eq(s.to_h)
  end

  it "can be parsed from string" do
    s = "12345.6789"
    expect(described_class.parse(s).iou_amount.to_f).to eq(s.to_f)

    expect { described_class.parse("whatever") }.to raise_error("Number 'whatever' is not valid")
  end

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
