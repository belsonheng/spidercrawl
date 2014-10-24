require 'spidercrawl'

pages = Spiderman.shoot('http://forums.hardwarezone.com.sg/hwm-magazine-publication-38/')

pages.each do |page| 
	puts "#{page.url}"
	puts "Images #{page.images}"
	puts "Emails #{page.emails}"
	puts "Header #{page.headers}"
end

