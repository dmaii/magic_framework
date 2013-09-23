require_relative 'server'
require 'singleton'

module MagicFramework

  class << self
    def route_matcher(route)
      r = route.split('/').reject{ |c| c.empty? }.inject('^') do |str, v|
        str << '/' << (v.start_with?(':') ? '[A-Za-z0-9]+' : v)
      end 
      r << (r.length.eql?(1) ? '/' : '') << '$'
    end 

    # Creates a map of maps. Each section of a route maps
    # to either 1) An map with just the indexif it's not variable or
    # 2) a map of the variable name and the regex it requires
    def map_route(route)
      route.split('/').trim.inject_with_index({}) do |r, (v, i)|
        if v.start_with? ':'  
          content = { regex: '[A-Za-z0-9]+', name: v[1..-1] }
        else 
          content = { name: v }
        end
        r.merge({ i => content })
      end 
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
      match = find_match path
      html = (m = find_match(path) && m.call) ? m.call : '404'
      response.write html
      response.finish
    end 

    def find_match(route)
      r = lambda { false }
      @routes.keys.each do |k|
        if Regexp.new(k).match(route)
          r = @routes[k][1]
          break
        end 
      end 
      r
    end 

    def find_match(route)
      r = lambda { false } 
      route.split('/').trim.each_with_index do |v, i|
        # v is now each item in the route
        # going through each route on routes
        @routes.keys.each do |iv|
          if iv.has_key? i && iv[i]
          end 
        end 
      end 
    end 
  end 
end 

# Variables are in this order: |r, (v, i)|
module Enumerable
  def inject_with_index(initial, &block)
    self.each_with_index.inject(initial, &block)
  end 

  def trim
    self.reject { |v| v.empty? }
  end 
end


def get(path, &blk)
  matcher = MagicFramework.route_matcher path
  MagicFramework::App.instance.routes[matcher] = ['GET', blk]
end 


app = Rack::Builder.new do 
  use Rack::CommonLogger
  run MagicFramework::App.instance
end 

at_exit { MagicFramework::Server.new(app).start }
