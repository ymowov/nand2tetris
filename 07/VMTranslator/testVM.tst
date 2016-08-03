load test.vm,
set sp 256,
set local 256,
set argument 400,
set this 3000,
set that 3010,
set argument[0] 1234,
set argument[1] 37,
set argument[2] 9,
set argument[3] 305,
set argument[4] 300,
set argument[5] 3010,
set argument[6] 4010,


repeat 9999 {
  vmstep;
}

