namespace :api do
  desc "API Routes"
  task :routes => :environment do
    puts "     #{'Method'.ljust(10)} #{'Version'.ljust(15)} #{'Path'}"
    puts "     #{'------'.ljust(10)} #{'-------'.ljust(15)} #{'----'}"
    API::Base.routes.each do |api|
      method = api.route_method.ljust(10)
      version = (api.route_version || '').ljust(15)
      path = api.route_path.gsub(":version", '')
      puts "     #{method} #{version} #{path}"
    end
  end
end
