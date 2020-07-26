module npo2_test();

reg done;
reg [`REG_DATAWIDTH-1:0] rdata;
reg [`REG_DATAWIDTH-1:0] wdata;

task run();
begin
  initialize_brams();
  npo2_test();
  compare_outputs();
end
endtask

integer mean = 1;
integer inv_var = 1;

`ifdef MATMUL_SIZE_4
NOT SUPPORTING 4x4 here
`endif

`ifdef MATMUL_SIZE_8
integer a_start_addr = 0;
integer b_start_addr = 0;
integer c_start_addr = 600;
//integer problem_size = 24;
integer gemm_M = 14;
integer gemm_K = 12;
integer gemm_N = 16;

//////////////////////////////////////////////
//Initialize BRAMs A and B
//////////////////////////////////////////////
/*
>>> a = np.random.randint(low=0, high=3,size=(14,12), dtype=np.uint8)
>>> print(a)
[[1 1 2 2 0 2 0 0 0 2 0 2]
 [0 1 0 2 0 2 1 1 0 0 1 0]
 [1 1 2 2 0 2 1 1 0 1 2 0]
 [2 1 0 0 1 0 1 0 0 2 2 1]
 [1 2 2 0 0 2 0 0 0 0 1 0]
 [1 1 0 2 1 2 1 1 2 0 1 0]
 [2 1 2 2 0 1 1 1 1 1 1 1]
 [0 2 1 0 1 2 1 1 2 2 2 2]
 [2 2 1 0 0 1 0 0 0 1 0 1]
 [2 2 0 2 0 2 0 2 0 0 2 0]
 [0 2 0 1 2 1 0 2 2 0 0 0]
 [2 0 0 1 0 0 1 0 2 0 0 1]
 [0 1 2 2 1 1 0 1 1 0 2 0]
 [0 2 0 0 1 1 2 0 0 1 2 1]]
>>> b = np.random.randint(low=0, high=3,size=(12,16), dtype=np.uint8)
>>> print(b)
[[2 0 1 2 2 0 0 2 1 1 0 1 0 1 2 1]
 [0 1 2 2 1 1 2 1 1 0 0 1 0 0 2 0]
 [0 2 2 0 2 2 1 0 2 0 1 2 1 0 1 2]
 [1 1 2 0 2 2 2 0 2 0 0 1 2 0 2 1]
 [0 2 1 1 2 0 2 0 2 1 2 0 2 1 2 1]
 [0 0 0 0 0 2 0 0 2 2 2 1 1 1 2 1]
 [1 1 0 1 2 1 2 0 2 1 1 2 2 0 1 1]
 [2 1 1 0 2 0 0 0 0 1 0 2 1 0 2 0]
 [2 1 0 1 2 0 1 0 0 2 1 1 1 1 2 2]
 [0 2 0 0 2 0 2 2 1 2 2 0 0 1 0 2]
 [2 0 2 2 2 1 0 0 1 2 2 1 1 2 1 1]
 [2 0 0 1 1 1 0 2 2 1 0 2 1 2 0 2]]
>>> c=np.matmul(a,b)
>>> print(c)
[[ 8 11 11  6 17 15 12 11 20 11 10 14 10  9 14 17]
 [ 7  5  9  5 11 11  8  1 12  8  7 10 10  4 14  6]
 [11 11 16  9 21 16 12  5 19 13 13 16 13  8 19 14]
 [11  8  9 13 18  5 10 11 13 13 11  9  7 11 11 12]
 [ 4  6 11  8 10 11  6  4 12  7  8 10  5  5 13  8]
 [13  9 11 10 19 11 12  3 15 14 11 13 14  8 22 12]
 [15 12 15 11 24 14 13  9 19 13 10 18 13  9 20 17]
 [15 14 12 14 24 13 15 10 20 21 18 18 14 15 20 20]
 [ 6  6  8  9 11  7  7 10 11  7  5  9  3  6 11  9]
 [14  6 16 12 18 12  8  6 14 12  8 14 10  8 22  8]
 [ 9 11 10  8 16  6 12  2 10 10  8 10 11  5 20  8]
 [12  4  4  8 13  4  6  6  8  8  3  9  7  6 11 10]
 [10 11 16  8 19 13 11  1 15 10 11 13 13  7 18 12]
 [ 8  8  9 12 15  9 12  6 15 12 12 11 10  9 12 10]]
>>> np.set_printoptions(formatter={'int':hex})
>>> print(c)
[[0x8 0xb 0xb 0x6 0x11 0xf 0xc 0xb 0x14 0xb 0xa 0xe 0xa 0x9 0xe 0x11]
 [0x7 0x5 0x9 0x5 0xb 0xb 0x8 0x1 0xc 0x8 0x7 0xa 0xa 0x4 0xe 0x6]
 [0xb 0xb 0x10 0x9 0x15 0x10 0xc 0x5 0x13 0xd 0xd 0x10 0xd 0x8 0x13 0xe]
 [0xb 0x8 0x9 0xd 0x12 0x5 0xa 0xb 0xd 0xd 0xb 0x9 0x7 0xb 0xb 0xc]
 [0x4 0x6 0xb 0x8 0xa 0xb 0x6 0x4 0xc 0x7 0x8 0xa 0x5 0x5 0xd 0x8]
 [0xd 0x9 0xb 0xa 0x13 0xb 0xc 0x3 0xf 0xe 0xb 0xd 0xe 0x8 0x16 0xc]
 [0xf 0xc 0xf 0xb 0x18 0xe 0xd 0x9 0x13 0xd 0xa 0x12 0xd 0x9 0x14 0x11]
 [0xf 0xe 0xc 0xe 0x18 0xd 0xf 0xa 0x14 0x15 0x12 0x12 0xe 0xf 0x14 0x14]
 [0x6 0x6 0x8 0x9 0xb 0x7 0x7 0xa 0xb 0x7 0x5 0x9 0x3 0x6 0xb 0x9]
 [0xe 0x6 0x10 0xc 0x12 0xc 0x8 0x6 0xe 0xc 0x8 0xe 0xa 0x8 0x16 0x8]
 [0x9 0xb 0xa 0x8 0x10 0x6 0xc 0x2 0xa 0xa 0x8 0xa 0xb 0x5 0x14 0x8]
 [0xc 0x4 0x4 0x8 0xd 0x4 0x6 0x6 0x8 0x8 0x3 0x9 0x7 0x6 0xb 0xa]
 [0xa 0xb 0x10 0x8 0x13 0xd 0xb 0x1 0xf 0xa 0xb 0xd 0xd 0x7 0x12 0xc]
 [0x8 0x8 0x9 0xc 0xf 0x9 0xc 0x6 0xf 0xc 0xc 0xb 0xa 0x9 0xc 0xa]]
>>>
*/

reg [`DWIDTH-1:0] a[14][12] = 
'{{8'd1,8'd1,8'd2,8'd2,8'd0,8'd2,8'd0,8'd0,8'd0,8'd2,8'd0,8'd2},
  {8'd0,8'd1,8'd0,8'd2,8'd0,8'd2,8'd1,8'd1,8'd0,8'd0,8'd1,8'd0},
  {8'd1,8'd1,8'd2,8'd2,8'd0,8'd2,8'd1,8'd1,8'd0,8'd1,8'd2,8'd0},
  {8'd2,8'd1,8'd0,8'd0,8'd1,8'd0,8'd1,8'd0,8'd0,8'd2,8'd2,8'd1},
  {8'd1,8'd2,8'd2,8'd0,8'd0,8'd2,8'd0,8'd0,8'd0,8'd0,8'd1,8'd0},
  {8'd1,8'd1,8'd0,8'd2,8'd1,8'd2,8'd1,8'd1,8'd2,8'd0,8'd1,8'd0},
  {8'd2,8'd1,8'd2,8'd2,8'd0,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd0,8'd2,8'd1,8'd0,8'd1,8'd2,8'd1,8'd1,8'd2,8'd2,8'd2,8'd2},
  {8'd2,8'd2,8'd1,8'd0,8'd0,8'd1,8'd0,8'd0,8'd0,8'd1,8'd0,8'd1},
  {8'd2,8'd2,8'd0,8'd2,8'd0,8'd2,8'd0,8'd2,8'd0,8'd0,8'd2,8'd0},
  {8'd0,8'd2,8'd0,8'd1,8'd2,8'd1,8'd0,8'd2,8'd2,8'd0,8'd0,8'd0},
  {8'd2,8'd0,8'd0,8'd1,8'd0,8'd0,8'd1,8'd0,8'd2,8'd0,8'd0,8'd1},
  {8'd0,8'd1,8'd2,8'd2,8'd1,8'd1,8'd0,8'd1,8'd1,8'd0,8'd2,8'd0},
  {8'd0,8'd2,8'd0,8'd0,8'd1,8'd1,8'd2,8'd0,8'd0,8'd1,8'd2,8'd1}};

