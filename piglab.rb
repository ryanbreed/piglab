require 'packetfu'
require 'pry'
require 'snort/rule'
require 'base64'
require 'elasticsearch'

def assemble_match(str)
  str.gsub(/"/,"")
     .split("|")
     .reject(&:empty?)
     .flat_map do |str|
       str.split(" ").map {|c| decode_match_part(c)}
     end.join
end

def decode_match_part(str)
  if str.match(/\A[[:xdigit:]]{2}\z/)
    str.to_i(16).chr
  else
    str
  end
end

module Snort
  def self.action_keywords
    %w{ alert log pass activate dynamic drop reject sdrop }
  end
  def self.match_rule_types(*keywords)
    keywords=action_keywords if keywords.empty?
    Regexp.new '\A\s*#*\s*(' + keywords.map(&:to_s).join('|') + ')\s+' 
  end
  class RuleCollection
    attr_accessor :path, :glob
    attr_reader   :files
    def initialize(*args)
      Hash[*args].each {|k,v| self.send(format("%s=",k),v)}
      @glob ||= '*.rules'
      @files ||= []
    end
    def add_file(fn, parse_options={})
      new_rf=Snort::RuleFile.parse(fn,*parse_options).read!
      files.push(new_rf) unless has?(new_rf)
    end
    def has?(other)
      files.any? {|rf| File.expand_path(rf.path)==File.expand_path(other.path)}
    end
    def file_names
      Dir.glob(File.join(path,glob))
    end
    def stats
      files.map(&:stats)
           .reduce do |c_stats, rf_stats|
             c_stats.merge(rf_stats) {|key, coll_v, rf_v| coll_v + rf_v }
           end
    end
    def rules
      files.flat_map(&:rules)
    end
    def self.parse(path, glob: '*.rules', parse_options: {})
      collection=RuleCollection.new(path: path, glob: glob)
      collection.file_names.each {|fn| collection.add_file(fn,*parse_options) }
      yield collection if block_given?
      collection
    end
  end
  class RuleFile
    attr_accessor :include_regexp
    attr_accessor :path
    attr_accessor :required_options
    attr_accessor :rules
    attr_accessor :filter

    def self.parse(path,*options)
      rf=RuleFile.new({path: path}.merge(Hash[*options])).read!
      rf.rules.each {|r| r.rule_file=rf}
      yield rf if block_given?
      rf
    end

    def initialize(*args)
      Hash[*args].each {|k,v| self.send(format("%s=",k),v)}
      @required_options ||= %w{ sid msg rev }
      @include_regexp ||= Snort.match_rule_types
      @filter ||= Proc.new { |rule| true }
      @rules ||= []
    end

    def read!
      @rules=read
      self
    end

    def read
      File.open(path,"r") do |file|
        file.readlines
            .grep(include_regexp)
            .map {|line| Snort::Rule.parse(line.chomp) }
            .reject {|rule| required_options.any? {|o| rule.send(o).nil?}}
            .select {|rule| filter.call(rule) }
      end
    end

    def action_stats
      Hash[
        Snort.action_keywords.map do |keyword| 
          [
            keyword.to_sym, 
            rules.count { |r| r.action==keyword }
          ]
        end
      ]
    end

    def stats
     
      { 
        size:     rules.size,
        enabled:  rules.count(&:enabled),
        disabled: rules.count {|r| r.enabled==false}
      }.merge(action_stats)
    end

    def save!
      save(path,"w")
    end

    def save(save_to="saved.rules",mode="w")
      File.open(save_to,mode) do |out|
        rules.each {|r| out.puts(r.to_s) }.size
      end
    end
  end
  class Rule
    attr_accessor :rule_file
    def method_missing(meth,*args,&block)
      if options.map(&:keyword).include?(meth.to_s)
        get_option_first(meth.to_s)
      elsif args.empty?
        nil
      else
        raise NoMethodError, meth
      end
    end
    def sets_flowbit?(name=".*")
      self.flowbits&.match(Regexp.new('\Aset,\s*'+name))
    end
    def checks_flowbit?(name=".*")
      self.flowbits&.match(Regexp.new('\Aisset,\s*'+name))
    end
  end
end
