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
    close
  end

  def translate
    case @parser.command_type
    when C_ARITHMETIC
      write_arithmetic
    when C_PUSH
      write_push
    when C_POP
      write_pop
    when C_LABEL
      write_label
    when C_GOTO
      write_goto
    when C_CALL
      write_call
    when C_FUNCTION
      write_function
    when C_RETURN
      write_return
    end
  end

  def write_arithmetic
    # add -> D=D+M
    case @parser.arg0
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
    when S_STATIC
      load_static
      push_stack
    when S_LOCAL, S_ARGUMENTS, S_THIS, S_THAT, S_POINTER, S_TEMP
      load_memory(segment: @parser.arg(1), value: @parser.arg(2))
      push_stack
    end
  end

  def write_pop
    case @parser.arg(1)
    when S_STATIC
      pop_stack(save_to_d: true)
      load_static(save_from_d: true)
    when S_LOCAL, S_ARGUMENTS, S_THIS, S_THAT, S_POINTER, S_TEMP
      pop_stack(save_to_d: true)
      a_instruction(R_R13)
      c_instruction("M=D")
      load_memory(segment: @parser.arg(1), value: @parser.arg(2), save_from_r13: true)
    end
  end

  def write_label
    label_instruction(@parser.arg(1))
  end

  def write_goto
    if @parser.arg0.eql?("if-goto")
      pop_stack(save_to_d: true)
      conditional_jump = true
    end
    a_instruction(@parser.arg(1))
    c_instruction("#{conditional_jump ? 'D; JNE' : '0; JEQ'}")
  end

  def write_call
    push_arguments
    function_init
    write_goto
    label_instruction("LABEL", true) # return address destination
  end

  def write_function
    label_instruction(@parser.arg(1))
    @parser.arg(2).to_i.times do
      a_instruction("0")
      c_instruction("D=A")
      push_stack
    end
  end

  def write_return
    a_instruction("LCL") # frame = LCL
    c_instruction("D=M")
    a_instruction(R_R15)
    c_instruction("M=D")

    pop_stack # *ARG = pop, reposition the return value
    a_instruction("ARG")
    c_instruction("A=M")
    c_instruction("M=D")
    c_instruction("D=A+1")

    a_instruction("SP") # SP = ARG+1
    c_instruction("M=D")

    %w(THIS THAT ARG LCL).each_with_index do |segment, index|
      a_instruction(R_R15)
      c_instruction("MD=M-1")
      c_instruction("A=D")
      if index == 4
        c_instruction("#{conditional_jump ? 'D' : '0'}; JNE")
      else
        c_instruction("D=M")
        a_instruction(segment)
        c_instruction("M=D")
      end
    end
  end

  def push_arguments
    @parser.args[2..-1].each do |arg|
      a_instruction(arg)
      c_instruction("D=A")
      push_stack
      @arguments_count += 1
    end
  end

  def function_init
    # push global variables in previous function
    a_instruction("LABEL", true) # return address
    c_instruction("D=A")
    push_stack
    a_instruction("LCL") # LCL
    c_instruction("D=A")
    push_stack
    a_instruction("ARG") # ARG
    c_instruction("D=A")
    push_stack
    a_instruction("THIS") # THIS
    c_instruction("D=A")
    push_stack
    a_instruction("THAT") # THAT
    c_instruction("D=A")
    push_stack

    # reposition
    a_instruction(@arguments_count+5) # ARG = SP - arguments_count - 5
    c_instruction("D=A")
    a_instruction(@SP)
    c_instruction("D=M-D")
    a_instruction(@ARG)
    c_instruction("M=D")
    a_instruction(@SP) # LCL = SP
    c_instruction("D=M")
    a_instruction(@ARG)
    c_instruction("M=D")
  end

  def load_static(save_from_d: false)
    a_instruction("#{@parser.file_name}.#{@parser.arg(2)}")
    save_from_d ? c_instruction("M=D") : c_instruction("D=M")
  end

  def load_memory(segment: , value: , save_from_r13: false)
    labels = Hash[S_LOCAL, "LCL", S_ARGUMENTS, "ARG", S_THIS,
      "THIS", S_THAT, "THAT", S_POINTER, "THIS", S_TEMP, R_TEMP ]
    a_instruction(value) # load the index as constant
    c_instruction("D=A")
    a_instruction(labels[segment]) # load the correspond address
    case @parser.arg(1)
    when S_TEMP, S_POINTER
      c_instruction("AD=A+D") # set A = temp/pointer(this)'s address + offset
    else
      c_instruction("AD=M+D") # set A = address + offset
    end
    if save_from_r13
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
    label_instruction("label_jeq", true)
    c_instruction("D=-1")
    label_instruction("label_jne", true)
  end

  def condition_jump(address:, set_line_number: false)
    a_instruction(address, set_line_number)
    c_instruction("0; JEQ")
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
  def a_instruction(register, set_line_number = false)
    line_number = @parser.line_number if set_line_number
    @hack_file.write("@#{register}#{line_number}\n")
  end

  def c_instruction(string)
    @hack_file.write("#{string}\n")
  end

  def label_instruction(string, set_line_number = false)
    line_number = @parser.line_number if set_line_number
    @hack_file.write("(#{string}#{line_number})\n")
  end

  def close
    @hack_file.close
  end
end