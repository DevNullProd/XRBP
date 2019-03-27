describe XRBP::WebSocket::Command do
  context "command specified" do
    subject { described_class.new(command: 'test') } 

    it 'returns command' do
      expect(subject.requesting).to eq 'test'
    end

    it 'is requesting' do
      expect(subject).to be_requesting('test')
    end
  end
end
