require_relative 'server'

module MagicFramework

  class << self
    attr_reader :routes

    def get(path, &block)
      puts 'boo'
      @routes = {}
      @routes[path] = ['GET', path, block ]
    end 
  end 

  class App
    def call(env)
      puts MagicFramework.routes.to_s
      if MagicFramework.routes.has_key? env['PATH_INFO']
        return MagicFramework.routes[2].call
      end 
      response = Rack::Response.new
      response['Content-Type'] = 'text/html'
      html = File.read 'test.html'
      response.write html
      a = response.finish
      a
    end 
  end 

  # Stole this from sinatra. This adds methods to the main
  # application from the MagicFramework module
  module Delegator #:nodoc:
    def self.delegate(*methods)
      puts respond_to?(:get) + 'shasdfjl'
      methods.each do |method_name|
        define_method(method_name) do |*args, &block|
        return super(*args, &block) if respond_to? method_name
        end
        private method_name
      end
    end

    delegate :get 

  end
end 

app = Rack::Builder.new do 
  use Rack::CommonLogger
  run MagicFramework::App.new
  map '/boo' do
    run Proc.new {|env| [200, {"Content-Type" => "text/html"}, ["infinity 0.1"]] }
  end 
end 

at_exit { MagicFramework::Server.new(app).start }
