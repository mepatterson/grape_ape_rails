require 'grape_ape_rails'
require 'rails'
module GrapeApeRails
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/routes.rake"
    end
  end
end
