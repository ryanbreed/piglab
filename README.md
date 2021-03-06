# piglab - a working environment for snort

## Installation
Note: needs a ruby ~> 2.3

For now:

    git clone https://github.com/ryanbreed/piglab
    cd piglab && bash ./bin/setup

## Usage - guard mode
There is a Guard configuration that will automatically run tests as
you modify snort's configuration or rules. The specific tests will be
invoked depending on which type of modification has been made.

This will, for example, ensure that an update to snort's config will
pass a syntax check, or the introduction of a new rule fires on
required pcaps and doesn't fire on others.

To get guard mode started: `bundle exec guard`

{TODO: slightly incomplete}

## Usage - rake mode

There are a bunch of Rake tasks for running snort in various configs.

Use `bundle exec rake -T snort` for more details:

    snort:conf:full      # generate full config
    snort:run:all        # run all rules against all pcaps
    snort:run:only       # run all rules against specific pcap collections
    snort:test:all       # run test rules against all pcaps
    snort:test:only      # run test rules against specific pcap collection
    ...

## Usage - console mode
There is also an interactive pry console for your project:

    13:41 $ bundle exec console
    CURRENT PROJECT: ---
    :project:
      :root: "/Users/ryan/build/piglab"
      :conf_dir: "/Users/ryan/build/piglab/conf"
      :rules_dir: "/Users/ryan/build/piglab/conf/rules"
      ...
      ...
    [1] pry(main)>

where you can interact with snort's configuration:

    [20] pry(main)> puts project.render_snort_conf(expand: true)
    ##
    ## GENERATED ON: 2017-01-25 14:01:25
    ## GENERATED BY: ryan
    ## TARGET PLATFORM: darwin16
    ## INCLUDED SECTIONS: var_net, var_path, output, engine_decoder, engine_detection, engine_dynamic, rules_local
    config policy_mode:tap
    include classification.config
    include reference.config
    ###
    ### BEGIN  var_net
    ###
    ipvar HOME_NET any
    ipvar EXTERNAL_NET any
    ...
    ...
    ###
    ### BEGIN  rules_base
    ###
    include $RULE_PATH/app-detect.rules
    include $RULE_PATH/attack-responses.rules
    include $RULE_PATH/backdoor.rules
    include $RULE_PATH/bad-traffic.rules
    ...
    ...
    ##
    ## STATUS OF WORKING REPO
    ##
    ## ## master...origin/master [ahead 1]
    ## commit 174d9696ed23e5a6be98c38ee74e6d2a299f7603
    ## Author: Ryan Breed
    ## Date:   Wed Jan 25 14:01:07 2017 -0600
    ################################

or interact with the pcap collection:

    packets = project.readpackets(collection: :boring)

or discover regex patterns in sample strings

    samples = packets.read_streams(:http_client_request).grep(%r{^Directory: })
    project.discover_patterns(strings: samples, expand: :to_re)

    {TODO: example}

or interact with the rule collection.
this disables all of the community rules for SERVER-WEBAPP:

    project.rules.matches_msg("SERVER-WEBAPP") do |collection|
      collection.rules.each do |rule|
        rule.disable if rule.metadata.match(/ruleset community/)
      end
      collection.save!  
    end
