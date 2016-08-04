require "./code_writer.rb"
path = "../../08/FunctionCalls/SimpleFunction/SimpleFunction"
@c = CodeWriter.new("#{path}.asm")
@p = @c.set_file_name("#{path}.vm")
# @c = CodeWriter.new("./test.asm")
# @p = @c.set_file_name("./test.vm")
@c.write
