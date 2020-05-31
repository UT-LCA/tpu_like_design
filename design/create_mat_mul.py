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

module matmul(
 clk,
 reset,
 start_mat_mul,
 done_mat_mul,
 address_mat_a,
 address_mat_b,
 address_mat_c,
 address_stride_a,
 address_stride_b,
 address_stride_c,
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
 save_output_to_accum,
 add_accum_to_output,
 enable_conv_mode,
 conv_filter_height,
 conv_filter_width,
 conv_stride_horiz,
 conv_stride_verti,
 conv_padding_left,
 conv_padding_right,
 conv_padding_top,
 conv_padding_bottom,
 num_channels_inp,
 num_channels_out,
 inp_img_height,
 inp_img_width,
 out_img_height,
 out_img_width,
 batch_size,
 validity_mask_a_rows,
 validity_mask_a_cols_b_rows,
 validity_mask_b_cols,
 final_mat_mul_size,
 a_loc,
 b_loc
);

 input clk;
 input reset;
 input start_mat_mul;
 output done_mat_mul;
 input [`AWIDTH-1:0] address_mat_a;
 input [`AWIDTH-1:0] address_mat_b;
 input [`AWIDTH-1:0] address_mat_c;
 input [`ADDR_STRIDE_WIDTH-1:0] address_stride_a;
 input [`ADDR_STRIDE_WIDTH-1:0] address_stride_b;
 input [`ADDR_STRIDE_WIDTH-1:0] address_stride_c;
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
 input save_output_to_accum;
 input add_accum_to_output;
 input enable_conv_mode;
 input [3:0] conv_filter_height;
 input [3:0] conv_filter_width;
 input [3:0] conv_stride_horiz;
 input [3:0] conv_stride_verti;
 input [3:0] conv_padding_left;
 input [3:0] conv_padding_right;
 input [3:0] conv_padding_top;
 input [3:0] conv_padding_bottom;
 input [15:0] num_channels_inp;
 input [15:0] num_channels_out;
 input [15:0] inp_img_height;
 input [15:0] inp_img_width;
 input [15:0] out_img_height;
 input [15:0] out_img_width;
 input [31:0] batch_size;
 input [`MASK_WIDTH-1:0] validity_mask_a_rows;
 input [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows;
 input [`MASK_WIDTH-1:0] validity_mask_b_cols;
//7:0 is okay here. We aren't going to make a matmul larger than 128x128
//In fact, these will get optimized out by the synthesis tool, because
//we hardcode them at the instantiation level.
 input [7:0] final_mat_mul_size;
 input [7:0] a_loc;
 input [7:0] b_loc;

//////////////////////////////////////////////////////////////////////////
// Logic for clock counting and when to assert done
//////////////////////////////////////////////////////////////////////////

reg done_mat_mul;
//This is 7 bits because the expectation is that clock count will be pretty
//small. For large matmuls, this will need to increased to have more bits.
//In general, a systolic multiplier takes 4*N-2+P cycles, where N is the size 
//of the matmul and P is the number of pipleine stages in the MAC block.
reg [6:0] clk_cnt;

//Finding out number of cycles to assert matmul done.
//When we have to save the outputs to accumulators, then we don't need to
//shift out data. So, we can assert done_mat_mul early.
//In the normal case, we have to include the time to shift out the results. 
//Note: the count expression used to contain "4*final_mat_mul_size", but 
//to avoid multiplication, we now use "final_mat_mul_size<<2"
wire [6:0] clk_cnt_for_done;
assign clk_cnt_for_done = 
                          (save_output_to_accum && add_accum_to_output) ?
                          ((final_mat_mul_size<<2) - 3 + `NUM_CYCLES_IN_MAC - final_mat_mul_size) : (
                          (save_output_to_accum) ?
                          ((final_mat_mul_size<<2) - 3 + `NUM_CYCLES_IN_MAC - final_mat_mul_size) : (
                          (add_accum_to_output) ? 
                          ((final_mat_mul_size<<2) - 3 + `NUM_CYCLES_IN_MAC) :  
                          ((final_mat_mul_size<<2) - 3 + `NUM_CYCLES_IN_MAC) ));  

