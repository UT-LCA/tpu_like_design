`timescale 1ns/1ns
module matmul_tb;

reg clk;
reg reset;
reg we1;
reg we2;
reg enable_writing_to_mem;
reg enable_reading_from_mem;
reg [15:0] data_pi;
reg [4:0] addr_pi;
wire done_mat_mul;
reg [8:0] out_sel;
reg start;


matrix_multiplication u_matul(
  .clk(clk), 
  .clk_mem(clk),
  .reset(reset), 
  .enable_writing_to_mem(enable_writing_to_mem), 
  .enable_reading_from_mem(enable_reading_from_mem), 
  .data_pi(), 
  .addr_pi(), 
  .we_a(),
  .we_b(),
  .we_c(),
  .data_from_out_mat(),
  .start_mat_mul(start),
  .done_mat_mul(done_mat_mul));

initial begin
  clk = 0;
  forever begin
    #10 clk = ~clk;
  end
end

initial begin
  reset = 1;
  #55 reset = 0;
end

initial begin
  start = 0;
  enable_writing_to_mem = 0;
  enable_reading_from_mem = 0;
  #115 start = 1;
  #1000;
  $finish;
end

//  A           B        Output       Output in hex
// 8 4 6 8   1 1 3 0   98 90 82 34    62 5A 52 22
// 3 3 3 7   0 1 4 3   75 63 51 26    4B 3F 33 1A
// 5 2 1 6   3 5 3 1   62 48 44 19    3E 30 2C 13
// 9 1 0 5   9 6 3 2   54 40 46 13    36 28 2E 0D

initial begin
  //A is stored in row major format
  force u_matul.matrix_A.ram[3:0] = '{32'h0506_0708, 32'h0001_0306, 32'h0102_0304, 32'h0905_0308};
  //Last element is 0 (i think the logic requires this)
  force u_matul.matrix_A.ram[127] = 32'h0;
  //B is stored in col major format
  force u_matul.matrix_B.ram[3:0] = '{32'h0203_0609, 32'h0103_0503, 32'h0304_0100, 32'h0003_0101};
  //Last element is 0 (i think the logic requires this)
  force u_matul.matrix_B.ram[127] = 32'h0;
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
