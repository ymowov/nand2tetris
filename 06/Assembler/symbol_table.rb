# Record the address of labels and variables in register
class SymbolTable
  def initialize
    @table = Hash["SP", "0", "LCL", "1", "ARG", "2", "THIS",
      "3", "THAT", "4", "SCREEN", "16384", "KBD", "24576"]
    (0..15).each { |n| @table["R#{n}"] = "#{n}" } # R0~R15
    @variable_num = 0
  end

  def insert(label, value)
    @table[label] = value unless has_symbol?(label)
  end

  def insert_variable(label)
    # index of variables becomes from 16 (defined by Hack language)
    unless has_symbol?(label)
      @table[label] = (16 + @variable_num).to_s
      @variable_num+=1
    end
  end

  def read(label)
    @table[label]
  end

private
  def has_symbol?(label)
    @table.has_key?(label)
  end
end