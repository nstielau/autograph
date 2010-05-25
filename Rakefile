require 'rake'
require File.dirname(__FILE__) + '/lib/autograph'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "autograph"
    gem.summary = %Q{Simple httperf runner with nice html reports with graphs.}
    gem.description = %Q{Autograph wraps httperf, running multiple tests while varying the parameters, graphing the output.}
    gem.email = "nick.stielau@gmail.com"
    gem.homepage = "http://github.com/nstielau/autograph"
    gem.authors = ["Nick Stielau"]
    gem.add_runtime_dependency 'builder',  '= 2.1.2'
    gem.add_runtime_dependency 'ruport',  '= 1.6.3'
    gem.add_runtime_dependency 'scruffy', '= 0.2.5'
    gem.add_runtime_dependency 'gchart',  '= 1.0.0'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end


task :install_local do
  `sudo gem install --local ./pkg/$(ls ./pkg | head -1) --no-ri --no-rdoc`
end

task :test => :check_dependencies
task :default => :test
