require_relative '../../../libs/code_util'
require_relative 'pe32_section'


class Pe32SectionTable
  def initialize(alignment, section_base_address = 0)
    @alignment = alignment
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
  def append(section)
    puts "section '#{section.name}' => file offset: #{@file_offset.to_s(16)}"
    section.setup @section_address, @file_offset
    @file_offset += section.size_of_raw_data
    @section_address += int_align(section.virtual_size, @alignment.section_alignment)
    @sections[section.name] = section
  end
  def items
    @sections
  end
  def [](key)
    @sections[key]
  end
  def find_by_type(type)
    @sections.values.find{|s|s.type == type}
  end
  def get_size_of_image(section_name = nil)
    fetch_sections_by_name(section_name).inject(0) do |a,b|
      a + int_align(b.virtual_size, @alignment.section_alignment)
    end
  end
  def get_image(section_name = nil)
    fetch_sections_by_name(section_name).map{|s|str_align(s.data, @alignment.file_alignment)}.join
  end
end
