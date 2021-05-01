class Function < SymbolBase
  attr_reader :arguments
  
  private
  def initialize(context, name, type, arguments, modifiers = [])
    super(context, name, type, modifiers)
    @arguments = arguments
  end
end
