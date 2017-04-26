require 'rubygems/dependency_installer'

#
# limit activesupport version if not on ruby 2.2 or higher
# @see https://www.tiredpixel.com/2014/01/05/curses-conditional-ruby-gem-installation-within-a-gemspec/
#

di = Gem::DependencyInstaller.new

begin
  if RUBY_VERSION >= '2.2'
    di.install "activesupport", "~> 4.2.8"
  else
    di.install "activesupport", "< 5.0.0"
  end
rescue => e
  warn "#{$0}: #{e}"

  exit!
end


# https://en.wikibooks.org/wiki/Ruby_Programming/RubyGems#How_to_install_different_versions_of_gems_depending_on_which_version_of_ruby_the_installee_is_using

# create dummy rakefile to indicate success
f = File.open(File.join(File.dirname(__FILE__), "Rakefile"), "w")
f.write("task :default\n")
f.close
