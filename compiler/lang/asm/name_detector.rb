require_relative 'constants'
require_relative '../../lexes_consumer'
require_relative '../../symbols/init'
require_relative '../../context'
require_relative '../../parser/parsing_exceptions'
require_relative '../../dll_import'


module Asm
  class NameDetector < LexesConsumer
    private
    def initialize(symbols)
      @symbols = symbols
      @contexts = [Context.new('__main__', :module, nil)]
      @blocks = []
    end
    def current_context
      @contexts.last
    end
    def expected_text(pos, expected, found)
      ExpectedTextException.new(position_info(pos), expected, found)
    end
    def unexpected_text(pos, text)
      UnexpectedTextException.new(position_info(pos), text)
    end
    def handle_assignment(lex)
      name = lex.variable.text
      if @symbols.find(@contexts.last, name, true).nil?
        @symbols << Variable.new(@contexts.last, name, nil)
      end
    end
    def handle_function_declaration(lex)
      name = lex.name.text
      if !@symbols.find(current_context, name, false).nil?
        raise ParsingError.new(lex.pos, "Function '#{name}' already defined.")
      elsif current_context.type != :module
        raise ParsingError.new(lex.pos, "Function cannot be nested. => pos: #{lex.pos.inspect}")
      else
        @symbols << Function.new(current_context, name, nil, [])
        @contexts << Context.new(name, :function, current_context)
      end
    end
    def handle_if(lex)
      @blocks << "if"
    end
    def handle_elseif(lex)
    end
    def handle_else(lex)
    end
    def handle_end(lex)
      if !@blocks.empty?
        @blocks.pop
      elsif @contexts.count == 1
        raise ParsingError.new(lex.pos, "Unexpected 'end'.")
      else
        @contexts.pop
      end
    end
    def handle_lib_import(lex)
      name = lex.name
      if !@symbols.find(current_context, name, false).nil?
        raise ParsingError.new(lex.pos, "Variable '#{name.text}' already defined.")
      else
        dll_entry = DllImport.new(lex.library.text, lex.function.text)
        @symbols << Import.new(current_context, name.text, dll_entry, nil, [])
      end
    end
    
    public
    def consume(lexes)
      lexes.each do |lex|
        if lex.is_a?(Lex::Assignment)
          handle_assignment lex
        elsif lex.is_a?(Lex::FunctionDeclaration)
          handle_function_declaration lex
        elsif lex.type == :identifier
          if lex.text == "if"
            handle_if lex
          elsif lex.text == "elseif"
            handle_elseif lex
          elsif lex.text == "else"
            handle_else lex
          elsif lex.text == "end"
            handle_end lex
          end
        elsif lex.is_a?(Lex::LibImport)
          handle_lib_import lex
        end
      end
    end
  end
end
