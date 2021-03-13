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
    if (data.length > 0) && (align_size > 0)
      if (extra_size = (data.length % align_size)) > 0
        data = data + (0.chr * (align_size - extra_size))
      end
    end
    
    data
  end
end
