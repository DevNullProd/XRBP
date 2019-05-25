shared_examples "database access" do |opts={}|
  let(:key) { ["516F940640172099A89F9733B8E69F2A56720E67C53EE7E0F3022BB6E55E6986"].pack("H*") }
  let(:val) { "0000000000000000014c57520002d4ebd001633dd73a0b3efdc4fad6eb19f6a6089e7aebc73af596db471305bc0ebb99d9d1414bd4db8c9d43934a5e57c598f0505664f9349da87fd32afbe1c315a2cb6cfb5b690aecc6b1a3fea269daaa66c820978ac95f0399ecaca7a3abac91402c9fc7961a53d053332f247c5e24247c5e250a00" }

  it "returns values for key" do
    actual = db[key].unpack("H*").first
    expect(actual).to eq(val)
  end

  context "key not found" do
    it "returns nil" do
      expect(db["key"]).to be_nil
    end
  end
end
