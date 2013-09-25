require_relative 'magic_framework'

get '/' do
  'Hello, World!'
end

get '/:something' do 
  puts params
  params[:something]
end 
