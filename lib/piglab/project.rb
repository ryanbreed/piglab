module Piglab
  class Project
    attr_accessor :root, :templates, :config, :expand_sections
    attr_reader   :conf_dir, :rules_dir, :so_rule_stubs
    def initialize(*args)
      Hash[*args].each {|k,v| self.send(format('%s=',k),v)}
      @config    ||= snort_defaults
      @root      ||= File.expand_path(File.join(__dir__,'..','..'))
      @templates ||= File.expand_path(File.join(@root,'templates'))
      @patterns  ||= File.expand_path(File.join(@root,'patterns'))
      @conf_dir      = File.expand_path(File.join(@root,'conf'))
      @rules_dir     = File.expand_path(File.join(@conf_dir,'rules'))
      @so_rule_stubs = File.expand_path(File.join(@conf_dir,'so_rule_stubs'))
      @expand_sections = false if @expand_sections.nil?
      yield self if block_given?
      self
    end

    def snort_defaults
      {
        var_net:          "net_vars.conf",
        var_path:         "path_vars.conf",
        output:           "output.conf",
        engine_decoder:   "decoder.conf",
        engine_detection: "engine_detection.conf",
        engine_dynamic:   "engine_dynamic.conf",
        rules_base:       "included_rules.conf",
        rules_so_stubs:   "included_so_rules.conf",
        rules_local:      'included_local.conf',
        rules_test:       nil
      }
    end

    def render_snort_conf(expand: false, template: 'snort.conf.erb')
      snort_conf_erb = File.join(templates, template)
      tpl = ERB.new(File.read(snort_conf_erb),nil,"<>>-")
      state = binding
      tpl.result(state)
    end
    def git_last_commit
      IO.popen("git log -1")
        .readlines
        .map {|line| format('## %s', line)}
        .join
    end
    def git_status
      IO.popen("git status -b -s -uall --ignore-submodules").readlines
        .map {|line| format('## %s',line)}
        .join
    end
  end
end
