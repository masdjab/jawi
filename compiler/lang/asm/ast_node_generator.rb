require_relative 'lexer'


module Jawi
  class AstNodeGenerator
    private
    def initialize(source_provider, token_generator)
      @source_provider = source_provider
      @token_generator = token_generator
    end
    def convert_tokens_to_ast_nodes(tokens)
      tokens.map{|t|Lex::Node.new(t.pos, t.type, t.text)}
    end

    public
    def generate_ast_nodes(source_name)
      source = @source_provider.get_source(source_name)
      tokens = @token_generator.generate_tokens(source)
      lexer = Lexer.new(tokens)
      lexer.lex
    end
  end
end
