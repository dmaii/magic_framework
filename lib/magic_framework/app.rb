require 'singleton'

module MagicFramework
  class App
    include Singleton

    attr_accessor :routes, :params, :opts

    def initialize
      @routes = {}
      @params = {}
      @opts = {:environment=>"development", 
               :pid=>nil, 
               :Port=>3301, 
               :Host=>"localhost", 
               :AccessLog=>[] 
      } 
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
      #require 'debugger'; debugger;
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
                if name_hash.has_key? :mult_splat
                  regex, token = name_hash[:regex], split[ii]
                  mult_splat = MagicFramework.mult_splat_params regex, token
                  params[:splat] << mult_splat
                else 
                  params[:splat] << split[ii]
                end 
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
