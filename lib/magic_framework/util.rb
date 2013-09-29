# Variables are in this order: |r, (v, i)|
module Enumerable
  def inject_with_index(initial, &block)
    self.each_with_index.inject(initial, &block)
  end 

  def trim
    self.reject { |v| v.empty? }
  end 
end

module MagicFramework
  class << self
    # This method needs to generate a map of array index positions on the name/regex
    # associated with that location
    def route_matcher(route)
      #require 'debugger'; debugger;
      r = {}
      splat_index = 0
      split = route.split('/').trim.each_with_index do |v, i|
        if v.start_with? ':'
          name = v[1..-1]
          r[i] = { :name => name, :regex => ALPHANUMERIC }
        elsif v.include? '*'
          if v.eql? '*'
            # If it's *, save which splat it is
            r[i] = { :regex => ALPHANUMERIC, :splat => splat_index }
            splat_index += 1
          else
            r[i] = { :regex => v.gsub('*', '[A-Za-z0-9]+'),  
                     :splat => splat_index, 
                     :mult_splat => true }
            splat_index += 1
          end
        else
          name = v
          r[i] = { :name => name }
        end 
      end 
      r 
    end     

    def mult_splat_params(route, path)
      #require 'debugger'; debugger;
      delimiters = route.split('[A-Za-z0-9]+').trim
      r = []
      while matched = path.match(/([A-Za-z0-9]+)#{delimiter = delimiters.shift}/)
        matched_with_delimiter = matched[0]
        if delimiter.to_s != ''
          r << (no_delimiter = matched_with_delimiter[0...-delimiter.size])
        else
          r << matched_with_delimiter
        end 
        path = path[matched_with_delimiter.size...path.size] if path
      end 
      r
    end 
  end
end 
