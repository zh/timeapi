require 'rubygems'
require 'sinatra'
require 'chronic'
require 'date'
require 'cgi'
require 'json'
require 'active_support/time'

ENV['RACK_ENV'] ||= "development"
ENV['TIMEAPI_MIME'] ||= "text/plain"

module TimeAPI
  
  class App < Sinatra::Base
 
    configure do 
      disable :sessions
      set :environment, ENV['RACK_ENV']
    end

    helpers do
      ZoneOffset = {
        'A' => +1,
        'ADT' => -3,
        'AKDT' => -8,
        'AKST' => -9,
        'AST' => -4,
        'B' => +2,
        'BST' => +1,
        'C' => +3,
        'CDT' => -5,
        'CEDT' => +2,
        'CEST' => +2,
        'CET' => +1,
        'CST' => -6,
        'D' => +4,
        'E' => +5,
        'EDT' => -4,
        'EEDT' => +3,
        'EEST' => +3,
        'EET' => +2,
        'EST' => 'EST',
        'F' => +6,
        'G' => +7,
        'GMT' => 'GMT',
        'H' => +8,
        'HADT' => -9,
        'HAST' => -10,
        'I' => +9,
        'IST' => +1,
        'JST' => +9,
        'K' => +10,
        'L' => +11,
        'M' => +12,
        'MDT' => -6,
        'MSD' => +4,
        'MSK' => +3,
        'MST' => -7,
        'N' => -1,
        'O' => -2,
        'P' => -3,
        'PDT' => -7,
        'PST' => -8,
        'Q' => -4,
        'R' => -5,
        'S' => -6,
        'T' => -7,
        'U' => -8,
        'UTC' => 'UTC',
        'V' => -9,
        'W' => -10,
        'WEDT' => +1,
        'WEST' => +1,
        'WET' => 0,
        'X' => -11,
        'Y' => -12,
        'Z' => 0
      }

      def callback
        (request.params['callback'] || '').gsub(/[^a-zA-Z0-9_]/, '')
      end
	
      def prefers_json?
        (request.accept.first || '').downcase == 'application/json'
      end
  
      def json?
        prefers_json? \
          || /\.json$/.match((params[:zone] || '').downcase) \
          || /\.json$/.match((params[:time] || '').downcase)
      end
	
      def jsonp?
        json? && !callback.empty?
      end

      def format
        format = (request.params.select { |k,v| v.empty? }.first || [nil]).first \
          || request.params['format'] \
          || (jsonp? ? '%B %d, %Y %H:%M:%S GMT%z' : '')
        CGI.unescape(format).gsub('\\', '%')
      end

      def parse(zone='UTC', time='now')
        zone = zone.gsub(/\.json$/, '').upcase
        offset = ZoneOffset[zone] || Integer(zone)
        time = time \
          .gsub(/\.json$/, '') \
          .gsub(/^at /, '') \
          .gsub(/(\d)h/, '\1 hours') \
          .gsub(/(\d)min/, '\1 minutes') \
          .gsub(/(\d)m/, '\1 minutes') \
          .gsub(/(\d)sec/, '\1 seconds') \
          .gsub(/(\d)s/, '\1 seconds')
      
        if json?
          response.headers['Content-Type'] = 'application/json'
        else
          response.headers['Content-Type'] = ENV['TIMEAPI_MIME']
        end

        fmt = format.empty? ? "%Y-%m-%d %H:%M:%S %Z" : format
        time = Chronic.parse(CGI.unescape(time))
        time = DateTime.parse((time ? time : Time.now).in_time_zone(offset).to_s).strftime(fmt)
        time = json? ? { 'dateString' => time }.to_json : time
        time = jsonp? ? callback + '(' + time + ');' : time
        time
      end
    end  
  
    get '/' do
      erb :index
    end

    get '/favicon.ico' do
      ''
    end

    post '/' do
      throw :halt, [400, "Bad request, missing 'dt' parameter"] unless params[:dt]
      parse(params[:zone], params[:dt])
    end

    get '/:zone/?' do
      parse(params[:zone])
    end
    
    get '/:zone/:time/?' do
      parse(params[:zone], params[:time])
    end
  
    # start the server if ruby file executed directly
    run! if app_file == $0  
  end
end
