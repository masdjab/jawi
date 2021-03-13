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
    pe_struct.image_base = @base_address

    raw_header_size = Pe32Struct.calc_header_size(object_code.sections.count)
    size_of_headers = int_align(raw_header_size, pe_struct.section_alignment)
    section_table = Pe32SectionTable.new(pe_struct, size_of_headers)
    object_code.sections.each{|s|section_table.add s}
    section_info_code = section_table.find_by_type(:code)
    section_info_data = section_table.find_by_type(:data)
    section_info_import = section_table[".idata"]
    binary_image = section_table.get_image

    data_offset = section_info_data.virtual_address
    object_code.references.each do |ref|
      if ref.resolver.is_a?(DataResolver32)
        resolved_value = ref.resolver.resolve_reference(@base_address + data_offset)
      elsif ref.resolver.is_a?(ImportResolver32)
        resolved_value = ref.resolver.resolve_reference(section_info_import.section)
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

    pe_struct.optional_data_directory.import.address = section_info_import.virtual_address
    pe_struct.optional_data_directory.import.size = section_info_import.virtual_size
    pe_struct.size_of_code = int_align(section_info_code.section.data.length, pe_struct.file_alignment)
    pe_struct.size_of_initialized_data = int_align(section_info_data.section.data.length, pe_struct.file_alignment)
    pe_struct.base_of_code = section_info_code.virtual_address
    pe_struct.base_of_data = section_info_import.virtual_address
    pe_struct.entry_point = section_info_code.virtual_address
    pe_struct.size_of_image = size_of_headers + section_table.get_size_of_image
    pe_struct.section_info_list = section_table.items.values
    pe_struct.image_body = binary_image
    pe_struct.to_bin
  end
end
