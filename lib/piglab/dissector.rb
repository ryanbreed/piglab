module Piglab
  class Dissector
    include Piglab::Regexes
    attr_accessor :samples, :sample_glob, :grok_glob
    attr_accessor :patterns
    attr_reader   :pile
    def initialize(*args)
      Hash[*args].each {|k,v| self.send(format('%s=',k),v)}
      @sample_glob =   'extracts/text/*.txt'
      @grok_glob   =   'patterns/*.grok'
      @samples     ||= read_samples(sample_glob)
      @pile        ||= read_groks(grok_glob)
      @patterns    ||= Hash[pile.patterns.map {|name,match_expr| [name, (pile.compile("%{#{name}}"); Regexp.new(pile.expanded_pattern))]}]
      yield self if block_given?
      self
    end
    def read_samples(glob=sample_glob)
      data=Dir.glob(glob).map {|f| File.read(f,nil,encoding: Encoding::BINARY) }
      if block_given? 
        data.flat_map {|d| yield(d)}
      else
        data
      end
    end
    def read_groks(glob=grok_glob)
      pile=Grok.new
      Dir.glob(glob).flat_map do |filename|
        pile.add_patterns_from_file(filename)
      end
      pile
    end
    def sample_strings
      @sample_strings ||= samples.map(&:to_s)
    end
    def to_byte_match(subj,end_idx=-1)
      str=case subj
      when String
        subj
      when Grok::Match
        subj.match[0]
      when MatchData
        subj.to_s
      else
        ""
      end
      format('|%s|', str[0..end_idx].bytes.map {|b| b.to_s(16)}.join(" "))
    end
    def longest_match(str)
      valid=Hash[patterns.map {|name,re| [name,re.match(str)]}]
                .reject {|k,v| v.nil? || v==false }
      valid.max_by {|k,v| v.captures.reject(&:nil?).map(&:length)}
    end
  end
end
