require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :console do
  require 'irb'
  require 'irb/completion'
  require 'chatterbot' # You know what to do.
  ARGV.clear
  IRB.start
end
