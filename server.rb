require 'rack'

module MagicFramework
  class Server < Rack::Server

    def initialize(app)
      @app = app
    end 

    class Options
      def parse!(args)
        args = args.dup
        # hard coding this until later
        r = {:environment=>"development", 
             :pid=>nil, 
             :Port=>3301, 
             :Host=>"localhost", 
             :AccessLog=>[] 
        } 
        r
      end 
    end 

    def call(env)
      @app.call(env)
    end 

    def opt_parser
      Options.new 
    end

    def default_options
      super.merge({
        :Port => 3301,
        #:database => Options::DB
      })
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
