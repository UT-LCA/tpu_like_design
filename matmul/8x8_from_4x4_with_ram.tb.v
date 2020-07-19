
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


initial begin
  //A is stored in row major format
force u_matmul.matrix_A_0_0.ram[ 0] = 8'h02;
force u_matmul.matrix_A_0_0.ram[ 1] = 8'h02;
force u_matmul.matrix_A_0_0.ram[ 2] = 8'h02;
force u_matmul.matrix_A_0_0.ram[ 3] = 8'h02;
force u_matmul.matrix_A_0_0.ram[ 4] = 8'h02;
force u_matmul.matrix_A_0_0.ram[ 5] = 8'h02;
force u_matmul.matrix_A_0_0.ram[ 6] = 8'h02;
force u_matmul.matrix_A_0_0.ram[ 7] = 8'h02;
force u_matmul.matrix_A_0_0.ram[ 8] = 8'h02;
force u_matmul.matrix_A_0_0.ram[ 9] = 8'h02;
force u_matmul.matrix_A_0_0.ram[10] = 8'h02;
force u_matmul.matrix_A_0_0.ram[11] = 8'h02;
force u_matmul.matrix_A_0_0.ram[12] = 8'h02;
force u_matmul.matrix_A_0_0.ram[13] = 8'h02;
force u_matmul.matrix_A_0_0.ram[14] = 8'h02;
force u_matmul.matrix_A_0_0.ram[15] = 8'h02;
force u_matmul.matrix_A_0_0.ram[16] = 8'h02;
force u_matmul.matrix_A_0_0.ram[17] = 8'h02;
force u_matmul.matrix_A_0_0.ram[18] = 8'h02;
force u_matmul.matrix_A_0_0.ram[19] = 8'h02;
force u_matmul.matrix_A_0_0.ram[20] = 8'h02;
force u_matmul.matrix_A_0_0.ram[21] = 8'h02;
force u_matmul.matrix_A_0_0.ram[22] = 8'h02;
force u_matmul.matrix_A_0_0.ram[23] = 8'h02;
force u_matmul.matrix_A_0_0.ram[24] = 8'h02;
force u_matmul.matrix_A_0_0.ram[25] = 8'h02;
force u_matmul.matrix_A_0_0.ram[26] = 8'h02;
force u_matmul.matrix_A_0_0.ram[27] = 8'h02;
force u_matmul.matrix_A_0_0.ram[28] = 8'h02;
force u_matmul.matrix_A_0_0.ram[29] = 8'h02;
force u_matmul.matrix_A_0_0.ram[30] = 8'h02;
force u_matmul.matrix_A_0_0.ram[31] = 8'h02;

force u_matmul.matrix_A_1_0.ram[ 0] = 8'h01;
force u_matmul.matrix_A_1_0.ram[ 1] = 8'h01;
force u_matmul.matrix_A_1_0.ram[ 2] = 8'h01;
force u_matmul.matrix_A_1_0.ram[ 3] = 8'h01;
force u_matmul.matrix_A_1_0.ram[ 4] = 8'h01;
force u_matmul.matrix_A_1_0.ram[ 5] = 8'h01;
force u_matmul.matrix_A_1_0.ram[ 6] = 8'h01;
force u_matmul.matrix_A_1_0.ram[ 7] = 8'h01;
force u_matmul.matrix_A_1_0.ram[ 8] = 8'h01;
force u_matmul.matrix_A_1_0.ram[ 9] = 8'h01;
force u_matmul.matrix_A_1_0.ram[10] = 8'h01;
force u_matmul.matrix_A_1_0.ram[11] = 8'h01;
force u_matmul.matrix_A_1_0.ram[12] = 8'h01;
force u_matmul.matrix_A_1_0.ram[13] = 8'h01;
force u_matmul.matrix_A_1_0.ram[14] = 8'h01;
force u_matmul.matrix_A_1_0.ram[15] = 8'h01;
force u_matmul.matrix_A_1_0.ram[16] = 8'h01;
force u_matmul.matrix_A_1_0.ram[17] = 8'h01;
force u_matmul.matrix_A_1_0.ram[18] = 8'h01;
force u_matmul.matrix_A_1_0.ram[19] = 8'h01;
force u_matmul.matrix_A_1_0.ram[20] = 8'h01;
force u_matmul.matrix_A_1_0.ram[21] = 8'h01;
force u_matmul.matrix_A_1_0.ram[22] = 8'h01;
force u_matmul.matrix_A_1_0.ram[23] = 8'h01;
force u_matmul.matrix_A_1_0.ram[24] = 8'h01;
force u_matmul.matrix_A_1_0.ram[25] = 8'h01;
force u_matmul.matrix_A_1_0.ram[26] = 8'h01;
force u_matmul.matrix_A_1_0.ram[27] = 8'h01;
force u_matmul.matrix_A_1_0.ram[28] = 8'h01;
force u_matmul.matrix_A_1_0.ram[29] = 8'h01;
force u_matmul.matrix_A_1_0.ram[30] = 8'h01;
force u_matmul.matrix_A_1_0.ram[31] = 8'h01;


