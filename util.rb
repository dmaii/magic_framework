# Variables are in this order: |r, (v, i)|
module Enumerable
  def inject_with_index(initial, &block)
    self.each_with_index.inject(initial, &block)
  end 

  def trim
    self.reject { |v| v.empty? }
  end 
end

