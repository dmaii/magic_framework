require_relative 'server'

module MagicFramework

  attr_accessor :routes

  def initialize
    @routes = {}
  end 

  def self.get(path, &block)
    @routes[path] = ['GET', path, block ]
  end 

  class App
    def call(env)
      [200, {'Content-Type' => 'text/plain'}, ['I will be a big strong app someday!']]
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

app_file = /[\/A-Za-z0-9]+.rb/.match(caller[0])[0]
puts File.read(app_file)

at_exit MagicFramework::Server.new(app).start
