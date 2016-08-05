require "./code_writer.rb"
class VmTranslator
  def initialize(path)
    @path = path
    @writer = CodeWriter.new("#{@path}/#{@path.split('/')[-1]}.asm")
  end

  def compile
    translate_all
    @writer.close
  end

  private
  def translate_all
    Dir["#{@path}/*.vm"].each do |file|
      translate(file)
    end
  end

  def translate(path_to_file)
    @writer.set_file_name(path_to_file)
    @writer.write
  end
end