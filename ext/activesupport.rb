require 'rubygems/dependency_installer'

#
# limit activesupport version if not on ruby 2.2 or higher
# @see https://www.tiredpixel.com/2014/01/05/curses-conditional-ruby-gem-installation-within-a-gemspec/
#

di = Gem::DependencyInstaller.new

begin
  if RUBY_VERSION >= '2.2'
    di.install "activesupport"
  else
    di.install "activesupport", "< 5.0.0"
  end
rescue => e
  warn "#{$0}: #{e}"

  exit!
end
