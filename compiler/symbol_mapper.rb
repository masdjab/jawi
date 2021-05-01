class SymbolMapper
  def initialize(symbol_map)
    @symbol_map = symbol_map
    @local_indices = {}
  end
  def map_symbols(symbols)
    symbols.items.each do |s|
      if s.is_a?(Variable)
        if !@local_indices.key?(s.context)
          @local_indices[s.context] = 0
        end
        @symbol_map[s] = @local_indices[s.context]
        @local_indices[s.context] += 1
      end
    end
  end
end
