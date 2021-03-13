# resources:
# https://wiki.osdev.org/MZ
# https://board.flatassembler.net/topic.php?t=1736
# https://board.flatassembler.net/topic.php?t=15181
# https://www.fileformat.info/format/exe/corion-mz.htm
# https://faydoc.tripod.com/structures/15/1594.htm


require_relative '../../libs/binary_converter'
require_relative '../../libs/code_util'


class MzStruct
  attr_accessor \
    :signature, :extra_bytes, :num_of_pages, :relocation_items, :header_size, 
    :min_alloc_paragraphs, :max_alloc_paragraphs, :initial_ss, :initial_sp, 
    :checksum, :initial_ip, :initial_cs, :relocation_table, :overlay, :overlay_info, 
    :image_body
  
  private
  def initialize
    @signature = "MZ"                   # 00 signature
    @extra_bytes = 0                    # 02 number of bytes in last 512-byte page
    @num_of_pages = 0                   # 04 total number of 512-byte pages in executable, including the last page
    @relocation_items = 0               # 06 number of relocation entries
    @header_size = 0                    # 08 header size in paragraphs
    @min_alloc_paragraphs = 0x10        # 0A Minimum paragraphs of memory allocated in addition to the code size
    @max_alloc_paragraphs = 0xffff      # 0C Maximum number of paragraphs allocated in addition to the code size
    @initial_ss = 0                     # 0E Initial SS relative to start of executable
    @initial_sp = 0                     # 10 Initial SP
    @checksum = 0                       # 12 Checksum (or 0) of executable
    @initial_ip = 0                     # 14 CS:IP relative to start of executable (entry point)
    @initial_cs = 0                     # 16 CS:IP relative to start of executable (entry point)
    @relocation_table = 0               # 18 Offset of relocation table, 40h for new-(NE,LE,LX,W3,PE etc.) executable
    @overlay_number = 0                 # 1A Overlay number (0h = main program)
    @overlay_info = ""                  # 1C Overlay info
    @image_body = ""
  end
  def int2bin(data, size)
    BinaryConverter.int2bin(data, size)
  end
  def str_align(data, size)
    CodeUtil.str_align(data, size)
  end
  
  public
  def to_bin
    header_items = 
      [
        @signature, 
        int2bin(@extra_bytes, :word), 
        int2bin(@num_of_pages, :word), 
        int2bin(@relocation_items, :word), 
        int2bin(@header_size, :word), 
        int2bin(@min_alloc_paragraphs, :word), 
        int2bin(@max_alloc_paragraphs, :word), 
        int2bin(@initial_ss, :word), 
        int2bin(@initial_sp, :word), 
        int2bin(@checksum, :word), 
        int2bin(@initial_ip, :word), 
        int2bin(@initial_cs, :word), 
        int2bin(@relocation_table, :word), 
        int2bin(@overlay_number, :word), 
        @overlay_info, 
      ]
    
    header = header_items.join
    if header.length > (@header_size * 0x10)
      raise "Size of the header (#{header.length}) is larger than the specified header_size (#{@header_size} * 16)."
    end
    
    str_align(header, 0x10) + @image_body
  end
end
