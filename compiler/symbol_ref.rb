class SymbolRef
  attr_reader :context, :location, :resolver
  
  def initialize(context, location, resolver)
    @context = context
    @location = location
    @resolver = resolver
  end
end
