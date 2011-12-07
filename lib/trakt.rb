require 'typhoeus'
require 'yajl'
require 'date'

module Trakt

  def self.base_url
    "http://api.trakt.tv"
  end

  class << self
    attr_accessor  :username, :password, :api_key, :utc_offset
  end

  class Base
    attr_accessor :results

    def initialize()
      self.results = request
    end

    def base_url
      Trakt::base_url
    end

    def request
      response = Typhoeus::Request.get(url)
      parser = Yajl::Parser.new
      parser.parse(response.body)
    end
  end

  module User

    class Calendar < Trakt::Base

     def url
        unless Trakt::utc_offset.nil? 
          if Trakt::utc_offset < 0
            date = Date.parse((Time.now + ((Trakt::utc_offset.to_i*-1)*60)).to_s).to_s
          else
            date = Date.parse((Time.now - ((Trakt::utc_offset.to_i)*60)).to_s).to_s
          end
        else 
          date = Date.today
        end
        puts "Date: #{date}"
        "#{base_url}/user/calendar/shows.json/#{Trakt::api_key}/#{Trakt::username}/#{date}/1"
      end

    end

  end

end
