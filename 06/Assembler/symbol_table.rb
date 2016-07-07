class SymbolTable
  def initialize
    @table = Hash["SP", "0", "LCL", "1", "ARG", "2", "THIS",
      "3", "THAT", "4", "SCREEN", "16384", "KBD", "24576"]
    (0..15).each { |n| @table["R#{n}"] = "#{n}" } # R0~R15
    @variable_num = 0
  end

  def insert(label, value)
    @table[label] = value unless @table.has_symbol?(code._destination)
  end

  def insert_variable(label)
    unless has_symbol?(label)
      puts "has! #{label}, #{@variable_num}"
      @table[label] = (16 + @variable_num).to_s
      @variable_num+=1
    end
  end

  def read(label)
    @table[label]
  end

  def has_symbol?(label)
    @table.has_key?(label)
  end

  def table
    @table
  end
end