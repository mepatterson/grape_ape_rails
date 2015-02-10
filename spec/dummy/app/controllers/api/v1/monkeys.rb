module API
  module V1
    class Monkeys < GrapeApeRails::API
      include GrapeApeRails::Handlers::All

      formatter :json, Grape::Formatter::GarActiveModelSerializers

      resource :monkeys do
        desc "Get many monkeys"
        get '/' do
          @monkeys = Monkey.all
          @monkeys
        end

        desc "Get a single Monkey"
        get ':id' do
          @monkey = Monkey.find(params[:id])
          @monkey
        end
      end
    end
  end
end
