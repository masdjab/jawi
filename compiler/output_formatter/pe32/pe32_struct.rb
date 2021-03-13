# resources:
# https://docs.microsoft.com/en-us/windows/win32/debug/pe-format
# https://blog.kowalczyk.info/articles/pefileformat.html
# https://en.wikipedia.org/wiki/DOS_MZ_executable
# https://web.archive.org/web/20120915093039/http://msdn.microsoft.com/en-us/magazine/cc301808.aspx
# https://docs.microsoft.com/en-us/archive/msdn-magazine/2002/february/inside-windows-win32-portable-executable-file-format-in-detail
# https://www.fileformat.info/format/exe/corion-mz.htm
# https://en.wikibooks.org/wiki/X86_Disassembly/Windows_Executable_Files

# @3c => offset to PE signature
# location after PE signature:
# 00  4   signature                     PE\0\0
# 04  2   machine                       target machine identifier (0x14c = Intel 386 or later)
# 06  2   number of sections            indicates the size of section table which immediately follows the header
# 08  4   datetimestamp                 The low 32 bits of the number of seconds since 00:00 January 1, 1970 
#                                       (a C run-time time_t value), that indicates when the file was created.
# 0C  4   pointer to symbol table       the file offset of the COFF symbol table, or zero if not present
# 10  4   number of symbols             the number of entries in the symbol table
# 14  2   size of optional header   
# 16  2   characteristics               indicates the attributes of file
#                                       0x0100  Machine is based on a 32-bit-word architecture.
#                                       0x0008  COFF symbol table entries for local symbols have been removed.
#                                               This flag is deprecated and should be zero
#                                       0x0004  COFF line numbers have been removed.
#                                               This flag is deprecated and should be zero.
#                                       0x0002  This indicates that the image file is valid and can be run.
#                                               If this flag is not set, it indicates a linker error.
#                                       0x0001  Windows CE, and Microsoft Windows NT and later.

# optional header (pe32/pe32+):
# 00  18  2   magic number              0x10b   PE32
#                                       0x20b   PE32+
# 02  1a  1   major linker version
# 03  1b  1   minor linker version
# 04  1c  4   size of code
# 08  20  4   size of initialized data
# 0c  24  4   size of uninitialized data
# 10  28  4   address of entry point    entrypoint address
# 14  2c  4   base of code              address of beginning-of-code section relative to image base when loaded to memory
# for PE32
# 18  30  4   base of data              address of beginning-of-data section relative to image base when loaded to memory
# 1C  34  4   image base                preferred address of the first byte of image when loaded to memary
# 20  38  4   section alignment         
# 24  3c  4   file alignment
# 28  40  2   major os version
# 2a  42  2   minor os version
# 2c  44  2   major image version
# 2e  46  2   minor image version
# 30  48  2   major subsystem version
# 32  4a  2   minor subsystem version
# 34  4c  4   win32 version value       reserved, must be zero
# 38  50  4   size of image             the size in bytes of the image including all headers
# 3c  54  4   size of headers           total size of msdos stub, pe header, sections header rounded up to filealignment
# 40  58  4   checksum
# 44  5c  2   subsystem                 2   The Windows graphical user interface (GUI) subsystem
#                                       3   The Windows character subsystem
# 46  5e  2   DLL characteristics
# 48  60  4   size of stack reserve
# 4c  64  4   size of stack commit
# 50  68  4   size of heap reserve
# 54  6c  4   size of heap commit
# 58  70  4   loader flags              reserved must be zero
# 5c  74  4   number of rvas and sizes
# 60  78  8   export table              address and size of export table
# 68  80  8   import table              address and size of import table
# 70  88  8   resource table
# 78  90  8   exception table
# 80  98  8   certificate table
# 88  a0  8   base relocation table
# 90  a8  8   debug
# 98  b0  8   architecture
# a0  b8  8   global pointer
# a8  c0  8   TLS table
# b0  c8  8   load config table
# b8  d0  8   bound import
# c0  d8  8   IAT
# c8  e0  8   delay import descriptor
# d0  e8  8   CLR runtime header
# d8  f0  8   reserved, must be zero

