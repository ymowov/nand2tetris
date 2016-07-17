require "./parser.rb"

class CodeWriter
  def initialize(path_to_hack_file)
    @hack_file = File.open(path_to_hack_file, "w")
  end

  def set_file_name(path_to_vm_file)
    @parser = Parser.new(path_to_vm_file)
  end

  def write
    while @parser.has_more_commands? do
      if !@parser.advance.empty?
        translate
      end
    end
  end

  def translate
    case @parser.command_type
    when C_ARITHMETIC
      write_arithmetic
    when C_PUSH
      write_push
    when C_POP
      write_pop
    end
  end

  def write_arithmetic
    # add -> D=D+M
    case @parser.arg1
    when "add"
      write_arithmetic_binary(calculation: "D+M")
    when "sub"
      write_arithmetic_binary(calculation: "M-D")
    when "eq"
      write_arithmetic_binary_jump("JEQ")
    when "gt"
      write_arithmetic_binary_jump("JGT")
    when "lt"
      write_arithmetic_binary_jump("JLT")
    when "and"
      write_arithmetic_binary(calculation: "M&D")
    when "or"
      write_arithmetic_binary(calculation: "M|D")
    when "neg"
      write_arithmetic_binary(calculation: "-D", unary: true)
    when "not"
      write_arithmetic_binary(calculation: "!D", unary: true)
    end
  end

  def write_push
    case @parser.arg(1)
    when S_CONSTANT
      push_stack(register: @parser.arg(2))
    when S_LOCAL, S_ARGUMENTS, S_THIS, S_THAT
      load_memory
      push_stack
    end
  end

  def write_pop
    case @parser.arg(1)
    when S_LOCAL, S_ARGUMENTS, S_THIS, S_THAT
      # pop local 3
      pop_stack(save_to_d: true)
      a_instruction(R_R13)
      c_instruction("M=D")
      load_memory(pop_to_mem: true)
    end
  end

  def load_memory(pop_to_mem: false)
    labels = Hash[S_LOCAL, "LCL", S_ARGUMENTS, "ARG", S_THIS, "THIS", S_THAT, "THAT" ]
    a_instruction(@parser.arg(2)) # load the index as constant
    c_instruction("D=A")
    a_instruction(labels[@parser.arg(1)]) # load the correspond address
    c_instruction("AD=M+D") # set A = address + offset
    if pop_to_mem
      a_instruction(R_R14) # save the address + offset to R14
      c_instruction("M=D")

      a_instruction(R_R13) # load the data just be poped, saved in R13
      c_instruction("D=M")

      a_instruction(R_R14) # save the data to *(R14)
      c_instruction("A=M")
      c_instruction("M=D")
    else
      c_instruction("D=M")
    end
  end

  def close
    @hack_file.close
  end

  def push_stack(register: nil)
    if register
      a_instruction(register) # save the register's value to D-register
      c_instruction("D=A")
    end
    a_instruction("SP") # save this value to the stack
    c_instruction("A=M")
    c_instruction("M=D")
    a_instruction("SP") # stack counter + 1
    c_instruction("M=M+1")
  end

  def pop_stack(save_to_d: true)
    a_instruction("SP")
    c_instruction("M=M-1")
    c_instruction("A=M")
    c_instruction("D=M") if save_to_d
  end

  def jump(jump_type)
    a_instruction("label_jeq", true)
    c_instruction("D; #{jump_type}")
    c_instruction("D=0")
    a_instruction("label_jne", true)
    c_instruction("0; JEQ")
    label_instruction("label_jeq")
    c_instruction("D=-1")
    label_instruction("label_jne")
  end

  def write_arithmetic_binary(calculation:, jump_type: nil, unary: false)
    pop_stack
    pop_stack(save_to_d: false) unless unary
    c_instruction("D=#{calculation}")
    jump(jump_type) if jump_type
    push_stack
  end

  def write_arithmetic_binary_jump(jump_type)
    write_arithmetic_binary(calculation: "M-D", jump_type: jump_type)
  end

private
  def a_instruction(register, label = false)
    line_number = @parser.line_number if label
    @hack_file.write("@#{register}#{line_number}\n")
  end

  def c_instruction(string)
    @hack_file.write("#{string}\n")
  end

  def label_instruction(string)
    # puts @parser.line_number
    @hack_file.write("(#{string}#{@parser.line_number})\n")
  end
end