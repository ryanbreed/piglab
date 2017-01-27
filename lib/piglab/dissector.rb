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
    def to_bytematch
      
    end
  end
  class Dissector
    attr_accessor :streams, :dir
    def initialize(*args)
      Hash[*args].each {|k,v| self.send(format('%s=',k),v)}
      @dir     ||="extracts/text"
      @streams ||= read_streams(@dir )if Dir.exist?(@dir)
      yield self if block_given?
      self
    end

    def to_byte_match(str)
      format('|%s|', str.bytes.map {|b| b.to_s(16)}.join(" "))
    end

    def b64us(min=16,max=nil)
      alphabet="-0123456789=ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz"
      Regexp.new(format('(?<encoded>[%s]{%s,%s})',alphabet,min,max))
    end
    def b64(min=16,max=nil)
      alphabet="+\/0123456789=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
      Regexp.new(format('(?<encoded>[%s]{%s,%s})',alphabet,min,max))
    end
    def b32(min=16,max=nil)
      alphabet="234567=ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      Regexp.new(format('(?<encoded>[%s]{%s,%s})',alphabet,min,max))
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
