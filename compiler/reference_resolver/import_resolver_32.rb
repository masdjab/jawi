require_relative '../../libs/binary_converter'

class ImportResolver32
  def initialize(import_function)
    @import_function = import_function
  end
  def resolve_reference(import_table)
    BinaryConverter.int2bin(import_table.get_address(@import_function), :dword)
  end
end
