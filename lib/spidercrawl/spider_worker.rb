require 'spidercrawl/request'
require 'spidercrawl/page'
require 'colorize'

module Spidercrawl
  # Start working hard
  class SpiderWorker

    attr_reader :page

    def initialize(url, options = {})
      @url = url
      #@headers = options[:headers]
      @delay = options[:delay] ? options[:delay] : 0 # default 0 seconds
      @threads = options[:threads] ? options[:threads] : 10 # default 10 seconds
      @timeout = options[:timeout] ? options[:timeout] : 20 # default 20 seconds
      @allow_redirections = options[:allow_redirections]
      @max_pages = options[:max_pages]
      @pattern = options[:pattern]
      @setup = nil
      @teardown = nil
    end

    def crawl
      link_queue = Queue.new
      pages, visited_links = [], []
      link_queue << @url

      spider_worker = Request.new(@url, :threads => @threads, :timeout => @timeout)
      begin
        url = link_queue.pop
        next if visited_links.include?(url) || url !~ @pattern
        visited_links << url
        spider_worker.uri = URI.parse(url)

        response = @setup.yield url unless @setup.nil?
        page = (response ? setup_page(URI(url), response) : spider_worker.fetch)

        if page.success? || page.redirect? then
          while page.redirect?
            puts ("**redirect to #{page.location}" + (visited_links.include?(page.location) ? " which we have already visited!" : "")).yellow.on_black
            break if visited_links.include?(page.location)
            visited_links << (spider_worker.uri = URI.parse(page.location))
            page = spider_worker.fetch
          end
          pages << page
          page.internal_links.each { |link| link_queue << link if !visited_links.include?(link) && link =~ @pattern }
        elsif page.not_found? then
          puts "page not found"
        end
        @teardown.yield urls, page unless @teardown.nil?
        sleep @delay
      end until link_queue.empty?
      puts "Total pages crawled: #{visited_links.size}"
      pages
    end

    #
    # Code block for before fetch
    #
    def before_fetch(&block)
      @setup = block if block
    end

    #
    # Code block for after fetch
    #
    def after_fetch(&block)
      @teardown = block if block
    end

    def on()
      # TODO :success, :failure, :redirect
    end

    #
    # Setup page based on given response
    #
    private
    def setup_page(uri, response)
      page = Page.new(uri, response_code: response.code.to_i,
                           response_head: response.instance_variable_get("@header"),
                           response_body: response.body,
                           crawled_time: (Time.now.to_f*1000).to_i)
    end
  end
end