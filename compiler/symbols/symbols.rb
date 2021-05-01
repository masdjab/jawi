class Symbols
  attr_reader :items
  def initialize
    @items = []
  end
  def count
    @items.count
  end
  def [](index)
    @items[index]
  end
  def <<(item)
    @items << item
  end
  def empty?
    @items.empty?
  end
  def find(context, name, search_in_parent)
    if @items.empty?
      nil
    else
      if !search_in_parent
        target_contexts = [context.to_s]
      else
        target_contexts = []
        current = context
        while current
          target_contexts << current.to_s
          current = current.parent
        end
      end
      
      @items.find{|s|target_contexts.include?(s.context.to_s) && (s.name == name)}
    end
  end
end
