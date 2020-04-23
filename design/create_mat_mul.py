import sys
import math
from datetime import datetime

if len(sys.argv) < 2:
	print("Expected format : ./create_mat_mul.py <size of square systolic array - should be a power of 2>")
	exit(-1)

systolic_size = sys.argv[1]

f = open(sys.argv[1] + "x" + sys.argv[1] + "_gen.v","w")

f.write("""
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: """ + str(datetime.now()) +
"""
// Design Name: 
// Module Name: matmul_""" + sys.argv[1] + "x" + sys.argv[1] + 
"""
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define DWIDTH 8
`define AWIDTH 13
`define MEM_SIZE 8192
`define MAT_MUL_SIZE """ + sys.argv[1] +
"""
`define LOG2_MAT_MUL_SIZE """ + str(int(math.log2(int(sys.argv[1])))) + 
"""
`define BB_MAT_MUL_SIZE `MAT_MUL_SIZE
`define NUM_CYCLES_IN_MAC 3

module matmul_4x4(
 clk,
 reset,
 start_mat_mul,
 done_mat_mul,
 a_data,
 b_data,
 a_data_in, //Data values coming in from previous matmul - systolic connections
 b_data_in,
 c_data_in, //Data values coming in from previous matmul - systolic shifting
 c_data_out, //Data values going out to next matmul - systolic shifting
 a_data_out,
 b_data_out,
 a_addr,
 b_addr,
 c_addr,
 c_data_available,
 final_mat_mul_size,
 a_loc,
 b_loc
);

 input clk;
 input reset;
 input start_mat_mul;
 output done_mat_mul;
 input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data;
 input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data;
 input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in;
 input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in;
 input [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in;
 output [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_out;
 output [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out;
 output [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out;
 output [`AWIDTH-1:0] a_addr;
 output [`AWIDTH-1:0] b_addr;
 output [`AWIDTH-1:0] c_addr;
 output c_data_available;
//7:0 is okay here. We aren't going to make a matmul larger than 128x128
//In fact, these will get optimized out by the synthesis tool, because
//we hardcode them at the instantiation level.
 input [7:0] final_mat_mul_size;
 input [7:0] a_loc;
 input [7:0] b_loc;

reg done_mat_mul;
//This is 7 bits because the expectation is that clock count will be pretty
//small. For large matmuls, this will need to increased to have more bits.
//In general, a systolic multiplier takes 4*N-2+P cycles, where N is the size 
//of the matmul and P is the number of pipleine stages in the MAC block.
reg [6:0] clk_cnt;


always @(posedge clk) begin
  if (reset || ~start_mat_mul) begin
    clk_cnt <= 0;
    done_mat_mul <= 0;
  end
  //else if (clk_cnt == 4*final_mat_mul_size-2+4) begin
  //Writing the line above to avoid multiplication:
  else if (clk_cnt == (final_mat_mul_size<<2)+2+1) begin
      done_mat_mul <= 1;
  end
  else if (done_mat_mul == 0) begin
      clk_cnt <= clk_cnt + 1;
      //clk_cnt <= clk_cnt_inc;
  end    
end
 
reg [`AWIDTH-1:0] a_addr;
always @(posedge clk) begin
  if (reset || ~start_mat_mul) begin
    a_addr <= `MEM_SIZE-1-3;//a_loc*16;
  end
  //else if (clk_cnt >= a_loc*`MAT_MUL_SIZE+final_mat_mul_size) begin
  //Writing the line above to avoid multiplication:
  else if (clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size) begin
    a_addr <= `MEM_SIZE-1-3; 
  end
  //else if ((clk_cnt >= a_loc*`MAT_MUL_SIZE) && (clk_cnt < a_loc*`MAT_MUL_SIZE+final_mat_mul_size)) begin
  //Writing the line above to avoid multiplication:
  else if ((clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)) && (clk_cnt < (a_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin
    a_addr <= a_addr + 4;
  end
end  
""")

for i in range(int(sys.argv[1])):
	f.write("wire [`DWIDTH-1:0] a" + str(i) + "_data;\n")

f.write("\n")

for i in range(int(sys.argv[1])):
	f.write("assign a"+ str(i) + "_data = a_data[" + str(i+1) + "*`DWIDTH-1:" + str(i) + "*`DWIDTH];\n")

f.write("\n")	

for i in range(int(sys.argv[1])):
	f.write("wire [`DWIDTH-1:0] a" + str(i) + "_data_in;\n")

f.write("\n")

for i in range(int(sys.argv[1])):
	f.write("assign a"+ str(i) + "_data_in = a_data_in[" + str(i+1) + "*`DWIDTH-1:" + str(i) + "*`DWIDTH];\n")

