load test.vm,
set sp 256,
set local 300,
set argument 400,
set this 3000,
set that 3010,
set RAM[300] 999,
set RAM[400] 5,
set RAM[3015] 888,


repeat 9999 {
  vmstep;
}

