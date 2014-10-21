require 'nokogiri'

module Spidercrawl
  # Parses the content with Nokogiri
  class Page

    attr_reader :location

	def initialize(url, options = {})
	  @url = url
	  @code = options[:response_code]
	  @headers = options[:response_head]
	  @location = options[:redirect_url]
	  @body = options[:response_body]
	  @time = options[:response_time]
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

    def headers
      @headers['Content-Type']
    end
	#
	# Return the title of the page
	#
	def title
	  @title = doc.css('head title').inner_text rescue nil
	end

	#
	# Return the entire links found in the page; exclude empty links
	#
	def links
	  @links = doc.css('a').map { |link| link['href'].to_s }.uniq.delete_if { |href| href.empty? }.map { |link| absolutify(link) }.uniq
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

    def emails
    end

	def images
	end

	def content_type
	end

    #
    # Return the time taken to fetch the page in ms
    #
    def response_time
      @time
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
	# Return the absolute url without query params, etc.
	#
	private
	def absolutify(page_url)
      page_url = page_url.split('?')[0].split('#')[0]
	  return page_url if URI(page_url).absolute?
	  URI.join(base_url, page_url).to_s
	end
  end
end