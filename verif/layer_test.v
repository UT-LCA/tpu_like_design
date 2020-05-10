module layer_test();

reg done;
reg [`REG_DATAWIDTH-1:0] rdata;

task run();
begin
    initialize_brams();
    layer_test();
    compare_outputs();
end
endtask

integer mean = 1;
integer inv_var = 1;

`ifdef MATMUL_SIZE_4
integer a_start_addr = 0;
integer b_start_addr = 0;
integer c_start_addr = 200;
integer problem_size = 4;

reg [`DWIDTH-1:0] a[4][4] = 
'{{8,4,6,8},
  {3,3,3,7},
  {5,2,1,6},
  {9,1,0,5}};

reg [`DWIDTH-1:0] b[4][4] = 
'{{1,1,3,0},
  {0,1,4,3},
  {3,5,3,1},
  {9,6,3,2}};

reg [`DWIDTH-1:0] c[4][4] = 
'{{98,90,82,34},
  {75,63,51,26},
  {62,48,44,19},
  {54,40,46,13}};

// c in hex  
//62 5a 52 22 
//4b 3f 33 1a
//3e 30 2c 13
//36 28 2e 0d
`endif

`ifdef MATMUL_SIZE_8
/*
>>> a = np.random.randint(low=0, high=5,size=(8,8), dtype=np.uint8)
>>> print(a)
[[4 0 2 0 3 2 2 0]
 [1 2 3 4 1 1 1 3]
 [0 2 2 1 0 3 2 2]
 [1 0 2 3 2 0 1 0]
 [4 2 1 1 3 2 1 4]
 [2 0 2 2 0 1 0 1]
 [0 1 1 3 2 4 4 4]
 [2 2 3 0 0 4 2 3]]
>>> b = np.random.randint(low=0, high=5,size=(8,8), dtype=np.uint8)
>>> print(b)
[[1 2 3 3 3 2 2 1]
 [0 0 3 2 1 3 4 2]
 [1 0 2 2 2 4 3 3]
 [2 4 3 2 0 0 3 3]
 [2 1 4 0 3 4 2 0]
 [0 2 2 3 1 2 1 0]
 [0 1 0 4 0 1 0 2]
 [3 2 1 0 3 4 2 2]]
>>> c=np.matmul(a,b)
>>> print(c)
[[12 17 32 30 27 34 22 14]
 [23 28 36 28 24 39 40 34]
 [10 16 21 27 15 30 24 21]
 [13 17 24 17 13 19 21 18]
 [25 28 43 30 39 51 38 24]
 [11 16 19 17 14 18 19 16]
 [23 34 34 38 25 43 32 30]
 [14 20 29 36 27 44 31 25]]
>>> np.set_printoptions(formatter={'int':hex})
>>> print(c)
[[0xc 0x11 0x20 0x1e 0x1b 0x22 0x16 0xe]
 [0x17 0x1c 0x24 0x1c 0x18 0x27 0x28 0x22]
 [0xa 0x10 0x15 0x1b 0xf 0x1e 0x18 0x15]
 [0xd 0x11 0x18 0x11 0xd 0x13 0x15 0x12]
 [0x19 0x1c 0x2b 0x1e 0x27 0x33 0x26 0x18]
 [0xb 0x10 0x13 0x11 0xe 0x12 0x13 0x10]
 [0x17 0x22 0x22 0x26 0x19 0x2b 0x20 0x1e]
 [0xe 0x14 0x1d 0x24 0x1b 0x2c 0x1f 0x19]]
*/

integer a_start_addr = 0;
integer b_start_addr = 150;
integer c_start_addr = 400;
integer problem_size = 8;

reg [`DWIDTH-1:0] a[8][8] = 
'{{8'd4,8'd0,8'd2,8'd0,8'd3,8'd2,8'd2,8'd0},
  {8'd1,8'd2,8'd3,8'd4,8'd1,8'd1,8'd1,8'd3},
  {8'd0,8'd2,8'd2,8'd1,8'd0,8'd3,8'd2,8'd2},
  {8'd1,8'd0,8'd2,8'd3,8'd2,8'd0,8'd1,8'd0},
  {8'd4,8'd2,8'd1,8'd1,8'd3,8'd2,8'd1,8'd4},
  {8'd2,8'd0,8'd2,8'd2,8'd0,8'd1,8'd0,8'd1},
  {8'd0,8'd1,8'd1,8'd3,8'd2,8'd4,8'd4,8'd4},
  {8'd2,8'd2,8'd3,8'd0,8'd0,8'd4,8'd2,8'd3}};

