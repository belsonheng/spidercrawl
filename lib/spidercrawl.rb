require "spidercrawl/spider_worker"

class Spiderman
  def self.shoot(urls)
	spiderman = Spidercrawl::SpiderWorker.new(urls)
	#block.call(spiderman)
	spiderman.crawl
  end
end
