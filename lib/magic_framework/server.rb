require 'rack'
require_relative 'app'

module MagicFramework
  class Server < Rack::Server

    def initialize(app)
      @app = app
    end 

    def call(env)
      @app.call(env)
    end 

    def opt_parser
      Options.new 
    end

    def options
      MagicFramework::App.instance.opts
    end 

    def app
      # The public directory is designed for static content
      Rack::Cascade.new([self], [405, 404, 403])
    end 

    def start
      super
    end 
  end 
end 
