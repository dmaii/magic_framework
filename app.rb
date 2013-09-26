require_relative 'magic_framework'

get '/' do
  'Hello, World!'
end

get '/:something/:boo/adsf' do 
  puts params
  params[:something]
end 
