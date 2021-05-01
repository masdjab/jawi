require_relative '../../import_table_32'
require_relative '../../../libs/binary_converter'
require_relative '../../../libs/code_util'
require_relative 'pe32_struct'


class Pe32Formatter
  private
  def initialize(base_address = 0x400000)
    @base_address = base_address
  end
  def hex2bin(data)
    BinaryConverter.hex2bin(data)
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
  
  public
  def format(object_code)
    pe_struct = Pe32Struct.new
    pe_struct.alignment = object_code.alignment
    pe_struct.image_base = @base_address
    
    raw_header_size = Pe32Struct.calc_header_size(object_code.sections.count)
    header_size_in_pages = int_align(raw_header_size, object_code.alignment.file_alignment)
    header_size_in_section = int_align(raw_header_size, object_code.alignment.section_alignment)
    puts "raw_header_size: 0x#{raw_header_size.to_s(16)}"
    puts "header_size_in_pages: 0x#{header_size_in_pages.to_s(16)}"
    puts "header_size_in_section: 0x#{header_size_in_section.to_s(16)}"
    section_table = Pe32SectionTable.new(object_code.alignment, header_size_in_section)
    object_code.sections.each{|s|section_table.append s}
    code_sction = section_table.find_by_type(:code)
    data_section = section_table.find_by_type(:data)
    string_section = section_table.find_by_type(:string)
    import_section = section_table[".idata"]
    binary_image = section_table.get_image
    
    data_offset = data_section.virtual_address
    string_offset = string_section.virtual_address
    object_code.references.each do |ref|
      if ref.resolver.is_a?(DataResolver32)
        resolved_value = ref.resolver.resolve_reference(@base_address + data_offset)
      elsif ref.resolver.is_a?(StringResolver32)
        resolved_value = ref.resolver.resolve_reference(@base_address + string_offset)
      elsif ref.resolver.is_a?(ImportResolver32)
        resolved_value = ref.resolver.resolve_reference(import_section)
      else
        raise "Cannot resolve reference of type '#{ref.resolver.class}'."
      end

      if section_table.key?(ref.context)
        offset = section_table[ref.context].pointer_to_raw_data + ref.location
        binary_image[offset, resolved_value.length] = resolved_value
      else
        raise "Reference context '#{ref.context}' not found."
      end
    end
    
    pe_struct.optional_data_directory.import.address = import_section.virtual_address
    pe_struct.optional_data_directory.import.size = import_section.virtual_size
    pe_struct.size_of_code = int_align(code_sction.data.length, object_code.alignment.file_alignment)
    pe_struct.size_of_uninitialized_data = int_align(data_section.data.length, object_code.alignment.file_alignment)
    pe_struct.size_of_initialized_data = 
      int_align(string_section.data.length, object_code.alignment.file_alignment) \
      + int_align(import_section.data.length, object_code.alignment.file_alignment)
    pe_struct.base_of_code = code_sction.virtual_address
    pe_struct.base_of_data = data_section.virtual_address
    pe_struct.entry_point = code_sction.virtual_address
    pe_struct.size_of_image = header_size_in_section + section_table.get_size_of_image
    pe_struct.section_info_list = section_table.items.values
    pe_struct.image_body = binary_image
    pe_struct.to_bin
  end
end
