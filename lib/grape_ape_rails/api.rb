require 'grape'
require 'grape-kaminari'
require 'grape-rails-cache'
require 'swagger/grape_swagger_modified'
require 'hashie_rails' if defined?(::Rails)
require 'http_accept_language'
require 'grape_ape_rails/base'
require 'grape_ape_rails/handlers/header_versioning'
require 'grape_ape_rails/handlers/rails_logging'


module GrapeApeRails
  class API < Grape::API

    def self.api_keys_map
      @api_keys_map ||= {}
    end

    def self.api_version_cascades_map
      @api_version_cascades ||= {}
    end

    def self.api_secret_key
      @api_secret_key
    end

    def self.api_secret_key=(val)
      @api_secret_key = val
    end

    def API.grape_apis(&block)
      res = yield
      include GrapeApeRails::Base
      res
    end

    # args:
    #   [0] => version name (e.g. 'v1')
    #   [1] => (optional) an array of cascades (e.g. ['V2', 'V1'])
    def API.api(name, *args, &block)
      puts "Spinning up Grape API: #{name} ..."
      @gar_api_version = name
      mounts_klass = Class.new(GrapeApeRails::API)
      klass = GrapeApeRails.const_set("#{name}Base", mounts_klass)
      api_key = GrapeApeRails.configuration.api_secret_key
      api_key = args[0] if args[0].present? && args[0].is_a?(String)

      api_version = name.underscore.gsub('_','.')
      if args[0].present? && args[0].is_a?(Array)
        GrapeApeRails::API.api_version_cascades_map.merge!({ api_version => args[0].map{ |v| v.underscore.gsub('_','.') } })
      elsif args[1].present? && args[1].is_a?(Array)
        GrapeApeRails::API.api_version_cascades_map.merge!({ api_version => args[1].map{ |v| v.underscore.gsub('_','.') } })
      end
      dotname = name.underscore.gsub('_','.')
      GrapeApeRails::API.api_keys_map.merge!({ dotname => api_key })
      yield
      mount mounts_klass
    ensure
      puts "Swaggering #{api_version} endpoints..."
      klass.add_swagger_documentation hide_documentation_path: true,
                                api_version: api_version.gsub('.','_'),
                                mount_with_version: true,
                                mount_path: "/api/docs"
    end

    def API.grape_mount(resource)
      mounts_klass = "GrapeApeRails::#{@gar_api_version}Base".constantize
      name = "API::#{@gar_api_version}::#{resource.to_s.camelize}"
      puts "  endpoints: #{name}"
      mounts_klass.send(:mount, name.constantize)
    rescue NameError => e
      puts "    [ERROR] Could not instantiate API Endpoints at '#{name}'. Maybe you still need to create the class file?"
    end

  end
end

class Grape::Endpoint
  def error!(message, status = nil, headers = nil)
    if defined?(::Rails) && Rails.respond_to?(:logger)
      api_version = "[#{env['rack.routing_args'][:route_info].route_version}]" rescue nil
      Rails.logger.warn "[API]#{api_version} Responding with #{status} #{message}"
    end
    status = settings[:default_error_status] unless status
    throw :error, message: message, status: status, headers: headers
  end
end
