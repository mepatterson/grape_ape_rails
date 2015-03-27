require "grape_ape_rails/version"

require 'active_support'
require 'grape'
require 'swagger/grape_swagger_modified'
require 'grape_ape_rails/railtie' if defined?(Rails)
require 'grape_ape_rails/api'
require 'grape_ape_rails/base'
require 'grape_ape_rails/handlers/header_versioning'
require 'grape_ape_rails/handlers/responses'
require 'grape_ape_rails/handlers/formatters'
require 'grape_ape_rails/handlers/locale'
require 'grape_ape_rails/handlers'


module GrapeApeRails

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
    raise_configuration_errors!
    self
  end

  def self.raise_configuration_errors!
    if self.configuration.api_header_security_enabled
      %i[ app_name organization_name api_secret_key ].each do |setting|
        if self.configuration.send(setting).nil?
          raise "You must set #{setting} in a configuration block in your initializer!"
        end
      end
    end
  end

  class Configuration
    attr_accessor :app_name, :organization_name,
                  :api_secret_key, :api_header_security_enabled,
                  :available_locales, :security_envelope_debug,
                  :swagger_documentation

    def initialize
      @app_name = nil
      @organization_name = nil
      @api_secret_key = nil
      @api_header_security_enabled = true
      @api_security_algorithm = "sha256"
      @available_locales = [ :en ]
      @swagger_documentation = true
      # ...
    end
  end

end
