require "./code_writer.rb"

@c = CodeWriter.new("./test.asm")
@p = @c.set_file_name("./test.vm")
@c.write
@c.close