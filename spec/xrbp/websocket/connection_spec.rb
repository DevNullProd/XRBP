describe XRBP::WebSocket::Connection do
  subject { XRBP::WebSocket::Connection.new 'wss://test.com:443' }
  let(:client){ subject.client }

  it 'is not initialized' do
    expect(subject).to_not be_initialized
  end

  it 'is not open' do
    expect(subject).to_not be_open
  end

  it 'is closed' do
    expect(subject).to be_closed
  end

  it 'is completed' do
    expect(subject).to be_completed
  end

  context "client exists" do
    before(:each) do
      subject.client
    end

    it "is initialized" do
      expect(subject).to be_initialized
    end
  end

  context "client is open" do
    before(:each) do
      expect(client).to receive(:open?).and_return true
    end

    it "is open" do
      expect(subject).to be_open
    end

    it "is not closed" do
      expect(subject).to_not be_closed
    end
  end

  context "client is not completed" do
    before(:each) do
      expect(client).to receive(:completed?).and_return false
    end

    it "is not completed" do
      expect(subject).to_not be_completed
    end
  end

  describe "#connect" do
    it "connects to client" do
      expect(client).to receive(:connect)
      subject.connect
    end
  end

  describe "#close!" do
    it "closes client" do
      expect(client).to receive(:open?).and_return true
      expect(client).to receive(:close)
      subject.close!
    end
  end

  describe "#close!" do
    it "async closes client" do
      expect(client).to receive(:open?).and_return true
      expect(client).to receive(:async_close)
      subject.async_close!
    end
  end

  describe "#send_data" do
    it "sends data via client" do
      expect(client).to receive(:send_data).with("foo")
      subject.send_data("foo")
    end
  end

  describe "#add_work" do
    it "adds work to client pool" do
      expect(client).to receive(:add_work)
      subject.add_work do
      end
    end
  end

  describe "#next_connection" do
    context "no parent" do
      it "returns nil" do
        expect(subject.next_connection(nil)).to be_nil
      end
    end

    it "returns parent's next connection" do
      parent = double
      expect(parent).to receive(:next_connection).with(:foo).and_return :bar

      subject.parent = parent
      expect(subject.next_connection(:foo)).to eq(:bar)
    end
  end
end
