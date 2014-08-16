require 'grape'
require 'http_accept_language'

module GrapeApeRails
  module Base

    extend ActiveSupport::Concern

    included do
      use ::GrapeApeRails::Handlers::RailsLogging

      ['/health', '/'].each do |route|
        get route do
          status 200
          nil
        end
      end

      # global exception handler, used for error notifications
      rescue_from :all do |e|
        error_response(message: { error: { code: "INTERNAL_SERVER_ERROR", message: e.message } }, status: 500)
      end

    end

  end
end
