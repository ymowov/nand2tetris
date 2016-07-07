=begin
1. This class translate each field from Parse class into its corresponding binary value.(16-bits)
2. It will lookup the truth table provided by Nandtoteris class in Coursera.
3. This code is written by Hack lanuage.

Example:
A-instruction:
@21 ->   0000000000010101

C-instruction:
D=D+1 -> 1110011111010000
=end
require "./parser.rb"

class Code
  include Parser
  @@jump_table = Hash["JGT", "001", "JEQ", "010", "JGE", "011",
           "JLT", "100", "JNE", "101", "JLE", "110", "JMP", "111"]

  @@comp_table = Hash["0", "101010", "1", "111111", "-1", "111010", "D", "001100", "X", "110000",
                   "!D", "001101", "!X", "110001", "-D", "001111", "-X", "110011", "D+1", "011111",
                   "X+1", "110111", "D-1", "001110", "X-1", "110010", "D+X", "000010", "D-X", "010011",
                   "X-D", "000111", "D&X", "000000", "D|X", "010101"]


  def initialize(str)
    @str = str
  end

  def compile
    case type
    when @@a_instuction
      "0" << ("%015b" % _destination.to_i)
    when @@c_instuction
      "111" << comp << dest << jump
    when @@label_instuction
      # look up the symbol table
    end
  end

  def self.comp_table
    @@comp_table
  end

  def self.jump_table
    @@jump_table
  end

  def type
    if @str.include? "@"
      is_integer?(@str.gsub("@", "")) ? @@a_instuction : @@variable_instuction
    elsif @str[0, -1].eql?("()")
      @@label_instuction
    else
      @@c_instuction
    end
  end

private
  def dest
    %w(A D M).each_with_object("") do |c, str|
      str << (_destination.include?(c) ? "1" : "0")
    end if _destination
  end

  def jump
    @@jump_table[_jump] || "000"
  end

  def comp
    computation = _computation.gsub(/[MA]/, "X")
    comp_a << @@comp_table[computation]
  end

  def comp_a
    if _computation.include?("M")
      "1"
    else
      "0"
    end
  end

  def str
    @str
  end

  def is_integer?(str)
    str.to_i.to_s == str
  end
end

