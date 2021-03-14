require_relative '../macine_code'

module Compiler
  module MachineLanguage
    class AbstractLanguage
      private
      def raise_not_implemented
        raise "Method not implemented."
      end
      
      public
      def set_accumulator(value, size)
        raise_not_implemented
      end
      def push_accumulator
        raise_not_implemented
      end
      def push_immediate(value)
        raise_not_implemented
      end
      def get_global_variable(location, size)
        raise_not_implemented
      end
      def set_global_variable(location, size, value)
        raise_not_implemented
      end
      def get_local_variable(index, size)
        raise_not_implemented
      end
      def set_local_variable(index, size, value)
        raise_not_implemented
      end
      def get_parameter(index, size)
        raise_not_implemented
      end
      def call(relative_distance)
        raise_not_implemented
      end
      def call_indirect(location)
        raise_not_implemented
      end
      def function_enter(locals_count = 0)
        raise_not_implemented
      end
      def function_leave(locals_count = 0)
        raise_not_implemented
      end
      def return(stack_adjust = 0)
      end
      def jump(relative_distance)
        raise_not_implemented
      end
    end
  end
end