f.write("\n")

for i in range(int(sys.argv[1])):
	for j in range(1,i+1):
		f.write("reg [`DWIDTH-1:0] a" + str(i) + "_data_delayed_" + str(j) + ";\n")

f.write("\n")

f.write(
"""
always @(posedge clk) begin
  if (reset || ~start_mat_mul || clk_cnt==0) begin
""")

for i in range(int(sys.argv[1])):
	for j in range(1,i+1):
		f.write("		a"+ str(i) +"_data_delayed_" + str(j) + " <= 0;\n")

f.write(
"""
  end
  else begin
""")

for i in range(1,int(sys.argv[1])):
	f.write("	a" + str(i)+ "_data_delayed_1 <= a" +str(i)+ "_data;\n")

for i in range(1,int(sys.argv[1])):
	for j in range(2,i+1):
		f.write("	a"+ str(i) +"_data_delayed_" + str(j) + " <= a"+ str(i) +"_data_delayed_"+ str(j-1) + ";\n")

f.write(
""" 
  end
end

reg [`AWIDTH-1:0] b_addr;
always @(posedge clk) begin
  if (reset || ~start_mat_mul) begin
    b_addr <= `MEM_SIZE-1-3;//b_loc*16;
  end
  //else if (clk_cnt >= b_loc*`MAT_MUL_SIZE+final_mat_mul_size) begin
  //Writing the line above to avoid multiplication:
  else if (clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size) begin
    b_addr <= `MEM_SIZE-1-3;
  end
  //else if ((clk_cnt >= b_loc*`MAT_MUL_SIZE) && (clk_cnt < b_loc*`MAT_MUL_SIZE+final_mat_mul_size)) begin
  //Writing the line above to avoid multiplication:
  else if ((clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)) && (clk_cnt < (b_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin
    b_addr <= b_addr + 4;
  end
end

""")

for i in range(int(sys.argv[1])):
	f.write("wire [`DWIDTH-1:0] b" + str(i) + "_data;\n")

f.write("\n")

for i in range(int(sys.argv[1])):
	f.write("assign b"+ str(i) + "_data = b_data[" + str(i+1) + "*`DWIDTH-1:" + str(i) + "*`DWIDTH];\n")

f.write("\n")	

for i in range(int(sys.argv[1])):
	f.write("wire [`DWIDTH-1:0] b" + str(i) + "_data_in;\n")

f.write("\n")

for i in range(int(sys.argv[1])):
	f.write("assign b"+ str(i) + "_data_in = b_data_in[" + str(i+1) + "*`DWIDTH-1:" + str(i) + "*`DWIDTH];\n")

f.write("\n")

for i in range(int(sys.argv[1])):
	for j in range(1,i+1):
		f.write("reg [`DWIDTH-1:0] b" + str(i) + "_data_delayed_" + str(j) + ";\n")

f.write("\n")

f.write(
"""
always @(posedge clk) begin
  if (reset || ~start_mat_mul || clk_cnt==0) begin
""")

for i in range(int(sys.argv[1])):
	for j in range(1,i+1):
		f.write("		b"+ str(i) +"_data_delayed_" + str(j) + " <= 0;\n")

f.write(
"""
  end
  else begin
""")

for i in range(1,int(sys.argv[1])):
	f.write("	b" + str(i)+ "_data_delayed_1 <= b" +str(i)+ "_data;\n")

for i in range(1,int(sys.argv[1])):
	for j in range(2,i+1):
		f.write("	b"+ str(i) +"_data_delayed_" + str(j) + " <= b"+ str(i) +"_data_delayed_"+ str(j-1) + ";\n")

f.write(
""" 
  end
end
""")

for i in range(int(sys.argv[1])):
	f.write("wire [`DWIDTH-1:0] a" + str(i) + ";\n")

for i in range(int(sys.argv[1])):
	f.write("wire [`DWIDTH-1:0] b" + str(i) + ";\n")

f.write("\n")

"""
//If b_loc is 0, that means this matmul block is on the top-row of the
//final large matmul. In that case, b will take inputs from mem.
//If b_loc != 0, that means this matmul block is not on the top-row of the
//final large matmul. In that case, b will take inputs from the matmul on top
//of this one.
"""
f.write("assign a0 = (b_loc==0) ? a0_data           : a0_data_in;\n")

for i in range(1,int(sys.argv[1])):
	f.write("assign a" + str(i) + " = (b_loc==0) ? a" + str(i) + "_data_delayed_"+ str(i) + " : a"+ str(i) + "_data_in;\n")

