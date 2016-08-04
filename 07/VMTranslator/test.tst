load test.asm,
set RAM[0] 256,
set RAM[1] 300,
set RAM[2] 400,
set RAM[400] 6,
set RAM[401] 3000,

repeat 9999 {
  ticktock;
}

