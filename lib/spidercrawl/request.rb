require 'spidercrawl/page'
require 'spidercrawl/user_agents'
require 'net/http'
require 'curb'
require 'colorize'
require 'typhoeus'

module Spidercrawl
  # Makes the request to the targeted website
  class Request

    attr_accessor :uri

    def initialize(url, options = {})
      @uri = URI.parse(url)
      @threads = options[:threads]
      @timeout = options[:timeout]

      @http = Net::HTTP.new(@uri.host, @uri.port) do |http|
        http.open_timeout = @timeout # in seconds
        http.read_timeout = @timeout # in seconds
      end

      @c = Curl::Easy.new(@uri.to_s) do |curl|
        curl.headers['User-Agent'] = UserAgents.random
      end
    end

    #
    # Fetch a page from the given url using libcurl
    #
    def curl
      puts "fetching #{@uri.to_s}".green.on_black
      start_time = Time.now
      begin
        c = @c
        c.url = @uri.to_s
        c.perform
        end_time = Time.now
        case c.response_code
        when 200 then
          page = Page.new(@uri, response_code: c.response_code,
                                response_head: c.header_str,
                                response_body: c.body_str,
                                response_time: ((end_time-start_time)*1000).round,
                                crawled_time: (Time.now.to_f*1000).to_i)
        when 300..307 then
          page = Page.new(@uri, response_code: c.response_code,
                                response_head: c.header_str,
                                response_body: c.body_str,
                                response_time: ((end_time-start_time)*1000).round,
                                redirect_url:  c.redirect_url)
        when 404 then
          page = Page.new(@uri, response_code: c.response_code,
                                response_time: ((end_time-start_time)*1000).round)
        end
      rescue Exception => e
        puts e.inspect
        puts e.backtrace
      end
    end

    #
    # Fetch a page from the given url using net/http
    #
    def fetch
      puts "fetching #{@uri.to_s}".green.on_black
      start_time = Time.now
      begin
        request = Net::HTTP::Get.new(@uri.request_uri)
        request["User-Agent"] = UserAgents.random
        response = @http.request(request) 
        end_time = Time.now
        case response
        when Net::HTTPSuccess then
          page = Page.new(@uri, response_code: response.code.to_i,
                                response_head: response.instance_variable_get("@header"),
                                response_body: response.body,
                                response_time: (end_time-start_time).to_f,
                                crawled_time: (Time.now.to_f*1000).to_i)
        when Net::HTTPRedirection then
          page = Page.new(@uri, response_code: response.code.to_i,
                                response_head: response.instance_variable_get("@header"),
                                response_body: response.body,
                                response_time: (end_time-start_time).to_f,
                                redirect_url:  response['location'])
        when Net::HTTPNotFound then
          page = Page.new(@uri, response_code: response.code.to_i,
                                response_time: (end_time-start_time).to_f)
        end
      rescue Exception => e
        puts e.inspect
        puts e.backtrace
      end
    end
  end

  # Makes parallel requests to the targeted website using typhoeus and hydra
  class ParallelRequest
    
    attr_accessor :urls

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
      page, pages = nil, []

      @urls.each do |url|
        request = Typhoeus::Request.new(url, :timeout => @timeout, :followlocation => false, :headers => {"Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "Cache-Control" => "no-cache", "Pragma" => "no-cache", "User-Agent" => UserAgents.random})
        request.on_complete do |response|
          uri = URI(url)
          if response.success?
            puts "fetching #{url}".green.on_black
            page = Page.new(uri, response_code: response.code,
                                 response_head: response.headers,
                                 response_body: response.body,
                                 response_time: response.time*1000,
                                 crawled_time: (Time.now.to_f*1000).to_i)
          elsif (300..307).include?(response.code)
            puts "fetching #{url}".green.on_black
            puts "### #{response.code} ### redirect to #{response.headers['Location']}".white.on_black
            page = Page.new(uri, response_code: response.code,
                                 response_head: response.headers,
                                 response_body: response.body,
                                 response_time: response.time*1000,
                                 redirect_url:  response.headers['Location'])
          elsif 404 == response.code
            puts "fetching #{url}".green.on_black
            puts "### 404 - not found".magenta.on_black
            page = Page.new(uri, response_code: response.code,
                                 response_time: response.time*1000)
          else
            puts "fetching #{url}".green.on_black
            puts "### #{response.code} ### failed #{url}".magenta.on_black
            page = Page.new(uri, response_code: response.code,
                                 response_time: response.time*1000)
          end
          pages << page
        end
        hydra.queue(request)
      end
      hydra.run
      return pages
    end
  end
end