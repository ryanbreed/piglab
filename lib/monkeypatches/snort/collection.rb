module Snort
  class Collection
    attr_accessor :path, :glob, :selected, :files
    def initialize(*args)
      Hash[*args].each {|k,v| self.send(format("%s=",k),v)}
      @glob ||= '*.rules'
      @files ||= []
      @selected ||=[]
    end

    def self.parse(path, glob: '*.rules', parse_options: {})
      collection=Collection.new(path: path, glob: glob)
      collection.file_names.each {|fn| collection.add_file(fn,*parse_options) }
      yield collection if block_given?
      collection
    end

    def add_file(fn, parse_options={})
      new_rf=Snort::RuleFile.parse(fn,*parse_options).read!
      files.push(new_rf) unless has_file?(new_rf)
    end

    def has_file?(other)
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
      case
      when selected.empty?
        all_rules
      else
        selected
      end
    end

    def all_rules
      files.flat_map(&:rules)
    end

    def keymatch(key,*match_args)
      rexp=Regexp.new(*match_args)
      selected = rules.select { |rule| rule.send(key)&.match(rexp ) }
      rfs = selected.map(&:rule_file).sort.uniq
      RuleCollection.new(selected: selected, files: rfs)
    end

    def argmatch(*match_args)
      rexp=Regexp.new(*match_args)
      selected = rules.select { |rule| rule.options.any? {|o| o.arguments.any? {|a| a.match(rexp)}} }
      rfs = selected.map(&:rule_file).sort.uniq
      RuleCollection.new(selected: selected, files: rfs)
    end

    def method_missing(meth,*args)
      case meth.to_s
      when /\Amatches_(?<keyword>[a-z]+)\z/
        keyword=$~[:keyword]
        rexp=Regexp.new(*args)
        selected = rules.select { |rule| rule.send(keyword)&.match(rexp ) }
        rfs = selected.map(&:rule_file).sort.uniq
        RuleCollection.new(selected: selected, files: rfs)
      else
        raise NoMethodError, meth
      end
    end
  end
end
