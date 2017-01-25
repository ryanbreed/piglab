require "spec_helper"

RSpec.describe Snort::Rule do
  let(:rule) { Snort::Rule.parse('alert tcp $EXTERNAL_NET any -> $HOME_NET $HTTP_PORTS (msg:"APP-DETECT Acunetix web vulnerability scan attempt"; flow:to_server,established; flowbits:set,acunetix-scan; content:"Acunetix-"; fast_pattern:only; http_header; metadata:service http; reference:url,www.acunetix.com; classtype:web-application-attack; sid:25358; rev:3;)')}
  let(:setter) { Snort::Rule.parse('alert tcp $EXTERNAL_NET any -> $HOME_NET $HTTP_PORTS (msg:"APP-DETECT Acunetix web vulnerability scan attempt"; flow:to_server,established; flowbits:set,acunetix-scan; content:"Acunetix-"; fast_pattern:only; http_header; metadata:service http; reference:url,www.acunetix.com; classtype:web-application-attack; sid:25358; rev:3;)')}
  let(:checker) { Snort::Rule.parse('alert tcp $EXTERNAL_NET $FILE_DATA_PORTS -> $HOME_NET any (msg:"APP-DETECT Teamviewer installer download attempt"; flow:to_client,established; flowbits:isset,file.exe; content:"T|00|e|00|a|00|m|00|V|00|i|00|e|00|w|00|e|00|r"; content:"www.teamviewer.com"; fast_pattern:only; metadata:service ftp-data, service http, service imap, service pop3; reference:url,en.wikipedia.org/wiki/TeamViewer; classtype:policy-violation; sid:24095; rev:2;)')}
  let(:nobits) {Snort::Rule.parse('alert tcp $HOME_NET any -> $EXTERNAL_NET $HTTP_PORTS (msg:"APP-DETECT Absolute Software Computrace outbound connection - search.namequery.com"; flow:to_server,established; content:"Host|3A| search.namequery.com|0D 0A|"; fast_pattern:only; http_header; content:"TagId: "; http_header; metadata:policy security-ips drop, ruleset community, service http; reference:url,absolute.com/support/consumer/technology_computrace; reference:url,www.blackhat.com/presentations/bh-usa-09/ORTEGA/BHUSA09-Ortega-DeactivateRootkit-PAPER.pdf; classtype:misc-activity; sid:26287; rev:4;)')}
  it "has been monkeypatched with all methods" do
    expect(rule).to respond_to(:sets_flowbit?, :checks_flowbit?, :has_argument?)
  end
  describe '#method_missing' do
    it "delegates access to options" do
      expect(rule.msg).to eq('"APP-DETECT Acunetix web vulnerability scan attempt"')
    end
    it "returns nil for unset options" do
      expect(rule.pcre).to be_nil
    end
    it 'raises an exception for invalid options'
  end
  describe '#sets_flowbit?' do
    it "returns true for a rule that sets a flowbit"
    it "returns false for a rule that checks a flowbit"
    it "returns false for a rule that has no flowbit action"
  end
  describe '#checks_flowbit?' do
    it "returns true for a rule that checks a flowbit"
    it "returns false for a rule that sets a flowbit"
    it "returns false for a rule that has no flowbit action"
  end
end
