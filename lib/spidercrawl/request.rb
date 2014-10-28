require 'spidercrawl/page'
require 'spidercrawl/user_agents'
require 'net/http'
require 'typhoeus'

module Spidercrawl
  # Makes the request to the targeted website
  class Request

    attr_accessor :url

    def initialize(url, options = {})
      @url = url
      @threads = options[:threads]
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
                                 response_time: ((end_time-start_time)*1000).round,
                                 crawled_time: (Time.now.to_f*1000).to_i)
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
  # Makes parallel requests to the targeted website using typhoeus and hydra
  class ParallelRequest
    
    def initialize(urls, options = {})
      @urls = urls
      @threads = options[:threads]
      @timeout = options[:timeout]
    end

    #
    # Fetch page(s) from the given url(s)
    #
    def fetch
      hydra = Typhoeus::Hydra.new(:max_concurrency => @threads)

      @urls.each do |url|
        puts "fetching #{url}"
        request = Typhoeus::Request.new(url, :timeout => @timeout, :follow_location => false, :headers => {"User-Agent" => UserAgents.random})
        request.on_headers do |response|
          puts "Success: #{url}" if response.success?
          puts "Redirect: #{response.headers['Location']}" if (300..307).include?(response.code)
        end
        hydra.queue(request)
      end

      hydra.run
    end
  end
end