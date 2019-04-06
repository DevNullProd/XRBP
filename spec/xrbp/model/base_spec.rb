require_relative '../../helpers/test_handshake'
require_relative '../../helpers/force_serializable'

describe XRBP::Model::Base do
  let(:subject) {XRBP::Model::Account.new(id: 'rn1EBe15wNK5737xxw79PLJwNeEyipMiVH')}
  
  describe "#set_opts" do
    before {subject.set_opts(limit: 15)}
    it { expect(subject.full_opts).to eq({:id=>"rn1EBe15wNK5737xxw79PLJwNeEyipMiVH", :limit=>15})}
  end

  describe '#full_opts' do
    it { expect(subject.full_opts).to eq({id: 'rn1EBe15wNK5737xxw79PLJwNeEyipMiVH'})}
  end
end
