module Piglab
  class WiresharkStream
    def self.read(glob='extracts/text/*.txt')
      Dir.glob(glob).map do |fname|
        data=File.read(fname)
        pre,post = data.split(/\n\d+\n/)
        WiresharkStream.new(payload: post, preamble: pre)
      end
    end
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
end
