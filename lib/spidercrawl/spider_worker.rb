require 'spidercrawl/request'
require 'spidercrawl/page'
require 'colorize'

module Spidercrawl
  # Start working hard
  class SpiderWorker

    attr_reader :page

    def initialize(url, options = {})
      @url = url
      #@headers = options[:headers]
      @delay = options[:delay] ? options[:delay] : 0 # default 0 seconds
      @threads = options[:threads] ? options[:threads] : 10 # default 10 threads
      @timeout = options[:timeout] ? options[:timeout] : 20 # default 20 seconds
      @allow_redirections = options[:allow_redirections]
      @max_pages = options[:max_pages]
      @pattern = options[:pattern]
      @setup = nil
      @teardown = nil
      @redirect = nil
      @success = nil
      @failure = nil
    end

    def crawl
      link_queue = Queue.new
      pages, visited_links = [], []
      link_queue << @url

      spider_worker = Request.new(@url, :threads => @threads, :timeout => @timeout)

      begin
        url = link_queue.pop
        next if visited_links.include?(url) 
        next if (@pattern && url !~ @pattern)
        visited_links << url
        spider_worker.uri = URI.parse(url)

        start_time = Time.now
        response = @setup.yield url unless @setup.nil?
        end_time = Time.now

        page = (response ? setup_page(URI.parse(url), response, ((end_time - start_time).to_f*1000).to_i) : spider_worker.curl)

        if page.success? || page.redirect? then
          while page.redirect?
            puts ("### redirect to #{page.location}" + (visited_links.include?(page.location) ? " which we have already visited!" : "")).white.on_black
            break if visited_links.include?(page.location)
            
            start_time = Time.now
            response = @redirect.yield page.location unless @redirect.nil?
            end_time = Time.now

            spider_worker.uri = URI.parse(page.location)
            page = (response ? setup_page(URI.parse(page.location), response, ((end_time - start_time).to_f*1000).to_i) : spider_worker.curl)
            visited_links << page.url
          end
          unless visited_links.include?(page.location)
            pages << page unless page.content == ""
            page.internal_links.each do |link| 
              if !visited_links.include?(link) 
                if @pattern
                  link_queue << link if link =~ @pattern
                else
                  link_queue << link
                end
              end
            end rescue nil
            @teardown.yield page unless @teardown.nil?
            sleep @delay
          end
        elsif page.not_found? then
          puts "page not found"
        end
      end until link_queue.empty?
      pages
    end

    def parallel_crawl
      link_queue = Queue.new
      pages, visited_links = [], []
      link_queue << @url

      spider_workers = ParallelRequest.new([@url], :threads => @threads, :timeout => @timeout)

      begin
        urls = []
        while !link_queue.empty?
          url = link_queue.pop
          next if visited_links.include?(url) || (@pattern && url !~ @pattern)
          visited_links << url

          start_time = Time.now
          response = @setup.yield url unless @setup.nil?
          end_time = Time.now
          
          if response then
            pages << (page = setup_page(URI.parse(url), response, ((end_time - start_time).to_f*1000).to_i))
            @teardown.yield page unless @teardown.nil?

            page.internal_links.each do |link| # queue up internal links for crawling 
              if !visited_links.include?(link) 
                if @pattern
                  link_queue << link if link =~ @pattern
                else
                  link_queue << link
                end
              end
            end unless page.internal_links.nil?
          else # queue up url for crawling 
            urls << url
            puts "queue: #{url}"
          end
        end

        spider_workers.urls = urls
        responses = spider_workers.fetch

        responses.each do |page|
          if (503..504).include?(page.response_code) then
            link_queue << page.url
          elsif page.success? || page.redirect? then
            response = nil
            if page.redirect? then
              puts ("### redirect to #{page.location}" + (visited_links.include?(page.location) ? " which we have already visited!" : "")).white.on_black
              unless visited_links.include?(page.location) || (@pattern && page.location !~ @pattern)
                start_time = Time.now
                response = @redirect.yield page.location unless @redirect.nil?
                end_time = Time.now

                if response then
                  page = setup_page(URI.parse(page.location), response, ((end_time - start_time).to_f*1000).to_i)
                  visited_links << page.url        
                else
                  puts "queue: #{page.location}"
                  link_queue << page.location
                end
              else
                puts "discard: #{page.location}"
              end
            end
            if page.success? || response then
              pages << page unless page.content == ""

              page.internal_links.each do |link| # queue up internal links for crawling
                if !visited_links.include?(link) 
                  if @pattern
                    link_queue << link if link =~ @pattern
                  else
                    link_queue << link
                  end
                end
              end unless page.internal_links.nil?
              page.crawled_time = (Time.now.to_f*1000).to_i
              @teardown.yield page unless @teardown.nil?
            end
          elsif page.not_found? then
            puts "page not found"
          end
        end
      end until link_queue.empty?
      pages
    end

    #
    # Code block for before fetch
    #
    def before_fetch(&block)
      @setup = block if block
    end

    #
    # Code block for after fetch
    #
    def after_fetch(&block)
      @teardown = block if block
    end

    #
    # Code block for on redirect
    #
    def on_redirect(&block)
      @redirect = block if block
    end

    #
    # Code block for on success
    #
    def on_success(&block)
      @success = block if block
    end

    #
    # Code block for on failure
    #
    def on_failure(&block)
      @failure = block if block
    end

    #
    # Setup page based on given response
    #
    private
    def setup_page(uri, response, response_time)
      page = Page.new(uri, response_code: response.code.to_i,
                           response_head: response.instance_variable_get("@header"),
                           response_body: response.body,
                           response_time: response_time,
                           crawled_time: (Time.now.to_f*1000).to_i)
    end
  end
end
