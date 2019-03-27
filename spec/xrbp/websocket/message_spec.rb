# frozen_string_literal: true

describe XRBP::WebSocket::Message do
  subject { described_class.new 'Test message' }
  let(:connection) { XRBP::WebSocket::Connection.new "*" }

  it 'returns message text' do
    expect(subject.to_s).to eq 'Test message'
  end

  it 'waits for signal' do
    expect(subject.signal).to be(subject)
  end

  it 'waits for connection close' do
    expect(connection).to receive(:closed?).and_return true
    subject.connection = connection
    expect(subject.wait).to be_nil
  end

  it 'returns proc which waites for signal' do
    expect(subject.bl.call).to be(subject)
  end
end
