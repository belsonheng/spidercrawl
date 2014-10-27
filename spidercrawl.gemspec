# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spidercrawl/version'

Gem::Specification.new do |spec|
  spec.name          = "spidercrawl"
  spec.version       = Spidercrawl::VERSION
  spec.authors       = ["Belson Heng"]
  spec.email         = ["belsonheng@gmail.com"]
  spec.summary       = %q{A ruby gem that can crawl a domain and let you have information about the pages it visits.}
  spec.description   = %q{With the help of Nokogiri, SpiderCrawl will parse each page and return you its title, links, css, words, and many many more! You can also customize what you want to do before & after each fetch request.}
  spec.homepage      = "http://github.com/belsonheng/spidercrawl"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'nokogiri', '~> 1.6'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