force u_matmul.matrix_B_0_0.ram[ 0] = 8'h01;
force u_matmul.matrix_B_0_0.ram[ 1] = 8'h01;
force u_matmul.matrix_B_0_0.ram[ 2] = 8'h01;
force u_matmul.matrix_B_0_0.ram[ 3] = 8'h01;
force u_matmul.matrix_B_0_0.ram[ 4] = 8'h01;
force u_matmul.matrix_B_0_0.ram[ 5] = 8'h01;
force u_matmul.matrix_B_0_0.ram[ 6] = 8'h01;
force u_matmul.matrix_B_0_0.ram[ 7] = 8'h01;
force u_matmul.matrix_B_0_0.ram[ 8] = 8'h01;
force u_matmul.matrix_B_0_0.ram[ 9] = 8'h01;
force u_matmul.matrix_B_0_0.ram[10] = 8'h01;
force u_matmul.matrix_B_0_0.ram[11] = 8'h01;
force u_matmul.matrix_B_0_0.ram[12] = 8'h01;
force u_matmul.matrix_B_0_0.ram[13] = 8'h01;
force u_matmul.matrix_B_0_0.ram[14] = 8'h01;
force u_matmul.matrix_B_0_0.ram[15] = 8'h01;
force u_matmul.matrix_B_0_0.ram[16] = 8'h01;
force u_matmul.matrix_B_0_0.ram[17] = 8'h01;
force u_matmul.matrix_B_0_0.ram[18] = 8'h01;
force u_matmul.matrix_B_0_0.ram[19] = 8'h01;
force u_matmul.matrix_B_0_0.ram[20] = 8'h01;
force u_matmul.matrix_B_0_0.ram[21] = 8'h01;
force u_matmul.matrix_B_0_0.ram[22] = 8'h01;
force u_matmul.matrix_B_0_0.ram[23] = 8'h01;
force u_matmul.matrix_B_0_0.ram[24] = 8'h01;
force u_matmul.matrix_B_0_0.ram[25] = 8'h01;
force u_matmul.matrix_B_0_0.ram[26] = 8'h01;
force u_matmul.matrix_B_0_0.ram[27] = 8'h01;
force u_matmul.matrix_B_0_0.ram[28] = 8'h01;
force u_matmul.matrix_B_0_0.ram[29] = 8'h01;
force u_matmul.matrix_B_0_0.ram[30] = 8'h01;
force u_matmul.matrix_B_0_0.ram[31] = 8'h01;

force u_matmul.matrix_B_0_1.ram[ 0] = 8'h02;
force u_matmul.matrix_B_0_1.ram[ 1] = 8'h02;
force u_matmul.matrix_B_0_1.ram[ 2] = 8'h02;
force u_matmul.matrix_B_0_1.ram[ 3] = 8'h02;
force u_matmul.matrix_B_0_1.ram[ 4] = 8'h02;
force u_matmul.matrix_B_0_1.ram[ 5] = 8'h02;
force u_matmul.matrix_B_0_1.ram[ 6] = 8'h02;
force u_matmul.matrix_B_0_1.ram[ 7] = 8'h02;
force u_matmul.matrix_B_0_1.ram[ 8] = 8'h02;
force u_matmul.matrix_B_0_1.ram[ 9] = 8'h02;
force u_matmul.matrix_B_0_1.ram[10] = 8'h02;
force u_matmul.matrix_B_0_1.ram[11] = 8'h02;
force u_matmul.matrix_B_0_1.ram[12] = 8'h02;
force u_matmul.matrix_B_0_1.ram[13] = 8'h02;
force u_matmul.matrix_B_0_1.ram[14] = 8'h02;
force u_matmul.matrix_B_0_1.ram[15] = 8'h02;
force u_matmul.matrix_B_0_1.ram[16] = 8'h02;
force u_matmul.matrix_B_0_1.ram[17] = 8'h02;
force u_matmul.matrix_B_0_1.ram[18] = 8'h02;
force u_matmul.matrix_B_0_1.ram[19] = 8'h02;
force u_matmul.matrix_B_0_1.ram[20] = 8'h02;
force u_matmul.matrix_B_0_1.ram[21] = 8'h02;
force u_matmul.matrix_B_0_1.ram[22] = 8'h02;
force u_matmul.matrix_B_0_1.ram[23] = 8'h02;
force u_matmul.matrix_B_0_1.ram[24] = 8'h02;
force u_matmul.matrix_B_0_1.ram[25] = 8'h02;
force u_matmul.matrix_B_0_1.ram[26] = 8'h02;
force u_matmul.matrix_B_0_1.ram[27] = 8'h02;
force u_matmul.matrix_B_0_1.ram[28] = 8'h02;
force u_matmul.matrix_B_0_1.ram[29] = 8'h02;
force u_matmul.matrix_B_0_1.ram[30] = 8'h02;
force u_matmul.matrix_B_0_1.ram[31] = 8'h02;

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
