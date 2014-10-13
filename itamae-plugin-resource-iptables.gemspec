# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'itamae/plugin/resource/iptables/version'

Gem::Specification.new do |spec|
  spec.name          = "itamae-plugin-resource-iptables"
  spec.version       = Itamae::Plugin::Resource::Iptables::VERSION
  spec.authors       = ["Kohei Suzuki"]
  spec.email         = ["eagletmt@gmail.com"]
  spec.summary       = %q{itamae resource plugin to manage iptables.}
  spec.description   = %q{itamae resource plugin to manage iptables.}
  spec.homepage      = "https://github.com/eagletmt/itamae-plugin-resource-iptables"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_dependency "itamae"
end
