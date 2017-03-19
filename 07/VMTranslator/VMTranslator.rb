require "./CodeWriter.rb"
class VmTranslator
  def initialize(path)
    @vm_path = File.expand_path(path) # dir
    if path[-3..-1] == ".vm" # single file
      file_name = path.split('/')[-1][0..-4]
      @asm_path = "#{@vm_path[0..-4]}.asm"
      @single_file = true
    else # a directory
      @asm_path = "#{@vm_path}/#{@vm_path.split('/')[-1]}.asm"
      @single_file = false
    end
    @writer = CodeWriter.new(@asm_path, @single_file)
  end

  def compile
    if @single_file
      translate(@vm_path)
    else
      translate_all
    end
    @writer.close
  end

  private
  def translate_all
    Dir["#{@vm_path}/*.vm"].each do |file|
      puts "translate file = #{file}"
      translate(file)
    end
  end

  def translate(path_to_vm_file)
    @writer.set_file_name(path_to_vm_file)
    @writer.write
  end
end

if __FILE__ == $0
  VmTranslator.new(ARGV[0]).compile
end