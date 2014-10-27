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

## Future TODO

1. include asynchronous fetch using [Typhoeus](https://github.com/typhoeus/typhoeus)
2. use peach for parallel each
3. run benchmark test
4. robotex to obey robots rule
5. redis-bloomfilter for checking visited urls

## Dependencies

Nokogiri 1.6          # For parsing html files

## Contributing

1. Fork it ( https://github.com/belsonheng/spidercrawl/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

SpiderCrawl is released under the [MIT license](https://github.com/belsonheng/spidercrawl/blob/master/LICENSE.txt).
