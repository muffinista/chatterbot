# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

#$:.push File.expand_path("../lib", __FILE__)
require "chatterbot/version"

Gem::Specification.new do |s|
  s.name = %q{chatterbot}
  s.version     = Chatterbot::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ["Colin Mitchell"]
  s.email = %q{colin@muffinlabs.com}
  s.homepage = %q{http://github.com/muffinista/chatterbot}
  s.summary = %q{A ruby framework for writing Twitter bots}
  s.description = %q{A ruby framework for writing bots that run on Twitter. Comes with a simple DSL for easy coding.}

  s.rubyforge_project = "chatterbot"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.licenses = ["MIT"]

  # load activesupport but check ruby version along the way
  s.extensions << 'ext/mkrf_conf.rb'
  
  s.add_runtime_dependency(%q<oauth>, ["~> 0.4.7"])
  s.add_runtime_dependency(%q<twitter>, ["~> 6.2.0"])
  s.add_runtime_dependency(%q<launchy>, [">= 2.4.2"])
  s.add_runtime_dependency(%q<colorize>, [">= 0.7.3"])

  s.add_development_dependency 'bundler', '~> 1.0'
end

