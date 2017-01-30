module Piglab
  module Util
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
  end
end
