require_relative 'server'

module MagicFramework
  class App
    def call(env)
      [200, {'Content-Type' => 'text/plain'}, ['I will be a big strong app someday!']]
    end 
  end 
end 

MagicFramework::Server.new(MagicFramework::App.new).start
