require 'spidercrawl/fetch'

module Spidercrawl
  # Start working hard
  class SpiderWorker

  	def initialize(url, options = {})
  	  @url = url
  	  @headers = options[:headers]
  	  @timeout = options[:timeout]
  	  @allow_redirections = options[:allow_redirections]
  	  @max_pages = option[:max_pages]
  	  @pattern = Regex.new('^(http)(:)(\\/)(\\/)(forums\\.hardwarezone\\.com\\.sg)(\\/)(hwm)(-)(magazine)(-)(publication)(-)(38)(\\/).*?(\\.)(html)$')
  	  @link_queue = Queue.new
  	  @visited_links = []
  	  @page_count = 0
  	end

  	def crawl
  	  link_queue << url
  	  begin
  	  	url = link_queue.pop
  	    next unless url.match(pattern) && !visited_links.include?(url)
  	    spider_worker = Fetch.new(url)
  	    @page = spider_worker.fetch

  	    if page.success? then
          page_count += 1
	        page.links.each { |link| link_queue << link if link.match(pattern) && !visited_links.include?(link) }
  	    elsif page.redirect? then 
  	  	  puts "redirected to #{page.redirect_url}" if allow_redirections
  	    elsif page.not_found? then
	  	    puts "page not found"
  	    end

  	    break if page_count == max_pages
  	  end until link_queue.empty?
	  end
  end
end