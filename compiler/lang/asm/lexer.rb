require_relative 'lex_types'
require_relative '../../../libs/fetcher'
require_relative '../../../libs/node_fetcher'
require_relative '../../../libs/position_info_provider'
require_relative '../../parser/parsing_exceptions'
require_relative '../../parser/tokenizer'
require_relative '../../parser/token'


module Asm
  END_OF_LINE = [:cr, :lf, :crlf, :comment]
  OPERABLE_VALUES = [:number, :string, :identifier, :variable, :address, :bracket, :call]
  BRACKETABLE_VALUES = OPERABLE_VALUES + [:operation]
  EXPRESSABLE_VALUES = OPERABLE_VALUES + [:operation]
  
  OPERATOR_PRIORITIES = {
    and: 1, 
    or: 2, 
    star: 3, 
    slash: 3, 
    plus: 4, 
    minus: 4, 
    equal: 5, 
    not_equal: 5, 
    lt: 5, 
    le: 5, 
    gt: 5, 
    ge: 5, 
    and2: 6, 
    or2: 7, 
  }
  
  OPERATORS = OPERATOR_PRIORITIES.keys
  
  class Lexer
    private
    def initialize
      @position_info_provider = nil
      @fetcher = nil
    end
    def position_info(pos)
      @position_info_provider ? @position_info_provider.get_position_info(pos) : pos
    end
    def expected_text(pos, expected, found)
      ExpectedTextException.new(position_info(pos), expected, found)
    end
    def unexpected_text(pos, text)
      UnexpectedTextException.new(position_info(pos), text)
    end
    def is_bracketable_values
      if !@fetcher.next.nil? && (@fetcher.next.type == :comma)
        result = true
        comma = false
        pos = @fetcher.pos
        while @fetcher[pos]
          got_comma = false
          
          if @fetcher[pos].type == :whitespace
            # ignore
          elsif [:cr, :lf, :crlf, :comment].include?(@fetcher[pos].type)
            if comma
              # ignore
            else
              break
            end
          elsif @fetcher[pos].type == :comma
            got_comma = true
          elsif BRACKETABLE_VALUES.include?(@fetcher[pos].type)
            # ignore
          elsif [:rbrk].include?(@fetcher[pos].type)
            break
          else
            result = false
            break
          end
          
          comma = got_comma
          pos += 1
        end
        
        result
      else
        false
      end
    end
    def is_operable_values
      anchor = @fetcher.pos
      first_node = @fetcher.current
      
      if OPERABLE_VALUES.include?(@fetcher[anchor].type) \
      && !@fetcher[anchor + 1].nil? && OPERATORS.include?(@fetcher[anchor + 1].type) \
      && !@fetcher[anchor + 2].nil? && OPERABLE_VALUES.include?(@fetcher[anchor + 2].type)
        result = true
        allows = OPERATORS + OPERABLE_VALUES + [:whitespace]
        
        pos = @fetcher.pos
        while @fetcher[pos]
          if allows.include?(@fetcher[pos].type)
            pos += 1
          elsif [:cr, :lf, :crlf, :comment, :rbrk].include?(@fetcher[pos].type)
            break
          else
            result = false
            break
          end
        end
        
        result
      else
        false
      end
    end
    def is_library_import
      if @fetcher.current.nil? || (@fetcher.current.type != :assignment)
        false
      else
        assignment = @fetcher.current
        if (assignment.value.type != :expression) || (assignment.value.nodes.count != 1)
          false
        elsif assignment.value.nodes[0].type != :call
          false
        elsif assignment.value.nodes[0].name.type != :identifier
          false
        elsif assignment.value.nodes[0].name.text != "import"
          false
        else
          true
        end
      end
    end
    def fetch_address_of
      ampersand = @fetcher.fetch
      name = @fetcher.fetch
      Lex::AddressOf.new(ampersand.pos, name)
    end
    def fetch_values
      values = []
      
      comma = false
      while token = @fetcher.current
        got_comma = false
        
        if token.type == :whitespace
          @fetcher.fetch
        elsif [:cr, :lf, :crlf, :comment].include?(token.type)
          if comma
            @fetcher.fetch
          else
            break
          end
        elsif token.type == :comma
          @fetcher.fetch
          got_comma = true
        elsif BRACKETABLE_VALUES.include?(token.type)
          values << @fetcher.fetch
        else
          break
        end
        
        comma = got_comma
      end
      
      Lex::Values.new(values[0].pos, values)
    end
    def fetch_bracket_with_single_value
      bracket = @fetcher.fetch
      values = @fetcher.fetch
      if @fetcher.current.nil? || (@fetcher.current.type != :rbrk)
        raise expected_text(@fetcher.pos, ')', @fetcher.current ? @fetcher.current.text : nil)
      else
        @fetcher.fetch
        Lex::Bracket.new(bracket.pos, values)
      end
    end
    def fetch_bracket_with_values
      bracket = @fetcher.fetch
      values = @fetcher.fetch
      if @fetcher.current.nil? || (@fetcher.current.type != :rbrk)
        raise expected_text(@fetcher.pos, ')', @fetcher.current ? @fetcher.current.text : nil)
      else
        @fetcher.fetch
        Lex::Bracket.new(bracket.pos, values)
      end
    end
    def fetch_bracket_without_values
      lbrk = @fetcher.fetch
      rbrk = @fetcher.fetch
      Lex::Bracket.new(lbrk.pos, Lex::Values.new(rbrk.pos, []))
    end
    def fetch_single_value_into_expression
      value = @fetcher.fetch
      Lex::Expression.new(value.pos, [value])
    end
    def fetch_single_value_without_bracket
      value = @fetcher.fetch
      Lex::Values.new(value.pos, [value])
    end
    def fetch_return_without_value
      token = @fetcher.fetch
      Lex::Return.new(token.pos)
    end
    def fetch_return_with_value
      token = @fetcher.fetch
      value = @fetcher.fetch
      Lex::Return.new(token.pos, value)
    end
    def fetch_operation
      value1 = @fetcher.fetch
      anchor = @fetcher.pos
      operation_pos = value1.pos
      
      while !@fetcher[anchor].nil? && OPERATORS.include?(@fetcher[anchor].type) \
      && !@fetcher[anchor + 1].nil? && OPERABLE_VALUES.include?(@fetcher[anchor + 1].type)
        operator = @fetcher.fetch
        operation_pos = operator.pos
        value2 = @fetcher.fetch
        
        if (value1.type == :operation) && ((op2 = OPERATOR_PRIORITIES[operator.type]) < (op1 = OPERATOR_PRIORITIES[value1.operator.type]))
          value2 = Lex::Operation.new(operation_pos, operator, value1.value2, value2)
          value1 = Lex::Operation.new(value1.pos, value1.operator, value1.value1, value2)
        else
          value1 = Lex::Operation.new(operation_pos, operator, value1, value2)
        end
        
        anchor = @fetcher.pos
      end
      
      value1
    end
    def fetch_function_declaration
      def_token = @fetcher.fetch
      name_token = @fetcher.fetch
      bracket = @fetcher.fetch
      
      if bracket.type != :bracket
        raise expected_text(bracket.pos.pos, "(", bracket.to_s)
      elsif ![:values, :identifier].include?(bracket.value.type)
        raise expected_text(bracket.pos.pos, "argument", bracket.to_s)
      else
        if bracket.value.type == :identifier
          Lex::FunctionDeclaration.new(def_token.pos.pos, name_token, [bracket.value])
        elsif bracket.value.type == :values
          if !(non_names = bracket.value.items.select{|v|v.type != :identifier}).empty?
            raise expected_text(non_names[0].pos.pos, "identifier", non_names[0].to_s)
          else
            Lex::FunctionDeclaration.new(def_token.pos.pos, name_token, bracket.value.items)
          end
        end
      end
    end
    def fetch_function_call
      name = @fetcher.fetch
      args = @fetcher.fetch
      
      if args.type == :bracket
        args = args.value
      end
      if args.type == :values
        args = args.items
      end
      
      Lex::FunctionCall.new(name.pos, name, args)
    end
    def fetch_variable_assignment
      receiver = @fetcher.fetch
      assign = @fetcher.fetch
      expression = @fetcher.fetch
      Lex::Assignment.new(receiver.pos, receiver, expression)
    end
    def fetch_library_import
      assignment = @fetcher.fetch
      fcall = assignment.value.nodes[0]
      
      if fcall.arguments.count < 1
        raise expected_text(fcall.name.pos + fcall.name.text.length, 'library name', nil)
      elsif fcall.arguments.count < 2
        raise expected_text(fcall.arguments[0].pos + fcall.arguments[0].text.length, 'function name', nil)
      else
        Lex::LibImport.new(assignment.pos, assignment.variable, fcall.arguments[0], fcall.arguments[1])
      end
    end
    
    public
    def lex(source)
      fetcher = Fetcher.new(source)
      @position_info_provider = PositionInfoProvider.new(source)
      tokenizer = Tokenizer.new(fetcher, @position_info_provider)
      nodes = tokenizer.tokenize
      
      nodes = 
        nodes.map do |node|
          if node.type == :string
            Token.new(node.pos, node.type, node.text[1...-1])
          else
            node
          end
        end
      
      done = false
      while !done
        tokens = nodes
        nodes = []
        done = true
        @fetcher = NodeFetcher.new(tokens, [:whitespace])
        
        while token = @fetcher.current
          anchor = @fetcher.pos
          
          if [:whitespace, :cr, :lf, :crlf, :comment].include?(token.type)
            nodes << @fetcher.fetch
          elsif is_bracketable_values
            nodes << fetch_values
            done = false
          elsif (token.type == :lbrk) && !@fetcher.next.nil? && (@fetcher.next.type == :rbrk)
            nodes << fetch_bracket_without_values
            done = false
          elsif (@fetcher[anchor].type == :lbrk) && !@fetcher[anchor + 1].nil? \
          && BRACKETABLE_VALUES.include?(@fetcher[anchor + 1].type) \
          && !@fetcher[anchor + 2].nil? && (@fetcher[anchor + 2].type == :rbrk)
            nodes << fetch_bracket_with_single_value
            done = false
          elsif (token.type == :lbrk) && !@fetcher.next.nil? && (@fetcher.next.type == :values)
            nodes << fetch_bracket_with_values
            done = false
          elsif (@fetcher[anchor].type == :identifier) && !@fetcher[anchor + 1].nil? \
          && BRACKETABLE_VALUES.include?(@fetcher[anchor + 1].type) \
          && (@fetcher[anchor + 2].nil? || END_OF_LINE.include?(@fetcher[anchor + 2].type))
            nodes << @fetcher.fetch
            nodes << fetch_single_value_without_bracket
            done = false
          elsif (@fetcher[anchor].type == :identifier) && (@fetcher[anchor].text == "def") \
          && !@fetcher[anchor + 1].nil? && (@fetcher[anchor + 1].type == :identifier) \
          && !@fetcher[anchor + 2].nil? && (@fetcher[anchor + 2].type == :bracket)
            nodes << fetch_function_declaration
            done = false
          elsif (@fetcher[anchor].type == :identifier) && !@fetcher[anchor + 1].nil? \
          && [:values, :bracket].include?(@fetcher[anchor + 1].type)
            nodes << fetch_function_call
            done = false
          elsif (token.type == :and) && !@fetcher.next.nil? && (@fetcher.next.type == :identifier)
            nodes << fetch_address_of
            done = false
          elsif (@fetcher[anchor].type == :identifier) && (@fetcher[anchor].text == "return") \
          && !@fetcher[anchor + 1].nil? && EXPRESSABLE_VALUES.include?(@fetcher[anchor + 1].type) \
          && (@fetcher[anchor + 2].nil? || END_OF_LINE.include?(@fetcher[anchor + 2].type))
            nodes << @fetcher.fetch
            nodes << fetch_single_value_into_expression
            done = false
          elsif (@fetcher[anchor].type == :assign) \
          && !@fetcher[anchor + 1].nil? && EXPRESSABLE_VALUES.include?(@fetcher[anchor + 1].type) \
          && (@fetcher[anchor + 2].nil? || END_OF_LINE.include?(@fetcher[anchor + 2].type))
            nodes << @fetcher.fetch
            nodes << fetch_single_value_into_expression
            done = false
          elsif (@fetcher[anchor].type == :identifier) && (@fetcher[anchor].text == "return") \
          && (@fetcher[anchor + 1].nil? || END_OF_LINE.include?(@fetcher[anchor + 1].type))
            nodes << fetch_return_without_value
            done = false
          elsif (@fetcher[anchor].type == :identifier) && (@fetcher[anchor].text == "return") \
          && !@fetcher[anchor + 1].nil? && (@fetcher[anchor + 1].type == :expression) \
          && (@fetcher[anchor + 2].nil? || END_OF_LINE.include?(@fetcher[anchor + 2].type))
            nodes << fetch_return_with_value
            done = false
          elsif !@fetcher[anchor + 1].nil? && !@fetcher[anchor + 2].nil? \
          && [:identifier, :variable, :address].include?(@fetcher[anchor].type) \
          && (@fetcher[anchor + 1].type == :assign) && (@fetcher[anchor + 2].type == :expression)
            nodes << fetch_variable_assignment
            done = false
          elsif is_operable_values
            nodes << fetch_operation
            done = false
          elsif is_library_import
            nodes << fetch_library_import
            done = false
          else
            nodes << @fetcher.fetch
          end
        end
      end
      
      # remove unused nodes
      remove_list = [:whitespace, :cr, :lf, :crlf, :comment]
      nodes = nodes.select{|n|!remove_list.include?(n.type)}
      
      nodes
    end
  end
end
