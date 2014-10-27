require 'spidercrawl/page'
require 'net/http'

module Spidercrawl
  # Makes the request to the targeted website
  class Request

    attr_accessor :url

    def initialize(url, options = {})
      @url = url
      @timeout = options[:timeout]
    end

    #
    # Fetch a page from the given url
    #
    def fetch
      puts "fetching #{@url}"
      uri = URI(@url)
      start_time = Time.now
      begin
        Net::HTTP.start(uri.host, uri.port) do |http|
          http.open_timeout = @timeout # in seconds
          http.read_timeout = @timeout # in seconds
          response = http.get(uri)
          end_time = Time.now
          case response
          when Net::HTTPSuccess then
            page = Page.new(uri, response_code: response.code.to_i,
                                 response_head: response.instance_variable_get("@header"),
                                 response_body: response.body,
                                 response_time: ((end_time-start_time)*1000).round)
          when Net::HTTPRedirection then
            page = Page.new(uri, response_code: response.code.to_i,
                                 response_head: response.instance_variable_get("@header"),
                                 response_body: response.body,
                                 response_time: ((end_time-start_time)*1000).round,
                                 redirect_url:  response['location'])
          when Net::HTTPNotFound then
            page = Page.new(uri, response_code: response.code.to_i,
                                 response_time: ((end_time-start_time)*1000).round)
          end
        end
      rescue Exception => e
        puts e.inspect
        puts e.backtrace
      end
    end
  end
end