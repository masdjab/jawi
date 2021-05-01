require_relative '../../compiler/source_provider/simple_source_provider'
require_relative '../../compiler/lang/asm/lexer'


main_code =<<EOS
def add(v1, v2)
  return v1 + v2
end
def puts (text, color)
  screen = 0xe0000
  # for i in range(text.length)
  #   screen << text[i]
  #   screen << byte(color)
  # end
end
def shutdown()
  puts "Hello...", 0x40 + 0x10
  return add (12, 35) + 1
end

age = 4 + 21 / (3 + 2) * 5
if age == 3 || age == 4
  &block = 4
else
  &block = 32
end
EOS

lexer = Asm::Lexer.new
nodes = lexer.lex(main_code)
nodes = nodes.select{|n|![:comment, :cr, :lf, :crlf].include?(n.type)}.map{|n|n.to_s}
puts nodes.join($/)
