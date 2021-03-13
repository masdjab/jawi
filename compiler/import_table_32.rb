class ImportTable32
  attr_accessor :image_base_address
  
  private
  def initialize(base_address = 0)
    @base_address = 0
    @import_table = {}
  end
  def entry_key(import_function)
    "#{import_function.module_name}:#{import_function.function_name}"
  end
  
  public
  def set_address(import_function, offset)
    @import_table[entry_key(import_function)] = @base_address + offset
  end
  def get_address(import_function)
    lookup_key = entry_key(import_function)
    
    if !@import_table.key?(lookup_key)
      raise "Cannot find import address for '#{lookup_key}'."
    else
      @base_address + @import_table[lookup_key]
    end
  end
end