# optional header data directories
# 00  4   virtual address
# 04  4   size


require_relative '../../../libs/binary_converter'
require_relative '../../../libs/code_util'
require_relative '../../code_section'
require_relative '../mz_struct'
require_relative 'pe32_const'
require_relative 'pe_version'
require_relative 'pe32_data_directory'
require_relative 'pe32_section_info'
require_relative 'pe32_import_section'
require_relative 'pe32_section_table'


class Pe32Struct
  attr_accessor \
    :machine, :timestamp, :pointer_to_symbol_table, 
    :number_of_symbols, :size_of_optional_header, :characteristics, 
    :magic_number, :linker_version, :size_of_code, :size_of_initialized_data, 
    :size_of_uninitialized_data, :entry_point, :base_of_code, :base_of_data, 
    :image_base, :section_alignment, :file_alignment, :os_version, 
    :image_version, :subsystem_version, 
    :size_of_image, :subsystem, :dll_characteristics, 
    :size_of_stack_reserve, :size_of_stack_commit, :size_of_heap_reserve, 
    :size_of_heap_commit, :loader_flags, :optional_data_directory, 
    :section_info_list, :image_body
  
  private
  def initialize
    @machine = Pe32Const::MACHINE_TYPE_I386
    @timestamp = nil
    @pointer_to_symbol_table = 0
    @number_of_symbols = 0
    @size_of_optional_header = 0xe0
    @characteristics = Pe32Const::DEFAULT_CHARACTERISTICS
    @magic_number = Pe32Const::MAGIC_NUMBER_PE32
    @linker_version = PeVersion.new(1, 0)
    @size_of_code = 0
    @size_of_initialized_data = 0
    @size_of_uninitialized_data = 0
    @entry_point = 0
    @base_of_code = 0
    @base_of_data = 0
    @image_base = Pe32Const::DEFAULT_IMAGE_BASE_ADDRESS
    @section_alignment = Pe32Const::DEFAULT_SECTION_ALIGNMENT
    @file_alignment = Pe32Const::DEFAULT_FILE_ALIGNMENT
    @os_version = PeVersion.new(1, 0)
    @image_version = PeVersion.new(0, 0)
    @subsystem_version = PeVersion.new(4, 0)
    @size_of_image = 0
    @subsystem = Pe32Const::SUBSYSTEM_GUI
    @dll_characteristics = 0
    @size_of_stack_reserve = 0x1000
    @size_of_stack_commit = 0x1000
    @size_of_heap_reserve = 0x10000
    @size_of_heap_commit = 0
    @loader_flags = 0
    @optional_data_directory = Pe32DataDirectory.new
    @section_info_list = []
    @image_body = ""
  end
  def int2bin(data, size)
    BinaryConverter.int2bin(data, size)
  end
  def int_align(val, size)
    CodeUtil.int_align(val, size)
  end
  def str_align(data, size)
    CodeUtil.str_align(data, size)
  end
  def timestamp_to_int(value)
    if value
      (value - Time.new(1970, 1, 1)).to_i
    else
      0
    end
  end
  def create_msdos_stub
    BinaryConverter.hex2bin("0E1FBA0E00B409CD21B8014CCD21") + "This program cannot be run in DOS mode.\r\n$"
  end
  
  public
  def self.calc_header_size(num_of_sections)
    Pe32Const::FIXED_HEADER_SIZE + (num_of_sections * Pe32Const::SIZE_OF_SECTION_INFO)
  end
  def to_bin
    if @file_alignment < 0x200
      raise "PE32.file_alignment must not less than 512, #{@file_alignment} given."
    elsif @file_alignment > 0xffff
      raise "PE32.file_alignment must not greater than 65535, #{@file_alignment} given."
    elsif (@file_alignment % 2) != 0
      raise "PE32.file_alignment must be a power of 2, #{@file_alignment} given."
    elsif @section_alignment < @file_alignment
      raise "PE32.section_alignment (#{@section_alignment}) must not less than PE32.file_alignment (#{@file_alignment})."
    elsif (@image_body.length > 0) && ((@image_body.length % @file_alignment) != 0)
      raise "The size of PE32.image_body (#{@image_body.length}) must be aligned with the PE32.file_alignment (#{@file_alignment})."
    end
    
    mz_struct = MzStruct.new
    mz_struct.extra_bytes = 0x80
    mz_struct.num_of_pages = 1
    mz_struct.header_size = 4
    mz_struct.initial_ss = 0
    mz_struct.initial_sp = 0x140
    mz_struct.relocation_table = 0x40
    mz_struct.overlay_info = (0.chr * 0x20) + int2bin(0x80, :word) + int2bin(0, :word)
    mz_struct.image_body = create_msdos_stub
    
    file_timestamp = @timestamp ? @timestamp : Time.new
    raw_header_size = self.class.calc_header_size(@section_info_list.count)
    size_of_headers = int_align(raw_header_size, @file_alignment)
    section_info_bin = @section_info_list.map{|x|x.to_bin(size_of_headers)}.join
    
    header = 
      [
        str_align(mz_struct.to_bin, 0x10), 
        "PE\0\0",                                             # 0080
        
        # COFF File Header
        int2bin(@machine, :word),                             # 0084
        int2bin(@section_info_list.count, :word),             # 0086
        int2bin(timestamp_to_int(file_timestamp), :dword),    # 0088
        int2bin(@pointer_to_symbol_table, :dword),            # 008C
        int2bin(@number_of_symbols, :dword),                  # 0090
        int2bin(@size_of_optional_header, :word),             # 0094
        int2bin(@characteristics, :word),                     # 0096
        
        # Optional Header
        int2bin(@magic_number, :word),                        # 0098
        int2bin(@linker_version.major, :byte),                # 009A
        int2bin(@linker_version.minor, :byte),                # 009B
        int2bin(@size_of_code, :dword),                       # 009C
        int2bin(@size_of_initialized_data, :dword),           # 00A0
        int2bin(@size_of_uninitialized_data, :dword),         # 00A4
        int2bin(@entry_point, :dword),                        # 00A8
        int2bin(@base_of_code, :dword),                       # 00AC
        int2bin(@base_of_data, :dword),                       # 00B0
        int2bin(@image_base, :dword),                         # 00B4
        int2bin(@section_alignment, :dword),                  # 00B8
        int2bin(@file_alignment, :dword),                     # 00BC
        int2bin(@os_version.major, :word),                    # 00C0
        int2bin(@os_version.minor, :word),                    # 00C2
        int2bin(@image_version.major, :word),                 # 00C4
        int2bin(@image_version.minor, :word),                 # 00C6
        int2bin(@subsystem_version.major, :word),             # 00C8
        int2bin(@subsystem_version.minor, :word),             # 00CA
        int2bin(win32_version_value = 0, :dword),             # 00CC
        int2bin(@size_of_image, :dword),                      # 00D0
        int2bin(size_of_headers, :dword),                     # 00D4
        int2bin(checksum = 0, :dword),                        # 00D8
        int2bin(@subsystem, :word),                           # 00DC
        int2bin(@dll_characteristics, :word),                 # 00DE
        int2bin(@size_of_stack_reserve, :dword),              # 00E0
        int2bin(@size_of_stack_commit, :dword),               # 00E4
        int2bin(@size_of_heap_reserve, :dword),               # 00E8
        int2bin(@size_of_heap_commit, :dword),                # 00EC
        int2bin(@loader_flags, :dword),                       # 00F0
        int2bin(@optional_data_directory.count, :dword),      # 00F4
        @optional_data_directory.to_bin,                      # 00F8
        section_info_bin,                                     # 0178
      ]
    
    str_align(header.join, @file_alignment) + @image_body
  end
end
