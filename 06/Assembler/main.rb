require "./symbol_table.rb"
require "./code.rb"
require "tempfile"

@a_instuction = 0
@c_instuction = 1
@label_instuction = 2
@variable_instuction = 3
path_to_asm_file = "../add/Add"

hack_file = File.open(path_to_asm_file+".hack", "w")
asm_file = File.open(path_to_asm_file+".asm", "r")
t_file = Tempfile.new('filename_temp.txt')
symbol_table = SymbolTable.new

asm_file.each_line do |line|
  line = line.gsub(/\s+|^$\n|\/\/.+/, "")  # remove comment, blank line or spaces
  t_file.puts line unless line.chomp.empty?
end

index = 0
t_file.open.each_line do |line|
  code = Code.new(line.gsub("\n", ""))
  case code.type
  when @label_instuction
    symbol_table.insert(code._destination, index)
  when @variable_instuction
    symbol_table.insert_variable(code._destination)
    index+=1
  else
    index+=1
  end
end

t_file.open.each_line do |line|
  code = Code.new(line.gsub("\n", ""))
  # puts line
  hack_file.write "#{code.compile}\n"
end

asm_file.close
hack_file.close