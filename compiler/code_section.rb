class Section
  FLAG_READABLE = 1
  FLAG_WRITABLE = 2
  FLAG_EXECUTABLE = 4
  FLAG_UNINITIALIZED = 8
  FLAG_INITIALIZED = 16
end


class SectionBase
  attr_reader   :name, :type, :flag, :alignment
  attr_accessor :data, :section_base_address
  
  private
  def initialize(name, type, flag, alignment, data = "")
    @name = name
    @type = type
    @flag = flag
    @data = data
    @alignment = alignment
    @section_base_address = 0
    @section_file_offset = 0
  end
  
  public
  def setup(section_base_address, section_file_offset)
    @section_base_address = section_base_address
    @section_file_offset = section_file_offset
  end
end


class StandardSection < SectionBase
end
