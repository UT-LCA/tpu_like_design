`timescale 1ns/1ns
module matmul_tb;

reg clk;
reg resetn;
reg pe_resetn;
reg start;
reg clear_done;

matrix_multiplication u_matmul(
  .clk(clk), 
  .clk_mem(clk),
  .resetn(resetn), 
  .pe_resetn(pe_resetn), 
  .address_mat_a(11'b0),
  .address_mat_b(11'b0),
  .address_mat_c(11'b0),
  .address_stride_a(8'd4),
  .address_stride_b(8'd4),
  .address_stride_c(8'd4),
  .validity_mask_a_rows(4'b1111),
  .validity_mask_a_cols_b_rows(4'b1111),
  .validity_mask_b_cols(4'b1111),
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
  pe_resetn = 0;
  #55;
  resetn = 1;
  pe_resetn = 1;
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
  for (int i=0; i<4; i++) begin
    for (int j=0; j<4; j++) begin
      u_matmul.matrix_A.ram[4*i + j] = 1'b1;
      u_matmul.matrix_B.ram[4*i + j] = 1'b1;
    end
  end
end

/*
//  A           B        Output       Output in hex
// 8 4 6 8   1 1 3 0   98 90 82 34    62 5A 52 22
// 3 3 3 7   0 1 4 3   75 63 51 26    4B 3F 33 1A
// 5 2 1 6   3 5 3 1   62 48 44 19    3E 30 2C 13
// 9 1 0 5   9 6 3 2   54 40 46 13    36 28 2E 0D

initial begin
  //A is stored in row major format
  force u_matmul.matrix_A.ram[0]  = 8'h08;
  force u_matmul.matrix_A.ram[1]  = 8'h03;
  force u_matmul.matrix_A.ram[2]  = 8'h05;
  force u_matmul.matrix_A.ram[3]  = 8'h09;
  force u_matmul.matrix_A.ram[4]  = 8'h04;
  force u_matmul.matrix_A.ram[5]  = 8'h03;
  force u_matmul.matrix_A.ram[6]  = 8'h02;
  force u_matmul.matrix_A.ram[7]  = 8'h01;
  force u_matmul.matrix_A.ram[8]  = 8'h06;
  force u_matmul.matrix_A.ram[9]  = 8'h03;
  force u_matmul.matrix_A.ram[10] = 8'h01;
  force u_matmul.matrix_A.ram[11] = 8'h00;
  force u_matmul.matrix_A.ram[12] = 8'h08;
  force u_matmul.matrix_A.ram[13] = 8'h07;
  force u_matmul.matrix_A.ram[14] = 8'h06;
  force u_matmul.matrix_A.ram[15] = 8'h05;
  //force u_matmul.matrix_A.ram[3:0] = '{32'h0506_0708, 32'h0001_0306, 32'h0102_0304, 32'h0905_0308};
  //bram_a.write(0, int('0x09050308',16))
  //bram_a.write(4, int('0x01020304',16))
  //bram_a.write(8, int('0x00010306',16))
  //bram_a.write(12, int('0x05060708',16))
  //bram_a.write(32764,int('0x00000000',16))
  
  
  //Last element is 0 (i think the logic requires this)
  force u_matmul.matrix_A.ram[`MEM_SIZE-1-3] = 8'h0;
  force u_matmul.matrix_A.ram[`MEM_SIZE-1-2] = 8'h0;
  force u_matmul.matrix_A.ram[`MEM_SIZE-1-1] = 8'h0;
  force u_matmul.matrix_A.ram[`MEM_SIZE-1-0] = 8'h0;
  //force u_matmul.matrix_A.ram[127] = 32'h0;

  //B is stored in col major format
  force u_matmul.matrix_B.ram[0]  = 8'h01;
  force u_matmul.matrix_B.ram[1]  = 8'h01;
  force u_matmul.matrix_B.ram[2]  = 8'h03;
  force u_matmul.matrix_B.ram[3]  = 8'h00;
  force u_matmul.matrix_B.ram[4]  = 8'h00;
  force u_matmul.matrix_B.ram[5]  = 8'h01;
  force u_matmul.matrix_B.ram[6]  = 8'h04;
  force u_matmul.matrix_B.ram[7]  = 8'h03;
  force u_matmul.matrix_B.ram[8]  = 8'h03;
  force u_matmul.matrix_B.ram[9]  = 8'h05;
  force u_matmul.matrix_B.ram[10] = 8'h03;
  force u_matmul.matrix_B.ram[11] = 8'h01;
  force u_matmul.matrix_B.ram[12] = 8'h09;
  force u_matmul.matrix_B.ram[13] = 8'h06;
  force u_matmul.matrix_B.ram[14] = 8'h03;
  force u_matmul.matrix_B.ram[15] = 8'h02;
  //force u_matmul.matrix_B.ram[3:0] = '{32'h0203_0609, 32'h0103_0503, 32'h0304_0100, 32'h0003_0101};

  //Last element is 0 (i think the logic requires this)
  force u_matmul.matrix_B.ram[`MEM_SIZE-1-3] = 8'h0;
  force u_matmul.matrix_B.ram[`MEM_SIZE-1-2] = 8'h0;
  force u_matmul.matrix_B.ram[`MEM_SIZE-1-1] = 8'h0;
  force u_matmul.matrix_B.ram[`MEM_SIZE-1-0] = 8'h0;
  //force u_matmul.matrix_B.ram[127] = 32'h0;
  //bram_b.write(0, int('0x00030101',16))
  //bram_b.write(4, int('0x03040100',16))
  //bram_b.write(8, int('0x01030503',16))
  //bram_b.write(12, int('0x02030609',16))
  //bram_b.write(32764,int('0x00000000',16))
end
*/
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
