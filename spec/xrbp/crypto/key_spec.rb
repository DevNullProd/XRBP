describe XRBP::Crypto::Key do
  it "generates valid sec256k1 key"
  it "generates valid ed25519 key"

  [:secp256k1, :ed25519].each { |key_type|

    let(:dat) { "ABCDEFGHIJLMNOPQRSTUVWYZ12345678" }

    it "generates signs and verifies #{key_type} digest" do
      key = described_class.send(key_type)
      signed = XRBP::Crypto::Key.sign_digest(key, dat)
      expect(XRBP::Crypto::Key.verify(key, signed, dat))
    end

    it "accepts #{key_type} seed" do
      seed = XRBP::Crypto.seed[:seed]
      key = described_class.send(key_type, seed)
      signed = XRBP::Crypto::Key.sign_digest(key, dat)
      expect(XRBP::Crypto::Key.verify(key, signed, dat))
    end
  }
end
