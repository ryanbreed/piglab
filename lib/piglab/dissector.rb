module Piglab
  class Dissector
    include Piglab::Regexes
    attr_accessor :samples, :patterns, :sample_glob, :grok_glob
    def initialize(*args)
      Hash[*args].each {|k,v| self.send(format('%s=',k),v)}
      @sample_glob = 'extracts/text/*.txt'
      @grok_glob   = 'patterns/*.grok'
      @samples ||= read_samples
      @patterns ||= read_groks
      yield self if block_given?
      self
    end
    def read_samples(glob=sample_glob)
      Dir.glob(glob).map {|f| File.read(f,nil,encoding: Encoding::BINARY) }
    end
    def read_groks(glob=grok_glob)
      Dir.glob(glob).flat_map do |filename|
        File.readlines(filename).map do |line|
          line.chomp!
          name,pattern = line.split(%r{\s+},2)
          g=Grok.new
          g.add_pattern(name,pattern)
          g.compile("%{#{name}}")
          g
        end
      end
    end
    def matchers
      @matchers ||= patterns.map do |pattern|
        case pattern
        when String
          Regexp.new(pattern)
        when Regexp
          pattern
        when Grok
          pattern
        else
          nil
        end
      end.reject(&:nil?)
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
      valid=Hash[matchers.zip(matchers.map {|p| p.match(str) })]
                .reject {|k,v| v.nil? || v==false }
      grok,grokmatch = valid.max_by {|k,v| v.end - v.start }
      grokmatch
    end
  end
end
