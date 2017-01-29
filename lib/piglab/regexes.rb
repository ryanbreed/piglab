module Piglab
  module Regexes
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
  end
end
