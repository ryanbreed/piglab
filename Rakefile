require 'erb'
require 'piglab'

namespace :snort do
  desc "generate full config"
  task :conf do
    os=RbConfig::CONFIG["target_os"].gsub(/\d+/,'')
    snort_conf=format("conf/snort_%s.conf",os)
    %x{ cp #{snort_conf} conf/generated.conf }
  end
  namespace :conf do
    desc "generate ruletest config"
    task :ruletest do
    end
    desc "generate nostub config"
    task :nostubs do
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
  desc "run all rules against all pcaps"
  task :run => "snort:conf" do
    %x{ snort --suppress-config-log -q -c conf/generated.conf --pcap-dir pcap }
  end
  namespace :run do
    desc "run all rules against specific pcap collections"
    task :only => "snort:conf" do
      %x{ snort --suppress-config-log -q -c conf/generated.conf --pcap-dir pcap }
    end
  end
  desc "generate so_rule stubs"
  task :so_stubs => "snort:conf:nostubs" do
    %x{ snort --suppress-config-log -q -c conf/generated_nostubs.conf --dump-dynamic-rules=/etc/snort/so_rule_stubs }
  end
end
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
