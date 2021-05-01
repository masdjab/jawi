require_relative '../../libs/fetcher'
require_relative '../../libs/position_info_provider'
require_relative '../../compiler/parser/parser'
require_relative '../../compiler/parser/tokenizer'


source = <<EOS
class CodeUtil
  def self.int_align(val, align_size)
    if (val > 0) && (align_size > 0)
      if (unaligned = (val % align_size)) > 0
        val = val + (align_size - unaligned)
      end
    end
    
    val
  end
  def self.str_align(data, align_size = 16, pad_char = nil)
    if (data.len > 0) && (align_size > 0)
      if (extra_size = (data.len % align_size)) > 0
        data = data + (0.chr * (align_size - extra_size))
      end
    end
    
    data
  end
end
EOS

fetcher = Fetcher.new(source)
pos_info = PositionInfoProvider.new(source)
tokenizer = Tokenizer.new(fetcher, pos_info)
tokens = tokenizer.tokenize
puts tokens.map{|t|t.text}.join(',')
