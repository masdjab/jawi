module Asm
  module Lex
    class NodeBase
      attr_reader :pos, :type
      def initialize(pos, type)
        @pos = pos
        @type = type
      end
      def class_name
        "#{self.class}"[10..-1]
      end
    end
    
    
    class Values < NodeBase
      attr_reader :items
      def initialize(pos, items)
        super(pos, :values)
        @items = items
      end
      def to_s
        "#{class_name}(#{@items.map{|x|x.to_s}.join(", ")})"
      end
    end
    
    
    class Bracket < NodeBase
      attr_reader :value
      def initialize(pos, value)
        super(pos, :bracket)
        @value = value
      end
      def to_s
        "#{class_name}(#{@value})"
      end
    end
    
    
    class Return < NodeBase
      attr_reader :value
      def initialize(pos, value = nil)
        super(pos, :return)
        @value = value
      end
      def to_s
        "#{class_name}(#{@value ? @value.to_s : ""})"
      end
    end
    
    
    class FunctionDeclaration < NodeBase
      attr_reader :name, :parameters
      def initialize(pos, name, parameters)
        super(pos, :function)
        @name = name
        @parameters = parameters
      end
      def to_s
        "#{class_name}(#{@name.text}(#{@parameters.map{|x|x.to_s}.join(", ")}))"
      end
    end
    
    
    class FunctionCall < NodeBase
      attr_reader :name, :arguments
      def initialize(pos, name, arguments)
        super(pos, :call)
        @name = name
        @arguments = arguments
      end
      def to_s
        "#{class_name}(#{@name.text}(#{@arguments.map{|x|x.to_s}.join(", ")}))"
      end
    end
    
    
    class AddressOf < NodeBase
      attr_reader :variable
      def initialize(pos, variable)
        super(pos, :address)
        @variable = variable
      end
      def to_s
        "#{class_name}(#{@variable})"
      end
    end
    
    
    class Operation < NodeBase
      attr_reader :operator, :value1, :value2
      def initialize(pos, operator, value1, value2)
        super(pos, :operation)
        @operator = operator
        @value1 = value1
        @value2 = value2
      end
      def to_s
        "#{class_name}(#{@operator.text}, #{@value1}, #{@value2})"
      end
    end
    
    
    class Expression < NodeBase
      attr_reader :nodes
      def initialize(pos, nodes)
        super(pos, :expression)
        @nodes = nodes
      end
      def to_s
        "#{class_name}(#{@nodes.map{|n|n.to_s}.join(", ")})"
      end
    end
    
    
    class Assignment < NodeBase
      attr_reader :variable, :value
      def initialize(pos, variable, value)
        super(pos, :assignment)
        @variable = variable
        @value = value
      end
      def to_s
        "#{class_name}(#{@variable}, #{@value})"
      end
    end
    
    
    class LibImport < NodeBase
      attr_reader :name, :library, :function
      def initialize(pos, name, library, function)
        super(pos, :import)
        @name = name
        @library = library
        @function = function
      end
      def to_s
        "#{class_name}(#{@name}, #{@library}, #{@function})"
      end
    end
  end
end
