
`timescale 1ns/1ns
module matmul_tb;

reg clk;
reg resetn;
reg start;
reg clear_done;

matrix_multiplication u_matmul(
  .clk(clk), 
  .clk_mem(clk),
  .resetn(resetn), 
  .pe_resetn(resetn), 
  .PCLK(clk),
  .PRESETn(resetn)
  );

initial begin
  clk = 0;
  forever begin
    #10 clk = ~clk;
  end
end

initial begin
  resetn = 0;
  #55 resetn = 1;
end

initial begin
  force u_matmul.start_reg = start;
  force u_matmul.clear_done_reg = clear_done;
end

initial begin
  start = 0;
  #115 start = 1;
  @(posedge u_matmul.done_mat_mul);
  start = 0;
  clear_done = 1;
  #200;
  #115 start = 1;
  @(posedge u_matmul.done_mat_mul);
  start = 0;
  clear_done = 1;
  #200;
  $finish;
end

reg [`DWIDTH-1:0] a[16][16] = 
'{{8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  // -> goes to matrix_A_0_0.ram
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  // -> goes to matrix_A_0_0.ram
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  // -> goes to matrix_A_0_0.ram
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  // -> goes to matrix_A_0_0.ram
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  // -> goes to matrix_A_0_0.ram
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  // -> goes to matrix_A_0_0.ram
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  // -> goes to matrix_A_0_0.ram
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  // -> goes to matrix_A_0_0.ram
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  // -> goes to matrix_A_1_0.ram
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  // -> goes to matrix_A_1_0.ram
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  // -> goes to matrix_A_1_0.ram
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  // -> goes to matrix_A_1_0.ram
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  // -> goes to matrix_A_1_0.ram
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  // -> goes to matrix_A_1_0.ram
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  // -> goes to matrix_A_1_0.ram
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1}}; // -> goes to matrix_A_1_0.ram

reg [`DWIDTH-1:0] b[16][16] = 
'{{8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1}};

// |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    | 
// go to matrix_B_0_0.ram   |    |    |    |    |    |    |    |    |    |    | 
//                     |    |    |    |    |    |    |    |    |    |    |    |
//                    go to matrix_B_0_0.ram    |    |    |    |    |    |    |
//                                         |    |    |    |    |    |    |    |
//                                         go to matrix_B_0_1.ram   |    |    |  
//                                                             |    |    |    |  
//                                                             go to matrix_B_0_1.ram

// There will be 4 BRAMs for each A and B
// Assume i increases in horizontal direction
initial begin

for (int i=0; i<16; i++) begin
  for (int j=0; j<8; j++) begin
    u_matmul.matrix_A_0_0.ram[8*i + j] = a[i][j];
  end
  for (int j=8; j<16; j++) begin
    u_matmul.matrix_A_1_0.ram[8*i + j-8] = a[i][j];
  end
end

for (int j=0; j<16; j++) begin
  for (int i=0; i<8; i++) begin
    u_matmul.matrix_B_0_0.ram[8*j + i] = b[i][j];
  end
  for (int i=8; i<16; i++) begin
    u_matmul.matrix_B_0_1.ram[8*j + i-8] = b[i][j];
  end
end

end
/*
reg [15:0] matA [15:0] = '{1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6};
reg [15:0] matB [15:0] = '{4,5,2,8,5,8,0,2,6,9,5,8,3,9,3,0};

initial begin
  enable_writing_to_mem = 0;
  we1 = 0;
  we2 = 0;
  data_pi = 0;
  addr_pi = 0;
  #65;

  enable_writing_to_mem = 1;

//write first memory
  for(int i=0; i<16; i++) begin
    we1 = 1;
    we2 = 0;
    addr_pi = i;
    data_pi = matA[i];
    @(posedge clk);
    #5;
  end

  we1 = 0;
  we2 = 0;
  data_pi = 0;
  addr_pi = 0;
  @(posedge clk);

//write second memory
  for(int i=0; i<16; i++) begin
    we1 = 0;
    we2 = 1;
    addr_pi = i;
    data_pi = matB[i];
    @(posedge clk);
    #5;
  end

  we1 = 0;
  we2 = 0;

  #25;
//start matrix multiplication process  
  enable_writing_to_mem = 0;
  addr_pi = 0;
  while(1) begin
    @(posedge clk);
    if (done_mat_mul == 1) begin
        break;
    end
  end

  for(int i=0; i<16; i++) begin
    out_sel = i;
    @(posedge clk);
  end

    @(posedge clk);

  $finish;
end
*/

initial begin
  $vcdpluson;
  $vcdplusmemon;
end

endmodule
