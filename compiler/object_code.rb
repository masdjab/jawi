class ObjectCode
  attr_reader :base_address, :alignment, :sections, :references
  
  def initialize(base_address, alignment)
    @base_address = base_address
    @alignment = alignment
    @sections = []
    @references = []
  end
end
