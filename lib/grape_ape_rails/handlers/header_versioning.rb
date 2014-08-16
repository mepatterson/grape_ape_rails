module GrapeApeRails
  module Handlers
    module HeaderVersioning
      extend ActiveSupport::Concern

      included do
        gar_resource = self.name.split('::').last.underscore
        gar_version = self.name.split('::')[-2].underscore.gsub('_','.')
        cascades = GrapeApeRails::API.api_version_cascades_map
        gar_version = cascades[gar_version] if cascades[gar_version].present?
        gar_appname = GrapeApeRails.configuration.app_name
        gar_organization = GrapeApeRails.configuration.organization_name
        version gar_version, using: :header, vendor: "#{gar_organization}.#{gar_appname}", strict: true

        before do
          req = Rack::Request.new(env)
          api_key = version ? GrapeApeRails::API.api_keys_map[version] : nil
          if api_key.nil?
            msg = "Cannot determine API version from header info."
            error!({ code: "UNAUTHORIZED", message: msg}, 401)
          end
        end
      end

    end
  end
end
