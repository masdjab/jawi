require_relative '../../../libs/binary_converter'


class Pe32Rva
  attr_accessor :address, :size
  def initialize(address = 0, size = 0)
    @address = address
    @size = size
  end
  def to_bin
    [@address, @size].map{|x|BinaryConverter.int2bin(x, :dword)}.join
  end
end
