require 'rubygems'
require 'sinatra'
require 'chronic'
require 'date'

module TimeAPI
  PST = -8
  MST = -7
  CST = -6
  EST = -5
  PDT = -7
  MDT = -6
  CDT = -5
  EDT = -4
  UTC = 0
  GMT = 0
  
  class App < Sinatra::Default
  
    set :sessions, false
    set :run, false
    set :environment, ENV['RACK_ENV']
  
    get '/' do
      erb :index
    end
    
    get '/favicon.ico' do
      ''
    end
    
    get '/:zone' do
      zone = params[:zone].upcase
      offset = TimeAPI::const_get(zone)
      
      Time.new.utc.to_datetime.new_offset(Rational(offset,24)).to_s
    end
    
    get '/:zone/:time' do
      zone = params[:zone].upcase
      offset = TimeAPI::const_get(zone)
      
      Chronic.parse(
        params[:time], :now=>Time.new.utc
      ).to_datetime.new_offset(Rational(offset,24)).to_s
    end
  
  end
end

class Time
  def to_datetime
    # Convert seconds + microseconds into a fractional number of seconds
    seconds = sec + Rational(usec, 10**6)

    # Convert a UTC offset measured in minutes to one measured in a
    # fraction of a day.
    offset = Rational(utc_offset, 60 * 60 * 24)
    DateTime.new(year, month, day, hour, min, seconds, offset)
  end
end