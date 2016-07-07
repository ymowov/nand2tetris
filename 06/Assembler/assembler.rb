# Assume there's no error in .asm code
require "./instruction_type.rb"
require "./symbol_table.rb"
require "./code.rb"
require "tempfile"

class Assembler
  def initialize(path)
    @hack_file = File.open(path+".hack", "w")
    @asm_file = File.open(path+".asm", "r")
    @t_file = Tempfile.new("temp.txt") # record clean assembly code
    @symbol_table = SymbolTable.new
  end

  def compile
    # remove comment, blank line or spaces
    @asm_file.each_line do |line|
      line = line.gsub(/\s+|^$\n|\/\/.+/, "")
      @t_file.puts line unless line.chomp.empty?
    end

    # put labels into symbol table
    index = 0 # line number of instruction
    @t_file.open.each_line do |line|
      code = Code.new(line.gsub("\n", ""))
      if code.type == LABEL_INSTRUCTION
        # label is not a struction but record the line number of next instruction
        @symbol_table.insert(code._destination, index)
      else
        index+=1
      end
    end

    # put variables into symbol table
    @t_file.open.each_line do |line|
      code = Code.new(line.gsub("\n", "")) # 'line' include the '\n' in the end if line
      @symbol_table.insert_variable(code._destination) if code.type == VARIABLE_INSTRUCTION
    end

    # compile .asm code line by line
    @t_file.open.each_line do |line|
      code = Code.new(line.gsub("\n", ""), @symbol_table)
      @hack_file.write "#{code.compile}\n" unless code.type == LABEL_INSTRUCTION
    end

    @asm_file.close
    @hack_file.close
  end
end