require 'grape'
require 'grape-kaminari'
require 'grape-rails-cache'
require 'swagger/grape_swagger_modified'
require 'hashie-forbidden_attributes' if defined?(::Rails)
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
      api_key = api_key_from(args)
      api_version = name.underscore.gsub('_','.')
      update_api_version_cascades_map(api_version, args)
      update_api_keys_map(name, api_key)
      yield
      mount mounts_klass
    ensure
      if GrapeApeRails.configuration.swagger_documentation
        puts "Swaggering #{api_version} endpoints at /api/docs ..."
        klass.add_swagger_documentation hide_documentation_path: true,
                                  api_version: api_version.gsub('.','_'),
                                  mount_with_version: true,
                                  mount_path: "/api/docs"
      end
    end

    def API.grape_mount(resource)
      mounts_klass = "GrapeApeRails::#{@gar_api_version}Base".constantize
      name = "API::#{@gar_api_version}::#{resource.to_s.camelize}"
      puts "  endpoints: #{name}"
      mounts_klass.send(:mount, name.constantize)
    rescue NameError => e
      puts "    [ERROR] Could not instantiate API Endpoints at '#{name}'. Maybe you still need to create the class file?"
    end

    private

    class << self
      def api_key_from(args)
        api_key = GrapeApeRails.configuration.api_secret_key
        api_key = args[0] if args[0].present? && args[0].is_a?(String)
        api_key
      end

      def update_api_keys_map(name, api_key)
        GrapeApeRails::API.api_keys_map.merge!({ name.underscore.gsub('_','.') => api_key })
      end

      def update_api_version_cascades_map(api_version, args)
        return unless arr = cascades_array_from(args)
        cascades = arr.map{ |v| v.underscore.gsub('_','.') }
        GrapeApeRails::API.api_version_cascades_map.merge!({ api_version => cascades })
      end

      def cascades_array_from(args)
        return args[0] if args[0].present? && args[0].is_a?(Array)
        return args[1] if args[1].present? && args[1].is_a?(Array)
        return nil
      end
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

