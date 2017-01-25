# piglab - a working environment for snort

## Installation
Note: needs a ruby ~> 2.3

For now:

    git clone https://github.com/ryanbreed/piglab
    cd piglab && bash ./bin/setup

## Usage

There are a bunch of Rake tasks for running snort in various configs.

Use `bundle exec rake -T snort` for more details:

    snort:conf:full      # generate full config
    snort:conf:nostubs   # generate nostub config
    snort:conf:ruletest  # generate ruletest config
    snort:run:all        # run all rules against all pcaps
    snort:run:only       # run all rules against specific pcap collections
    snort:so_stubs       # generate so_rule stubs
    snort:test:all       # run test rules against all pcaps
    snort:test:only      # run test rules against single test dir


There is also an interactive pry console for your project:

    13:41 $ bundle exec console
    CURRENT PROJECT: ---
    :project:
      :root: "/Users/ryan/build/piglab"
      :conf_dir: "/Users/ryan/build/piglab/conf"
      :rules_dir: "/Users/ryan/build/piglab/conf/rules"
      :so_stubs: "/Users/ryan/build/piglab/conf/so_rule_stubs"
      :templates: "/Users/ryan/build/piglab/templates"
      :patterns: "/Users/ryan/build/piglab/patterns"
    :snort:
      :var_net: net_vars.conf
      :var_path: path_vars.conf
      :output: output.conf
      :engine_decoder: decoder.conf
      :engine_detection: engine_detection.conf
      :engine_dynamic: engine_dynamic.conf
      :rules_base: included_rules.conf
      :rules_so_stubs: included_so_rules.conf
      :rules_local: included_local.conf
      :rules_test:
    [1] pry(main)>

where you can interact with snort's configuration:
