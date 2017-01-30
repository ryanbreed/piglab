require "spec_helper"

RSpec.describe Piglab::Project do
  let(:default_config) {Piglab::Project.snort_defaults}
  let(:test_config)    {Piglab::Project.snort_defaults(without: [:engine_dynamic, :rules_base, :rules_so_stubs, :rules_test, :rules_local])}
  let(:project)        {Piglab::Project.new(config: default_config)}
  let(:test_project)   {Piglab::Project.new(config: test_config)}
  let(:target)         {RbConfig::CONFIG["target_os"].gsub(/\d+/,'')}
  context "configuring snort" do
    describe ".snort_defaults" do 
      it "returns a default set of keys" do
        expect(default_config).to include(
          :var_net, :var_path, 
          :engine_dynamic, :engine_decoder, :engine_detection, :engine_preproc, 
          :rules_preproc, :rules_base, :rules_so_stubs, :rules_local
        )
      end
      it "excludes keys when passed an array via without:" do
        expect(test_config).not_to include(:rules_base, :rules_so_stubs, :rules_test)
      end
    end
  end
  context "constructor defaults" do
    describe "::initialize" do
      it "sets the root" do 
        expect(project.root).to eq(File.expand_path(File.join(__dir__,'..','..','..')))
      end 
      it "sets the snort config" do
        expect(project.config).to be_a(Hash)
      end
    end
    describe "#render_snort_conf" do
      let(:short) {test_project.render_snort_conf}
      let(:exp)   {test_project.render_snort_conf(expand: true)}
      it "renders shortened configs by default" do
        expect(short).to eq c=<<-END
##
## INCLUDED SECTIONS: var_net, var_path, engine_decoder, engine_detection, engine_preproc, rules_preproc
##
## PREAMBLE
config policy_mode:tap
include classification.config
include reference.config
###
### BEGIN  var_net
###
include net_vars.conf

###
### BEGIN  var_path
###
include path_vars.conf

###
### BEGIN  engine_decoder
###
include engine_decoder.conf

###
### BEGIN  engine_detection
###
include engine_detection.conf

###
### BEGIN  engine_preproc
###
include engine_preproc.conf

###
### BEGIN  rules_preproc
###
include included_preproc_rules.conf

################################
END
      end
    end
  end
end
