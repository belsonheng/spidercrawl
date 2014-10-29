require "spidercrawl/spider_worker"

class Spiderman
  def self.shoot(urls, options, &block)
    spiderman = Spidercrawl::SpiderWorker.new(urls, options)
    yield spiderman if block_given?
    spiderman.parallel_crawl if options[:parallel] == true
    spiderman.crawl if options[:parallel] == false
  end
end
