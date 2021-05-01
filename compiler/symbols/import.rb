class Import < SymbolBase
  attr_reader :dll_entry, :arguments
  
  private
  def initialize(context, name, dll_entry, type, arguments, modifiers = [])
    super(context, name, type, modifiers)
    @dll_entry = dll_entry
    @arguments = arguments
  end
end
