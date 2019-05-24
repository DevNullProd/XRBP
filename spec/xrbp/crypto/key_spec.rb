describe XRBP::Crypto::Key do
  it "generates valid sec256k1 key"
  it "generates valid ed25519 key"

  it "generates signs and verifies digest" do
    key = described_class.secp256k1
    dat = "ABCDEFGHIJLMNOPQRSTUVWYZ12345678"
    signed = XRBP::Crypto::Key.sign_digest(key, dat)
    expect(XRBP::Crypto::Key.verify(key, signed, dat))
  end
end
