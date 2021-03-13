require_relative '../../../libs/binary_converter'


class Pe32SectionInfo
  attr_accessor \
    :section, :virtual_size, :virtual_address, :size_of_raw_data,
    :pointer_to_raw_data, :pointer_to_relocations, :pointer_to_line_numbers,
    :number_of_relocations, :number_of_line_numbers

  private
  def initialize(section)
    @section = section
    @virtual_size = 0
    @virtual_address = 0
    @size_of_raw_data = 0
    @pointer_to_raw_data = 0
    @pointer_to_relocations = 0
    @pointer_to_line_numbers = 0
    @number_of_relocations = 0
    @number_of_line_numbers = 0
  end
  def int2bin(data, size)
    BinaryConverter.int2bin(data, size)
  end

  public
  def to_bin(base_offset = 0)
    raw_data_offset = @pointer_to_raw_data ? base_offset + @pointer_to_raw_data : 0

    temp =
        [
            (@name ? @name[0..7] : "").ljust(8, 0.chr),
            int2bin(@virtual_size, :dword),
            int2bin(@virtual_address, :dword),
            int2bin(@size_of_raw_data, :dword),
            int2bin(raw_data_offset, :dword),
            int2bin(@pointer_to_relocations, :dword),
            int2bin(@pointer_to_line_numbers, :dword),
            int2bin(@number_of_relocations, :word),
            int2bin(@number_of_line_numbers, :word),
            int2bin(@section.flag, :dword)
        ]

    temp.join
  end
end
