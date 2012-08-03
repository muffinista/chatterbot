# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "chatterbot/version"

Gem::Specification.new do |s|
  s.name = %q{chatterbot}
  s.version     = Chatterbot::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ["Colin Mitchell"]
  s.email = %q{colin@muffinlabs.com}
  s.homepage = %q{http://github.com/muffinista/chatterbot}
  s.summary = %q{A framework for writing Twitter bots}
  s.description = %q{A framework for writing bots that run on Twitter. Comes with a simple DSL for easy coding.}

  s.rubyforge_project = "chatterbot"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.licenses = ["WTFDBAL"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      #      s.add_runtime_dependency(%q<twitter_oauth>, [">= 0"])
      s.add_runtime_dependency(%q<oauth>, [">= 0"])
      s.add_runtime_dependency(%q<twitter>, [">= 3.4.1"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<watchr>, [">= 0"])
    else
      s.add_dependency(%q<twitter>, [">= 3.4.1"])
      s.add_dependency(%q<oauth>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rdoc>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<watchr>, [">= 0"])
    end
  else
    s.add_dependency(%q<twitter>, [">= 3.4.1"])
    s.add_dependency(%q<oauth>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rdoc>, [">= 0"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<watchr>, [">= 0"])
  end
end