"""
//If a_loc is 0, that means this matmul block is on the left-col of the
//final large matmul. In that case, a will take inputs from mem.
//If a_loc != 0, that means this matmul block is not on the left-col of the
//final large matmul. In that case, a will take inputs from the matmul on left
//of this one.
"""
f.write("\n")

f.write("assign b0 = (a_loc==0) ? b0_data           : b0_data_in;\n")

for i in range(1,int(sys.argv[1])):
	f.write("assign b" + str(i) + " = (a_loc==0) ? b" + str(i) + "_data_delayed_"+ str(i) + " : b"+ str(i) + "_data_in;\n")

f.write("\n")
for i in range(int(sys.argv[1])):
	f.write("wire [`DWIDTH-1:0] ")

	for j in range(int(sys.argv[1])):
		f.write("a" + str(i) + str(j) + "to" + str(i) + str(j+1))

		if (j != int(sys.argv[1])-1):
			f.write(", ")
		else:
			f.write(";\n")

f.write("\n")
for i in range(int(sys.argv[1])):
	f.write("wire [`DWIDTH-1:0] ")

	for j in range(int(sys.argv[1])):
		f.write("b" + str(j) + str(i)  + "to" + str(j+1) + str(i))

		if (j != int(sys.argv[1])-1):
			f.write(", ")
		else:
			f.write(";\n")

for i in range(int(sys.argv[1])):
	f.write("wire [`DWIDTH-1:0] cin_row" + str(i) + ";\n")

f.write("wire row_latch_en;\n\n")

for i in range(int(sys.argv[1])):
	for j in range(int(sys.argv[1])):
		f.write("wire [`DWIDTH-1:0] matrixC" + str(i) + str(j) + ";\n")

for i in range(int(sys.argv[1])):
	f.write("assign cin_row" + str(i) + " = " + "c_data_in" + "[" + str(i+1) + "*`DWIDTH-1:" + str(i) + "*`DWIDTH];\n")

f.write(
"""
//assign row_latch_en = (clk_cnt==(`MAT_MUL_SIZE + (a_loc+b_loc) * `BB_MAT_MUL_SIZE + 10 +  `NUM_CYCLES_IN_MAC - 1));
//Writing the line above to avoid multiplication:
assign row_latch_en = (clk_cnt==(`MAT_MUL_SIZE + ((a_loc+b_loc) << `LOG2_MAT_MUL_SIZE) + 10 +  `NUM_CYCLES_IN_MAC - 1));

reg c_data_available;
reg [`AWIDTH-1:0] c_addr;
reg start_capturing_c_data;
integer counter;
reg [""" + sys.argv[1] + """*`DWIDTH-1:0] c_data_out;
"""
)

f.write(
"""
//For larger matmuls, this logic will have more entries in the case statement
always @(posedge clk) begin
  if (reset | ~start_mat_mul) begin
    start_capturing_c_data <= 1'b0;
    c_data_available <= 1'b0;
    c_addr <= `MEM_SIZE-1-3;
    c_data_out <= 0;
    counter <= 0;
  end else if (row_latch_en) begin
    start_capturing_c_data <= 1'b1;
    c_data_available <= 1'b1;
    c_addr <= c_addr + """ + sys.argv[1] + """;
    c_data_out <= {""")

for i in range(int(sys.argv[1])-1,-1,-1):
    f.write("matrixC0" + str(i))

    if i == 0:
    	f.write("};\n")
    else:
    	f.write(", ")


f.write(
"""
    counter <= counter + 1;
  end else if (done_mat_mul) begin
    start_capturing_c_data <= 1'b0;
    c_data_available <= 1'b0;
    c_addr <= `MEM_SIZE-1-3;
    c_data_out <= 0;
  end 
  else if (start_capturing_c_data) begin
    c_data_available <= 1'b1;
    c_addr <= c_addr + """ + sys.argv[1] + """; 
    counter <= counter + 1;
    case (counter)  //rest of the elements are captured here
    """)

for i in range(1,int(sys.argv[1])):
	f.write("		"+str(i) + ": c_data_out <= {")
	for j in range(int(sys.argv[1])-1,-1,-1):
		f.write("matrixC" + str(i) + str(j))

		if j == 0:
			f.write("};\n")
		else:
			f.write(", ")

f.write("""
        default: c_data_out <= 0;
    endcase
  end
end""")

f.write("""
//For larger matmul, more PEs will be needed
wire effective_rst;
assign effective_rst = reset | ~start_mat_mul;

processing_element pe00(.reset(effective_rst), .clk(clk),  .in_a(a0),      .in_b(b0),  .out_a(a00to01), .out_b(b00to10), .out_c(matrixC00));
""")

