require_relative 'magic_framework/server'
require_relative 'magic_framework/constants'
require_relative 'magic_framework/util'
require_relative 'magic_framework/app'
require 'singleton'
include Constants

def params
  MagicFramework::App.instance.params
end 

def get(path, &blk)
  matcher = MagicFramework.route_matcher path
  MagicFramework::App.instance.routes[matcher] = ['GET', blk]
end 

def set(opts)
  MagicFramework::App.instance.opts.update opts
end 

app = Rack::Builder.new do 
  use Rack::CommonLogger
  run MagicFramework::App.instance
end 

at_exit { MagicFramework::Server.new(app).start }
