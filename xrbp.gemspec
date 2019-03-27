lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xrbp/version'

Gem::Specification.new do |spec|
  spec.name          = "xrbp"
  spec.version       = XRBP::VERSION
  spec.authors       = ["Dev Null Productions"]
  spec.email         = ["devnullproductions@gmail.com"]
  spec.description   = %q{Ruby XRP Tools}
  spec.summary       = %q{Helper module to read and write data from the XRP Ledger and related resources!}
  spec.homepage      = "https://github.com/DevNullProd/XRBP"
  spec.license       = "MIT"

  spec.files         = Dir.glob("examples/**/*.rb") +
                       Dir.glob("lib/**/*.rb")      +
                       Dir.glob("spec/**/*.rb")     +
                       ["README.md", "LICENSE.txt", ".yardopts"]

  spec.require_paths = ["lib"]

  spec.add_dependency "json", '~> 2.1'
  spec.add_dependency "event_emitter", '~> 0.2'
  spec.add_dependency "concurrent-ruby", '~> 1.0'

  # for websocket module
  spec.add_dependency "websocket", '~> 1.2'

  # for webclient module
  # TODO remove this dep, fallback to net-http if curb isn't avaiable
  spec.add_dependency 'curb', '~> 0.9'

  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'camcorder', '~> 0.0.5'
end
