require_relative 'server'
require_relative 'constants'
require_relative 'util'
require 'singleton'
include Constants

module MagicFramework
  class << self
    # This method needs to generate a map of array index positions on the name/regex
    # associated with that location
    def route_matcher(route)
      r = {}
      splat_index = 0
      split = route.split('/').trim.each_with_index do |v, i|
        if v.start_with? ':'
          name = v[1..-1]
          r[i] = { :name => name, :regex => ALPHANUMERIC }
        elsif v.eql? '*'
          # If it's *, save which splat it is
          r[i] = { :regex => ALPHANUMERIC, :splat => splat_index }
          splat_index += 1
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
        puts m.to_s
        html = m[:block].call
      else
        html = '404'
      end 
      response.write html
      response.finish
    end 

    def find_match(route) 
      r = { block: lambda { false } } 
      puts @routes
      @routes.keys.each do |v|
        # v is a map of index numbers to the regex/name in the index
        if v.empty?
          regex = '^/$'
        else
          regex = '^'
          regex << v.values.inject('') do |ir, iv|
            ir << '/' << (iv[:regex] || iv[:name])
          end 
          regex << '$'
        end 
        if Regexp.new(regex).match route
          # If a match is found, then immediately set the block on the return value
          r[:block] = @routes[v][1]
          (0..((split = route.split('/').trim).length - 1)).each do |ii|
            name_hash = v[ii] || {}
            if name_hash.has_key? :regex
              if name_hash.has_key? :splat
                params[:splat] ||= []
                params[:splat] << split[ii]
              else
                r[name_hash[:name].to_sym] = split[ii] 
                @params= r.reject { |k| k.eql? :block }
              end 
            end 
          end 
        end 
      end 
      r
    end 
  end 
end 

def params
  MagicFramework::App.instance.params
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
