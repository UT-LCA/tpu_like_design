task accumulator_test();
begin
  //Start the actual test
  $display("Set enables to 1");
  //enable_matmul = 1;
  //enable_norm = 1;
  //enable_activation = 1;
  //enable_pool = 1;
  if ($test$plusargs("norm_disabled")) begin
    write(`REG_ENABLES_ADDR, 32'h0000_000d);
  end 
  if ($test$plusargs("pool_disabled")) begin
    write(`REG_ENABLES_ADDR, 32'h0000_000b);
  end 
  if ($test$plusargs("activation_disabled")) begin
    write(`REG_ENABLES_ADDR, 32'h0000_0007);
  end 
  else begin//all blocks enabled
    write(`REG_ENABLES_ADDR, 32'h0000_000f);
  end
  read(`REG_ENABLES_ADDR, rdata);

  $display("Configure the value of mean and inv_variance");
  //mean = 8'h01;
  //inv_var = 8'h01;
  write(`REG_MEAN_ADDR, 32'h0000_0001);
  write(`REG_INV_VAR_ADDR, 32'h0000_0001);

  $display("-------------------------------------------");
  $display("Layer 0");
  $display("-------------------------------------------");
  $display("Configure the addresses of matrix A, B and C");
  //matrix A -> starts at address 0x8 in BRAM A
  //matrix B -> starts at address 0x0 in BRAM B
  //matrix C -> will start at address 0x20 in BRAM A
  write(`REG_MATRIX_A_ADDR, 32'h0000_0008);
  write(`REG_MATRIX_B_ADDR, 32'h0000_0000);
  write(`REG_MATRIX_C_ADDR, 32'h0000_0020);

  $display("Start the TPU");
  //start = 1;
  write(`REG_STDN_TPU_ADDR, 32'h0000_0001);
  
  $display("Wait until TPU is done");
  do 
  begin
      read(`REG_STDN_TPU_ADDR, rdata);
      done = rdata[31];
  end 
  while (done == 0);
  
  $display("TPU operation is done now.");

  $display("Stop the TPU");
  //start = 0;
  write(`REG_STDN_TPU_ADDR, 32'h0000_0000);

  $display("-------------------------------------------");
  $display("Layer 1");
  $display("-------------------------------------------");
  $display("Configure the addresses of matrix A, B and C");
  //matrix A -> 0x20 in BRAM A (the last layer wrote output here)
  //matrix B -> starts at address 0x0 in BRAM B
  //matrix C -> will start at address 0x40 in BRAM A
  write(`REG_MATRIX_A_ADDR, 32'h0000_0020); //
  write(`REG_MATRIX_B_ADDR, 32'h0000_0000);
  write(`REG_MATRIX_C_ADDR, 32'h0000_0040);

  $display("Restart the TPU");
  //start = 1;
  write(`REG_STDN_TPU_ADDR, 32'h0000_0001);
  
  $display("Wait until TPU is done");
  do 
  begin
      read(`REG_STDN_TPU_ADDR, rdata);
      done = rdata[31];
  end 
  while (done == 0);
  
  $display("TPU operation is done now.");

  $display("Stop the TPU");
  //start = 0;
  write(`REG_STDN_TPU_ADDR, 32'h0000_0000);
end
endtask


//////////////////////////////////////////////
//Initialize BRAMs A and B
//////////////////////////////////////////////
//>>> print(a)
//[[2 2 1 0 2 0 1 0 2 1 2 2]
// [0 1 1 2 0 2 0 1 2 2 1 2]
// [1 1 2 1 2 2 2 2 2 0 2 1]
// [1 0 0 2 0 1 1 0 2 1 2 0]
// [2 2 0 0 2 1 2 1 1 2 2 1]
// [1 2 0 0 0 0 2 0 0 1 1 0]
// [0 1 0 2 1 2 1 1 0 1 2 2]
// [0 0 0 1 2 1 1 1 1 2 1 2]
// [2 0 0 1 1 1 1 1 2 2 1 0]
// [2 0 0 1 2 2 1 0 1 1 0 2]
// [2 1 2 0 1 1 0 0 0 0 0 1]
// [1 2 1 0 2 2 0 1 0 0 0 1]]
//>>> print(b)
//[[0 0 0 2 0 1 2 1 2 0 0 2]
// [1 1 1 2 2 2 1 2 2 2 0 0]
// [0 0 0 0 0 1 2 0 0 0 1 0]
// [0 1 2 1 0 1 1 2 0 2 2 1]
// [0 0 0 1 0 1 0 2 2 1 2 2]
// [0 1 0 2 1 1 0 0 2 2 2 0]
// [2 0 1 2 2 0 1 0 1 2 2 0]
// [2 2 1 0 2 1 1 0 0 1 0 1]
// [0 0 0 1 1 1 0 2 1 0 0 1]
// [0 1 1 0 1 2 1 0 1 0 1 1]
// [1 0 1 1 0 1 2 2 1 1 0 2]
// [0 0 1 1 0 2 1 0 1 0 2 1]]
//>>> print(c)
//[[ 6  3  8 18  9 19 16 18 20 10 12 17]
// [ 4  9 11 13 10 19 12 12 13 12 15 11]
// [11  8 10 20 14 18 17 17 19 18 18 16]
// [ 4  4  8 12  6 10 10 13 10 10  9 11]
// [10  7 10 20 14 19 16 16 22 15 14 17]
// [ 7  3  6 11  9  8  9  7 10  9  5  5]
// [ 7  8 12 15  9 16 12 12 14 16 17 12]
// [ 5  6  9 11  8 15  9 10 13 10 16 13]
// [ 5  6  7 13  9 13 11 12 14  9 10 14]
// [ 2  4  6 16  6 14  9 10 17 10 17 13]
// [ 1  2  2 10  3 10 10  6 11  5  8  7]
// [ 4  6  4 13  8 13  8  9 15 11 11  8]]
//>>> np.set_printoptions(formatter={'int':hex})
//>>> print(c)
//[[0x6 0x3 0x8 0x12 0x9 0x13 0x10 0x12 0x14 0xa 0xc 0x11]
// [0x4 0x9 0xb 0xd 0xa 0x13 0xc 0xc 0xd 0xc 0xf 0xb]
// [0xb 0x8 0xa 0x14 0xe 0x12 0x11 0x11 0x13 0x12 0x12 0x10]
// [0x4 0x4 0x8 0xc 0x6 0xa 0xa 0xd 0xa 0xa 0x9 0xb]
// [0xa 0x7 0xa 0x14 0xe 0x13 0x10 0x10 0x16 0xf 0xe 0x11]
// [0x7 0x3 0x6 0xb 0x9 0x8 0x9 0x7 0xa 0x9 0x5 0x5]
// [0x7 0x8 0xc 0xf 0x9 0x10 0xc 0xc 0xe 0x10 0x11 0xc]
// [0x5 0x6 0x9 0xb 0x8 0xf 0x9 0xa 0xd 0xa 0x10 0xd]
// [0x5 0x6 0x7 0xd 0x9 0xd 0xb 0xc 0xe 0x9 0xa 0xe]
// [0x2 0x4 0x6 0x10 0x6 0xe 0x9 0xa 0x11 0xa 0x11 0xd]
// [0x1 0x2 0x2 0xa 0x3 0xa 0xa 0x6 0xb 0x5 0x8 0x7]
// [0x4 0x6 0x4 0xd 0x8 0xd 0x8 0x9 0xf 0xb 0xb 0x8]]
//
integer a_start_addr = 8;
reg [`DWIDTH-1:0] a[12][12] = 
'{{8'd2,8'd2,8'd1,8'd0,8'd2,8'd0,8'd1,8'd0,8'd2,8'd1,8'd2,8'd2},
  {8'd0,8'd1,8'd1,8'd2,8'd0,8'd2,8'd0,8'd1,8'd2,8'd2,8'd1,8'd2},
  {8'd1,8'd1,8'd2,8'd1,8'd2,8'd2,8'd2,8'd2,8'd2,8'd0,8'd2,8'd1},
  {8'd1,8'd0,8'd0,8'd2,8'd0,8'd1,8'd1,8'd0,8'd2,8'd1,8'd2,8'd0},
  {8'd2,8'd2,8'd0,8'd0,8'd2,8'd1,8'd2,8'd1,8'd1,8'd2,8'd2,8'd1},
  {8'd1,8'd2,8'd0,8'd0,8'd0,8'd0,8'd2,8'd0,8'd0,8'd1,8'd1,8'd0},
  {8'd0,8'd1,8'd0,8'd2,8'd1,8'd2,8'd1,8'd1,8'd0,8'd1,8'd2,8'd2},
  {8'd0,8'd0,8'd0,8'd1,8'd2,8'd1,8'd1,8'd1,8'd1,8'd2,8'd1,8'd2},
  {8'd2,8'd0,8'd0,8'd1,8'd1,8'd1,8'd1,8'd1,8'd2,8'd2,8'd1,8'd0},
  {8'd2,8'd0,8'd0,8'd1,8'd2,8'd2,8'd1,8'd0,8'd1,8'd1,8'd0,8'd2},
  {8'd2,8'd1,8'd2,8'd0,8'd1,8'd1,8'd0,8'd0,8'd0,8'd0,8'd0,8'd1},
  {8'd1,8'd2,8'd1,8'd0,8'd2,8'd2,8'd0,8'd1,8'd0,8'd0,8'd0,8'd1}};

integer b_start_addr = 0;
reg [`DWIDTH-1:0] b[12][12] =   
'{{8'd0,8'd0,8'd0,8'd2,8'd0,8'd1,8'd2,8'd1,8'd2,8'd0,8'd0,8'd2},
  {8'd1,8'd1,8'd1,8'd2,8'd2,8'd2,8'd1,8'd2,8'd2,8'd2,8'd0,8'd0},
  {8'd0,8'd0,8'd0,8'd0,8'd0,8'd1,8'd2,8'd0,8'd0,8'd0,8'd1,8'd0},
  {8'd0,8'd1,8'd2,8'd1,8'd0,8'd1,8'd1,8'd2,8'd0,8'd2,8'd2,8'd1},
  {8'd0,8'd0,8'd0,8'd1,8'd0,8'd1,8'd0,8'd2,8'd2,8'd1,8'd2,8'd2},
  {8'd0,8'd1,8'd0,8'd2,8'd1,8'd1,8'd0,8'd0,8'd2,8'd2,8'd2,8'd0},
  {8'd2,8'd0,8'd1,8'd2,8'd2,8'd0,8'd1,8'd0,8'd1,8'd2,8'd2,8'd0},
  {8'd2,8'd2,8'd1,8'd0,8'd2,8'd1,8'd1,8'd0,8'd0,8'd1,8'd0,8'd1},
  {8'd0,8'd0,8'd0,8'd1,8'd1,8'd1,8'd0,8'd2,8'd1,8'd0,8'd0,8'd1},
  {8'd0,8'd1,8'd1,8'd0,8'd1,8'd2,8'd1,8'd0,8'd1,8'd0,8'd1,8'd1},
  {8'd1,8'd0,8'd1,8'd1,8'd0,8'd1,8'd2,8'd2,8'd1,8'd1,8'd0,8'd2},
  {8'd0,8'd0,8'd1,8'd1,8'd0,8'd2,8'd1,8'd0,8'd1,8'd0,8'd2,8'd1}};

integer problem_size = 12;

task initialize_brams_for_8x8();
begin
   //A is stored in row major format
   for (int i=0; i<problem_size; i++) begin
       for (int j=0; j<problem_size; j++) begin
           u_top.matrix_A.ram[a_start_addr+problem_size*i+j] = a[j][i];
       end
   end

  //B is stored in col major format
   for (int i=0; i<problem_size; i++) begin
       for (int j=0; j<problem_size; j++) begin
           u_top.matrix_B.ram[b_start_addr+problem_size*i+j] = b[i][j];
           #1;
       end
    end

end
endtask

