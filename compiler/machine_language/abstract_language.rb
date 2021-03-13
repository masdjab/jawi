require_relative '../macine_code'

module Compiler
  module MachineLanguage
    class AbstractLanguage
      private
      def raise_not_implemented
        raise "Method not implemented."
      end
      
      public
      def set_accumulator(value)
        raise_not_implmented
      end
      def push_accumulator
        raise_not_implmented
      end
      def push_immediate(value)
        raise_not_implmented
      end
      def get_global_variable(location)
        raise_not_implmented
      end
      def set_global_variable(location, value)
        raise_not_implmented
      end
      def get_local_variable(index)
        raise_not_implmented
      end
      def set_local_variable(index, value)
        raise_not_implmented
      end
      def get_parameter(index)
        raise_not_implmented
      end
      def call(relative_distance)
        raise_not_implmented
      end
      def call_indirect(location)
        raise_not_implmented
      end
      def function_enter(locals_count = 0)
        raise_not_implmented
      end
      def function_leave(locals_count = 0)
        raise_not_implmented
      end
      def return(stack_adjust = 0)
      end
      def jump(relative_distance)
        raise_not_implmented
      end
    end
  end
end
