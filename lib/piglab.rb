
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
    only_payloads=%w{ ruby/shell_reverse_tcp_ssl ruby/shell_reverse_tcp ruby/shell_bind_tcp python/shell_reverse_tcp_ssl python/shell_reverse_tcp python/meterpreter_reverse_tcp python/meterpreter_reverse_https python/meterpreter_reverse_http python/meterpreter_bind_tcp php/shell_findsock php/reverse_php php/reverse_perl php/meterpreter_reverse_tcp php/exec php/download_exec php/bind_php php/bind_perl nodejs/shell_reverse_tcp_ssl nodejs/shell_reverse_tcp nodejs/shell_bind_tcp linux/x86/shell_reverse_tcp linux/x86/shell_find_tag linux/x86/shell_find_port linux/x86/shell_bind_tcp_random_port linux/x86/shell_bind_tcp linux/x86/read_file linux/x86/mettle_reverse_tcp linux/x86/metsvc_reverse_tcp linux/x86/metsvc_bind_tcp linux/x86/exec linux/x86/chmod linux/x86/adduser linux/x64/shell_reverse_tcp linux/x64/shell_find_port linux/x64/shell_bind_tcp_random_port linux/x64/shell_bind_tcp linux/x64/mettle_reverse_tcp linux/x64/exec linux/aarch64/mettle_reverse_tcp java/shell_reverse_tcp java/jsp_shell_reverse_tcp java/jsp_shell_bind_tcp cmd/unix/reverse_zsh cmd/unix/reverse_ssl_double_telnet cmd/unix/reverse_ruby_ssl cmd/unix/reverse_ruby cmd/unix/reverse_python_ssl cmd/unix/reverse_python cmd/unix/reverse_php_ssl cmd/unix/reverse_perl_ssl cmd/unix/reverse_perl cmd/unix/reverse_openssl cmd/unix/reverse_nodejs cmd/unix/reverse_netcat_gaping cmd/unix/reverse_netcat cmd/unix/reverse_lua cmd/unix/reverse_bash_telnet_ssl cmd/unix/reverse_bash cmd/unix/reverse_awk cmd/unix/reverse cmd/unix/generic cmd/unix/bind_zsh cmd/unix/bind_ruby cmd/unix/bind_perl cmd/unix/bind_nodejs cmd/unix/bind_netcat_gaping cmd/unix/bind_netcat cmd/unix/bind_lua cmd/unix/bind_inetd cmd/unix/bind_awk cmd/mainframe/reverse_shell_jcl cmd/mainframe/generic_jcl python/meterpreter/reverse_tcp_uuid python/meterpreter/reverse_tcp_ssl python/meterpreter/reverse_tcp python/meterpreter/reverse_https python/meterpreter/reverse_http python/meterpreter/bind_tcp_uuid python/meterpreter/bind_tcp php/meterpreter/reverse_tcp_uuid php/meterpreter/reverse_tcp php/meterpreter/bind_tcp_uuid php/meterpreter/bind_tcp netware/shell/reverse_tcp multi/meterpreter/reverse_https multi/meterpreter/reverse_http linux/x86/shell/reverse_tcp_uuid linux/x86/mettle/reverse_tcp_uuid linux/x86/meterpreter/reverse_tcp_uuid linux/x86/shell/reverse_tcp linux/x86/mettle/reverse_tcp linux/x86/meterpreter/reverse_tcp linux/x86/shell/reverse_nonx_tcp linux/x86/mettle/reverse_nonx_tcp linux/x86/meterpreter/reverse_nonx_tcp linux/x86/shell/find_tag linux/x86/mettle/find_tag linux/x86/meterpreter/find_tag linux/x86/shell/bind_tcp_uuid linux/x86/mettle/bind_tcp_uuid linux/x86/meterpreter/bind_tcp_uuid linux/x86/shell/bind_tcp linux/x86/mettle/bind_tcp linux/x86/meterpreter/bind_tcp linux/x86/shell/bind_nonx_tcp linux/x86/mettle/bind_nonx_tcp linux/x86/meterpreter/bind_nonx_tcp linux/x64/shell/reverse_tcp linux/x64/mettle/reverse_tcp linux/x64/shell/bind_tcp linux/x64/mettle/bind_tcp java/shell/reverse_tcp java/meterpreter/reverse_tcp java/meterpreter/reverse_https java/meterpreter/reverse_http java/shell/bind_tcp java/meterpreter/bind_tcp }
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
    (framework.payloads.keys - only_payloads).each {|p| framework.payloads.delete(p)}
    framework
  end
end
