class Section
  FLAG_READABLE = 1
  FLAG_WRITABLE = 2
  FLAG_EXECUTABLE = 4
  FLAG_UNINITIALIZED = 8
  FLAG_INITIALIZED = 16
end


class SectionBase
  attr_reader   :name, :type, :flag
  attr_accessor :data

  private
  def initialize(name, type, flag, data = "")
    @name = name
    @type = type
    @flag = flag
    @data = data
  end

  public
  def setup(section_base_address, section_file_offset)
    # do nothing
  end
end


class StandardSection < SectionBase
end
