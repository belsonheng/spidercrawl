require "spidercrawl/spider_worker"

module Spidercrawl
  class Spidercrawl
  	def self.start(urls)
  	  spiderman = SpiderWorker.new(urls, allow_redirections: false)
  	  spiderman.crawl
  	end
  end
end
