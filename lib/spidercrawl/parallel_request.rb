require 'spidercrawl/page'
require 'spidercrawl/user_agents'
require 'curb'

module Spidercrawl
  # Makes the request to the targeted website
  class ParallelRequest

    attr_accessor :url

    def initialize(url, options = {})
      @url = url
      @threads = options[:threads]
      @timeout = options[:timeout]
    end

    #
    # Fetch a page from the given url
    #
=begin
    def fetch
      puts "fetching #{@url}"
      uri = URI(@url)
      start_time = Time.now
      begin
        request = Typhoeus::Request.new(url, :timeout => @timeout, :follow_location => true, :user_agent => UserAgents.random)

        request.on_complete do |response|
          end_time = Time.now
          if response.success?
            page = Page.new(uri, response_code: response.code.to_i,
                                 response_head: response.instance_variable_get("@header"),
                                 response_body: response.body,
                                 response_time: ((end_time-start_time)*1000).round,
                                 crawled_time: (Time.now.to_f*1000).to_i)
          elsif (300..307).include?(response.code.to_i)
            page = Page.new(uri, response_code: response.code.to_i,
                                 response_head: response.instance_variable_get("@header"),
                                 response_body: response.body,
                                 response_time: ((end_time-start_time)*1000).round,
                                 redirect_url:  response['location'])
          elsif 404 == response.code.to_i
            page = Page.new(uri, response_code: response.code.to_i,
                                 response_time: ((end_time-start_time)*1000).round)
          end
          @hydra.queue request
        end
      end
=end

    def fetch_pages(urls)
      request = Curl::Multi.new
      urls.each do |url|
        c = Curl::Easy.new(url) do |curl|
          
          curl.on_success do |response|
            puts "easy: #{response.code}"
          end

          curl.on_redirect do |response|
            puts "redirect #{response.code}"
          end

          curl.on_missing do |easy|

          end
        end
        request.add(c)
      end
      request.perform
    end
  end
end