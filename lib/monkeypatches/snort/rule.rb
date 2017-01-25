module Snort
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
    def has_argument?(arg)
      options.any? {|o| o.arguments.include?(arg)}
    end
    def sets_flowbit?(name=".*")
      self.flowbits&.match(Regexp.new('\Aset,\s*'+name))
    end
    def checks_flowbit?(name=".*")
      self.flowbits&.match(Regexp.new('\Aisset,\s*'+name))
    end
  end
end