for i in range(int(sys.argv[1])-1):
	f.write("processing_element pe0" + str(i+1) + 
		"(.reset(effective_rst), .clk(clk),  .in_a(a0" + str(i) + "to0" + str(i+1) +
		"), .in_b(b" + str(i+1) + "),  .out_a(a0" +  str(i+1) + "to0" + str(i+2) + "), .out_b(b0"+
		 str(i+1) + "to1" + str(i+1) + "), .out_c(matrixC0" + str(i+1) + "));\n")

f.write("\n")

# for i in range(int(sys.argv[1])-1):
# 	f.write("processing_element pe" + str(i+1) + "0" + 
# 	"(.reset(effective_rst), .clk(clk),  .in_a(a" + str(i+1) +
# 	"), .in_b(b" + str(i) + "0to" + str(i+1) + "0),  .out_a(a" +  str(i+1) + "0to" + str(i+1) + "1), .out_b(b"+
# 	 str(i+1) + "0to" + str(i+1) + "0), .out_c(matrixC" + str(i+1) + "0));\n")

for i in range(int(sys.argv[1])-1):
	f.write("processing_element pe" + str(i+1) + 
	"0(.reset(effective_rst), .clk(clk),  .in_a(a" + str(i+1) +
	"), .in_b(b" + str(i) + "0to" + str(i+1) + "0),  .out_a(a" +  str(i+1) + "0to" + str(i+1) + "1), .out_b(b"+
	 str(i+1) + "0to" + str(i+2) + "0), .out_c(matrixC" + str(i+1) + "0));\n")

f.write("\n")

for i in range(int(sys.argv[1])-1):
	for j in range(int(sys.argv[1])-1):
		f.write("processing_element pe" + str(i+1) + str(j+1) +
		"(.reset(effective_rst), .clk(clk),  .in_a(a" + str(i+1) + str(j) + "to" + str(i+1) + str(j+1) +
		"), .in_b(b" + str(i) + str(j+1) + "to" + str(i+1) + str(j+1) +"),  .out_a(a" +  str(i+1) + str(j+1) + 
		"to" + str(i+1) + str(j+2) +"), .out_b(b"+str(i+1) + str(j+1) + "to" + str(i+2) + str(j+1) + "), .out_c(matrixC" + str(i+1) + str(j+1) + "));\n")

"""

processing_element pe10(.reset(effective_rst), .clk(clk),  .in_a(a1),      .in_b(b00to10), .out_a(a10to11), .out_b(b10to20), .out_c(matrixC10));
processing_element pe11(.reset(effective_rst), .clk(clk),  .in_a(a10to11), .in_b(b01to11), .out_a(a11to12), .out_b(b11to21), .out_c(matrixC11));
processing_element pe12(.reset(effective_rst), .clk(clk),  .in_a(a11to12), .in_b(b02to12), .out_a(a12to13), .out_b(b12to22), .out_c(matrixC12));
processing_element pe13(.reset(effective_rst), .clk(clk),  .in_a(a12to13), .in_b(b03to13), .out_a(a13to14), .out_b(b13to23), .out_c(matrixC13));

processing_element pe20(.reset(effective_rst), .clk(clk),  .in_a(a2),      .in_b(b10to20), .out_a(a20to21), .out_b(b20to30), .out_c(matrixC20));
processing_element pe21(.reset(effective_rst), .clk(clk),  .in_a(a20to21), .in_b(b11to21), .out_a(a21to22), .out_b(b21to31), .out_c(matrixC21));
processing_element pe22(.reset(effective_rst), .clk(clk),  .in_a(a21to22), .in_b(b12to22), .out_a(a22to23), .out_b(b22to32), .out_c(matrixC22));
processing_element pe23(.reset(effective_rst), .clk(clk),  .in_a(a22to23), .in_b(b13to23), .out_a(a23to24), .out_b(b23to33), .out_c(matrixC23));

processing_element pe30(.reset(effective_rst), .clk(clk),  .in_a(a3),      .in_b(b20to30), .out_a(a30to31), .out_b(b30to40), .out_c(matrixC30));
processing_element pe31(.reset(effective_rst), .clk(clk),  .in_a(a30to31), .in_b(b21to31), .out_a(a31to32), .out_b(b31to41), .out_c(matrixC31));
processing_element pe32(.reset(effective_rst), .clk(clk),  .in_a(a31to32), .in_b(b22to32), .out_a(a32to33), .out_b(b32to42), .out_c(matrixC32));
processing_element pe33(.reset(effective_rst), .clk(clk),  .in_a(a32to33), .in_b(b23to33), .out_a(a33to34), .out_b(b33to43), .out_c(matrixC33));


"""

