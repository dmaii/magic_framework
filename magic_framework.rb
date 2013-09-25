require_relative 'server'
require 'singleton'

module MagicFramework

  class << self
    # This method needs to generate a map of array index positions on the name/regex
    # associated with that location
    def route_matcher(route)
      r = {}
      split = route.split('/').trim.each_with_index do |v, i|
        if v.start_with? ':'
          name = v[1..-1]
          r[i] = { :name => name, :regex => '[A-Za-z0-9]+' }
        else
          name = v
          r[i] = { :name => name }
        end 
      end 
      r 
    end     
  end 

  class App
    include Singleton

    attr_accessor :routes, :params

    def initialize
      @routes = {}
      @params = {}
    end 

    def call(env)
      response = Rack::Response.new
      response['Content-Type'] = 'text/html'
      path = env['PATH_INFO']
      if (m = find_match(path)) && m[:block].respond_to?(:call)
        puts m
        html = m[:block].call
      else
        html = '404'
      end 
      response.write html
      response.finish
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


def params
  MagicFramework::App.instance.params
end 

# For this method to work, routes would need to be keyed by a map of index numbers to the 
# regex/name in the index to the block associated with it
define_method('find_match') do |route|
  include MagicFramework
  r = { block: lambda { false } } 
  App.instance.routes.keys.each do |v|
    # v is a map of index numbers to the regex/name in the index
    regex = v.values.inject('') do |ir, iv|
      ir << '/' << (iv[:regex] || iv[:name])
    end 
    if Regexp.new(regex).match route
      # If a match is found, then immediately set the block on the return value
      r[:block] = App.instance.routes[v][1]
      (0..((split = route.split('/').trim).length - 1)).each do |ii|
        name_hash = v[ii] || {}
        if name_hash.has_key? :regex
          r[name_hash[:name].to_sym] = split[ii] 
          App.instance.params= r.reject { |k| k.eql? :block }
        end 
      end 
    end 
  end 
  r
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
