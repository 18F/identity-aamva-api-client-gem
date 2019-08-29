# rubocop:disable Style/FileName
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'aamva/version'

Gem::Specification.new do |s|
  s.name = 'aamva'
  s.version = Aamva::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = [
    'Zach Margolis <zachary.margolis@gsa.gov>',
    'Jonathan Hooper <jonathan.hooper@gsa.gov>',
  ]
  s.email = 'hello@login.gov'
  s.homepage = 'http://github.com/18F/identity-aamva-api-client-gem'
  s.summary = 'AAMVA API client'
  s.description = 'AAMVA API client for Ruby'
  s.date = Time.now.utc.strftime('%Y-%m-%d')
  s.files = Dir.glob('app/**/*') + Dir.glob('lib/**/*') + [
    'LICENSE.md',
    'README.md',
    'Gemfile',
    'aamva-api-client.gemspec',
  ]
  s.license = 'LICENSE'
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
  s.rdoc_options = ['--charset=UTF-8']

  s.add_dependency('dotenv')
  s.add_dependency('faraday')
  s.add_dependency('hashie')
  s.add_dependency('typhoeus')
  s.add_dependency('xmldsig')

  s.add_development_dependency('irb')
  s.add_development_dependency('pry-byebug')
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('webmock')
end
