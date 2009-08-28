require 'rubygems'
require 'sinatra'
require 'chronic'

module TimeAPI

  class App < Sinatra::Default
  
    set :sessions, false
    set :run, false
    set :environment, ENV['RACK_ENV']
  
    get '/' do
      erb :form
    end
    
    # Main hub endpoint for both publisher and subscribers
    post '/' do
      throw :halt, [400, "Bad request, missing 'dt' parameter"] unless params['dt']
      Chronic.parse(params['dt']).to_s
    end
  
  end
end
