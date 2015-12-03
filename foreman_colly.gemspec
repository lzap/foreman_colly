require File.expand_path('../lib/foreman_colly/version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'foreman_colly'
  s.version     = ForemanColly::VERSION
  s.date        = Date.today.to_s
  s.authors     = ['Lukas Zapletal']
  s.email       = ['lukas-x@zapletalovi.com']
  s.homepage    = 'https://github.com/lzap/foreman_colly'
  s.summary     = 'Foreman plugin for Collectd'
  s.description = 'Foreman plugin that integrates with Collectd as a cache of probe values'

  s.files = Dir['{app,config,db,lib,locale}/**/*'] + ['LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'collectd-uxsock'
  s.add_dependency 'deface'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rdoc'
end
