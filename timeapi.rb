require 'rubygems'
require 'sinatra'
require 'chronic'

module TimeAPI
  PST = -8
  MST = -7
  CST = -6
  EST = -5
  PDT = -7
  MDT = -6
  CDT = -5
  EDT = -4
  
  class App < Sinatra::Default
  
    set :sessions, false
    set :run, false
    set :environment, ENV['RACK_ENV']
  
    get '/' do
      erb :index
    end
    
    # Main hub endpoint for both publisher and subscribers
    get '/:zone' do
      zone = params[:zone].upcase
      offset = TimeAPI::const_get(zone) * 60 * 60
      
      (Time.now.utc + offset).to_s.gsub('UTC',zone)
    end
    
    get '/:zone/:time' do
      zone = params[:zone].upcase
      offset = TimeAPI::const_get(zone) * 60 * 60
      
      Chronic.parse(params[:time], :now=>Time.now.utc + offset).to_s.gsub('UTC',zone)
    end
  
  end
end

TimeAPI::App.run!