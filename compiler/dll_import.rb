class DllImport
  attr_reader :module_name, :function_name
  
  def initialize(module_name, function_name)
    @module_name = module_name
    @function_name = function_name
  end
end
