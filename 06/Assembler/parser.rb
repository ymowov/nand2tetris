=begin
This class unpack each instruction(written by Hack language) into its underlying fields.
Example:
D=D+1;JEQ -> D D+1 JEQ
M=M+D -> M M+D
=end

module Parser
  def _destination
    # print the character before the '='
    case type
    when C_INSTRUCTION
      @str[0..equal_index-1] if equal_index > 0
    when A_INSTRUCTION, VARIABLE_INSTRUCTION
      @str[1..-1]
    when LABEL_INSTRUCTION
      @str[1..-2]
    end
  end

  def _computation
    # print the character between '=' and ';' or after '='
    if type == C_INSTRUCTION
      equal_index > 0 ? @str[equal_index+1..end_of_computation_index-1] : @str[0..end_of_computation_index-1]
    end
  end

  def _jump
    (type == C_INSTRUCTION && end_of_computation_index > 0) ? @str[end_of_computation_index+1..-1] : nil
  end

private
  def equal_index
    @str.index("=") || 0
  end

  def end_of_computation_index
    @str.index(";") || 0
  end
end