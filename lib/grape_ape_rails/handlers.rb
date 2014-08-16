module GrapeApeRails
  module Handlers
    module All
      extend ActiveSupport::Concern

      included do
        # middleware for every API
        use ::HttpAcceptLanguage::Middleware
        use ::GrapeApeRails::Handlers::RailsLogging

        # third-party Grape tools
        include Grape::Kaminari
        include Grape::Rails::Cache

        # Gar-specific handlers
        include GrapeApeRails::Handlers::HeaderVersioning
        include GrapeApeRails::Handlers::Responses
        include GrapeApeRails::Handlers::Locale
      end
    end
  end
end
