require_relative '../size_alignment'
require_relative 'pe32_const'


class Pe32SizeAlignment < SizeAlignment
  attr_reader :section_alignment, :file_alignment
  def initialize(section_alignment = Pe32Const::DEFAULT_SECTION_ALIGNMENT, file_alignment = Pe32Const::DEFAULT_FILE_ALIGNMENT)
    super(section_alignment, file_alignment)
  end
end
