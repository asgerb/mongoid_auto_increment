require 'rubygems'
require 'rake'
require 'bundler'
Bundler::GemHelper.install_tasks

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = 'mongoid_auto_increment'
  gem.homepage = 'http://github.com/proton/mongoid_auto_increment'
  gem.license = 'MIT'
  gem.summary = 'Auto-incrementing fields for Mongoid documents'
  gem.description = 'Add SQL like auto-incrementing fields to your Mongoid documents.'
  gem.email = 'psavichev@gmail.com'
  gem.authors = ['Peter Savichev (proton)']
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

task default: :spec

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ''

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "mongoid_auto_increment #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Build gem'
task :build do
  puts 'Regenerating gemspec'
  system 'rake gemspec'
  puts 'Building'
  system 'gem build mongoid_auto_increment.gemspec'
end

desc 'Release gem'
task release: :build do
  version = File.exist?('VERSION') ? File.read('VERSION') : ''
end
