require_relative '../../../libs/binary_converter'
require_relative '../../../libs/code_util'


class Pe32ImportSection < SectionBase
  attr_reader :image_base_address, :section_base_address

  private
  def initialize(name, type, flag, image_base_address = 0x400000, section_base_address = 0)
    super(name, type, flag, "")
    @image_base_address = image_base_address
    @section_base_address = section_base_address
    @libraries = []
    @functions = []
    @imports_changed = true
  end
  def str_align(data, size)
    CodeUtil.str_align(data, size)
  end
  def int2bin(data, size)
    BinaryConverter.int2bin(data, size)
  end
  def append_name_to_table(table, name)
    name_len_odd = (name.length % 2) != 0
    table + name + (0.chr * (1 + (name_len_odd ? 0 : 1)))
  end
  def build_section_body
    if @imports_changed
      directory_table = str_align(0.chr * (4 * 5 * (@libraries.count + 1)), 0x10)
      lookup_table_size = 4 * (@libraries.count + @functions.count)
      lookup_table = str_align(0.chr * (2 * lookup_table_size), 0x10)
      sorted_libraries = @libraries.sort
      lib_name_table = ""
      fun_name_table = ""

      ln_index = 0
      offset = @section_base_address + directory_table.length + lookup_table.length
      sorted_libraries.each do |lib|
        directory_table[(4 * 5 * ln_index) + 12, 4] = int2bin(offset + lib_name_table.length, :dword)
        lib_name_table = append_name_to_table(lib_name_table, lib)
        ln_index += 1
      end
      lib_name_table = append_name_to_table(lib_name_table, "")
      lib_name_table = str_align(lib_name_table, 0x10)

      ln_index = 0
      fn_index = 0
      iat_offset = @section_base_address + directory_table.length
      str_offset = @section_base_address + directory_table.length + lookup_table.length + lib_name_table.length
      sorted_libraries.each do |lib|
        directory_table[(4 * 5 * ln_index) + 0, 4] = int2bin(iat_offset + lookup_table_size + 4 * fn_index, :dword)
        directory_table[(4 * 5 * ln_index) + 16, 4] = int2bin(iat_offset + 4 * fn_index, :dword)
        fn_names = @functions.select{|f|f[:library] == lib}.map{|f|f[:function]}.sort
        fn_names.each do |fun|
          fx = @functions.find{|f|(f[:library] == lib) && (f[:function] == fun)}
          fx[:section_address] = @image_base_address + iat_offset + 4 * fn_index
          str_address = int2bin(str_offset + fun_name_table.length, :dword)
          lookup_table[4 * fn_index, 4] = str_address
          lookup_table[lookup_table_size + 4 * fn_index, 4] = str_address
          fun_name_table = append_name_to_table(fun_name_table, int2bin(0, :word) + fun)
          fn_index += 1
        end
        fn_index += 1
        ln_index += 1
      end
      fun_name_table = str_align(fun_name_table, 0x10)

      @imports_changed = false

      @data = directory_table + lookup_table + lib_name_table + fun_name_table
    end

    @data
  end

  public
  def setup(section_base_address, section_file_offset)
    puts "#{self.class}.setup(0x#{image_base_address.to_s(16)}, 0x#{section_base_address.to_s(16)}, 0x#{section_file_offset.to_s(16)})"
    @section_base_address = section_base_address
    @imports_changed = true
  end
  def add_import_item(dll_import)
    if !@libraries.include?(dll_import.module_name)
      @libraries << dll_import.module_name
    end
    if @functions.find{|x|(x[:lib] == dll_import.module_name) && (x[:fun] == dll_import.function_name)}.nil?
      @functions << {library: dll_import.module_name, function: dll_import.function_name, section_address: 0}
    end
  end
  def data
    build_section_body
  end
  def get_address(dll_import)
    if (fun = @functions.find{|f|(f[:library] == dll_import.module_name) && (f[:function] == dll_import.function_name)}).nil?
      raise "Import entry #{dll_import.module_name}:#{dll_import.function_name} not found."
    else
      fun[:section_address]
    end
  end
end
