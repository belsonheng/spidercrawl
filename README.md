# SpiderCrawl

A ruby gem that can crawl a domain and let you have information about the pages it visits. 

With the help of Nokogiri, SpiderCrawl will parse each page and return you its title, links, css, words, and many many more! You can also customize what you want to do before & after each fetch request.

Long story short - Feed an URL to SpiderCrawl and it will crawl + scrape the content for you. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spidercrawl'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spidercrawl

## Usage

Start crawling a domain by calling __Spiderman.shoot__(*url*) and it will return you a list of pages it has crawled and scraped:

    pages = Spiderman.shoot('http://forums.hardwarezone.com.sg/hwm-magazine-publication-38/')

To include a pattern matching for each page:

    pages = Spiderman.shoot('http://forums.hardwarezone.com.sg/hwm-magazine-publication-38/',
                            :pattern => Regexp.new('^http:\/\/forums\.hardwarezone\.com\.sg\/hwm-magazine-publication-38\/?(.*\.html)?$')

Access the following scraped data:

    pages.each do |page|
      page.url              #URL of the page
      page.scheme           #Scheme of the page (http, https, etc.)
      page.host             #Hostname of the page
      page.base_url         #Root URL of the page
      page.doc              #Nokogiri document
      page.headers          #Response headers for the page
      page.title            #Title of the page
      page.links            #Every link found in the page, returned as an array
      page.internal_links   #Only internal links returned as an array
      page.external_links   #Only external links returned as an array
      page.emails           #Every email found in the page, returned as an array
      page.images           #Every img found in the page, returned as an array
      page.words            #Every word that appeared in the page, returned as an array
      page.css              #CSS scripts used in the page, returned as an array
      page.content          #Contents of the HTML document in string
      page.content_type     #Content type of the page
      page.text             #Any text found in the page without HTML tags
      page.response_code    #HTTP response code of the page
      page.response_time    #HTTP response time of the page
      page.crawled_time     #The time when this page is crawled/fetched, returned as milliseconds since epoch
    end

## TODO
+ Include faraday
+ Replace curb dependency with patron

## Dependencies

+ Colorize
+ Curb
+ Nokogiri
+ Typhoeus

## Contributing

1. Fork it ( https://github.com/belsonheng/spidercrawl/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

SpiderCrawl is released under the [MIT license](https://github.com/belsonheng/spidercrawl/blob/master/LICENSE.txt).
