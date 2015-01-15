# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grape_ape_rails/version'

Gem::Specification.new do |spec|
  spec.name          = "grape_ape_rails"
  spec.version       = GrapeApeRails::VERSION
  spec.authors       = ["Matt E. Patterson"]
  spec.email         = ["madraziel@gmail.com"]
  spec.summary       = %q{Provides customized Grape API functionality inside Rails}
  spec.description   = %q{Provides customized Grape API functionality inside Rails}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport'
  spec.add_dependency 'multi_json'
  spec.add_dependency 'oj'
  spec.add_dependency "grape", "0.9.0"
  spec.add_dependency 'grape-rabl'
  spec.add_dependency 'grape-kaminari'
  spec.add_dependency 'grape-rails-cache'
  spec.add_dependency 'kramdown'
  spec.add_dependency 'grape-active_model_serializers'
  spec.add_dependency 'http_accept_language'
  spec.add_dependency 'rabl'
  spec.add_dependency 'hashie_rails'

  spec.add_development_dependency "rails", "~> 4.1"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "factory_girl_rails"
  spec.add_development_dependency "rspec-rails", '~> 3.0.0'
  spec.add_development_dependency 'shoulda-matchers'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'codeclimate-test-reporter'
end
