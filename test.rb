require_relative 'magic_framework'

get '/' do
  'Hello, World!'
end

get '/:something' do
  'something here'
end 

puts MagicFramework::map_route('/adsf/:bb/adsf')
