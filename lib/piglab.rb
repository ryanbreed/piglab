
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
require 'piglab/dissector'

module Piglab
  def self.project(*args)
    Piglab::Project.new(*args)
  end
  def self.dissector(*args)
    Piglab::Dissector.new(*args)
  end
  def self.msf(base=File.join('vendor','metasploit-framework'),*args)
    lib=File.expand_path(File.join(base,'lib'))
    $LOAD_PATH.push(lib)
    extra_opts=Hash[*args]
    require 'msfenv'
    require 'rex'
    require 'msf/ui'
    require 'msf/base'
    require 'msf/core/payload_generator'
    create_opts={
      module_types: [ 
        ::Msf::MODULE_PAYLOAD, 
        ::Msf::MODULE_ENCODER, 
        ::Msf::MODULE_NOP
      ],
      'DisableDataBase' => true
    }
    framework=::Msf::Simple::Framework.create(create_opts.merge(extra_opts))
  end
end
