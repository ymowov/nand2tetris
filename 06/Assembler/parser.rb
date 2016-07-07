=begin
This class unpack each instruction(written by Hack language) into its underlying fields.
Example:
D=D+1;JEQ -> D D+1 JEQ
M=M+D -> M M+D
=end

module Parser
  @@a_instuction = 0
  @@c_instuction = 1
  @@label_instuction = 2
  @@variable_instuction = 3
  def _destination
    # print the character before the '='
    case type
    when @@c_instuction
      @str[0..equal_index-1] if equal_index > 0
    when @@a_instuction, @@variable_instuction
      @str[1..-1]
    when @@label_instuction
      @str[1..-2]
    end
  end

  def _computation
    # print the character between '=' and ';' or after '='
    if type == @@c_instuction
      equal_index > 0 ? @str[equal_index+1..end_of_computation_index-1] : @str[0..end_of_computation_index-1]
    end
  end

  def _jump
    (type == @@c_instuction && end_of_computation_index > 0) ? @str[end_of_computation_index+1..-1] : nil
  end


private
  def equal_index
    @str.index("=") || 0
  end

  def end_of_computation_index
    @str.index(";") || 0
  end
end