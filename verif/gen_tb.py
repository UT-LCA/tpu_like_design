import sys
import math
from datetime import datetime

if len(sys.argv) < 2:
	print("Expected format : ./create_mat_mul.py <size of square systolic array - should be a power of 2>")
	exit(-1)

systolic_size = sys.argv[1]

f = open(sys.argv[1] + "x" + sys.argv[1] + "_with_ram_tb_gen.v","w")

f.write("""
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
""")

for i in range(int(sys.argv[1])*int(sys.argv[1])):
	f.write("force u_matul.matrix_A.ram[" + str(i) + "] = 8'h01;\n" )

  
#//Last element is 0 (i think the logic requires this)
  
for i in range(int(sys.argv[1])-1,-1,-1):
	f.write("force u_matul.matrix_A.ram[`MEM_SIZE-1-" + str(i) + "] = 8'h0;\n")

f.write("\n\n")

for i in range(int(sys.argv[1])*int(sys.argv[1])):
	f.write("force u_matul.matrix_B.ram[" + str(i) + "] = 8'h01;\n" )
  
#//Last element is 0 (i think the logic requires this)
  
for i in range(int(sys.argv[1])-1,-1,-1):
	f.write("force u_matul.matrix_B.ram[`MEM_SIZE-1-" + str(i) + "] = 8'h0;\n")

f.write("""
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

endmodule""")
