# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ccbill/version'

Gem::Specification.new do |spec|
  spec.name          = "ccbill_helper"
  spec.version       = CCBill::VERSION
  spec.authors       = ["Aaron Klaassen"]
  spec.email         = ["aaron.klaassen@outerspacehero.com"]
  spec.summary       = %q{Helpers for interacting with CCBill.}
  spec.description   = %q{Helpers and wrappers for CCBill's often archaic or poorly-documented API's.}
  spec.homepage      = "https://github.com/aaronklaassen/ccbill_helper/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake",    "~> 10.0"
  spec.add_development_dependency "rspec",   "~> 3.1.0"
  spec.add_development_dependency "pry"
end
