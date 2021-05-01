class SymbolBase
  attr_reader :context, :name, :type, :modifiers

  private
  def initialize(context, name, type, modifiers = [])
    @context = context
    @name = name
    @type = type
    @modifiers = modifiers
  end
  
  public
  def to_s
    "#{@context}.#{self.class}(#{@name})"
  end
end
