require_relative '../../compiler/source_provider/simple_source_provider'
require_relative '../../compiler/lang/jawi/lexer'


main_code =<<EOS
private
def int add(int v1, int v2)
  # return v1 + v2
end

public
def static void sleep(int milli_seconds)
  # do nothing
end

str x, y
int z1
int z2
str message
# x = '2'
# y = '3'
# z1 = add(x.to_i, '3'.to_i)
# z2 = add x.to_i, 3.to_s.to_i

# message = "well done. z: " + z.to_s
# puts message
EOS

source_dict = {'main' => main_code}
source_provider = SimpleSourceProvider.new(source_dict)
lexer = Jawi::Lexer.new(source_provider, 'main')
nodes = lexer.lex
nodes = nodes.map{|n|n.to_s}
puts nodes.join($/)