always @(posedge clk) begin
  if (reset || ~start_mat_mul) begin
    clk_cnt <= 0;
    done_mat_mul <= 0;
  end
  else if (clk_cnt == clk_cnt_for_done) begin
    done_mat_mul <= 1;
    clk_cnt <= clk_cnt + 1;

  end
  else if (done_mat_mul == 0) begin
    clk_cnt <= clk_cnt + 1;

  end    
  else begin
    done_mat_mul <= 0;
    clk_cnt <= clk_cnt + 1;
  end
end

//////////////////////////////////////////////////////////////////////////
// Logic to keep track of c,r,s values during convolution
//////////////////////////////////////////////////////////////////////////
reg [3:0] r; //iterator for filter height
reg [3:0] s; //iterator for filter width
reg [15:0] c; //iterator for input channels
reg [15:0] cur_c_saved;
reg [3:0] cur_r_saved;
reg [3:0] cur_s_saved;
reg dummy;

always @(posedge clk) begin
  if (reset || (add_accum_to_output && ~save_output_to_accum && done_mat_mul)) begin
    c <= 0;
    r <= 0;
    s <= 0;
  end
  else if (~start_mat_mul) begin
    //Dummy statements to make ODIN happy
    dummy <= conv_stride_horiz | conv_stride_verti | (|out_img_height) | (|out_img_width) | (|batch_size);
  end
  //Note than a_loc or b_loc doesn't matter in the code below. A and B are always synchronized.
  //else if ((clk_cnt >= a_loc*`MAT_MUL_SIZE) && (clk_cnt < a_loc*`MAT_MUL_SIZE+final_mat_mul_size)) begin
  //Writing the line above to avoid multiplication:
  else if ((clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)) && (clk_cnt < (a_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin
    if (enable_conv_mode) begin
      if (s < (conv_filter_width-1)) begin
          s <= s + 1;
      end else begin
          s <= 0;
      end 

      if (s == (conv_filter_width-1)) begin
          if (r == (conv_filter_height-1)) begin
              r <= 0;
          end else begin
              r <= r + 1;
          end
      end 

      if ((r == (conv_filter_height-1)) && (s == (conv_filter_width-1))) begin
          if (c == (num_channels_inp-1)) begin
              c <= 0;
          end else begin
              c <= c + 1;
          end
      end
    end
  end
end  

//////////////////////////////////////////////////////////////////////////
// Logic to generate addresses to BRAM A
//////////////////////////////////////////////////////////////////////////
reg [`AWIDTH-1:0] a_addr;
reg a_mem_access; //flag that tells whether the matmul is trying to access memory or not

always @(posedge clk) begin
  //(clk_cnt >= a_loc*`MAT_MUL_SIZE+final_mat_mul_size) begin
  //Writing the line above to avoid multiplication:
  if (reset || ~start_mat_mul || (clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin
    if (enable_conv_mode) begin
      a_addr <= address_mat_a;
    end 
    else begin
      a_addr <= address_mat_a-address_stride_a;
    end
    a_mem_access <= 0;
  end
  //else if ((clk_cnt >= a_loc*`MAT_MUL_SIZE) && (clk_cnt < a_loc*`MAT_MUL_SIZE+final_mat_mul_size)) begin
  //Writing the line above to avoid multiplication:
  else if ((clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)) && (clk_cnt < (a_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin
    if (enable_conv_mode) begin
      a_addr <= address_mat_a + s + r * (inp_img_width+conv_padding_left+conv_padding_right) + c * (inp_img_width+conv_padding_left+conv_padding_right) * (inp_img_height+conv_padding_top+conv_padding_bottom);
    end
    else begin
      a_addr <= a_addr + address_stride_a;
    end
    a_mem_access <= 1;
  end
end

//////////////////////////////////////////////////////////////////////////
// Logic to generate valid signals for data coming from BRAM A
//////////////////////////////////////////////////////////////////////////
reg a_data_valid; //flag that tells whether the data from memory is valid
reg [7:0] a_mem_access_counter;
always @(posedge clk) begin
  if (reset || ~start_mat_mul) begin
    a_data_valid <= 0;
    a_mem_access_counter <= 0;
  end
  else if (a_mem_access == 1) begin
    a_mem_access_counter = a_mem_access_counter + 1;  
""")
for i in range(int(sys.argv[1])):
  if i==0:
    f.write("    if ((validity_mask_a_cols_b_rows[" + str(i) +"]==1'b0 && a_mem_access_counter==" + str(i) + ") ||\n")
  elif i==(int(sys.argv[1])-1):
    f.write("        (validity_mask_a_cols_b_rows[" + str(i) +"]==1'b0 && a_mem_access_counter==" + str(i) + ")) begin\n")
  else:
    f.write("        (validity_mask_a_cols_b_rows[" + str(i) +"]==1'b0 && a_mem_access_counter==" + str(i) + ") ||\n")
f.write("""    
      a_data_valid <= 0;
    end
    else if (a_mem_access_counter == `MEM_ACCESS_LATENCY) begin
      a_data_valid <= 1;
    end
  end
  else begin
    a_data_valid <= 0;
    a_mem_access_counter <= 0;
  end
end

//////////////////////////////////////////////////////////////////////////
// Logic to delay certain parts of the data received from BRAM A (systolic data setup)
//////////////////////////////////////////////////////////////////////////
""")

for i in range(int(sys.argv[1])):
	f.write("wire [`DWIDTH-1:0] a" + str(i) + "_data;\n")

f.write("\n")

for i in range(int(sys.argv[1])):
	f.write("assign a"+ str(i) + "_data = a_data[" + str(i+1) + "*`DWIDTH-1:" + str(i) + "*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[" + str(i) + "]}};\n")

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

//////////////////////////////////////////////////////////////////////////
// Logic to generate addresses to BRAM B
//////////////////////////////////////////////////////////////////////////
reg [`AWIDTH-1:0] b_addr;
reg b_mem_access; //flag that tells whether the matmul is trying to access memory or not
always @(posedge clk) begin
  //else if (clk_cnt >= b_loc*`MAT_MUL_SIZE+final_mat_mul_size) begin
  //Writing the line above to avoid multiplication:
  if ((reset || ~start_mat_mul) || (clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin
    if (enable_conv_mode) begin
      b_addr <= address_mat_b;
    end 
    else begin
      b_addr <= address_mat_b - address_stride_b;
    end
    b_mem_access <= 0;
  end
  //else if ((clk_cnt >= b_loc*`MAT_MUL_SIZE) && (clk_cnt < b_loc*`MAT_MUL_SIZE+final_mat_mul_size)) begin
  //Writing the line above to avoid multiplication:
  else if ((clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)) && (clk_cnt < (b_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin
    if (enable_conv_mode) begin
      b_addr <= address_mat_b + (s*num_channels_out) + (r*num_channels_out*num_channels_out) + (c*num_channels_out*num_channels_out*num_channels_out);
    end
    else begin
      b_addr <= b_addr + address_stride_b;
    end
    b_mem_access <= 1;
  end
end 

//////////////////////////////////////////////////////////////////////////
// Logic to generate valid signals for data coming from BRAM B
//////////////////////////////////////////////////////////////////////////
reg b_data_valid; //flag that tells whether the data from memory is valid
reg [7:0] b_mem_access_counter;
always @(posedge clk) begin
  if (reset || ~start_mat_mul) begin
    b_data_valid <= 0;
    b_mem_access_counter <= 0;
  end
  else if (b_mem_access == 1) begin
    b_mem_access_counter = b_mem_access_counter + 1;  
""")
for i in range(int(sys.argv[1])):
  if i==0:
    f.write("    if ((validity_mask_a_cols_b_rows[" + str(i) +"]==1'b0 && b_mem_access_counter==" + str(i) + ") ||\n")
  elif i==(int(sys.argv[1])-1):
    f.write("        (validity_mask_a_cols_b_rows[" + str(i) +"]==1'b0 && b_mem_access_counter==" + str(i) + ")) begin\n")
  else:
    f.write("        (validity_mask_a_cols_b_rows[" + str(i) +"]==1'b0 && b_mem_access_counter==" + str(i) + ") ||\n")
f.write("""    
      b_data_valid <= 0;
    end
    else if (b_mem_access_counter == `MEM_ACCESS_LATENCY) begin
      b_data_valid <= 1;
    end
  end
  else begin
    b_data_valid <= 0;
    b_mem_access_counter <= 0;
  end
end

//////////////////////////////////////////////////////////////////////////
// Logic to delay certain parts of the data received from BRAM B (systolic data setup)
//////////////////////////////////////////////////////////////////////////
""")

for i in range(int(sys.argv[1])):
	f.write("wire [`DWIDTH-1:0] b" + str(i) + "_data;\n")

f.write("\n")

for i in range(int(sys.argv[1])):
	f.write("assign b"+ str(i) + "_data = b_data[" + str(i+1) + "*`DWIDTH-1:" + str(i) + "*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[" + str(i) + "]}};\n")

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

//////////////////////////////////////////////////////////////////////////
// Logic to mux data_in coming from neighboring matmuls
//////////////////////////////////////////////////////////////////////////
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

f.write("""\n
//////////////////////////////////////////////////////////////////////////
// Logic to handle accumulation of partial sums (accumulators)
//////////////////////////////////////////////////////////////////////////
\n""")
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


for i in range(int(sys.argv[1])):
	for j in range(int(sys.argv[1])):
		f.write("wire [`DWIDTH-1:0] matrixC" + str(i) + str(j) + "_added;\n")

f.write("\n\n")

for i in range(int(sys.argv[1])):
	for j in range(int(sys.argv[1])):
		f.write("reg [`DWIDTH-1:0] matrixC" + str(i) + str(j) + "_accum;\n")


f.write(
"""
reg outputs_saved_to_accum;
reg outputs_added_to_accum;
wire reset_accum;

always @(posedge clk) begin
  if (reset || ~(save_output_to_accum || add_accum_to_output) || (reset_accum)) begin
""")


for i in range(int(sys.argv[1])):
	for j in range(int(sys.argv[1])):
		f.write("matrixC" + str(i) + str(j) + "_accum <= 0;\n")

f.write(
""" outputs_saved_to_accum <= 0;
    outputs_added_to_accum <= 0;
    cur_c_saved <= 0;
    cur_r_saved <= 0;
    cur_s_saved <= 0;
  end
  else if (row_latch_en && save_output_to_accum && add_accum_to_output) begin
"""
)

for i in range(int(sys.argv[1])):
	for j in range(int(sys.argv[1])):
		f.write("\tmatrixC" + str(i) + str(j) + "_accum <= matrixC" + str(i) + str(j) + "_added;\n")

f.write(
"""
    outputs_saved_to_accum <= 1;
    outputs_added_to_accum <= 1;
    cur_c_saved <= c;
    cur_r_saved <= r;
    cur_s_saved <= s;
  end
  else if (row_latch_en && save_output_to_accum) begin
""")

for i in range(int(sys.argv[1])):
	for j in range(int(sys.argv[1])):
		f.write("\tmatrixC" + str(i) + str(j) + "_accum <= matrixC" + str(i) + str(j) + ";\n")

f.write("""
    outputs_saved_to_accum <= 1;
    cur_c_saved <= c;
    cur_r_saved <= r;
    cur_s_saved <= s;
  end
  else if (row_latch_en && add_accum_to_output) begin
    outputs_added_to_accum <= 1;
  end
end
""")


for i in range(int(sys.argv[1])):
	for j in range(int(sys.argv[1])):
		f.write("assign matrixC" + str(i) + str(j) + "_added = (add_accum_to_output) ? (matrixC" + str(i) + str(j) + " + matrixC" + str(i) + str(j) + "_accum) : matrixC" + str(i) + str(j) + ";\n")


f.write(
"""
//////////////////////////////////////////////////////////////////////////
// Logic to capture matrix C data from the PEs and shift it out
//////////////////////////////////////////////////////////////////////////
//assign row_latch_en = (clk_cnt==(`MAT_MUL_SIZE + (a_loc+b_loc) * `BB_MAT_MUL_SIZE + 10 +  `NUM_CYCLES_IN_MAC - 1));
//Writing the line above to avoid multiplication:
//assign row_latch_en = (clk_cnt==(`MAT_MUL_SIZE + ((a_loc+b_loc) << `LOG2_MAT_MUL_SIZE) + 10 +  `NUM_CYCLES_IN_MAC - 1));
assign row_latch_en =  (save_output_to_accum) ?
                       ((clk_cnt == ((`MAT_MUL_SIZE<<2) - `MAT_MUL_SIZE -1 +`NUM_CYCLES_IN_MAC))) :
                       ((clk_cnt == ((`MAT_MUL_SIZE<<2) - `MAT_MUL_SIZE -2 +`NUM_CYCLES_IN_MAC)));

reg c_data_available;
reg [`AWIDTH-1:0] c_addr;
reg start_capturing_c_data;
integer counter;
reg [""" + sys.argv[1] + """*`DWIDTH-1:0] c_data_out;

//We need to reset the accumulators when the mat mul is done and when we are 
//done with final reduction to generated a tile's output.
assign reset_accum = done_mat_mul & start_capturing_c_data;

//If save_output_to_accum is asserted, that means we are not intending to shift
//out the outputs, because the outputs are still partial sums. 
wire condition_to_start_shifting_output;
assign condition_to_start_shifting_output = 
                          (save_output_to_accum && add_accum_to_output) ?
                          1'b0 : (
                          (save_output_to_accum) ?
                          1'b0 : (
                          (add_accum_to_output) ? 
                          row_latch_en:  
                          row_latch_en ));  

"""
)

f.write(
"""
//For larger matmuls, this logic will have more entries in the case statement
always @(posedge clk) begin
  if (reset | ~start_mat_mul) begin
    start_capturing_c_data <= 1'b0;
    c_data_available <= 1'b0;
    c_addr <= address_mat_c-address_stride_c;
    c_data_out <= 0;
    counter <= 0;
  end else if (condition_to_start_shifting_output) begin
    start_capturing_c_data <= 1'b1;
    c_data_available <= 1'b1;
    c_addr <= c_addr + address_stride_c ;
    c_data_out <= {""")

for i in range(int(sys.argv[1])-1,-1,-1):
    f.write("matrixC" + str(i) + "0_added")

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
    c_addr <= address_mat_c - address_stride_c;
    c_data_out <= 0;
  end 
  else if (start_capturing_c_data) begin
    c_data_available <= 1'b1;
    c_addr <= c_addr + address_stride_c; 
    counter <= counter + 1;
    case (counter)  //rest of the elements are captured here
    """)

for i in range(1,int(sys.argv[1])):
	f.write("		"+str(i) + ": c_data_out <= {")
	for j in range(int(sys.argv[1])-1,-1,-1):
		f.write("matrixC" + str(j) + str(i) + "_added")

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
//////////////////////////////////////////////////////////////////////////
// Instantiations of the actual PEs
//////////////////////////////////////////////////////////////////////////
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

f.write("assign a_data_out = {")

for i in range(int(sys.argv[1])-1,-1,-1):
	f.write("a" + str(i) + str(int(sys.argv[1])-1) + "to" +  str(i) + sys.argv[1])

	if i != 0:
		f.write(",")
	else:
		f.write("};\n") 

f.write("assign b_data_out = {")

for i in range(int(sys.argv[1])-1,-1,-1):
	f.write("b" + str(int(sys.argv[1])-1) + str(i) + "to" +  sys.argv[1] + str(i) )

	if i != 0:
		f.write(",")
	else:
		f.write("};\n") 

f.write("""
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
