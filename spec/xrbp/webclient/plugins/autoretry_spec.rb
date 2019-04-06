require_relative '../../../helpers/test_handshake'
require_relative '../../../helpers/force_serializable'

describe XRBP::WebClient::Plugins::AutoRetry do
  let(:connection) { XRBP::WebClient::Connection.new 'wss://s1.ripple.com:443' }
  subject { described_class.new connection }

  describe '#added' do

  end

  describe '#handle_error' do

  end
end
