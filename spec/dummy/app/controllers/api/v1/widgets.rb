module API
  module V1
    class Widgets < GrapeApeRails::API
      include GrapeApeRails::Handlers::All

      get "/thing" do
        { foo: 42 }
      end

      resource :widgets do
        desc "Get a single Widget"
        get ':id', rabl: 'v1/widget' do
          @widget = Widget.find(params[:id])
          @widget
        end

        desc "Get all Widgets"
        get '/', rabl: 'v1/widgets' do
          @widgets = Widget.all
          @widgets
        end

        desc "Get a Widget, requiring a name"
        params do
          requires :name
        end
        get ':id/named', rabl: 'v1/widget' do
          @widget = Widget.first
          @widget
        end

        desc "Create a Widget"
        params do
          requires :name
          requires :color
        end
        post "/", rabl: 'v1/widget' do
          widget_params = params.except(:route_info, :format)
          @widget = Widget.new widget_params
          unless @widget.save
            errs = @widget.errors.messages.map{ |a, m| "#{a} #{m.join(', ')}" }.join('; ')
            error!({ code: 'CREATE_WIDGET_FAILED', message: "Resource failed validation. #{errs}" }, 422)
          end
          @widget
        end

        desc "Update a Widget"
        put ":id", rabl: 'v1/widget' do
          widget_params = params.except(:route_info, :format)
          @widget = Widget.find(params[:id])
          unless @widget.update_attributes widget_params
            errs = @widget.errors.messages.map{ |a, m| "#{a} #{m.join(', ')}" }.join('; ')
            error!({ code: 'UPDATE_WIDGET_FAILED', message: "Resource failed validation. #{errs}" }, 422)
          end
          @widget
        end

      end
    end
  end
end
