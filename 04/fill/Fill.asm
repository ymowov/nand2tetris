// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel. When no key is pressed, the
// program clears the screen, i.e. writes "white" in every pixel.

(LOOP)
  // n = keyboard's address
  @KBD
  D=A
  @SCREEN
  D=D-A
  @n
  M=D

  // arr = screen's address
  @SCREEN
  D=A
  @arr
  M=D

  // i = 0
  @i
  M=0

  // if keyboard is pressed, turn off the screen. else, turn on the screen
  @KBD
  D=M
  @TURNOFF
  D ; JGT

  // turn on the screen
  (TURNON)
    @n
    D=M
    @i
    D=D-M

    @LOOP
    D ; JEQ

    @arr
    D=M
    @i
    A=D+M
    M=0

    // i++
    @i
    M=M+1

    @TURNON
    0 ; JEQ
  ////////////////////////////////

  // else, trun off the screen
  (TURNOFF)
    @n
    D=M
    @i
    D=D-M

    @LOOP
    D ; JEQ

    @arr
    D=M
    @i
    A=D+M
    M=-1

    // i++
    @i
    M=M+1

    @TURNOFF
    0 ; JEQ

@LOOP
0; JEQ