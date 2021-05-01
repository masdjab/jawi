require_relative '../../machine_language/intel32'
require_relative '../../symbol_ref'
require_relative '../../reference_resolver/data_resolver_32'
require_relative '../../reference_resolver/string_resolver_32'
require_relative '../../reference_resolver/import_resolver_32'


module Asm
  class InstructionTranslator
    private
    def initialize(sections, symbols, symbol_maps, references)
      @sections = sections
      @symbols = symbols
      @symbol_maps = symbol_maps
      @references = references
      @code = @sections['code']
      @data = @sections['data']
      @string = @sections['string']
      @import = @sections['import']
      @language = ::Compiler::MachineLanguage::Intel32.new()
      @contexts = [Context.new('__main__', :module, nil)]
      @data_type = :dword
      @data_size = 4
      @blocks = []
    end
    def current_context
      @contexts.last
    end
    def append_code(code)
      @code.data << code
    end
    def add_string(text)
      offset = @string.data.length
      @string.data << text
      offset
    end
    def get_value(lex)
      if lex.is_a?(Token) && (lex.type == :identifier)
        value = @symbols.find(current_context, lex.text, true)
        if value.nil?
          puts "Error handling get_value: Undefined name or function '#{lex.text}'."
        else
          if value.context.type == :function
            mc = @language.get_local_variable(0, :dword)
          else
            mc = @language.get_global_variable(0, :dword)
          end
          
          offset = @data_size * @symbol_maps[value]
          puts "offset(#{lex.text}) = #{offset}"
          @references << SymbolRef.new(@code.name, @code.data.length + mc.argpos, DataResolver32.new(offset))
          append_code mc.code
        end
      elsif lex.is_a?(Token) && (lex.type == :string)
        mc = @language.get_local_variable(0, :dword)
        append_code mc.code
      elsif lex.is_a?(Token) && (lex.type == :number)
        mc = @language.set_accumulator(lex.text.to_i, :dword)
        append_code mc.code
      else
        puts "Cannot handle get_value(#{lex.inspect})"
      end
    end
    def set_value(lex)
      if lex.is_a?(Token) && (lex.type == :identifier)
        value = @symbols.find(current_context, lex.text, true)
        if value.nil?
          puts "Error handling set_value: Undefined name or function '#{lex.text}'."
        else
          if value.context.type == :function
            mc = @language.set_local_variable(0, @data_type)
          else
            mc = @language.set_global_variable(0, @data_type)
          end
          
          offset = @data_size * @symbol_maps[value]
          @references << SymbolRef.new(@code.name, @code.data.length + mc.argpos, DataResolver32.new(offset))
          append_code mc.code
        end
      else
        puts "Cannot handle set_value(#{lex.inspect})"
      end
    end
    def pass_arguments(arguments)
      arguments.reverse.each do |arg|
        get_value arg
        mc = @language.push_accumulator
        append_code mc.code
      end
    end
    def handle_import(lex)
      function = @symbols.find(current_context, lex.name.text, true)
      if function.nil?
        puts "Cannot handle import, function '#{lex.name.text}' not found."
      elsif !function.is_a?(Import)
        puts "Cannot handle import, function '#{lex.name.text}' is not an import function."
      else
        @import.add_import_item function.dll_entry
      end
    end
    def handle_function_call(lex)
      function = @symbols.find(current_context, lex.name.text, true)
      
      if function.nil?
        puts "Cannot handle function call, function '#{lex.name.text}' not found."
      else
        pass_arguments lex.arguments
        mc = @language.call_indirect(0)
        
        if function.is_a?(Function)
          puts "Cannot handle function call 1: '#{lex.name.text}'."
        elsif function.is_a?(Import)
          @references << SymbolRef.new(@code.name, @code.data.length + mc.argpos, ImportResolver32.new(function.dll_entry))
        else
          puts "Cannot handle function call 2: '#{lex.name.text}'."
        end
        
        append_code mc.code
      end
    end
    def handle_expression(lex)
      lex.nodes.each do |node|
        if node.type == :string
          str_offset = add_string(node.text)
          mc = @language.set_accumulator(0, :dword)
          @references << SymbolRef.new(@code.name, @code.data.length + mc.argpos, StringResolver32.new(str_offset))
          append_code mc.code
        end
      end
    end
    def handle_assignment(lex)
      handle_expression lex.value
      set_value lex.variable
    end
    
    public
    def translate_instructions(lexes)
      lexes.each do |lex|
        if lex.type == :import
          handle_import lex
        elsif lex.type == :call
          handle_function_call lex
        elsif lex.type == :assignment
          handle_assignment lex
        end
      end
    end
  end
end
