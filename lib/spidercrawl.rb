require "spidercrawl/spider_worker"

class Spiderman
  def self.shoot(urls, options, &block)
    spiderman = Spidercrawl::SpiderWorker.new(urls, options)
    yield spiderman if block_given?
    return spiderman.parallel_crawl if options[:parallel] == true
    return spiderman.crawl unless options[:parallel]
  end
end
