require 'nokogiri'

module Spidercrawl
  # Parses the content with Nokogiri
  class Page

    attr_reader :location, :response_time
    attr_accessor :crawled_time

    def initialize(url, options = {})
      @url = url
      @code = options[:response_code]
      @headers = options[:response_head]
      @location = options[:redirect_url]
      @body = options[:response_body]
      @response_time = options[:response_time]
      @crawled_time = options[:crawled_time]
    end

    #
    # Return the url of the page
    #
    def url
      @url.to_s
    end

    #
    # Return the url scheme of the page (e.g. http, https, etc.)
    #
    def scheme
      @url.scheme
    end

    #
    # Return the url host of the page
    #
    def host
      @url.host
    end

    #
    # Return the base url of the page
    #
    def base_url
      @base_url = "#{scheme}://#{host}"
    end

    #
    # Return the Nokogiri html document
    #
    def doc
      @document = Nokogiri::HTML(@body)
      rescue Exception => e
        puts e.inspect
        puts e.backtrace
    end

    #
    # Return the headers of the page
    #
    def headers
      puts @headers
    end
    
    #
    # Return the title of the page
    #
    def title
      @title = doc.css('head title').inner_text
    end

    #
    # Return the entire links found in the page; exclude empty links
    #
    def links
      @links = doc.css('a').map { |link| link['href'].to_s }.uniq.delete_if { |href| href.empty? }.map { |url| absolutify(url.strip) }
    end

    #
    # Return the internal links found in the page
    #
    def internal_links
      @internal_links = links.select { |link| URI(link).host == host }
    end

    #
    # Return the external links found in the page
    #
    def external_links
      @external_links = links.select { |link| URI(link).host != host }
    end

    #
    # Return any emails found in the page
    #
    def emails
      @body.match(/[\w.!#\$%+-]+@[\w-]+(?:\.[\w-]+)+/)
    end

    #
    # Return all images found in the page
    #
    def images
      @images = doc.css('img').map { |img| img['src'].to_s }.uniq.delete_if { |src| src.empty? }.map { |url| absolutify(url.strip) }
    end

    #
    # Return all words found in the page
    #
    def words
      @words = text.split(/[^a-zA-Z]/).delete_if { |word| word.empty? }
    end

    #
    # Return css scripts of the page
    #
    def css
      @css = doc.search("[@type='text/css']")
    end

    def meta_keywords
    end

    def meta_descriptions
    end

    #
    # Return html content as a string
    #
    def content
      @body.to_s
    end

    #
    # Return the content type of the page
    #
    def content_type
      doc.at("meta[@http-equiv='Content-Type']")['content']
    end

    # 
    # Return plain text of the page without html tags
    #
    def text
      temp_doc = doc
      temp_doc.css('script, noscript, style, link').each { |node| node.remove }
      @text = temp_doc.css('body').text.split("\n").collect { |line| line.strip }.join("\n")
    end

    #
    # Return the response code
    #
    def response_code
      @code
    end

    #
    # Return true if page not found 
    #
    def not_found?
      @code == 404
    end

    #
    # Return true if page is fetched successfully
    #
    def success?
      @code == 200
    end

    #
    # Return true if page is redirected
    #
    def redirect?
      (300..307).include?(@code)
    end

    #
    # Return the absolute url
    #
    private
    def absolutify(page_url)
      return URI.escape(page_url) if page_url =~ /^\w*\:/i
      return base_url + URI.escape(page_url)
    end
  end
end