require 'nokogiri'

module Spidercrawl
  # Parses the content with Nokogiri
  class Page

	def initialize(url, options = {})
	  @url = url
	  @code = options[:response_code]
	  @headers = options[:response_head]
	  @location = options[:redirect_url]
	  @body = options[:response_body]
	  @time = options[:response_time]
	end

	def url
	  url.to_s
	end

	def scheme
	  url.scheme
	end

	def host
	  url.host
	end

	def base_url
	  @base_url = "#{url.scheme}://#{url.host}"
	end

	#
	# Return Nokogiri html document
	#
	def doc
	  @document = Nokogiri::HTML(body)
	rescue Exception => e
	  puts e.inspect
	  puts e.backtrace
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
	  @links = doc.css('a').map { |link| link['href'].to_s }.uniq.delete_if { |href| href.empty? }.map { |link| absolutify(link) }
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

	def images
	end

	def content_type
	end

	def redirect?
	  (300..307).include?(code)
	end

	def success?
	  code == 200
	end

	def not_found?
	  code == 404
	end

	#
	# Return the absolute url
	#
	private
	def absolutify(page_url)
	  return page_url if URI(page_url.split('?')[0]).absolute?
	  URI.join(base_url, page_url).to_s
	end
  end
end