reg [`DWIDTH-1:0] b[8][8] = 
'{{8'd1,8'd2,8'd3,8'd3,8'd3,8'd2,8'd2,8'd1},
  {8'd0,8'd0,8'd3,8'd2,8'd1,8'd3,8'd4,8'd2},
  {8'd1,8'd0,8'd2,8'd2,8'd2,8'd4,8'd3,8'd3},
  {8'd2,8'd4,8'd3,8'd2,8'd0,8'd0,8'd3,8'd3},
  {8'd2,8'd1,8'd4,8'd0,8'd3,8'd4,8'd2,8'd0},
  {8'd0,8'd2,8'd2,8'd3,8'd1,8'd2,8'd1,8'd0},
  {8'd0,8'd1,8'd0,8'd4,8'd0,8'd1,8'd0,8'd2},
  {8'd3,8'd2,8'd1,8'd0,8'd3,8'd4,8'd2,8'd2}};

reg [`DWIDTH-1:0] c[8][8] = 
'{{8'd12,8'd17,8'd32,8'd30,8'd27,8'd34,8'd22,8'd14},
  {8'd23,8'd28,8'd36,8'd28,8'd24,8'd39,8'd40,8'd34},
  {8'd10,8'd16,8'd21,8'd27,8'd15,8'd30,8'd24,8'd21},
  {8'd13,8'd17,8'd24,8'd17,8'd13,8'd19,8'd21,8'd18},
  {8'd25,8'd28,8'd43,8'd30,8'd39,8'd51,8'd38,8'd24},
  {8'd11,8'd16,8'd19,8'd17,8'd14,8'd18,8'd19,8'd16},
  {8'd23,8'd34,8'd34,8'd38,8'd25,8'd43,8'd32,8'd30},
  {8'd14,8'd20,8'd29,8'd36,8'd27,8'd44,8'd31,8'd25}};

`endif

////////////////////////////////////////////
//Task to initialize BRAMs
////////////////////////////////////////////
task initialize_brams();
begin
   //A is stored in col major format
   for (int i=0; i<problem_size; i++) begin
       for (int j=0; j<problem_size; j++) begin
           u_top.matrix_A.ram[a_start_addr+problem_size*i+j] = a[j][i];
       end
   end

  //B is stored in row major format
   for (int i=0; i<problem_size; i++) begin
       for (int j=0; j<problem_size; j++) begin
           u_top.matrix_B.ram[b_start_addr+problem_size*i+j] = b[i][j];
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
   ////////Note that this is only testing first layer
   for (int i=0; i<problem_size; i++) begin
       for (int j=0; j<problem_size; j++) begin
           address = c_start_addr+problem_size*i+j;
           observed = u_top.matrix_A.ram[address];
           expected = (c[j][i] - mean) * inv_var;
           if (expected != observed) begin
             $display("Mismatch found. Address = %0d, Expected = %0d, Observed = %0d", address, expected, observed);
             fail = 1;
           end
       end
   end
   if (fail == 0) begin
     $display("===============================");
     $display("Test passed (only first layer's output was compared)");
     $display("===============================");
   end
end
endtask

////////////////////////////////////////////
//The actual test
////////////////////////////////////////////
task layer_test();
begin
  done = 0;
  //Start the actual test
  $display("Set enables to 1");
  //enable_matmul = 1;
  //enable_norm = 1;
  //enable_activation = 1;
  //enable_pool = 1;
  if ($test$plusargs("norm_disabled")) begin
    write(`REG_ENABLES_ADDR, 32'h0000_000d);
  end 
  else if ($test$plusargs("pool_disabled")) begin
    write(`REG_ENABLES_ADDR, 32'h0000_000b);
  end 
  else if ($test$plusargs("activation_disabled")) begin
    write(`REG_ENABLES_ADDR, 32'h0000_0007);
  end 
  else begin//all blocks enabled
    write(`REG_ENABLES_ADDR, 32'h0000_000f);
  end
  read(`REG_ENABLES_ADDR, rdata);

  $display("Configure the value of mean and inv_variance");
  write(`REG_MEAN_ADDR, mean);
  write(`REG_INV_VAR_ADDR, inv_var);

  $display("-------------------------------------------");
  $display("Layer 0");
  $display("-------------------------------------------");
  $display("Configure the addresses of matrix A, B and C");
  write(`REG_MATRIX_A_ADDR, a_start_addr);
  write(`REG_MATRIX_B_ADDR, b_start_addr);
  write(`REG_MATRIX_C_ADDR, c_start_addr);

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
  //matrix A -> addr_mat_c (the last layer wrote output here)
  write(`REG_MATRIX_A_ADDR, c_start_addr); //
  write(`REG_MATRIX_B_ADDR, b_start_addr);
  write(`REG_MATRIX_C_ADDR, c_start_addr+500);

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

endmodule
