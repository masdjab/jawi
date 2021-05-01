require_relative '../../compiler/source_provider/simple_source_provider'
require_relative '../../compiler/symbols/init'
require_relative '../../compiler/compiler'


msgbox_test = <<EOS
msgbox = import 'user32.dll', 'MessageBoxA'
exit_process = import 'kernel32.dll', 'ExitProcess'

title = 'Message Title\0'
message = 'This is a MessageBox test using Flat Assembler.\0'

msgbox 0, message, title, 0
exit_process 0
EOS


simple_code = <<EOS
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
  block = 4
else
  block = 32
end
EOS


source_dict = {'main' => msgbox_test}
source_provider = SimpleSourceProvider.new(source_dict)
symbols = Symbols.new
compiler = Asm::Compiler.new(symbols, source_provider, 'main')
compiler.compile
symbols.items.each{|s|puts s.to_s}
