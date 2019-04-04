require_relative '../../helpers/test_handshake'
require_relative '../../helpers/force_serializable'

describe XRBP::WebClient::Connection do
  subject { described_class.new 'wss://s1.ripple.com:443' }
  # let(:connection) { XRBP::WebClient::Connection.new 'wss://s1.ripple.com:443' }
  describe '#plugin_namespace' do
    it 'should returned WebClient object' do
      expect(subject.plugin_namespace).to eq(XRBP::WebClient)
    end
  end

  describe '#parsing_plugins' do
    it 'should returned plugins' do

    end
  end

  describe '#url' do
    it 'should returned initializeed url' do
      expect(subject.url).to eq('wss://s1.ripple.com:443')
    end
  end

  describe '#force_quit?' do
    it { expect(subject.force_quit?).to eq(false) }
  end

  describe 'when force_quit!' do
    before {subject.force_quit!}
    it { expect(subject.force_quit?).to eq(true)}
    it 'should wake_all threads' do

    end
  end

  describe '#handle_error' do

  end

  describe '#perform' do

  end
end
