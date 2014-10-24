require 'spidercrawl/request'
require 'spidercrawl/page'

module Spidercrawl
  # Start working hard
  class SpiderWorker

    attr_reader :page

  	def initialize(url, options = {})
  	  @url = url
  	  @headers = options[:headers]
  	  @timeout = options[:timeout]
  	  @allow_redirections = options[:allow_redirections]
  	  @max_pages = options[:max_pages]
  	  @pattern = Regexp.new('^http:\/\/forums\.hardwarezone\.com\.sg\/hwm-magazine-publication-38\/?(.*\.html)?$')
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
        spider_worker = Request.new(url)
        proceed = @setup.call(url) unless @setup.nil?
        page = spider_worker.fetch if proceed
        @after_spider_crawl
        if page.success? || page.redirect? then
          while page.redirect?
            #puts "**redirect to #{page.location}" + (visited_links.include?(page.location) ? " which we have already visited!" : "")
            break if visited_links.include?(page.location)
            visited_links << (spider_worker.url = page.location)
            page = spider_worker.fetch
          end
          pages << page
          page.internal_links.each { |link| link_queue << link if !visited_links.include?(link) && link =~ @pattern }
        elsif page.not_found? then
          puts "page not found"
        end
      end until link_queue.empty?
      pages
    end

    def before_spider_crawl(&block)
      @setup = block if block_given?
    end

    def on_spider_crawl(&block)
      
    end

    def after_spider_crawl(&block)
      @teardown = block if block_given?
    end

    def on()

    end
  end
end