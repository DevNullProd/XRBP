#describe XRBP::WebSocket::Plugins::CommandDispatcher do
#  let(:connection) {
#    XRBP::WebSocket::Connection.new "wss://s1.ripple.com:443" do |c|
#      c.add_plugin :command_dispatcher
#    end
#  }
#
#  before(:each) do
#    #connection.client.stub_handshake!
#    connection.client.force_serializable!
#    Camcorder.intercept_constructor XRBP::WebSocket::Socket
#
#    # XXX fix random 
#    allow(SecureRandom).to receive(:random_bytes).with(4).and_return('1234')
#  end
#
#  after(:each) do
#    Camcorder.deintercept_constructor XRBP::WebSocket::Socket
#  end
#
#  it "sends command and returns response" do
#    connection.connect
#    puts connection.cmd XRBP::WebSocket::Cmds::ServerInfo.new
#  end
#end
