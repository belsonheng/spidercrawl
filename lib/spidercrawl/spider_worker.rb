require 'spidercrawl/request'
require 'spidercrawl/page'

module Spidercrawl
  # Start working hard
  class SpiderWorker

    attr_reader :page

    def initialize(url, options = {})
      @url = url
      #@headers = options[:headers]
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
      begin
        url = link_queue.pop
        next if visited_links.include?(url) || url !~ @pattern
        visited_links << url
        spider_worker = Request.new(url, :timeout => @timeout)
        response = @setup.yield url unless @setup.nil?
        page = (response ? process_page(URI(url), response) : spider_worker.fetch)
        if page.success? || page.redirect? then
          while page.redirect?
            puts "**redirect to #{page.location}" + (visited_links.include?(page.location) ? " which we have already visited!" : "")
            break if visited_links.include?(page.location)
            visited_links << (spider_worker.url = page.location)
            page = spider_worker.fetch
          end
          pages << page
          page.internal_links.each { |link| link_queue << link if !visited_links.include?(link) && link =~ @pattern }
        elsif page.not_found? then
          puts "page not found"
        end
        @teardown.yield url, page unless @teardown.nil?
      end until link_queue.empty?
      pages
    end

    def before_fetch(&block)
      @setup = block if block
    end

    def after_fetch(&block)
      @teardown = block if block
    end

    def on()
      # TODO :success, :failure, :redirect
    end

    private
    def process_page(uri, response)
      page = Page.new(uri, response_code: response.code.to_i,
                           response_head: response.instance_variable_get("@header"),
                           response_body: response.body
                           crawled_time: (Time.now.to_f*1000).to_i)
    end
  end
end