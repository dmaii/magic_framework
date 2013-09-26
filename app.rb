require_relative 'magic_framework'

get '/' do
  'Hello, World!'
end

get '/:something/:boo/adsf' do 
  puts params
  params[:something]
end 

get '/splatthis/*/*' do
  params[:splat][0] << 'boo' << params[:splat][1]
end 

get '/splatthis/*.*' do
  params[:splat].to_s
end 
