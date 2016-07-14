# Build a Modern Computer from First Principles: From Nand to Tetris
## [My Course Certificate](https://www.coursera.org/account/accomplishments/certificate/FEXYJUGC4EGK)

### Week 6: Assembler
* Assembler.rb - The assembler I built in Ruby to compile assembly code written in Hack language(.asm) to binary code(.hack)
* `main.rb` integrates the assembler I designed to compile all the test programs list below.
* After compiling, the program will automatically compare all the correspond correct .cmp.hack file to check whether the assembler works well.
#### Test Programs
Symbolic Program | Without Symbols | Description
------------ | ------------- | -------------
Add.asm |  | Adds up the constants 2 and 3 and puts the result in R0.
Max.asm | MaxL.asm | Computes max(R0,R1) and puts the result in R2.
Rect.asm | RectL.asm | Draws a rectangle at the top-left corner of the screen. The rectangle is 16 pixels wide and R0 pixels high.
Pong.asm | PongL.asm | A single-player Pong game.

### Week 5: Computer Architecture
* Memory.hdl - Entire RAM address space
* CPU.hdl - The Hack CPU
* Computer.hdl - The platform's top-most chip

### Week 4: Machine Language
* Mult.asm - Multiplication: Computes the value R0*R1 and stores the result in R2.
* Fill.asm - I/O handling: When a key is pressed (any key), the program blackens the screen. When no key is pressed, the program clears the screen.

### Week 3: Sequential Logic
* DFF - Data Flip-Flop (primitive)
* Bit - 1-bit register
* Register - 16-bit register
* RAM8 - 16-bit / 8-register memory
* RAM64 - 16-bit / 64-register memory
* RAM512 - 16-bit / 512-register memory
* RAM4K - 16-bit / 4096-register memory
* RAM16K - 16-bit / 16384-register memory
* PC - 16-bit program counter

### Week 2: Boolean Arithmetic
* Half - Adder
* FullAdder - Full Adder
* Add16 - 16-bit Adder
* Inc16 - 16-bit incrementer
* ALU - Arithmetic Logic Unit

### Week 1: Boolean Logic
* Nand - Nand gate (primitive)
* Not - Not gate
* And - And gate
* Or - Or gate
* Xor - Xor gate
* Mux - Mux gate
* DMux - DMux gate
* Not16 - 16-bit Not
* And16 - 16-bit And
* Or16 - 16-bit Or
* Mux16 - 16-bit multiplexor
* Or8Way - Or(in0,in1,...,in7)
* Mux4Way16 - 16-bit/4-way mux
* Mux8Way16 - 16-bit/8-way mux
* DMux4Way - 4-way demultiplexor
* DMux8Way - 8-way demultiplexor
