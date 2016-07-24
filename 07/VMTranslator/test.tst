load test.asm,
set RAM[0] 256,
set RAM[1] 300,
set RAM[2] 400,
set RAM[3] 3000,
set RAM[4] 3010,
set RAM[300] 999,
set RAM[400] 5,
set RAM[3015] 888,


repeat 9999 {
  ticktock;
}

