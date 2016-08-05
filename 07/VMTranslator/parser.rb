require "./vm_constants.rb"

class Parser
  @@command_types = Hash["add", C_ARITHMETIC, "sub", C_ARITHMETIC, "neg", C_ARITHMETIC,
    "eq", C_ARITHMETIC, "gt", C_ARITHMETIC, "lt", C_ARITHMETIC, "and", C_ARITHMETIC,
    "or", C_ARITHMETIC, "not", C_ARITHMETIC, "push", C_PUSH, "pop", C_POP, "label", C_LABEL,
    "goto", C_GOTO, "if-goto", C_GOTO, "call", C_CALL, "function", C_FUNCTION, "return", C_RETURN]

  def initialize(path_to_vm_file)
    @vm_file = File.open(path_to_vm_file, "r")
  end

  def has_more_commands?
    !@vm_file.eof?
  end

  def advance
    # read the next line and remove comments
    @current_command = @vm_file.gets.gsub(/\/\/.+|\n|\r/, "")
  end

  def command_type
    @@command_types[arg0]
  end

  def arg0
    split_command[0]
  end

  def arg(index)
    split_command[index]
  end

  def args
    split_command
  end

  def arg_count
    split_command.count
  end

  def line_number
    @vm_file.lineno
  end

  def file_name
    File.basename(@vm_file.path, ".vm")
  end

  def command
    @current_command
  end

  private
  def split_command
    @current_command.split(" ")
  end
end