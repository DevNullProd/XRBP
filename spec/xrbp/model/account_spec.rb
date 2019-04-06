require_relative '../../helpers/test_handshake'
require_relative '../../helpers/force_serializable'

describe XRBP::Model::Account do
  subject { described_class.new 'rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B' }

  describe '#latest' do
    let(:connection) { XRBP::WebClient::Connection.new }
    it 'should be returned latest account' do
      last_item = XRBP::Model::Account.latest(connection: connection)
      Signal.trap('INT') {
        connection.force_quit!
      }
      expect(last_item).not_to eq(nil)
      expect(described_class.latest(connection: connection)).to eq(last_item)
    end
  end

  describe '#info' do

  end

  describe '#objects' do

  end

  describe '#username' do

  end
end
