require 'bundler'
Bundler::GemHelper.install_tasks

require "chatterbot/version"

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov_opts = %w{--exclude .bundler,.rvm}
  spec.rcov = true
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "'chatterbot #{Chatterbot::VERSION}'"
end

task :console do
  require 'irb'
  require 'irb/completion'
  require 'chatterbot' # You know what to do.
  ARGV.clear
  IRB.start
end
