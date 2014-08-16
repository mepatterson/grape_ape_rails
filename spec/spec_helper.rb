ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require 'rspec/rails'
require 'shoulda/matchers'
require 'database_cleaner'
require 'factory_girl'
require 'timecop'
require 'pry'
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

Rails.backtrace_cleaner.remove_silencers!

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.infer_spec_type_from_file_location!
  config.filter_run :focus
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    FactoryGirl.lint
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.before(:each) do
    # ... stubs here
  end

  config.around(:each) do |spec|
    DatabaseCleaner.cleaning do
      spec.run
    end
  end


  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

FactoryGirl.define do
  factory :widget do
    name          "Magical Widget Alpha"
    color         "green"
    radioactive   true
    rads          150
  end

  factory :monkey do
    name          "Frank the Monkey"
    color         "brown"
  end
end

def gar_response(payload, success_or_failure = :success)
  payload = [payload] unless payload.is_a? Array
  hash = { result: payload }
  hash = { error: { code: 'FAILURE', message: 'This is a failure.' } } if success_or_failure == :failure
  MultiJson.dump hash
end

def gar_success(payload)
  gar_response payload, :success
end

def gar_failure(payload)
  gar_response payload, :failure
end

def req(method, path, args = {})
  version = args[:version] || 'v1'
  args[:params] ||= {}
  headers = args[:headers] || {}
  headers.merge!({ 'HTTP_ACCEPT_LANGUAGE' => args[:locale] }) if args[:locale]
  headers.merge!({ 'Accept' => "application/vnd.monkeyworks.titan-#{version}+json", 'Content-Type' => 'application/json' })
  headers.merge!({ 'HTTP_IF_NONE_MATCH' => args[:etag] }) if args[:etag]
  send(method, path, args[:params], headers)
end

def json_result(raw=false)
  json = MultiJson.load(response.body, symbolize_keys: true)
  raw ? json : json[:result]
end

def json_error
  MultiJson.load(response.body, symbolize_keys: true)[:error]
rescue
  nil
end
