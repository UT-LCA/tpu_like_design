
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020-05-01 15:29:27.476318
// Design Name: 
// Module Name: matmul_8x8
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
`define MAT_MUL_SIZE 8
`define LOG2_MAT_MUL_SIZE 3
`define BB_MAT_MUL_SIZE `MAT_MUL_SIZE
`define NUM_CYCLES_IN_MAC 3

module matmul_8x8(
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
    a_addr <= `MEM_SIZE-1-7;//a_loc*16;
  end
  //else if (clk_cnt >= a_loc*`MAT_MUL_SIZE+final_mat_mul_size) begin
  //Writing the line above to avoid multiplication:
  else if (clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size) begin
    a_addr <= `MEM_SIZE-1-7; 
  end
  //else if ((clk_cnt >= a_loc*`MAT_MUL_SIZE) && (clk_cnt < a_loc*`MAT_MUL_SIZE+final_mat_mul_size)) begin
  //Writing the line above to avoid multiplication:
  else if ((clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)) && (clk_cnt < (a_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin
    a_addr <= a_addr + 8;
  end
end  
wire [`DWIDTH-1:0] a0_data;
wire [`DWIDTH-1:0] a1_data;
wire [`DWIDTH-1:0] a2_data;
wire [`DWIDTH-1:0] a3_data;
wire [`DWIDTH-1:0] a4_data;
wire [`DWIDTH-1:0] a5_data;
wire [`DWIDTH-1:0] a6_data;
wire [`DWIDTH-1:0] a7_data;

assign a0_data = a_data[1*`DWIDTH-1:0*`DWIDTH];
assign a1_data = a_data[2*`DWIDTH-1:1*`DWIDTH];
assign a2_data = a_data[3*`DWIDTH-1:2*`DWIDTH];
assign a3_data = a_data[4*`DWIDTH-1:3*`DWIDTH];
assign a4_data = a_data[5*`DWIDTH-1:4*`DWIDTH];
assign a5_data = a_data[6*`DWIDTH-1:5*`DWIDTH];
assign a6_data = a_data[7*`DWIDTH-1:6*`DWIDTH];
assign a7_data = a_data[8*`DWIDTH-1:7*`DWIDTH];

wire [`DWIDTH-1:0] a0_data_in;
wire [`DWIDTH-1:0] a1_data_in;
wire [`DWIDTH-1:0] a2_data_in;
wire [`DWIDTH-1:0] a3_data_in;
wire [`DWIDTH-1:0] a4_data_in;
wire [`DWIDTH-1:0] a5_data_in;
wire [`DWIDTH-1:0] a6_data_in;
wire [`DWIDTH-1:0] a7_data_in;

assign a0_data_in = a_data_in[1*`DWIDTH-1:0*`DWIDTH];
assign a1_data_in = a_data_in[2*`DWIDTH-1:1*`DWIDTH];
assign a2_data_in = a_data_in[3*`DWIDTH-1:2*`DWIDTH];
assign a3_data_in = a_data_in[4*`DWIDTH-1:3*`DWIDTH];
assign a4_data_in = a_data_in[5*`DWIDTH-1:4*`DWIDTH];
assign a5_data_in = a_data_in[6*`DWIDTH-1:5*`DWIDTH];
assign a6_data_in = a_data_in[7*`DWIDTH-1:6*`DWIDTH];
assign a7_data_in = a_data_in[8*`DWIDTH-1:7*`DWIDTH];

reg [`DWIDTH-1:0] a1_data_delayed_1;
reg [`DWIDTH-1:0] a2_data_delayed_1;
reg [`DWIDTH-1:0] a2_data_delayed_2;
reg [`DWIDTH-1:0] a3_data_delayed_1;
reg [`DWIDTH-1:0] a3_data_delayed_2;
reg [`DWIDTH-1:0] a3_data_delayed_3;
reg [`DWIDTH-1:0] a4_data_delayed_1;
reg [`DWIDTH-1:0] a4_data_delayed_2;
reg [`DWIDTH-1:0] a4_data_delayed_3;
reg [`DWIDTH-1:0] a4_data_delayed_4;
reg [`DWIDTH-1:0] a5_data_delayed_1;
reg [`DWIDTH-1:0] a5_data_delayed_2;
reg [`DWIDTH-1:0] a5_data_delayed_3;
reg [`DWIDTH-1:0] a5_data_delayed_4;
reg [`DWIDTH-1:0] a5_data_delayed_5;
reg [`DWIDTH-1:0] a6_data_delayed_1;
reg [`DWIDTH-1:0] a6_data_delayed_2;
reg [`DWIDTH-1:0] a6_data_delayed_3;
reg [`DWIDTH-1:0] a6_data_delayed_4;
reg [`DWIDTH-1:0] a6_data_delayed_5;
reg [`DWIDTH-1:0] a6_data_delayed_6;
reg [`DWIDTH-1:0] a7_data_delayed_1;
reg [`DWIDTH-1:0] a7_data_delayed_2;
reg [`DWIDTH-1:0] a7_data_delayed_3;
reg [`DWIDTH-1:0] a7_data_delayed_4;
reg [`DWIDTH-1:0] a7_data_delayed_5;
reg [`DWIDTH-1:0] a7_data_delayed_6;
reg [`DWIDTH-1:0] a7_data_delayed_7;


always @(posedge clk) begin
  if (reset || ~start_mat_mul || clk_cnt==0) begin
		a1_data_delayed_1 <= 0;
		a2_data_delayed_1 <= 0;
		a2_data_delayed_2 <= 0;
		a3_data_delayed_1 <= 0;
		a3_data_delayed_2 <= 0;
		a3_data_delayed_3 <= 0;
		a4_data_delayed_1 <= 0;
		a4_data_delayed_2 <= 0;
		a4_data_delayed_3 <= 0;
		a4_data_delayed_4 <= 0;
		a5_data_delayed_1 <= 0;
		a5_data_delayed_2 <= 0;
		a5_data_delayed_3 <= 0;
		a5_data_delayed_4 <= 0;
		a5_data_delayed_5 <= 0;
		a6_data_delayed_1 <= 0;
		a6_data_delayed_2 <= 0;
		a6_data_delayed_3 <= 0;
		a6_data_delayed_4 <= 0;
		a6_data_delayed_5 <= 0;
		a6_data_delayed_6 <= 0;
		a7_data_delayed_1 <= 0;
		a7_data_delayed_2 <= 0;
		a7_data_delayed_3 <= 0;
		a7_data_delayed_4 <= 0;
		a7_data_delayed_5 <= 0;
		a7_data_delayed_6 <= 0;
		a7_data_delayed_7 <= 0;

  end
  else begin
	a1_data_delayed_1 <= a1_data;
	a2_data_delayed_1 <= a2_data;
	a3_data_delayed_1 <= a3_data;
	a4_data_delayed_1 <= a4_data;
	a5_data_delayed_1 <= a5_data;
	a6_data_delayed_1 <= a6_data;
	a7_data_delayed_1 <= a7_data;
	a2_data_delayed_2 <= a2_data_delayed_1;
	a3_data_delayed_2 <= a3_data_delayed_1;
	a3_data_delayed_3 <= a3_data_delayed_2;
	a4_data_delayed_2 <= a4_data_delayed_1;
	a4_data_delayed_3 <= a4_data_delayed_2;
	a4_data_delayed_4 <= a4_data_delayed_3;
	a5_data_delayed_2 <= a5_data_delayed_1;
	a5_data_delayed_3 <= a5_data_delayed_2;
	a5_data_delayed_4 <= a5_data_delayed_3;
	a5_data_delayed_5 <= a5_data_delayed_4;
	a6_data_delayed_2 <= a6_data_delayed_1;
	a6_data_delayed_3 <= a6_data_delayed_2;
	a6_data_delayed_4 <= a6_data_delayed_3;
	a6_data_delayed_5 <= a6_data_delayed_4;
	a6_data_delayed_6 <= a6_data_delayed_5;
	a7_data_delayed_2 <= a7_data_delayed_1;
	a7_data_delayed_3 <= a7_data_delayed_2;
	a7_data_delayed_4 <= a7_data_delayed_3;
	a7_data_delayed_5 <= a7_data_delayed_4;
	a7_data_delayed_6 <= a7_data_delayed_5;
	a7_data_delayed_7 <= a7_data_delayed_6;
 
  end
end

reg [`AWIDTH-1:0] b_addr;
always @(posedge clk) begin
  if (reset || ~start_mat_mul) begin
    b_addr <= `MEM_SIZE-1-7;//b_loc*16;
  end
  //else if (clk_cnt >= b_loc*`MAT_MUL_SIZE+final_mat_mul_size) begin
  //Writing the line above to avoid multiplication:
  else if (clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size) begin
    b_addr <= `MEM_SIZE-1-7;
  end
  //else if ((clk_cnt >= b_loc*`MAT_MUL_SIZE) && (clk_cnt < b_loc*`MAT_MUL_SIZE+final_mat_mul_size)) begin
  //Writing the line above to avoid multiplication:
  else if ((clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)) && (clk_cnt < (b_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin
    b_addr <= b_addr + 8;
  end
end

wire [`DWIDTH-1:0] b0_data;
wire [`DWIDTH-1:0] b1_data;
wire [`DWIDTH-1:0] b2_data;
wire [`DWIDTH-1:0] b3_data;
wire [`DWIDTH-1:0] b4_data;
wire [`DWIDTH-1:0] b5_data;
wire [`DWIDTH-1:0] b6_data;
wire [`DWIDTH-1:0] b7_data;

assign b0_data = b_data[1*`DWIDTH-1:0*`DWIDTH];
assign b1_data = b_data[2*`DWIDTH-1:1*`DWIDTH];
assign b2_data = b_data[3*`DWIDTH-1:2*`DWIDTH];
assign b3_data = b_data[4*`DWIDTH-1:3*`DWIDTH];
assign b4_data = b_data[5*`DWIDTH-1:4*`DWIDTH];
assign b5_data = b_data[6*`DWIDTH-1:5*`DWIDTH];
assign b6_data = b_data[7*`DWIDTH-1:6*`DWIDTH];
assign b7_data = b_data[8*`DWIDTH-1:7*`DWIDTH];

wire [`DWIDTH-1:0] b0_data_in;
wire [`DWIDTH-1:0] b1_data_in;
wire [`DWIDTH-1:0] b2_data_in;
wire [`DWIDTH-1:0] b3_data_in;
wire [`DWIDTH-1:0] b4_data_in;
wire [`DWIDTH-1:0] b5_data_in;
wire [`DWIDTH-1:0] b6_data_in;
wire [`DWIDTH-1:0] b7_data_in;

assign b0_data_in = b_data_in[1*`DWIDTH-1:0*`DWIDTH];
assign b1_data_in = b_data_in[2*`DWIDTH-1:1*`DWIDTH];
assign b2_data_in = b_data_in[3*`DWIDTH-1:2*`DWIDTH];
assign b3_data_in = b_data_in[4*`DWIDTH-1:3*`DWIDTH];
assign b4_data_in = b_data_in[5*`DWIDTH-1:4*`DWIDTH];
assign b5_data_in = b_data_in[6*`DWIDTH-1:5*`DWIDTH];
assign b6_data_in = b_data_in[7*`DWIDTH-1:6*`DWIDTH];
assign b7_data_in = b_data_in[8*`DWIDTH-1:7*`DWIDTH];

reg [`DWIDTH-1:0] b1_data_delayed_1;
reg [`DWIDTH-1:0] b2_data_delayed_1;
reg [`DWIDTH-1:0] b2_data_delayed_2;
reg [`DWIDTH-1:0] b3_data_delayed_1;
reg [`DWIDTH-1:0] b3_data_delayed_2;
reg [`DWIDTH-1:0] b3_data_delayed_3;
reg [`DWIDTH-1:0] b4_data_delayed_1;
reg [`DWIDTH-1:0] b4_data_delayed_2;
reg [`DWIDTH-1:0] b4_data_delayed_3;
reg [`DWIDTH-1:0] b4_data_delayed_4;
reg [`DWIDTH-1:0] b5_data_delayed_1;
reg [`DWIDTH-1:0] b5_data_delayed_2;
reg [`DWIDTH-1:0] b5_data_delayed_3;
reg [`DWIDTH-1:0] b5_data_delayed_4;
reg [`DWIDTH-1:0] b5_data_delayed_5;
reg [`DWIDTH-1:0] b6_data_delayed_1;
reg [`DWIDTH-1:0] b6_data_delayed_2;
reg [`DWIDTH-1:0] b6_data_delayed_3;
reg [`DWIDTH-1:0] b6_data_delayed_4;
reg [`DWIDTH-1:0] b6_data_delayed_5;
reg [`DWIDTH-1:0] b6_data_delayed_6;
reg [`DWIDTH-1:0] b7_data_delayed_1;
reg [`DWIDTH-1:0] b7_data_delayed_2;
reg [`DWIDTH-1:0] b7_data_delayed_3;
reg [`DWIDTH-1:0] b7_data_delayed_4;
reg [`DWIDTH-1:0] b7_data_delayed_5;
reg [`DWIDTH-1:0] b7_data_delayed_6;
reg [`DWIDTH-1:0] b7_data_delayed_7;


always @(posedge clk) begin
  if (reset || ~start_mat_mul || clk_cnt==0) begin
		b1_data_delayed_1 <= 0;
		b2_data_delayed_1 <= 0;
		b2_data_delayed_2 <= 0;
		b3_data_delayed_1 <= 0;
		b3_data_delayed_2 <= 0;
		b3_data_delayed_3 <= 0;
		b4_data_delayed_1 <= 0;
		b4_data_delayed_2 <= 0;
		b4_data_delayed_3 <= 0;
		b4_data_delayed_4 <= 0;
		b5_data_delayed_1 <= 0;
		b5_data_delayed_2 <= 0;
		b5_data_delayed_3 <= 0;
		b5_data_delayed_4 <= 0;
		b5_data_delayed_5 <= 0;
		b6_data_delayed_1 <= 0;
		b6_data_delayed_2 <= 0;
		b6_data_delayed_3 <= 0;
		b6_data_delayed_4 <= 0;
		b6_data_delayed_5 <= 0;
		b6_data_delayed_6 <= 0;
		b7_data_delayed_1 <= 0;
		b7_data_delayed_2 <= 0;
		b7_data_delayed_3 <= 0;
		b7_data_delayed_4 <= 0;
		b7_data_delayed_5 <= 0;
		b7_data_delayed_6 <= 0;
		b7_data_delayed_7 <= 0;

  end
  else begin
	b1_data_delayed_1 <= b1_data;
	b2_data_delayed_1 <= b2_data;
	b3_data_delayed_1 <= b3_data;
	b4_data_delayed_1 <= b4_data;
	b5_data_delayed_1 <= b5_data;
	b6_data_delayed_1 <= b6_data;
	b7_data_delayed_1 <= b7_data;
	b2_data_delayed_2 <= b2_data_delayed_1;
	b3_data_delayed_2 <= b3_data_delayed_1;
	b3_data_delayed_3 <= b3_data_delayed_2;
	b4_data_delayed_2 <= b4_data_delayed_1;
	b4_data_delayed_3 <= b4_data_delayed_2;
	b4_data_delayed_4 <= b4_data_delayed_3;
	b5_data_delayed_2 <= b5_data_delayed_1;
	b5_data_delayed_3 <= b5_data_delayed_2;
	b5_data_delayed_4 <= b5_data_delayed_3;
	b5_data_delayed_5 <= b5_data_delayed_4;
	b6_data_delayed_2 <= b6_data_delayed_1;
	b6_data_delayed_3 <= b6_data_delayed_2;
	b6_data_delayed_4 <= b6_data_delayed_3;
	b6_data_delayed_5 <= b6_data_delayed_4;
	b6_data_delayed_6 <= b6_data_delayed_5;
	b7_data_delayed_2 <= b7_data_delayed_1;
	b7_data_delayed_3 <= b7_data_delayed_2;
	b7_data_delayed_4 <= b7_data_delayed_3;
	b7_data_delayed_5 <= b7_data_delayed_4;
	b7_data_delayed_6 <= b7_data_delayed_5;
	b7_data_delayed_7 <= b7_data_delayed_6;
 
  end
end
wire [`DWIDTH-1:0] a0;
wire [`DWIDTH-1:0] a1;
wire [`DWIDTH-1:0] a2;
wire [`DWIDTH-1:0] a3;
wire [`DWIDTH-1:0] a4;
wire [`DWIDTH-1:0] a5;
wire [`DWIDTH-1:0] a6;
wire [`DWIDTH-1:0] a7;
wire [`DWIDTH-1:0] b0;
wire [`DWIDTH-1:0] b1;
wire [`DWIDTH-1:0] b2;
wire [`DWIDTH-1:0] b3;
wire [`DWIDTH-1:0] b4;
wire [`DWIDTH-1:0] b5;
wire [`DWIDTH-1:0] b6;
wire [`DWIDTH-1:0] b7;

assign a0 = (b_loc==0) ? a0_data           : a0_data_in;
assign a1 = (b_loc==0) ? a1_data_delayed_1 : a1_data_in;
assign a2 = (b_loc==0) ? a2_data_delayed_2 : a2_data_in;
assign a3 = (b_loc==0) ? a3_data_delayed_3 : a3_data_in;
assign a4 = (b_loc==0) ? a4_data_delayed_4 : a4_data_in;
assign a5 = (b_loc==0) ? a5_data_delayed_5 : a5_data_in;
assign a6 = (b_loc==0) ? a6_data_delayed_6 : a6_data_in;
assign a7 = (b_loc==0) ? a7_data_delayed_7 : a7_data_in;

assign b0 = (a_loc==0) ? b0_data           : b0_data_in;
assign b1 = (a_loc==0) ? b1_data_delayed_1 : b1_data_in;
assign b2 = (a_loc==0) ? b2_data_delayed_2 : b2_data_in;
assign b3 = (a_loc==0) ? b3_data_delayed_3 : b3_data_in;
assign b4 = (a_loc==0) ? b4_data_delayed_4 : b4_data_in;
assign b5 = (a_loc==0) ? b5_data_delayed_5 : b5_data_in;
assign b6 = (a_loc==0) ? b6_data_delayed_6 : b6_data_in;
assign b7 = (a_loc==0) ? b7_data_delayed_7 : b7_data_in;

wire [`DWIDTH-1:0] a00to01, a01to02, a02to03, a03to04, a04to05, a05to06, a06to07, a07to08;
wire [`DWIDTH-1:0] a10to11, a11to12, a12to13, a13to14, a14to15, a15to16, a16to17, a17to18;
wire [`DWIDTH-1:0] a20to21, a21to22, a22to23, a23to24, a24to25, a25to26, a26to27, a27to28;
wire [`DWIDTH-1:0] a30to31, a31to32, a32to33, a33to34, a34to35, a35to36, a36to37, a37to38;
wire [`DWIDTH-1:0] a40to41, a41to42, a42to43, a43to44, a44to45, a45to46, a46to47, a47to48;
wire [`DWIDTH-1:0] a50to51, a51to52, a52to53, a53to54, a54to55, a55to56, a56to57, a57to58;
wire [`DWIDTH-1:0] a60to61, a61to62, a62to63, a63to64, a64to65, a65to66, a66to67, a67to68;
wire [`DWIDTH-1:0] a70to71, a71to72, a72to73, a73to74, a74to75, a75to76, a76to77, a77to78;

wire [`DWIDTH-1:0] b00to10, b10to20, b20to30, b30to40, b40to50, b50to60, b60to70, b70to80;
wire [`DWIDTH-1:0] b01to11, b11to21, b21to31, b31to41, b41to51, b51to61, b61to71, b71to81;
wire [`DWIDTH-1:0] b02to12, b12to22, b22to32, b32to42, b42to52, b52to62, b62to72, b72to82;
wire [`DWIDTH-1:0] b03to13, b13to23, b23to33, b33to43, b43to53, b53to63, b63to73, b73to83;
wire [`DWIDTH-1:0] b04to14, b14to24, b24to34, b34to44, b44to54, b54to64, b64to74, b74to84;
wire [`DWIDTH-1:0] b05to15, b15to25, b25to35, b35to45, b45to55, b55to65, b65to75, b75to85;
wire [`DWIDTH-1:0] b06to16, b16to26, b26to36, b36to46, b46to56, b56to66, b66to76, b76to86;
wire [`DWIDTH-1:0] b07to17, b17to27, b27to37, b37to47, b47to57, b57to67, b67to77, b77to87;
wire [`DWIDTH-1:0] cin_row0;
wire [`DWIDTH-1:0] cin_row1;
wire [`DWIDTH-1:0] cin_row2;
wire [`DWIDTH-1:0] cin_row3;
wire [`DWIDTH-1:0] cin_row4;
wire [`DWIDTH-1:0] cin_row5;
wire [`DWIDTH-1:0] cin_row6;
wire [`DWIDTH-1:0] cin_row7;
wire row_latch_en;

wire [`DWIDTH-1:0] matrixC00;
wire [`DWIDTH-1:0] matrixC01;
wire [`DWIDTH-1:0] matrixC02;
wire [`DWIDTH-1:0] matrixC03;
wire [`DWIDTH-1:0] matrixC04;
wire [`DWIDTH-1:0] matrixC05;
wire [`DWIDTH-1:0] matrixC06;
wire [`DWIDTH-1:0] matrixC07;
wire [`DWIDTH-1:0] matrixC10;
wire [`DWIDTH-1:0] matrixC11;
wire [`DWIDTH-1:0] matrixC12;
wire [`DWIDTH-1:0] matrixC13;
wire [`DWIDTH-1:0] matrixC14;
wire [`DWIDTH-1:0] matrixC15;
wire [`DWIDTH-1:0] matrixC16;
wire [`DWIDTH-1:0] matrixC17;
wire [`DWIDTH-1:0] matrixC20;
wire [`DWIDTH-1:0] matrixC21;
wire [`DWIDTH-1:0] matrixC22;
wire [`DWIDTH-1:0] matrixC23;
wire [`DWIDTH-1:0] matrixC24;
wire [`DWIDTH-1:0] matrixC25;
wire [`DWIDTH-1:0] matrixC26;
wire [`DWIDTH-1:0] matrixC27;
wire [`DWIDTH-1:0] matrixC30;
wire [`DWIDTH-1:0] matrixC31;
wire [`DWIDTH-1:0] matrixC32;
wire [`DWIDTH-1:0] matrixC33;
wire [`DWIDTH-1:0] matrixC34;
wire [`DWIDTH-1:0] matrixC35;
wire [`DWIDTH-1:0] matrixC36;
wire [`DWIDTH-1:0] matrixC37;
wire [`DWIDTH-1:0] matrixC40;
wire [`DWIDTH-1:0] matrixC41;
wire [`DWIDTH-1:0] matrixC42;
wire [`DWIDTH-1:0] matrixC43;
wire [`DWIDTH-1:0] matrixC44;
wire [`DWIDTH-1:0] matrixC45;
wire [`DWIDTH-1:0] matrixC46;
wire [`DWIDTH-1:0] matrixC47;
wire [`DWIDTH-1:0] matrixC50;
wire [`DWIDTH-1:0] matrixC51;
wire [`DWIDTH-1:0] matrixC52;
wire [`DWIDTH-1:0] matrixC53;
wire [`DWIDTH-1:0] matrixC54;
wire [`DWIDTH-1:0] matrixC55;
wire [`DWIDTH-1:0] matrixC56;
wire [`DWIDTH-1:0] matrixC57;
wire [`DWIDTH-1:0] matrixC60;
wire [`DWIDTH-1:0] matrixC61;
wire [`DWIDTH-1:0] matrixC62;
wire [`DWIDTH-1:0] matrixC63;
wire [`DWIDTH-1:0] matrixC64;
wire [`DWIDTH-1:0] matrixC65;
wire [`DWIDTH-1:0] matrixC66;
wire [`DWIDTH-1:0] matrixC67;
wire [`DWIDTH-1:0] matrixC70;
wire [`DWIDTH-1:0] matrixC71;
wire [`DWIDTH-1:0] matrixC72;
wire [`DWIDTH-1:0] matrixC73;
wire [`DWIDTH-1:0] matrixC74;
wire [`DWIDTH-1:0] matrixC75;
wire [`DWIDTH-1:0] matrixC76;
wire [`DWIDTH-1:0] matrixC77;
assign cin_row0 = c_data_in[1*`DWIDTH-1:0*`DWIDTH];
assign cin_row1 = c_data_in[2*`DWIDTH-1:1*`DWIDTH];
assign cin_row2 = c_data_in[3*`DWIDTH-1:2*`DWIDTH];
assign cin_row3 = c_data_in[4*`DWIDTH-1:3*`DWIDTH];
assign cin_row4 = c_data_in[5*`DWIDTH-1:4*`DWIDTH];
assign cin_row5 = c_data_in[6*`DWIDTH-1:5*`DWIDTH];
assign cin_row6 = c_data_in[7*`DWIDTH-1:6*`DWIDTH];
assign cin_row7 = c_data_in[8*`DWIDTH-1:7*`DWIDTH];

//assign row_latch_en = (clk_cnt==(`MAT_MUL_SIZE + (a_loc+b_loc) * `BB_MAT_MUL_SIZE + 10 +  `NUM_CYCLES_IN_MAC - 1));
//Writing the line above to avoid multiplication:
assign row_latch_en = (clk_cnt==(`MAT_MUL_SIZE + ((a_loc+b_loc) << `LOG2_MAT_MUL_SIZE) + 10 +  `NUM_CYCLES_IN_MAC - 1));

reg c_data_available;
reg [`AWIDTH-1:0] c_addr;
reg start_capturing_c_data;
integer counter;
reg [8*`DWIDTH-1:0] c_data_out;

//For larger matmuls, this logic will have more entries in the case statement
always @(posedge clk) begin
  if (reset | ~start_mat_mul) begin
    start_capturing_c_data <= 1'b0;
    c_data_available <= 1'b0;
    c_addr <= `MEM_SIZE-1-7;
    c_data_out <= 0;
    counter <= 0;
  end else if (row_latch_en) begin
    start_capturing_c_data <= 1'b1;
    c_data_available <= 1'b1;
    c_addr <= c_addr + 8;
    c_data_out <= {matrixC70, matrixC60, matrixC50, matrixC40, matrixC30, matrixC20, matrixC10, matrixC00};

    counter <= counter + 1;
  end else if (done_mat_mul) begin
    start_capturing_c_data <= 1'b0;
    c_data_available <= 1'b0;
    c_addr <= `MEM_SIZE-1-7;
    c_data_out <= 0;
  end 
  else if (start_capturing_c_data) begin
    c_data_available <= 1'b1;
    c_addr <= c_addr + 8; 
    counter <= counter + 1;
    case (counter)  //rest of the elements are captured here
    		1: c_data_out <= {matrixC71, matrixC61, matrixC51, matrixC41, matrixC31, matrixC21, matrixC11, matrixC01};
		2: c_data_out <= {matrixC72, matrixC62, matrixC52, matrixC42, matrixC32, matrixC22, matrixC12, matrixC02};
		3: c_data_out <= {matrixC73, matrixC63, matrixC53, matrixC43, matrixC33, matrixC23, matrixC13, matrixC03};
		4: c_data_out <= {matrixC74, matrixC64, matrixC54, matrixC44, matrixC34, matrixC24, matrixC14, matrixC04};
		5: c_data_out <= {matrixC75, matrixC65, matrixC55, matrixC45, matrixC35, matrixC25, matrixC15, matrixC05};
		6: c_data_out <= {matrixC76, matrixC66, matrixC56, matrixC46, matrixC36, matrixC26, matrixC16, matrixC06};
		7: c_data_out <= {matrixC77, matrixC67, matrixC57, matrixC47, matrixC37, matrixC27, matrixC17, matrixC07};

        default: c_data_out <= 0;
    endcase
  end
end
//For larger matmul, more PEs will be needed
wire effective_rst;
assign effective_rst = reset | ~start_mat_mul;

processing_element pe00(.reset(effective_rst), .clk(clk),  .in_a(a0),      .in_b(b0),  .out_a(a00to01), .out_b(b00to10), .out_c(matrixC00));
processing_element pe01(.reset(effective_rst), .clk(clk),  .in_a(a00to01), .in_b(b1),  .out_a(a01to02), .out_b(b01to11), .out_c(matrixC01));
processing_element pe02(.reset(effective_rst), .clk(clk),  .in_a(a01to02), .in_b(b2),  .out_a(a02to03), .out_b(b02to12), .out_c(matrixC02));
processing_element pe03(.reset(effective_rst), .clk(clk),  .in_a(a02to03), .in_b(b3),  .out_a(a03to04), .out_b(b03to13), .out_c(matrixC03));
processing_element pe04(.reset(effective_rst), .clk(clk),  .in_a(a03to04), .in_b(b4),  .out_a(a04to05), .out_b(b04to14), .out_c(matrixC04));
processing_element pe05(.reset(effective_rst), .clk(clk),  .in_a(a04to05), .in_b(b5),  .out_a(a05to06), .out_b(b05to15), .out_c(matrixC05));
processing_element pe06(.reset(effective_rst), .clk(clk),  .in_a(a05to06), .in_b(b6),  .out_a(a06to07), .out_b(b06to16), .out_c(matrixC06));
processing_element pe07(.reset(effective_rst), .clk(clk),  .in_a(a06to07), .in_b(b7),  .out_a(a07to08), .out_b(b07to17), .out_c(matrixC07));

processing_element pe10(.reset(effective_rst), .clk(clk),  .in_a(a1), .in_b(b00to10),  .out_a(a10to11), .out_b(b10to20), .out_c(matrixC10));
processing_element pe20(.reset(effective_rst), .clk(clk),  .in_a(a2), .in_b(b10to20),  .out_a(a20to21), .out_b(b20to30), .out_c(matrixC20));
processing_element pe30(.reset(effective_rst), .clk(clk),  .in_a(a3), .in_b(b20to30),  .out_a(a30to31), .out_b(b30to40), .out_c(matrixC30));
processing_element pe40(.reset(effective_rst), .clk(clk),  .in_a(a4), .in_b(b30to40),  .out_a(a40to41), .out_b(b40to50), .out_c(matrixC40));
processing_element pe50(.reset(effective_rst), .clk(clk),  .in_a(a5), .in_b(b40to50),  .out_a(a50to51), .out_b(b50to60), .out_c(matrixC50));
processing_element pe60(.reset(effective_rst), .clk(clk),  .in_a(a6), .in_b(b50to60),  .out_a(a60to61), .out_b(b60to70), .out_c(matrixC60));
processing_element pe70(.reset(effective_rst), .clk(clk),  .in_a(a7), .in_b(b60to70),  .out_a(a70to71), .out_b(b70to80), .out_c(matrixC70));

processing_element pe11(.reset(effective_rst), .clk(clk),  .in_a(a10to11), .in_b(b01to11),  .out_a(a11to12), .out_b(b11to21), .out_c(matrixC11));
processing_element pe12(.reset(effective_rst), .clk(clk),  .in_a(a11to12), .in_b(b02to12),  .out_a(a12to13), .out_b(b12to22), .out_c(matrixC12));
processing_element pe13(.reset(effective_rst), .clk(clk),  .in_a(a12to13), .in_b(b03to13),  .out_a(a13to14), .out_b(b13to23), .out_c(matrixC13));
processing_element pe14(.reset(effective_rst), .clk(clk),  .in_a(a13to14), .in_b(b04to14),  .out_a(a14to15), .out_b(b14to24), .out_c(matrixC14));
processing_element pe15(.reset(effective_rst), .clk(clk),  .in_a(a14to15), .in_b(b05to15),  .out_a(a15to16), .out_b(b15to25), .out_c(matrixC15));
processing_element pe16(.reset(effective_rst), .clk(clk),  .in_a(a15to16), .in_b(b06to16),  .out_a(a16to17), .out_b(b16to26), .out_c(matrixC16));
processing_element pe17(.reset(effective_rst), .clk(clk),  .in_a(a16to17), .in_b(b07to17),  .out_a(a17to18), .out_b(b17to27), .out_c(matrixC17));
processing_element pe21(.reset(effective_rst), .clk(clk),  .in_a(a20to21), .in_b(b11to21),  .out_a(a21to22), .out_b(b21to31), .out_c(matrixC21));
processing_element pe22(.reset(effective_rst), .clk(clk),  .in_a(a21to22), .in_b(b12to22),  .out_a(a22to23), .out_b(b22to32), .out_c(matrixC22));
processing_element pe23(.reset(effective_rst), .clk(clk),  .in_a(a22to23), .in_b(b13to23),  .out_a(a23to24), .out_b(b23to33), .out_c(matrixC23));
processing_element pe24(.reset(effective_rst), .clk(clk),  .in_a(a23to24), .in_b(b14to24),  .out_a(a24to25), .out_b(b24to34), .out_c(matrixC24));
processing_element pe25(.reset(effective_rst), .clk(clk),  .in_a(a24to25), .in_b(b15to25),  .out_a(a25to26), .out_b(b25to35), .out_c(matrixC25));
processing_element pe26(.reset(effective_rst), .clk(clk),  .in_a(a25to26), .in_b(b16to26),  .out_a(a26to27), .out_b(b26to36), .out_c(matrixC26));
processing_element pe27(.reset(effective_rst), .clk(clk),  .in_a(a26to27), .in_b(b17to27),  .out_a(a27to28), .out_b(b27to37), .out_c(matrixC27));
processing_element pe31(.reset(effective_rst), .clk(clk),  .in_a(a30to31), .in_b(b21to31),  .out_a(a31to32), .out_b(b31to41), .out_c(matrixC31));
processing_element pe32(.reset(effective_rst), .clk(clk),  .in_a(a31to32), .in_b(b22to32),  .out_a(a32to33), .out_b(b32to42), .out_c(matrixC32));
processing_element pe33(.reset(effective_rst), .clk(clk),  .in_a(a32to33), .in_b(b23to33),  .out_a(a33to34), .out_b(b33to43), .out_c(matrixC33));
processing_element pe34(.reset(effective_rst), .clk(clk),  .in_a(a33to34), .in_b(b24to34),  .out_a(a34to35), .out_b(b34to44), .out_c(matrixC34));
processing_element pe35(.reset(effective_rst), .clk(clk),  .in_a(a34to35), .in_b(b25to35),  .out_a(a35to36), .out_b(b35to45), .out_c(matrixC35));
processing_element pe36(.reset(effective_rst), .clk(clk),  .in_a(a35to36), .in_b(b26to36),  .out_a(a36to37), .out_b(b36to46), .out_c(matrixC36));
processing_element pe37(.reset(effective_rst), .clk(clk),  .in_a(a36to37), .in_b(b27to37),  .out_a(a37to38), .out_b(b37to47), .out_c(matrixC37));
processing_element pe41(.reset(effective_rst), .clk(clk),  .in_a(a40to41), .in_b(b31to41),  .out_a(a41to42), .out_b(b41to51), .out_c(matrixC41));
processing_element pe42(.reset(effective_rst), .clk(clk),  .in_a(a41to42), .in_b(b32to42),  .out_a(a42to43), .out_b(b42to52), .out_c(matrixC42));
processing_element pe43(.reset(effective_rst), .clk(clk),  .in_a(a42to43), .in_b(b33to43),  .out_a(a43to44), .out_b(b43to53), .out_c(matrixC43));
processing_element pe44(.reset(effective_rst), .clk(clk),  .in_a(a43to44), .in_b(b34to44),  .out_a(a44to45), .out_b(b44to54), .out_c(matrixC44));
processing_element pe45(.reset(effective_rst), .clk(clk),  .in_a(a44to45), .in_b(b35to45),  .out_a(a45to46), .out_b(b45to55), .out_c(matrixC45));
processing_element pe46(.reset(effective_rst), .clk(clk),  .in_a(a45to46), .in_b(b36to46),  .out_a(a46to47), .out_b(b46to56), .out_c(matrixC46));
processing_element pe47(.reset(effective_rst), .clk(clk),  .in_a(a46to47), .in_b(b37to47),  .out_a(a47to48), .out_b(b47to57), .out_c(matrixC47));
processing_element pe51(.reset(effective_rst), .clk(clk),  .in_a(a50to51), .in_b(b41to51),  .out_a(a51to52), .out_b(b51to61), .out_c(matrixC51));
processing_element pe52(.reset(effective_rst), .clk(clk),  .in_a(a51to52), .in_b(b42to52),  .out_a(a52to53), .out_b(b52to62), .out_c(matrixC52));
processing_element pe53(.reset(effective_rst), .clk(clk),  .in_a(a52to53), .in_b(b43to53),  .out_a(a53to54), .out_b(b53to63), .out_c(matrixC53));
processing_element pe54(.reset(effective_rst), .clk(clk),  .in_a(a53to54), .in_b(b44to54),  .out_a(a54to55), .out_b(b54to64), .out_c(matrixC54));
processing_element pe55(.reset(effective_rst), .clk(clk),  .in_a(a54to55), .in_b(b45to55),  .out_a(a55to56), .out_b(b55to65), .out_c(matrixC55));
processing_element pe56(.reset(effective_rst), .clk(clk),  .in_a(a55to56), .in_b(b46to56),  .out_a(a56to57), .out_b(b56to66), .out_c(matrixC56));
processing_element pe57(.reset(effective_rst), .clk(clk),  .in_a(a56to57), .in_b(b47to57),  .out_a(a57to58), .out_b(b57to67), .out_c(matrixC57));
processing_element pe61(.reset(effective_rst), .clk(clk),  .in_a(a60to61), .in_b(b51to61),  .out_a(a61to62), .out_b(b61to71), .out_c(matrixC61));
processing_element pe62(.reset(effective_rst), .clk(clk),  .in_a(a61to62), .in_b(b52to62),  .out_a(a62to63), .out_b(b62to72), .out_c(matrixC62));
processing_element pe63(.reset(effective_rst), .clk(clk),  .in_a(a62to63), .in_b(b53to63),  .out_a(a63to64), .out_b(b63to73), .out_c(matrixC63));
processing_element pe64(.reset(effective_rst), .clk(clk),  .in_a(a63to64), .in_b(b54to64),  .out_a(a64to65), .out_b(b64to74), .out_c(matrixC64));
processing_element pe65(.reset(effective_rst), .clk(clk),  .in_a(a64to65), .in_b(b55to65),  .out_a(a65to66), .out_b(b65to75), .out_c(matrixC65));
processing_element pe66(.reset(effective_rst), .clk(clk),  .in_a(a65to66), .in_b(b56to66),  .out_a(a66to67), .out_b(b66to76), .out_c(matrixC66));
processing_element pe67(.reset(effective_rst), .clk(clk),  .in_a(a66to67), .in_b(b57to67),  .out_a(a67to68), .out_b(b67to77), .out_c(matrixC67));
processing_element pe71(.reset(effective_rst), .clk(clk),  .in_a(a70to71), .in_b(b61to71),  .out_a(a71to72), .out_b(b71to81), .out_c(matrixC71));
processing_element pe72(.reset(effective_rst), .clk(clk),  .in_a(a71to72), .in_b(b62to72),  .out_a(a72to73), .out_b(b72to82), .out_c(matrixC72));
processing_element pe73(.reset(effective_rst), .clk(clk),  .in_a(a72to73), .in_b(b63to73),  .out_a(a73to74), .out_b(b73to83), .out_c(matrixC73));
processing_element pe74(.reset(effective_rst), .clk(clk),  .in_a(a73to74), .in_b(b64to74),  .out_a(a74to75), .out_b(b74to84), .out_c(matrixC74));
processing_element pe75(.reset(effective_rst), .clk(clk),  .in_a(a74to75), .in_b(b65to75),  .out_a(a75to76), .out_b(b75to85), .out_c(matrixC75));
processing_element pe76(.reset(effective_rst), .clk(clk),  .in_a(a75to76), .in_b(b66to76),  .out_a(a76to77), .out_b(b76to86), .out_c(matrixC76));
processing_element pe77(.reset(effective_rst), .clk(clk),  .in_a(a76to77), .in_b(b67to77),  .out_a(a77to78), .out_b(b77to87), .out_c(matrixC77));
assign a_data_out = {a77to78,a67to68,a57to58,a47to48,a37to38,a27to28,a17to18,a07to08};
assign b_data_out = {b77to87,b76to86,b75to85,b74to84,b73to83,b72to82,b71to81,b70to80};

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
