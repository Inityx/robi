# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "Rindle"
  spec.version       = '1.0'
  spec.authors       = ["Andrew Tolvstad"]
  spec.license       = "Apache 2.0"

  spec.files         = ['lib/fetcher.rb', 'lib/compiler.rb']
  spec.executables   = ['bin/rindle']
  spec.require_paths = ["lib"]
end
