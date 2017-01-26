# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
#directories %w( lib conf spec ).select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}

ignore %r{^pcap/}

guard :rspec, cmd: "bundle exec rspec" do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

end

guard :bundler do
  require 'guard/bundler'
  require 'guard/bundler/verify'
  helper = Guard::Bundler::Verify.new

  files = ['Gemfile']
  files += Dir['*.gemspec'] if files.any? { |f| helper.uses_gemspec?(f) }

  # Assume files are symlinked from somewhere
  files.each { |file| watch(helper.real_path(file)) }
end

# Add files and commands to this file, like the example:
#   watch(%r{file/path}) { `command(s)` }
#
guard :shell do
  os=RbConfig::CONFIG["target_os"].gsub(/\d+/,'')
  snort_conf=format("conf/snort_%s.conf",os)
  filter(%r{^conf/generated.conf})
  filter(%r{^conf/rules/local.rules})
  watch(%r{^#{snort_conf}}) do |m|
    `time snort -r pcap/boring/one_packet.pcap -c #{snort_conf} -T`
  end

  watch(%r{^conf/.*/*.rules}) do |m|
    `time snort --suppress-config-log --require-rule-sid -r pcap/boring/one_packet.pcap -c #{snort_conf} -T`
  end

  watch(%r{^test.rules}) do |m|
    `cp #{m[0]} conf/rules/local.rules && time snort --suppress-config-log --require-rule-sid -r pcap/boring/one_packet.pcap -c #{snort_conf} -T`
  end
end
