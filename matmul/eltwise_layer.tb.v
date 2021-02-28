
`timescale 1ns/1ns
module layer_tb;

reg clk;
reg resetn;
reg start;
reg clear_done;

eltwise_layer u_layer(
  .clk(clk), 
  .clk_mem(clk),
  .resetn(resetn), 
  .op(2'b00),
  .pe_resetn(resetn));

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
  force u_layer.start_reg = start;
  force u_layer.clear_done_reg = clear_done;
  force u_layer.iterations = 10;
end

initial begin
  start = 0;
  #115 start = 1;
  @(posedge u_layer.done_eltwise_op);
  start = 0;
  clear_done = 1;
  #200;
  #115 start = 1;
  @(posedge u_layer.done_eltwise_op);
  start = 0;
  clear_done = 1;
  #200;
  $finish;
end

//One column in this is really interpreted as 1 row in matrix A
//In the following, by changing the first column, I'm effectively changing the first row of matrix A.
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

//One column in this is really interpreted as 1 column in matrix B. Transposed.
//In the following, by changing the first row, I'm effectively changing the last column of matrix B.
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
    u_layer.matrix_A_0.ram[16*i + j] = a[i][j];
  end
end

for (int j=0; j<16; j++) begin
  for (int i=0; i<16; i++) begin
    u_layer.matrix_B_0.ram[16*j + i] = b[i][j];
  end
end

for (int i=0; i<16; i++) begin
  for (int j=0; j<16; j++) begin
    u_layer.matrix_A_1.ram[16*i + j] = a[i][j];
  end
end

for (int j=0; j<16; j++) begin
  for (int i=0; i<16; i++) begin
    u_layer.matrix_B_1.ram[16*j + i] = b[i][j];
  end
end

end

initial begin
  $vcdpluson;
  $vcdplusmemon;
end

endmodule

