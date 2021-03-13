class ObjectCode
  attr_reader :sections, :references
  
  def initialize
    @sections = []
    @references = []
  end
end