reg [`DWIDTH-1:0] b[12][16] =   
'{{8'd2,8'd0,8'd1,8'd2,8'd2,8'd0,8'd0,8'd2,8'd1,8'd1,8'd0,8'd1,8'd0,8'd1,8'd2,8'd1},
  {8'd0,8'd1,8'd2,8'd2,8'd1,8'd1,8'd2,8'd1,8'd1,8'd0,8'd0,8'd1,8'd0,8'd0,8'd2,8'd0},
  {8'd0,8'd2,8'd2,8'd0,8'd2,8'd2,8'd1,8'd0,8'd2,8'd0,8'd1,8'd2,8'd1,8'd0,8'd1,8'd2},
  {8'd1,8'd1,8'd2,8'd0,8'd2,8'd2,8'd2,8'd0,8'd2,8'd0,8'd0,8'd1,8'd2,8'd0,8'd2,8'd1},
  {8'd0,8'd2,8'd1,8'd1,8'd2,8'd0,8'd2,8'd0,8'd2,8'd1,8'd2,8'd0,8'd2,8'd1,8'd2,8'd1},
  {8'd0,8'd0,8'd0,8'd0,8'd0,8'd2,8'd0,8'd0,8'd2,8'd2,8'd2,8'd1,8'd1,8'd1,8'd2,8'd1},
  {8'd1,8'd1,8'd0,8'd1,8'd2,8'd1,8'd2,8'd0,8'd2,8'd1,8'd1,8'd2,8'd2,8'd0,8'd1,8'd1},
  {8'd2,8'd1,8'd1,8'd0,8'd2,8'd0,8'd0,8'd0,8'd0,8'd1,8'd0,8'd2,8'd1,8'd0,8'd2,8'd0},
  {8'd2,8'd1,8'd0,8'd1,8'd2,8'd0,8'd1,8'd0,8'd0,8'd2,8'd1,8'd1,8'd1,8'd1,8'd2,8'd2},
  {8'd0,8'd2,8'd0,8'd0,8'd2,8'd0,8'd2,8'd2,8'd1,8'd2,8'd2,8'd0,8'd0,8'd1,8'd0,8'd2},
  {8'd2,8'd0,8'd2,8'd2,8'd2,8'd1,8'd0,8'd0,8'd1,8'd2,8'd2,8'd1,8'd1,8'd2,8'd1,8'd1},
  {8'd2,8'd0,8'd0,8'd1,8'd1,8'd1,8'd0,8'd2,8'd2,8'd1,8'd0,8'd2,8'd1,8'd2,8'd0,8'd2}};

reg [`DWIDTH-1:0] c[14][16] =   
'{{ 8'd8,18'd1,18'd1, 8'd6,18'd7,18'd5,18'd2,18'd1,28'd0,18'd1,18'd0,18'd4,18'd0, 8'd9,18'd4,8'd17},
  { 8'd7, 8'd5, 8'd9, 8'd5,18'd1,18'd1, 8'd8, 8'd1,18'd2, 8'd8, 8'd7,18'd0,18'd0, 8'd4,18'd4, 8'd6},
  {18'd1,18'd1,18'd6, 8'd9,28'd1,18'd6,18'd2, 8'd5,18'd9,18'd3,18'd3,18'd6,18'd3, 8'd8,18'd9,8'd14},
  {18'd1, 8'd8, 8'd9,18'd3,18'd8, 8'd5,18'd0,18'd1,18'd3,18'd3,18'd1, 8'd9, 8'd7,18'd1,18'd1,8'd12},
  { 8'd4, 8'd6,18'd1, 8'd8,18'd0,18'd1, 8'd6, 8'd4,18'd2, 8'd7, 8'd8,18'd0, 8'd5, 8'd5,18'd3, 8'd8},
  {18'd3, 8'd9,18'd1,18'd0,18'd9,18'd1,18'd2, 8'd3,18'd5,18'd4,18'd1,18'd3,18'd4, 8'd8,28'd2,8'd12},
  {18'd5,18'd2,18'd5,18'd1,28'd4,18'd4,18'd3, 8'd9,18'd9,18'd3,18'd0,18'd8,18'd3, 8'd9,28'd0,8'd17},
  {18'd5,18'd4,18'd2,18'd4,28'd4,18'd3,18'd5,18'd0,28'd0,28'd1,18'd8,18'd8,18'd4,18'd5,28'd0,8'd20},
  { 8'd6, 8'd6, 8'd8, 8'd9,18'd1, 8'd7, 8'd7,18'd0,18'd1, 8'd7, 8'd5, 8'd9, 8'd3, 8'd6,18'd1, 8'd9},
  {18'd4, 8'd6,18'd6,18'd2,18'd8,18'd2, 8'd8, 8'd6,18'd4,18'd2, 8'd8,18'd4,18'd0, 8'd8,28'd2, 8'd8},
  { 8'd9,18'd1,18'd0, 8'd8,18'd6, 8'd6,18'd2, 8'd2,18'd0,18'd0, 8'd8,18'd0,18'd1, 8'd5,28'd0, 8'd8},
  {18'd2, 8'd4, 8'd4, 8'd8,18'd3, 8'd4, 8'd6, 8'd6, 8'd8, 8'd8, 8'd3, 8'd9, 8'd7, 8'd6,18'd1,8'd10},
  {18'd0,18'd1,18'd6, 8'd8,18'd9,18'd3,18'd1, 8'd1,18'd5,18'd0,18'd1,18'd3,18'd3, 8'd7,18'd8,8'd12},
  { 8'd8, 8'd8, 8'd9,18'd2,18'd5, 8'd9,18'd2, 8'd6,18'd5,18'd2,18'd2,18'd1,18'd0, 8'd9,18'd2,8'd10}};

