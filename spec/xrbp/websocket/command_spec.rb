describe XRBP::WebSocket::Command do
  subject { described_class.new(command: 'test') }

  it 'returns command being requested' do
    expect(subject.requesting).to eq 'test'
  end

  it 'returns bool indicating if we are request command' do
    expect(subject).to be_requesting('test')
  end
end
