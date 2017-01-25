
require 'packetfu'
require 'snort/rule'
require 'base64'
require 'grok-pure'

require "piglab/version"
require 'monkeypatches'

module Piglab
  def assemble_match(str)
    str.gsub(/"/,"")
       .split("|")
       .reject(&:empty?)
       .flat_map do |str|
         str.split(" ").map {|c| decode_match_part(c)}
       end.join
  end

  def decode_match_part(str)
    if str.match(/\A[[:xdigit:]]{2}\z/)
      str.to_i(16).chr
    else
      str
    end
  end

  def grokpile
    g=Grok.new
    g.add_patterns_from_file('vendor/patterns/patterns/grok-patterns')
    %w{
      WINDOWSMAC CISCOMAC        MAC
      SYSLOGPROG SYSLOGHOST      SYSLOGFACILITY
      PROG       SYSLOGTIMESTAMP SYSLOGBASE
      URI URIPATHPARAM
    }.each {|p| g.patterns.delete(p)}

    g.add_pattern("MAC",g.patterns.delete("COMMONMAC"))
    g.add_pattern("WEB_SCHEME","(?i:(f|ht)tps?)")
    g.add_pattern( "WEB_URI", "%{WEB_SCHEME}://(?:%{USER}(?::[^@]*)?@)?%{IPORHOST}(?::%{POSINT:port})?(?:%{URIPATH}(?:%{URIPARAM})?)?" )
    g
  end
end
