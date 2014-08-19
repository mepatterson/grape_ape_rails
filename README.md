# GrapeApeRails

[![Gem Version](https://badge.fury.io/rb/grape_ape_rails.svg)](http://badge.fury.io/rb/grape_ape_rails)
[![Code Climate](https://codeclimate.com/github/mepatterson/grape_ape_rails/badges/gpa.svg)](https://codeclimate.com/github/mepatterson/grape_ape_rails)
[![Build Status](https://semaphoreapp.com/api/v1/projects/dbb9cbd7-0767-4215-b3f8-faa25510b708/231133/shields_badge.png)](https://semaphoreapp.com/mepatterson/grape_ape_rails)

The general purpose of this gem is to wrap the various best practices of integrating GrapeAPI within the context of a Rails app
into an easy-to-use macro-framework and DSL, plus some opinionated value-adds and features. Basically, Grape and Rails play
together great, but can be tricky to integrate in a robust, clean way; GrapeApeRails (hopefully) makes your life easier.

## Features/Opinions

GrapeApeRails is opinionated. The goal is to make integration easier, so GrapeApeRails makes a number of integration decisions for you:

* API endpoints respond with JSON
* API endpoints expect serialized JSON strings for POST and PUT bodies
* JSON responses are wrapped in a structure that mostly resembles the JSON-RPC spec
* GrapeApeRails APIs are header-versioned using the 'Accept' HTTP header
* API endpoints automatically handle locale if provided (either via params[:locale] or the 'Accept-Language' header) and use the `http_accept_language` middleware
* GrapeApeRails provides an ActiveSupport::Notification that can be suscribed to for logging/injection into the Rails log
* Pagination support is already included for all endpoints via the [grape-kaminari gem](https://github.com/monterail/grape-kaminari)
* Rails cache support is already included for all endpoints via the [grape-rails-cache gem](https://github.com/monterail/grape-rails-cache)
* API endpoints are automagically documented into [Swagger API XML docs](https://helloreverb.com/developers/swagger), presented by your API via mounted endpoints
* Swagger-documented APIs are automatically separated into different URIs by API version

If these opinions and features align closely to what you're planning to build for your API, I think you'll find GrapeApeRails very useful.
If you're intending to build something very different from the above, you're probably better off integrating Grape on your own, or looking at alternate projects
like [Rails::API](https://github.com/rails-api/rails-api).

## Installation

Add this line to your application's Gemfile:

    gem 'grape_ape_rails'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grape_ape_rails

## Setup

First, GrapeApeRails needs an initializer as `config/initializers/grape_ape_rails.rb`

The easiest way to do this is to run the handy rails generator command:

```ruby
rails g grape_ape_rails:setup
```

This will:
* create your initializer with some default settings, based on how you answer the questions
* add a `tilt.root` Rack config to your application.rb for use with Rabl templates

Next, you'll need to create your `API::Base` class, which serves as the starting point for all
of your API endpoints and all versions of your API. By default, GrapeApeRails looks for a
base.rb file in `app/controllers/api/base.rb`

```ruby
# app/controllers/api/base.rb
module API
  class Base < GrapeApeRails::API
    grape_apis do
      # always mount admins first and public-facing versions after
      # with newest version lowest
      api "V1" do
        # ... mounts go here
      end
    end
  end
end
```

NOTE: the api name needs to look like a class name, with camelcase (e.g. "V1" or "AdminV1").
This actually _is_ the class that GrapeApeRails will then expect you to define for exposing your endpoints.
Internally, Grape will translate this to an under-dotted version name (e.g "v1" or "admin.v1")
and this is what will be expected in the Accept header string provided by the requestor.

## Usage

Now that you've got your base.rb ready, you need to mount your various resources/endpoints. This is
done via the `grape_mount` command. These should generally be mounted as pluralized resource names.

```ruby
# inside the base.rb ...
api "V1" do
  grape_mount :widgets
  grape_mount :robots
  grape_mount :pirates
  # ... etc
end
```

If you try to spin up your app now, it will complain that you need to actually create the class files
for each of the resources you've mounted. So let's do that in a 'v1' subfolder...

```ruby
# app/controllers/api/v1/widgets.rb
module API
  module V1
    class Widgets < GrapeApeRails::API
      include GrapeApeRails::Handlers::All

      resource :widgets do
        desc "Get a single Widget"
        get ':id', rabl: 'v1/widget' do
          @widget = Widget.find(params[:id])
          @widget
        end
      end
    end
  end
end
```

In this case, I've simply created a `/widgets/:id` endpoint, but you can define whatever endpoints you want.
Because you've defined this within the :widgets resource, the API will assume all of these endpoints begin
with `/widgets`

### Rabl

In my example, I'm using the default Rabl-based templating. The `rabl` parameter expects a path to the .rabl template file,
as found within /app/views/api/ ... all Rabl functionality should work as expected.

### ActiveModel Serializers

If you'd prefer ActiveModel Serializers over Rabl, GrapeApeRails supports that as well via a custom Grape formatter
called `Grape::Formatter::GarActiveModelSerializers`. To use it, just override the `formatter` within each of your API
classes.

```ruby
module API
  module V1
    class Monkeys < GrapeApeRails::API
      include GrapeApeRails::Handlers::All

      formatter :json, Grape::Formatter::GarActiveModelSerializers

      resource :monkeys do
        desc "Get a single Monkey"
        get ':id' do
          @monkey = Monkey.find(params[:id])
          @monkey
        end
      end
    end
  end
end
```

In this case, it's expected that you've defined a MonkeySerializer class in your models directory, as usual with ActiveModelSerializers.

### JSON Response Structures

Similar to the JSON-RPC spec, endpoints exposed using GrapeApeRails will present either a `result` hash or an `error` hash.
The error hash will be composed of a `code` (a machine-friendly enum-like uppercase string) and a
message (human-friendly, user-presentable message that includes the code inside brackets).

```ruby
# Successful response
{
  "result" : {
    "widgets" : [
      { "id" : 1, "name" : "Fancy Widget" },
      { "id" : 2, "name" : "Other Thing" },
      ...
    ]
  }
}

# Error response
{
  "error" : {
    "code" : "UNAUTHORIZED",
    "message" : "[UNAUTHORIZED] Requires a valid user authorization"
  }
}
```

In the case of a validation error on a resource, there will additionally be a `data` key inside the error hash that includes Rails-style validation errors.

IMPORTANT: In defining response structures, I made the decision (based on lots of research) to go with a plural resource key and an _always-array_ approach in the
response hash. To put it another way:

If you ask for /widgets/1 you will get

`{ "result" : { "widgets" : [ {<widget>} ] } }`

and if you ask for /widgets you will get

`{ "result" : { "widgets" : [ {widget1}, {widget2}, {widget3}, ... ] } }`

### Pagination

GrapeApeRails uses Kaminari for pagination via the [grape-kaminari](https://github.com/monterail/grape-kaminari) gem.

Enabling pagination on a resource is super-simple:

```ruby
# inside your API resource class...
desc "Return a list of Widgets"
params :pagination do
  optional :page,     type: Integer
  optional :per_page, type: Integer
  optional :offset,   type: Integer
end
paginate per_page: 30
get '/', rabl: 'v1/widgets' do
  @widgets = paginate(@widgets)
end
```

_From the grape-kaminari docs:_

Now you can make a HTTP request to your endpoint with the following parameters

- `page`: your current page (default: 1)
- `per_page`: how many to record in a page (default: 10)
- `offset`: the offset to start from (default: 0)

```
curl -v http://host.dev/widgets?page=3&offset=10
```

and the response will be paginated and also will include pagination headers

```
X-Total: 42
X-Total-Pages: 5
X-Page: 3
X-Per-Page: 10
X-Next-Page: 4
X-Prev-Page: 2
X-Offset: 10
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
