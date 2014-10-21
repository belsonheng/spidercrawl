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
        page = spider_worker.fetch
        if page.success? then
          pages << page
          page.internal_links.each { |link| link_queue << link if !visited_links.include?(link) && link =~ @pattern }
        elsif page.redirect? then
          puts "**redirect to #{page.location}"
          spider_worker.url = page.location
          spider_worker.fetch
        elsif page.not_found? then
          puts "page not found"
        end
      end until link_queue.empty?
    end
  end
end