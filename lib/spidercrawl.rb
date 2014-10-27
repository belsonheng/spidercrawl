require "spidercrawl/spider_worker"

class Spiderman
  def self.shoot(urls, options, &block)
	spiderman = Spidercrawl::SpiderWorker.new(urls, options)
	yield spiderman if block_given?
	spiderman.crawl
  end
end
