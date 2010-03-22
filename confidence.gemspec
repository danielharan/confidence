require 'lib/confidence'

Gem::Specification.new do |s|
  s.name                = "confidence"
  s.summary             = "MP voting record scraper"
  s.description         = "MP voting record scraper."
  s.authors             = %w( chebuctonian mynyml )
  s.require_path        = "lib"
  s.version             =  Confidence::VERSION
  s.files               =  File.read("Manifest").strip.split("\n")

  s.add_development_dependency 'minitest'
end
