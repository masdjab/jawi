require_relative '../libs/binary_converter'
require_relative 'reference_resolver/data_resolver_32'
require_relative 'reference_resolver/import_resolver_32'
require_relative 'dll_import'
require_relative 'symbol_ref'
require_relative 'object_code'
require_relative 'code_section'
require_relative 'output_formatter/pe32/pe32_struct'
require_relative 'output_formatter/pe32/pe32_formatter'

def hex2bin(data)
  BinaryConverter.hex2bin(data)
end


code_body = hex2bin("6800000000680000000068000000006800000000FF15000000006800000000FF1500000000")
#                         0         5         10        15        20          26        31
message_title = "Win32 MessageBox Test\0"
message_body = "This is a MessageBox test compiled using Jawi Compiler.\0"
data_body = [message_title, message_body].join

sect = Pe32Const

flags = sect::SECTION_READABLE | sect::SECTION_WRITABLE | sect::SECTION_INITIALIZED_DATA
import_section = Pe32ImportSection.new(".idata", :import, flags)
import_section.add_import_item exit_process = DllImport.new('kernel32.dll', 'ExitProcess')
import_section.add_import_item message_box = DllImport.new('user32.dll', 'MessageBoxA')

code_section = StandardSection.new(".text", :code, sect::SECTION_CODE | sect::SECTION_EXECUTABLE | sect::SECTION_READABLE, code_body)
data_section = StandardSection.new(".bss", :data, sect::SECTION_READABLE | sect::SECTION_WRITABLE, data_body)

object_code = ObjectCode.new
object_code.references << SymbolRef.new(".text", 6, DataResolver32.new(0))
object_code.references << SymbolRef.new(".text", 11, DataResolver32.new(message_title.length))
object_code.references << SymbolRef.new(".text", 33, ImportResolver32.new(exit_process))
object_code.references << SymbolRef.new(".text", 22, ImportResolver32.new(message_box))
object_code.sections << code_section
object_code.sections << data_section
object_code.sections << import_section

formatter = Pe32Formatter.new
executable_image = formatter.format(object_code)

File.binwrite("output.exe", executable_image)
