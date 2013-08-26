# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "ffmpeg/version"

Gem::Specification.new do |s|
  s.name        = "ruby-ffmpeg"
  s.version     = FFMPEG::VERSION
  s.authors     = ["David Backeus (Original-Streamio-ffmpeg)", "Omkiran Sharma (ruby-ffmpeg)"]
  s.email       = ["david@streamio.com", "mail.av501@gmail.com"]
  s.homepage    = "http://github.com/av501/ffmpeg"
  s.summary     = "Wraps ffmpeg to read metadata and transcodes videos."
  
  s.add_development_dependency("rspec", "~> 2.7")
  s.add_development_dependency("rake", "~> 10.0")

  s.files        = Dir.glob("lib/**/*") + %w(README.md LICENSE CHANGELOG)
end
