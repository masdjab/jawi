class SizeAlignment
  attr_reader :section_alignment, :file_alignment
  def initialize(section_alignment, file_alignment)
    @section_alignment = section_alignment
    @file_alignment = file_alignment
  end
end
