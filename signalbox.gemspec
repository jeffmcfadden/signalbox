Gem::Specification.new do |spec|
  spec.name          = "signalbox"
  spec.version       = "0.1.0"
  spec.authors       = ["Jeff McFadden"]
  spec.email         = [""]

  spec.summary       = "DCC model railroad automation framework with sensor-driven control"
  spec.description   = "SignalBox is a distributed control system for DCC model railroads. " \
                       "It provides a Ruby-based server that receives sensor events from ESP32 nodes, " \
                       "applies control logic, and sends DCC-EX commands to control trains."
  spec.homepage      = "https://github.com/jeffmcfadden/signalbox"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.files = Dir[
    "lib/**/*.rb",
    "exe/*",
    "layouts/**/*.rb",
    "README.md",
    "LICENSE"
  ]

  spec.bindir        = "exe"
  spec.executables   = ["signalbox-server", "signalbox-conductor"]
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "logger", "~> 1.6"
  spec.add_dependency "json", "~> 2.7"

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
end
