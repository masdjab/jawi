require_relative '../../../libs/code_util'
require_relative 'pe32_section_info'


class Pe32SectionTable
  def initialize(pe_struct, section_base_address = 0)
    @pe_struct = pe_struct
    @sections = {}
    @section_address = section_base_address
    @file_offset = 0
  end
  def int_align(data, size)
    CodeUtil.int_align(data, size)
  end
  def str_align(data, size)
    CodeUtil.str_align(data, size)
  end
  def fetch_sections_by_name(section_name = nil)
    if section_name
      if !section_name.is_a?(String)
        raise "The 'section_name' parameter must be a String, #{section_name.class} given."
      elsif !@sections.key?(section_name)
        raise "Invalid section_name: '#{section_name}'."
      else
        [@sections[section_name]]
      end
    else
      @sections.values
    end
  end

  public
  def key?(key)
    @sections.key?(key)
  end
  def add(section)
    section.setup @section_address, @file_offset
    section_info = Pe32SectionInfo.new(section)
    section_info.virtual_size = section.data.length
    section_info.virtual_address = @section_address
    section_info.size_of_raw_data = int_align(section_info.virtual_size, @pe_struct.file_alignment)
    section_info.pointer_to_raw_data = @file_offset
    @file_offset += section_info.size_of_raw_data
    @section_address += int_align(section.data.length, @pe_struct.section_alignment)
    @sections[section.name] = section_info
  end
  def items
    @sections
  end
  def [](key)
    @sections[key]
  end
  def find_by_type(type)
    @sections.values.find{|s|s.section.type == type}
  end
  def get_size_of_image(section_name = nil)
    fetch_sections_by_name(section_name).inject(0) do |a,b|
      a + int_align(b.virtual_size, @pe_struct.section_alignment)
    end
  end
  def get_image(section_name = nil)
    fetch_sections_by_name(section_name).map{|s|str_align(s.section.data, @pe_struct.file_alignment)}.join
  end
end
