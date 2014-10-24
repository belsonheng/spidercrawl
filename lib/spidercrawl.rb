require "spidercrawl/spider_worker"

class Spiderman
  def self.shoot(urls)
	spiderman = Spidercrawl::SpiderWorker.new(urls)
	spiderman.crawl
  end

  def self.before_spider_crawl(&block)
  
  end

  def self.after_spider_crawl(&block)

  end

  def self.on()

  end
end
