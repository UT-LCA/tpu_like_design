
`timescale 1ns/1ns
module matmul_tb;

reg clk;
reg resetn;
reg start;
reg clear_done;

matrix_multiplication u_matul(
  .clk(clk), 
  .clk_mem(clk),
  .resetn(resetn), 
  .start_reg(start),
  .clear_done_reg(clear_done));

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
  start = 0;
  #115 start = 1;
  @(posedge u_matul.done_mat_mul);
  start = 0;
  clear_done = 1;
  #200;
  #115 start = 1;
  @(posedge u_matul.done_mat_mul);
  start = 0;
  clear_done = 1;
  #200;
  $finish;
end


initial begin
  //A is stored in row major format
force u_matul.matrix_A.ram[0] = 8'h01;
force u_matul.matrix_A.ram[1] = 8'h01;
force u_matul.matrix_A.ram[2] = 8'h01;
force u_matul.matrix_A.ram[3] = 8'h01;
force u_matul.matrix_A.ram[4] = 8'h01;
force u_matul.matrix_A.ram[5] = 8'h01;
force u_matul.matrix_A.ram[6] = 8'h01;
force u_matul.matrix_A.ram[7] = 8'h01;
force u_matul.matrix_A.ram[8] = 8'h00;
force u_matul.matrix_A.ram[9] = 8'h01;
force u_matul.matrix_A.ram[10] = 8'h01;
force u_matul.matrix_A.ram[11] = 8'h01;
force u_matul.matrix_A.ram[12] = 8'h01;
force u_matul.matrix_A.ram[13] = 8'h01;
force u_matul.matrix_A.ram[14] = 8'h01;
force u_matul.matrix_A.ram[15] = 8'h01;
force u_matul.matrix_A.ram[16] = 8'h01;
force u_matul.matrix_A.ram[17] = 8'h01;
force u_matul.matrix_A.ram[18] = 8'h01;
force u_matul.matrix_A.ram[19] = 8'h01;
force u_matul.matrix_A.ram[20] = 8'h01;
force u_matul.matrix_A.ram[21] = 8'h01;
force u_matul.matrix_A.ram[22] = 8'h01;
force u_matul.matrix_A.ram[23] = 8'h01;
force u_matul.matrix_A.ram[24] = 8'h01;
force u_matul.matrix_A.ram[25] = 8'h01;
force u_matul.matrix_A.ram[26] = 8'h01;
force u_matul.matrix_A.ram[27] = 8'h01;
force u_matul.matrix_A.ram[28] = 8'h01;
force u_matul.matrix_A.ram[29] = 8'h01;
force u_matul.matrix_A.ram[30] = 8'h01;
force u_matul.matrix_A.ram[31] = 8'h01;
force u_matul.matrix_A.ram[32] = 8'h01;
force u_matul.matrix_A.ram[33] = 8'h01;
force u_matul.matrix_A.ram[34] = 8'h01;
force u_matul.matrix_A.ram[35] = 8'h01;
force u_matul.matrix_A.ram[36] = 8'h01;
force u_matul.matrix_A.ram[37] = 8'h01;
force u_matul.matrix_A.ram[38] = 8'h01;
force u_matul.matrix_A.ram[39] = 8'h01;
force u_matul.matrix_A.ram[40] = 8'h01;
force u_matul.matrix_A.ram[41] = 8'h01;
force u_matul.matrix_A.ram[42] = 8'h01;
force u_matul.matrix_A.ram[43] = 8'h01;
force u_matul.matrix_A.ram[44] = 8'h01;
force u_matul.matrix_A.ram[45] = 8'h01;
force u_matul.matrix_A.ram[46] = 8'h01;
force u_matul.matrix_A.ram[47] = 8'h01;
force u_matul.matrix_A.ram[48] = 8'h01;
force u_matul.matrix_A.ram[49] = 8'h01;
force u_matul.matrix_A.ram[50] = 8'h01;
force u_matul.matrix_A.ram[51] = 8'h01;
force u_matul.matrix_A.ram[52] = 8'h01;
force u_matul.matrix_A.ram[53] = 8'h01;
force u_matul.matrix_A.ram[54] = 8'h01;
force u_matul.matrix_A.ram[55] = 8'h01;
force u_matul.matrix_A.ram[56] = 8'h01;
force u_matul.matrix_A.ram[57] = 8'h01;
force u_matul.matrix_A.ram[58] = 8'h01;
force u_matul.matrix_A.ram[59] = 8'h01;
force u_matul.matrix_A.ram[60] = 8'h01;
force u_matul.matrix_A.ram[61] = 8'h01;
force u_matul.matrix_A.ram[62] = 8'h01;
force u_matul.matrix_A.ram[63] = 8'h01;
force u_matul.matrix_A.ram[`MEM_SIZE-1-7] = 8'h0;
force u_matul.matrix_A.ram[`MEM_SIZE-1-6] = 8'h0;
force u_matul.matrix_A.ram[`MEM_SIZE-1-5] = 8'h0;
force u_matul.matrix_A.ram[`MEM_SIZE-1-4] = 8'h0;
force u_matul.matrix_A.ram[`MEM_SIZE-1-3] = 8'h0;
force u_matul.matrix_A.ram[`MEM_SIZE-1-2] = 8'h0;
force u_matul.matrix_A.ram[`MEM_SIZE-1-1] = 8'h0;
force u_matul.matrix_A.ram[`MEM_SIZE-1-0] = 8'h0;


force u_matul.matrix_B.ram[0] = 8'h00;
force u_matul.matrix_B.ram[1] = 8'h01;
force u_matul.matrix_B.ram[2] = 8'h01;
force u_matul.matrix_B.ram[3] = 8'h01;
force u_matul.matrix_B.ram[4] = 8'h01;
force u_matul.matrix_B.ram[5] = 8'h01;
force u_matul.matrix_B.ram[6] = 8'h01;
force u_matul.matrix_B.ram[7] = 8'h01;
force u_matul.matrix_B.ram[8] = 8'h01;
force u_matul.matrix_B.ram[9] = 8'h01;
force u_matul.matrix_B.ram[10] = 8'h01;
force u_matul.matrix_B.ram[11] = 8'h01;
force u_matul.matrix_B.ram[12] = 8'h01;
force u_matul.matrix_B.ram[13] = 8'h01;
force u_matul.matrix_B.ram[14] = 8'h01;
force u_matul.matrix_B.ram[15] = 8'h01;
force u_matul.matrix_B.ram[16] = 8'h01;
force u_matul.matrix_B.ram[17] = 8'h01;
force u_matul.matrix_B.ram[18] = 8'h01;
force u_matul.matrix_B.ram[19] = 8'h01;
force u_matul.matrix_B.ram[20] = 8'h01;
force u_matul.matrix_B.ram[21] = 8'h01;
force u_matul.matrix_B.ram[22] = 8'h01;
force u_matul.matrix_B.ram[23] = 8'h01;
force u_matul.matrix_B.ram[24] = 8'h01;
force u_matul.matrix_B.ram[25] = 8'h01;
force u_matul.matrix_B.ram[26] = 8'h01;
force u_matul.matrix_B.ram[27] = 8'h01;
force u_matul.matrix_B.ram[28] = 8'h01;
force u_matul.matrix_B.ram[29] = 8'h01;
force u_matul.matrix_B.ram[30] = 8'h01;
force u_matul.matrix_B.ram[31] = 8'h01;
force u_matul.matrix_B.ram[32] = 8'h01;
force u_matul.matrix_B.ram[33] = 8'h01;
force u_matul.matrix_B.ram[34] = 8'h01;
force u_matul.matrix_B.ram[35] = 8'h01;
force u_matul.matrix_B.ram[36] = 8'h01;
force u_matul.matrix_B.ram[37] = 8'h01;
force u_matul.matrix_B.ram[38] = 8'h01;
force u_matul.matrix_B.ram[39] = 8'h01;
force u_matul.matrix_B.ram[40] = 8'h01;
force u_matul.matrix_B.ram[41] = 8'h01;
force u_matul.matrix_B.ram[42] = 8'h01;
force u_matul.matrix_B.ram[43] = 8'h01;
force u_matul.matrix_B.ram[44] = 8'h01;
force u_matul.matrix_B.ram[45] = 8'h01;
force u_matul.matrix_B.ram[46] = 8'h01;
force u_matul.matrix_B.ram[47] = 8'h01;
force u_matul.matrix_B.ram[48] = 8'h01;
force u_matul.matrix_B.ram[49] = 8'h01;
force u_matul.matrix_B.ram[50] = 8'h01;
force u_matul.matrix_B.ram[51] = 8'h01;
force u_matul.matrix_B.ram[52] = 8'h01;
force u_matul.matrix_B.ram[53] = 8'h01;
force u_matul.matrix_B.ram[54] = 8'h01;
force u_matul.matrix_B.ram[55] = 8'h01;
force u_matul.matrix_B.ram[56] = 8'h01;
force u_matul.matrix_B.ram[57] = 8'h01;
force u_matul.matrix_B.ram[58] = 8'h01;
force u_matul.matrix_B.ram[59] = 8'h01;
force u_matul.matrix_B.ram[60] = 8'h01;
force u_matul.matrix_B.ram[61] = 8'h01;
force u_matul.matrix_B.ram[62] = 8'h01;
force u_matul.matrix_B.ram[63] = 8'h01;
force u_matul.matrix_B.ram[`MEM_SIZE-1-7] = 8'h0;
force u_matul.matrix_B.ram[`MEM_SIZE-1-6] = 8'h0;
force u_matul.matrix_B.ram[`MEM_SIZE-1-5] = 8'h0;
force u_matul.matrix_B.ram[`MEM_SIZE-1-4] = 8'h0;
force u_matul.matrix_B.ram[`MEM_SIZE-1-3] = 8'h0;
force u_matul.matrix_B.ram[`MEM_SIZE-1-2] = 8'h0;
force u_matul.matrix_B.ram[`MEM_SIZE-1-1] = 8'h0;
force u_matul.matrix_B.ram[`MEM_SIZE-1-0] = 8'h0;

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
