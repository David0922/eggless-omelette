require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'puma', '~> 5.0'
  gem 'rails', '~> 6.1.3'
end

require 'action_controller/railtie'

class App < Rails::Application
  routes.append do
    get '/', action: :hi, controller: 'main'
  end

  # do not eager load code on boot
  config.eager_load = false

  # show full error reports
  config.consider_all_requests_local = true
end

class MainController < ActionController::API
  def hi
    # render json: { msg: 'goodbye world' }
    render plain: "goodbye world\n"
  end
end

App.initialize!

Rack::Server.new(app: App, Port: 3000, daemonize: false).start
