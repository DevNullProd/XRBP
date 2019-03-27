# frozen_string_literal: true

describe XRBP::WebSocket::Message do
  subject { described_class.new 'Test message' }
  let(:connection) { XRBP::WebSocket::Connection.new "*" }

  before(:each) do
    subject.connection = connection
  end

  it 'returns message text' do
    expect(subject.to_s).to eq 'Test message'
  end

  it 'waits for signal' do
    Thread.new {
      sleep(0.1)
      subject.signal
    }
    subject.wait
  end

  it 'waits for connection close' do
    expect(connection).to receive(:closed?).and_return true
    expect(subject.wait).to be_nil
  end

  describe "#bl" do
    it 'defaults to callback which signals wait condition' do
      Thread.new {
        sleep(0.1)
        subject.bl.call
      }
      subject.wait
    end
  end
end
