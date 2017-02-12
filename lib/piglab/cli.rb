
module Piglab
  class Cli < Thor
    no_commands do
      def valid_arch?(arch_s)
        @cs_arch||=Crabstone.constants.map(&:to_s).grep(/^ARCH/)
        @cs_arch.include?(arch_s)
      end
      def valid_mode?(mode_s)
        @cs_mode||=Crabstone.constants.map(&:to_s).grep(/^MODE/)
        @cs_mode.include?(mode_s)
      end
      def get_dis_arch(arch)
        arch_s = arch.match(/^ARCH_/) ? arch : "ARCH_" + arch
        if valid_arch?(arch_s)
          Crabstone.const_get(arch_s.to_sym)
        else
          raise ArgumentError, "#{arch} not valid Crabstone arch"
        end
      end
      def get_dis_mode(mode)
        mode_s = mode.match(/^MODE_/) ? mode : 'MODE_' + mode
        if valid_mode?(mode_s)
          Crabstone.const_get(mode_s.to_sym)
        else
          raise ArgumentError, "#{mode} not valid Crabstone mode"
        end
      end
      def get_dis(arch,mode,detailed=true)
        cs_arch=get_dis_arch(arch)
        cs_mode=get_dis_mode(mode)
        cs = Crabstone::Disassembler.new(cs_arch,cs_mode)
        cs.decomposer=true
        cs
      end
    end
    desc "disassemble FILENAME", "disassemble a sample file"
    option :architecture, default: 'X86'
    option :mode, default: '64'
    option :base, default: '0x0000'
    def disassemble(filename)
      cs=get_dis(options[:architecture],options[:mode])
      data=File.read(filename)
      base_addr = options[:base].to_i
      cs.disasm(data,base_addr).each do |i|
        puts format('%-08s %016s', i.mnemonic, i.op_str.to_s)
      end
    end
  end

end
