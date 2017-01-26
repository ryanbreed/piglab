module Piglab
  class Stream
    attr_accessor :src, :sport, :dst, :dport, :payload, :preamble
    def initialize(*args)
      Hash[*args].each {|k,v| self.send(format('%s=',k),v)}
    end
    def inspect
      to_s
    end
    def to_s
      payload
    end
  end
  class Dissector
    attr_accessor :streams
    def initialize(*args)
      Hash[*args].each {|k,v| self.send(format('%s=',k),v)}
      @dir ||="extracts/text"
      @streams ||= read_streams(@dir)
      yield self if block_given?
      self
    end
    private
    def read_streams(dir=@dir)
      Dir.glob(File.join(dir,"*.txt")).map do |fname|
        data=File.read(fname)
        pre,post = data.split(/\n\d+\n/)
        Stream.new(payload: post, preamble: pre)
      end
    end
  end
end
