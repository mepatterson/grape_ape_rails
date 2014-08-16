module API
  module V2
    class Widgets < GrapeApeRails::API
      include GrapeApeRails::Handlers::All

      resource :widgets do

        desc "Get a single Widget [v2]"
        get ':id', rabl: 'v2/widget' do
          @widget = Widget.find(params[:id])
          @widget
        end

      end

    end
  end
end
