require 'singleton'


# Variables are in this order: |r, (v, i)|
module Enumerable
  def inject_with_index(initial, &block)
    self.each_with_index.inject(initial, &block)
  end 

  def trim
    self.reject { |v| v.empty? }
  end 
end

def route_matcher(route)
  r = {}
  splat_index = 0

  # This goes through all the values of a route, separated by a forward
  # slash. If the value is starts with a colon, then it's going to be a
  # variable. If it's a * and only a *, then it should be included in the
  # splat array in params.  
  split = route.split('/').trim.each_with_index do |v, i|
    if v.start_with? ':'
      name = v[1..-1]
      r[i] = { :name => name, :regex => '[A-Za-z0-9]+' }
    elsif v.eql? '*' 
      # If it's *, save which splat it is
      r[i] = { :regex => '[A-Za-z0-9]+', :splat => splat_index }
      splat_index += 1
    else 
      name = v
      r[i] = { :name => name }
    end 
  end 
  r 
end     
class Test
  include Singleton
  attr_accessor :routes 
  def initialize
    @routes = {}
  end 
end 

params = {}

def get(path, &blk)
  matcher = route_matcher path
  Test.instance.routes[matcher] = ['GET', blk]
end 

get '/boo/:soo/poo' do
  params[:soo]
end 

get '/*' do
  params[:splat].to_s
end 

puts Test.instance.routes

# For this method to work, routes would need to be keyed by a map of index numbers to the 
# regex/name in the index to the block associated with it

define_method('find_match') do |route|
  params = {}
  r = { block: lambda { false } } 
  # For every item in routes, generate a regex matcher out of it
  # and check if the route matches. If it's a match, then extract the
  # route variables from the route, and return a map with the following items:
  # block: the block associated with the route, variables: a map of variable names
  # with their corresponding values
  Test.instance.routes.keys.each do |v|
    # v is a map of index numbers to the regex/name in the index
    regex = v.values.inject('') do |ir, iv|
      ir << '/' << (iv[:regex] || iv[:name])
    end 
    if Regexp.new(regex).match route
      # If a match is found, then immediately set the block on the return value
      # v[ii] is the actual value of the current route item we're on
      #require 'debugger'; debugger;
      r[:block] = Test.instance.routes[v][1]
      (0..((split = route.split('/').trim).length - 1)).each do |ii|
        name_hash = v[ii]
        if name_hash.has_key? :regex
          if name_hash.has_key? :splat 
            params[:splat] ||= []
            params[:splat] << split[ii]
          else 
            r[name_hash[:name].to_sym] = split[ii] 
            params = r.reject { |k| k.eql? :block }
          end 
        end 
      end 
    end 
  end 
  r
end 

path = '/asdfasdf'
puts find_match(path)
if (m = find_match(path)) && m[:block].respond_to?(:call)
  html = m[:block].call
else
  html = '404'
end 

puts html

