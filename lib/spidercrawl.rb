require "spidercrawl/spider_worker"

class Spiderman
  def self.shoot(urls, options, &block)
	spiderman = Spidercrawl::SpiderWorker.new(urls, options)
	block.call(spiderman)
	spiderman.crawl
  end
end
