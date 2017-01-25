module Snort
  def self.action_keywords
    %w{ alert log pass activate dynamic drop reject sdrop }
  end
  def self.match_rule_types(*keywords)
    keywords=action_keywords if keywords.empty?
    Regexp.new '\A\s*#*\s*(' + keywords.map(&:to_s).join('|') + ')\s+'
  end
end
