module Piglab
  class Dissector
    include Piglab::Regexes
    attr_accessor :samples, :patterns
    def initialize(*args)
      Hash[*args].each {|k,v| self.send(format('%s=',k),v)}
      @samples ||= []
      @patterns ||= []
      yield self if block_given?
      self
    end
    def read_samples(glob='extracts/text/*.txt')
      Dir.glob(glob).map {|f| File.read(f) }
    end
    def read_groks(filename)
      File.readlines(filename).map do |line|
        line.chomp
        name,pattern = line.split(%r{\s+},2)
        g=Grok.new
        g.add_pattern(name,pattern)
        g
      end
    end
    def matchers
      patterns.map do |pattern|
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
      samples.map(&:to_s)
    end
    def to_byte_match(str)
      format('|%s|', str.bytes.map {|b| b.to_s(16)}.join(" "))
    end
    def longest_matcher(str, patterns=[])
      lengths=Hash[patterns.zip(patterns.map {|p| p.match(str)&.size })]
                .reject {|k,v| v.nil?}
      pattern, size = lengths.max_by {|k,v| v }
      pattern.match(str)
    end
  end
end