f.write("""

assign a_data_out = {a33to34,a23to24,a13to14,a03to04};
assign b_data_out = {b33to43,b32to42,b31to41,b30to40};
endmodule

module processing_element(
 reset, 
 clk, 
 in_a,
 in_b, 
 out_a, 
 out_b, 
 out_c
 );

 input reset;
 input clk;
 input  [`DWIDTH-1:0] in_a;
 input  [`DWIDTH-1:0] in_b;
 output [`DWIDTH-1:0] out_a;
 output [`DWIDTH-1:0] out_b;
 output [`DWIDTH-1:0] out_c;  //reduced precision

 reg [`DWIDTH-1:0] out_a;
 reg [`DWIDTH-1:0] out_b;
 wire [`DWIDTH-1:0] out_c;

 wire [`DWIDTH-1:0] out_mac;

 assign out_c = out_mac;

 seq_mac u_mac(.a(in_a), .b(in_b), .out(out_mac), .reset(reset), .clk(clk));

 always @(posedge clk)begin
    if(reset) begin
      out_a<=0;
      out_b<=0;
    end
    else begin  
      out_a<=in_a;
      out_b<=in_b;
    end
 end
 
endmodule

module seq_mac(a, b, out, reset, clk);
input [`DWIDTH-1:0] a;
input [`DWIDTH-1:0] b;
input reset;
input clk;
output [`DWIDTH-1:0] out;

reg [`DWIDTH-1:0] out;
wire [`DWIDTH-1:0] mul_out;
wire [`DWIDTH-1:0] add_out;

reg [`DWIDTH-1:0] a_flopped;
reg [`DWIDTH-1:0] b_flopped;

wire [2*`DWIDTH-1:0] mul_out_temp;
reg [2*`DWIDTH-1:0] mul_out_temp_reg;

always @(posedge clk) begin
  if (reset) begin
    a_flopped <= 0;
    b_flopped <= 0;
  end else begin
    a_flopped <= a;
    b_flopped <= b;
  end
end

//assign mul_out = a * b;
qmult mult_u1(.i_multiplicand(a_flopped), .i_multiplier(b_flopped), .o_result(mul_out_temp));

always @(posedge clk) begin
  if (reset) begin
    mul_out_temp_reg <= 0;
  end else begin
    mul_out_temp_reg <= mul_out_temp;
  end
end

//down cast the result
assign mul_out = 
    (mul_out_temp_reg[2*`DWIDTH-1] == 0) ?  //positive number
        (
           (|(mul_out_temp_reg[2*`DWIDTH-2 : `DWIDTH-1])) ?  //is any bit from 14:7 is 1, that means overlfow
             {mul_out_temp_reg[2*`DWIDTH-1] , {(`DWIDTH-1){1'b1}}} : //sign bit and then all 1s
             {mul_out_temp_reg[2*`DWIDTH-1] , mul_out_temp_reg[`DWIDTH-2:0]} 
        )
        : //negative number
        (
           (|(mul_out_temp_reg[2*`DWIDTH-2 : `DWIDTH-1])) ?  //is any bit from 14:7 is 0, that means overlfow
             {mul_out_temp_reg[2*`DWIDTH-1] , mul_out_temp_reg[`DWIDTH-2:0]} :
             {mul_out_temp_reg[2*`DWIDTH-1] , {(`DWIDTH-1){1'b0}}} //sign bit and then all 0s
        );


//we just truncate the higher bits of the product
//assign add_out = mul_out + out;
qadd add_u1(.a(out), .b(mul_out), .c(add_out));

always @(posedge clk) begin
  if (reset) begin
    out <= 0;
  end else begin
    out <= add_out;
  end
end

endmodule

module qmult(i_multiplicand,i_multiplier,o_result);
input [`DWIDTH-1:0] i_multiplicand;
input [`DWIDTH-1:0] i_multiplier;
output [2*`DWIDTH-1:0] o_result;

assign o_result = i_multiplicand * i_multiplier;
//DW02_mult #(`DWIDTH,`DWIDTH) u_mult(.A(i_multiplicand), .B(i_multiplier), .TC(1'b1), .PRODUCT(o_result));

endmodule

module qadd(a,b,c);
input [`DWIDTH-1:0] a;
input [`DWIDTH-1:0] b;
output [`DWIDTH-1:0] c;

assign c = a + b;
//DW01_add #(`DWIDTH) u_add(.A(a), .B(b), .CI(1'b0), .SUM(c), .CO());
endmodule
""")
