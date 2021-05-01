require_relative '../../libs/binary_converter'
require_relative '../machine_code'


module Compiler
  module MachineLanguage
    class Intel32
      private
      def hex2bin(value)
        BinaryConverter.hex2bin(value)
      end
      def int2bin(value, size)
        BinaryConverter.int2bin(value, size)
      end
      def compose(code, argpos, arglen)
        Compiler::MachineCode.new(code, argpos, arglen)
      end
      
      public
      def set_accumulator(value, size)
        compose hex2bin("B8") + int2bin(value, :dword), 1, 4
      end
      def push_immediate(value)
        compose hex2bin("68") + int2bin(value, :dword), 1, 4
      end
      def push_accumulator
        compose hex2bin("50"), 0, 0
      end
      def get_global_variable(location, size)
        compose hex2bin("A1") + int2bin(location, :dword), 1, 4
      end
      def set_global_variable(location, size)
        compose hex2bin("A3") + int2bin(location, :dword), 1, 4
      end
      def get_local_variable(index, size)
        compose hex2bin("8B45") + int2bin(-((index + 1) * 4), :byte), 2, 1
      end
      def set_local_variable(index, size)
        compose hex2bin("8945") + int2bin(-((index + 1) * 4), :byte), 2, 1
      end
      def get_parameter(index, size)
        compose hex2bin("8B45") + int2bin((index + 2) * 4, :byte), 0, 0
      end
      def call(relative_distance)
        compose hex2bin("E8") + int2bin(relative_distance, :dword), 1, 4
      end
      def call_indirect(location)
        compose hex2bin("FF15") + int2bin(location, :dword), 2, 4
      end
      def function_enter(locals_count = 0)
        if locals_count == 0
          compose hex2bin("5589E5"), 0, 0
        else
          compose hex2bin("5589E583EC") + int2bin(locals_count * 4, :byte), 0, 0
        end
      end
      def function_leave(locals_count = 0)
        if stack_adjust == 0
          compose hex2bin("5D"), 0, 0
        else
          compose hex2bin("83C4") + int2bin(locals_count * 4, :byte) + hex2bin("5D") + int2bin(stack_adjust * 4, :word), 2, 2
        end
      end
      def return(stack_adjust = 0)
        if stack_adjust == 0
          compose hex2bin("C3"), 0, 0
        else
          compose hex2bin("C2") + int2bin(stack_adjust * 4, :word), 2, 2
        end
      end
      def jump(relative_distance)
        compose hex2bin("E9") + int2bin(relative_distance, :dword), 1, 4
      end
    end
  end
end
