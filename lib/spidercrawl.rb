require "spidercrawl/spider_worker"

module Spidercrawl
  class Spiderman
  	def self.start(urls)
  	  spiderman = SpiderWorker.new(urls, allow_redirections: false)
  	  spiderman.crawl
  	end
  end
end
