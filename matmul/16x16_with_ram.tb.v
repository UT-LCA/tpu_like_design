
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
  .address_mat_a(11'b0),
  .address_mat_b(11'b0),
  .address_mat_c(11'b0),
  .address_stride_a(8'd16),
  .address_stride_b(8'd16),
  .address_stride_c(8'd16),
  .save_output_to_accum(1'b0),
  .add_accum_to_output(1'b0),
  .validity_mask_a_rows(16'hffff),
  .validity_mask_a_cols_b_rows(16'hffff),
  .validity_mask_b_cols(16'hffff),
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

initial begin

for (int i=0; i<16; i++) begin
  for (int j=0; j<16; j++) begin
    u_matmul.matrix_A.ram[16*i + j] = a[i][j];
  end
end

for (int j=0; j<16; j++) begin
  for (int i=0; i<16; i++) begin
    u_matmul.matrix_B.ram[16*j + i] = b[i][j];
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
