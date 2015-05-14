require 'tilt'
require 'rabl'
require 'grape-active_model_serializers'

Rabl.configure do |config|
  config.include_json_root = false
end
Rabl.register!

module Grape
  module Formatter
    module GarJsonSerializer
      def self.call(resource, env)
        MultiJson.dump({ result: resource })
      end
    end


    module GarError
      def self.call(message, backtrace, options, env)
        err = { error: { code: 'ERROR', message: message } }
        if message.is_a?(Hash) && message[:code].present? && message[:message].present?
          full_msg = "[#{message[:code]}] #{message[:message]}"
          err = { error: { code: message[:code], message: full_msg } }
          err[:error].merge!({ data: message[:data] }) if message[:data].present?
        elsif message.respond_to?(:error_code) && message.respond_to?(:message)
          full_msg = "[#{message.error_code}] #{message.message}"
          err = { error: { code: message.error_code, message: full_msg } }
        end
        MultiJson.dump err
      end
    end

    module GarActiveModelSerializers
      def self.call(resource, env)
        if serializer = Grape::Formatter::ActiveModelSerializers.fetch_serializer(resource, env)
          serializer.root = false
          %Q[{\"result\":{\"#{pluralized_resource(serializer, env)}\":#{dump_to_json_array_string(serializer)}}}]
        else
          Grape::Formatter::GarJsonSerializer.call resource, env
        end
      end

      private

      def self.dump_to_json_array_string(serializer)
        str = serializer.object.try(:empty?) ? nil : MultiJson.dump(serializer)
        str = "[#{str}]" unless is_serialized_array_string?(str)
        str
      end

      def self.is_serialized_array_string?(str)
        str.present? && str[0,1] == '[' && str[-1,1] == ']'
      end

      def self.pluralized_resource(serializer, env)
        single = serializer.try(:resource_singular) || serializer.instance_variable_get(:@resource_name).try(:singularize) || serializer.instance_variable_get(:@object).class.name.underscore
        plural = serializer.try(:resource_plural) || serializer.instance_variable_get(:@resource_name) || single.pluralize
        # allow the pluralized resource name to be overriden with a custom route setting
        if env["rack.routing_args"][:route_info].route_settings[:custom] && env["rack.routing_args"][:route_info].route_settings[:custom][:resource_plural]
          plural = env["rack.routing_args"][:route_info].route_settings[:custom][:resource_plural].to_s.downcase
        end
        plural
      end
    end

    module GarRabl
      class << self
        attr_reader :env
        attr_reader :endpoint

        def call(object, env)
          @env = env
          @endpoint = env['api.endpoint']
          if rablable?
            rabl do |template|
              engine = ::Tilt.new(view_path(template), tilt_options)
              output = engine.render endpoint, {}
              output = wrap_output(output)
              if layout_template
                layout_template.render(endpoint) { output }
              else
                output
              end
            end
          else
            Grape::Formatter::GarJsonSerializer.call object, env
          end
        end

        private

        def wrap_output(output)
          template = MultiJson.dump({ result: "***" })
          template.gsub(%Q("***"), output)
        end

        def view_path(template)
          if template.split('.')[-1] == 'rabl'
            File.join(env['api.tilt.root'], template)
          else
            File.join(env['api.tilt.root'], (template + '.rabl'))
          end
        end

        def rablable?
          !!endpoint.options[:route_options][:rabl]
        end

        def rabl
          template = endpoint.options[:route_options][:rabl]
          fail 'missing rabl template' unless template
          set_view_root unless env['api.tilt.root']
          yield template
        end

        def set_view_root
          fail "Use Rack::Config to set 'api.tilt.root' in config.ru"
        end

        def set_layouts_base
          fail "Use Rack::Config to set 'api.title.layouts_base' in config.ru"
        end

        def tilt_options
          { format: env['api.format'], view_path: env['api.tilt.root'] }
        end

        def layout_template
          set_layouts_base unless env['api.tilt.layouts_base']
          ver = env['rack.routing_args'][:route_info].route_version
          layout_path = "#{env['api.tilt.layouts_base']}/#{ver}.json.haml"
          if File.exist?(layout_path)
            ::Tilt.new(layout_path, tilt_options.merge(format: :xhtml, ugly: true))
          else
            nil
          end
        rescue
          nil
        end
      end
    end

  end
end
