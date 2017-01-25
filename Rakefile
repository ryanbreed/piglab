namespace :snort do 
  desc "generate so_rule stubs"
  task :so_stubs do
    %x{ snort -c snort.conf --dump-dynamic-rules=/etc/snort/so_rule_stubs }
  end
end
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
