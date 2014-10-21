require 'spidercrawl'

pages = Spiderman.shoot('http://forums.hardwarezone.com.sg/hwm-magazine-publication-38/')

pages.each do |page| 
	puts "#{page.url}"
	puts "Title #{page.title}"
	puts "Header #{page.headers}"
end

