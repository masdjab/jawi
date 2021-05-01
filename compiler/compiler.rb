require_relative '../libs/code_util'
require_relative 'parser/parsing_exceptions'
require_relative 'lang/asm/lexer'
require_relative 'lang/asm/name_detector'
require_relative 'lang/asm/instruction_translator'
require_relative 'object_code'
require_relative 'code_section'
require_relative 'symbol_mapper'
require_relative 'output_formatter/pe32/pe32_size_alignment'
require_relative 'output_formatter/pe32/pe32_const'
require_relative 'output_formatter/pe32/pe32_import_section'
require_relative 'output_formatter/pe32/pe32_formatter'


module Asm
  class Compiler
    private
    def initialize(symbols, source_provider, main_source_name)
      @symbols = symbols
      @source_provider = source_provider
      @main_source_name = main_source_name
    end
    def int_align(val, size)
      CodeUtil.int_align(val, size)
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
    def detect_names(lexes)
      name_detector = NameDetector.new(@symbols)
      name_detector.consume lexes
    end
    def translate_instructions(sections, symbols, symbol_maps, references, lexes)
      puts "symbols:"
      @symbols.items.each{|s|puts "#{s.class}(#{s.context}, #{s.name})"}
      puts
      
      translator = InstructionTranslator.new(sections, symbols, symbol_maps, references)
      translator.translate_instructions lexes
    end
    
    public
    def compile
      const = Pe32Const
      size_alignment = Pe32SizeAlignment.new
      source = @source_provider.get_source(@main_source_name)
      position_info_provider = PositionInfoProvider.new(source)
      object_code = ObjectCode.new(Pe32Const::DEFAULT_IMAGE_BASE_ADDRESS, size_alignment)
      symbol_maps = {}
      symbol_mapper = SymbolMapper.new(symbol_maps)
      
      flags = const::SECTION_READABLE | const::SECTION_WRITABLE | const::SECTION_INITIALIZED_DATA
      import_section = Pe32ImportSection.new('.idata', :import, flags, size_alignment)
      import_section.image_base_address = object_code.base_address
      
      sections = {
        'code'    => StandardSection.new('.text', :code, 0, @alignment, ""), 
        'string'  => StandardSection.new('.bss', :string, 0, @alignment, ""), 
        'import'  => import_section, 
      }
      
      lexer = Asm::Lexer.new
      lexes = lexer.lex(source)
      
      puts lexes.map{|lex|lex.to_s}
      puts
      
      detect_names lexes
      symbol_mapper.map_symbols @symbols
      translate_instructions sections, @symbols, symbol_maps, object_code.references, lexes
      
      data_count = @symbols.items.select{|s|s.is_a?(Variable) && (s.context.name == '__main__')}.count
      
      code_section = 
        Pe32Section.new(
          ".text", 
          :code, 
          const::SECTION_CODE | const::SECTION_EXECUTABLE | const::SECTION_READABLE, 
          size_alignment, 
          sections['code'].data, 
          sections['code'].data.length
        )
      data_section = 
        Pe32Section.new(
          ".data", 
          :data, 
          const::SECTION_READABLE | const::SECTION_WRITABLE | const::SECTION_UNINITIALIZED_DATA, 
          size_alignment, 
          "", 
          data_count * 4
        )
      string_section = 
        Pe32Section.new(
          ".bss", 
          :string, 
          const::SECTION_READABLE | const::SECTION_WRITABLE | const::SECTION_INITIALIZED_DATA, 
          size_alignment, 
          sections['string'].data, 
          sections['string'].data.length
        )
      
      object_code.sections << code_section
      object_code.sections << data_section
      object_code.sections << string_section
      object_code.sections << import_section
      
      formatter = Pe32Formatter.new
      executable_image = formatter.format(object_code)
      File.binwrite("output.exe", executable_image)
    end
  end
end
