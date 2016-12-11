# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'hashira/rails/version'
require 'date'

Gem::Specification.new do |s|
  s.required_ruby_version = ">= #{Hashira::Rails::RUBY_VERSION}"
  s.authors = ['Elliot Winkler (elliot.winkler@gmail.com)']
  s.date = Date.today.strftime('%Y-%m-%d')
  s.description = "hashira-rails generates Rails projects, preconfigured with sensible defaults."
  s.summary = "hashira-rails generates Rails projects, preconfigured with sensible defaults."
  s.email = 'elliot.winkler@gmail.com'
  s.executables = ['hashira-rails']
  s.bindir = 'exe'
  s.extra_rdoc_files = %w[README.md LICENSE]
  s.files = `git ls-files`.split("\n")
  s.homepage = 'https://github.com/mcmire/hashira-rails'
  s.license = 'MIT'
  s.name = 'hashira-rails'
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.version = Hashira::Rails::VERSION

  s.add_dependency 'bitters', '~> 1.3'
  s.add_dependency 'bundler', '~> 1.3'
  s.add_dependency 'rails', Hashira::Rails::RAILS_VERSION

  s.add_development_dependency 'rspec', '~> 3.2'
  s.add_development_dependency 'byebug'
end
