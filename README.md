### XRBP - Ruby XRP Library

<p align="center">
  <img src="https://raw.githubusercontent.com/devnullprod/xrbp/master/logo.png" />
</p>


XRBP is a rubygem which provides a fault-tolerant interface to the [XRP](https://en.wikipedia.org/wiki/XRP) ledger.

With XRP you can connect to one or more [rippled](https://github.com/ripple/rippled) servers and use them to transparently read and write data to/from the XRP Ledger:

```ruby
require 'xrbp'

ws = XRBP::WebSocket::Connection.new "wss://s1.ripple.com:443"
ws.add_plugin :autoconnect, :command_dispatcher

ws.cmd XRBP::WebSocket::Cmds::ServerInfo.new
```

XRBP provides fully-object-oriented mechanisms to interact with the ledger:

```ruby
ws.on :ledger do |l|
  puts "Ledger received: "
  puts l
end

XRBP::Model::Ledger.subscribe(:connection => ws)
```

#### Supported Features:

Other data types besides ledgers may be syncronized:

```ruby
puts XRBP::Model::Account.new("rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B").info
```

Also data from other sources, such as the [Ripple DataV2 API](https://developers.ripple.com/data-api.html)

```ruby
connection = XRBP::WebClient::Connection.new
XRBP::Model::Validator.all(:connection => connection)
                      .each do |v|
  puts v
end
```

XRPB allows easy access to the following data:

- XRP ledgers, transactions, account, and objects
- Network nodes, validators, gateways
- Markets with quotes
- & more (see *examples/* for more use cases)

#### Multiple Connections

XRBP facilitates fault-tolerant applications by providing customizable strategies which to leverage multiple rippled servers in communications.

```ruby
ws = XRBP::WebSocket::RoundRobin.new "wss://s1.ripple.com:443",
                                     "wss://s2.ripple.com:443"

ws.add_plugin :command_dispatcher
ws.connect

puts ws.cmd(XRBP::WebSocket::Cmds::ServerInfo.new)
puts ws.cmd(XRBP::WebSocket::Cmds::ServerInfo.new)
```

In this case the first **ServerInfo** command will be sent to *s1.ripple.com* while the second will be sent to *s2.ripple.com*.

The following demonstrates prioritized connections:

```ruby
ws = XRBP::WebSocket::Prioritized.new "wss://s1.ripple.com:443",
                                      "wss://s2.ripple.com:443"

ws.add_plugin :command_dispatcher, :result_parser
ws.parse_results { |res|
  res["result"]["ledger"]
}
ws.connect

puts ws.cmd(XRBP::WebSocket::Cmds::Ledger.new(28327070))
```

*s1.ripple.com* will be queried for the specified ledger. If not present *s2.ripple.com* will be queried.

#### Installation / Documentation

XRPB may be installed with the following command:

```ruby
$ gem install xrbp
```

Documentation is available [online](https://www.rubydoc.info/gems/xrbp)

#### License

Copyright (C) 2019 Dev Null Productions

Made available under the MIT License
