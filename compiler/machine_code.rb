module Compiler
  class MachineCode
    attr_reader :code, :argpos, :arglen
    
    def initialize(code, argpos, arglen)
      @code = code
      @argpos = argpos
      @arglen = arglen
    end
  end
end
