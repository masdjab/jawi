require_relative '../../libs/binary_converter'

class DataResolver32
  def initialize(offset)
    @offset = offset
  end
  def resolve_reference(base_address)
    BinaryConverter.int2bin(base_address + @offset, :dword)
  end
end
