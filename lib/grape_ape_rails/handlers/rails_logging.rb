module GrapeApeRails
  module Handlers
    class RailsLogging
      def initialize(app)
        @app = app
      end

      def call(env)
        api_version = env['rack.routing_args'][:route_info].route_version rescue nil
        payload = {
          remote_addr:    env['REMOTE_ADDR'],
          request_method: env['REQUEST_METHOD'],
          request_path:   env['PATH_INFO'],
          request_query:  env['QUERY_STRING'],
          api_version:    api_version
        }
        req = Rack::Request.new(env)
        payload[:params] = req.params
        ActiveSupport::Notifications.instrument "grape.request", payload do
          @app.call(env).tap do |response|
            status, headers, body = *response
            payload[:params].merge!(env["api.endpoint"].params.to_hash)
            payload[:params].delete("route_info")
            payload[:params].delete("format")
            payload[:response_status] = status
          end
        end
      rescue
        @app.call(env)
      end
    end
  end
end
