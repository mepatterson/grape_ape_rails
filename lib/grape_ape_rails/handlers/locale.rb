module GrapeApeRails
  module Handlers
    module Locale

      extend ActiveSupport::Concern

      included do
        I18n.config.enforce_available_locales = true
        I18n.config.load_path += Dir['./config/locales/*.yml']
        I18n.config.available_locales = GrapeApeRails.configuration.available_locales
        I18n.config.default_locale = :en

        before do
          # set the locale based on Accept-Language or params[:locale]
          req = Rack::Request.new(env)
          params_locale = (req.params['locale'] && I18n.available_locales.include?(req.params['locale'].downcase.to_sym)) ? req.params['locale'] : nil
          I18n.locale = env.http_accept_language.compatible_language_from(I18n.available_locales) || params_locale || :en
        end
      end

    end
  end
end

