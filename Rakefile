require 'erb'
require 'piglab'

namespace :snort do
  namespace :conf do
    desc "generate full config"
    task :full do
      config = Piglab::Project.snort_defaults
      puts "generating sections: #{config.keys.map(&:to_s).join(', ')}"
      project = Piglab.project(config: config)
      File.open('conf/generated.conf','w') do |snort|
        snort.write(project.render_snort_conf(expand: true))
      end
    end
    desc "generate ruletest config"
    task :ruletest do
      config = Piglab::Project.snort_defaults(without: [:rules_base,:rules_so_stubs])
      puts "generating sections: #{config.keys.map(&:to_s).join(', ')}"
      project = Piglab.project(config: config)
      File.open('conf/generated.conf','w') do |snort|
        snort.write(project.render_snort_conf(expand: true))
      end
    end
    desc "generate nostub config"
    task :nostubs do
      config = Piglab::Project.snort_defaults(without: [:rules_so_stubs])
      puts "generating sections: #{config.keys.map(&:to_s).join(', ')}"
      project = Piglab.project(config: config)
      File.open('conf/generated.conf','w') do |snort|
        snort.write(project.render_snort_conf(expand: true))
      end
    end
  end
  namespace :test do
    desc "run test rules against all pcaps"
    task :all => "snort:conf:ruletest" do
    end
    desc "run test rules against specific pcap collection"
    task :only => "snort:conf:ruletest" do
    end
  end
  namespace :run do
    desc "run all rules against all pcaps"
    task :all => "snort:conf" do
      conf="conf/generated.conf"
      pcap="pcap"
      puts "running #{conf} against #{pcap}"
      %x{ snort --suppress-config-log -q -c #{conf} --pcap-dir #{pcap} --pcap-reset --pcap-show }
    end
    desc "run all rules against specific pcap collections"
    task :only => "snort:conf" do
      %x{ snort --suppress-config-log -c conf/generated.conf --pcap-dir pcap }
    end
  end
  desc "generate so_rule stubs"
  task :so_stubs => "snort:conf:nostubs" do
    %x{ snort --suppress-config-log -q -c conf/generated_nostubs.conf --dump-dynamic-rules=so_rule_stubs }
  end
end
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
