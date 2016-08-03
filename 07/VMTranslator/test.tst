load test.asm,
set RAM[0] 256,
set RAM[1] 256,
set RAM[2] 400,
set RAM[3] 3000,
set RAM[4] 3010,
set RAM[400] 1234,
set RAM[401] 37,
set RAM[402] 9,
set RAM[403] 305,
set RAM[404] 300,
set RAM[405] 3010,
set RAM[406] 4010,

repeat 9999 {
  ticktock;
}