`endif

////////////////////////////////////////////
//Task to initialize BRAMs
////////////////////////////////////////////
task initialize_brams();
begin
   //A is stored in col major format
   for (int i=0; i<gemm_K; i++) begin
       for (int j=0; j<gemm_M; j++) begin
           u_top.matrix_A.ram[a_start_addr+gemm_M*i+j] = a[j][i];
       end
   end

  //B is stored in row major format
   for (int i=0; i<gemm_K; i++) begin
       for (int j=0; j<gemm_N; j++) begin
           u_top.matrix_B.ram[b_start_addr+gemm_N*i+j] = b[i][j];
       end
    end

end
endtask

////////////////////////////////////////////
//Task to compare outputs with expected values
////////////////////////////////////////////
task compare_outputs();
begin
   integer fail = 0;
   integer address, observed, expected;
   //C is stored like A
   for (int i=0; i<gemm_M; i++) begin
       for (int j=0; j<gemm_K; j++) begin
           address = c_start_addr+gemm_K*i+j;
           observed = u_top.matrix_A.ram[address];
           expected = c[j][i];
           if (expected != observed) begin
             $display("Mismatch found. Address = %0d, Expected = %0d, Observed = %0d", address, expected, observed);
             fail = 1;
           end
       end
   end
   if (fail == 0) begin
     $display("===============================");
     $display("Test passed");
     $display("===============================");
   end
end
endtask

////////////////////////////////////////////
//The actual test
////////////////////////////////////////////
task npo2_test();
begin
  done = 0;
  //Start the actual test
  $display("Set enables to 1");
  //enable_matmul = 1;
  //enable_norm = 1;
  //enable_activation = 1;
  //enable_pool = 1;

  //reg value to enable all blocks (non conv mode)
  wdata = 32'h0000_000f;
  if ($test$plusargs("norm_disabled")) begin
    wdata &= 32'b1111_1111_1111_1111_1111_1111_1111_1101;
  end 
  if ($test$plusargs("pool_disabled")) begin
    wdata &= 32'b1111_1111_1111_1111_1111_1111_1111_1011;
  end 
  if ($test$plusargs("activation_disabled")) begin
    wdata &= 32'b1111_1111_1111_1111_1111_1111_1111_0111;
  end 
  write(`REG_ENABLES_ADDR, wdata);
  read(`REG_ENABLES_ADDR, rdata);

  $display("Configure the value of mean and inv_variance");
  write(`REG_MEAN_ADDR, mean);
  write(`REG_INV_VAR_ADDR, inv_var);

  for (int tile_x = 0; tile_x < gemm_N/`MAT_MUL_SIZE; tile_x++) begin
  for (int tile_y = 0; tile_y < (gemm_M/`MAT_MUL_SIZE + 1); tile_y++) begin
 
  /////////////////////////////////////////////////////////////////
  //First pass
  /////////////////////////////////////////////////////////////////
  write(`REG_MATRIX_A_STRIDE_ADDR, 14);
  write(`REG_MATRIX_B_STRIDE_ADDR, 16);
  write(`REG_MATRIX_C_STRIDE_ADDR, 14);

  if ((tile_x == 1) && (tile_y == 0)) begin
    //Set rows 7-8 of A as invalid.
    write(`REG_VALID_MASK_ADDR, 32'hffff_ff3f);
  end
  if ((tile_x == 1) && (tile_y == 1)) begin
    //Set rows 7-8 of A as invalid.
    write(`REG_VALID_MASK_ADDR, 32'hffff_ff3f);
  end

  //Set save_output_to_accum = 1 and set add_accum_to_output = 1 (even though we don't need to add)
  //write(`REG_ACCUM_ACTIONS_ADDR, 32'h0000_0003);
  //Configure addresses
  //We don't need to configure C addr right now actually because output won't be written to bram
  //But it's okay. Let's do it now anyway.
  write(`REG_MATRIX_A_ADDR, a_start_addr + tile_x*`MAT_MUL_SIZE);
  write(`REG_MATRIX_B_ADDR, b_start_addr + tile_y*`MAT_MUL_SIZE);
  write(`REG_MATRIX_C_ADDR, c_start_addr + tile_x*`MAT_MUL_SIZE + tile_y*`MAT_MUL_SIZE*gemm_M);

  $display("Start the TPU for first pass");
  //start = 1;
  //also pe_reset = 1
  write(`REG_STDN_TPU_ADDR, 32'h0000_8001);
  
  $display("Wait until TPU is done");
  do 
  begin
      read(`REG_STDN_TPU_ADDR, rdata);
      done = rdata[31];
  end 
  while (done == 0);

  $display("Stop the TPU");
  //start = 0;
  write(`REG_STDN_TPU_ADDR, 32'h0000_0000);

  /////////////////////////////////////////////////////////////////
  //Second pass
  /////////////////////////////////////////////////////////////////
  write(`REG_MATRIX_A_STRIDE_ADDR, 14);
  write(`REG_MATRIX_B_STRIDE_ADDR, 16);
  write(`REG_MATRIX_C_STRIDE_ADDR, 14);

  if ((tile_x == 0) && (tile_y == 0)) begin
    //Set cols4-7 of A as invalid.
    write(`REG_VALID_MASK_ADDR, 32'hffff_0fff);
  end
  if ((tile_x == 0) && (tile_y == 1)) begin
    //Set cols4-7 of A as invalid.
    write(`REG_VALID_MASK_ADDR, 32'hffff_0fff);
  end
  if ((tile_x == 1) && (tile_y == 0)) begin
    //Set cols 4-7 of A as invalid. rows 7-8 of A as invalid.
    write(`REG_VALID_MASK_ADDR, 32'hffff_0f3f);
  end
  if ((tile_x == 1) && (tile_y == 1)) begin
    //Set cols 4-7 of A as invalid. rows 7-8 of A as invalid.
    write(`REG_VALID_MASK_ADDR, 32'hffff_0f3f);
  end

  //Set save_output_to_accum = 1 and set add_accum_to_output = 1 
  //Already configured in step 1
  //Configure strides to 12 (because we have 3 tiles in each direction)
  //Already configured in step 1
  //Configure addresses. Matrix C address is already configured.
  write(`REG_MATRIX_A_ADDR, a_start_addr + gemm_M* `MAT_MUL_SIZE + tile_x*`MAT_MUL_SIZE);
  write(`REG_MATRIX_B_ADDR, b_start_addr + gemm_N* `MAT_MUL_SIZE + tile_y*`MAT_MUL_SIZE);

  $display("Start the TPU for second pass");
  //start = 1;
  write(`REG_STDN_TPU_ADDR, 32'h0000_0001);
  
  $display("Wait until TPU is done");
  do 
  begin
      read(`REG_STDN_TPU_ADDR, rdata);
      done = rdata[31];
  end 
  while (done == 0);

  $display("Stop the TPU");
  //start = 0;
  write(`REG_STDN_TPU_ADDR, 32'h0000_0000);

end
end

end
endtask

endmodule
