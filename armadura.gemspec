# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'armadura/version'
require 'date'

Gem::Specification.new do |s|
  s.required_ruby_version = ">= #{Armadura::RUBY_VERSION}"
  s.authors = ['Elliot Winkler (elliot.winkler@gmail.com)']
  s.date = Date.today.strftime('%Y-%m-%d')
  s.description = "Armadura generates Rails projects, preconfigured with sensible defaults."
  s.summary = "Armadura generates Rails projects, preconfigured with sensible defaults."
  s.email = 'elliot.winkler@gmail.com'
  s.executables = ['armadura']
  s.bindir = 'exe'
  s.extra_rdoc_files = %w[README.md LICENSE]
  s.files = `git ls-files`.split("\n")
  s.homepage = 'https://github.com/mcmire/armadura'
  s.license = 'MIT'
  s.name = 'armadura'
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.version = Armadura::VERSION

  s.add_dependency 'bitters', '~> 1.3'
  s.add_dependency 'bundler', '~> 1.3'
  s.add_dependency 'rails', Armadura::RAILS_VERSION

  s.add_development_dependency 'rspec', '~> 3.2'
  s.add_development_dependency 'byebug'
end
