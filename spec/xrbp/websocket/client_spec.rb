require_relative '../../helpers/test_handshake'
require_relative '../../helpers/force_serializable'

describe XRBP::WebSocket::Client do
  subject { described_class.new "wss://s1.ripple.com:443" }
  let(:socket) { subject.send(:socket) }
  let(:pool)   { subject.send(:pool)   }

  before(:each) do
    subject.stub_handshake!
    subject.force_serializable!
    Camcorder.intercept_constructor XRBP::WebSocket::Socket
  end

  after(:each) do
    Camcorder.deintercept_constructor XRBP::WebSocket::Socket
  end

  describe '#connect' do
    after(:each) do
      pool.kill
      pool.wait_for_termination
    end

    it "connects to client" do
      # XXX we are recording socket, cannot add expections to it
      socket = double
      subject.instance_variable_set(:@socket, socket)
      expect(socket).to receive(:connect)
      expect(socket).to receive(:write)
      expect(socket).to receive(:read_next)

      subject.connect
    end

    it "performs handshake" do
      expect(subject).to receive(:handshake!)
      subject.connect
    end

    it "starts reading" do
      expect(subject).to receive(:start_read)
      subject.connect
    end

    it "is open" do
      subject.connect
      expect(subject).to be_open
    end

    context "connection error" do
      it "is closed"
    end

    context "handshake error" do
      it "is closed"
    end

    context "read error" do
      it "is closed"
    end
  end

  it 'is not opened' do
    expect(subject).to_not be_open
  end

  it 'is closed' do
    expect(subject).to be_closed
  end

  it 'is completed' do
    expect(subject).to be_completed
  end

  describe "#close" do
    it "closes connection" do
      subject.connect
      subject.close
      expect(subject).to be_closed
    end

    it "results in completed connection" do
      subject.connect
      subject.close
      expect(subject).to be_completed
    end
  end

  describe "#send_data" do
    let(:socket) { double }

    before(:each) do
      # XXX we are recording socket, cannot add expections to it
      subject.instance_variable_set(:@socket, socket)

      # XXX stub data_frame as it will contain random data
      expect(subject).to receive(:data_frame).with("foobar", :text).and_return "frame"

      # setup connection state
      expect(subject).to receive(:handshaked?).and_return true
      expect(subject).to receive(:closed?).and_return false
    end

    it "sends data" do
      expect(socket).to receive(:write_nonblock).with("frame")

      subject.send_data("foobar")
    end

    context "error is thrown" do
      it "closes the connection asynchronously" do
        expect(socket).to receive(:write_nonblock).and_raise Errno::EPIPE
        expect(subject).to receive(:async_close).with(Errno::EPIPE)

        subject.send_data("foobar")
      end
    end
  end
end
