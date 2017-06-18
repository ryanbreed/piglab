require 'piglab'
require 'pry'
require 'erb'
require 'net/http'
require 'uri'
SNORT_CONF='conf/generated.conf'

def current_config
  File.exist?(SNORT_CONF) ?  File.read(SNORT_CONF) : ""
end

def vrt_oinkcode_params
  { oinkcode: ENV['SNORT_OINKCODE'] }.reject {|k,v| v.nil? }
end

def vrt_uri 
  URI(ENV.fetch("SNORT_RULE_SNAPSHOT","https://snort.org/rules/snortrules-snapshot-2990.tar.gz"))
end


def vrt_download
  uri = vrt_uri
  uri.params = vrt_oinkcode_params
  res = Net::HTTP.get_response(uri)
end

namespace :vrt do
  desc "download latest subscription ruleset"
  task :subscription do |t|
    
  end
end
namespace :snort do

  desc "generate full config"
  task :conf => 'snort:conf:full'
  namespace :conf do
    task :full do
      config = Piglab::Project.snort_defaults
      project = Piglab.project(config: config)
      generated = project.render_snort_conf(expand: true)
      if generated!=current_config
        File.open(SNORT_CONF,'w') { |snort| snort.write(generated) }
      else
        puts "no updates; leaving #{SNORT_CONF} alone"
      end
    end
    desc "generate ruletest config"
    task :ruletest do
      config = Piglab::Project.snort_defaults(without: [:rules_base,:rules_so_stubs])
      project = Piglab.project(config: config)
      generated = project.render_snort_conf(expand: true)
      if generated!=current_config
        File.open('conf/generated.conf','w') { |snort| snort.write(generated) }
      else
        puts "no updates; leaving #{SNORT_CONF} alone"
      end
    end
    desc "generate nostub config"
    task :nostubs do
      config = Piglab::Project.snort_defaults(without: [:rules_so_stubs])
      project = Piglab.project(config: config)
      generated = project.render_snort_conf(expand: true)
      if generated!=current_config
        File.open('conf/generated.conf','w') { |snort| snort.write(generated) }
      else
        puts "no updates; leaving #{SNORT_CONF} alone"
      end
    end
  end
  desc "run test rules against all pcaps"
  task :test => "snort:test:all"
  namespace :test do
    task :all => "snort:conf:ruletest" do
      snort_cmd = %w{ snort -c conf/generated.conf -q --suppress-config-log --pcap-show --pcap-reset --pcap-dir pcap}
      IO.popen(snort_cmd,"r").readlines.each {|l| puts l}
    end
    desc "run test rules against specific pcap collection"
    task :only, [:pcap] => "snort:conf:ruletest" do |task,args|
      dir=File.join('pcap',args[:pcap])
      snort_cmd = %w{ snort -c conf/generated.conf -q --suppress-config-log --pcap-show --pcap-reset --pcap-dir}.push(dir)
      IO.popen(snort_cmd,"r").readlines.each {|l| puts l}
    end
  end
  desc "run all rules against all pcaps"
  task :run => "snort:run:all"
  namespace :run do
    task :all => "snort:conf:full" do
      snort_cmd = %w{ snort -c conf/generated.conf -q --suppress-config-log --pcap-show --pcap-reset --pcap-dir pcap}
      IO.popen(snort_cmd,"r").readlines.each {|l| puts l}
    end
    desc "run all rules against specific pcap collections"
    task :only, [:pcap] => "snort:conf:full" do |task,args|
      dir=File.join('pcap',args[:pcap])
      snort_cmd = %w{ snort -c conf/generated.conf -q --suppress-config-log --pcap-show --pcap-reset --pcap-dir}.push(dir)
      IO.popen(snort_cmd,"r").readlines.each {|l| puts l}
    end
  end
  desc "generate so_rule stubs"
  task :so_stubs => "snort:conf:nostubs" do
    template='templates/generated_so_rules.conf.erb'
    %x{ snort --suppress-config-log -q -c conf/generated.conf --dump-dynamic-rules=conf/so_rule_stubs }
    tmpl=ERB.new(File.read(template),nil,'<>>-')
    state=binding
    File.open('conf/generated_so_includes.conf','w') {|f| f.write(tmpl.result(state))}
  end
end
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
