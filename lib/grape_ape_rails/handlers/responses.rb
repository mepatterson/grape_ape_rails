module GrapeApeRails
  module Handlers
    module Responses
      extend ActiveSupport::Concern

      included do
        format :json
        formatter :json, Grape::Formatter::GarRabl
        error_formatter :json, Grape::Formatter::GarError

        before do
          # ...
        end

        rescue_from Grape::Exceptions::ValidationErrors do |e|
          status = 422
          hash_err = { error: {
            code: 'RESOURCE_FAILED_VALIDATION',
            message: '[RESOURCE_FAILED_VALIDATION] Resource failed validation per API parameter requirements' }
          }
          log_msg = hash_err[:error].clone
          hash_err[:error].merge!({ data: e.errors }) if e.errors.present?
          if defined?(::Rails) && Rails.respond_to?(:logger)
            api_version = "[#{env['rack.routing_args'][:route_info].route_version}]" rescue nil
            Rails.logger.warn "[API]#{api_version} Responding with #{status} #{log_msg}"
          end
          Rack::Response.new(MultiJson.dump(hash_err), status)
        end
      end
    end
  end
end
