require 'digest'
module GrapeApeRails
  module Generators
    DEFAULT_TILT_ROOT = "app/views/api"

    class SetupGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)
      desc "Sets up GrapeApeRails for your application"

      def create_initializer
        say "\n\nCreating an initializer..."
        say ("-"*80)
        org_name = ask("Provide a name for your organization (all lowercase please):")
        if org_name.blank?
          say_status "error", "You must provide an organization name!", :red
          exit
        end
        app_name = ask("Provide a name for this app (all lowercase please):")
        if app_name.blank?
          say_status "error", "You must provide a name for the app!", :red
          exit
        end
        api_key = ask("Provide the primary API Secret Key (leave blank and I'll create one for you):")
        if api_key.blank?
          api_key = Digest::SHA256.hexdigest("#{app_name}#{Time.now.to_f.to_s}")
        end
        copy_file "initializer.rb", "config/initializers/grape_ape_rails.rb"
        gsub_file "config/initializers/grape_ape_rails.rb", '%%ORGNAME%%', org_name.downcase, verbose: false
        gsub_file "config/initializers/grape_ape_rails.rb", '%%APPNAME%%', app_name.downcase, verbose: false
        gsub_file "config/initializers/grape_ape_rails.rb", '%%APIKEY%%', api_key, verbose: false
      end

      def configure_tilt_root
        say "\n\nConfiguring Tilt for RABL templates..."
        say ("-"*80)

        if yes?("Will you be using RABL templates? (y/n)")
          tilt_root = ask("What will be your RABL templates' root directory (default: #{DEFAULT_TILT_ROOT})?")
          tilt_root = DEFAULT_TILT_ROOT if tilt_root.blank?
          tilt_root = tilt_root[1..-1] if tilt_root[0] == '/'
          say_status "modified", "config/application.rb", :green
          say_status "NOTE", "Added a Rack::Config middleware block. You might have to move this around later once you start adding more stuff to your application.rb. It should generally be at the end.", :white
        else
          tilt_root = DEFAULT_TILT_ROOT
          say_status "NOTE", "We'll set the default in case you want to use RABL later. You can always change it in application.rb", :white
          say_status "modified", "config/application.rb", :green
        end
        application do
          <<-RUBY.gsub(/^ {4}/, '')
    config.middleware.use(Rack::Config) do |env|
          env['api.tilt.root'] = Rails.root.join "#{tilt_root}"
        end
          RUBY
        end
      end

    end
  end
end
