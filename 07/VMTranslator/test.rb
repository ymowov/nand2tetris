require "./code_writer.rb"

# @c = CodeWriter.new("../StackArithmetic/StackTest/StackTestYm.asm")
# @p = @c.set_file_name("../StackArithmetic/StackTest/StackTest.vm")
@c = CodeWriter.new("./test.asm")
@p = @c.set_file_name("./test.vm")
@c.write
@c.close