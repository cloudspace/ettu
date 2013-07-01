# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ettu/version'

Gem::Specification.new do |spec|
  spec.name          = 'ettu'
  spec.version       = Ettu::VERSION
  spec.author        = 'Justin Ridgewell'
  spec.email         = 'jridgewell@cloudspace.com'
  spec.description   = %q{Account for js, css, and views when using ETags.}
  spec.summary       = %q{Account for view code when using ETags.}
  spec.homepage      = 'http://github.com/cloudspace/ettu'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9'

  spec.add_dependency 'rails', '~> 4.0'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
end
