require_relative 'server'
require 'singleton'

module MagicFramework

  class << self
    def route_matcher(route)
      r = route.split('/').reject{ |c| c.empty? }.inject('^') do |str, i|
        str << '/' << (i.start_with?(':') ? '[A-Za-z0-9]+' : i)
      end 
      r << (r.length.eql?(1) ? '/' : '') << '$'
    end 
  end 

  class App
    include Singleton

    attr_accessor :routes

    def initialize
      @routes = {}
    end 

    def call(env)
      response = Rack::Response.new
      response['Content-Type'] = 'text/html'
      path = env['PATH_INFO']
      html = (find_match(path) && find_match(path).call) ? find_match(path).call : '404'
      response.write(html)
      response.finish
    end 

    def find_match(route)
      #require 'debugger'; debugger;
      r = @routes.keys.inject(lambda { false }) do |p, i|
        puts route.inspect
        puts i.inspect
        puts Regexp.new(i)
        puts Regexp.new(i).match(route) ? true : false
        if Regexp.new(i).match(route)
          p = @routes[i][1]
          break
        end 
      end 
      puts r.class
      r
    end 
  end 


end 

module Enumerable
  def inject_with_index(initial, &block)
    self.each_with_index.inject(initial, &block)
  end 
end


def get(path, &block)
  matcher = MagicFramework.route_matcher path
  MagicFramework::App.instance.routes[matcher] = ['GET', block]
end 

app = Rack::Builder.new do 
  use Rack::CommonLogger
  run MagicFramework::App.instance
end 

at_exit { MagicFramework::Server.new(app).start }
