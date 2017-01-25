
require 'packetfu'
require 'snort/rule'
require 'base64'
require 'grok-pure'
require 'yaml'
require 'erb'

require 'monkeypatches'
require "piglab/version"
require 'piglab/project'
require 'piglab/util'

module Piglab

  def self.project(*args)
    Piglab::Project.new(*args)
  end

end
