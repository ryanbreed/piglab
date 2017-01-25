module Snort
  class RuleFile
    attr_accessor :include_regexp
    attr_accessor :path
    attr_accessor :required_options
    attr_accessor :rules
    attr_accessor :filter

    def self.parse(path,*options)
      rf=RuleFile.new({path: path}.merge(Hash[*options])).read!
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

    def <=>(other)
      path <=> other.path
    end

    def read!
      @rules=read
      self
    end

    def read
      File.open(path,"r") do |file|
        file.readlines
            .grep(include_regexp)
            .map {|line| r=Snort::Rule.parse(line.chomp); r.rule_file=self; r }
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
end
