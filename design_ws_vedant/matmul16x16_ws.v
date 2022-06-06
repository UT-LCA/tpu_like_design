////////////////////////////////////////////////////////////////////////////////
// THIS FILE WAS AUTOMATICALLY GENERATED FROM generate_matmul.v.mako
// DO NOT EDIT
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns
`define DWIDTH 8
`define AWIDTH 11
`define MEM_SIZE 2048

`define MAT_MUL_SIZE 16
`define MASK_WIDTH 16
`define LOG2_MAT_MUL_SIZE 4

`define BB_MAT_MUL_SIZE `MAT_MUL_SIZE
`define NUM_CYCLES_IN_MAC 3
`define MEM_ACCESS_LATENCY 1
`define REG_DATAWIDTH 32
`define REG_ADDRWIDTH 8
`define ADDR_STRIDE_WIDTH 8
`define MAX_BITS_POOL 3
`define VCS

module matmul_16x16_systolic(
    clk,
    reset,
    pe_reset,
    start_mat_mul,
    done_mat_mul,
    num_matrices_A,
    num_matrices_B,
    address_mat_a,
    address_mat_b,
    address_mat_c,
    address_stride_a,
    address_stride_b,
    address_stride_c,
    a_data,
    b_data,
    a_data_in,  // Data values coming in from previous matmul - systolic connections
    b_data_in,  // Data values coming in from previous matmul - weight matrix 
    c_data_in,  // Data values coming in from previous matmul - systolic shifting
    c_data_out, // Data values going out to next matmul - systolic shifting
    a_data_out,
    b_data_out,
    a_addr,
    b_addr,
    c_addr,
    c_data_available,
    matrixC150,
    matrixC151,
    matrixC152,
    matrixC153,
    matrixC154,
    matrixC155,
    matrixC156,
    matrixC157,
    matrixC158,
    matrixC159,
    matrixC1510,
    matrixC1511,
    matrixC1512,
    matrixC1513,
    matrixC1514,
    matrixC1515,
    validity_mask_a_rows,
    validity_mask_a_cols_b_rows,
    validity_mask_b_cols,
    a_loc,
    b_loc
);

input clk;
input reset;
input pe_reset;
input start_mat_mul;
output done_mat_mul;
input [31:0] num_matrices_A; // Number of 16x16 matrices the input matrix can be divided into
input [31:0] num_matrices_B; // Number of 16x16 matrices the weight matrix can be divided into
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
output [`DWIDTH-1:0] matrixC150;
output [`DWIDTH-1:0] matrixC151;
output [`DWIDTH-1:0] matrixC152;
output [`DWIDTH-1:0] matrixC153;
output [`DWIDTH-1:0] matrixC154;
output [`DWIDTH-1:0] matrixC155;
output [`DWIDTH-1:0] matrixC156;
output [`DWIDTH-1:0] matrixC157;
output [`DWIDTH-1:0] matrixC158;
output [`DWIDTH-1:0] matrixC159;
output [`DWIDTH-1:0] matrixC1510;
output [`DWIDTH-1:0] matrixC1511;
output [`DWIDTH-1:0] matrixC1512;
output [`DWIDTH-1:0] matrixC1513;
output [`DWIDTH-1:0] matrixC1514;
output [`DWIDTH-1:0] matrixC1515;
input [`MASK_WIDTH-1:0] validity_mask_a_rows;
input [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows;
input [`MASK_WIDTH-1:0] validity_mask_b_cols;
input [31:0] a_loc;
input [31:0] b_loc;

//////////////////////////////////////////////////////////////////////////
// Logic for clock counting and when to assert done
//////////////////////////////////////////////////////////////////////////

reg done_mat_mul;
// This is set to 31 bits in accordance with the previous simulations.
// In general, a systolic multiplier takes 4*N-2+P cycles, where N is the size 
// of the matmul and P is the number of pipeline stages in the MAC block.
reg [31:0] clk_cnt;

// Finding out number of cycles to assert matmul done.
// When we have to save the outputs to accumulators, then we don't need to
// shift out data. So, we can assert done_mat_mul early.
// Note: the count expression used to contain "num_matrices_16x16*8", but 
// to avoid multiplication, we now use "num_matrices_16x16 << 3"
wire [31:0] clk_cnt_for_done;
assign clk_cnt_for_done = 
((num_matrices_A << (2*`LOG2_MAT_MUL_SIZE -1)) + 1  + `NUM_CYCLES_IN_MAC) ;  

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

wire [`DWIDTH-1:0] a0_data;
wire [`DWIDTH-1:0] a1_data;
wire [`DWIDTH-1:0] a2_data;
wire [`DWIDTH-1:0] a3_data;
wire [`DWIDTH-1:0] a4_data;
wire [`DWIDTH-1:0] a5_data;
wire [`DWIDTH-1:0] a6_data;
wire [`DWIDTH-1:0] a7_data;
wire [`DWIDTH-1:0] a8_data;
wire [`DWIDTH-1:0] a9_data;
wire [`DWIDTH-1:0] a10_data;
wire [`DWIDTH-1:0] a11_data;
wire [`DWIDTH-1:0] a12_data;
wire [`DWIDTH-1:0] a13_data;
wire [`DWIDTH-1:0] a14_data;
wire [`DWIDTH-1:0] a15_data;
wire [`DWIDTH-1:0] b0_data;
wire [`DWIDTH-1:0] b1_data;
wire [`DWIDTH-1:0] b2_data;
wire [`DWIDTH-1:0] b3_data;
wire [`DWIDTH-1:0] b4_data;
wire [`DWIDTH-1:0] b5_data;
wire [`DWIDTH-1:0] b6_data;
wire [`DWIDTH-1:0] b7_data;
wire [`DWIDTH-1:0] b8_data;
wire [`DWIDTH-1:0] b9_data;
wire [`DWIDTH-1:0] b10_data;
wire [`DWIDTH-1:0] b11_data;
wire [`DWIDTH-1:0] b12_data;
wire [`DWIDTH-1:0] b13_data;
wire [`DWIDTH-1:0] b14_data;
wire [`DWIDTH-1:0] b15_data;
wire [`DWIDTH-1:0] a1_data_delayed_1;
wire [`DWIDTH-1:0] a2_data_delayed_1;
wire [`DWIDTH-1:0] a2_data_delayed_2;
wire [`DWIDTH-1:0] a3_data_delayed_1;
wire [`DWIDTH-1:0] a3_data_delayed_2;
wire [`DWIDTH-1:0] a3_data_delayed_3;
wire [`DWIDTH-1:0] a4_data_delayed_1;
wire [`DWIDTH-1:0] a4_data_delayed_2;
wire [`DWIDTH-1:0] a4_data_delayed_3;
wire [`DWIDTH-1:0] a4_data_delayed_4;
wire [`DWIDTH-1:0] a5_data_delayed_1;
wire [`DWIDTH-1:0] a5_data_delayed_2;
wire [`DWIDTH-1:0] a5_data_delayed_3;
wire [`DWIDTH-1:0] a5_data_delayed_4;
wire [`DWIDTH-1:0] a5_data_delayed_5;
wire [`DWIDTH-1:0] a6_data_delayed_1;
wire [`DWIDTH-1:0] a6_data_delayed_2;
wire [`DWIDTH-1:0] a6_data_delayed_3;
wire [`DWIDTH-1:0] a6_data_delayed_4;
wire [`DWIDTH-1:0] a6_data_delayed_5;
wire [`DWIDTH-1:0] a6_data_delayed_6;
wire [`DWIDTH-1:0] a7_data_delayed_1;
wire [`DWIDTH-1:0] a7_data_delayed_2;
wire [`DWIDTH-1:0] a7_data_delayed_3;
wire [`DWIDTH-1:0] a7_data_delayed_4;
wire [`DWIDTH-1:0] a7_data_delayed_5;
wire [`DWIDTH-1:0] a7_data_delayed_6;
wire [`DWIDTH-1:0] a7_data_delayed_7;
wire [`DWIDTH-1:0] a8_data_delayed_1;
wire [`DWIDTH-1:0] a8_data_delayed_2;
wire [`DWIDTH-1:0] a8_data_delayed_3;
wire [`DWIDTH-1:0] a8_data_delayed_4;
wire [`DWIDTH-1:0] a8_data_delayed_5;
wire [`DWIDTH-1:0] a8_data_delayed_6;
wire [`DWIDTH-1:0] a8_data_delayed_7;
wire [`DWIDTH-1:0] a8_data_delayed_8;
wire [`DWIDTH-1:0] a9_data_delayed_1;
wire [`DWIDTH-1:0] a9_data_delayed_2;
wire [`DWIDTH-1:0] a9_data_delayed_3;
wire [`DWIDTH-1:0] a9_data_delayed_4;
wire [`DWIDTH-1:0] a9_data_delayed_5;
wire [`DWIDTH-1:0] a9_data_delayed_6;
wire [`DWIDTH-1:0] a9_data_delayed_7;
wire [`DWIDTH-1:0] a9_data_delayed_8;
wire [`DWIDTH-1:0] a9_data_delayed_9;
wire [`DWIDTH-1:0] a10_data_delayed_1;
wire [`DWIDTH-1:0] a10_data_delayed_2;
wire [`DWIDTH-1:0] a10_data_delayed_3;
wire [`DWIDTH-1:0] a10_data_delayed_4;
wire [`DWIDTH-1:0] a10_data_delayed_5;
wire [`DWIDTH-1:0] a10_data_delayed_6;
wire [`DWIDTH-1:0] a10_data_delayed_7;
wire [`DWIDTH-1:0] a10_data_delayed_8;
wire [`DWIDTH-1:0] a10_data_delayed_9;
wire [`DWIDTH-1:0] a10_data_delayed_10;
wire [`DWIDTH-1:0] a11_data_delayed_1;
wire [`DWIDTH-1:0] a11_data_delayed_2;
wire [`DWIDTH-1:0] a11_data_delayed_3;
wire [`DWIDTH-1:0] a11_data_delayed_4;
wire [`DWIDTH-1:0] a11_data_delayed_5;
wire [`DWIDTH-1:0] a11_data_delayed_6;
wire [`DWIDTH-1:0] a11_data_delayed_7;
wire [`DWIDTH-1:0] a11_data_delayed_8;
wire [`DWIDTH-1:0] a11_data_delayed_9;
wire [`DWIDTH-1:0] a11_data_delayed_10;
wire [`DWIDTH-1:0] a11_data_delayed_11;
wire [`DWIDTH-1:0] a12_data_delayed_1;
wire [`DWIDTH-1:0] a12_data_delayed_2;
wire [`DWIDTH-1:0] a12_data_delayed_3;
wire [`DWIDTH-1:0] a12_data_delayed_4;
wire [`DWIDTH-1:0] a12_data_delayed_5;
wire [`DWIDTH-1:0] a12_data_delayed_6;
wire [`DWIDTH-1:0] a12_data_delayed_7;
wire [`DWIDTH-1:0] a12_data_delayed_8;
wire [`DWIDTH-1:0] a12_data_delayed_9;
wire [`DWIDTH-1:0] a12_data_delayed_10;
wire [`DWIDTH-1:0] a12_data_delayed_11;
wire [`DWIDTH-1:0] a12_data_delayed_12;
wire [`DWIDTH-1:0] a13_data_delayed_1;
wire [`DWIDTH-1:0] a13_data_delayed_2;
wire [`DWIDTH-1:0] a13_data_delayed_3;
wire [`DWIDTH-1:0] a13_data_delayed_4;
wire [`DWIDTH-1:0] a13_data_delayed_5;
wire [`DWIDTH-1:0] a13_data_delayed_6;
wire [`DWIDTH-1:0] a13_data_delayed_7;
wire [`DWIDTH-1:0] a13_data_delayed_8;
wire [`DWIDTH-1:0] a13_data_delayed_9;
wire [`DWIDTH-1:0] a13_data_delayed_10;
wire [`DWIDTH-1:0] a13_data_delayed_11;
wire [`DWIDTH-1:0] a13_data_delayed_12;
wire [`DWIDTH-1:0] a13_data_delayed_13;
wire [`DWIDTH-1:0] a14_data_delayed_1;
wire [`DWIDTH-1:0] a14_data_delayed_2;
wire [`DWIDTH-1:0] a14_data_delayed_3;
wire [`DWIDTH-1:0] a14_data_delayed_4;
wire [`DWIDTH-1:0] a14_data_delayed_5;
wire [`DWIDTH-1:0] a14_data_delayed_6;
wire [`DWIDTH-1:0] a14_data_delayed_7;
wire [`DWIDTH-1:0] a14_data_delayed_8;
wire [`DWIDTH-1:0] a14_data_delayed_9;
wire [`DWIDTH-1:0] a14_data_delayed_10;
wire [`DWIDTH-1:0] a14_data_delayed_11;
wire [`DWIDTH-1:0] a14_data_delayed_12;
wire [`DWIDTH-1:0] a14_data_delayed_13;
wire [`DWIDTH-1:0] a14_data_delayed_14;
wire [`DWIDTH-1:0] a15_data_delayed_1;
wire [`DWIDTH-1:0] a15_data_delayed_2;
wire [`DWIDTH-1:0] a15_data_delayed_3;
wire [`DWIDTH-1:0] a15_data_delayed_4;
wire [`DWIDTH-1:0] a15_data_delayed_5;
wire [`DWIDTH-1:0] a15_data_delayed_6;
wire [`DWIDTH-1:0] a15_data_delayed_7;
wire [`DWIDTH-1:0] a15_data_delayed_8;
wire [`DWIDTH-1:0] a15_data_delayed_9;
wire [`DWIDTH-1:0] a15_data_delayed_10;
wire [`DWIDTH-1:0] a15_data_delayed_11;
wire [`DWIDTH-1:0] a15_data_delayed_12;
wire [`DWIDTH-1:0] a15_data_delayed_13;
wire [`DWIDTH-1:0] a15_data_delayed_14;
wire [`DWIDTH-1:0] a15_data_delayed_15;
wire [`DWIDTH-1:0] b1_data_delayed_1;
wire [`DWIDTH-1:0] b2_data_delayed_1;
wire [`DWIDTH-1:0] b2_data_delayed_2;
wire [`DWIDTH-1:0] b3_data_delayed_1;
wire [`DWIDTH-1:0] b3_data_delayed_2;
wire [`DWIDTH-1:0] b3_data_delayed_3;
wire [`DWIDTH-1:0] b4_data_delayed_1;
wire [`DWIDTH-1:0] b4_data_delayed_2;
wire [`DWIDTH-1:0] b4_data_delayed_3;
wire [`DWIDTH-1:0] b4_data_delayed_4;
wire [`DWIDTH-1:0] b5_data_delayed_1;
wire [`DWIDTH-1:0] b5_data_delayed_2;
wire [`DWIDTH-1:0] b5_data_delayed_3;
wire [`DWIDTH-1:0] b5_data_delayed_4;
wire [`DWIDTH-1:0] b5_data_delayed_5;
wire [`DWIDTH-1:0] b6_data_delayed_1;
wire [`DWIDTH-1:0] b6_data_delayed_2;
wire [`DWIDTH-1:0] b6_data_delayed_3;
wire [`DWIDTH-1:0] b6_data_delayed_4;
wire [`DWIDTH-1:0] b6_data_delayed_5;
wire [`DWIDTH-1:0] b6_data_delayed_6;
wire [`DWIDTH-1:0] b7_data_delayed_1;
wire [`DWIDTH-1:0] b7_data_delayed_2;
wire [`DWIDTH-1:0] b7_data_delayed_3;
wire [`DWIDTH-1:0] b7_data_delayed_4;
wire [`DWIDTH-1:0] b7_data_delayed_5;
wire [`DWIDTH-1:0] b7_data_delayed_6;
wire [`DWIDTH-1:0] b7_data_delayed_7;
wire [`DWIDTH-1:0] b8_data_delayed_1;
wire [`DWIDTH-1:0] b8_data_delayed_2;
wire [`DWIDTH-1:0] b8_data_delayed_3;
wire [`DWIDTH-1:0] b8_data_delayed_4;
wire [`DWIDTH-1:0] b8_data_delayed_5;
wire [`DWIDTH-1:0] b8_data_delayed_6;
wire [`DWIDTH-1:0] b8_data_delayed_7;
wire [`DWIDTH-1:0] b8_data_delayed_8;
wire [`DWIDTH-1:0] b9_data_delayed_1;
wire [`DWIDTH-1:0] b9_data_delayed_2;
wire [`DWIDTH-1:0] b9_data_delayed_3;
wire [`DWIDTH-1:0] b9_data_delayed_4;
wire [`DWIDTH-1:0] b9_data_delayed_5;
wire [`DWIDTH-1:0] b9_data_delayed_6;
wire [`DWIDTH-1:0] b9_data_delayed_7;
wire [`DWIDTH-1:0] b9_data_delayed_8;
wire [`DWIDTH-1:0] b9_data_delayed_9;
wire [`DWIDTH-1:0] b10_data_delayed_1;
wire [`DWIDTH-1:0] b10_data_delayed_2;
wire [`DWIDTH-1:0] b10_data_delayed_3;
wire [`DWIDTH-1:0] b10_data_delayed_4;
wire [`DWIDTH-1:0] b10_data_delayed_5;
wire [`DWIDTH-1:0] b10_data_delayed_6;
wire [`DWIDTH-1:0] b10_data_delayed_7;
wire [`DWIDTH-1:0] b10_data_delayed_8;
wire [`DWIDTH-1:0] b10_data_delayed_9;
wire [`DWIDTH-1:0] b10_data_delayed_10;
wire [`DWIDTH-1:0] b11_data_delayed_1;
wire [`DWIDTH-1:0] b11_data_delayed_2;
wire [`DWIDTH-1:0] b11_data_delayed_3;
wire [`DWIDTH-1:0] b11_data_delayed_4;
wire [`DWIDTH-1:0] b11_data_delayed_5;
wire [`DWIDTH-1:0] b11_data_delayed_6;
wire [`DWIDTH-1:0] b11_data_delayed_7;
wire [`DWIDTH-1:0] b11_data_delayed_8;
wire [`DWIDTH-1:0] b11_data_delayed_9;
wire [`DWIDTH-1:0] b11_data_delayed_10;
wire [`DWIDTH-1:0] b11_data_delayed_11;
wire [`DWIDTH-1:0] b12_data_delayed_1;
wire [`DWIDTH-1:0] b12_data_delayed_2;
wire [`DWIDTH-1:0] b12_data_delayed_3;
wire [`DWIDTH-1:0] b12_data_delayed_4;
wire [`DWIDTH-1:0] b12_data_delayed_5;
wire [`DWIDTH-1:0] b12_data_delayed_6;
wire [`DWIDTH-1:0] b12_data_delayed_7;
wire [`DWIDTH-1:0] b12_data_delayed_8;
wire [`DWIDTH-1:0] b12_data_delayed_9;
wire [`DWIDTH-1:0] b12_data_delayed_10;
wire [`DWIDTH-1:0] b12_data_delayed_11;
wire [`DWIDTH-1:0] b12_data_delayed_12;
wire [`DWIDTH-1:0] b13_data_delayed_1;
wire [`DWIDTH-1:0] b13_data_delayed_2;
wire [`DWIDTH-1:0] b13_data_delayed_3;
wire [`DWIDTH-1:0] b13_data_delayed_4;
wire [`DWIDTH-1:0] b13_data_delayed_5;
wire [`DWIDTH-1:0] b13_data_delayed_6;
wire [`DWIDTH-1:0] b13_data_delayed_7;
wire [`DWIDTH-1:0] b13_data_delayed_8;
wire [`DWIDTH-1:0] b13_data_delayed_9;
wire [`DWIDTH-1:0] b13_data_delayed_10;
wire [`DWIDTH-1:0] b13_data_delayed_11;
wire [`DWIDTH-1:0] b13_data_delayed_12;
wire [`DWIDTH-1:0] b13_data_delayed_13;
wire [`DWIDTH-1:0] b14_data_delayed_1;
wire [`DWIDTH-1:0] b14_data_delayed_2;
wire [`DWIDTH-1:0] b14_data_delayed_3;
wire [`DWIDTH-1:0] b14_data_delayed_4;
wire [`DWIDTH-1:0] b14_data_delayed_5;
wire [`DWIDTH-1:0] b14_data_delayed_6;
wire [`DWIDTH-1:0] b14_data_delayed_7;
wire [`DWIDTH-1:0] b14_data_delayed_8;
wire [`DWIDTH-1:0] b14_data_delayed_9;
wire [`DWIDTH-1:0] b14_data_delayed_10;
wire [`DWIDTH-1:0] b14_data_delayed_11;
wire [`DWIDTH-1:0] b14_data_delayed_12;
wire [`DWIDTH-1:0] b14_data_delayed_13;
wire [`DWIDTH-1:0] b14_data_delayed_14;
wire [`DWIDTH-1:0] b15_data_delayed_1;
wire [`DWIDTH-1:0] b15_data_delayed_2;
wire [`DWIDTH-1:0] b15_data_delayed_3;
wire [`DWIDTH-1:0] b15_data_delayed_4;
wire [`DWIDTH-1:0] b15_data_delayed_5;
wire [`DWIDTH-1:0] b15_data_delayed_6;
wire [`DWIDTH-1:0] b15_data_delayed_7;
wire [`DWIDTH-1:0] b15_data_delayed_8;
wire [`DWIDTH-1:0] b15_data_delayed_9;
wire [`DWIDTH-1:0] b15_data_delayed_10;
wire [`DWIDTH-1:0] b15_data_delayed_11;
wire [`DWIDTH-1:0] b15_data_delayed_12;
wire [`DWIDTH-1:0] b15_data_delayed_13;
wire [`DWIDTH-1:0] b15_data_delayed_14;
wire [`DWIDTH-1:0] b15_data_delayed_15;

reg b_data_sel; // MUX select for Ping-Pong buffers containing the weights in the matmul
reg b_data_valid_ping;
reg b_data_valid_pong;

always @ (posedge clk) begin
	if ((clk_cnt >= 16'd1 && clk_cnt <= 16'd8)||(clk_cnt >= 16'd17 && clk_cnt <= 16'd24))
		b_data_valid_pong <= 1'b1;
	else 
		b_data_valid_pong <= 1'b0;
end

always @ (posedge clk) begin
	if ((clk_cnt >= 16'd9 && clk_cnt <= 16'd16))
		b_data_valid_ping <= 1'b1;
	else 
		b_data_valid_ping <= 1'b0;
end

always @ (posedge clk) begin
	if ((clk_cnt >= 16'd10 && clk_cnt <= 16'd17)||(clk_cnt >= 16'd26 && clk_cnt <= 16'd33))
		b_data_sel <= 1'b1;
	else 
		b_data_sel <= 1'b0;
end

//////////////////////////////////////////////////////////////////////////
// Instantiation of systolic data setup
//////////////////////////////////////////////////////////////////////////
systolic_data_setup u_systolic_data_setup(
    .clk(clk),
    .reset(reset),
    .start_mat_mul(start_mat_mul),
    .a_addr(a_addr),
    .b_addr(b_addr),
    .address_mat_a(address_mat_a),
    .address_mat_b(address_mat_b),
    .address_stride_a(address_stride_a),
    .address_stride_b(address_stride_b),
    .a_data(a_data),
    .b_data(b_data),
    .clk_cnt(clk_cnt),
    .a0_data(a0_data),
    .a1_data_delayed_1(a1_data_delayed_1),
    .a2_data_delayed_2(a2_data_delayed_2),
    .a3_data_delayed_3(a3_data_delayed_3),
    .a4_data_delayed_4(a4_data_delayed_4),
    .a5_data_delayed_5(a5_data_delayed_5),
    .a6_data_delayed_6(a6_data_delayed_6),
    .a7_data_delayed_7(a7_data_delayed_7),
    .a8_data_delayed_8(a8_data_delayed_8),
    .a9_data_delayed_9(a9_data_delayed_9),
    .a10_data_delayed_10(a10_data_delayed_10),
    .a11_data_delayed_11(a11_data_delayed_11),
    .a12_data_delayed_12(a12_data_delayed_12),
    .a13_data_delayed_13(a13_data_delayed_13),
    .a14_data_delayed_14(a14_data_delayed_14),
    .a15_data_delayed_15(a15_data_delayed_15),
    .b0_data(b0_data),
    .b1_data_delayed_1(b1_data_delayed_1),
    .b2_data_delayed_2(b2_data_delayed_2),
    .b3_data_delayed_3(b3_data_delayed_3),
    .b4_data_delayed_4(b4_data_delayed_4),
    .b5_data_delayed_5(b5_data_delayed_5),
    .b6_data_delayed_6(b6_data_delayed_6),
    .b7_data_delayed_7(b7_data_delayed_7),
    .b8_data_delayed_8(b8_data_delayed_8),
    .b9_data_delayed_9(b9_data_delayed_9),
    .b10_data_delayed_10(b10_data_delayed_10),
    .b11_data_delayed_11(b11_data_delayed_11),
    .b12_data_delayed_12(b12_data_delayed_12),
    .b13_data_delayed_13(b13_data_delayed_13),
    .b14_data_delayed_14(b14_data_delayed_14),
    .b15_data_delayed_15(b15_data_delayed_15),
    .validity_mask_a_rows(validity_mask_a_rows),
    .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
    .validity_mask_b_cols(validity_mask_b_cols),
    .num_matrices_A(num_matrices_A),
    .num_matrices_B(num_matrices_B),
    .a_loc(a_loc),
    .b_loc(b_loc)
);

//////////////////////////////////////////////////////////////////////////
// Logic to mux data_in coming from neighboring matmuls
//////////////////////////////////////////////////////////////////////////
wire [`DWIDTH-1:0] a0;
wire [`DWIDTH-1:0] a1;
wire [`DWIDTH-1:0] a2;
wire [`DWIDTH-1:0] a3;
wire [`DWIDTH-1:0] a4;
wire [`DWIDTH-1:0] a5;
wire [`DWIDTH-1:0] a6;
wire [`DWIDTH-1:0] a7;
wire [`DWIDTH-1:0] a8;
wire [`DWIDTH-1:0] a9;
wire [`DWIDTH-1:0] a10;
wire [`DWIDTH-1:0] a11;
wire [`DWIDTH-1:0] a12;
wire [`DWIDTH-1:0] a13;
wire [`DWIDTH-1:0] a14;
wire [`DWIDTH-1:0] a15;
wire [`DWIDTH-1:0] b0;
wire [`DWIDTH-1:0] b1;
wire [`DWIDTH-1:0] b2;
wire [`DWIDTH-1:0] b3;
wire [`DWIDTH-1:0] b4;
wire [`DWIDTH-1:0] b5;
wire [`DWIDTH-1:0] b6;
wire [`DWIDTH-1:0] b7;
wire [`DWIDTH-1:0] b8;
wire [`DWIDTH-1:0] b9;
wire [`DWIDTH-1:0] b10;
wire [`DWIDTH-1:0] b11;
wire [`DWIDTH-1:0] b12;
wire [`DWIDTH-1:0] b13;
wire [`DWIDTH-1:0] b14;
wire [`DWIDTH-1:0] b15;
wire [`DWIDTH-1:0] c0;
wire [`DWIDTH-1:0] c1;
wire [`DWIDTH-1:0] c2;
wire [`DWIDTH-1:0] c3;
wire [`DWIDTH-1:0] c4;
wire [`DWIDTH-1:0] c5;
wire [`DWIDTH-1:0] c6;
wire [`DWIDTH-1:0] c7;
wire [`DWIDTH-1:0] c8;
wire [`DWIDTH-1:0] c9;
wire [`DWIDTH-1:0] c10;
wire [`DWIDTH-1:0] c11;
wire [`DWIDTH-1:0] c12;
wire [`DWIDTH-1:0] c13;
wire [`DWIDTH-1:0] c14;
wire [`DWIDTH-1:0] c15;

wire [`DWIDTH-1:0] a0_data_in;
wire [`DWIDTH-1:0] a1_data_in;
wire [`DWIDTH-1:0] a2_data_in;
wire [`DWIDTH-1:0] a3_data_in;
wire [`DWIDTH-1:0] a4_data_in;
wire [`DWIDTH-1:0] a5_data_in;
wire [`DWIDTH-1:0] a6_data_in;
wire [`DWIDTH-1:0] a7_data_in;
wire [`DWIDTH-1:0] a8_data_in;
wire [`DWIDTH-1:0] a9_data_in;
wire [`DWIDTH-1:0] a10_data_in;
wire [`DWIDTH-1:0] a11_data_in;
wire [`DWIDTH-1:0] a12_data_in;
wire [`DWIDTH-1:0] a13_data_in;
wire [`DWIDTH-1:0] a14_data_in;
wire [`DWIDTH-1:0] a15_data_in;
assign a0_data_in = a_data_in[`DWIDTH-1:0];
assign a1_data_in = a_data_in[2*`DWIDTH-1:1*`DWIDTH];
assign a2_data_in = a_data_in[3*`DWIDTH-1:2*`DWIDTH];
assign a3_data_in = a_data_in[4*`DWIDTH-1:3*`DWIDTH];
assign a4_data_in = a_data_in[5*`DWIDTH-1:4*`DWIDTH];
assign a5_data_in = a_data_in[6*`DWIDTH-1:5*`DWIDTH];
assign a6_data_in = a_data_in[7*`DWIDTH-1:6*`DWIDTH];
assign a7_data_in = a_data_in[8*`DWIDTH-1:7*`DWIDTH];
assign a8_data_in = a_data_in[9*`DWIDTH-1:8*`DWIDTH];
assign a9_data_in = a_data_in[10*`DWIDTH-1:9*`DWIDTH];
assign a10_data_in = a_data_in[11*`DWIDTH-1:10*`DWIDTH];
assign a11_data_in = a_data_in[12*`DWIDTH-1:11*`DWIDTH];
assign a12_data_in = a_data_in[13*`DWIDTH-1:12*`DWIDTH];
assign a13_data_in = a_data_in[14*`DWIDTH-1:13*`DWIDTH];
assign a14_data_in = a_data_in[15*`DWIDTH-1:14*`DWIDTH];
assign a15_data_in = a_data_in[16*`DWIDTH-1:15*`DWIDTH];

wire [`DWIDTH-1:0] b0_data_in;
wire [`DWIDTH-1:0] b1_data_in;
wire [`DWIDTH-1:0] b2_data_in;
wire [`DWIDTH-1:0] b3_data_in;
wire [`DWIDTH-1:0] b4_data_in;
wire [`DWIDTH-1:0] b5_data_in;
wire [`DWIDTH-1:0] b6_data_in;
wire [`DWIDTH-1:0] b7_data_in;
wire [`DWIDTH-1:0] b8_data_in;
wire [`DWIDTH-1:0] b9_data_in;
wire [`DWIDTH-1:0] b10_data_in;
wire [`DWIDTH-1:0] b11_data_in;
wire [`DWIDTH-1:0] b12_data_in;
wire [`DWIDTH-1:0] b13_data_in;
wire [`DWIDTH-1:0] b14_data_in;
wire [`DWIDTH-1:0] b15_data_in;
assign b0_data_in = b_data_in[`DWIDTH-1:0];
assign b1_data_in = b_data_in[2*`DWIDTH-1:1*`DWIDTH];
assign b2_data_in = b_data_in[3*`DWIDTH-1:2*`DWIDTH];
assign b3_data_in = b_data_in[4*`DWIDTH-1:3*`DWIDTH];
assign b4_data_in = b_data_in[5*`DWIDTH-1:4*`DWIDTH];
assign b5_data_in = b_data_in[6*`DWIDTH-1:5*`DWIDTH];
assign b6_data_in = b_data_in[7*`DWIDTH-1:6*`DWIDTH];
assign b7_data_in = b_data_in[8*`DWIDTH-1:7*`DWIDTH];
assign b8_data_in = b_data_in[9*`DWIDTH-1:8*`DWIDTH];
assign b9_data_in = b_data_in[10*`DWIDTH-1:9*`DWIDTH];
assign b10_data_in = b_data_in[11*`DWIDTH-1:10*`DWIDTH];
assign b11_data_in = b_data_in[12*`DWIDTH-1:11*`DWIDTH];
assign b12_data_in = b_data_in[13*`DWIDTH-1:12*`DWIDTH];
assign b13_data_in = b_data_in[14*`DWIDTH-1:13*`DWIDTH];
assign b14_data_in = b_data_in[15*`DWIDTH-1:14*`DWIDTH];
assign b15_data_in = b_data_in[16*`DWIDTH-1:15*`DWIDTH];

// If b_loc is 0, that means this matmul block is on the top-row of the
// final large matmul. In that case, b will take inputs from mem.
// If b_loc != 0, that means this matmul block is not on the top-row of the
// final large matmul. In that case, b will take inputs from the matmul on top
// of this one.
assign a0 = (b_loc==0) ? a0_data           : a0_data_in;
assign a1 = (b_loc==0) ? a1_data_delayed_1 : a1_data_in;
assign a2 = (b_loc==0) ? a2_data_delayed_2 : a2_data_in;
assign a3 = (b_loc==0) ? a3_data_delayed_3 : a3_data_in;
assign a4 = (b_loc==0) ? a4_data_delayed_4 : a4_data_in;
assign a5 = (b_loc==0) ? a5_data_delayed_5 : a5_data_in;
assign a6 = (b_loc==0) ? a6_data_delayed_6 : a6_data_in;
assign a7 = (b_loc==0) ? a7_data_delayed_7 : a7_data_in;
assign a8 = (b_loc==0) ? a8_data_delayed_8 : a8_data_in;
assign a9 = (b_loc==0) ? a9_data_delayed_9 : a9_data_in;
assign a10 = (b_loc==0) ? a10_data_delayed_10 : a10_data_in;
assign a11 = (b_loc==0) ? a11_data_delayed_11 : a11_data_in;
assign a12 = (b_loc==0) ? a12_data_delayed_12 : a12_data_in;
assign a13 = (b_loc==0) ? a13_data_delayed_13 : a13_data_in;
assign a14 = (b_loc==0) ? a14_data_delayed_14 : a14_data_in;
assign a15 = (b_loc==0) ? a15_data_delayed_15 : a15_data_in;

/// If a_loc is 0, that means this matmul block is on the left-col of the
// final large matmul. In that case, a will take inputs from mem.
// If a_loc != 0, that means this matmul block is not on the left-col of the
// final large matmul. In that case, a will take inputs from the matmul on left
// of this one.
assign b0 = (a_loc==0) ? b0_data           : b0_data_in;
assign b1 = (a_loc==0) ? b1_data_delayed_1 : b1_data_in;
assign b2 = (a_loc==0) ? b2_data_delayed_2 : b2_data_in;
assign b3 = (a_loc==0) ? b3_data_delayed_3 : b3_data_in;
assign b4 = (a_loc==0) ? b4_data_delayed_4 : b4_data_in;
assign b5 = (a_loc==0) ? b5_data_delayed_5 : b5_data_in;
assign b6 = (a_loc==0) ? b6_data_delayed_6 : b6_data_in;
assign b7 = (a_loc==0) ? b7_data_delayed_7 : b7_data_in;
assign b8 = (a_loc==0) ? b8_data_delayed_8 : b8_data_in;
assign b9 = (a_loc==0) ? b9_data_delayed_9 : b9_data_in;
assign b10 = (a_loc==0) ? b10_data_delayed_10 : b10_data_in;
assign b11 = (a_loc==0) ? b11_data_delayed_11 : b11_data_in;
assign b12 = (a_loc==0) ? b12_data_delayed_12 : b12_data_in;
assign b13 = (a_loc==0) ? b13_data_delayed_13 : b13_data_in;
assign b14 = (a_loc==0) ? b14_data_delayed_14 : b14_data_in;
assign b15 = (a_loc==0) ? b15_data_delayed_15 : b15_data_in;

assign c0 = c_data_in[`DWIDTH-1:0];
assign c1 = c_data_in[2*`DWIDTH-1:1*`DWIDTH];
assign c2 = c_data_in[3*`DWIDTH-1:2*`DWIDTH];
assign c3 = c_data_in[4*`DWIDTH-1:3*`DWIDTH];
assign c4 = c_data_in[5*`DWIDTH-1:4*`DWIDTH];
assign c5 = c_data_in[6*`DWIDTH-1:5*`DWIDTH];
assign c6 = c_data_in[7*`DWIDTH-1:6*`DWIDTH];
assign c7 = c_data_in[8*`DWIDTH-1:7*`DWIDTH];
assign c8 = c_data_in[9*`DWIDTH-1:8*`DWIDTH];
assign c9 = c_data_in[10*`DWIDTH-1:9*`DWIDTH];
assign c10 = c_data_in[11*`DWIDTH-1:10*`DWIDTH];
assign c11 = c_data_in[12*`DWIDTH-1:11*`DWIDTH];
assign c12 = c_data_in[13*`DWIDTH-1:12*`DWIDTH];
assign c13 = c_data_in[14*`DWIDTH-1:13*`DWIDTH];
assign c14 = c_data_in[15*`DWIDTH-1:14*`DWIDTH];
assign c15 = c_data_in[16*`DWIDTH-1:15*`DWIDTH];

wire [`DWIDTH-1:0] matrixC00;
wire [`DWIDTH-1:0] matrixC01;
wire [`DWIDTH-1:0] matrixC02;
wire [`DWIDTH-1:0] matrixC03;
wire [`DWIDTH-1:0] matrixC04;
wire [`DWIDTH-1:0] matrixC05;
wire [`DWIDTH-1:0] matrixC06;
wire [`DWIDTH-1:0] matrixC07;
wire [`DWIDTH-1:0] matrixC08;
wire [`DWIDTH-1:0] matrixC09;
wire [`DWIDTH-1:0] matrixC010;
wire [`DWIDTH-1:0] matrixC011;
wire [`DWIDTH-1:0] matrixC012;
wire [`DWIDTH-1:0] matrixC013;
wire [`DWIDTH-1:0] matrixC014;
wire [`DWIDTH-1:0] matrixC015;
wire [`DWIDTH-1:0] matrixC10;
wire [`DWIDTH-1:0] matrixC11;
wire [`DWIDTH-1:0] matrixC12;
wire [`DWIDTH-1:0] matrixC13;
wire [`DWIDTH-1:0] matrixC14;
wire [`DWIDTH-1:0] matrixC15;
wire [`DWIDTH-1:0] matrixC16;
wire [`DWIDTH-1:0] matrixC17;
wire [`DWIDTH-1:0] matrixC18;
wire [`DWIDTH-1:0] matrixC19;
wire [`DWIDTH-1:0] matrixC110;
wire [`DWIDTH-1:0] matrixC111;
wire [`DWIDTH-1:0] matrixC112;
wire [`DWIDTH-1:0] matrixC113;
wire [`DWIDTH-1:0] matrixC114;
wire [`DWIDTH-1:0] matrixC115;
wire [`DWIDTH-1:0] matrixC20;
wire [`DWIDTH-1:0] matrixC21;
wire [`DWIDTH-1:0] matrixC22;
wire [`DWIDTH-1:0] matrixC23;
wire [`DWIDTH-1:0] matrixC24;
wire [`DWIDTH-1:0] matrixC25;
wire [`DWIDTH-1:0] matrixC26;
wire [`DWIDTH-1:0] matrixC27;
wire [`DWIDTH-1:0] matrixC28;
wire [`DWIDTH-1:0] matrixC29;
wire [`DWIDTH-1:0] matrixC210;
wire [`DWIDTH-1:0] matrixC211;
wire [`DWIDTH-1:0] matrixC212;
wire [`DWIDTH-1:0] matrixC213;
wire [`DWIDTH-1:0] matrixC214;
wire [`DWIDTH-1:0] matrixC215;
wire [`DWIDTH-1:0] matrixC30;
wire [`DWIDTH-1:0] matrixC31;
wire [`DWIDTH-1:0] matrixC32;
wire [`DWIDTH-1:0] matrixC33;
wire [`DWIDTH-1:0] matrixC34;
wire [`DWIDTH-1:0] matrixC35;
wire [`DWIDTH-1:0] matrixC36;
wire [`DWIDTH-1:0] matrixC37;
wire [`DWIDTH-1:0] matrixC38;
wire [`DWIDTH-1:0] matrixC39;
wire [`DWIDTH-1:0] matrixC310;
wire [`DWIDTH-1:0] matrixC311;
wire [`DWIDTH-1:0] matrixC312;
wire [`DWIDTH-1:0] matrixC313;
wire [`DWIDTH-1:0] matrixC314;
wire [`DWIDTH-1:0] matrixC315;
wire [`DWIDTH-1:0] matrixC40;
wire [`DWIDTH-1:0] matrixC41;
wire [`DWIDTH-1:0] matrixC42;
wire [`DWIDTH-1:0] matrixC43;
wire [`DWIDTH-1:0] matrixC44;
wire [`DWIDTH-1:0] matrixC45;
wire [`DWIDTH-1:0] matrixC46;
wire [`DWIDTH-1:0] matrixC47;
wire [`DWIDTH-1:0] matrixC48;
wire [`DWIDTH-1:0] matrixC49;
wire [`DWIDTH-1:0] matrixC410;
wire [`DWIDTH-1:0] matrixC411;
wire [`DWIDTH-1:0] matrixC412;
wire [`DWIDTH-1:0] matrixC413;
wire [`DWIDTH-1:0] matrixC414;
wire [`DWIDTH-1:0] matrixC415;
wire [`DWIDTH-1:0] matrixC50;
wire [`DWIDTH-1:0] matrixC51;
wire [`DWIDTH-1:0] matrixC52;
wire [`DWIDTH-1:0] matrixC53;
wire [`DWIDTH-1:0] matrixC54;
wire [`DWIDTH-1:0] matrixC55;
wire [`DWIDTH-1:0] matrixC56;
wire [`DWIDTH-1:0] matrixC57;
wire [`DWIDTH-1:0] matrixC58;
wire [`DWIDTH-1:0] matrixC59;
wire [`DWIDTH-1:0] matrixC510;
wire [`DWIDTH-1:0] matrixC511;
wire [`DWIDTH-1:0] matrixC512;
wire [`DWIDTH-1:0] matrixC513;
wire [`DWIDTH-1:0] matrixC514;
wire [`DWIDTH-1:0] matrixC515;
wire [`DWIDTH-1:0] matrixC60;
wire [`DWIDTH-1:0] matrixC61;
wire [`DWIDTH-1:0] matrixC62;
wire [`DWIDTH-1:0] matrixC63;
wire [`DWIDTH-1:0] matrixC64;
wire [`DWIDTH-1:0] matrixC65;
wire [`DWIDTH-1:0] matrixC66;
wire [`DWIDTH-1:0] matrixC67;
wire [`DWIDTH-1:0] matrixC68;
wire [`DWIDTH-1:0] matrixC69;
wire [`DWIDTH-1:0] matrixC610;
wire [`DWIDTH-1:0] matrixC611;
wire [`DWIDTH-1:0] matrixC612;
wire [`DWIDTH-1:0] matrixC613;
wire [`DWIDTH-1:0] matrixC614;
wire [`DWIDTH-1:0] matrixC615;
wire [`DWIDTH-1:0] matrixC70;
wire [`DWIDTH-1:0] matrixC71;
wire [`DWIDTH-1:0] matrixC72;
wire [`DWIDTH-1:0] matrixC73;
wire [`DWIDTH-1:0] matrixC74;
wire [`DWIDTH-1:0] matrixC75;
wire [`DWIDTH-1:0] matrixC76;
wire [`DWIDTH-1:0] matrixC77;
wire [`DWIDTH-1:0] matrixC78;
wire [`DWIDTH-1:0] matrixC79;
wire [`DWIDTH-1:0] matrixC710;
wire [`DWIDTH-1:0] matrixC711;
wire [`DWIDTH-1:0] matrixC712;
wire [`DWIDTH-1:0] matrixC713;
wire [`DWIDTH-1:0] matrixC714;
wire [`DWIDTH-1:0] matrixC715;
wire [`DWIDTH-1:0] matrixC80;
wire [`DWIDTH-1:0] matrixC81;
wire [`DWIDTH-1:0] matrixC82;
wire [`DWIDTH-1:0] matrixC83;
wire [`DWIDTH-1:0] matrixC84;
wire [`DWIDTH-1:0] matrixC85;
wire [`DWIDTH-1:0] matrixC86;
wire [`DWIDTH-1:0] matrixC87;
wire [`DWIDTH-1:0] matrixC88;
wire [`DWIDTH-1:0] matrixC89;
wire [`DWIDTH-1:0] matrixC810;
wire [`DWIDTH-1:0] matrixC811;
wire [`DWIDTH-1:0] matrixC812;
wire [`DWIDTH-1:0] matrixC813;
wire [`DWIDTH-1:0] matrixC814;
wire [`DWIDTH-1:0] matrixC815;
wire [`DWIDTH-1:0] matrixC90;
wire [`DWIDTH-1:0] matrixC91;
wire [`DWIDTH-1:0] matrixC92;
wire [`DWIDTH-1:0] matrixC93;
wire [`DWIDTH-1:0] matrixC94;
wire [`DWIDTH-1:0] matrixC95;
wire [`DWIDTH-1:0] matrixC96;
wire [`DWIDTH-1:0] matrixC97;
wire [`DWIDTH-1:0] matrixC98;
wire [`DWIDTH-1:0] matrixC99;
wire [`DWIDTH-1:0] matrixC910;
wire [`DWIDTH-1:0] matrixC911;
wire [`DWIDTH-1:0] matrixC912;
wire [`DWIDTH-1:0] matrixC913;
wire [`DWIDTH-1:0] matrixC914;
wire [`DWIDTH-1:0] matrixC915;
wire [`DWIDTH-1:0] matrixC100;
wire [`DWIDTH-1:0] matrixC101;
wire [`DWIDTH-1:0] matrixC102;
wire [`DWIDTH-1:0] matrixC103;
wire [`DWIDTH-1:0] matrixC104;
wire [`DWIDTH-1:0] matrixC105;
wire [`DWIDTH-1:0] matrixC106;
wire [`DWIDTH-1:0] matrixC107;
wire [`DWIDTH-1:0] matrixC108;
wire [`DWIDTH-1:0] matrixC109;
wire [`DWIDTH-1:0] matrixC1010;
wire [`DWIDTH-1:0] matrixC1011;
wire [`DWIDTH-1:0] matrixC1012;
wire [`DWIDTH-1:0] matrixC1013;
wire [`DWIDTH-1:0] matrixC1014;
wire [`DWIDTH-1:0] matrixC1015;
wire [`DWIDTH-1:0] matrixC110;
wire [`DWIDTH-1:0] matrixC111;
wire [`DWIDTH-1:0] matrixC112;
wire [`DWIDTH-1:0] matrixC113;
wire [`DWIDTH-1:0] matrixC114;
wire [`DWIDTH-1:0] matrixC115;
wire [`DWIDTH-1:0] matrixC116;
wire [`DWIDTH-1:0] matrixC117;
wire [`DWIDTH-1:0] matrixC118;
wire [`DWIDTH-1:0] matrixC119;
wire [`DWIDTH-1:0] matrixC1110;
wire [`DWIDTH-1:0] matrixC1111;
wire [`DWIDTH-1:0] matrixC1112;
wire [`DWIDTH-1:0] matrixC1113;
wire [`DWIDTH-1:0] matrixC1114;
wire [`DWIDTH-1:0] matrixC1115;
wire [`DWIDTH-1:0] matrixC120;
wire [`DWIDTH-1:0] matrixC121;
wire [`DWIDTH-1:0] matrixC122;
wire [`DWIDTH-1:0] matrixC123;
wire [`DWIDTH-1:0] matrixC124;
wire [`DWIDTH-1:0] matrixC125;
wire [`DWIDTH-1:0] matrixC126;
wire [`DWIDTH-1:0] matrixC127;
wire [`DWIDTH-1:0] matrixC128;
wire [`DWIDTH-1:0] matrixC129;
wire [`DWIDTH-1:0] matrixC1210;
wire [`DWIDTH-1:0] matrixC1211;
wire [`DWIDTH-1:0] matrixC1212;
wire [`DWIDTH-1:0] matrixC1213;
wire [`DWIDTH-1:0] matrixC1214;
wire [`DWIDTH-1:0] matrixC1215;
wire [`DWIDTH-1:0] matrixC130;
wire [`DWIDTH-1:0] matrixC131;
wire [`DWIDTH-1:0] matrixC132;
wire [`DWIDTH-1:0] matrixC133;
wire [`DWIDTH-1:0] matrixC134;
wire [`DWIDTH-1:0] matrixC135;
wire [`DWIDTH-1:0] matrixC136;
wire [`DWIDTH-1:0] matrixC137;
wire [`DWIDTH-1:0] matrixC138;
wire [`DWIDTH-1:0] matrixC139;
wire [`DWIDTH-1:0] matrixC1310;
wire [`DWIDTH-1:0] matrixC1311;
wire [`DWIDTH-1:0] matrixC1312;
wire [`DWIDTH-1:0] matrixC1313;
wire [`DWIDTH-1:0] matrixC1314;
wire [`DWIDTH-1:0] matrixC1315;
wire [`DWIDTH-1:0] matrixC140;
wire [`DWIDTH-1:0] matrixC141;
wire [`DWIDTH-1:0] matrixC142;
wire [`DWIDTH-1:0] matrixC143;
wire [`DWIDTH-1:0] matrixC144;
wire [`DWIDTH-1:0] matrixC145;
wire [`DWIDTH-1:0] matrixC146;
wire [`DWIDTH-1:0] matrixC147;
wire [`DWIDTH-1:0] matrixC148;
wire [`DWIDTH-1:0] matrixC149;
wire [`DWIDTH-1:0] matrixC1410;
wire [`DWIDTH-1:0] matrixC1411;
wire [`DWIDTH-1:0] matrixC1412;
wire [`DWIDTH-1:0] matrixC1413;
wire [`DWIDTH-1:0] matrixC1414;
wire [`DWIDTH-1:0] matrixC1415;
wire [`DWIDTH-1:0] matrixC150;
wire [`DWIDTH-1:0] matrixC151;
wire [`DWIDTH-1:0] matrixC152;
wire [`DWIDTH-1:0] matrixC153;
wire [`DWIDTH-1:0] matrixC154;
wire [`DWIDTH-1:0] matrixC155;
wire [`DWIDTH-1:0] matrixC156;
wire [`DWIDTH-1:0] matrixC157;
wire [`DWIDTH-1:0] matrixC158;
wire [`DWIDTH-1:0] matrixC159;
wire [`DWIDTH-1:0] matrixC1510;
wire [`DWIDTH-1:0] matrixC1511;
wire [`DWIDTH-1:0] matrixC1512;
wire [`DWIDTH-1:0] matrixC1513;
wire [`DWIDTH-1:0] matrixC1514;
wire [`DWIDTH-1:0] matrixC1515;

//////////////////////////////////////////////////////////////////////////
// Instantiations of the actual PEs
//////////////////////////////////////////////////////////////////////////
systolic_pe_matrix u_systolic_pe_matrix(
    .reset(reset),
    .clk(clk),
    .pe_reset(pe_reset),
    .start_mat_mul(start_mat_mul),
    .b_data_sel(b_data_sel),
    .b_data_valid_ping(b_data_valid_ping), 
    .b_data_valid_pong(b_data_valid_pong),
    .a0(a0),
    .a1(a1),
    .a2(a2),
    .a3(a3),
    .a4(a4),
    .a5(a5),
    .a6(a6),
    .a7(a7),
    .a8(a8),
    .a9(a9),
    .a10(a10),
    .a11(a11),
    .a12(a12),
    .a13(a13),
    .a14(a14),
    .a15(a15),
    .b0(b0),
    .b1(b1),
    .b2(b2),
    .b3(b3),
    .b4(b4),
    .b5(b5),
    .b6(b6),
    .b7(b7),
    .b8(b8),
    .b9(b9),
    .b10(b10),
    .b11(b11),
    .b12(b12),
    .b13(b13),
    .b14(b14),
    .b15(b15),
    .c0(c0),
    .c1(c1),
    .c2(c2),
    .c3(c3),
    .c4(c4),
    .c5(c5),
    .c6(c6),
    .c7(c7),
    .c8(c8),
    .c9(c9),
    .c10(c10),
    .c11(c11),
    .c12(c12),
    .c13(c13),
    .c14(c14),
    .c15(c15),
    .matrixC00(matrixC00),
    .matrixC01(matrixC01),
    .matrixC02(matrixC02),
    .matrixC03(matrixC03),
    .matrixC04(matrixC04),
    .matrixC05(matrixC05),
    .matrixC06(matrixC06),
    .matrixC07(matrixC07),
    .matrixC08(matrixC08),
    .matrixC09(matrixC09),
    .matrixC010(matrixC010),
    .matrixC011(matrixC011),
    .matrixC012(matrixC012),
    .matrixC013(matrixC013),
    .matrixC014(matrixC014),
    .matrixC015(matrixC015),
    .matrixC10(matrixC10),
    .matrixC11(matrixC11),
    .matrixC12(matrixC12),
    .matrixC13(matrixC13),
    .matrixC14(matrixC14),
    .matrixC15(matrixC15),
    .matrixC16(matrixC16),
    .matrixC17(matrixC17),
    .matrixC18(matrixC18),
    .matrixC19(matrixC19),
    .matrixC110(matrixC110),
    .matrixC111(matrixC111),
    .matrixC112(matrixC112),
    .matrixC113(matrixC113),
    .matrixC114(matrixC114),
    .matrixC115(matrixC115),
    .matrixC20(matrixC20),
    .matrixC21(matrixC21),
    .matrixC22(matrixC22),
    .matrixC23(matrixC23),
    .matrixC24(matrixC24),
    .matrixC25(matrixC25),
    .matrixC26(matrixC26),
    .matrixC27(matrixC27),
    .matrixC28(matrixC28),
    .matrixC29(matrixC29),
    .matrixC210(matrixC210),
    .matrixC211(matrixC211),
    .matrixC212(matrixC212),
    .matrixC213(matrixC213),
    .matrixC214(matrixC214),
    .matrixC215(matrixC215),
    .matrixC30(matrixC30),
    .matrixC31(matrixC31),
    .matrixC32(matrixC32),
    .matrixC33(matrixC33),
    .matrixC34(matrixC34),
    .matrixC35(matrixC35),
    .matrixC36(matrixC36),
    .matrixC37(matrixC37),
    .matrixC38(matrixC38),
    .matrixC39(matrixC39),
    .matrixC310(matrixC310),
    .matrixC311(matrixC311),
    .matrixC312(matrixC312),
    .matrixC313(matrixC313),
    .matrixC314(matrixC314),
    .matrixC315(matrixC315),
    .matrixC40(matrixC40),
    .matrixC41(matrixC41),
    .matrixC42(matrixC42),
    .matrixC43(matrixC43),
    .matrixC44(matrixC44),
    .matrixC45(matrixC45),
    .matrixC46(matrixC46),
    .matrixC47(matrixC47),
    .matrixC48(matrixC48),
    .matrixC49(matrixC49),
    .matrixC410(matrixC410),
    .matrixC411(matrixC411),
    .matrixC412(matrixC412),
    .matrixC413(matrixC413),
    .matrixC414(matrixC414),
    .matrixC415(matrixC415),
    .matrixC50(matrixC50),
    .matrixC51(matrixC51),
    .matrixC52(matrixC52),
    .matrixC53(matrixC53),
    .matrixC54(matrixC54),
    .matrixC55(matrixC55),
    .matrixC56(matrixC56),
    .matrixC57(matrixC57),
    .matrixC58(matrixC58),
    .matrixC59(matrixC59),
    .matrixC510(matrixC510),
    .matrixC511(matrixC511),
    .matrixC512(matrixC512),
    .matrixC513(matrixC513),
    .matrixC514(matrixC514),
    .matrixC515(matrixC515),
    .matrixC60(matrixC60),
    .matrixC61(matrixC61),
    .matrixC62(matrixC62),
    .matrixC63(matrixC63),
    .matrixC64(matrixC64),
    .matrixC65(matrixC65),
    .matrixC66(matrixC66),
    .matrixC67(matrixC67),
    .matrixC68(matrixC68),
    .matrixC69(matrixC69),
    .matrixC610(matrixC610),
    .matrixC611(matrixC611),
    .matrixC612(matrixC612),
    .matrixC613(matrixC613),
    .matrixC614(matrixC614),
    .matrixC615(matrixC615),
    .matrixC70(matrixC70),
    .matrixC71(matrixC71),
    .matrixC72(matrixC72),
    .matrixC73(matrixC73),
    .matrixC74(matrixC74),
    .matrixC75(matrixC75),
    .matrixC76(matrixC76),
    .matrixC77(matrixC77),
    .matrixC78(matrixC78),
    .matrixC79(matrixC79),
    .matrixC710(matrixC710),
    .matrixC711(matrixC711),
    .matrixC712(matrixC712),
    .matrixC713(matrixC713),
    .matrixC714(matrixC714),
    .matrixC715(matrixC715),
    .matrixC80(matrixC80),
    .matrixC81(matrixC81),
    .matrixC82(matrixC82),
    .matrixC83(matrixC83),
    .matrixC84(matrixC84),
    .matrixC85(matrixC85),
    .matrixC86(matrixC86),
    .matrixC87(matrixC87),
    .matrixC88(matrixC88),
    .matrixC89(matrixC89),
    .matrixC810(matrixC810),
    .matrixC811(matrixC811),
    .matrixC812(matrixC812),
    .matrixC813(matrixC813),
    .matrixC814(matrixC814),
    .matrixC815(matrixC815),
    .matrixC90(matrixC90),
    .matrixC91(matrixC91),
    .matrixC92(matrixC92),
    .matrixC93(matrixC93),
    .matrixC94(matrixC94),
    .matrixC95(matrixC95),
    .matrixC96(matrixC96),
    .matrixC97(matrixC97),
    .matrixC98(matrixC98),
    .matrixC99(matrixC99),
    .matrixC910(matrixC910),
    .matrixC911(matrixC911),
    .matrixC912(matrixC912),
    .matrixC913(matrixC913),
    .matrixC914(matrixC914),
    .matrixC915(matrixC915),
    .matrixC100(matrixC100),
    .matrixC101(matrixC101),
    .matrixC102(matrixC102),
    .matrixC103(matrixC103),
    .matrixC104(matrixC104),
    .matrixC105(matrixC105),
    .matrixC106(matrixC106),
    .matrixC107(matrixC107),
    .matrixC108(matrixC108),
    .matrixC109(matrixC109),
    .matrixC1010(matrixC1010),
    .matrixC1011(matrixC1011),
    .matrixC1012(matrixC1012),
    .matrixC1013(matrixC1013),
    .matrixC1014(matrixC1014),
    .matrixC1015(matrixC1015),
    .matrixC110(matrixC110),
    .matrixC111(matrixC111),
    .matrixC112(matrixC112),
    .matrixC113(matrixC113),
    .matrixC114(matrixC114),
    .matrixC115(matrixC115),
    .matrixC116(matrixC116),
    .matrixC117(matrixC117),
    .matrixC118(matrixC118),
    .matrixC119(matrixC119),
    .matrixC1110(matrixC1110),
    .matrixC1111(matrixC1111),
    .matrixC1112(matrixC1112),
    .matrixC1113(matrixC1113),
    .matrixC1114(matrixC1114),
    .matrixC1115(matrixC1115),
    .matrixC120(matrixC120),
    .matrixC121(matrixC121),
    .matrixC122(matrixC122),
    .matrixC123(matrixC123),
    .matrixC124(matrixC124),
    .matrixC125(matrixC125),
    .matrixC126(matrixC126),
    .matrixC127(matrixC127),
    .matrixC128(matrixC128),
    .matrixC129(matrixC129),
    .matrixC1210(matrixC1210),
    .matrixC1211(matrixC1211),
    .matrixC1212(matrixC1212),
    .matrixC1213(matrixC1213),
    .matrixC1214(matrixC1214),
    .matrixC1215(matrixC1215),
    .matrixC130(matrixC130),
    .matrixC131(matrixC131),
    .matrixC132(matrixC132),
    .matrixC133(matrixC133),
    .matrixC134(matrixC134),
    .matrixC135(matrixC135),
    .matrixC136(matrixC136),
    .matrixC137(matrixC137),
    .matrixC138(matrixC138),
    .matrixC139(matrixC139),
    .matrixC1310(matrixC1310),
    .matrixC1311(matrixC1311),
    .matrixC1312(matrixC1312),
    .matrixC1313(matrixC1313),
    .matrixC1314(matrixC1314),
    .matrixC1315(matrixC1315),
    .matrixC140(matrixC140),
    .matrixC141(matrixC141),
    .matrixC142(matrixC142),
    .matrixC143(matrixC143),
    .matrixC144(matrixC144),
    .matrixC145(matrixC145),
    .matrixC146(matrixC146),
    .matrixC147(matrixC147),
    .matrixC148(matrixC148),
    .matrixC149(matrixC149),
    .matrixC1410(matrixC1410),
    .matrixC1411(matrixC1411),
    .matrixC1412(matrixC1412),
    .matrixC1413(matrixC1413),
    .matrixC1414(matrixC1414),
    .matrixC1415(matrixC1415),
    .matrixC150(matrixC150),
    .matrixC151(matrixC151),
    .matrixC152(matrixC152),
    .matrixC153(matrixC153),
    .matrixC154(matrixC154),
    .matrixC155(matrixC155),
    .matrixC156(matrixC156),
    .matrixC157(matrixC157),
    .matrixC158(matrixC158),
    .matrixC159(matrixC159),
    .matrixC1510(matrixC1510),
    .matrixC1511(matrixC1511),
    .matrixC1512(matrixC1512),
    .matrixC1513(matrixC1513),
    .matrixC1514(matrixC1514),
    .matrixC1515(matrixC1515),
    .a_data_out(a_data_out),
    .b_data_out(b_data_out)
);
  
wire c_data_available;
  
assign c_data_available = (clk_cnt > (`LOG2_MAT_MUL_SIZE-1+(`MAT_MUL_SIZE << 1)) & clk_cnt <= ((`LOG2_MAT_MUL_SIZE+(`MAT_MUL_SIZE << 1)) + (num_matrices_A << `LOG2_MAT_MUL_SIZE)-1));

endmodule

//////////////////////////////////////////////////////////////////////////
// Systolic data setup
//////////////////////////////////////////////////////////////////////////
module systolic_data_setup(
    clk,
    reset,
    start_mat_mul,
    a_addr,
    b_addr,
    address_mat_a,
    address_mat_b,
    address_stride_a,
    address_stride_b,
    a_data,
    b_data,
    clk_cnt,
    a0_data,
    a1_data_delayed_1,
    a2_data_delayed_2,
    a3_data_delayed_3,
    a4_data_delayed_4,
    a5_data_delayed_5,
    a6_data_delayed_6,
    a7_data_delayed_7,
    a8_data_delayed_8,
    a9_data_delayed_9,
    a10_data_delayed_10,
    a11_data_delayed_11,
    a12_data_delayed_12,
    a13_data_delayed_13,
    a14_data_delayed_14,
    a15_data_delayed_15,
    b0_data,
    b1_data_delayed_1,
    b2_data_delayed_2,
    b3_data_delayed_3,
    b4_data_delayed_4,
    b5_data_delayed_5,
    b6_data_delayed_6,
    b7_data_delayed_7,
    b8_data_delayed_8,
    b9_data_delayed_9,
    b10_data_delayed_10,
    b11_data_delayed_11,
    b12_data_delayed_12,
    b13_data_delayed_13,
    b14_data_delayed_14,
    b15_data_delayed_15,
    validity_mask_a_rows,
    validity_mask_a_cols_b_rows,
    validity_mask_b_cols,
    num_matrices_A,
    num_matrices_B,
    a_loc,
    b_loc 
);

input clk;
input reset;
input start_mat_mul;
output [`AWIDTH-1:0] a_addr;
output [`AWIDTH-1:0] b_addr;
input [`AWIDTH-1:0] address_mat_a;
input [`AWIDTH-1:0] address_mat_b;
input [`ADDR_STRIDE_WIDTH-1:0] address_stride_a;
input [`ADDR_STRIDE_WIDTH-1:0] address_stride_b;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data;
input [31:0] clk_cnt;
output [`DWIDTH-1:0] a0_data;
output [`DWIDTH-1:0] a1_data_delayed_1;
output [`DWIDTH-1:0] a2_data_delayed_2;
output [`DWIDTH-1:0] a3_data_delayed_3;
output [`DWIDTH-1:0] a4_data_delayed_4;
output [`DWIDTH-1:0] a5_data_delayed_5;
output [`DWIDTH-1:0] a6_data_delayed_6;
output [`DWIDTH-1:0] a7_data_delayed_7;
output [`DWIDTH-1:0] a8_data_delayed_8;
output [`DWIDTH-1:0] a9_data_delayed_9;
output [`DWIDTH-1:0] a10_data_delayed_10;
output [`DWIDTH-1:0] a11_data_delayed_11;
output [`DWIDTH-1:0] a12_data_delayed_12;
output [`DWIDTH-1:0] a13_data_delayed_13;
output [`DWIDTH-1:0] a14_data_delayed_14;
output [`DWIDTH-1:0] a15_data_delayed_15;
output [`DWIDTH-1:0] b0_data;
output [`DWIDTH-1:0] b1_data_delayed_1;
output [`DWIDTH-1:0] b2_data_delayed_2;
output [`DWIDTH-1:0] b3_data_delayed_3;
output [`DWIDTH-1:0] b4_data_delayed_4;
output [`DWIDTH-1:0] b5_data_delayed_5;
output [`DWIDTH-1:0] b6_data_delayed_6;
output [`DWIDTH-1:0] b7_data_delayed_7;
output [`DWIDTH-1:0] b8_data_delayed_8;
output [`DWIDTH-1:0] b9_data_delayed_9;
output [`DWIDTH-1:0] b10_data_delayed_10;
output [`DWIDTH-1:0] b11_data_delayed_11;
output [`DWIDTH-1:0] b12_data_delayed_12;
output [`DWIDTH-1:0] b13_data_delayed_13;
output [`DWIDTH-1:0] b14_data_delayed_14;
output [`DWIDTH-1:0] b15_data_delayed_15;
input [`MASK_WIDTH-1:0] validity_mask_a_rows;
input [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows;
input [`MASK_WIDTH-1:0] validity_mask_b_cols;
input [31:0] num_matrices_A;
input [31:0] num_matrices_B;
input [31:0] a_loc;
input [31:0] b_loc;

wire [`DWIDTH-1:0] a0_data;
wire [`DWIDTH-1:0] a1_data;
wire [`DWIDTH-1:0] a2_data;
wire [`DWIDTH-1:0] a3_data;
wire [`DWIDTH-1:0] a4_data;
wire [`DWIDTH-1:0] a5_data;
wire [`DWIDTH-1:0] a6_data;
wire [`DWIDTH-1:0] a7_data;
wire [`DWIDTH-1:0] a8_data;
wire [`DWIDTH-1:0] a9_data;
wire [`DWIDTH-1:0] a10_data;
wire [`DWIDTH-1:0] a11_data;
wire [`DWIDTH-1:0] a12_data;
wire [`DWIDTH-1:0] a13_data;
wire [`DWIDTH-1:0] a14_data;
wire [`DWIDTH-1:0] a15_data;
wire [`DWIDTH-1:0] b0_data;
wire [`DWIDTH-1:0] b1_data;
wire [`DWIDTH-1:0] b2_data;
wire [`DWIDTH-1:0] b3_data;
wire [`DWIDTH-1:0] b4_data;
wire [`DWIDTH-1:0] b5_data;
wire [`DWIDTH-1:0] b6_data;
wire [`DWIDTH-1:0] b7_data;
wire [`DWIDTH-1:0] b8_data;
wire [`DWIDTH-1:0] b9_data;
wire [`DWIDTH-1:0] b10_data;
wire [`DWIDTH-1:0] b11_data;
wire [`DWIDTH-1:0] b12_data;
wire [`DWIDTH-1:0] b13_data;
wire [`DWIDTH-1:0] b14_data;
wire [`DWIDTH-1:0] b15_data;

wire a_data_valid; // flag that tells whether the data from memory is valid
wire b_data_valid; // flag that tells whether the data from memory is valid

//////////////////////////////////////////////////////////////////////////
// Logic to generate addresses to BRAM A
//////////////////////////////////////////////////////////////////////////

reg [`AWIDTH-1:0] a_addr;
reg a_mem_access; // flag that tells whether the matmul is trying to access memory or not
  
always @(posedge clk) begin     
if ((reset || ~start_mat_mul) || (clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)+`MAT_MUL_SIZE+(num_matrices_A << `LOG2_MAT_MUL_SIZE))) begin
        a_addr <= address_mat_a-address_stride_a;
        a_mem_access <= 0; 
end
else if ((clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)+`MAT_MUL_SIZE) && (clk_cnt < (a_loc<<`LOG2_MAT_MUL_SIZE)+`MAT_MUL_SIZE+(num_matrices_A << `LOG2_MAT_MUL_SIZE))) begin
        a_addr <= a_addr + address_stride_a;
        a_mem_access <= 1;
end
end


//////////////////////////////////////////////////////////////////////////
// Logic to generate valid signals for data coming from BRAM A
//////////////////////////////////////////////////////////////////////////

reg [31:0] a_mem_access_counter;

always @(posedge clk) begin
    if (reset || ~start_mat_mul) begin
        a_mem_access_counter <= 0;
    end
    else if (a_mem_access == 1) begin
        a_mem_access_counter <= a_mem_access_counter + 1;  
    end
    else begin
        a_mem_access_counter <= 0;
    end
end
  
assign a_data_valid = 
       ((validity_mask_a_cols_b_rows[0]==1'b0 && a_mem_access_counter==1) ||
        (validity_mask_a_cols_b_rows[1]==1'b0 && a_mem_access_counter==2) ||
        (validity_mask_a_cols_b_rows[2]==1'b0 && a_mem_access_counter==3) ||
        (validity_mask_a_cols_b_rows[3]==1'b0 && a_mem_access_counter==4) ||
        (validity_mask_a_cols_b_rows[4]==1'b0 && a_mem_access_counter==5) ||
        (validity_mask_a_cols_b_rows[5]==1'b0 && a_mem_access_counter==6) ||
        (validity_mask_a_cols_b_rows[6]==1'b0 && a_mem_access_counter==7) ||
        (validity_mask_a_cols_b_rows[7]==1'b0 && a_mem_access_counter==8) ||
        (validity_mask_a_cols_b_rows[8]==1'b0 && a_mem_access_counter==9) ||
        (validity_mask_a_cols_b_rows[9]==1'b0 && a_mem_access_counter==10) ||
        (validity_mask_a_cols_b_rows[10]==1'b0 && a_mem_access_counter==11) ||
        (validity_mask_a_cols_b_rows[11]==1'b0 && a_mem_access_counter==12) ||
        (validity_mask_a_cols_b_rows[12]==1'b0 && a_mem_access_counter==13) ||
        (validity_mask_a_cols_b_rows[13]==1'b0 && a_mem_access_counter==14) ||
        (validity_mask_a_cols_b_rows[14]==1'b0 && a_mem_access_counter==15) ||
        (validity_mask_a_cols_b_rows[15]==1'b0 && a_mem_access_counter==16)) ?
        1'b0 : (a_mem_access_counter >= `MEM_ACCESS_LATENCY);

//////////////////////////////////////////////////////////////////////////
// Logic to delay certain parts of the data received from BRAM A (systolic data setup)
//////////////////////////////////////////////////////////////////////////

// Slice data into chunks and qualify it with whether it is valid or not
assign a0_data = a_data[`DWIDTH-1:0] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[0]}};
assign a1_data = a_data[2*`DWIDTH-1:1*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[1]}};
assign a2_data = a_data[3*`DWIDTH-1:2*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[2]}};
assign a3_data = a_data[4*`DWIDTH-1:3*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[3]}};
assign a4_data = a_data[5*`DWIDTH-1:4*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[4]}};
assign a5_data = a_data[6*`DWIDTH-1:5*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[5]}};
assign a6_data = a_data[7*`DWIDTH-1:6*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[6]}};
assign a7_data = a_data[8*`DWIDTH-1:7*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[7]}};
assign a8_data = a_data[9*`DWIDTH-1:8*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[8]}};
assign a9_data = a_data[10*`DWIDTH-1:9*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[9]}};
assign a10_data = a_data[11*`DWIDTH-1:10*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[10]}};
assign a11_data = a_data[12*`DWIDTH-1:11*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[11]}};
assign a12_data = a_data[13*`DWIDTH-1:12*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[12]}};
assign a13_data = a_data[14*`DWIDTH-1:13*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[13]}};
assign a14_data = a_data[15*`DWIDTH-1:14*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[14]}};
assign a15_data = a_data[16*`DWIDTH-1:15*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[15]}};

// For larger matmuls, more such delaying flops will be needed
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
reg [`DWIDTH-1:0] a8_data_delayed_1;
reg [`DWIDTH-1:0] a8_data_delayed_2;
reg [`DWIDTH-1:0] a8_data_delayed_3;
reg [`DWIDTH-1:0] a8_data_delayed_4;
reg [`DWIDTH-1:0] a8_data_delayed_5;
reg [`DWIDTH-1:0] a8_data_delayed_6;
reg [`DWIDTH-1:0] a8_data_delayed_7;
reg [`DWIDTH-1:0] a8_data_delayed_8;
reg [`DWIDTH-1:0] a9_data_delayed_1;
reg [`DWIDTH-1:0] a9_data_delayed_2;
reg [`DWIDTH-1:0] a9_data_delayed_3;
reg [`DWIDTH-1:0] a9_data_delayed_4;
reg [`DWIDTH-1:0] a9_data_delayed_5;
reg [`DWIDTH-1:0] a9_data_delayed_6;
reg [`DWIDTH-1:0] a9_data_delayed_7;
reg [`DWIDTH-1:0] a9_data_delayed_8;
reg [`DWIDTH-1:0] a9_data_delayed_9;
reg [`DWIDTH-1:0] a10_data_delayed_1;
reg [`DWIDTH-1:0] a10_data_delayed_2;
reg [`DWIDTH-1:0] a10_data_delayed_3;
reg [`DWIDTH-1:0] a10_data_delayed_4;
reg [`DWIDTH-1:0] a10_data_delayed_5;
reg [`DWIDTH-1:0] a10_data_delayed_6;
reg [`DWIDTH-1:0] a10_data_delayed_7;
reg [`DWIDTH-1:0] a10_data_delayed_8;
reg [`DWIDTH-1:0] a10_data_delayed_9;
reg [`DWIDTH-1:0] a10_data_delayed_10;
reg [`DWIDTH-1:0] a11_data_delayed_1;
reg [`DWIDTH-1:0] a11_data_delayed_2;
reg [`DWIDTH-1:0] a11_data_delayed_3;
reg [`DWIDTH-1:0] a11_data_delayed_4;
reg [`DWIDTH-1:0] a11_data_delayed_5;
reg [`DWIDTH-1:0] a11_data_delayed_6;
reg [`DWIDTH-1:0] a11_data_delayed_7;
reg [`DWIDTH-1:0] a11_data_delayed_8;
reg [`DWIDTH-1:0] a11_data_delayed_9;
reg [`DWIDTH-1:0] a11_data_delayed_10;
reg [`DWIDTH-1:0] a11_data_delayed_11;
reg [`DWIDTH-1:0] a12_data_delayed_1;
reg [`DWIDTH-1:0] a12_data_delayed_2;
reg [`DWIDTH-1:0] a12_data_delayed_3;
reg [`DWIDTH-1:0] a12_data_delayed_4;
reg [`DWIDTH-1:0] a12_data_delayed_5;
reg [`DWIDTH-1:0] a12_data_delayed_6;
reg [`DWIDTH-1:0] a12_data_delayed_7;
reg [`DWIDTH-1:0] a12_data_delayed_8;
reg [`DWIDTH-1:0] a12_data_delayed_9;
reg [`DWIDTH-1:0] a12_data_delayed_10;
reg [`DWIDTH-1:0] a12_data_delayed_11;
reg [`DWIDTH-1:0] a12_data_delayed_12;
reg [`DWIDTH-1:0] a13_data_delayed_1;
reg [`DWIDTH-1:0] a13_data_delayed_2;
reg [`DWIDTH-1:0] a13_data_delayed_3;
reg [`DWIDTH-1:0] a13_data_delayed_4;
reg [`DWIDTH-1:0] a13_data_delayed_5;
reg [`DWIDTH-1:0] a13_data_delayed_6;
reg [`DWIDTH-1:0] a13_data_delayed_7;
reg [`DWIDTH-1:0] a13_data_delayed_8;
reg [`DWIDTH-1:0] a13_data_delayed_9;
reg [`DWIDTH-1:0] a13_data_delayed_10;
reg [`DWIDTH-1:0] a13_data_delayed_11;
reg [`DWIDTH-1:0] a13_data_delayed_12;
reg [`DWIDTH-1:0] a13_data_delayed_13;
reg [`DWIDTH-1:0] a14_data_delayed_1;
reg [`DWIDTH-1:0] a14_data_delayed_2;
reg [`DWIDTH-1:0] a14_data_delayed_3;
reg [`DWIDTH-1:0] a14_data_delayed_4;
reg [`DWIDTH-1:0] a14_data_delayed_5;
reg [`DWIDTH-1:0] a14_data_delayed_6;
reg [`DWIDTH-1:0] a14_data_delayed_7;
reg [`DWIDTH-1:0] a14_data_delayed_8;
reg [`DWIDTH-1:0] a14_data_delayed_9;
reg [`DWIDTH-1:0] a14_data_delayed_10;
reg [`DWIDTH-1:0] a14_data_delayed_11;
reg [`DWIDTH-1:0] a14_data_delayed_12;
reg [`DWIDTH-1:0] a14_data_delayed_13;
reg [`DWIDTH-1:0] a14_data_delayed_14;
reg [`DWIDTH-1:0] a15_data_delayed_1;
reg [`DWIDTH-1:0] a15_data_delayed_2;
reg [`DWIDTH-1:0] a15_data_delayed_3;
reg [`DWIDTH-1:0] a15_data_delayed_4;
reg [`DWIDTH-1:0] a15_data_delayed_5;
reg [`DWIDTH-1:0] a15_data_delayed_6;
reg [`DWIDTH-1:0] a15_data_delayed_7;
reg [`DWIDTH-1:0] a15_data_delayed_8;
reg [`DWIDTH-1:0] a15_data_delayed_9;
reg [`DWIDTH-1:0] a15_data_delayed_10;
reg [`DWIDTH-1:0] a15_data_delayed_11;
reg [`DWIDTH-1:0] a15_data_delayed_12;
reg [`DWIDTH-1:0] a15_data_delayed_13;
reg [`DWIDTH-1:0] a15_data_delayed_14;
reg [`DWIDTH-1:0] a15_data_delayed_15;

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
    a8_data_delayed_1 <= 0;
    a8_data_delayed_2 <= 0;
    a8_data_delayed_3 <= 0;
    a8_data_delayed_4 <= 0;
    a8_data_delayed_5 <= 0;
    a8_data_delayed_6 <= 0;
    a8_data_delayed_7 <= 0;
    a8_data_delayed_8 <= 0;
    a9_data_delayed_1 <= 0;
    a9_data_delayed_2 <= 0;
    a9_data_delayed_3 <= 0;
    a9_data_delayed_4 <= 0;
    a9_data_delayed_5 <= 0;
    a9_data_delayed_6 <= 0;
    a9_data_delayed_7 <= 0;
    a9_data_delayed_8 <= 0;
    a9_data_delayed_9 <= 0;
    a10_data_delayed_1 <= 0;
    a10_data_delayed_2 <= 0;
    a10_data_delayed_3 <= 0;
    a10_data_delayed_4 <= 0;
    a10_data_delayed_5 <= 0;
    a10_data_delayed_6 <= 0;
    a10_data_delayed_7 <= 0;
    a10_data_delayed_8 <= 0;
    a10_data_delayed_9 <= 0;
    a10_data_delayed_10 <= 0;
    a11_data_delayed_1 <= 0;
    a11_data_delayed_2 <= 0;
    a11_data_delayed_3 <= 0;
    a11_data_delayed_4 <= 0;
    a11_data_delayed_5 <= 0;
    a11_data_delayed_6 <= 0;
    a11_data_delayed_7 <= 0;
    a11_data_delayed_8 <= 0;
    a11_data_delayed_9 <= 0;
    a11_data_delayed_10 <= 0;
    a11_data_delayed_11 <= 0;
    a12_data_delayed_1 <= 0;
    a12_data_delayed_2 <= 0;
    a12_data_delayed_3 <= 0;
    a12_data_delayed_4 <= 0;
    a12_data_delayed_5 <= 0;
    a12_data_delayed_6 <= 0;
    a12_data_delayed_7 <= 0;
    a12_data_delayed_8 <= 0;
    a12_data_delayed_9 <= 0;
    a12_data_delayed_10 <= 0;
    a12_data_delayed_11 <= 0;
    a12_data_delayed_12 <= 0;
    a13_data_delayed_1 <= 0;
    a13_data_delayed_2 <= 0;
    a13_data_delayed_3 <= 0;
    a13_data_delayed_4 <= 0;
    a13_data_delayed_5 <= 0;
    a13_data_delayed_6 <= 0;
    a13_data_delayed_7 <= 0;
    a13_data_delayed_8 <= 0;
    a13_data_delayed_9 <= 0;
    a13_data_delayed_10 <= 0;
    a13_data_delayed_11 <= 0;
    a13_data_delayed_12 <= 0;
    a13_data_delayed_13 <= 0;
    a14_data_delayed_1 <= 0;
    a14_data_delayed_2 <= 0;
    a14_data_delayed_3 <= 0;
    a14_data_delayed_4 <= 0;
    a14_data_delayed_5 <= 0;
    a14_data_delayed_6 <= 0;
    a14_data_delayed_7 <= 0;
    a14_data_delayed_8 <= 0;
    a14_data_delayed_9 <= 0;
    a14_data_delayed_10 <= 0;
    a14_data_delayed_11 <= 0;
    a14_data_delayed_12 <= 0;
    a14_data_delayed_13 <= 0;
    a14_data_delayed_14 <= 0;
    a15_data_delayed_1 <= 0;
    a15_data_delayed_2 <= 0;
    a15_data_delayed_3 <= 0;
    a15_data_delayed_4 <= 0;
    a15_data_delayed_5 <= 0;
    a15_data_delayed_6 <= 0;
    a15_data_delayed_7 <= 0;
    a15_data_delayed_8 <= 0;
    a15_data_delayed_9 <= 0;
    a15_data_delayed_10 <= 0;
    a15_data_delayed_11 <= 0;
    a15_data_delayed_12 <= 0;
    a15_data_delayed_13 <= 0;
    a15_data_delayed_14 <= 0;
    a15_data_delayed_15 <= 0;
  end
  else begin
    a1_data_delayed_1 <= a1_data;
    a2_data_delayed_1 <= a2_data;
    a2_data_delayed_2 <= a2_data_delayed_1;
    a3_data_delayed_1 <= a3_data;
    a3_data_delayed_2 <= a3_data_delayed_1;
    a3_data_delayed_3 <= a3_data_delayed_2;
    a4_data_delayed_1 <= a4_data;
    a4_data_delayed_2 <= a4_data_delayed_1;
    a4_data_delayed_3 <= a4_data_delayed_2;
    a4_data_delayed_4 <= a4_data_delayed_3;
    a5_data_delayed_1 <= a5_data;
    a5_data_delayed_2 <= a5_data_delayed_1;
    a5_data_delayed_3 <= a5_data_delayed_2;
    a5_data_delayed_4 <= a5_data_delayed_3;
    a5_data_delayed_5 <= a5_data_delayed_4;
    a6_data_delayed_1 <= a6_data;
    a6_data_delayed_2 <= a6_data_delayed_1;
    a6_data_delayed_3 <= a6_data_delayed_2;
    a6_data_delayed_4 <= a6_data_delayed_3;
    a6_data_delayed_5 <= a6_data_delayed_4;
    a6_data_delayed_6 <= a6_data_delayed_5;
    a7_data_delayed_1 <= a7_data;
    a7_data_delayed_2 <= a7_data_delayed_1;
    a7_data_delayed_3 <= a7_data_delayed_2;
    a7_data_delayed_4 <= a7_data_delayed_3;
    a7_data_delayed_5 <= a7_data_delayed_4;
    a7_data_delayed_6 <= a7_data_delayed_5;
    a7_data_delayed_7 <= a7_data_delayed_6;
    a8_data_delayed_1 <= a8_data;
    a8_data_delayed_2 <= a8_data_delayed_1;
    a8_data_delayed_3 <= a8_data_delayed_2;
    a8_data_delayed_4 <= a8_data_delayed_3;
    a8_data_delayed_5 <= a8_data_delayed_4;
    a8_data_delayed_6 <= a8_data_delayed_5;
    a8_data_delayed_7 <= a8_data_delayed_6;
    a8_data_delayed_8 <= a8_data_delayed_7;
    a9_data_delayed_1 <= a9_data;
    a9_data_delayed_2 <= a9_data_delayed_1;
    a9_data_delayed_3 <= a9_data_delayed_2;
    a9_data_delayed_4 <= a9_data_delayed_3;
    a9_data_delayed_5 <= a9_data_delayed_4;
    a9_data_delayed_6 <= a9_data_delayed_5;
    a9_data_delayed_7 <= a9_data_delayed_6;
    a9_data_delayed_8 <= a9_data_delayed_7;
    a9_data_delayed_9 <= a9_data_delayed_8;
    a10_data_delayed_1 <= a10_data;
    a10_data_delayed_2 <= a10_data_delayed_1;
    a10_data_delayed_3 <= a10_data_delayed_2;
    a10_data_delayed_4 <= a10_data_delayed_3;
    a10_data_delayed_5 <= a10_data_delayed_4;
    a10_data_delayed_6 <= a10_data_delayed_5;
    a10_data_delayed_7 <= a10_data_delayed_6;
    a10_data_delayed_8 <= a10_data_delayed_7;
    a10_data_delayed_9 <= a10_data_delayed_8;
    a10_data_delayed_10 <= a10_data_delayed_9;
    a11_data_delayed_1 <= a11_data;
    a11_data_delayed_2 <= a11_data_delayed_1;
    a11_data_delayed_3 <= a11_data_delayed_2;
    a11_data_delayed_4 <= a11_data_delayed_3;
    a11_data_delayed_5 <= a11_data_delayed_4;
    a11_data_delayed_6 <= a11_data_delayed_5;
    a11_data_delayed_7 <= a11_data_delayed_6;
    a11_data_delayed_8 <= a11_data_delayed_7;
    a11_data_delayed_9 <= a11_data_delayed_8;
    a11_data_delayed_10 <= a11_data_delayed_9;
    a11_data_delayed_11 <= a11_data_delayed_10;
    a12_data_delayed_1 <= a12_data;
    a12_data_delayed_2 <= a12_data_delayed_1;
    a12_data_delayed_3 <= a12_data_delayed_2;
    a12_data_delayed_4 <= a12_data_delayed_3;
    a12_data_delayed_5 <= a12_data_delayed_4;
    a12_data_delayed_6 <= a12_data_delayed_5;
    a12_data_delayed_7 <= a12_data_delayed_6;
    a12_data_delayed_8 <= a12_data_delayed_7;
    a12_data_delayed_9 <= a12_data_delayed_8;
    a12_data_delayed_10 <= a12_data_delayed_9;
    a12_data_delayed_11 <= a12_data_delayed_10;
    a12_data_delayed_12 <= a12_data_delayed_11;
    a13_data_delayed_1 <= a13_data;
    a13_data_delayed_2 <= a13_data_delayed_1;
    a13_data_delayed_3 <= a13_data_delayed_2;
    a13_data_delayed_4 <= a13_data_delayed_3;
    a13_data_delayed_5 <= a13_data_delayed_4;
    a13_data_delayed_6 <= a13_data_delayed_5;
    a13_data_delayed_7 <= a13_data_delayed_6;
    a13_data_delayed_8 <= a13_data_delayed_7;
    a13_data_delayed_9 <= a13_data_delayed_8;
    a13_data_delayed_10 <= a13_data_delayed_9;
    a13_data_delayed_11 <= a13_data_delayed_10;
    a13_data_delayed_12 <= a13_data_delayed_11;
    a13_data_delayed_13 <= a13_data_delayed_12;
    a14_data_delayed_1 <= a14_data;
    a14_data_delayed_2 <= a14_data_delayed_1;
    a14_data_delayed_3 <= a14_data_delayed_2;
    a14_data_delayed_4 <= a14_data_delayed_3;
    a14_data_delayed_5 <= a14_data_delayed_4;
    a14_data_delayed_6 <= a14_data_delayed_5;
    a14_data_delayed_7 <= a14_data_delayed_6;
    a14_data_delayed_8 <= a14_data_delayed_7;
    a14_data_delayed_9 <= a14_data_delayed_8;
    a14_data_delayed_10 <= a14_data_delayed_9;
    a14_data_delayed_11 <= a14_data_delayed_10;
    a14_data_delayed_12 <= a14_data_delayed_11;
    a14_data_delayed_13 <= a14_data_delayed_12;
    a14_data_delayed_14 <= a14_data_delayed_13;
    a15_data_delayed_1 <= a15_data;
    a15_data_delayed_2 <= a15_data_delayed_1;
    a15_data_delayed_3 <= a15_data_delayed_2;
    a15_data_delayed_4 <= a15_data_delayed_3;
    a15_data_delayed_5 <= a15_data_delayed_4;
    a15_data_delayed_6 <= a15_data_delayed_5;
    a15_data_delayed_7 <= a15_data_delayed_6;
    a15_data_delayed_8 <= a15_data_delayed_7;
    a15_data_delayed_9 <= a15_data_delayed_8;
    a15_data_delayed_10 <= a15_data_delayed_9;
    a15_data_delayed_11 <= a15_data_delayed_10;
    a15_data_delayed_12 <= a15_data_delayed_11;
    a15_data_delayed_13 <= a15_data_delayed_12;
    a15_data_delayed_14 <= a15_data_delayed_13;
    a15_data_delayed_15 <= a15_data_delayed_14;
  end
end

//////////////////////////////////////////////////////////////////////////
// Logic to generate addresses to BRAM B
//////////////////////////////////////////////////////////////////////////

reg [`AWIDTH-1:0] b_addr;
reg b_mem_access; // flag that tells whether the matmul is trying to access memory or not
 
always @(posedge clk) begin  
    if ((reset || ~start_mat_mul) || (clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)+num_matrices_B << `LOG2_MAT_MUL_SIZE)) begin
        b_addr <= address_mat_b - address_stride_b;
        b_mem_access <= 0;
    end 
    else if ((clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)) && (clk_cnt < (b_loc<<`LOG2_MAT_MUL_SIZE)+num_matrices_B << `LOG2_MAT_MUL_SIZE)) begin
        b_addr <= b_addr + address_stride_b;
        b_mem_access <= 1;
    end
end  

//////////////////////////////////////////////////////////////////////////
// Logic to generate valid signals for data coming from BRAM B
//////////////////////////////////////////////////////////////////////////

reg [7:0] b_mem_access_counter;

always @(posedge clk) begin
    if (reset || ~start_mat_mul) begin
        b_mem_access_counter <= 0;
    end
    else if (b_mem_access == 1) begin
        b_mem_access_counter <= b_mem_access_counter + 1;  
    end
    else begin
        b_mem_access_counter <= 0;
    end
end

assign b_data_valid = 
       ((validity_mask_a_cols_b_rows[0]==1'b0 && b_mem_access_counter==1) ||
        (validity_mask_a_cols_b_rows[1]==1'b0 && b_mem_access_counter==2) ||
        (validity_mask_a_cols_b_rows[2]==1'b0 && b_mem_access_counter==3) ||
        (validity_mask_a_cols_b_rows[3]==1'b0 && b_mem_access_counter==4) ||
        (validity_mask_a_cols_b_rows[4]==1'b0 && b_mem_access_counter==5) ||
        (validity_mask_a_cols_b_rows[5]==1'b0 && b_mem_access_counter==6) ||
        (validity_mask_a_cols_b_rows[6]==1'b0 && b_mem_access_counter==7) ||
        (validity_mask_a_cols_b_rows[7]==1'b0 && b_mem_access_counter==8) ||
        (validity_mask_a_cols_b_rows[8]==1'b0 && b_mem_access_counter==9) ||
        (validity_mask_a_cols_b_rows[9]==1'b0 && b_mem_access_counter==10) ||
        (validity_mask_a_cols_b_rows[10]==1'b0 && b_mem_access_counter==11) ||
        (validity_mask_a_cols_b_rows[11]==1'b0 && b_mem_access_counter==12) ||
        (validity_mask_a_cols_b_rows[12]==1'b0 && b_mem_access_counter==13) ||
        (validity_mask_a_cols_b_rows[13]==1'b0 && b_mem_access_counter==14) ||
        (validity_mask_a_cols_b_rows[14]==1'b0 && b_mem_access_counter==15) ||
        (validity_mask_a_cols_b_rows[15]==1'b0 && b_mem_access_counter==16)) ?
        1'b0 : (b_mem_access_counter >= `MEM_ACCESS_LATENCY);   

//////////////////////////////////////////////////////////////////////////
// Logic to delay certain parts of the data received from BRAM B (systolic data setup)
//////////////////////////////////////////////////////////////////////////

// Slice data into chunks and qualify it with whether it is valid or not
assign b0_data = b_data[`DWIDTH-1:0] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[0]}};
assign b1_data = b_data[2*`DWIDTH-1:1*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[1]}};
assign b2_data = b_data[3*`DWIDTH-1:2*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[2]}};
assign b3_data = b_data[4*`DWIDTH-1:3*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[3]}};
assign b4_data = b_data[5*`DWIDTH-1:4*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[4]}};
assign b5_data = b_data[6*`DWIDTH-1:5*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[5]}};
assign b6_data = b_data[7*`DWIDTH-1:6*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[6]}};
assign b7_data = b_data[8*`DWIDTH-1:7*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[7]}};
assign b8_data = b_data[9*`DWIDTH-1:8*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[8]}};
assign b9_data = b_data[10*`DWIDTH-1:9*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[9]}};
assign b10_data = b_data[11*`DWIDTH-1:10*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[10]}};
assign b11_data = b_data[12*`DWIDTH-1:11*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[11]}};
assign b12_data = b_data[13*`DWIDTH-1:12*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[12]}};
assign b13_data = b_data[14*`DWIDTH-1:13*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[13]}};
assign b14_data = b_data[15*`DWIDTH-1:14*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[14]}};
assign b15_data = b_data[16*`DWIDTH-1:15*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[15]}};

// For larger matmuls, more such delaying flops will be needed
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
reg [`DWIDTH-1:0] b8_data_delayed_1;
reg [`DWIDTH-1:0] b8_data_delayed_2;
reg [`DWIDTH-1:0] b8_data_delayed_3;
reg [`DWIDTH-1:0] b8_data_delayed_4;
reg [`DWIDTH-1:0] b8_data_delayed_5;
reg [`DWIDTH-1:0] b8_data_delayed_6;
reg [`DWIDTH-1:0] b8_data_delayed_7;
reg [`DWIDTH-1:0] b8_data_delayed_8;
reg [`DWIDTH-1:0] b9_data_delayed_1;
reg [`DWIDTH-1:0] b9_data_delayed_2;
reg [`DWIDTH-1:0] b9_data_delayed_3;
reg [`DWIDTH-1:0] b9_data_delayed_4;
reg [`DWIDTH-1:0] b9_data_delayed_5;
reg [`DWIDTH-1:0] b9_data_delayed_6;
reg [`DWIDTH-1:0] b9_data_delayed_7;
reg [`DWIDTH-1:0] b9_data_delayed_8;
reg [`DWIDTH-1:0] b9_data_delayed_9;
reg [`DWIDTH-1:0] b10_data_delayed_1;
reg [`DWIDTH-1:0] b10_data_delayed_2;
reg [`DWIDTH-1:0] b10_data_delayed_3;
reg [`DWIDTH-1:0] b10_data_delayed_4;
reg [`DWIDTH-1:0] b10_data_delayed_5;
reg [`DWIDTH-1:0] b10_data_delayed_6;
reg [`DWIDTH-1:0] b10_data_delayed_7;
reg [`DWIDTH-1:0] b10_data_delayed_8;
reg [`DWIDTH-1:0] b10_data_delayed_9;
reg [`DWIDTH-1:0] b10_data_delayed_10;
reg [`DWIDTH-1:0] b11_data_delayed_1;
reg [`DWIDTH-1:0] b11_data_delayed_2;
reg [`DWIDTH-1:0] b11_data_delayed_3;
reg [`DWIDTH-1:0] b11_data_delayed_4;
reg [`DWIDTH-1:0] b11_data_delayed_5;
reg [`DWIDTH-1:0] b11_data_delayed_6;
reg [`DWIDTH-1:0] b11_data_delayed_7;
reg [`DWIDTH-1:0] b11_data_delayed_8;
reg [`DWIDTH-1:0] b11_data_delayed_9;
reg [`DWIDTH-1:0] b11_data_delayed_10;
reg [`DWIDTH-1:0] b11_data_delayed_11;
reg [`DWIDTH-1:0] b12_data_delayed_1;
reg [`DWIDTH-1:0] b12_data_delayed_2;
reg [`DWIDTH-1:0] b12_data_delayed_3;
reg [`DWIDTH-1:0] b12_data_delayed_4;
reg [`DWIDTH-1:0] b12_data_delayed_5;
reg [`DWIDTH-1:0] b12_data_delayed_6;
reg [`DWIDTH-1:0] b12_data_delayed_7;
reg [`DWIDTH-1:0] b12_data_delayed_8;
reg [`DWIDTH-1:0] b12_data_delayed_9;
reg [`DWIDTH-1:0] b12_data_delayed_10;
reg [`DWIDTH-1:0] b12_data_delayed_11;
reg [`DWIDTH-1:0] b12_data_delayed_12;
reg [`DWIDTH-1:0] b13_data_delayed_1;
reg [`DWIDTH-1:0] b13_data_delayed_2;
reg [`DWIDTH-1:0] b13_data_delayed_3;
reg [`DWIDTH-1:0] b13_data_delayed_4;
reg [`DWIDTH-1:0] b13_data_delayed_5;
reg [`DWIDTH-1:0] b13_data_delayed_6;
reg [`DWIDTH-1:0] b13_data_delayed_7;
reg [`DWIDTH-1:0] b13_data_delayed_8;
reg [`DWIDTH-1:0] b13_data_delayed_9;
reg [`DWIDTH-1:0] b13_data_delayed_10;
reg [`DWIDTH-1:0] b13_data_delayed_11;
reg [`DWIDTH-1:0] b13_data_delayed_12;
reg [`DWIDTH-1:0] b13_data_delayed_13;
reg [`DWIDTH-1:0] b14_data_delayed_1;
reg [`DWIDTH-1:0] b14_data_delayed_2;
reg [`DWIDTH-1:0] b14_data_delayed_3;
reg [`DWIDTH-1:0] b14_data_delayed_4;
reg [`DWIDTH-1:0] b14_data_delayed_5;
reg [`DWIDTH-1:0] b14_data_delayed_6;
reg [`DWIDTH-1:0] b14_data_delayed_7;
reg [`DWIDTH-1:0] b14_data_delayed_8;
reg [`DWIDTH-1:0] b14_data_delayed_9;
reg [`DWIDTH-1:0] b14_data_delayed_10;
reg [`DWIDTH-1:0] b14_data_delayed_11;
reg [`DWIDTH-1:0] b14_data_delayed_12;
reg [`DWIDTH-1:0] b14_data_delayed_13;
reg [`DWIDTH-1:0] b14_data_delayed_14;
reg [`DWIDTH-1:0] b15_data_delayed_1;
reg [`DWIDTH-1:0] b15_data_delayed_2;
reg [`DWIDTH-1:0] b15_data_delayed_3;
reg [`DWIDTH-1:0] b15_data_delayed_4;
reg [`DWIDTH-1:0] b15_data_delayed_5;
reg [`DWIDTH-1:0] b15_data_delayed_6;
reg [`DWIDTH-1:0] b15_data_delayed_7;
reg [`DWIDTH-1:0] b15_data_delayed_8;
reg [`DWIDTH-1:0] b15_data_delayed_9;
reg [`DWIDTH-1:0] b15_data_delayed_10;
reg [`DWIDTH-1:0] b15_data_delayed_11;
reg [`DWIDTH-1:0] b15_data_delayed_12;
reg [`DWIDTH-1:0] b15_data_delayed_13;
reg [`DWIDTH-1:0] b15_data_delayed_14;
reg [`DWIDTH-1:0] b15_data_delayed_15;

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
    b8_data_delayed_1 <= 0;
    b8_data_delayed_2 <= 0;
    b8_data_delayed_3 <= 0;
    b8_data_delayed_4 <= 0;
    b8_data_delayed_5 <= 0;
    b8_data_delayed_6 <= 0;
    b8_data_delayed_7 <= 0;
    b8_data_delayed_8 <= 0;
    b9_data_delayed_1 <= 0;
    b9_data_delayed_2 <= 0;
    b9_data_delayed_3 <= 0;
    b9_data_delayed_4 <= 0;
    b9_data_delayed_5 <= 0;
    b9_data_delayed_6 <= 0;
    b9_data_delayed_7 <= 0;
    b9_data_delayed_8 <= 0;
    b9_data_delayed_9 <= 0;
    b10_data_delayed_1 <= 0;
    b10_data_delayed_2 <= 0;
    b10_data_delayed_3 <= 0;
    b10_data_delayed_4 <= 0;
    b10_data_delayed_5 <= 0;
    b10_data_delayed_6 <= 0;
    b10_data_delayed_7 <= 0;
    b10_data_delayed_8 <= 0;
    b10_data_delayed_9 <= 0;
    b10_data_delayed_10 <= 0;
    b11_data_delayed_1 <= 0;
    b11_data_delayed_2 <= 0;
    b11_data_delayed_3 <= 0;
    b11_data_delayed_4 <= 0;
    b11_data_delayed_5 <= 0;
    b11_data_delayed_6 <= 0;
    b11_data_delayed_7 <= 0;
    b11_data_delayed_8 <= 0;
    b11_data_delayed_9 <= 0;
    b11_data_delayed_10 <= 0;
    b11_data_delayed_11 <= 0;
    b12_data_delayed_1 <= 0;
    b12_data_delayed_2 <= 0;
    b12_data_delayed_3 <= 0;
    b12_data_delayed_4 <= 0;
    b12_data_delayed_5 <= 0;
    b12_data_delayed_6 <= 0;
    b12_data_delayed_7 <= 0;
    b12_data_delayed_8 <= 0;
    b12_data_delayed_9 <= 0;
    b12_data_delayed_10 <= 0;
    b12_data_delayed_11 <= 0;
    b12_data_delayed_12 <= 0;
    b13_data_delayed_1 <= 0;
    b13_data_delayed_2 <= 0;
    b13_data_delayed_3 <= 0;
    b13_data_delayed_4 <= 0;
    b13_data_delayed_5 <= 0;
    b13_data_delayed_6 <= 0;
    b13_data_delayed_7 <= 0;
    b13_data_delayed_8 <= 0;
    b13_data_delayed_9 <= 0;
    b13_data_delayed_10 <= 0;
    b13_data_delayed_11 <= 0;
    b13_data_delayed_12 <= 0;
    b13_data_delayed_13 <= 0;
    b14_data_delayed_1 <= 0;
    b14_data_delayed_2 <= 0;
    b14_data_delayed_3 <= 0;
    b14_data_delayed_4 <= 0;
    b14_data_delayed_5 <= 0;
    b14_data_delayed_6 <= 0;
    b14_data_delayed_7 <= 0;
    b14_data_delayed_8 <= 0;
    b14_data_delayed_9 <= 0;
    b14_data_delayed_10 <= 0;
    b14_data_delayed_11 <= 0;
    b14_data_delayed_12 <= 0;
    b14_data_delayed_13 <= 0;
    b14_data_delayed_14 <= 0;
    b15_data_delayed_1 <= 0;
    b15_data_delayed_2 <= 0;
    b15_data_delayed_3 <= 0;
    b15_data_delayed_4 <= 0;
    b15_data_delayed_5 <= 0;
    b15_data_delayed_6 <= 0;
    b15_data_delayed_7 <= 0;
    b15_data_delayed_8 <= 0;
    b15_data_delayed_9 <= 0;
    b15_data_delayed_10 <= 0;
    b15_data_delayed_11 <= 0;
    b15_data_delayed_12 <= 0;
    b15_data_delayed_13 <= 0;
    b15_data_delayed_14 <= 0;
    b15_data_delayed_15 <= 0;
  end
  else begin
    b1_data_delayed_1 <= b1_data;
    b2_data_delayed_1 <= b2_data;
    b2_data_delayed_2 <= b2_data_delayed_1;
    b3_data_delayed_1 <= b3_data;
    b3_data_delayed_2 <= b3_data_delayed_1;
    b3_data_delayed_3 <= b3_data_delayed_2;
    b4_data_delayed_1 <= b4_data;
    b4_data_delayed_2 <= b4_data_delayed_1;
    b4_data_delayed_3 <= b4_data_delayed_2;
    b4_data_delayed_4 <= b4_data_delayed_3;
    b5_data_delayed_1 <= b5_data;
    b5_data_delayed_2 <= b5_data_delayed_1;
    b5_data_delayed_3 <= b5_data_delayed_2;
    b5_data_delayed_4 <= b5_data_delayed_3;
    b5_data_delayed_5 <= b5_data_delayed_4;
    b6_data_delayed_1 <= b6_data;
    b6_data_delayed_2 <= b6_data_delayed_1;
    b6_data_delayed_3 <= b6_data_delayed_2;
    b6_data_delayed_4 <= b6_data_delayed_3;
    b6_data_delayed_5 <= b6_data_delayed_4;
    b6_data_delayed_6 <= b6_data_delayed_5;
    b7_data_delayed_1 <= b7_data;
    b7_data_delayed_2 <= b7_data_delayed_1;
    b7_data_delayed_3 <= b7_data_delayed_2;
    b7_data_delayed_4 <= b7_data_delayed_3;
    b7_data_delayed_5 <= b7_data_delayed_4;
    b7_data_delayed_6 <= b7_data_delayed_5;
    b7_data_delayed_7 <= b7_data_delayed_6;
    b8_data_delayed_1 <= b8_data;
    b8_data_delayed_2 <= b8_data_delayed_1;
    b8_data_delayed_3 <= b8_data_delayed_2;
    b8_data_delayed_4 <= b8_data_delayed_3;
    b8_data_delayed_5 <= b8_data_delayed_4;
    b8_data_delayed_6 <= b8_data_delayed_5;
    b8_data_delayed_7 <= b8_data_delayed_6;
    b8_data_delayed_8 <= b8_data_delayed_7;
    b9_data_delayed_1 <= b9_data;
    b9_data_delayed_2 <= b9_data_delayed_1;
    b9_data_delayed_3 <= b9_data_delayed_2;
    b9_data_delayed_4 <= b9_data_delayed_3;
    b9_data_delayed_5 <= b9_data_delayed_4;
    b9_data_delayed_6 <= b9_data_delayed_5;
    b9_data_delayed_7 <= b9_data_delayed_6;
    b9_data_delayed_8 <= b9_data_delayed_7;
    b9_data_delayed_9 <= b9_data_delayed_8;
    b10_data_delayed_1 <= b10_data;
    b10_data_delayed_2 <= b10_data_delayed_1;
    b10_data_delayed_3 <= b10_data_delayed_2;
    b10_data_delayed_4 <= b10_data_delayed_3;
    b10_data_delayed_5 <= b10_data_delayed_4;
    b10_data_delayed_6 <= b10_data_delayed_5;
    b10_data_delayed_7 <= b10_data_delayed_6;
    b10_data_delayed_8 <= b10_data_delayed_7;
    b10_data_delayed_9 <= b10_data_delayed_8;
    b10_data_delayed_10 <= b10_data_delayed_9;
    b11_data_delayed_1 <= b11_data;
    b11_data_delayed_2 <= b11_data_delayed_1;
    b11_data_delayed_3 <= b11_data_delayed_2;
    b11_data_delayed_4 <= b11_data_delayed_3;
    b11_data_delayed_5 <= b11_data_delayed_4;
    b11_data_delayed_6 <= b11_data_delayed_5;
    b11_data_delayed_7 <= b11_data_delayed_6;
    b11_data_delayed_8 <= b11_data_delayed_7;
    b11_data_delayed_9 <= b11_data_delayed_8;
    b11_data_delayed_10 <= b11_data_delayed_9;
    b11_data_delayed_11 <= b11_data_delayed_10;
    b12_data_delayed_1 <= b12_data;
    b12_data_delayed_2 <= b12_data_delayed_1;
    b12_data_delayed_3 <= b12_data_delayed_2;
    b12_data_delayed_4 <= b12_data_delayed_3;
    b12_data_delayed_5 <= b12_data_delayed_4;
    b12_data_delayed_6 <= b12_data_delayed_5;
    b12_data_delayed_7 <= b12_data_delayed_6;
    b12_data_delayed_8 <= b12_data_delayed_7;
    b12_data_delayed_9 <= b12_data_delayed_8;
    b12_data_delayed_10 <= b12_data_delayed_9;
    b12_data_delayed_11 <= b12_data_delayed_10;
    b12_data_delayed_12 <= b12_data_delayed_11;
    b13_data_delayed_1 <= b13_data;
    b13_data_delayed_2 <= b13_data_delayed_1;
    b13_data_delayed_3 <= b13_data_delayed_2;
    b13_data_delayed_4 <= b13_data_delayed_3;
    b13_data_delayed_5 <= b13_data_delayed_4;
    b13_data_delayed_6 <= b13_data_delayed_5;
    b13_data_delayed_7 <= b13_data_delayed_6;
    b13_data_delayed_8 <= b13_data_delayed_7;
    b13_data_delayed_9 <= b13_data_delayed_8;
    b13_data_delayed_10 <= b13_data_delayed_9;
    b13_data_delayed_11 <= b13_data_delayed_10;
    b13_data_delayed_12 <= b13_data_delayed_11;
    b13_data_delayed_13 <= b13_data_delayed_12;
    b14_data_delayed_1 <= b14_data;
    b14_data_delayed_2 <= b14_data_delayed_1;
    b14_data_delayed_3 <= b14_data_delayed_2;
    b14_data_delayed_4 <= b14_data_delayed_3;
    b14_data_delayed_5 <= b14_data_delayed_4;
    b14_data_delayed_6 <= b14_data_delayed_5;
    b14_data_delayed_7 <= b14_data_delayed_6;
    b14_data_delayed_8 <= b14_data_delayed_7;
    b14_data_delayed_9 <= b14_data_delayed_8;
    b14_data_delayed_10 <= b14_data_delayed_9;
    b14_data_delayed_11 <= b14_data_delayed_10;
    b14_data_delayed_12 <= b14_data_delayed_11;
    b14_data_delayed_13 <= b14_data_delayed_12;
    b14_data_delayed_14 <= b14_data_delayed_13;
    b15_data_delayed_1 <= b15_data;
    b15_data_delayed_2 <= b15_data_delayed_1;
    b15_data_delayed_3 <= b15_data_delayed_2;
    b15_data_delayed_4 <= b15_data_delayed_3;
    b15_data_delayed_5 <= b15_data_delayed_4;
    b15_data_delayed_6 <= b15_data_delayed_5;
    b15_data_delayed_7 <= b15_data_delayed_6;
    b15_data_delayed_8 <= b15_data_delayed_7;
    b15_data_delayed_9 <= b15_data_delayed_8;
    b15_data_delayed_10 <= b15_data_delayed_9;
    b15_data_delayed_11 <= b15_data_delayed_10;
    b15_data_delayed_12 <= b15_data_delayed_11;
    b15_data_delayed_13 <= b15_data_delayed_12;
    b15_data_delayed_14 <= b15_data_delayed_13;
    b15_data_delayed_15 <= b15_data_delayed_14;
  end
end
  
endmodule

//////////////////////////////////////////////////////////////////////////
// Systolically connected PEs
//////////////////////////////////////////////////////////////////////////

module systolic_pe_matrix(
    reset,
    clk,
    pe_reset,
    start_mat_mul,
    b_data_sel,
    a0,    a1,    a2,    a3,    a4,    a5,    a6,    a7,    a8,    a9,    a10,    a11,    a12,    a13,    a14,    a15,
    b0,    b1,    b2,    b3,    b4,    b5,    b6,    b7,    b8,    b9,    b10,    b11,    b12,    b13,    b14,    b15,
    c0,    c1,    c2,    c3,    c4,    c5,    c6,    c7,    c8,    c9,    c10,    c11,    c12,    c13,    c14,    c15,
    matrixC00,
    matrixC01,
    matrixC02,
    matrixC03,
    matrixC04,
    matrixC05,
    matrixC06,
    matrixC07,
    matrixC08,
    matrixC09,
    matrixC010,
    matrixC011,
    matrixC012,
    matrixC013,
    matrixC014,
    matrixC015,
    matrixC10,
    matrixC11,
    matrixC12,
    matrixC13,
    matrixC14,
    matrixC15,
    matrixC16,
    matrixC17,
    matrixC18,
    matrixC19,
    matrixC110,
    matrixC111,
    matrixC112,
    matrixC113,
    matrixC114,
    matrixC115,
    matrixC20,
    matrixC21,
    matrixC22,
    matrixC23,
    matrixC24,
    matrixC25,
    matrixC26,
    matrixC27,
    matrixC28,
    matrixC29,
    matrixC210,
    matrixC211,
    matrixC212,
    matrixC213,
    matrixC214,
    matrixC215,
    matrixC30,
    matrixC31,
    matrixC32,
    matrixC33,
    matrixC34,
    matrixC35,
    matrixC36,
    matrixC37,
    matrixC38,
    matrixC39,
    matrixC310,
    matrixC311,
    matrixC312,
    matrixC313,
    matrixC314,
    matrixC315,
    matrixC40,
    matrixC41,
    matrixC42,
    matrixC43,
    matrixC44,
    matrixC45,
    matrixC46,
    matrixC47,
    matrixC48,
    matrixC49,
    matrixC410,
    matrixC411,
    matrixC412,
    matrixC413,
    matrixC414,
    matrixC415,
    matrixC50,
    matrixC51,
    matrixC52,
    matrixC53,
    matrixC54,
    matrixC55,
    matrixC56,
    matrixC57,
    matrixC58,
    matrixC59,
    matrixC510,
    matrixC511,
    matrixC512,
    matrixC513,
    matrixC514,
    matrixC515,
    matrixC60,
    matrixC61,
    matrixC62,
    matrixC63,
    matrixC64,
    matrixC65,
    matrixC66,
    matrixC67,
    matrixC68,
    matrixC69,
    matrixC610,
    matrixC611,
    matrixC612,
    matrixC613,
    matrixC614,
    matrixC615,
    matrixC70,
    matrixC71,
    matrixC72,
    matrixC73,
    matrixC74,
    matrixC75,
    matrixC76,
    matrixC77,
    matrixC78,
    matrixC79,
    matrixC710,
    matrixC711,
    matrixC712,
    matrixC713,
    matrixC714,
    matrixC715,
    matrixC80,
    matrixC81,
    matrixC82,
    matrixC83,
    matrixC84,
    matrixC85,
    matrixC86,
    matrixC87,
    matrixC88,
    matrixC89,
    matrixC810,
    matrixC811,
    matrixC812,
    matrixC813,
    matrixC814,
    matrixC815,
    matrixC90,
    matrixC91,
    matrixC92,
    matrixC93,
    matrixC94,
    matrixC95,
    matrixC96,
    matrixC97,
    matrixC98,
    matrixC99,
    matrixC910,
    matrixC911,
    matrixC912,
    matrixC913,
    matrixC914,
    matrixC915,
    matrixC100,
    matrixC101,
    matrixC102,
    matrixC103,
    matrixC104,
    matrixC105,
    matrixC106,
    matrixC107,
    matrixC108,
    matrixC109,
    matrixC1010,
    matrixC1011,
    matrixC1012,
    matrixC1013,
    matrixC1014,
    matrixC1015,
    matrixC110,
    matrixC111,
    matrixC112,
    matrixC113,
    matrixC114,
    matrixC115,
    matrixC116,
    matrixC117,
    matrixC118,
    matrixC119,
    matrixC1110,
    matrixC1111,
    matrixC1112,
    matrixC1113,
    matrixC1114,
    matrixC1115,
    matrixC120,
    matrixC121,
    matrixC122,
    matrixC123,
    matrixC124,
    matrixC125,
    matrixC126,
    matrixC127,
    matrixC128,
    matrixC129,
    matrixC1210,
    matrixC1211,
    matrixC1212,
    matrixC1213,
    matrixC1214,
    matrixC1215,
    matrixC130,
    matrixC131,
    matrixC132,
    matrixC133,
    matrixC134,
    matrixC135,
    matrixC136,
    matrixC137,
    matrixC138,
    matrixC139,
    matrixC1310,
    matrixC1311,
    matrixC1312,
    matrixC1313,
    matrixC1314,
    matrixC1315,
    matrixC140,
    matrixC141,
    matrixC142,
    matrixC143,
    matrixC144,
    matrixC145,
    matrixC146,
    matrixC147,
    matrixC148,
    matrixC149,
    matrixC1410,
    matrixC1411,
    matrixC1412,
    matrixC1413,
    matrixC1414,
    matrixC1415,
    matrixC150,
    matrixC151,
    matrixC152,
    matrixC153,
    matrixC154,
    matrixC155,
    matrixC156,
    matrixC157,
    matrixC158,
    matrixC159,
    matrixC1510,
    matrixC1511,
    matrixC1512,
    matrixC1513,
    matrixC1514,
    matrixC1515,
    a_data_out,
    b_data_out,
    b_data_valid_ping,
    b_data_valid_pong
);

input clk;
input reset;
input pe_reset;
input start_mat_mul;
input b_data_sel;
input b_data_valid_ping;
input b_data_valid_pong;
input [`DWIDTH-1:0] a0;
input [`DWIDTH-1:0] a1;
input [`DWIDTH-1:0] a2;
input [`DWIDTH-1:0] a3;
input [`DWIDTH-1:0] a4;
input [`DWIDTH-1:0] a5;
input [`DWIDTH-1:0] a6;
input [`DWIDTH-1:0] a7;
input [`DWIDTH-1:0] a8;
input [`DWIDTH-1:0] a9;
input [`DWIDTH-1:0] a10;
input [`DWIDTH-1:0] a11;
input [`DWIDTH-1:0] a12;
input [`DWIDTH-1:0] a13;
input [`DWIDTH-1:0] a14;
input [`DWIDTH-1:0] a15;
input [`DWIDTH-1:0] b0;
input [`DWIDTH-1:0] b1;
input [`DWIDTH-1:0] b2;
input [`DWIDTH-1:0] b3;
input [`DWIDTH-1:0] b4;
input [`DWIDTH-1:0] b5;
input [`DWIDTH-1:0] b6;
input [`DWIDTH-1:0] b7;
input [`DWIDTH-1:0] b8;
input [`DWIDTH-1:0] b9;
input [`DWIDTH-1:0] b10;
input [`DWIDTH-1:0] b11;
input [`DWIDTH-1:0] b12;
input [`DWIDTH-1:0] b13;
input [`DWIDTH-1:0] b14;
input [`DWIDTH-1:0] b15;
input [`DWIDTH-1:0] c0;
input [`DWIDTH-1:0] c1;
input [`DWIDTH-1:0] c2;
input [`DWIDTH-1:0] c3;
input [`DWIDTH-1:0] c4;
input [`DWIDTH-1:0] c5;
input [`DWIDTH-1:0] c6;
input [`DWIDTH-1:0] c7;
input [`DWIDTH-1:0] c8;
input [`DWIDTH-1:0] c9;
input [`DWIDTH-1:0] c10;
input [`DWIDTH-1:0] c11;
input [`DWIDTH-1:0] c12;
input [`DWIDTH-1:0] c13;
input [`DWIDTH-1:0] c14;
input [`DWIDTH-1:0] c15;
output [`DWIDTH-1:0] matrixC00;
output [`DWIDTH-1:0] matrixC01;
output [`DWIDTH-1:0] matrixC02;
output [`DWIDTH-1:0] matrixC03;
output [`DWIDTH-1:0] matrixC04;
output [`DWIDTH-1:0] matrixC05;
output [`DWIDTH-1:0] matrixC06;
output [`DWIDTH-1:0] matrixC07;
output [`DWIDTH-1:0] matrixC08;
output [`DWIDTH-1:0] matrixC09;
output [`DWIDTH-1:0] matrixC010;
output [`DWIDTH-1:0] matrixC011;
output [`DWIDTH-1:0] matrixC012;
output [`DWIDTH-1:0] matrixC013;
output [`DWIDTH-1:0] matrixC014;
output [`DWIDTH-1:0] matrixC015;
output [`DWIDTH-1:0] matrixC10;
output [`DWIDTH-1:0] matrixC11;
output [`DWIDTH-1:0] matrixC12;
output [`DWIDTH-1:0] matrixC13;
output [`DWIDTH-1:0] matrixC14;
output [`DWIDTH-1:0] matrixC15;
output [`DWIDTH-1:0] matrixC16;
output [`DWIDTH-1:0] matrixC17;
output [`DWIDTH-1:0] matrixC18;
output [`DWIDTH-1:0] matrixC19;
output [`DWIDTH-1:0] matrixC110;
output [`DWIDTH-1:0] matrixC111;
output [`DWIDTH-1:0] matrixC112;
output [`DWIDTH-1:0] matrixC113;
output [`DWIDTH-1:0] matrixC114;
output [`DWIDTH-1:0] matrixC115;
output [`DWIDTH-1:0] matrixC20;
output [`DWIDTH-1:0] matrixC21;
output [`DWIDTH-1:0] matrixC22;
output [`DWIDTH-1:0] matrixC23;
output [`DWIDTH-1:0] matrixC24;
output [`DWIDTH-1:0] matrixC25;
output [`DWIDTH-1:0] matrixC26;
output [`DWIDTH-1:0] matrixC27;
output [`DWIDTH-1:0] matrixC28;
output [`DWIDTH-1:0] matrixC29;
output [`DWIDTH-1:0] matrixC210;
output [`DWIDTH-1:0] matrixC211;
output [`DWIDTH-1:0] matrixC212;
output [`DWIDTH-1:0] matrixC213;
output [`DWIDTH-1:0] matrixC214;
output [`DWIDTH-1:0] matrixC215;
output [`DWIDTH-1:0] matrixC30;
output [`DWIDTH-1:0] matrixC31;
output [`DWIDTH-1:0] matrixC32;
output [`DWIDTH-1:0] matrixC33;
output [`DWIDTH-1:0] matrixC34;
output [`DWIDTH-1:0] matrixC35;
output [`DWIDTH-1:0] matrixC36;
output [`DWIDTH-1:0] matrixC37;
output [`DWIDTH-1:0] matrixC38;
output [`DWIDTH-1:0] matrixC39;
output [`DWIDTH-1:0] matrixC310;
output [`DWIDTH-1:0] matrixC311;
output [`DWIDTH-1:0] matrixC312;
output [`DWIDTH-1:0] matrixC313;
output [`DWIDTH-1:0] matrixC314;
output [`DWIDTH-1:0] matrixC315;
output [`DWIDTH-1:0] matrixC40;
output [`DWIDTH-1:0] matrixC41;
output [`DWIDTH-1:0] matrixC42;
output [`DWIDTH-1:0] matrixC43;
output [`DWIDTH-1:0] matrixC44;
output [`DWIDTH-1:0] matrixC45;
output [`DWIDTH-1:0] matrixC46;
output [`DWIDTH-1:0] matrixC47;
output [`DWIDTH-1:0] matrixC48;
output [`DWIDTH-1:0] matrixC49;
output [`DWIDTH-1:0] matrixC410;
output [`DWIDTH-1:0] matrixC411;
output [`DWIDTH-1:0] matrixC412;
output [`DWIDTH-1:0] matrixC413;
output [`DWIDTH-1:0] matrixC414;
output [`DWIDTH-1:0] matrixC415;
output [`DWIDTH-1:0] matrixC50;
output [`DWIDTH-1:0] matrixC51;
output [`DWIDTH-1:0] matrixC52;
output [`DWIDTH-1:0] matrixC53;
output [`DWIDTH-1:0] matrixC54;
output [`DWIDTH-1:0] matrixC55;
output [`DWIDTH-1:0] matrixC56;
output [`DWIDTH-1:0] matrixC57;
output [`DWIDTH-1:0] matrixC58;
output [`DWIDTH-1:0] matrixC59;
output [`DWIDTH-1:0] matrixC510;
output [`DWIDTH-1:0] matrixC511;
output [`DWIDTH-1:0] matrixC512;
output [`DWIDTH-1:0] matrixC513;
output [`DWIDTH-1:0] matrixC514;
output [`DWIDTH-1:0] matrixC515;
output [`DWIDTH-1:0] matrixC60;
output [`DWIDTH-1:0] matrixC61;
output [`DWIDTH-1:0] matrixC62;
output [`DWIDTH-1:0] matrixC63;
output [`DWIDTH-1:0] matrixC64;
output [`DWIDTH-1:0] matrixC65;
output [`DWIDTH-1:0] matrixC66;
output [`DWIDTH-1:0] matrixC67;
output [`DWIDTH-1:0] matrixC68;
output [`DWIDTH-1:0] matrixC69;
output [`DWIDTH-1:0] matrixC610;
output [`DWIDTH-1:0] matrixC611;
output [`DWIDTH-1:0] matrixC612;
output [`DWIDTH-1:0] matrixC613;
output [`DWIDTH-1:0] matrixC614;
output [`DWIDTH-1:0] matrixC615;
output [`DWIDTH-1:0] matrixC70;
output [`DWIDTH-1:0] matrixC71;
output [`DWIDTH-1:0] matrixC72;
output [`DWIDTH-1:0] matrixC73;
output [`DWIDTH-1:0] matrixC74;
output [`DWIDTH-1:0] matrixC75;
output [`DWIDTH-1:0] matrixC76;
output [`DWIDTH-1:0] matrixC77;
output [`DWIDTH-1:0] matrixC78;
output [`DWIDTH-1:0] matrixC79;
output [`DWIDTH-1:0] matrixC710;
output [`DWIDTH-1:0] matrixC711;
output [`DWIDTH-1:0] matrixC712;
output [`DWIDTH-1:0] matrixC713;
output [`DWIDTH-1:0] matrixC714;
output [`DWIDTH-1:0] matrixC715;
output [`DWIDTH-1:0] matrixC80;
output [`DWIDTH-1:0] matrixC81;
output [`DWIDTH-1:0] matrixC82;
output [`DWIDTH-1:0] matrixC83;
output [`DWIDTH-1:0] matrixC84;
output [`DWIDTH-1:0] matrixC85;
output [`DWIDTH-1:0] matrixC86;
output [`DWIDTH-1:0] matrixC87;
output [`DWIDTH-1:0] matrixC88;
output [`DWIDTH-1:0] matrixC89;
output [`DWIDTH-1:0] matrixC810;
output [`DWIDTH-1:0] matrixC811;
output [`DWIDTH-1:0] matrixC812;
output [`DWIDTH-1:0] matrixC813;
output [`DWIDTH-1:0] matrixC814;
output [`DWIDTH-1:0] matrixC815;
output [`DWIDTH-1:0] matrixC90;
output [`DWIDTH-1:0] matrixC91;
output [`DWIDTH-1:0] matrixC92;
output [`DWIDTH-1:0] matrixC93;
output [`DWIDTH-1:0] matrixC94;
output [`DWIDTH-1:0] matrixC95;
output [`DWIDTH-1:0] matrixC96;
output [`DWIDTH-1:0] matrixC97;
output [`DWIDTH-1:0] matrixC98;
output [`DWIDTH-1:0] matrixC99;
output [`DWIDTH-1:0] matrixC910;
output [`DWIDTH-1:0] matrixC911;
output [`DWIDTH-1:0] matrixC912;
output [`DWIDTH-1:0] matrixC913;
output [`DWIDTH-1:0] matrixC914;
output [`DWIDTH-1:0] matrixC915;
output [`DWIDTH-1:0] matrixC100;
output [`DWIDTH-1:0] matrixC101;
output [`DWIDTH-1:0] matrixC102;
output [`DWIDTH-1:0] matrixC103;
output [`DWIDTH-1:0] matrixC104;
output [`DWIDTH-1:0] matrixC105;
output [`DWIDTH-1:0] matrixC106;
output [`DWIDTH-1:0] matrixC107;
output [`DWIDTH-1:0] matrixC108;
output [`DWIDTH-1:0] matrixC109;
output [`DWIDTH-1:0] matrixC1010;
output [`DWIDTH-1:0] matrixC1011;
output [`DWIDTH-1:0] matrixC1012;
output [`DWIDTH-1:0] matrixC1013;
output [`DWIDTH-1:0] matrixC1014;
output [`DWIDTH-1:0] matrixC1015;
output [`DWIDTH-1:0] matrixC110;
output [`DWIDTH-1:0] matrixC111;
output [`DWIDTH-1:0] matrixC112;
output [`DWIDTH-1:0] matrixC113;
output [`DWIDTH-1:0] matrixC114;
output [`DWIDTH-1:0] matrixC115;
output [`DWIDTH-1:0] matrixC116;
output [`DWIDTH-1:0] matrixC117;
output [`DWIDTH-1:0] matrixC118;
output [`DWIDTH-1:0] matrixC119;
output [`DWIDTH-1:0] matrixC1110;
output [`DWIDTH-1:0] matrixC1111;
output [`DWIDTH-1:0] matrixC1112;
output [`DWIDTH-1:0] matrixC1113;
output [`DWIDTH-1:0] matrixC1114;
output [`DWIDTH-1:0] matrixC1115;
output [`DWIDTH-1:0] matrixC120;
output [`DWIDTH-1:0] matrixC121;
output [`DWIDTH-1:0] matrixC122;
output [`DWIDTH-1:0] matrixC123;
output [`DWIDTH-1:0] matrixC124;
output [`DWIDTH-1:0] matrixC125;
output [`DWIDTH-1:0] matrixC126;
output [`DWIDTH-1:0] matrixC127;
output [`DWIDTH-1:0] matrixC128;
output [`DWIDTH-1:0] matrixC129;
output [`DWIDTH-1:0] matrixC1210;
output [`DWIDTH-1:0] matrixC1211;
output [`DWIDTH-1:0] matrixC1212;
output [`DWIDTH-1:0] matrixC1213;
output [`DWIDTH-1:0] matrixC1214;
output [`DWIDTH-1:0] matrixC1215;
output [`DWIDTH-1:0] matrixC130;
output [`DWIDTH-1:0] matrixC131;
output [`DWIDTH-1:0] matrixC132;
output [`DWIDTH-1:0] matrixC133;
output [`DWIDTH-1:0] matrixC134;
output [`DWIDTH-1:0] matrixC135;
output [`DWIDTH-1:0] matrixC136;
output [`DWIDTH-1:0] matrixC137;
output [`DWIDTH-1:0] matrixC138;
output [`DWIDTH-1:0] matrixC139;
output [`DWIDTH-1:0] matrixC1310;
output [`DWIDTH-1:0] matrixC1311;
output [`DWIDTH-1:0] matrixC1312;
output [`DWIDTH-1:0] matrixC1313;
output [`DWIDTH-1:0] matrixC1314;
output [`DWIDTH-1:0] matrixC1315;
output [`DWIDTH-1:0] matrixC140;
output [`DWIDTH-1:0] matrixC141;
output [`DWIDTH-1:0] matrixC142;
output [`DWIDTH-1:0] matrixC143;
output [`DWIDTH-1:0] matrixC144;
output [`DWIDTH-1:0] matrixC145;
output [`DWIDTH-1:0] matrixC146;
output [`DWIDTH-1:0] matrixC147;
output [`DWIDTH-1:0] matrixC148;
output [`DWIDTH-1:0] matrixC149;
output [`DWIDTH-1:0] matrixC1410;
output [`DWIDTH-1:0] matrixC1411;
output [`DWIDTH-1:0] matrixC1412;
output [`DWIDTH-1:0] matrixC1413;
output [`DWIDTH-1:0] matrixC1414;
output [`DWIDTH-1:0] matrixC1415;
output [`DWIDTH-1:0] matrixC150;
output [`DWIDTH-1:0] matrixC151;
output [`DWIDTH-1:0] matrixC152;
output [`DWIDTH-1:0] matrixC153;
output [`DWIDTH-1:0] matrixC154;
output [`DWIDTH-1:0] matrixC155;
output [`DWIDTH-1:0] matrixC156;
output [`DWIDTH-1:0] matrixC157;
output [`DWIDTH-1:0] matrixC158;
output [`DWIDTH-1:0] matrixC159;
output [`DWIDTH-1:0] matrixC1510;
output [`DWIDTH-1:0] matrixC1511;
output [`DWIDTH-1:0] matrixC1512;
output [`DWIDTH-1:0] matrixC1513;
output [`DWIDTH-1:0] matrixC1514;
output [`DWIDTH-1:0] matrixC1515;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out;
  

wire [`DWIDTH-1:0] a00to01, a01to02, a02to03, a03to04, a04to05, a05to06, a06to07, a07to08, a08to09, a09to010, a010to011, a011to012, a012to013, a013to014, a014to015, a015to016;
wire [`DWIDTH-1:0] a10to11, a11to12, a12to13, a13to14, a14to15, a15to16, a16to17, a17to18, a18to19, a19to110, a110to111, a111to112, a112to113, a113to114, a114to115, a115to116;
wire [`DWIDTH-1:0] a20to21, a21to22, a22to23, a23to24, a24to25, a25to26, a26to27, a27to28, a28to29, a29to210, a210to211, a211to212, a212to213, a213to214, a214to215, a215to216;
wire [`DWIDTH-1:0] a30to31, a31to32, a32to33, a33to34, a34to35, a35to36, a36to37, a37to38, a38to39, a39to310, a310to311, a311to312, a312to313, a313to314, a314to315, a315to316;
wire [`DWIDTH-1:0] a40to41, a41to42, a42to43, a43to44, a44to45, a45to46, a46to47, a47to48, a48to49, a49to410, a410to411, a411to412, a412to413, a413to414, a414to415, a415to416;
wire [`DWIDTH-1:0] a50to51, a51to52, a52to53, a53to54, a54to55, a55to56, a56to57, a57to58, a58to59, a59to510, a510to511, a511to512, a512to513, a513to514, a514to515, a515to516;
wire [`DWIDTH-1:0] a60to61, a61to62, a62to63, a63to64, a64to65, a65to66, a66to67, a67to68, a68to69, a69to610, a610to611, a611to612, a612to613, a613to614, a614to615, a615to616;
wire [`DWIDTH-1:0] a70to71, a71to72, a72to73, a73to74, a74to75, a75to76, a76to77, a77to78, a78to79, a79to710, a710to711, a711to712, a712to713, a713to714, a714to715, a715to716;
wire [`DWIDTH-1:0] a80to81, a81to82, a82to83, a83to84, a84to85, a85to86, a86to87, a87to88, a88to89, a89to810, a810to811, a811to812, a812to813, a813to814, a814to815, a815to816;
wire [`DWIDTH-1:0] a90to91, a91to92, a92to93, a93to94, a94to95, a95to96, a96to97, a97to98, a98to99, a99to910, a910to911, a911to912, a912to913, a913to914, a914to915, a915to916;
wire [`DWIDTH-1:0] a100to101, a101to102, a102to103, a103to104, a104to105, a105to106, a106to107, a107to108, a108to109, a109to1010, a1010to1011, a1011to1012, a1012to1013, a1013to1014, a1014to1015, a1015to1016;
wire [`DWIDTH-1:0] a110to111, a111to112, a112to113, a113to114, a114to115, a115to116, a116to117, a117to118, a118to119, a119to1110, a1110to1111, a1111to1112, a1112to1113, a1113to1114, a1114to1115, a1115to1116;
wire [`DWIDTH-1:0] a120to121, a121to122, a122to123, a123to124, a124to125, a125to126, a126to127, a127to128, a128to129, a129to1210, a1210to1211, a1211to1212, a1212to1213, a1213to1214, a1214to1215, a1215to1216;
wire [`DWIDTH-1:0] a130to131, a131to132, a132to133, a133to134, a134to135, a135to136, a136to137, a137to138, a138to139, a139to1310, a1310to1311, a1311to1312, a1312to1313, a1313to1314, a1314to1315, a1315to1316;
wire [`DWIDTH-1:0] a140to141, a141to142, a142to143, a143to144, a144to145, a145to146, a146to147, a147to148, a148to149, a149to1410, a1410to1411, a1411to1412, a1412to1413, a1413to1414, a1414to1415, a1415to1416;
wire [`DWIDTH-1:0] a150to151, a151to152, a152to153, a153to154, a154to155, a155to156, a156to157, a157to158, a158to159, a159to1510, a1510to1511, a1511to1512, a1512to1513, a1513to1514, a1514to1515, a1515to1516;

wire [`DWIDTH-1:0] b00to10, b10to20, b20to30, b30to40, b40to50, b50to60, b60to70, b70to80, b80to90, b90to100, b100to110, b110to120, b120to130, b130to140, b140to150, b150to160;
wire [`DWIDTH-1:0] b01to11, b11to21, b21to31, b31to41, b41to51, b51to61, b61to71, b71to81, b81to91, b91to101, b101to111, b111to121, b121to131, b131to141, b141to151, b151to161;
wire [`DWIDTH-1:0] b02to12, b12to22, b22to32, b32to42, b42to52, b52to62, b62to72, b72to82, b82to92, b92to102, b102to112, b112to122, b122to132, b132to142, b142to152, b152to162;
wire [`DWIDTH-1:0] b03to13, b13to23, b23to33, b33to43, b43to53, b53to63, b63to73, b73to83, b83to93, b93to103, b103to113, b113to123, b123to133, b133to143, b143to153, b153to163;
wire [`DWIDTH-1:0] b04to14, b14to24, b24to34, b34to44, b44to54, b54to64, b64to74, b74to84, b84to94, b94to104, b104to114, b114to124, b124to134, b134to144, b144to154, b154to164;
wire [`DWIDTH-1:0] b05to15, b15to25, b25to35, b35to45, b45to55, b55to65, b65to75, b75to85, b85to95, b95to105, b105to115, b115to125, b125to135, b135to145, b145to155, b155to165;
wire [`DWIDTH-1:0] b06to16, b16to26, b26to36, b36to46, b46to56, b56to66, b66to76, b76to86, b86to96, b96to106, b106to116, b116to126, b126to136, b136to146, b146to156, b156to166;
wire [`DWIDTH-1:0] b07to17, b17to27, b27to37, b37to47, b47to57, b57to67, b67to77, b77to87, b87to97, b97to107, b107to117, b117to127, b127to137, b137to147, b147to157, b157to167;
wire [`DWIDTH-1:0] b08to18, b18to28, b28to38, b38to48, b48to58, b58to68, b68to78, b78to88, b88to98, b98to108, b108to118, b118to128, b128to138, b138to148, b148to158, b158to168;
wire [`DWIDTH-1:0] b09to19, b19to29, b29to39, b39to49, b49to59, b59to69, b69to79, b79to89, b89to99, b99to109, b109to119, b119to129, b129to139, b139to149, b149to159, b159to169;
wire [`DWIDTH-1:0] b010to110, b110to210, b210to310, b310to410, b410to510, b510to610, b610to710, b710to810, b810to910, b910to1010, b1010to1110, b1110to1210, b1210to1310, b1310to1410, b1410to1510, b1510to1610;
wire [`DWIDTH-1:0] b011to111, b111to211, b211to311, b311to411, b411to511, b511to611, b611to711, b711to811, b811to911, b911to1011, b1011to1111, b1111to1211, b1211to1311, b1311to1411, b1411to1511, b1511to1611;
wire [`DWIDTH-1:0] b012to112, b112to212, b212to312, b312to412, b412to512, b512to612, b612to712, b712to812, b812to912, b912to1012, b1012to1112, b1112to1212, b1212to1312, b1312to1412, b1412to1512, b1512to1612;
wire [`DWIDTH-1:0] b013to113, b113to213, b213to313, b313to413, b413to513, b513to613, b613to713, b713to813, b813to913, b913to1013, b1013to1113, b1113to1213, b1213to1313, b1313to1413, b1413to1513, b1513to1613;
wire [`DWIDTH-1:0] b014to114, b114to214, b214to314, b314to414, b414to514, b514to614, b614to714, b714to814, b814to914, b914to1014, b1014to1114, b1114to1214, b1214to1314, b1314to1414, b1414to1514, b1514to1614;
wire [`DWIDTH-1:0] b015to115, b115to215, b215to315, b315to415, b415to515, b515to615, b615to715, b715to815, b815to915, b915to1015, b1015to1115, b1115to1215, b1215to1315, b1315to1415, b1415to1515, b1515to1615;

wire [`DWIDTH-1:0] b00to10_ping, b10to20_ping, b20to30_ping, b30to40_ping, b40to50_ping, b50to60_ping, b60to70_ping, b70to80_ping, b80to90_ping, b90to100_ping, b100to110_ping, b110to120_ping, b120to130_ping, b130to140_ping, b140to150_ping, b150to160_ping;
wire [`DWIDTH-1:0] b01to11_ping, b11to21_ping, b21to31_ping, b31to41_ping, b41to51_ping, b51to61_ping, b61to71_ping, b71to81_ping, b81to91_ping, b91to101_ping, b101to111_ping, b111to121_ping, b121to131_ping, b131to141_ping, b141to151_ping, b151to161_ping;
wire [`DWIDTH-1:0] b02to12_ping, b12to22_ping, b22to32_ping, b32to42_ping, b42to52_ping, b52to62_ping, b62to72_ping, b72to82_ping, b82to92_ping, b92to102_ping, b102to112_ping, b112to122_ping, b122to132_ping, b132to142_ping, b142to152_ping, b152to162_ping;
wire [`DWIDTH-1:0] b03to13_ping, b13to23_ping, b23to33_ping, b33to43_ping, b43to53_ping, b53to63_ping, b63to73_ping, b73to83_ping, b83to93_ping, b93to103_ping, b103to113_ping, b113to123_ping, b123to133_ping, b133to143_ping, b143to153_ping, b153to163_ping;
wire [`DWIDTH-1:0] b04to14_ping, b14to24_ping, b24to34_ping, b34to44_ping, b44to54_ping, b54to64_ping, b64to74_ping, b74to84_ping, b84to94_ping, b94to104_ping, b104to114_ping, b114to124_ping, b124to134_ping, b134to144_ping, b144to154_ping, b154to164_ping;
wire [`DWIDTH-1:0] b05to15_ping, b15to25_ping, b25to35_ping, b35to45_ping, b45to55_ping, b55to65_ping, b65to75_ping, b75to85_ping, b85to95_ping, b95to105_ping, b105to115_ping, b115to125_ping, b125to135_ping, b135to145_ping, b145to155_ping, b155to165_ping;
wire [`DWIDTH-1:0] b06to16_ping, b16to26_ping, b26to36_ping, b36to46_ping, b46to56_ping, b56to66_ping, b66to76_ping, b76to86_ping, b86to96_ping, b96to106_ping, b106to116_ping, b116to126_ping, b126to136_ping, b136to146_ping, b146to156_ping, b156to166_ping;
wire [`DWIDTH-1:0] b07to17_ping, b17to27_ping, b27to37_ping, b37to47_ping, b47to57_ping, b57to67_ping, b67to77_ping, b77to87_ping, b87to97_ping, b97to107_ping, b107to117_ping, b117to127_ping, b127to137_ping, b137to147_ping, b147to157_ping, b157to167_ping;
wire [`DWIDTH-1:0] b08to18_ping, b18to28_ping, b28to38_ping, b38to48_ping, b48to58_ping, b58to68_ping, b68to78_ping, b78to88_ping, b88to98_ping, b98to108_ping, b108to118_ping, b118to128_ping, b128to138_ping, b138to148_ping, b148to158_ping, b158to168_ping;
wire [`DWIDTH-1:0] b09to19_ping, b19to29_ping, b29to39_ping, b39to49_ping, b49to59_ping, b59to69_ping, b69to79_ping, b79to89_ping, b89to99_ping, b99to109_ping, b109to119_ping, b119to129_ping, b129to139_ping, b139to149_ping, b149to159_ping, b159to169_ping;
wire [`DWIDTH-1:0] b010to110_ping, b110to210_ping, b210to310_ping, b310to410_ping, b410to510_ping, b510to610_ping, b610to710_ping, b710to810_ping, b810to910_ping, b910to1010_ping, b1010to1110_ping, b1110to1210_ping, b1210to1310_ping, b1310to1410_ping, b1410to1510_ping, b1510to1610_ping;
wire [`DWIDTH-1:0] b011to111_ping, b111to211_ping, b211to311_ping, b311to411_ping, b411to511_ping, b511to611_ping, b611to711_ping, b711to811_ping, b811to911_ping, b911to1011_ping, b1011to1111_ping, b1111to1211_ping, b1211to1311_ping, b1311to1411_ping, b1411to1511_ping, b1511to1611_ping;
wire [`DWIDTH-1:0] b012to112_ping, b112to212_ping, b212to312_ping, b312to412_ping, b412to512_ping, b512to612_ping, b612to712_ping, b712to812_ping, b812to912_ping, b912to1012_ping, b1012to1112_ping, b1112to1212_ping, b1212to1312_ping, b1312to1412_ping, b1412to1512_ping, b1512to1612_ping;
wire [`DWIDTH-1:0] b013to113_ping, b113to213_ping, b213to313_ping, b313to413_ping, b413to513_ping, b513to613_ping, b613to713_ping, b713to813_ping, b813to913_ping, b913to1013_ping, b1013to1113_ping, b1113to1213_ping, b1213to1313_ping, b1313to1413_ping, b1413to1513_ping, b1513to1613_ping;
wire [`DWIDTH-1:0] b014to114_ping, b114to214_ping, b214to314_ping, b314to414_ping, b414to514_ping, b514to614_ping, b614to714_ping, b714to814_ping, b814to914_ping, b914to1014_ping, b1014to1114_ping, b1114to1214_ping, b1214to1314_ping, b1314to1414_ping, b1414to1514_ping, b1514to1614_ping;
wire [`DWIDTH-1:0] b015to115_ping, b115to215_ping, b215to315_ping, b315to415_ping, b415to515_ping, b515to615_ping, b615to715_ping, b715to815_ping, b815to915_ping, b915to1015_ping, b1015to1115_ping, b1115to1215_ping, b1215to1315_ping, b1315to1415_ping, b1415to1515_ping, b1515to1615_ping;

wire [`DWIDTH-1:0] b00to10_pong, b10to20_pong, b20to30_pong, b30to40_pong, b40to50_pong, b50to60_pong, b60to70_pong, b70to80_pong, b80to90_pong, b90to100_pong, b100to110_pong, b110to120_pong, b120to130_pong, b130to140_pong, b140to150_pong, b150to160_pong;
wire [`DWIDTH-1:0] b01to11_pong, b11to21_pong, b21to31_pong, b31to41_pong, b41to51_pong, b51to61_pong, b61to71_pong, b71to81_pong, b81to91_pong, b91to101_pong, b101to111_pong, b111to121_pong, b121to131_pong, b131to141_pong, b141to151_pong, b151to161_pong;
wire [`DWIDTH-1:0] b02to12_pong, b12to22_pong, b22to32_pong, b32to42_pong, b42to52_pong, b52to62_pong, b62to72_pong, b72to82_pong, b82to92_pong, b92to102_pong, b102to112_pong, b112to122_pong, b122to132_pong, b132to142_pong, b142to152_pong, b152to162_pong;
wire [`DWIDTH-1:0] b03to13_pong, b13to23_pong, b23to33_pong, b33to43_pong, b43to53_pong, b53to63_pong, b63to73_pong, b73to83_pong, b83to93_pong, b93to103_pong, b103to113_pong, b113to123_pong, b123to133_pong, b133to143_pong, b143to153_pong, b153to163_pong;
wire [`DWIDTH-1:0] b04to14_pong, b14to24_pong, b24to34_pong, b34to44_pong, b44to54_pong, b54to64_pong, b64to74_pong, b74to84_pong, b84to94_pong, b94to104_pong, b104to114_pong, b114to124_pong, b124to134_pong, b134to144_pong, b144to154_pong, b154to164_pong;
wire [`DWIDTH-1:0] b05to15_pong, b15to25_pong, b25to35_pong, b35to45_pong, b45to55_pong, b55to65_pong, b65to75_pong, b75to85_pong, b85to95_pong, b95to105_pong, b105to115_pong, b115to125_pong, b125to135_pong, b135to145_pong, b145to155_pong, b155to165_pong;
wire [`DWIDTH-1:0] b06to16_pong, b16to26_pong, b26to36_pong, b36to46_pong, b46to56_pong, b56to66_pong, b66to76_pong, b76to86_pong, b86to96_pong, b96to106_pong, b106to116_pong, b116to126_pong, b126to136_pong, b136to146_pong, b146to156_pong, b156to166_pong;
wire [`DWIDTH-1:0] b07to17_pong, b17to27_pong, b27to37_pong, b37to47_pong, b47to57_pong, b57to67_pong, b67to77_pong, b77to87_pong, b87to97_pong, b97to107_pong, b107to117_pong, b117to127_pong, b127to137_pong, b137to147_pong, b147to157_pong, b157to167_pong;
wire [`DWIDTH-1:0] b08to18_pong, b18to28_pong, b28to38_pong, b38to48_pong, b48to58_pong, b58to68_pong, b68to78_pong, b78to88_pong, b88to98_pong, b98to108_pong, b108to118_pong, b118to128_pong, b128to138_pong, b138to148_pong, b148to158_pong, b158to168_pong;
wire [`DWIDTH-1:0] b09to19_pong, b19to29_pong, b29to39_pong, b39to49_pong, b49to59_pong, b59to69_pong, b69to79_pong, b79to89_pong, b89to99_pong, b99to109_pong, b109to119_pong, b119to129_pong, b129to139_pong, b139to149_pong, b149to159_pong, b159to169_pong;
wire [`DWIDTH-1:0] b010to110_pong, b110to210_pong, b210to310_pong, b310to410_pong, b410to510_pong, b510to610_pong, b610to710_pong, b710to810_pong, b810to910_pong, b910to1010_pong, b1010to1110_pong, b1110to1210_pong, b1210to1310_pong, b1310to1410_pong, b1410to1510_pong, b1510to1610_pong;
wire [`DWIDTH-1:0] b011to111_pong, b111to211_pong, b211to311_pong, b311to411_pong, b411to511_pong, b511to611_pong, b611to711_pong, b711to811_pong, b811to911_pong, b911to1011_pong, b1011to1111_pong, b1111to1211_pong, b1211to1311_pong, b1311to1411_pong, b1411to1511_pong, b1511to1611_pong;
wire [`DWIDTH-1:0] b012to112_pong, b112to212_pong, b212to312_pong, b312to412_pong, b412to512_pong, b512to612_pong, b612to712_pong, b712to812_pong, b812to912_pong, b912to1012_pong, b1012to1112_pong, b1112to1212_pong, b1212to1312_pong, b1312to1412_pong, b1412to1512_pong, b1512to1612_pong;
wire [`DWIDTH-1:0] b013to113_pong, b113to213_pong, b213to313_pong, b313to413_pong, b413to513_pong, b513to613_pong, b613to713_pong, b713to813_pong, b813to913_pong, b913to1013_pong, b1013to1113_pong, b1113to1213_pong, b1213to1313_pong, b1313to1413_pong, b1413to1513_pong, b1513to1613_pong;
wire [`DWIDTH-1:0] b014to114_pong, b114to214_pong, b214to314_pong, b314to414_pong, b414to514_pong, b514to614_pong, b614to714_pong, b714to814_pong, b814to914_pong, b914to1014_pong, b1014to1114_pong, b1114to1214_pong, b1214to1314_pong, b1314to1414_pong, b1414to1514_pong, b1514to1614_pong;
wire [`DWIDTH-1:0] b015to115_pong, b115to215_pong, b215to315_pong, b315to415_pong, b415to515_pong, b515to615_pong, b615to715_pong, b715to815_pong, b815to915_pong, b915to1015_pong, b1015to1115_pong, b1115to1215_pong, b1215to1315_pong, b1315to1415_pong, b1415to1515_pong, b1515to1615_pong;

reg [`DWIDTH-1:0] b0_data, b1_data, b2_data, b3_data, b4_data, b5_data, b6_data, b7_data, b8_data, b9_data, b10_data, b11_data, b12_data, b13_data, b14_data, b15_data; 

wire effective_rst;
assign effective_rst = reset | pe_reset;

reg b_data_sel_delay1;
reg b_data_sel_delay2;
reg b_data_sel_delay3;
reg b_data_sel_delay4;
reg b_data_sel_delay5;
reg b_data_sel_delay6;
reg b_data_sel_delay7;
reg b_data_sel_delay8;
reg b_data_sel_delay9;
reg b_data_sel_delay10;
reg b_data_sel_delay11;
reg b_data_sel_delay12;
reg b_data_sel_delay13;
reg b_data_sel_delay14;
reg b_data_sel_delay15;
reg b_data_sel_delay16;
reg b_data_sel_delay17;
reg b_data_sel_delay18;
reg b_data_sel_delay19;
reg b_data_sel_delay20;
reg b_data_sel_delay21;
reg b_data_sel_delay22;
reg b_data_sel_delay23;
reg b_data_sel_delay24;
reg b_data_sel_delay25;
reg b_data_sel_delay26;
reg b_data_sel_delay27;
reg b_data_sel_delay28;
reg b_data_sel_delay29;
reg b_data_sel_delay30;

always @ (posedge clk) begin
    if (reset) begin
        b_data_sel_delay1 <= 0;
        b_data_sel_delay2 <= 0;
        b_data_sel_delay3 <= 0;
        b_data_sel_delay4 <= 0;
        b_data_sel_delay5 <= 0;
        b_data_sel_delay6 <= 0;
        b_data_sel_delay7 <= 0;
        b_data_sel_delay8 <= 0;
        b_data_sel_delay9 <= 0;
        b_data_sel_delay10 <= 0;
        b_data_sel_delay11 <= 0;
        b_data_sel_delay12 <= 0;
        b_data_sel_delay13 <= 0;
        b_data_sel_delay14 <= 0;
        b_data_sel_delay15 <= 0;
        b_data_sel_delay16 <= 0;
        b_data_sel_delay17 <= 0;
        b_data_sel_delay18 <= 0;
        b_data_sel_delay19 <= 0;
        b_data_sel_delay20 <= 0;
        b_data_sel_delay21 <= 0;
        b_data_sel_delay22 <= 0;
        b_data_sel_delay23 <= 0;
        b_data_sel_delay24 <= 0;
        b_data_sel_delay25 <= 0;
        b_data_sel_delay26 <= 0;
        b_data_sel_delay27 <= 0;
        b_data_sel_delay28 <= 0;
        b_data_sel_delay29 <= 0;
        b_data_sel_delay30 <= 0;
    end
    else begin
        b_data_sel_delay1 <= b_data_sel;
        b_data_sel_delay2 <= b_data_sel_delay1;
        b_data_sel_delay3 <= b_data_sel_delay2;
        b_data_sel_delay4 <= b_data_sel_delay3;
        b_data_sel_delay5 <= b_data_sel_delay4;
        b_data_sel_delay6 <= b_data_sel_delay5;
        b_data_sel_delay7 <= b_data_sel_delay6;
        b_data_sel_delay8 <= b_data_sel_delay7;
        b_data_sel_delay9 <= b_data_sel_delay8;
        b_data_sel_delay10 <= b_data_sel_delay9;
        b_data_sel_delay11 <= b_data_sel_delay10;
        b_data_sel_delay12 <= b_data_sel_delay11;
        b_data_sel_delay13 <= b_data_sel_delay12;
        b_data_sel_delay14 <= b_data_sel_delay13;
        b_data_sel_delay15 <= b_data_sel_delay14;
        b_data_sel_delay16 <= b_data_sel_delay15;
        b_data_sel_delay17 <= b_data_sel_delay16;
        b_data_sel_delay18 <= b_data_sel_delay17;
        b_data_sel_delay19 <= b_data_sel_delay18;
        b_data_sel_delay20 <= b_data_sel_delay19;
        b_data_sel_delay21 <= b_data_sel_delay20;
        b_data_sel_delay22 <= b_data_sel_delay21;
        b_data_sel_delay23 <= b_data_sel_delay22;
        b_data_sel_delay24 <= b_data_sel_delay23;
        b_data_sel_delay25 <= b_data_sel_delay24;
        b_data_sel_delay26 <= b_data_sel_delay25;
        b_data_sel_delay27 <= b_data_sel_delay26;
        b_data_sel_delay28 <= b_data_sel_delay27;
        b_data_sel_delay29 <= b_data_sel_delay28;
        b_data_sel_delay30 <= b_data_sel_delay29;
  	end
end

// Signals for Each PONG buffer

reg b_data_valid_pong_delay01;
reg b_data_valid_pong_delay02;
reg b_data_valid_pong_delay03;
reg b_data_valid_pong_delay04;
reg b_data_valid_pong_delay05;
reg b_data_valid_pong_delay06;
reg b_data_valid_pong_delay07;
reg b_data_valid_pong_delay08;
reg b_data_valid_pong_delay09;
reg b_data_valid_pong_delay010;
reg b_data_valid_pong_delay011;
reg b_data_valid_pong_delay012;
reg b_data_valid_pong_delay013;
reg b_data_valid_pong_delay014;
reg b_data_valid_pong_delay015;
reg b_data_valid_pong_delay016;
reg b_data_valid_pong_delay017;
reg b_data_valid_pong_delay018;
reg b_data_valid_pong_delay019;
reg b_data_valid_pong_delay020;
reg b_data_valid_pong_delay021;
reg b_data_valid_pong_delay022;
reg b_data_valid_pong_delay023;
reg b_data_valid_pong_delay024;
reg b_data_valid_pong_delay025;
reg b_data_valid_pong_delay026;
reg b_data_valid_pong_delay027;
reg b_data_valid_pong_delay028;
reg b_data_valid_pong_delay029;
reg b_data_valid_pong_delay030;
wire b_data_valid_pong_delay10;
wire b_data_valid_pong_delay20;
wire b_data_valid_pong_delay30;
wire b_data_valid_pong_delay40;
wire b_data_valid_pong_delay50;
wire b_data_valid_pong_delay60;
wire b_data_valid_pong_delay70;
wire b_data_valid_pong_delay80;
wire b_data_valid_pong_delay90;
wire b_data_valid_pong_delay100;
wire b_data_valid_pong_delay110;
wire b_data_valid_pong_delay120;
wire b_data_valid_pong_delay130;
wire b_data_valid_pong_delay140;
wire b_data_valid_pong_delay150;
wire b_data_valid_pong_delay11;
wire b_data_valid_pong_delay21;
wire b_data_valid_pong_delay31;
wire b_data_valid_pong_delay41;
wire b_data_valid_pong_delay51;
wire b_data_valid_pong_delay61;
wire b_data_valid_pong_delay71;
wire b_data_valid_pong_delay81;
wire b_data_valid_pong_delay91;
wire b_data_valid_pong_delay101;
wire b_data_valid_pong_delay111;
wire b_data_valid_pong_delay121;
wire b_data_valid_pong_delay131;
wire b_data_valid_pong_delay141;
wire b_data_valid_pong_delay151;
wire b_data_valid_pong_delay12;
wire b_data_valid_pong_delay22;
wire b_data_valid_pong_delay32;
wire b_data_valid_pong_delay42;
wire b_data_valid_pong_delay52;
wire b_data_valid_pong_delay62;
wire b_data_valid_pong_delay72;
wire b_data_valid_pong_delay82;
wire b_data_valid_pong_delay92;
wire b_data_valid_pong_delay102;
wire b_data_valid_pong_delay112;
wire b_data_valid_pong_delay122;
wire b_data_valid_pong_delay132;
wire b_data_valid_pong_delay142;
wire b_data_valid_pong_delay152;
wire b_data_valid_pong_delay13;
wire b_data_valid_pong_delay23;
wire b_data_valid_pong_delay33;
wire b_data_valid_pong_delay43;
wire b_data_valid_pong_delay53;
wire b_data_valid_pong_delay63;
wire b_data_valid_pong_delay73;
wire b_data_valid_pong_delay83;
wire b_data_valid_pong_delay93;
wire b_data_valid_pong_delay103;
wire b_data_valid_pong_delay113;
wire b_data_valid_pong_delay123;
wire b_data_valid_pong_delay133;
wire b_data_valid_pong_delay143;
wire b_data_valid_pong_delay153;
wire b_data_valid_pong_delay14;
wire b_data_valid_pong_delay24;
wire b_data_valid_pong_delay34;
wire b_data_valid_pong_delay44;
wire b_data_valid_pong_delay54;
wire b_data_valid_pong_delay64;
wire b_data_valid_pong_delay74;
wire b_data_valid_pong_delay84;
wire b_data_valid_pong_delay94;
wire b_data_valid_pong_delay104;
wire b_data_valid_pong_delay114;
wire b_data_valid_pong_delay124;
wire b_data_valid_pong_delay134;
wire b_data_valid_pong_delay144;
wire b_data_valid_pong_delay154;
wire b_data_valid_pong_delay15;
wire b_data_valid_pong_delay25;
wire b_data_valid_pong_delay35;
wire b_data_valid_pong_delay45;
wire b_data_valid_pong_delay55;
wire b_data_valid_pong_delay65;
wire b_data_valid_pong_delay75;
wire b_data_valid_pong_delay85;
wire b_data_valid_pong_delay95;
wire b_data_valid_pong_delay105;
wire b_data_valid_pong_delay115;
wire b_data_valid_pong_delay125;
wire b_data_valid_pong_delay135;
wire b_data_valid_pong_delay145;
wire b_data_valid_pong_delay155;
wire b_data_valid_pong_delay16;
wire b_data_valid_pong_delay26;
wire b_data_valid_pong_delay36;
wire b_data_valid_pong_delay46;
wire b_data_valid_pong_delay56;
wire b_data_valid_pong_delay66;
wire b_data_valid_pong_delay76;
wire b_data_valid_pong_delay86;
wire b_data_valid_pong_delay96;
wire b_data_valid_pong_delay106;
wire b_data_valid_pong_delay116;
wire b_data_valid_pong_delay126;
wire b_data_valid_pong_delay136;
wire b_data_valid_pong_delay146;
wire b_data_valid_pong_delay156;
wire b_data_valid_pong_delay17;
wire b_data_valid_pong_delay27;
wire b_data_valid_pong_delay37;
wire b_data_valid_pong_delay47;
wire b_data_valid_pong_delay57;
wire b_data_valid_pong_delay67;
wire b_data_valid_pong_delay77;
wire b_data_valid_pong_delay87;
wire b_data_valid_pong_delay97;
wire b_data_valid_pong_delay107;
wire b_data_valid_pong_delay117;
wire b_data_valid_pong_delay127;
wire b_data_valid_pong_delay137;
wire b_data_valid_pong_delay147;
wire b_data_valid_pong_delay157;
wire b_data_valid_pong_delay18;
wire b_data_valid_pong_delay28;
wire b_data_valid_pong_delay38;
wire b_data_valid_pong_delay48;
wire b_data_valid_pong_delay58;
wire b_data_valid_pong_delay68;
wire b_data_valid_pong_delay78;
wire b_data_valid_pong_delay88;
wire b_data_valid_pong_delay98;
wire b_data_valid_pong_delay108;
wire b_data_valid_pong_delay118;
wire b_data_valid_pong_delay128;
wire b_data_valid_pong_delay138;
wire b_data_valid_pong_delay148;
wire b_data_valid_pong_delay158;
wire b_data_valid_pong_delay19;
wire b_data_valid_pong_delay29;
wire b_data_valid_pong_delay39;
wire b_data_valid_pong_delay49;
wire b_data_valid_pong_delay59;
wire b_data_valid_pong_delay69;
wire b_data_valid_pong_delay79;
wire b_data_valid_pong_delay89;
wire b_data_valid_pong_delay99;
wire b_data_valid_pong_delay109;
wire b_data_valid_pong_delay119;
wire b_data_valid_pong_delay129;
wire b_data_valid_pong_delay139;
wire b_data_valid_pong_delay149;
wire b_data_valid_pong_delay159;
wire b_data_valid_pong_delay110;
wire b_data_valid_pong_delay210;
wire b_data_valid_pong_delay310;
wire b_data_valid_pong_delay410;
wire b_data_valid_pong_delay510;
wire b_data_valid_pong_delay610;
wire b_data_valid_pong_delay710;
wire b_data_valid_pong_delay810;
wire b_data_valid_pong_delay910;
wire b_data_valid_pong_delay1010;
wire b_data_valid_pong_delay1110;
wire b_data_valid_pong_delay1210;
wire b_data_valid_pong_delay1310;
wire b_data_valid_pong_delay1410;
wire b_data_valid_pong_delay1510;
wire b_data_valid_pong_delay111;
wire b_data_valid_pong_delay211;
wire b_data_valid_pong_delay311;
wire b_data_valid_pong_delay411;
wire b_data_valid_pong_delay511;
wire b_data_valid_pong_delay611;
wire b_data_valid_pong_delay711;
wire b_data_valid_pong_delay811;
wire b_data_valid_pong_delay911;
wire b_data_valid_pong_delay1011;
wire b_data_valid_pong_delay1111;
wire b_data_valid_pong_delay1211;
wire b_data_valid_pong_delay1311;
wire b_data_valid_pong_delay1411;
wire b_data_valid_pong_delay1511;
wire b_data_valid_pong_delay112;
wire b_data_valid_pong_delay212;
wire b_data_valid_pong_delay312;
wire b_data_valid_pong_delay412;
wire b_data_valid_pong_delay512;
wire b_data_valid_pong_delay612;
wire b_data_valid_pong_delay712;
wire b_data_valid_pong_delay812;
wire b_data_valid_pong_delay912;
wire b_data_valid_pong_delay1012;
wire b_data_valid_pong_delay1112;
wire b_data_valid_pong_delay1212;
wire b_data_valid_pong_delay1312;
wire b_data_valid_pong_delay1412;
wire b_data_valid_pong_delay1512;
wire b_data_valid_pong_delay113;
wire b_data_valid_pong_delay213;
wire b_data_valid_pong_delay313;
wire b_data_valid_pong_delay413;
wire b_data_valid_pong_delay513;
wire b_data_valid_pong_delay613;
wire b_data_valid_pong_delay713;
wire b_data_valid_pong_delay813;
wire b_data_valid_pong_delay913;
wire b_data_valid_pong_delay1013;
wire b_data_valid_pong_delay1113;
wire b_data_valid_pong_delay1213;
wire b_data_valid_pong_delay1313;
wire b_data_valid_pong_delay1413;
wire b_data_valid_pong_delay1513;
wire b_data_valid_pong_delay114;
wire b_data_valid_pong_delay214;
wire b_data_valid_pong_delay314;
wire b_data_valid_pong_delay414;
wire b_data_valid_pong_delay514;
wire b_data_valid_pong_delay614;
wire b_data_valid_pong_delay714;
wire b_data_valid_pong_delay814;
wire b_data_valid_pong_delay914;
wire b_data_valid_pong_delay1014;
wire b_data_valid_pong_delay1114;
wire b_data_valid_pong_delay1214;
wire b_data_valid_pong_delay1314;
wire b_data_valid_pong_delay1414;
wire b_data_valid_pong_delay1514;
wire b_data_valid_pong_delay115;
wire b_data_valid_pong_delay215;
wire b_data_valid_pong_delay315;
wire b_data_valid_pong_delay415;
wire b_data_valid_pong_delay515;
wire b_data_valid_pong_delay615;
wire b_data_valid_pong_delay715;
wire b_data_valid_pong_delay815;
wire b_data_valid_pong_delay915;
wire b_data_valid_pong_delay1015;
wire b_data_valid_pong_delay1115;
wire b_data_valid_pong_delay1215;
wire b_data_valid_pong_delay1315;
wire b_data_valid_pong_delay1415;
wire b_data_valid_pong_delay1515;
  
always @ (posedge clk) begin
    b_data_valid_pong_delay01 <= b_data_valid_pong;
    b_data_valid_pong_delay02 <= b_data_valid_pong_delay01;
    b_data_valid_pong_delay03 <= b_data_valid_pong_delay02;
    b_data_valid_pong_delay04 <= b_data_valid_pong_delay03;
    b_data_valid_pong_delay05 <= b_data_valid_pong_delay04;
    b_data_valid_pong_delay06 <= b_data_valid_pong_delay05;
    b_data_valid_pong_delay07 <= b_data_valid_pong_delay06;
    b_data_valid_pong_delay08 <= b_data_valid_pong_delay07;
    b_data_valid_pong_delay09 <= b_data_valid_pong_delay08;
    b_data_valid_pong_delay010 <= b_data_valid_pong_delay09;
    b_data_valid_pong_delay011 <= b_data_valid_pong_delay010;
    b_data_valid_pong_delay012 <= b_data_valid_pong_delay011;
    b_data_valid_pong_delay013 <= b_data_valid_pong_delay012;
    b_data_valid_pong_delay014 <= b_data_valid_pong_delay013;
    b_data_valid_pong_delay015 <= b_data_valid_pong_delay014;
    b_data_valid_pong_delay016 <= b_data_valid_pong_delay015;
    b_data_valid_pong_delay017 <= b_data_valid_pong_delay016;
    b_data_valid_pong_delay018 <= b_data_valid_pong_delay017;
    b_data_valid_pong_delay019 <= b_data_valid_pong_delay018;
    b_data_valid_pong_delay020 <= b_data_valid_pong_delay019;
    b_data_valid_pong_delay021 <= b_data_valid_pong_delay020;
    b_data_valid_pong_delay022 <= b_data_valid_pong_delay021;
    b_data_valid_pong_delay023 <= b_data_valid_pong_delay022;
    b_data_valid_pong_delay024 <= b_data_valid_pong_delay023;
    b_data_valid_pong_delay025 <= b_data_valid_pong_delay024;
    b_data_valid_pong_delay026 <= b_data_valid_pong_delay025;
    b_data_valid_pong_delay027 <= b_data_valid_pong_delay026;
    b_data_valid_pong_delay028 <= b_data_valid_pong_delay027;
    b_data_valid_pong_delay029 <= b_data_valid_pong_delay028;
    b_data_valid_pong_delay030 <= b_data_valid_pong_delay029;
end

assign b_data_valid_pong_delay10 = b_data_valid_pong & b_data_valid_pong_delay01;
assign b_data_valid_pong_delay20 = b_data_valid_pong & b_data_valid_pong_delay02;
assign b_data_valid_pong_delay30 = b_data_valid_pong & b_data_valid_pong_delay03;
assign b_data_valid_pong_delay40 = b_data_valid_pong & b_data_valid_pong_delay04;
assign b_data_valid_pong_delay50 = b_data_valid_pong & b_data_valid_pong_delay05;
assign b_data_valid_pong_delay60 = b_data_valid_pong & b_data_valid_pong_delay06;
assign b_data_valid_pong_delay70 = b_data_valid_pong & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay80 = b_data_valid_pong & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay90 = b_data_valid_pong & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay100 = b_data_valid_pong & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay110 = b_data_valid_pong & b_data_valid_pong_delay011;
assign b_data_valid_pong_delay120 = b_data_valid_pong & b_data_valid_pong_delay012;
assign b_data_valid_pong_delay130 = b_data_valid_pong & b_data_valid_pong_delay013;
assign b_data_valid_pong_delay140 = b_data_valid_pong & b_data_valid_pong_delay014;
assign b_data_valid_pong_delay150 = b_data_valid_pong & b_data_valid_pong_delay015;
assign b_data_valid_pong_delay11 = b_data_valid_pong_delay01 & b_data_valid_pong_delay02;
assign b_data_valid_pong_delay21 = b_data_valid_pong_delay01 & b_data_valid_pong_delay03;
assign b_data_valid_pong_delay31 = b_data_valid_pong_delay01 & b_data_valid_pong_delay04;
assign b_data_valid_pong_delay41 = b_data_valid_pong_delay01 & b_data_valid_pong_delay05;
assign b_data_valid_pong_delay51 = b_data_valid_pong_delay01 & b_data_valid_pong_delay06;
assign b_data_valid_pong_delay61 = b_data_valid_pong_delay01 & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay71 = b_data_valid_pong_delay01 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay81 = b_data_valid_pong_delay01 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay91 = b_data_valid_pong_delay01 & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay101 = b_data_valid_pong_delay01 & b_data_valid_pong_delay011;
assign b_data_valid_pong_delay111 = b_data_valid_pong_delay01 & b_data_valid_pong_delay012;
assign b_data_valid_pong_delay121 = b_data_valid_pong_delay01 & b_data_valid_pong_delay013;
assign b_data_valid_pong_delay131 = b_data_valid_pong_delay01 & b_data_valid_pong_delay014;
assign b_data_valid_pong_delay141 = b_data_valid_pong_delay01 & b_data_valid_pong_delay015;
assign b_data_valid_pong_delay151 = b_data_valid_pong_delay01 & b_data_valid_pong_delay016;
assign b_data_valid_pong_delay12 = b_data_valid_pong_delay02 & b_data_valid_pong_delay03;
assign b_data_valid_pong_delay22 = b_data_valid_pong_delay02 & b_data_valid_pong_delay04;
assign b_data_valid_pong_delay32 = b_data_valid_pong_delay02 & b_data_valid_pong_delay05;
assign b_data_valid_pong_delay42 = b_data_valid_pong_delay02 & b_data_valid_pong_delay06;
assign b_data_valid_pong_delay52 = b_data_valid_pong_delay02 & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay62 = b_data_valid_pong_delay02 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay72 = b_data_valid_pong_delay02 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay82 = b_data_valid_pong_delay02 & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay92 = b_data_valid_pong_delay02 & b_data_valid_pong_delay011;
assign b_data_valid_pong_delay102 = b_data_valid_pong_delay02 & b_data_valid_pong_delay012;
assign b_data_valid_pong_delay112 = b_data_valid_pong_delay02 & b_data_valid_pong_delay013;
assign b_data_valid_pong_delay122 = b_data_valid_pong_delay02 & b_data_valid_pong_delay014;
assign b_data_valid_pong_delay132 = b_data_valid_pong_delay02 & b_data_valid_pong_delay015;
assign b_data_valid_pong_delay142 = b_data_valid_pong_delay02 & b_data_valid_pong_delay016;
assign b_data_valid_pong_delay152 = b_data_valid_pong_delay02 & b_data_valid_pong_delay017;
assign b_data_valid_pong_delay13 = b_data_valid_pong_delay03 & b_data_valid_pong_delay04;
assign b_data_valid_pong_delay23 = b_data_valid_pong_delay03 & b_data_valid_pong_delay05;
assign b_data_valid_pong_delay33 = b_data_valid_pong_delay03 & b_data_valid_pong_delay06;
assign b_data_valid_pong_delay43 = b_data_valid_pong_delay03 & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay53 = b_data_valid_pong_delay03 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay63 = b_data_valid_pong_delay03 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay73 = b_data_valid_pong_delay03 & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay83 = b_data_valid_pong_delay03 & b_data_valid_pong_delay011;
assign b_data_valid_pong_delay93 = b_data_valid_pong_delay03 & b_data_valid_pong_delay012;
assign b_data_valid_pong_delay103 = b_data_valid_pong_delay03 & b_data_valid_pong_delay013;
assign b_data_valid_pong_delay113 = b_data_valid_pong_delay03 & b_data_valid_pong_delay014;
assign b_data_valid_pong_delay123 = b_data_valid_pong_delay03 & b_data_valid_pong_delay015;
assign b_data_valid_pong_delay133 = b_data_valid_pong_delay03 & b_data_valid_pong_delay016;
assign b_data_valid_pong_delay143 = b_data_valid_pong_delay03 & b_data_valid_pong_delay017;
assign b_data_valid_pong_delay153 = b_data_valid_pong_delay03 & b_data_valid_pong_delay018;
assign b_data_valid_pong_delay14 = b_data_valid_pong_delay04 & b_data_valid_pong_delay05;
assign b_data_valid_pong_delay24 = b_data_valid_pong_delay04 & b_data_valid_pong_delay06;
assign b_data_valid_pong_delay34 = b_data_valid_pong_delay04 & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay44 = b_data_valid_pong_delay04 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay54 = b_data_valid_pong_delay04 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay64 = b_data_valid_pong_delay04 & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay74 = b_data_valid_pong_delay04 & b_data_valid_pong_delay011;
assign b_data_valid_pong_delay84 = b_data_valid_pong_delay04 & b_data_valid_pong_delay012;
assign b_data_valid_pong_delay94 = b_data_valid_pong_delay04 & b_data_valid_pong_delay013;
assign b_data_valid_pong_delay104 = b_data_valid_pong_delay04 & b_data_valid_pong_delay014;
assign b_data_valid_pong_delay114 = b_data_valid_pong_delay04 & b_data_valid_pong_delay015;
assign b_data_valid_pong_delay124 = b_data_valid_pong_delay04 & b_data_valid_pong_delay016;
assign b_data_valid_pong_delay134 = b_data_valid_pong_delay04 & b_data_valid_pong_delay017;
assign b_data_valid_pong_delay144 = b_data_valid_pong_delay04 & b_data_valid_pong_delay018;
assign b_data_valid_pong_delay154 = b_data_valid_pong_delay04 & b_data_valid_pong_delay019;
assign b_data_valid_pong_delay15 = b_data_valid_pong_delay05 & b_data_valid_pong_delay06;
assign b_data_valid_pong_delay25 = b_data_valid_pong_delay05 & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay35 = b_data_valid_pong_delay05 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay45 = b_data_valid_pong_delay05 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay55 = b_data_valid_pong_delay05 & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay65 = b_data_valid_pong_delay05 & b_data_valid_pong_delay011;
assign b_data_valid_pong_delay75 = b_data_valid_pong_delay05 & b_data_valid_pong_delay012;
assign b_data_valid_pong_delay85 = b_data_valid_pong_delay05 & b_data_valid_pong_delay013;
assign b_data_valid_pong_delay95 = b_data_valid_pong_delay05 & b_data_valid_pong_delay014;
assign b_data_valid_pong_delay105 = b_data_valid_pong_delay05 & b_data_valid_pong_delay015;
assign b_data_valid_pong_delay115 = b_data_valid_pong_delay05 & b_data_valid_pong_delay016;
assign b_data_valid_pong_delay125 = b_data_valid_pong_delay05 & b_data_valid_pong_delay017;
assign b_data_valid_pong_delay135 = b_data_valid_pong_delay05 & b_data_valid_pong_delay018;
assign b_data_valid_pong_delay145 = b_data_valid_pong_delay05 & b_data_valid_pong_delay019;
assign b_data_valid_pong_delay155 = b_data_valid_pong_delay05 & b_data_valid_pong_delay020;
assign b_data_valid_pong_delay16 = b_data_valid_pong_delay06 & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay26 = b_data_valid_pong_delay06 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay36 = b_data_valid_pong_delay06 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay46 = b_data_valid_pong_delay06 & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay56 = b_data_valid_pong_delay06 & b_data_valid_pong_delay011;
assign b_data_valid_pong_delay66 = b_data_valid_pong_delay06 & b_data_valid_pong_delay012;
assign b_data_valid_pong_delay76 = b_data_valid_pong_delay06 & b_data_valid_pong_delay013;
assign b_data_valid_pong_delay86 = b_data_valid_pong_delay06 & b_data_valid_pong_delay014;
assign b_data_valid_pong_delay96 = b_data_valid_pong_delay06 & b_data_valid_pong_delay015;
assign b_data_valid_pong_delay106 = b_data_valid_pong_delay06 & b_data_valid_pong_delay016;
assign b_data_valid_pong_delay116 = b_data_valid_pong_delay06 & b_data_valid_pong_delay017;
assign b_data_valid_pong_delay126 = b_data_valid_pong_delay06 & b_data_valid_pong_delay018;
assign b_data_valid_pong_delay136 = b_data_valid_pong_delay06 & b_data_valid_pong_delay019;
assign b_data_valid_pong_delay146 = b_data_valid_pong_delay06 & b_data_valid_pong_delay020;
assign b_data_valid_pong_delay156 = b_data_valid_pong_delay06 & b_data_valid_pong_delay021;
assign b_data_valid_pong_delay17 = b_data_valid_pong_delay07 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay27 = b_data_valid_pong_delay07 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay37 = b_data_valid_pong_delay07 & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay47 = b_data_valid_pong_delay07 & b_data_valid_pong_delay011;
assign b_data_valid_pong_delay57 = b_data_valid_pong_delay07 & b_data_valid_pong_delay012;
assign b_data_valid_pong_delay67 = b_data_valid_pong_delay07 & b_data_valid_pong_delay013;
assign b_data_valid_pong_delay77 = b_data_valid_pong_delay07 & b_data_valid_pong_delay014;
assign b_data_valid_pong_delay87 = b_data_valid_pong_delay07 & b_data_valid_pong_delay015;
assign b_data_valid_pong_delay97 = b_data_valid_pong_delay07 & b_data_valid_pong_delay016;
assign b_data_valid_pong_delay107 = b_data_valid_pong_delay07 & b_data_valid_pong_delay017;
assign b_data_valid_pong_delay117 = b_data_valid_pong_delay07 & b_data_valid_pong_delay018;
assign b_data_valid_pong_delay127 = b_data_valid_pong_delay07 & b_data_valid_pong_delay019;
assign b_data_valid_pong_delay137 = b_data_valid_pong_delay07 & b_data_valid_pong_delay020;
assign b_data_valid_pong_delay147 = b_data_valid_pong_delay07 & b_data_valid_pong_delay021;
assign b_data_valid_pong_delay157 = b_data_valid_pong_delay07 & b_data_valid_pong_delay022;
assign b_data_valid_pong_delay18 = b_data_valid_pong_delay08 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay28 = b_data_valid_pong_delay08 & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay38 = b_data_valid_pong_delay08 & b_data_valid_pong_delay011;
assign b_data_valid_pong_delay48 = b_data_valid_pong_delay08 & b_data_valid_pong_delay012;
assign b_data_valid_pong_delay58 = b_data_valid_pong_delay08 & b_data_valid_pong_delay013;
assign b_data_valid_pong_delay68 = b_data_valid_pong_delay08 & b_data_valid_pong_delay014;
assign b_data_valid_pong_delay78 = b_data_valid_pong_delay08 & b_data_valid_pong_delay015;
assign b_data_valid_pong_delay88 = b_data_valid_pong_delay08 & b_data_valid_pong_delay016;
assign b_data_valid_pong_delay98 = b_data_valid_pong_delay08 & b_data_valid_pong_delay017;
assign b_data_valid_pong_delay108 = b_data_valid_pong_delay08 & b_data_valid_pong_delay018;
assign b_data_valid_pong_delay118 = b_data_valid_pong_delay08 & b_data_valid_pong_delay019;
assign b_data_valid_pong_delay128 = b_data_valid_pong_delay08 & b_data_valid_pong_delay020;
assign b_data_valid_pong_delay138 = b_data_valid_pong_delay08 & b_data_valid_pong_delay021;
assign b_data_valid_pong_delay148 = b_data_valid_pong_delay08 & b_data_valid_pong_delay022;
assign b_data_valid_pong_delay158 = b_data_valid_pong_delay08 & b_data_valid_pong_delay023;
assign b_data_valid_pong_delay19 = b_data_valid_pong_delay09 & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay29 = b_data_valid_pong_delay09 & b_data_valid_pong_delay011;
assign b_data_valid_pong_delay39 = b_data_valid_pong_delay09 & b_data_valid_pong_delay012;
assign b_data_valid_pong_delay49 = b_data_valid_pong_delay09 & b_data_valid_pong_delay013;
assign b_data_valid_pong_delay59 = b_data_valid_pong_delay09 & b_data_valid_pong_delay014;
assign b_data_valid_pong_delay69 = b_data_valid_pong_delay09 & b_data_valid_pong_delay015;
assign b_data_valid_pong_delay79 = b_data_valid_pong_delay09 & b_data_valid_pong_delay016;
assign b_data_valid_pong_delay89 = b_data_valid_pong_delay09 & b_data_valid_pong_delay017;
assign b_data_valid_pong_delay99 = b_data_valid_pong_delay09 & b_data_valid_pong_delay018;
assign b_data_valid_pong_delay109 = b_data_valid_pong_delay09 & b_data_valid_pong_delay019;
assign b_data_valid_pong_delay119 = b_data_valid_pong_delay09 & b_data_valid_pong_delay020;
assign b_data_valid_pong_delay129 = b_data_valid_pong_delay09 & b_data_valid_pong_delay021;
assign b_data_valid_pong_delay139 = b_data_valid_pong_delay09 & b_data_valid_pong_delay022;
assign b_data_valid_pong_delay149 = b_data_valid_pong_delay09 & b_data_valid_pong_delay023;
assign b_data_valid_pong_delay159 = b_data_valid_pong_delay09 & b_data_valid_pong_delay024;
assign b_data_valid_pong_delay110 = b_data_valid_pong_delay010 & b_data_valid_pong_delay011;
assign b_data_valid_pong_delay210 = b_data_valid_pong_delay010 & b_data_valid_pong_delay012;
assign b_data_valid_pong_delay310 = b_data_valid_pong_delay010 & b_data_valid_pong_delay013;
assign b_data_valid_pong_delay410 = b_data_valid_pong_delay010 & b_data_valid_pong_delay014;
assign b_data_valid_pong_delay510 = b_data_valid_pong_delay010 & b_data_valid_pong_delay015;
assign b_data_valid_pong_delay610 = b_data_valid_pong_delay010 & b_data_valid_pong_delay016;
assign b_data_valid_pong_delay710 = b_data_valid_pong_delay010 & b_data_valid_pong_delay017;
assign b_data_valid_pong_delay810 = b_data_valid_pong_delay010 & b_data_valid_pong_delay018;
assign b_data_valid_pong_delay910 = b_data_valid_pong_delay010 & b_data_valid_pong_delay019;
assign b_data_valid_pong_delay1010 = b_data_valid_pong_delay010 & b_data_valid_pong_delay020;
assign b_data_valid_pong_delay1110 = b_data_valid_pong_delay010 & b_data_valid_pong_delay021;
assign b_data_valid_pong_delay1210 = b_data_valid_pong_delay010 & b_data_valid_pong_delay022;
assign b_data_valid_pong_delay1310 = b_data_valid_pong_delay010 & b_data_valid_pong_delay023;
assign b_data_valid_pong_delay1410 = b_data_valid_pong_delay010 & b_data_valid_pong_delay024;
assign b_data_valid_pong_delay1510 = b_data_valid_pong_delay010 & b_data_valid_pong_delay025;
assign b_data_valid_pong_delay111 = b_data_valid_pong_delay011 & b_data_valid_pong_delay012;
assign b_data_valid_pong_delay211 = b_data_valid_pong_delay011 & b_data_valid_pong_delay013;
assign b_data_valid_pong_delay311 = b_data_valid_pong_delay011 & b_data_valid_pong_delay014;
assign b_data_valid_pong_delay411 = b_data_valid_pong_delay011 & b_data_valid_pong_delay015;
assign b_data_valid_pong_delay511 = b_data_valid_pong_delay011 & b_data_valid_pong_delay016;
assign b_data_valid_pong_delay611 = b_data_valid_pong_delay011 & b_data_valid_pong_delay017;
assign b_data_valid_pong_delay711 = b_data_valid_pong_delay011 & b_data_valid_pong_delay018;
assign b_data_valid_pong_delay811 = b_data_valid_pong_delay011 & b_data_valid_pong_delay019;
assign b_data_valid_pong_delay911 = b_data_valid_pong_delay011 & b_data_valid_pong_delay020;
assign b_data_valid_pong_delay1011 = b_data_valid_pong_delay011 & b_data_valid_pong_delay021;
assign b_data_valid_pong_delay1111 = b_data_valid_pong_delay011 & b_data_valid_pong_delay022;
assign b_data_valid_pong_delay1211 = b_data_valid_pong_delay011 & b_data_valid_pong_delay023;
assign b_data_valid_pong_delay1311 = b_data_valid_pong_delay011 & b_data_valid_pong_delay024;
assign b_data_valid_pong_delay1411 = b_data_valid_pong_delay011 & b_data_valid_pong_delay025;
assign b_data_valid_pong_delay1511 = b_data_valid_pong_delay011 & b_data_valid_pong_delay026;
assign b_data_valid_pong_delay112 = b_data_valid_pong_delay012 & b_data_valid_pong_delay013;
assign b_data_valid_pong_delay212 = b_data_valid_pong_delay012 & b_data_valid_pong_delay014;
assign b_data_valid_pong_delay312 = b_data_valid_pong_delay012 & b_data_valid_pong_delay015;
assign b_data_valid_pong_delay412 = b_data_valid_pong_delay012 & b_data_valid_pong_delay016;
assign b_data_valid_pong_delay512 = b_data_valid_pong_delay012 & b_data_valid_pong_delay017;
assign b_data_valid_pong_delay612 = b_data_valid_pong_delay012 & b_data_valid_pong_delay018;
assign b_data_valid_pong_delay712 = b_data_valid_pong_delay012 & b_data_valid_pong_delay019;
assign b_data_valid_pong_delay812 = b_data_valid_pong_delay012 & b_data_valid_pong_delay020;
assign b_data_valid_pong_delay912 = b_data_valid_pong_delay012 & b_data_valid_pong_delay021;
assign b_data_valid_pong_delay1012 = b_data_valid_pong_delay012 & b_data_valid_pong_delay022;
assign b_data_valid_pong_delay1112 = b_data_valid_pong_delay012 & b_data_valid_pong_delay023;
assign b_data_valid_pong_delay1212 = b_data_valid_pong_delay012 & b_data_valid_pong_delay024;
assign b_data_valid_pong_delay1312 = b_data_valid_pong_delay012 & b_data_valid_pong_delay025;
assign b_data_valid_pong_delay1412 = b_data_valid_pong_delay012 & b_data_valid_pong_delay026;
assign b_data_valid_pong_delay1512 = b_data_valid_pong_delay012 & b_data_valid_pong_delay027;
assign b_data_valid_pong_delay113 = b_data_valid_pong_delay013 & b_data_valid_pong_delay014;
assign b_data_valid_pong_delay213 = b_data_valid_pong_delay013 & b_data_valid_pong_delay015;
assign b_data_valid_pong_delay313 = b_data_valid_pong_delay013 & b_data_valid_pong_delay016;
assign b_data_valid_pong_delay413 = b_data_valid_pong_delay013 & b_data_valid_pong_delay017;
assign b_data_valid_pong_delay513 = b_data_valid_pong_delay013 & b_data_valid_pong_delay018;
assign b_data_valid_pong_delay613 = b_data_valid_pong_delay013 & b_data_valid_pong_delay019;
assign b_data_valid_pong_delay713 = b_data_valid_pong_delay013 & b_data_valid_pong_delay020;
assign b_data_valid_pong_delay813 = b_data_valid_pong_delay013 & b_data_valid_pong_delay021;
assign b_data_valid_pong_delay913 = b_data_valid_pong_delay013 & b_data_valid_pong_delay022;
assign b_data_valid_pong_delay1013 = b_data_valid_pong_delay013 & b_data_valid_pong_delay023;
assign b_data_valid_pong_delay1113 = b_data_valid_pong_delay013 & b_data_valid_pong_delay024;
assign b_data_valid_pong_delay1213 = b_data_valid_pong_delay013 & b_data_valid_pong_delay025;
assign b_data_valid_pong_delay1313 = b_data_valid_pong_delay013 & b_data_valid_pong_delay026;
assign b_data_valid_pong_delay1413 = b_data_valid_pong_delay013 & b_data_valid_pong_delay027;
assign b_data_valid_pong_delay1513 = b_data_valid_pong_delay013 & b_data_valid_pong_delay028;
assign b_data_valid_pong_delay114 = b_data_valid_pong_delay014 & b_data_valid_pong_delay015;
assign b_data_valid_pong_delay214 = b_data_valid_pong_delay014 & b_data_valid_pong_delay016;
assign b_data_valid_pong_delay314 = b_data_valid_pong_delay014 & b_data_valid_pong_delay017;
assign b_data_valid_pong_delay414 = b_data_valid_pong_delay014 & b_data_valid_pong_delay018;
assign b_data_valid_pong_delay514 = b_data_valid_pong_delay014 & b_data_valid_pong_delay019;
assign b_data_valid_pong_delay614 = b_data_valid_pong_delay014 & b_data_valid_pong_delay020;
assign b_data_valid_pong_delay714 = b_data_valid_pong_delay014 & b_data_valid_pong_delay021;
assign b_data_valid_pong_delay814 = b_data_valid_pong_delay014 & b_data_valid_pong_delay022;
assign b_data_valid_pong_delay914 = b_data_valid_pong_delay014 & b_data_valid_pong_delay023;
assign b_data_valid_pong_delay1014 = b_data_valid_pong_delay014 & b_data_valid_pong_delay024;
assign b_data_valid_pong_delay1114 = b_data_valid_pong_delay014 & b_data_valid_pong_delay025;
assign b_data_valid_pong_delay1214 = b_data_valid_pong_delay014 & b_data_valid_pong_delay026;
assign b_data_valid_pong_delay1314 = b_data_valid_pong_delay014 & b_data_valid_pong_delay027;
assign b_data_valid_pong_delay1414 = b_data_valid_pong_delay014 & b_data_valid_pong_delay028;
assign b_data_valid_pong_delay1514 = b_data_valid_pong_delay014 & b_data_valid_pong_delay029;
assign b_data_valid_pong_delay115 = b_data_valid_pong_delay015 & b_data_valid_pong_delay016;
assign b_data_valid_pong_delay215 = b_data_valid_pong_delay015 & b_data_valid_pong_delay017;
assign b_data_valid_pong_delay315 = b_data_valid_pong_delay015 & b_data_valid_pong_delay018;
assign b_data_valid_pong_delay415 = b_data_valid_pong_delay015 & b_data_valid_pong_delay019;
assign b_data_valid_pong_delay515 = b_data_valid_pong_delay015 & b_data_valid_pong_delay020;
assign b_data_valid_pong_delay615 = b_data_valid_pong_delay015 & b_data_valid_pong_delay021;
assign b_data_valid_pong_delay715 = b_data_valid_pong_delay015 & b_data_valid_pong_delay022;
assign b_data_valid_pong_delay815 = b_data_valid_pong_delay015 & b_data_valid_pong_delay023;
assign b_data_valid_pong_delay915 = b_data_valid_pong_delay015 & b_data_valid_pong_delay024;
assign b_data_valid_pong_delay1015 = b_data_valid_pong_delay015 & b_data_valid_pong_delay025;
assign b_data_valid_pong_delay1115 = b_data_valid_pong_delay015 & b_data_valid_pong_delay026;
assign b_data_valid_pong_delay1215 = b_data_valid_pong_delay015 & b_data_valid_pong_delay027;
assign b_data_valid_pong_delay1315 = b_data_valid_pong_delay015 & b_data_valid_pong_delay028;
assign b_data_valid_pong_delay1415 = b_data_valid_pong_delay015 & b_data_valid_pong_delay029;
assign b_data_valid_pong_delay1515 = b_data_valid_pong_delay015 & b_data_valid_pong_delay030;

// Signals for Each PING buffer

reg b_data_valid_ping_delay01;
reg b_data_valid_ping_delay02;
reg b_data_valid_ping_delay03;
reg b_data_valid_ping_delay04;
reg b_data_valid_ping_delay05;
reg b_data_valid_ping_delay06;
reg b_data_valid_ping_delay07;
reg b_data_valid_ping_delay08;
reg b_data_valid_ping_delay09;
reg b_data_valid_ping_delay010;
reg b_data_valid_ping_delay011;
reg b_data_valid_ping_delay012;
reg b_data_valid_ping_delay013;
reg b_data_valid_ping_delay014;
reg b_data_valid_ping_delay015;
reg b_data_valid_ping_delay016;
reg b_data_valid_ping_delay017;
reg b_data_valid_ping_delay018;
reg b_data_valid_ping_delay019;
reg b_data_valid_ping_delay020;
reg b_data_valid_ping_delay021;
reg b_data_valid_ping_delay022;
reg b_data_valid_ping_delay023;
reg b_data_valid_ping_delay024;
reg b_data_valid_ping_delay025;
reg b_data_valid_ping_delay026;
reg b_data_valid_ping_delay027;
reg b_data_valid_ping_delay028;
reg b_data_valid_ping_delay029;
reg b_data_valid_ping_delay030;
wire b_data_valid_ping_delay10;
wire b_data_valid_ping_delay20;
wire b_data_valid_ping_delay30;
wire b_data_valid_ping_delay40;
wire b_data_valid_ping_delay50;
wire b_data_valid_ping_delay60;
wire b_data_valid_ping_delay70;
wire b_data_valid_ping_delay80;
wire b_data_valid_ping_delay90;
wire b_data_valid_ping_delay100;
wire b_data_valid_ping_delay110;
wire b_data_valid_ping_delay120;
wire b_data_valid_ping_delay130;
wire b_data_valid_ping_delay140;
wire b_data_valid_ping_delay150;
wire b_data_valid_ping_delay11;
wire b_data_valid_ping_delay21;
wire b_data_valid_ping_delay31;
wire b_data_valid_ping_delay41;
wire b_data_valid_ping_delay51;
wire b_data_valid_ping_delay61;
wire b_data_valid_ping_delay71;
wire b_data_valid_ping_delay81;
wire b_data_valid_ping_delay91;
wire b_data_valid_ping_delay101;
wire b_data_valid_ping_delay111;
wire b_data_valid_ping_delay121;
wire b_data_valid_ping_delay131;
wire b_data_valid_ping_delay141;
wire b_data_valid_ping_delay151;
wire b_data_valid_ping_delay12;
wire b_data_valid_ping_delay22;
wire b_data_valid_ping_delay32;
wire b_data_valid_ping_delay42;
wire b_data_valid_ping_delay52;
wire b_data_valid_ping_delay62;
wire b_data_valid_ping_delay72;
wire b_data_valid_ping_delay82;
wire b_data_valid_ping_delay92;
wire b_data_valid_ping_delay102;
wire b_data_valid_ping_delay112;
wire b_data_valid_ping_delay122;
wire b_data_valid_ping_delay132;
wire b_data_valid_ping_delay142;
wire b_data_valid_ping_delay152;
wire b_data_valid_ping_delay13;
wire b_data_valid_ping_delay23;
wire b_data_valid_ping_delay33;
wire b_data_valid_ping_delay43;
wire b_data_valid_ping_delay53;
wire b_data_valid_ping_delay63;
wire b_data_valid_ping_delay73;
wire b_data_valid_ping_delay83;
wire b_data_valid_ping_delay93;
wire b_data_valid_ping_delay103;
wire b_data_valid_ping_delay113;
wire b_data_valid_ping_delay123;
wire b_data_valid_ping_delay133;
wire b_data_valid_ping_delay143;
wire b_data_valid_ping_delay153;
wire b_data_valid_ping_delay14;
wire b_data_valid_ping_delay24;
wire b_data_valid_ping_delay34;
wire b_data_valid_ping_delay44;
wire b_data_valid_ping_delay54;
wire b_data_valid_ping_delay64;
wire b_data_valid_ping_delay74;
wire b_data_valid_ping_delay84;
wire b_data_valid_ping_delay94;
wire b_data_valid_ping_delay104;
wire b_data_valid_ping_delay114;
wire b_data_valid_ping_delay124;
wire b_data_valid_ping_delay134;
wire b_data_valid_ping_delay144;
wire b_data_valid_ping_delay154;
wire b_data_valid_ping_delay15;
wire b_data_valid_ping_delay25;
wire b_data_valid_ping_delay35;
wire b_data_valid_ping_delay45;
wire b_data_valid_ping_delay55;
wire b_data_valid_ping_delay65;
wire b_data_valid_ping_delay75;
wire b_data_valid_ping_delay85;
wire b_data_valid_ping_delay95;
wire b_data_valid_ping_delay105;
wire b_data_valid_ping_delay115;
wire b_data_valid_ping_delay125;
wire b_data_valid_ping_delay135;
wire b_data_valid_ping_delay145;
wire b_data_valid_ping_delay155;
wire b_data_valid_ping_delay16;
wire b_data_valid_ping_delay26;
wire b_data_valid_ping_delay36;
wire b_data_valid_ping_delay46;
wire b_data_valid_ping_delay56;
wire b_data_valid_ping_delay66;
wire b_data_valid_ping_delay76;
wire b_data_valid_ping_delay86;
wire b_data_valid_ping_delay96;
wire b_data_valid_ping_delay106;
wire b_data_valid_ping_delay116;
wire b_data_valid_ping_delay126;
wire b_data_valid_ping_delay136;
wire b_data_valid_ping_delay146;
wire b_data_valid_ping_delay156;
wire b_data_valid_ping_delay17;
wire b_data_valid_ping_delay27;
wire b_data_valid_ping_delay37;
wire b_data_valid_ping_delay47;
wire b_data_valid_ping_delay57;
wire b_data_valid_ping_delay67;
wire b_data_valid_ping_delay77;
wire b_data_valid_ping_delay87;
wire b_data_valid_ping_delay97;
wire b_data_valid_ping_delay107;
wire b_data_valid_ping_delay117;
wire b_data_valid_ping_delay127;
wire b_data_valid_ping_delay137;
wire b_data_valid_ping_delay147;
wire b_data_valid_ping_delay157;
wire b_data_valid_ping_delay18;
wire b_data_valid_ping_delay28;
wire b_data_valid_ping_delay38;
wire b_data_valid_ping_delay48;
wire b_data_valid_ping_delay58;
wire b_data_valid_ping_delay68;
wire b_data_valid_ping_delay78;
wire b_data_valid_ping_delay88;
wire b_data_valid_ping_delay98;
wire b_data_valid_ping_delay108;
wire b_data_valid_ping_delay118;
wire b_data_valid_ping_delay128;
wire b_data_valid_ping_delay138;
wire b_data_valid_ping_delay148;
wire b_data_valid_ping_delay158;
wire b_data_valid_ping_delay19;
wire b_data_valid_ping_delay29;
wire b_data_valid_ping_delay39;
wire b_data_valid_ping_delay49;
wire b_data_valid_ping_delay59;
wire b_data_valid_ping_delay69;
wire b_data_valid_ping_delay79;
wire b_data_valid_ping_delay89;
wire b_data_valid_ping_delay99;
wire b_data_valid_ping_delay109;
wire b_data_valid_ping_delay119;
wire b_data_valid_ping_delay129;
wire b_data_valid_ping_delay139;
wire b_data_valid_ping_delay149;
wire b_data_valid_ping_delay159;
wire b_data_valid_ping_delay110;
wire b_data_valid_ping_delay210;
wire b_data_valid_ping_delay310;
wire b_data_valid_ping_delay410;
wire b_data_valid_ping_delay510;
wire b_data_valid_ping_delay610;
wire b_data_valid_ping_delay710;
wire b_data_valid_ping_delay810;
wire b_data_valid_ping_delay910;
wire b_data_valid_ping_delay1010;
wire b_data_valid_ping_delay1110;
wire b_data_valid_ping_delay1210;
wire b_data_valid_ping_delay1310;
wire b_data_valid_ping_delay1410;
wire b_data_valid_ping_delay1510;
wire b_data_valid_ping_delay111;
wire b_data_valid_ping_delay211;
wire b_data_valid_ping_delay311;
wire b_data_valid_ping_delay411;
wire b_data_valid_ping_delay511;
wire b_data_valid_ping_delay611;
wire b_data_valid_ping_delay711;
wire b_data_valid_ping_delay811;
wire b_data_valid_ping_delay911;
wire b_data_valid_ping_delay1011;
wire b_data_valid_ping_delay1111;
wire b_data_valid_ping_delay1211;
wire b_data_valid_ping_delay1311;
wire b_data_valid_ping_delay1411;
wire b_data_valid_ping_delay1511;
wire b_data_valid_ping_delay112;
wire b_data_valid_ping_delay212;
wire b_data_valid_ping_delay312;
wire b_data_valid_ping_delay412;
wire b_data_valid_ping_delay512;
wire b_data_valid_ping_delay612;
wire b_data_valid_ping_delay712;
wire b_data_valid_ping_delay812;
wire b_data_valid_ping_delay912;
wire b_data_valid_ping_delay1012;
wire b_data_valid_ping_delay1112;
wire b_data_valid_ping_delay1212;
wire b_data_valid_ping_delay1312;
wire b_data_valid_ping_delay1412;
wire b_data_valid_ping_delay1512;
wire b_data_valid_ping_delay113;
wire b_data_valid_ping_delay213;
wire b_data_valid_ping_delay313;
wire b_data_valid_ping_delay413;
wire b_data_valid_ping_delay513;
wire b_data_valid_ping_delay613;
wire b_data_valid_ping_delay713;
wire b_data_valid_ping_delay813;
wire b_data_valid_ping_delay913;
wire b_data_valid_ping_delay1013;
wire b_data_valid_ping_delay1113;
wire b_data_valid_ping_delay1213;
wire b_data_valid_ping_delay1313;
wire b_data_valid_ping_delay1413;
wire b_data_valid_ping_delay1513;
wire b_data_valid_ping_delay114;
wire b_data_valid_ping_delay214;
wire b_data_valid_ping_delay314;
wire b_data_valid_ping_delay414;
wire b_data_valid_ping_delay514;
wire b_data_valid_ping_delay614;
wire b_data_valid_ping_delay714;
wire b_data_valid_ping_delay814;
wire b_data_valid_ping_delay914;
wire b_data_valid_ping_delay1014;
wire b_data_valid_ping_delay1114;
wire b_data_valid_ping_delay1214;
wire b_data_valid_ping_delay1314;
wire b_data_valid_ping_delay1414;
wire b_data_valid_ping_delay1514;
wire b_data_valid_ping_delay115;
wire b_data_valid_ping_delay215;
wire b_data_valid_ping_delay315;
wire b_data_valid_ping_delay415;
wire b_data_valid_ping_delay515;
wire b_data_valid_ping_delay615;
wire b_data_valid_ping_delay715;
wire b_data_valid_ping_delay815;
wire b_data_valid_ping_delay915;
wire b_data_valid_ping_delay1015;
wire b_data_valid_ping_delay1115;
wire b_data_valid_ping_delay1215;
wire b_data_valid_ping_delay1315;
wire b_data_valid_ping_delay1415;
wire b_data_valid_ping_delay1515;
  
always @ (posedge clk) begin
    b_data_valid_ping_delay01 <= b_data_valid_ping;
    b_data_valid_ping_delay02 <= b_data_valid_ping_delay01;
    b_data_valid_ping_delay03 <= b_data_valid_ping_delay02;
    b_data_valid_ping_delay04 <= b_data_valid_ping_delay03;
    b_data_valid_ping_delay05 <= b_data_valid_ping_delay04;
    b_data_valid_ping_delay06 <= b_data_valid_ping_delay05;
    b_data_valid_ping_delay07 <= b_data_valid_ping_delay06;
    b_data_valid_ping_delay08 <= b_data_valid_ping_delay07;
    b_data_valid_ping_delay09 <= b_data_valid_ping_delay08;
    b_data_valid_ping_delay010 <= b_data_valid_ping_delay09;
    b_data_valid_ping_delay011 <= b_data_valid_ping_delay010;
    b_data_valid_ping_delay012 <= b_data_valid_ping_delay011;
    b_data_valid_ping_delay013 <= b_data_valid_ping_delay012;
    b_data_valid_ping_delay014 <= b_data_valid_ping_delay013;
    b_data_valid_ping_delay015 <= b_data_valid_ping_delay014;
    b_data_valid_ping_delay016 <= b_data_valid_ping_delay015;
    b_data_valid_ping_delay017 <= b_data_valid_ping_delay016;
    b_data_valid_ping_delay018 <= b_data_valid_ping_delay017;
    b_data_valid_ping_delay019 <= b_data_valid_ping_delay018;
    b_data_valid_ping_delay020 <= b_data_valid_ping_delay019;
    b_data_valid_ping_delay021 <= b_data_valid_ping_delay020;
    b_data_valid_ping_delay022 <= b_data_valid_ping_delay021;
    b_data_valid_ping_delay023 <= b_data_valid_ping_delay022;
    b_data_valid_ping_delay024 <= b_data_valid_ping_delay023;
    b_data_valid_ping_delay025 <= b_data_valid_ping_delay024;
    b_data_valid_ping_delay026 <= b_data_valid_ping_delay025;
    b_data_valid_ping_delay027 <= b_data_valid_ping_delay026;
    b_data_valid_ping_delay028 <= b_data_valid_ping_delay027;
    b_data_valid_ping_delay029 <= b_data_valid_ping_delay028;
    b_data_valid_ping_delay030 <= b_data_valid_ping_delay029;
end

assign b_data_valid_ping_delay10 = b_data_valid_ping & b_data_valid_ping_delay01;
assign b_data_valid_ping_delay20 = b_data_valid_ping & b_data_valid_ping_delay02;
assign b_data_valid_ping_delay30 = b_data_valid_ping & b_data_valid_ping_delay03;
assign b_data_valid_ping_delay40 = b_data_valid_ping & b_data_valid_ping_delay04;
assign b_data_valid_ping_delay50 = b_data_valid_ping & b_data_valid_ping_delay05;
assign b_data_valid_ping_delay60 = b_data_valid_ping & b_data_valid_ping_delay06;
assign b_data_valid_ping_delay70 = b_data_valid_ping & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay80 = b_data_valid_ping & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay90 = b_data_valid_ping & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay100 = b_data_valid_ping & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay110 = b_data_valid_ping & b_data_valid_ping_delay011;
assign b_data_valid_ping_delay120 = b_data_valid_ping & b_data_valid_ping_delay012;
assign b_data_valid_ping_delay130 = b_data_valid_ping & b_data_valid_ping_delay013;
assign b_data_valid_ping_delay140 = b_data_valid_ping & b_data_valid_ping_delay014;
assign b_data_valid_ping_delay150 = b_data_valid_ping & b_data_valid_ping_delay015;
assign b_data_valid_ping_delay11 = b_data_valid_ping_delay01 & b_data_valid_ping_delay02;
assign b_data_valid_ping_delay21 = b_data_valid_ping_delay01 & b_data_valid_ping_delay03;
assign b_data_valid_ping_delay31 = b_data_valid_ping_delay01 & b_data_valid_ping_delay04;
assign b_data_valid_ping_delay41 = b_data_valid_ping_delay01 & b_data_valid_ping_delay05;
assign b_data_valid_ping_delay51 = b_data_valid_ping_delay01 & b_data_valid_ping_delay06;
assign b_data_valid_ping_delay61 = b_data_valid_ping_delay01 & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay71 = b_data_valid_ping_delay01 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay81 = b_data_valid_ping_delay01 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay91 = b_data_valid_ping_delay01 & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay101 = b_data_valid_ping_delay01 & b_data_valid_ping_delay011;
assign b_data_valid_ping_delay111 = b_data_valid_ping_delay01 & b_data_valid_ping_delay012;
assign b_data_valid_ping_delay121 = b_data_valid_ping_delay01 & b_data_valid_ping_delay013;
assign b_data_valid_ping_delay131 = b_data_valid_ping_delay01 & b_data_valid_ping_delay014;
assign b_data_valid_ping_delay141 = b_data_valid_ping_delay01 & b_data_valid_ping_delay015;
assign b_data_valid_ping_delay151 = b_data_valid_ping_delay01 & b_data_valid_ping_delay016;
assign b_data_valid_ping_delay12 = b_data_valid_ping_delay02 & b_data_valid_ping_delay03;
assign b_data_valid_ping_delay22 = b_data_valid_ping_delay02 & b_data_valid_ping_delay04;
assign b_data_valid_ping_delay32 = b_data_valid_ping_delay02 & b_data_valid_ping_delay05;
assign b_data_valid_ping_delay42 = b_data_valid_ping_delay02 & b_data_valid_ping_delay06;
assign b_data_valid_ping_delay52 = b_data_valid_ping_delay02 & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay62 = b_data_valid_ping_delay02 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay72 = b_data_valid_ping_delay02 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay82 = b_data_valid_ping_delay02 & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay92 = b_data_valid_ping_delay02 & b_data_valid_ping_delay011;
assign b_data_valid_ping_delay102 = b_data_valid_ping_delay02 & b_data_valid_ping_delay012;
assign b_data_valid_ping_delay112 = b_data_valid_ping_delay02 & b_data_valid_ping_delay013;
assign b_data_valid_ping_delay122 = b_data_valid_ping_delay02 & b_data_valid_ping_delay014;
assign b_data_valid_ping_delay132 = b_data_valid_ping_delay02 & b_data_valid_ping_delay015;
assign b_data_valid_ping_delay142 = b_data_valid_ping_delay02 & b_data_valid_ping_delay016;
assign b_data_valid_ping_delay152 = b_data_valid_ping_delay02 & b_data_valid_ping_delay017;
assign b_data_valid_ping_delay13 = b_data_valid_ping_delay03 & b_data_valid_ping_delay04;
assign b_data_valid_ping_delay23 = b_data_valid_ping_delay03 & b_data_valid_ping_delay05;
assign b_data_valid_ping_delay33 = b_data_valid_ping_delay03 & b_data_valid_ping_delay06;
assign b_data_valid_ping_delay43 = b_data_valid_ping_delay03 & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay53 = b_data_valid_ping_delay03 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay63 = b_data_valid_ping_delay03 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay73 = b_data_valid_ping_delay03 & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay83 = b_data_valid_ping_delay03 & b_data_valid_ping_delay011;
assign b_data_valid_ping_delay93 = b_data_valid_ping_delay03 & b_data_valid_ping_delay012;
assign b_data_valid_ping_delay103 = b_data_valid_ping_delay03 & b_data_valid_ping_delay013;
assign b_data_valid_ping_delay113 = b_data_valid_ping_delay03 & b_data_valid_ping_delay014;
assign b_data_valid_ping_delay123 = b_data_valid_ping_delay03 & b_data_valid_ping_delay015;
assign b_data_valid_ping_delay133 = b_data_valid_ping_delay03 & b_data_valid_ping_delay016;
assign b_data_valid_ping_delay143 = b_data_valid_ping_delay03 & b_data_valid_ping_delay017;
assign b_data_valid_ping_delay153 = b_data_valid_ping_delay03 & b_data_valid_ping_delay018;
assign b_data_valid_ping_delay14 = b_data_valid_ping_delay04 & b_data_valid_ping_delay05;
assign b_data_valid_ping_delay24 = b_data_valid_ping_delay04 & b_data_valid_ping_delay06;
assign b_data_valid_ping_delay34 = b_data_valid_ping_delay04 & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay44 = b_data_valid_ping_delay04 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay54 = b_data_valid_ping_delay04 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay64 = b_data_valid_ping_delay04 & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay74 = b_data_valid_ping_delay04 & b_data_valid_ping_delay011;
assign b_data_valid_ping_delay84 = b_data_valid_ping_delay04 & b_data_valid_ping_delay012;
assign b_data_valid_ping_delay94 = b_data_valid_ping_delay04 & b_data_valid_ping_delay013;
assign b_data_valid_ping_delay104 = b_data_valid_ping_delay04 & b_data_valid_ping_delay014;
assign b_data_valid_ping_delay114 = b_data_valid_ping_delay04 & b_data_valid_ping_delay015;
assign b_data_valid_ping_delay124 = b_data_valid_ping_delay04 & b_data_valid_ping_delay016;
assign b_data_valid_ping_delay134 = b_data_valid_ping_delay04 & b_data_valid_ping_delay017;
assign b_data_valid_ping_delay144 = b_data_valid_ping_delay04 & b_data_valid_ping_delay018;
assign b_data_valid_ping_delay154 = b_data_valid_ping_delay04 & b_data_valid_ping_delay019;
assign b_data_valid_ping_delay15 = b_data_valid_ping_delay05 & b_data_valid_ping_delay06;
assign b_data_valid_ping_delay25 = b_data_valid_ping_delay05 & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay35 = b_data_valid_ping_delay05 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay45 = b_data_valid_ping_delay05 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay55 = b_data_valid_ping_delay05 & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay65 = b_data_valid_ping_delay05 & b_data_valid_ping_delay011;
assign b_data_valid_ping_delay75 = b_data_valid_ping_delay05 & b_data_valid_ping_delay012;
assign b_data_valid_ping_delay85 = b_data_valid_ping_delay05 & b_data_valid_ping_delay013;
assign b_data_valid_ping_delay95 = b_data_valid_ping_delay05 & b_data_valid_ping_delay014;
assign b_data_valid_ping_delay105 = b_data_valid_ping_delay05 & b_data_valid_ping_delay015;
assign b_data_valid_ping_delay115 = b_data_valid_ping_delay05 & b_data_valid_ping_delay016;
assign b_data_valid_ping_delay125 = b_data_valid_ping_delay05 & b_data_valid_ping_delay017;
assign b_data_valid_ping_delay135 = b_data_valid_ping_delay05 & b_data_valid_ping_delay018;
assign b_data_valid_ping_delay145 = b_data_valid_ping_delay05 & b_data_valid_ping_delay019;
assign b_data_valid_ping_delay155 = b_data_valid_ping_delay05 & b_data_valid_ping_delay020;
assign b_data_valid_ping_delay16 = b_data_valid_ping_delay06 & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay26 = b_data_valid_ping_delay06 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay36 = b_data_valid_ping_delay06 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay46 = b_data_valid_ping_delay06 & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay56 = b_data_valid_ping_delay06 & b_data_valid_ping_delay011;
assign b_data_valid_ping_delay66 = b_data_valid_ping_delay06 & b_data_valid_ping_delay012;
assign b_data_valid_ping_delay76 = b_data_valid_ping_delay06 & b_data_valid_ping_delay013;
assign b_data_valid_ping_delay86 = b_data_valid_ping_delay06 & b_data_valid_ping_delay014;
assign b_data_valid_ping_delay96 = b_data_valid_ping_delay06 & b_data_valid_ping_delay015;
assign b_data_valid_ping_delay106 = b_data_valid_ping_delay06 & b_data_valid_ping_delay016;
assign b_data_valid_ping_delay116 = b_data_valid_ping_delay06 & b_data_valid_ping_delay017;
assign b_data_valid_ping_delay126 = b_data_valid_ping_delay06 & b_data_valid_ping_delay018;
assign b_data_valid_ping_delay136 = b_data_valid_ping_delay06 & b_data_valid_ping_delay019;
assign b_data_valid_ping_delay146 = b_data_valid_ping_delay06 & b_data_valid_ping_delay020;
assign b_data_valid_ping_delay156 = b_data_valid_ping_delay06 & b_data_valid_ping_delay021;
assign b_data_valid_ping_delay17 = b_data_valid_ping_delay07 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay27 = b_data_valid_ping_delay07 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay37 = b_data_valid_ping_delay07 & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay47 = b_data_valid_ping_delay07 & b_data_valid_ping_delay011;
assign b_data_valid_ping_delay57 = b_data_valid_ping_delay07 & b_data_valid_ping_delay012;
assign b_data_valid_ping_delay67 = b_data_valid_ping_delay07 & b_data_valid_ping_delay013;
assign b_data_valid_ping_delay77 = b_data_valid_ping_delay07 & b_data_valid_ping_delay014;
assign b_data_valid_ping_delay87 = b_data_valid_ping_delay07 & b_data_valid_ping_delay015;
assign b_data_valid_ping_delay97 = b_data_valid_ping_delay07 & b_data_valid_ping_delay016;
assign b_data_valid_ping_delay107 = b_data_valid_ping_delay07 & b_data_valid_ping_delay017;
assign b_data_valid_ping_delay117 = b_data_valid_ping_delay07 & b_data_valid_ping_delay018;
assign b_data_valid_ping_delay127 = b_data_valid_ping_delay07 & b_data_valid_ping_delay019;
assign b_data_valid_ping_delay137 = b_data_valid_ping_delay07 & b_data_valid_ping_delay020;
assign b_data_valid_ping_delay147 = b_data_valid_ping_delay07 & b_data_valid_ping_delay021;
assign b_data_valid_ping_delay157 = b_data_valid_ping_delay07 & b_data_valid_ping_delay022;
assign b_data_valid_ping_delay18 = b_data_valid_ping_delay08 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay28 = b_data_valid_ping_delay08 & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay38 = b_data_valid_ping_delay08 & b_data_valid_ping_delay011;
assign b_data_valid_ping_delay48 = b_data_valid_ping_delay08 & b_data_valid_ping_delay012;
assign b_data_valid_ping_delay58 = b_data_valid_ping_delay08 & b_data_valid_ping_delay013;
assign b_data_valid_ping_delay68 = b_data_valid_ping_delay08 & b_data_valid_ping_delay014;
assign b_data_valid_ping_delay78 = b_data_valid_ping_delay08 & b_data_valid_ping_delay015;
assign b_data_valid_ping_delay88 = b_data_valid_ping_delay08 & b_data_valid_ping_delay016;
assign b_data_valid_ping_delay98 = b_data_valid_ping_delay08 & b_data_valid_ping_delay017;
assign b_data_valid_ping_delay108 = b_data_valid_ping_delay08 & b_data_valid_ping_delay018;
assign b_data_valid_ping_delay118 = b_data_valid_ping_delay08 & b_data_valid_ping_delay019;
assign b_data_valid_ping_delay128 = b_data_valid_ping_delay08 & b_data_valid_ping_delay020;
assign b_data_valid_ping_delay138 = b_data_valid_ping_delay08 & b_data_valid_ping_delay021;
assign b_data_valid_ping_delay148 = b_data_valid_ping_delay08 & b_data_valid_ping_delay022;
assign b_data_valid_ping_delay158 = b_data_valid_ping_delay08 & b_data_valid_ping_delay023;
assign b_data_valid_ping_delay19 = b_data_valid_ping_delay09 & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay29 = b_data_valid_ping_delay09 & b_data_valid_ping_delay011;
assign b_data_valid_ping_delay39 = b_data_valid_ping_delay09 & b_data_valid_ping_delay012;
assign b_data_valid_ping_delay49 = b_data_valid_ping_delay09 & b_data_valid_ping_delay013;
assign b_data_valid_ping_delay59 = b_data_valid_ping_delay09 & b_data_valid_ping_delay014;
assign b_data_valid_ping_delay69 = b_data_valid_ping_delay09 & b_data_valid_ping_delay015;
assign b_data_valid_ping_delay79 = b_data_valid_ping_delay09 & b_data_valid_ping_delay016;
assign b_data_valid_ping_delay89 = b_data_valid_ping_delay09 & b_data_valid_ping_delay017;
assign b_data_valid_ping_delay99 = b_data_valid_ping_delay09 & b_data_valid_ping_delay018;
assign b_data_valid_ping_delay109 = b_data_valid_ping_delay09 & b_data_valid_ping_delay019;
assign b_data_valid_ping_delay119 = b_data_valid_ping_delay09 & b_data_valid_ping_delay020;
assign b_data_valid_ping_delay129 = b_data_valid_ping_delay09 & b_data_valid_ping_delay021;
assign b_data_valid_ping_delay139 = b_data_valid_ping_delay09 & b_data_valid_ping_delay022;
assign b_data_valid_ping_delay149 = b_data_valid_ping_delay09 & b_data_valid_ping_delay023;
assign b_data_valid_ping_delay159 = b_data_valid_ping_delay09 & b_data_valid_ping_delay024;
assign b_data_valid_ping_delay110 = b_data_valid_ping_delay010 & b_data_valid_ping_delay011;
assign b_data_valid_ping_delay210 = b_data_valid_ping_delay010 & b_data_valid_ping_delay012;
assign b_data_valid_ping_delay310 = b_data_valid_ping_delay010 & b_data_valid_ping_delay013;
assign b_data_valid_ping_delay410 = b_data_valid_ping_delay010 & b_data_valid_ping_delay014;
assign b_data_valid_ping_delay510 = b_data_valid_ping_delay010 & b_data_valid_ping_delay015;
assign b_data_valid_ping_delay610 = b_data_valid_ping_delay010 & b_data_valid_ping_delay016;
assign b_data_valid_ping_delay710 = b_data_valid_ping_delay010 & b_data_valid_ping_delay017;
assign b_data_valid_ping_delay810 = b_data_valid_ping_delay010 & b_data_valid_ping_delay018;
assign b_data_valid_ping_delay910 = b_data_valid_ping_delay010 & b_data_valid_ping_delay019;
assign b_data_valid_ping_delay1010 = b_data_valid_ping_delay010 & b_data_valid_ping_delay020;
assign b_data_valid_ping_delay1110 = b_data_valid_ping_delay010 & b_data_valid_ping_delay021;
assign b_data_valid_ping_delay1210 = b_data_valid_ping_delay010 & b_data_valid_ping_delay022;
assign b_data_valid_ping_delay1310 = b_data_valid_ping_delay010 & b_data_valid_ping_delay023;
assign b_data_valid_ping_delay1410 = b_data_valid_ping_delay010 & b_data_valid_ping_delay024;
assign b_data_valid_ping_delay1510 = b_data_valid_ping_delay010 & b_data_valid_ping_delay025;
assign b_data_valid_ping_delay111 = b_data_valid_ping_delay011 & b_data_valid_ping_delay012;
assign b_data_valid_ping_delay211 = b_data_valid_ping_delay011 & b_data_valid_ping_delay013;
assign b_data_valid_ping_delay311 = b_data_valid_ping_delay011 & b_data_valid_ping_delay014;
assign b_data_valid_ping_delay411 = b_data_valid_ping_delay011 & b_data_valid_ping_delay015;
assign b_data_valid_ping_delay511 = b_data_valid_ping_delay011 & b_data_valid_ping_delay016;
assign b_data_valid_ping_delay611 = b_data_valid_ping_delay011 & b_data_valid_ping_delay017;
assign b_data_valid_ping_delay711 = b_data_valid_ping_delay011 & b_data_valid_ping_delay018;
assign b_data_valid_ping_delay811 = b_data_valid_ping_delay011 & b_data_valid_ping_delay019;
assign b_data_valid_ping_delay911 = b_data_valid_ping_delay011 & b_data_valid_ping_delay020;
assign b_data_valid_ping_delay1011 = b_data_valid_ping_delay011 & b_data_valid_ping_delay021;
assign b_data_valid_ping_delay1111 = b_data_valid_ping_delay011 & b_data_valid_ping_delay022;
assign b_data_valid_ping_delay1211 = b_data_valid_ping_delay011 & b_data_valid_ping_delay023;
assign b_data_valid_ping_delay1311 = b_data_valid_ping_delay011 & b_data_valid_ping_delay024;
assign b_data_valid_ping_delay1411 = b_data_valid_ping_delay011 & b_data_valid_ping_delay025;
assign b_data_valid_ping_delay1511 = b_data_valid_ping_delay011 & b_data_valid_ping_delay026;
assign b_data_valid_ping_delay112 = b_data_valid_ping_delay012 & b_data_valid_ping_delay013;
assign b_data_valid_ping_delay212 = b_data_valid_ping_delay012 & b_data_valid_ping_delay014;
assign b_data_valid_ping_delay312 = b_data_valid_ping_delay012 & b_data_valid_ping_delay015;
assign b_data_valid_ping_delay412 = b_data_valid_ping_delay012 & b_data_valid_ping_delay016;
assign b_data_valid_ping_delay512 = b_data_valid_ping_delay012 & b_data_valid_ping_delay017;
assign b_data_valid_ping_delay612 = b_data_valid_ping_delay012 & b_data_valid_ping_delay018;
assign b_data_valid_ping_delay712 = b_data_valid_ping_delay012 & b_data_valid_ping_delay019;
assign b_data_valid_ping_delay812 = b_data_valid_ping_delay012 & b_data_valid_ping_delay020;
assign b_data_valid_ping_delay912 = b_data_valid_ping_delay012 & b_data_valid_ping_delay021;
assign b_data_valid_ping_delay1012 = b_data_valid_ping_delay012 & b_data_valid_ping_delay022;
assign b_data_valid_ping_delay1112 = b_data_valid_ping_delay012 & b_data_valid_ping_delay023;
assign b_data_valid_ping_delay1212 = b_data_valid_ping_delay012 & b_data_valid_ping_delay024;
assign b_data_valid_ping_delay1312 = b_data_valid_ping_delay012 & b_data_valid_ping_delay025;
assign b_data_valid_ping_delay1412 = b_data_valid_ping_delay012 & b_data_valid_ping_delay026;
assign b_data_valid_ping_delay1512 = b_data_valid_ping_delay012 & b_data_valid_ping_delay027;
assign b_data_valid_ping_delay113 = b_data_valid_ping_delay013 & b_data_valid_ping_delay014;
assign b_data_valid_ping_delay213 = b_data_valid_ping_delay013 & b_data_valid_ping_delay015;
assign b_data_valid_ping_delay313 = b_data_valid_ping_delay013 & b_data_valid_ping_delay016;
assign b_data_valid_ping_delay413 = b_data_valid_ping_delay013 & b_data_valid_ping_delay017;
assign b_data_valid_ping_delay513 = b_data_valid_ping_delay013 & b_data_valid_ping_delay018;
assign b_data_valid_ping_delay613 = b_data_valid_ping_delay013 & b_data_valid_ping_delay019;
assign b_data_valid_ping_delay713 = b_data_valid_ping_delay013 & b_data_valid_ping_delay020;
assign b_data_valid_ping_delay813 = b_data_valid_ping_delay013 & b_data_valid_ping_delay021;
assign b_data_valid_ping_delay913 = b_data_valid_ping_delay013 & b_data_valid_ping_delay022;
assign b_data_valid_ping_delay1013 = b_data_valid_ping_delay013 & b_data_valid_ping_delay023;
assign b_data_valid_ping_delay1113 = b_data_valid_ping_delay013 & b_data_valid_ping_delay024;
assign b_data_valid_ping_delay1213 = b_data_valid_ping_delay013 & b_data_valid_ping_delay025;
assign b_data_valid_ping_delay1313 = b_data_valid_ping_delay013 & b_data_valid_ping_delay026;
assign b_data_valid_ping_delay1413 = b_data_valid_ping_delay013 & b_data_valid_ping_delay027;
assign b_data_valid_ping_delay1513 = b_data_valid_ping_delay013 & b_data_valid_ping_delay028;
assign b_data_valid_ping_delay114 = b_data_valid_ping_delay014 & b_data_valid_ping_delay015;
assign b_data_valid_ping_delay214 = b_data_valid_ping_delay014 & b_data_valid_ping_delay016;
assign b_data_valid_ping_delay314 = b_data_valid_ping_delay014 & b_data_valid_ping_delay017;
assign b_data_valid_ping_delay414 = b_data_valid_ping_delay014 & b_data_valid_ping_delay018;
assign b_data_valid_ping_delay514 = b_data_valid_ping_delay014 & b_data_valid_ping_delay019;
assign b_data_valid_ping_delay614 = b_data_valid_ping_delay014 & b_data_valid_ping_delay020;
assign b_data_valid_ping_delay714 = b_data_valid_ping_delay014 & b_data_valid_ping_delay021;
assign b_data_valid_ping_delay814 = b_data_valid_ping_delay014 & b_data_valid_ping_delay022;
assign b_data_valid_ping_delay914 = b_data_valid_ping_delay014 & b_data_valid_ping_delay023;
assign b_data_valid_ping_delay1014 = b_data_valid_ping_delay014 & b_data_valid_ping_delay024;
assign b_data_valid_ping_delay1114 = b_data_valid_ping_delay014 & b_data_valid_ping_delay025;
assign b_data_valid_ping_delay1214 = b_data_valid_ping_delay014 & b_data_valid_ping_delay026;
assign b_data_valid_ping_delay1314 = b_data_valid_ping_delay014 & b_data_valid_ping_delay027;
assign b_data_valid_ping_delay1414 = b_data_valid_ping_delay014 & b_data_valid_ping_delay028;
assign b_data_valid_ping_delay1514 = b_data_valid_ping_delay014 & b_data_valid_ping_delay029;
assign b_data_valid_ping_delay115 = b_data_valid_ping_delay015 & b_data_valid_ping_delay016;
assign b_data_valid_ping_delay215 = b_data_valid_ping_delay015 & b_data_valid_ping_delay017;
assign b_data_valid_ping_delay315 = b_data_valid_ping_delay015 & b_data_valid_ping_delay018;
assign b_data_valid_ping_delay415 = b_data_valid_ping_delay015 & b_data_valid_ping_delay019;
assign b_data_valid_ping_delay515 = b_data_valid_ping_delay015 & b_data_valid_ping_delay020;
assign b_data_valid_ping_delay615 = b_data_valid_ping_delay015 & b_data_valid_ping_delay021;
assign b_data_valid_ping_delay715 = b_data_valid_ping_delay015 & b_data_valid_ping_delay022;
assign b_data_valid_ping_delay815 = b_data_valid_ping_delay015 & b_data_valid_ping_delay023;
assign b_data_valid_ping_delay915 = b_data_valid_ping_delay015 & b_data_valid_ping_delay024;
assign b_data_valid_ping_delay1015 = b_data_valid_ping_delay015 & b_data_valid_ping_delay025;
assign b_data_valid_ping_delay1115 = b_data_valid_ping_delay015 & b_data_valid_ping_delay026;
assign b_data_valid_ping_delay1215 = b_data_valid_ping_delay015 & b_data_valid_ping_delay027;
assign b_data_valid_ping_delay1315 = b_data_valid_ping_delay015 & b_data_valid_ping_delay028;
assign b_data_valid_ping_delay1415 = b_data_valid_ping_delay015 & b_data_valid_ping_delay029;
assign b_data_valid_ping_delay1515 = b_data_valid_ping_delay015 & b_data_valid_ping_delay030;

processing_element pe00(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel),        .in_a(a0),      .in_b(b0),      .in_c(c0),        .out_a(a00to01), .out_b(b00to10), .out_b0(b00to10_ping), .out_b1(b00to10_pong), .out_c(matrixC00), .b_data_valid_ping(b_data_valid_ping),         .b_data_valid_pong(b_data_valid_pong        ));
processing_element pe01(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay1), .in_a(a00to01), .in_b(b1),      .in_c(c1),        .out_a(a01to02), .out_b(b01to11), .out_b0(b01to11_ping), .out_b1(b01to11_pong), .out_c(matrixC01), .b_data_valid_ping(b_data_valid_ping_delay01), .b_data_valid_pong(b_data_valid_pong_delay01));
processing_element pe02(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay2), .in_a(a01to02), .in_b(b2),      .in_c(c2),        .out_a(a02to03), .out_b(b02to12), .out_b0(b02to12_ping), .out_b1(b02to12_pong), .out_c(matrixC02), .b_data_valid_ping(b_data_valid_ping_delay02), .b_data_valid_pong(b_data_valid_pong_delay02));
processing_element pe03(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay3), .in_a(a02to03), .in_b(b3),      .in_c(c3),        .out_a(a03to04), .out_b(b03to13), .out_b0(b03to13_ping), .out_b1(b03to13_pong), .out_c(matrixC03), .b_data_valid_ping(b_data_valid_ping_delay03), .b_data_valid_pong(b_data_valid_pong_delay03));
processing_element pe04(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay4), .in_a(a03to04), .in_b(b4),      .in_c(c4),        .out_a(a04to05), .out_b(b04to14), .out_b0(b04to14_ping), .out_b1(b04to14_pong), .out_c(matrixC04), .b_data_valid_ping(b_data_valid_ping_delay04), .b_data_valid_pong(b_data_valid_pong_delay04));
processing_element pe05(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay5), .in_a(a04to05), .in_b(b5),      .in_c(c5),        .out_a(a05to06), .out_b(b05to15), .out_b0(b05to15_ping), .out_b1(b05to15_pong), .out_c(matrixC05), .b_data_valid_ping(b_data_valid_ping_delay05), .b_data_valid_pong(b_data_valid_pong_delay05));
processing_element pe06(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a05to06), .in_b(b6),      .in_c(c6),        .out_a(a06to07), .out_b(b06to16), .out_b0(b06to16_ping), .out_b1(b06to16_pong), .out_c(matrixC06), .b_data_valid_ping(b_data_valid_ping_delay06), .b_data_valid_pong(b_data_valid_pong_delay06));
processing_element pe07(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a06to07), .in_b(b7),      .in_c(c7),        .out_a(a07to08), .out_b(b07to17), .out_b0(b07to17_ping), .out_b1(b07to17_pong), .out_c(matrixC07), .b_data_valid_ping(b_data_valid_ping_delay07), .b_data_valid_pong(b_data_valid_pong_delay07));
processing_element pe08(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a07to08), .in_b(b8),      .in_c(c8),        .out_a(a08to09), .out_b(b08to18), .out_b0(b08to18_ping), .out_b1(b08to18_pong), .out_c(matrixC08), .b_data_valid_ping(b_data_valid_ping_delay08), .b_data_valid_pong(b_data_valid_pong_delay08));
processing_element pe09(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a08to09), .in_b(b9),      .in_c(c9),        .out_a(a09to010), .out_b(b09to19), .out_b0(b09to19_ping), .out_b1(b09to19_pong), .out_c(matrixC09), .b_data_valid_ping(b_data_valid_ping_delay09), .b_data_valid_pong(b_data_valid_pong_delay09));
processing_element pe010(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a09to010), .in_b(b10),      .in_c(c10),        .out_a(a010to011), .out_b(b010to110), .out_b0(b010to110_ping), .out_b1(b010to110_pong), .out_c(matrixC010), .b_data_valid_ping(b_data_valid_ping_delay010), .b_data_valid_pong(b_data_valid_pong_delay010));
processing_element pe011(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a010to011), .in_b(b11),      .in_c(c11),        .out_a(a011to012), .out_b(b011to111), .out_b0(b011to111_ping), .out_b1(b011to111_pong), .out_c(matrixC011), .b_data_valid_ping(b_data_valid_ping_delay011), .b_data_valid_pong(b_data_valid_pong_delay011));
processing_element pe012(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay12), .in_a(a011to012), .in_b(b12),      .in_c(c12),        .out_a(a012to013), .out_b(b012to112), .out_b0(b012to112_ping), .out_b1(b012to112_pong), .out_c(matrixC012), .b_data_valid_ping(b_data_valid_ping_delay012), .b_data_valid_pong(b_data_valid_pong_delay012));
processing_element pe013(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay13), .in_a(a012to013), .in_b(b13),      .in_c(c13),        .out_a(a013to014), .out_b(b013to113), .out_b0(b013to113_ping), .out_b1(b013to113_pong), .out_c(matrixC013), .b_data_valid_ping(b_data_valid_ping_delay013), .b_data_valid_pong(b_data_valid_pong_delay013));
processing_element pe014(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay14), .in_a(a013to014), .in_b(b14),      .in_c(c14),        .out_a(a014to015), .out_b(b014to114), .out_b0(b014to114_ping), .out_b1(b014to114_pong), .out_c(matrixC014), .b_data_valid_ping(b_data_valid_ping_delay014), .b_data_valid_pong(b_data_valid_pong_delay014));
processing_element pe015(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay15), .in_a(a014to015), .in_b(b15),      .in_c(c15),        .out_a(a015to016), .out_b(b015to115), .out_b0(b015to115_ping), .out_b1(b015to115_pong), .out_c(matrixC015), .b_data_valid_ping(b_data_valid_ping_delay015), .b_data_valid_pong(b_data_valid_pong_delay015));

processing_element pe10(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay1), .in_a(a1),      .in_b(b00to10), .in_c(matrixC00), .out_a(a10to11), .out_b(b10to20), .out_b0(b10to20_ping), .out_b1(b10to20_pong), .out_c(matrixC10), .b_data_valid_ping(b_data_valid_ping_delay10), .b_data_valid_pong(b_data_valid_pong_delay10));
processing_element pe11(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay2), .in_a(a10to11), .in_b(b01to11), .in_c(matrixC01), .out_a(a11to12), .out_b(b11to21), .out_b0(b11to21_ping), .out_b1(b11to21_pong), .out_c(matrixC11), .b_data_valid_ping(b_data_valid_ping_delay11), .b_data_valid_pong(b_data_valid_pong_delay11));
processing_element pe12(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay3), .in_a(a11to12), .in_b(b02to12), .in_c(matrixC02), .out_a(a12to13), .out_b(b12to22), .out_b0(b12to22_ping), .out_b1(b12to22_pong), .out_c(matrixC12), .b_data_valid_ping(b_data_valid_ping_delay12), .b_data_valid_pong(b_data_valid_pong_delay12));
processing_element pe13(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay4), .in_a(a12to13), .in_b(b03to13), .in_c(matrixC03), .out_a(a13to14), .out_b(b13to23), .out_b0(b13to23_ping), .out_b1(b13to23_pong), .out_c(matrixC13), .b_data_valid_ping(b_data_valid_ping_delay13), .b_data_valid_pong(b_data_valid_pong_delay13));
processing_element pe14(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay5), .in_a(a13to14), .in_b(b04to14), .in_c(matrixC04), .out_a(a14to15), .out_b(b14to24), .out_b0(b14to24_ping), .out_b1(b14to24_pong), .out_c(matrixC14), .b_data_valid_ping(b_data_valid_ping_delay14), .b_data_valid_pong(b_data_valid_pong_delay14));
processing_element pe15(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a14to15), .in_b(b05to15), .in_c(matrixC05), .out_a(a15to16), .out_b(b15to25), .out_b0(b15to25_ping), .out_b1(b15to25_pong), .out_c(matrixC15), .b_data_valid_ping(b_data_valid_ping_delay15), .b_data_valid_pong(b_data_valid_pong_delay15));
processing_element pe16(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a15to16), .in_b(b06to16), .in_c(matrixC06), .out_a(a16to17), .out_b(b16to26), .out_b0(b16to26_ping), .out_b1(b16to26_pong), .out_c(matrixC16), .b_data_valid_ping(b_data_valid_ping_delay16), .b_data_valid_pong(b_data_valid_pong_delay16));
processing_element pe17(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a16to17), .in_b(b07to17), .in_c(matrixC07), .out_a(a17to18), .out_b(b17to27), .out_b0(b17to27_ping), .out_b1(b17to27_pong), .out_c(matrixC17), .b_data_valid_ping(b_data_valid_ping_delay17), .b_data_valid_pong(b_data_valid_pong_delay17));
processing_element pe18(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a17to18), .in_b(b08to18), .in_c(matrixC08), .out_a(a18to19), .out_b(b18to28), .out_b0(b18to28_ping), .out_b1(b18to28_pong), .out_c(matrixC18), .b_data_valid_ping(b_data_valid_ping_delay18), .b_data_valid_pong(b_data_valid_pong_delay18));
processing_element pe19(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a18to19), .in_b(b09to19), .in_c(matrixC09), .out_a(a19to110), .out_b(b19to29), .out_b0(b19to29_ping), .out_b1(b19to29_pong), .out_c(matrixC19), .b_data_valid_ping(b_data_valid_ping_delay19), .b_data_valid_pong(b_data_valid_pong_delay19));
processing_element pe110(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a19to110), .in_b(b010to110), .in_c(matrixC010), .out_a(a110to111), .out_b(b110to210), .out_b0(b110to210_ping), .out_b1(b110to210_pong), .out_c(matrixC110), .b_data_valid_ping(b_data_valid_ping_delay110), .b_data_valid_pong(b_data_valid_pong_delay110));
processing_element pe111(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay12), .in_a(a110to111), .in_b(b011to111), .in_c(matrixC011), .out_a(a111to112), .out_b(b111to211), .out_b0(b111to211_ping), .out_b1(b111to211_pong), .out_c(matrixC111), .b_data_valid_ping(b_data_valid_ping_delay111), .b_data_valid_pong(b_data_valid_pong_delay111));
processing_element pe112(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay13), .in_a(a111to112), .in_b(b012to112), .in_c(matrixC012), .out_a(a112to113), .out_b(b112to212), .out_b0(b112to212_ping), .out_b1(b112to212_pong), .out_c(matrixC112), .b_data_valid_ping(b_data_valid_ping_delay112), .b_data_valid_pong(b_data_valid_pong_delay112));
processing_element pe113(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay14), .in_a(a112to113), .in_b(b013to113), .in_c(matrixC013), .out_a(a113to114), .out_b(b113to213), .out_b0(b113to213_ping), .out_b1(b113to213_pong), .out_c(matrixC113), .b_data_valid_ping(b_data_valid_ping_delay113), .b_data_valid_pong(b_data_valid_pong_delay113));
processing_element pe114(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay15), .in_a(a113to114), .in_b(b014to114), .in_c(matrixC014), .out_a(a114to115), .out_b(b114to214), .out_b0(b114to214_ping), .out_b1(b114to214_pong), .out_c(matrixC114), .b_data_valid_ping(b_data_valid_ping_delay114), .b_data_valid_pong(b_data_valid_pong_delay114));
processing_element pe115(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay16), .in_a(a114to115), .in_b(b015to115), .in_c(matrixC015), .out_a(a115to116), .out_b(b115to215), .out_b0(b115to215_ping), .out_b1(b115to215_pong), .out_c(matrixC115), .b_data_valid_ping(b_data_valid_ping_delay115), .b_data_valid_pong(b_data_valid_pong_delay115));

processing_element pe20(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay2), .in_a(a2),      .in_b(b10to20), .in_c(matrixC10), .out_a(a20to21), .out_b(b20to30), .out_b0(b20to30_ping), .out_b1(b20to30_pong), .out_c(matrixC20), .b_data_valid_ping(b_data_valid_ping_delay20), .b_data_valid_pong(b_data_valid_pong_delay20));
processing_element pe21(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay3), .in_a(a20to21), .in_b(b11to21), .in_c(matrixC11), .out_a(a21to22), .out_b(b21to31), .out_b0(b21to31_ping), .out_b1(b21to31_pong), .out_c(matrixC21), .b_data_valid_ping(b_data_valid_ping_delay21), .b_data_valid_pong(b_data_valid_pong_delay21));
processing_element pe22(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay4), .in_a(a21to22), .in_b(b12to22), .in_c(matrixC12), .out_a(a22to23), .out_b(b22to32), .out_b0(b22to32_ping), .out_b1(b22to32_pong), .out_c(matrixC22), .b_data_valid_ping(b_data_valid_ping_delay22), .b_data_valid_pong(b_data_valid_pong_delay22));
processing_element pe23(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay5), .in_a(a22to23), .in_b(b13to23), .in_c(matrixC13), .out_a(a23to24), .out_b(b23to33), .out_b0(b23to33_ping), .out_b1(b23to33_pong), .out_c(matrixC23), .b_data_valid_ping(b_data_valid_ping_delay23), .b_data_valid_pong(b_data_valid_pong_delay23));
processing_element pe24(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a23to24), .in_b(b14to24), .in_c(matrixC14), .out_a(a24to25), .out_b(b24to34), .out_b0(b24to34_ping), .out_b1(b24to34_pong), .out_c(matrixC24), .b_data_valid_ping(b_data_valid_ping_delay24), .b_data_valid_pong(b_data_valid_pong_delay24));
processing_element pe25(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a24to25), .in_b(b15to25), .in_c(matrixC15), .out_a(a25to26), .out_b(b25to35), .out_b0(b25to35_ping), .out_b1(b25to35_pong), .out_c(matrixC25), .b_data_valid_ping(b_data_valid_ping_delay25), .b_data_valid_pong(b_data_valid_pong_delay25));
processing_element pe26(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a25to26), .in_b(b16to26), .in_c(matrixC16), .out_a(a26to27), .out_b(b26to36), .out_b0(b26to36_ping), .out_b1(b26to36_pong), .out_c(matrixC26), .b_data_valid_ping(b_data_valid_ping_delay26), .b_data_valid_pong(b_data_valid_pong_delay26));
processing_element pe27(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a26to27), .in_b(b17to27), .in_c(matrixC17), .out_a(a27to28), .out_b(b27to37), .out_b0(b27to37_ping), .out_b1(b27to37_pong), .out_c(matrixC27), .b_data_valid_ping(b_data_valid_ping_delay27), .b_data_valid_pong(b_data_valid_pong_delay27));
processing_element pe28(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a27to28), .in_b(b18to28), .in_c(matrixC18), .out_a(a28to29), .out_b(b28to38), .out_b0(b28to38_ping), .out_b1(b28to38_pong), .out_c(matrixC28), .b_data_valid_ping(b_data_valid_ping_delay28), .b_data_valid_pong(b_data_valid_pong_delay28));
processing_element pe29(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a28to29), .in_b(b19to29), .in_c(matrixC19), .out_a(a29to210), .out_b(b29to39), .out_b0(b29to39_ping), .out_b1(b29to39_pong), .out_c(matrixC29), .b_data_valid_ping(b_data_valid_ping_delay29), .b_data_valid_pong(b_data_valid_pong_delay29));
processing_element pe210(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay12), .in_a(a29to210), .in_b(b110to210), .in_c(matrixC110), .out_a(a210to211), .out_b(b210to310), .out_b0(b210to310_ping), .out_b1(b210to310_pong), .out_c(matrixC210), .b_data_valid_ping(b_data_valid_ping_delay210), .b_data_valid_pong(b_data_valid_pong_delay210));
processing_element pe211(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay13), .in_a(a210to211), .in_b(b111to211), .in_c(matrixC111), .out_a(a211to212), .out_b(b211to311), .out_b0(b211to311_ping), .out_b1(b211to311_pong), .out_c(matrixC211), .b_data_valid_ping(b_data_valid_ping_delay211), .b_data_valid_pong(b_data_valid_pong_delay211));
processing_element pe212(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay14), .in_a(a211to212), .in_b(b112to212), .in_c(matrixC112), .out_a(a212to213), .out_b(b212to312), .out_b0(b212to312_ping), .out_b1(b212to312_pong), .out_c(matrixC212), .b_data_valid_ping(b_data_valid_ping_delay212), .b_data_valid_pong(b_data_valid_pong_delay212));
processing_element pe213(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay15), .in_a(a212to213), .in_b(b113to213), .in_c(matrixC113), .out_a(a213to214), .out_b(b213to313), .out_b0(b213to313_ping), .out_b1(b213to313_pong), .out_c(matrixC213), .b_data_valid_ping(b_data_valid_ping_delay213), .b_data_valid_pong(b_data_valid_pong_delay213));
processing_element pe214(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay16), .in_a(a213to214), .in_b(b114to214), .in_c(matrixC114), .out_a(a214to215), .out_b(b214to314), .out_b0(b214to314_ping), .out_b1(b214to314_pong), .out_c(matrixC214), .b_data_valid_ping(b_data_valid_ping_delay214), .b_data_valid_pong(b_data_valid_pong_delay214));
processing_element pe215(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay17), .in_a(a214to215), .in_b(b115to215), .in_c(matrixC115), .out_a(a215to216), .out_b(b215to315), .out_b0(b215to315_ping), .out_b1(b215to315_pong), .out_c(matrixC215), .b_data_valid_ping(b_data_valid_ping_delay215), .b_data_valid_pong(b_data_valid_pong_delay215));

processing_element pe30(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay3), .in_a(a3),      .in_b(b20to30), .in_c(matrixC20), .out_a(a30to31), .out_b(b30to40), .out_b0(b30to40_ping), .out_b1(b30to40_pong), .out_c(matrixC30), .b_data_valid_ping(b_data_valid_ping_delay30), .b_data_valid_pong(b_data_valid_pong_delay30));
processing_element pe31(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay4), .in_a(a30to31), .in_b(b21to31), .in_c(matrixC21), .out_a(a31to32), .out_b(b31to41), .out_b0(b31to41_ping), .out_b1(b31to41_pong), .out_c(matrixC31), .b_data_valid_ping(b_data_valid_ping_delay31), .b_data_valid_pong(b_data_valid_pong_delay31));
processing_element pe32(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay5), .in_a(a31to32), .in_b(b22to32), .in_c(matrixC22), .out_a(a32to33), .out_b(b32to42), .out_b0(b32to42_ping), .out_b1(b32to42_pong), .out_c(matrixC32), .b_data_valid_ping(b_data_valid_ping_delay32), .b_data_valid_pong(b_data_valid_pong_delay32));
processing_element pe33(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a32to33), .in_b(b23to33), .in_c(matrixC23), .out_a(a33to34), .out_b(b33to43), .out_b0(b33to43_ping), .out_b1(b33to43_pong), .out_c(matrixC33), .b_data_valid_ping(b_data_valid_ping_delay33), .b_data_valid_pong(b_data_valid_pong_delay33));
processing_element pe34(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a33to34), .in_b(b24to34), .in_c(matrixC24), .out_a(a34to35), .out_b(b34to44), .out_b0(b34to44_ping), .out_b1(b34to44_pong), .out_c(matrixC34), .b_data_valid_ping(b_data_valid_ping_delay34), .b_data_valid_pong(b_data_valid_pong_delay34));
processing_element pe35(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a34to35), .in_b(b25to35), .in_c(matrixC25), .out_a(a35to36), .out_b(b35to45), .out_b0(b35to45_ping), .out_b1(b35to45_pong), .out_c(matrixC35), .b_data_valid_ping(b_data_valid_ping_delay35), .b_data_valid_pong(b_data_valid_pong_delay35));
processing_element pe36(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a35to36), .in_b(b26to36), .in_c(matrixC26), .out_a(a36to37), .out_b(b36to46), .out_b0(b36to46_ping), .out_b1(b36to46_pong), .out_c(matrixC36), .b_data_valid_ping(b_data_valid_ping_delay36), .b_data_valid_pong(b_data_valid_pong_delay36));
processing_element pe37(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a36to37), .in_b(b27to37), .in_c(matrixC27), .out_a(a37to38), .out_b(b37to47), .out_b0(b37to47_ping), .out_b1(b37to47_pong), .out_c(matrixC37), .b_data_valid_ping(b_data_valid_ping_delay37), .b_data_valid_pong(b_data_valid_pong_delay37));
processing_element pe38(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a37to38), .in_b(b28to38), .in_c(matrixC28), .out_a(a38to39), .out_b(b38to48), .out_b0(b38to48_ping), .out_b1(b38to48_pong), .out_c(matrixC38), .b_data_valid_ping(b_data_valid_ping_delay38), .b_data_valid_pong(b_data_valid_pong_delay38));
processing_element pe39(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay12), .in_a(a38to39), .in_b(b29to39), .in_c(matrixC29), .out_a(a39to310), .out_b(b39to49), .out_b0(b39to49_ping), .out_b1(b39to49_pong), .out_c(matrixC39), .b_data_valid_ping(b_data_valid_ping_delay39), .b_data_valid_pong(b_data_valid_pong_delay39));
processing_element pe310(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay13), .in_a(a39to310), .in_b(b210to310), .in_c(matrixC210), .out_a(a310to311), .out_b(b310to410), .out_b0(b310to410_ping), .out_b1(b310to410_pong), .out_c(matrixC310), .b_data_valid_ping(b_data_valid_ping_delay310), .b_data_valid_pong(b_data_valid_pong_delay310));
processing_element pe311(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay14), .in_a(a310to311), .in_b(b211to311), .in_c(matrixC211), .out_a(a311to312), .out_b(b311to411), .out_b0(b311to411_ping), .out_b1(b311to411_pong), .out_c(matrixC311), .b_data_valid_ping(b_data_valid_ping_delay311), .b_data_valid_pong(b_data_valid_pong_delay311));
processing_element pe312(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay15), .in_a(a311to312), .in_b(b212to312), .in_c(matrixC212), .out_a(a312to313), .out_b(b312to412), .out_b0(b312to412_ping), .out_b1(b312to412_pong), .out_c(matrixC312), .b_data_valid_ping(b_data_valid_ping_delay312), .b_data_valid_pong(b_data_valid_pong_delay312));
processing_element pe313(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay16), .in_a(a312to313), .in_b(b213to313), .in_c(matrixC213), .out_a(a313to314), .out_b(b313to413), .out_b0(b313to413_ping), .out_b1(b313to413_pong), .out_c(matrixC313), .b_data_valid_ping(b_data_valid_ping_delay313), .b_data_valid_pong(b_data_valid_pong_delay313));
processing_element pe314(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay17), .in_a(a313to314), .in_b(b214to314), .in_c(matrixC214), .out_a(a314to315), .out_b(b314to414), .out_b0(b314to414_ping), .out_b1(b314to414_pong), .out_c(matrixC314), .b_data_valid_ping(b_data_valid_ping_delay314), .b_data_valid_pong(b_data_valid_pong_delay314));
processing_element pe315(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay18), .in_a(a314to315), .in_b(b215to315), .in_c(matrixC215), .out_a(a315to316), .out_b(b315to415), .out_b0(b315to415_ping), .out_b1(b315to415_pong), .out_c(matrixC315), .b_data_valid_ping(b_data_valid_ping_delay315), .b_data_valid_pong(b_data_valid_pong_delay315));

processing_element pe40(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay4), .in_a(a4),      .in_b(b30to40), .in_c(matrixC30), .out_a(a40to41), .out_b(b40to50), .out_b0(b40to50_ping), .out_b1(b40to50_pong), .out_c(matrixC40), .b_data_valid_ping(b_data_valid_ping_delay40), .b_data_valid_pong(b_data_valid_pong_delay40));
processing_element pe41(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay5), .in_a(a40to41), .in_b(b31to41), .in_c(matrixC31), .out_a(a41to42), .out_b(b41to51), .out_b0(b41to51_ping), .out_b1(b41to51_pong), .out_c(matrixC41), .b_data_valid_ping(b_data_valid_ping_delay41), .b_data_valid_pong(b_data_valid_pong_delay41));
processing_element pe42(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a41to42), .in_b(b32to42), .in_c(matrixC32), .out_a(a42to43), .out_b(b42to52), .out_b0(b42to52_ping), .out_b1(b42to52_pong), .out_c(matrixC42), .b_data_valid_ping(b_data_valid_ping_delay42), .b_data_valid_pong(b_data_valid_pong_delay42));
processing_element pe43(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a42to43), .in_b(b33to43), .in_c(matrixC33), .out_a(a43to44), .out_b(b43to53), .out_b0(b43to53_ping), .out_b1(b43to53_pong), .out_c(matrixC43), .b_data_valid_ping(b_data_valid_ping_delay43), .b_data_valid_pong(b_data_valid_pong_delay43));
processing_element pe44(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a43to44), .in_b(b34to44), .in_c(matrixC34), .out_a(a44to45), .out_b(b44to54), .out_b0(b44to54_ping), .out_b1(b44to54_pong), .out_c(matrixC44), .b_data_valid_ping(b_data_valid_ping_delay44), .b_data_valid_pong(b_data_valid_pong_delay44));
processing_element pe45(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a44to45), .in_b(b35to45), .in_c(matrixC35), .out_a(a45to46), .out_b(b45to55), .out_b0(b45to55_ping), .out_b1(b45to55_pong), .out_c(matrixC45), .b_data_valid_ping(b_data_valid_ping_delay45), .b_data_valid_pong(b_data_valid_pong_delay45));
processing_element pe46(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a45to46), .in_b(b36to46), .in_c(matrixC36), .out_a(a46to47), .out_b(b46to56), .out_b0(b46to56_ping), .out_b1(b46to56_pong), .out_c(matrixC46), .b_data_valid_ping(b_data_valid_ping_delay46), .b_data_valid_pong(b_data_valid_pong_delay46));
processing_element pe47(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a46to47), .in_b(b37to47), .in_c(matrixC37), .out_a(a47to48), .out_b(b47to57), .out_b0(b47to57_ping), .out_b1(b47to57_pong), .out_c(matrixC47), .b_data_valid_ping(b_data_valid_ping_delay47), .b_data_valid_pong(b_data_valid_pong_delay47));
processing_element pe48(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay12), .in_a(a47to48), .in_b(b38to48), .in_c(matrixC38), .out_a(a48to49), .out_b(b48to58), .out_b0(b48to58_ping), .out_b1(b48to58_pong), .out_c(matrixC48), .b_data_valid_ping(b_data_valid_ping_delay48), .b_data_valid_pong(b_data_valid_pong_delay48));
processing_element pe49(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay13), .in_a(a48to49), .in_b(b39to49), .in_c(matrixC39), .out_a(a49to410), .out_b(b49to59), .out_b0(b49to59_ping), .out_b1(b49to59_pong), .out_c(matrixC49), .b_data_valid_ping(b_data_valid_ping_delay49), .b_data_valid_pong(b_data_valid_pong_delay49));
processing_element pe410(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay14), .in_a(a49to410), .in_b(b310to410), .in_c(matrixC310), .out_a(a410to411), .out_b(b410to510), .out_b0(b410to510_ping), .out_b1(b410to510_pong), .out_c(matrixC410), .b_data_valid_ping(b_data_valid_ping_delay410), .b_data_valid_pong(b_data_valid_pong_delay410));
processing_element pe411(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay15), .in_a(a410to411), .in_b(b311to411), .in_c(matrixC311), .out_a(a411to412), .out_b(b411to511), .out_b0(b411to511_ping), .out_b1(b411to511_pong), .out_c(matrixC411), .b_data_valid_ping(b_data_valid_ping_delay411), .b_data_valid_pong(b_data_valid_pong_delay411));
processing_element pe412(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay16), .in_a(a411to412), .in_b(b312to412), .in_c(matrixC312), .out_a(a412to413), .out_b(b412to512), .out_b0(b412to512_ping), .out_b1(b412to512_pong), .out_c(matrixC412), .b_data_valid_ping(b_data_valid_ping_delay412), .b_data_valid_pong(b_data_valid_pong_delay412));
processing_element pe413(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay17), .in_a(a412to413), .in_b(b313to413), .in_c(matrixC313), .out_a(a413to414), .out_b(b413to513), .out_b0(b413to513_ping), .out_b1(b413to513_pong), .out_c(matrixC413), .b_data_valid_ping(b_data_valid_ping_delay413), .b_data_valid_pong(b_data_valid_pong_delay413));
processing_element pe414(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay18), .in_a(a413to414), .in_b(b314to414), .in_c(matrixC314), .out_a(a414to415), .out_b(b414to514), .out_b0(b414to514_ping), .out_b1(b414to514_pong), .out_c(matrixC414), .b_data_valid_ping(b_data_valid_ping_delay414), .b_data_valid_pong(b_data_valid_pong_delay414));
processing_element pe415(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay19), .in_a(a414to415), .in_b(b315to415), .in_c(matrixC315), .out_a(a415to416), .out_b(b415to515), .out_b0(b415to515_ping), .out_b1(b415to515_pong), .out_c(matrixC415), .b_data_valid_ping(b_data_valid_ping_delay415), .b_data_valid_pong(b_data_valid_pong_delay415));

processing_element pe50(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay5), .in_a(a5),      .in_b(b40to50), .in_c(matrixC40), .out_a(a50to51), .out_b(b50to60), .out_b0(b50to60_ping), .out_b1(b50to60_pong), .out_c(matrixC50), .b_data_valid_ping(b_data_valid_ping_delay50), .b_data_valid_pong(b_data_valid_pong_delay50));
processing_element pe51(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a50to51), .in_b(b41to51), .in_c(matrixC41), .out_a(a51to52), .out_b(b51to61), .out_b0(b51to61_ping), .out_b1(b51to61_pong), .out_c(matrixC51), .b_data_valid_ping(b_data_valid_ping_delay51), .b_data_valid_pong(b_data_valid_pong_delay51));
processing_element pe52(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a51to52), .in_b(b42to52), .in_c(matrixC42), .out_a(a52to53), .out_b(b52to62), .out_b0(b52to62_ping), .out_b1(b52to62_pong), .out_c(matrixC52), .b_data_valid_ping(b_data_valid_ping_delay52), .b_data_valid_pong(b_data_valid_pong_delay52));
processing_element pe53(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a52to53), .in_b(b43to53), .in_c(matrixC43), .out_a(a53to54), .out_b(b53to63), .out_b0(b53to63_ping), .out_b1(b53to63_pong), .out_c(matrixC53), .b_data_valid_ping(b_data_valid_ping_delay53), .b_data_valid_pong(b_data_valid_pong_delay53));
processing_element pe54(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a53to54), .in_b(b44to54), .in_c(matrixC44), .out_a(a54to55), .out_b(b54to64), .out_b0(b54to64_ping), .out_b1(b54to64_pong), .out_c(matrixC54), .b_data_valid_ping(b_data_valid_ping_delay54), .b_data_valid_pong(b_data_valid_pong_delay54));
processing_element pe55(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a54to55), .in_b(b45to55), .in_c(matrixC45), .out_a(a55to56), .out_b(b55to65), .out_b0(b55to65_ping), .out_b1(b55to65_pong), .out_c(matrixC55), .b_data_valid_ping(b_data_valid_ping_delay55), .b_data_valid_pong(b_data_valid_pong_delay55));
processing_element pe56(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a55to56), .in_b(b46to56), .in_c(matrixC46), .out_a(a56to57), .out_b(b56to66), .out_b0(b56to66_ping), .out_b1(b56to66_pong), .out_c(matrixC56), .b_data_valid_ping(b_data_valid_ping_delay56), .b_data_valid_pong(b_data_valid_pong_delay56));
processing_element pe57(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay12), .in_a(a56to57), .in_b(b47to57), .in_c(matrixC47), .out_a(a57to58), .out_b(b57to67), .out_b0(b57to67_ping), .out_b1(b57to67_pong), .out_c(matrixC57), .b_data_valid_ping(b_data_valid_ping_delay57), .b_data_valid_pong(b_data_valid_pong_delay57));
processing_element pe58(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay13), .in_a(a57to58), .in_b(b48to58), .in_c(matrixC48), .out_a(a58to59), .out_b(b58to68), .out_b0(b58to68_ping), .out_b1(b58to68_pong), .out_c(matrixC58), .b_data_valid_ping(b_data_valid_ping_delay58), .b_data_valid_pong(b_data_valid_pong_delay58));
processing_element pe59(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay14), .in_a(a58to59), .in_b(b49to59), .in_c(matrixC49), .out_a(a59to510), .out_b(b59to69), .out_b0(b59to69_ping), .out_b1(b59to69_pong), .out_c(matrixC59), .b_data_valid_ping(b_data_valid_ping_delay59), .b_data_valid_pong(b_data_valid_pong_delay59));
processing_element pe510(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay15), .in_a(a59to510), .in_b(b410to510), .in_c(matrixC410), .out_a(a510to511), .out_b(b510to610), .out_b0(b510to610_ping), .out_b1(b510to610_pong), .out_c(matrixC510), .b_data_valid_ping(b_data_valid_ping_delay510), .b_data_valid_pong(b_data_valid_pong_delay510));
processing_element pe511(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay16), .in_a(a510to511), .in_b(b411to511), .in_c(matrixC411), .out_a(a511to512), .out_b(b511to611), .out_b0(b511to611_ping), .out_b1(b511to611_pong), .out_c(matrixC511), .b_data_valid_ping(b_data_valid_ping_delay511), .b_data_valid_pong(b_data_valid_pong_delay511));
processing_element pe512(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay17), .in_a(a511to512), .in_b(b412to512), .in_c(matrixC412), .out_a(a512to513), .out_b(b512to612), .out_b0(b512to612_ping), .out_b1(b512to612_pong), .out_c(matrixC512), .b_data_valid_ping(b_data_valid_ping_delay512), .b_data_valid_pong(b_data_valid_pong_delay512));
processing_element pe513(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay18), .in_a(a512to513), .in_b(b413to513), .in_c(matrixC413), .out_a(a513to514), .out_b(b513to613), .out_b0(b513to613_ping), .out_b1(b513to613_pong), .out_c(matrixC513), .b_data_valid_ping(b_data_valid_ping_delay513), .b_data_valid_pong(b_data_valid_pong_delay513));
processing_element pe514(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay19), .in_a(a513to514), .in_b(b414to514), .in_c(matrixC414), .out_a(a514to515), .out_b(b514to614), .out_b0(b514to614_ping), .out_b1(b514to614_pong), .out_c(matrixC514), .b_data_valid_ping(b_data_valid_ping_delay514), .b_data_valid_pong(b_data_valid_pong_delay514));
processing_element pe515(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay20), .in_a(a514to515), .in_b(b415to515), .in_c(matrixC415), .out_a(a515to516), .out_b(b515to615), .out_b0(b515to615_ping), .out_b1(b515to615_pong), .out_c(matrixC515), .b_data_valid_ping(b_data_valid_ping_delay515), .b_data_valid_pong(b_data_valid_pong_delay515));

processing_element pe60(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a6),      .in_b(b50to60), .in_c(matrixC50), .out_a(a60to61), .out_b(b60to70), .out_b0(b60to70_ping), .out_b1(b60to70_pong), .out_c(matrixC60), .b_data_valid_ping(b_data_valid_ping_delay60), .b_data_valid_pong(b_data_valid_pong_delay60));
processing_element pe61(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a60to61), .in_b(b51to61), .in_c(matrixC51), .out_a(a61to62), .out_b(b61to71), .out_b0(b61to71_ping), .out_b1(b61to71_pong), .out_c(matrixC61), .b_data_valid_ping(b_data_valid_ping_delay61), .b_data_valid_pong(b_data_valid_pong_delay61));
processing_element pe62(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a61to62), .in_b(b52to62), .in_c(matrixC52), .out_a(a62to63), .out_b(b62to72), .out_b0(b62to72_ping), .out_b1(b62to72_pong), .out_c(matrixC62), .b_data_valid_ping(b_data_valid_ping_delay62), .b_data_valid_pong(b_data_valid_pong_delay62));
processing_element pe63(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a62to63), .in_b(b53to63), .in_c(matrixC53), .out_a(a63to64), .out_b(b63to73), .out_b0(b63to73_ping), .out_b1(b63to73_pong), .out_c(matrixC63), .b_data_valid_ping(b_data_valid_ping_delay63), .b_data_valid_pong(b_data_valid_pong_delay63));
processing_element pe64(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a63to64), .in_b(b54to64), .in_c(matrixC54), .out_a(a64to65), .out_b(b64to74), .out_b0(b64to74_ping), .out_b1(b64to74_pong), .out_c(matrixC64), .b_data_valid_ping(b_data_valid_ping_delay64), .b_data_valid_pong(b_data_valid_pong_delay64));
processing_element pe65(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a64to65), .in_b(b55to65), .in_c(matrixC55), .out_a(a65to66), .out_b(b65to75), .out_b0(b65to75_ping), .out_b1(b65to75_pong), .out_c(matrixC65), .b_data_valid_ping(b_data_valid_ping_delay65), .b_data_valid_pong(b_data_valid_pong_delay65));
processing_element pe66(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay12), .in_a(a65to66), .in_b(b56to66), .in_c(matrixC56), .out_a(a66to67), .out_b(b66to76), .out_b0(b66to76_ping), .out_b1(b66to76_pong), .out_c(matrixC66), .b_data_valid_ping(b_data_valid_ping_delay66), .b_data_valid_pong(b_data_valid_pong_delay66));
processing_element pe67(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay13), .in_a(a66to67), .in_b(b57to67), .in_c(matrixC57), .out_a(a67to68), .out_b(b67to77), .out_b0(b67to77_ping), .out_b1(b67to77_pong), .out_c(matrixC67), .b_data_valid_ping(b_data_valid_ping_delay67), .b_data_valid_pong(b_data_valid_pong_delay67));
processing_element pe68(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay14), .in_a(a67to68), .in_b(b58to68), .in_c(matrixC58), .out_a(a68to69), .out_b(b68to78), .out_b0(b68to78_ping), .out_b1(b68to78_pong), .out_c(matrixC68), .b_data_valid_ping(b_data_valid_ping_delay68), .b_data_valid_pong(b_data_valid_pong_delay68));
processing_element pe69(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay15), .in_a(a68to69), .in_b(b59to69), .in_c(matrixC59), .out_a(a69to610), .out_b(b69to79), .out_b0(b69to79_ping), .out_b1(b69to79_pong), .out_c(matrixC69), .b_data_valid_ping(b_data_valid_ping_delay69), .b_data_valid_pong(b_data_valid_pong_delay69));
processing_element pe610(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay16), .in_a(a69to610), .in_b(b510to610), .in_c(matrixC510), .out_a(a610to611), .out_b(b610to710), .out_b0(b610to710_ping), .out_b1(b610to710_pong), .out_c(matrixC610), .b_data_valid_ping(b_data_valid_ping_delay610), .b_data_valid_pong(b_data_valid_pong_delay610));
processing_element pe611(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay17), .in_a(a610to611), .in_b(b511to611), .in_c(matrixC511), .out_a(a611to612), .out_b(b611to711), .out_b0(b611to711_ping), .out_b1(b611to711_pong), .out_c(matrixC611), .b_data_valid_ping(b_data_valid_ping_delay611), .b_data_valid_pong(b_data_valid_pong_delay611));
processing_element pe612(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay18), .in_a(a611to612), .in_b(b512to612), .in_c(matrixC512), .out_a(a612to613), .out_b(b612to712), .out_b0(b612to712_ping), .out_b1(b612to712_pong), .out_c(matrixC612), .b_data_valid_ping(b_data_valid_ping_delay612), .b_data_valid_pong(b_data_valid_pong_delay612));
processing_element pe613(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay19), .in_a(a612to613), .in_b(b513to613), .in_c(matrixC513), .out_a(a613to614), .out_b(b613to713), .out_b0(b613to713_ping), .out_b1(b613to713_pong), .out_c(matrixC613), .b_data_valid_ping(b_data_valid_ping_delay613), .b_data_valid_pong(b_data_valid_pong_delay613));
processing_element pe614(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay20), .in_a(a613to614), .in_b(b514to614), .in_c(matrixC514), .out_a(a614to615), .out_b(b614to714), .out_b0(b614to714_ping), .out_b1(b614to714_pong), .out_c(matrixC614), .b_data_valid_ping(b_data_valid_ping_delay614), .b_data_valid_pong(b_data_valid_pong_delay614));
processing_element pe615(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay21), .in_a(a614to615), .in_b(b515to615), .in_c(matrixC515), .out_a(a615to616), .out_b(b615to715), .out_b0(b615to715_ping), .out_b1(b615to715_pong), .out_c(matrixC615), .b_data_valid_ping(b_data_valid_ping_delay615), .b_data_valid_pong(b_data_valid_pong_delay615));

processing_element pe70(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a7),      .in_b(b60to70), .in_c(matrixC60), .out_a(a70to71), .out_b(b70to80), .out_b0(b70to80_ping), .out_b1(b70to80_pong), .out_c(matrixC70), .b_data_valid_ping(b_data_valid_ping_delay70), .b_data_valid_pong(b_data_valid_pong_delay70));
processing_element pe71(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a70to71), .in_b(b61to71), .in_c(matrixC61), .out_a(a71to72), .out_b(b71to81), .out_b0(b71to81_ping), .out_b1(b71to81_pong), .out_c(matrixC71), .b_data_valid_ping(b_data_valid_ping_delay71), .b_data_valid_pong(b_data_valid_pong_delay71));
processing_element pe72(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a71to72), .in_b(b62to72), .in_c(matrixC62), .out_a(a72to73), .out_b(b72to82), .out_b0(b72to82_ping), .out_b1(b72to82_pong), .out_c(matrixC72), .b_data_valid_ping(b_data_valid_ping_delay72), .b_data_valid_pong(b_data_valid_pong_delay72));
processing_element pe73(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a72to73), .in_b(b63to73), .in_c(matrixC63), .out_a(a73to74), .out_b(b73to83), .out_b0(b73to83_ping), .out_b1(b73to83_pong), .out_c(matrixC73), .b_data_valid_ping(b_data_valid_ping_delay73), .b_data_valid_pong(b_data_valid_pong_delay73));
processing_element pe74(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a73to74), .in_b(b64to74), .in_c(matrixC64), .out_a(a74to75), .out_b(b74to84), .out_b0(b74to84_ping), .out_b1(b74to84_pong), .out_c(matrixC74), .b_data_valid_ping(b_data_valid_ping_delay74), .b_data_valid_pong(b_data_valid_pong_delay74));
processing_element pe75(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay12), .in_a(a74to75), .in_b(b65to75), .in_c(matrixC65), .out_a(a75to76), .out_b(b75to85), .out_b0(b75to85_ping), .out_b1(b75to85_pong), .out_c(matrixC75), .b_data_valid_ping(b_data_valid_ping_delay75), .b_data_valid_pong(b_data_valid_pong_delay75));
processing_element pe76(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay13), .in_a(a75to76), .in_b(b66to76), .in_c(matrixC66), .out_a(a76to77), .out_b(b76to86), .out_b0(b76to86_ping), .out_b1(b76to86_pong), .out_c(matrixC76), .b_data_valid_ping(b_data_valid_ping_delay76), .b_data_valid_pong(b_data_valid_pong_delay76));
processing_element pe77(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay14), .in_a(a76to77), .in_b(b67to77), .in_c(matrixC67), .out_a(a77to78), .out_b(b77to87), .out_b0(b77to87_ping), .out_b1(b77to87_pong), .out_c(matrixC77), .b_data_valid_ping(b_data_valid_ping_delay77), .b_data_valid_pong(b_data_valid_pong_delay77));
processing_element pe78(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay15), .in_a(a77to78), .in_b(b68to78), .in_c(matrixC68), .out_a(a78to79), .out_b(b78to88), .out_b0(b78to88_ping), .out_b1(b78to88_pong), .out_c(matrixC78), .b_data_valid_ping(b_data_valid_ping_delay78), .b_data_valid_pong(b_data_valid_pong_delay78));
processing_element pe79(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay16), .in_a(a78to79), .in_b(b69to79), .in_c(matrixC69), .out_a(a79to710), .out_b(b79to89), .out_b0(b79to89_ping), .out_b1(b79to89_pong), .out_c(matrixC79), .b_data_valid_ping(b_data_valid_ping_delay79), .b_data_valid_pong(b_data_valid_pong_delay79));
processing_element pe710(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay17), .in_a(a79to710), .in_b(b610to710), .in_c(matrixC610), .out_a(a710to711), .out_b(b710to810), .out_b0(b710to810_ping), .out_b1(b710to810_pong), .out_c(matrixC710), .b_data_valid_ping(b_data_valid_ping_delay710), .b_data_valid_pong(b_data_valid_pong_delay710));
processing_element pe711(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay18), .in_a(a710to711), .in_b(b611to711), .in_c(matrixC611), .out_a(a711to712), .out_b(b711to811), .out_b0(b711to811_ping), .out_b1(b711to811_pong), .out_c(matrixC711), .b_data_valid_ping(b_data_valid_ping_delay711), .b_data_valid_pong(b_data_valid_pong_delay711));
processing_element pe712(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay19), .in_a(a711to712), .in_b(b612to712), .in_c(matrixC612), .out_a(a712to713), .out_b(b712to812), .out_b0(b712to812_ping), .out_b1(b712to812_pong), .out_c(matrixC712), .b_data_valid_ping(b_data_valid_ping_delay712), .b_data_valid_pong(b_data_valid_pong_delay712));
processing_element pe713(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay20), .in_a(a712to713), .in_b(b613to713), .in_c(matrixC613), .out_a(a713to714), .out_b(b713to813), .out_b0(b713to813_ping), .out_b1(b713to813_pong), .out_c(matrixC713), .b_data_valid_ping(b_data_valid_ping_delay713), .b_data_valid_pong(b_data_valid_pong_delay713));
processing_element pe714(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay21), .in_a(a713to714), .in_b(b614to714), .in_c(matrixC614), .out_a(a714to715), .out_b(b714to814), .out_b0(b714to814_ping), .out_b1(b714to814_pong), .out_c(matrixC714), .b_data_valid_ping(b_data_valid_ping_delay714), .b_data_valid_pong(b_data_valid_pong_delay714));
processing_element pe715(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay22), .in_a(a714to715), .in_b(b615to715), .in_c(matrixC615), .out_a(a715to716), .out_b(b715to815), .out_b0(b715to815_ping), .out_b1(b715to815_pong), .out_c(matrixC715), .b_data_valid_ping(b_data_valid_ping_delay715), .b_data_valid_pong(b_data_valid_pong_delay715));

processing_element pe80(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a8),      .in_b(b70to80), .in_c(matrixC70), .out_a(a80to81), .out_b(b80to90), .out_b0(b80to90_ping), .out_b1(b80to90_pong), .out_c(matrixC80), .b_data_valid_ping(b_data_valid_ping_delay80), .b_data_valid_pong(b_data_valid_pong_delay80));
processing_element pe81(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a80to81), .in_b(b71to81), .in_c(matrixC71), .out_a(a81to82), .out_b(b81to91), .out_b0(b81to91_ping), .out_b1(b81to91_pong), .out_c(matrixC81), .b_data_valid_ping(b_data_valid_ping_delay81), .b_data_valid_pong(b_data_valid_pong_delay81));
processing_element pe82(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a81to82), .in_b(b72to82), .in_c(matrixC72), .out_a(a82to83), .out_b(b82to92), .out_b0(b82to92_ping), .out_b1(b82to92_pong), .out_c(matrixC82), .b_data_valid_ping(b_data_valid_ping_delay82), .b_data_valid_pong(b_data_valid_pong_delay82));
processing_element pe83(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a82to83), .in_b(b73to83), .in_c(matrixC73), .out_a(a83to84), .out_b(b83to93), .out_b0(b83to93_ping), .out_b1(b83to93_pong), .out_c(matrixC83), .b_data_valid_ping(b_data_valid_ping_delay83), .b_data_valid_pong(b_data_valid_pong_delay83));
processing_element pe84(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay12), .in_a(a83to84), .in_b(b74to84), .in_c(matrixC74), .out_a(a84to85), .out_b(b84to94), .out_b0(b84to94_ping), .out_b1(b84to94_pong), .out_c(matrixC84), .b_data_valid_ping(b_data_valid_ping_delay84), .b_data_valid_pong(b_data_valid_pong_delay84));
processing_element pe85(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay13), .in_a(a84to85), .in_b(b75to85), .in_c(matrixC75), .out_a(a85to86), .out_b(b85to95), .out_b0(b85to95_ping), .out_b1(b85to95_pong), .out_c(matrixC85), .b_data_valid_ping(b_data_valid_ping_delay85), .b_data_valid_pong(b_data_valid_pong_delay85));
processing_element pe86(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay14), .in_a(a85to86), .in_b(b76to86), .in_c(matrixC76), .out_a(a86to87), .out_b(b86to96), .out_b0(b86to96_ping), .out_b1(b86to96_pong), .out_c(matrixC86), .b_data_valid_ping(b_data_valid_ping_delay86), .b_data_valid_pong(b_data_valid_pong_delay86));
processing_element pe87(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay15), .in_a(a86to87), .in_b(b77to87), .in_c(matrixC77), .out_a(a87to88), .out_b(b87to97), .out_b0(b87to97_ping), .out_b1(b87to97_pong), .out_c(matrixC87), .b_data_valid_ping(b_data_valid_ping_delay87), .b_data_valid_pong(b_data_valid_pong_delay87));
processing_element pe88(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay16), .in_a(a87to88), .in_b(b78to88), .in_c(matrixC78), .out_a(a88to89), .out_b(b88to98), .out_b0(b88to98_ping), .out_b1(b88to98_pong), .out_c(matrixC88), .b_data_valid_ping(b_data_valid_ping_delay88), .b_data_valid_pong(b_data_valid_pong_delay88));
processing_element pe89(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay17), .in_a(a88to89), .in_b(b79to89), .in_c(matrixC79), .out_a(a89to810), .out_b(b89to99), .out_b0(b89to99_ping), .out_b1(b89to99_pong), .out_c(matrixC89), .b_data_valid_ping(b_data_valid_ping_delay89), .b_data_valid_pong(b_data_valid_pong_delay89));
processing_element pe810(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay18), .in_a(a89to810), .in_b(b710to810), .in_c(matrixC710), .out_a(a810to811), .out_b(b810to910), .out_b0(b810to910_ping), .out_b1(b810to910_pong), .out_c(matrixC810), .b_data_valid_ping(b_data_valid_ping_delay810), .b_data_valid_pong(b_data_valid_pong_delay810));
processing_element pe811(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay19), .in_a(a810to811), .in_b(b711to811), .in_c(matrixC711), .out_a(a811to812), .out_b(b811to911), .out_b0(b811to911_ping), .out_b1(b811to911_pong), .out_c(matrixC811), .b_data_valid_ping(b_data_valid_ping_delay811), .b_data_valid_pong(b_data_valid_pong_delay811));
processing_element pe812(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay20), .in_a(a811to812), .in_b(b712to812), .in_c(matrixC712), .out_a(a812to813), .out_b(b812to912), .out_b0(b812to912_ping), .out_b1(b812to912_pong), .out_c(matrixC812), .b_data_valid_ping(b_data_valid_ping_delay812), .b_data_valid_pong(b_data_valid_pong_delay812));
processing_element pe813(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay21), .in_a(a812to813), .in_b(b713to813), .in_c(matrixC713), .out_a(a813to814), .out_b(b813to913), .out_b0(b813to913_ping), .out_b1(b813to913_pong), .out_c(matrixC813), .b_data_valid_ping(b_data_valid_ping_delay813), .b_data_valid_pong(b_data_valid_pong_delay813));
processing_element pe814(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay22), .in_a(a813to814), .in_b(b714to814), .in_c(matrixC714), .out_a(a814to815), .out_b(b814to914), .out_b0(b814to914_ping), .out_b1(b814to914_pong), .out_c(matrixC814), .b_data_valid_ping(b_data_valid_ping_delay814), .b_data_valid_pong(b_data_valid_pong_delay814));
processing_element pe815(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay23), .in_a(a814to815), .in_b(b715to815), .in_c(matrixC715), .out_a(a815to816), .out_b(b815to915), .out_b0(b815to915_ping), .out_b1(b815to915_pong), .out_c(matrixC815), .b_data_valid_ping(b_data_valid_ping_delay815), .b_data_valid_pong(b_data_valid_pong_delay815));

processing_element pe90(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a9),      .in_b(b80to90), .in_c(matrixC80), .out_a(a90to91), .out_b(b90to100), .out_b0(b90to100_ping), .out_b1(b90to100_pong), .out_c(matrixC90), .b_data_valid_ping(b_data_valid_ping_delay90), .b_data_valid_pong(b_data_valid_pong_delay90));
processing_element pe91(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a90to91), .in_b(b81to91), .in_c(matrixC81), .out_a(a91to92), .out_b(b91to101), .out_b0(b91to101_ping), .out_b1(b91to101_pong), .out_c(matrixC91), .b_data_valid_ping(b_data_valid_ping_delay91), .b_data_valid_pong(b_data_valid_pong_delay91));
processing_element pe92(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a91to92), .in_b(b82to92), .in_c(matrixC82), .out_a(a92to93), .out_b(b92to102), .out_b0(b92to102_ping), .out_b1(b92to102_pong), .out_c(matrixC92), .b_data_valid_ping(b_data_valid_ping_delay92), .b_data_valid_pong(b_data_valid_pong_delay92));
processing_element pe93(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay12), .in_a(a92to93), .in_b(b83to93), .in_c(matrixC83), .out_a(a93to94), .out_b(b93to103), .out_b0(b93to103_ping), .out_b1(b93to103_pong), .out_c(matrixC93), .b_data_valid_ping(b_data_valid_ping_delay93), .b_data_valid_pong(b_data_valid_pong_delay93));
processing_element pe94(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay13), .in_a(a93to94), .in_b(b84to94), .in_c(matrixC84), .out_a(a94to95), .out_b(b94to104), .out_b0(b94to104_ping), .out_b1(b94to104_pong), .out_c(matrixC94), .b_data_valid_ping(b_data_valid_ping_delay94), .b_data_valid_pong(b_data_valid_pong_delay94));
processing_element pe95(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay14), .in_a(a94to95), .in_b(b85to95), .in_c(matrixC85), .out_a(a95to96), .out_b(b95to105), .out_b0(b95to105_ping), .out_b1(b95to105_pong), .out_c(matrixC95), .b_data_valid_ping(b_data_valid_ping_delay95), .b_data_valid_pong(b_data_valid_pong_delay95));
processing_element pe96(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay15), .in_a(a95to96), .in_b(b86to96), .in_c(matrixC86), .out_a(a96to97), .out_b(b96to106), .out_b0(b96to106_ping), .out_b1(b96to106_pong), .out_c(matrixC96), .b_data_valid_ping(b_data_valid_ping_delay96), .b_data_valid_pong(b_data_valid_pong_delay96));
processing_element pe97(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay16), .in_a(a96to97), .in_b(b87to97), .in_c(matrixC87), .out_a(a97to98), .out_b(b97to107), .out_b0(b97to107_ping), .out_b1(b97to107_pong), .out_c(matrixC97), .b_data_valid_ping(b_data_valid_ping_delay97), .b_data_valid_pong(b_data_valid_pong_delay97));
processing_element pe98(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay17), .in_a(a97to98), .in_b(b88to98), .in_c(matrixC88), .out_a(a98to99), .out_b(b98to108), .out_b0(b98to108_ping), .out_b1(b98to108_pong), .out_c(matrixC98), .b_data_valid_ping(b_data_valid_ping_delay98), .b_data_valid_pong(b_data_valid_pong_delay98));
processing_element pe99(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay18), .in_a(a98to99), .in_b(b89to99), .in_c(matrixC89), .out_a(a99to910), .out_b(b99to109), .out_b0(b99to109_ping), .out_b1(b99to109_pong), .out_c(matrixC99), .b_data_valid_ping(b_data_valid_ping_delay99), .b_data_valid_pong(b_data_valid_pong_delay99));
processing_element pe910(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay19), .in_a(a99to910), .in_b(b810to910), .in_c(matrixC810), .out_a(a910to911), .out_b(b910to1010), .out_b0(b910to1010_ping), .out_b1(b910to1010_pong), .out_c(matrixC910), .b_data_valid_ping(b_data_valid_ping_delay910), .b_data_valid_pong(b_data_valid_pong_delay910));
processing_element pe911(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay20), .in_a(a910to911), .in_b(b811to911), .in_c(matrixC811), .out_a(a911to912), .out_b(b911to1011), .out_b0(b911to1011_ping), .out_b1(b911to1011_pong), .out_c(matrixC911), .b_data_valid_ping(b_data_valid_ping_delay911), .b_data_valid_pong(b_data_valid_pong_delay911));
processing_element pe912(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay21), .in_a(a911to912), .in_b(b812to912), .in_c(matrixC812), .out_a(a912to913), .out_b(b912to1012), .out_b0(b912to1012_ping), .out_b1(b912to1012_pong), .out_c(matrixC912), .b_data_valid_ping(b_data_valid_ping_delay912), .b_data_valid_pong(b_data_valid_pong_delay912));
processing_element pe913(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay22), .in_a(a912to913), .in_b(b813to913), .in_c(matrixC813), .out_a(a913to914), .out_b(b913to1013), .out_b0(b913to1013_ping), .out_b1(b913to1013_pong), .out_c(matrixC913), .b_data_valid_ping(b_data_valid_ping_delay913), .b_data_valid_pong(b_data_valid_pong_delay913));
processing_element pe914(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay23), .in_a(a913to914), .in_b(b814to914), .in_c(matrixC814), .out_a(a914to915), .out_b(b914to1014), .out_b0(b914to1014_ping), .out_b1(b914to1014_pong), .out_c(matrixC914), .b_data_valid_ping(b_data_valid_ping_delay914), .b_data_valid_pong(b_data_valid_pong_delay914));
processing_element pe915(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay24), .in_a(a914to915), .in_b(b815to915), .in_c(matrixC815), .out_a(a915to916), .out_b(b915to1015), .out_b0(b915to1015_ping), .out_b1(b915to1015_pong), .out_c(matrixC915), .b_data_valid_ping(b_data_valid_ping_delay915), .b_data_valid_pong(b_data_valid_pong_delay915));

processing_element pe100(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a10),      .in_b(b90to100), .in_c(matrixC90), .out_a(a100to101), .out_b(b100to110), .out_b0(b100to110_ping), .out_b1(b100to110_pong), .out_c(matrixC100), .b_data_valid_ping(b_data_valid_ping_delay100), .b_data_valid_pong(b_data_valid_pong_delay100));
processing_element pe101(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a100to101), .in_b(b91to101), .in_c(matrixC91), .out_a(a101to102), .out_b(b101to111), .out_b0(b101to111_ping), .out_b1(b101to111_pong), .out_c(matrixC101), .b_data_valid_ping(b_data_valid_ping_delay101), .b_data_valid_pong(b_data_valid_pong_delay101));
processing_element pe102(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay12), .in_a(a101to102), .in_b(b92to102), .in_c(matrixC92), .out_a(a102to103), .out_b(b102to112), .out_b0(b102to112_ping), .out_b1(b102to112_pong), .out_c(matrixC102), .b_data_valid_ping(b_data_valid_ping_delay102), .b_data_valid_pong(b_data_valid_pong_delay102));
processing_element pe103(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay13), .in_a(a102to103), .in_b(b93to103), .in_c(matrixC93), .out_a(a103to104), .out_b(b103to113), .out_b0(b103to113_ping), .out_b1(b103to113_pong), .out_c(matrixC103), .b_data_valid_ping(b_data_valid_ping_delay103), .b_data_valid_pong(b_data_valid_pong_delay103));
processing_element pe104(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay14), .in_a(a103to104), .in_b(b94to104), .in_c(matrixC94), .out_a(a104to105), .out_b(b104to114), .out_b0(b104to114_ping), .out_b1(b104to114_pong), .out_c(matrixC104), .b_data_valid_ping(b_data_valid_ping_delay104), .b_data_valid_pong(b_data_valid_pong_delay104));
processing_element pe105(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay15), .in_a(a104to105), .in_b(b95to105), .in_c(matrixC95), .out_a(a105to106), .out_b(b105to115), .out_b0(b105to115_ping), .out_b1(b105to115_pong), .out_c(matrixC105), .b_data_valid_ping(b_data_valid_ping_delay105), .b_data_valid_pong(b_data_valid_pong_delay105));
processing_element pe106(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay16), .in_a(a105to106), .in_b(b96to106), .in_c(matrixC96), .out_a(a106to107), .out_b(b106to116), .out_b0(b106to116_ping), .out_b1(b106to116_pong), .out_c(matrixC106), .b_data_valid_ping(b_data_valid_ping_delay106), .b_data_valid_pong(b_data_valid_pong_delay106));
processing_element pe107(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay17), .in_a(a106to107), .in_b(b97to107), .in_c(matrixC97), .out_a(a107to108), .out_b(b107to117), .out_b0(b107to117_ping), .out_b1(b107to117_pong), .out_c(matrixC107), .b_data_valid_ping(b_data_valid_ping_delay107), .b_data_valid_pong(b_data_valid_pong_delay107));
processing_element pe108(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay18), .in_a(a107to108), .in_b(b98to108), .in_c(matrixC98), .out_a(a108to109), .out_b(b108to118), .out_b0(b108to118_ping), .out_b1(b108to118_pong), .out_c(matrixC108), .b_data_valid_ping(b_data_valid_ping_delay108), .b_data_valid_pong(b_data_valid_pong_delay108));
processing_element pe109(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay19), .in_a(a108to109), .in_b(b99to109), .in_c(matrixC99), .out_a(a109to1010), .out_b(b109to119), .out_b0(b109to119_ping), .out_b1(b109to119_pong), .out_c(matrixC109), .b_data_valid_ping(b_data_valid_ping_delay109), .b_data_valid_pong(b_data_valid_pong_delay109));
processing_element pe1010(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay20), .in_a(a109to1010), .in_b(b910to1010), .in_c(matrixC910), .out_a(a1010to1011), .out_b(b1010to1110), .out_b0(b1010to1110_ping), .out_b1(b1010to1110_pong), .out_c(matrixC1010), .b_data_valid_ping(b_data_valid_ping_delay1010), .b_data_valid_pong(b_data_valid_pong_delay1010));
processing_element pe1011(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay21), .in_a(a1010to1011), .in_b(b911to1011), .in_c(matrixC911), .out_a(a1011to1012), .out_b(b1011to1111), .out_b0(b1011to1111_ping), .out_b1(b1011to1111_pong), .out_c(matrixC1011), .b_data_valid_ping(b_data_valid_ping_delay1011), .b_data_valid_pong(b_data_valid_pong_delay1011));
processing_element pe1012(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay22), .in_a(a1011to1012), .in_b(b912to1012), .in_c(matrixC912), .out_a(a1012to1013), .out_b(b1012to1112), .out_b0(b1012to1112_ping), .out_b1(b1012to1112_pong), .out_c(matrixC1012), .b_data_valid_ping(b_data_valid_ping_delay1012), .b_data_valid_pong(b_data_valid_pong_delay1012));
processing_element pe1013(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay23), .in_a(a1012to1013), .in_b(b913to1013), .in_c(matrixC913), .out_a(a1013to1014), .out_b(b1013to1113), .out_b0(b1013to1113_ping), .out_b1(b1013to1113_pong), .out_c(matrixC1013), .b_data_valid_ping(b_data_valid_ping_delay1013), .b_data_valid_pong(b_data_valid_pong_delay1013));
processing_element pe1014(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay24), .in_a(a1013to1014), .in_b(b914to1014), .in_c(matrixC914), .out_a(a1014to1015), .out_b(b1014to1114), .out_b0(b1014to1114_ping), .out_b1(b1014to1114_pong), .out_c(matrixC1014), .b_data_valid_ping(b_data_valid_ping_delay1014), .b_data_valid_pong(b_data_valid_pong_delay1014));
processing_element pe1015(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay25), .in_a(a1014to1015), .in_b(b915to1015), .in_c(matrixC915), .out_a(a1015to1016), .out_b(b1015to1115), .out_b0(b1015to1115_ping), .out_b1(b1015to1115_pong), .out_c(matrixC1015), .b_data_valid_ping(b_data_valid_ping_delay1015), .b_data_valid_pong(b_data_valid_pong_delay1015));

processing_element pe110(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a11),      .in_b(b100to110), .in_c(matrixC100), .out_a(a110to111), .out_b(b110to120), .out_b0(b110to120_ping), .out_b1(b110to120_pong), .out_c(matrixC110), .b_data_valid_ping(b_data_valid_ping_delay110), .b_data_valid_pong(b_data_valid_pong_delay110));
processing_element pe111(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay12), .in_a(a110to111), .in_b(b101to111), .in_c(matrixC101), .out_a(a111to112), .out_b(b111to121), .out_b0(b111to121_ping), .out_b1(b111to121_pong), .out_c(matrixC111), .b_data_valid_ping(b_data_valid_ping_delay111), .b_data_valid_pong(b_data_valid_pong_delay111));
processing_element pe112(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay13), .in_a(a111to112), .in_b(b102to112), .in_c(matrixC102), .out_a(a112to113), .out_b(b112to122), .out_b0(b112to122_ping), .out_b1(b112to122_pong), .out_c(matrixC112), .b_data_valid_ping(b_data_valid_ping_delay112), .b_data_valid_pong(b_data_valid_pong_delay112));
processing_element pe113(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay14), .in_a(a112to113), .in_b(b103to113), .in_c(matrixC103), .out_a(a113to114), .out_b(b113to123), .out_b0(b113to123_ping), .out_b1(b113to123_pong), .out_c(matrixC113), .b_data_valid_ping(b_data_valid_ping_delay113), .b_data_valid_pong(b_data_valid_pong_delay113));
processing_element pe114(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay15), .in_a(a113to114), .in_b(b104to114), .in_c(matrixC104), .out_a(a114to115), .out_b(b114to124), .out_b0(b114to124_ping), .out_b1(b114to124_pong), .out_c(matrixC114), .b_data_valid_ping(b_data_valid_ping_delay114), .b_data_valid_pong(b_data_valid_pong_delay114));
processing_element pe115(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay16), .in_a(a114to115), .in_b(b105to115), .in_c(matrixC105), .out_a(a115to116), .out_b(b115to125), .out_b0(b115to125_ping), .out_b1(b115to125_pong), .out_c(matrixC115), .b_data_valid_ping(b_data_valid_ping_delay115), .b_data_valid_pong(b_data_valid_pong_delay115));
processing_element pe116(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay17), .in_a(a115to116), .in_b(b106to116), .in_c(matrixC106), .out_a(a116to117), .out_b(b116to126), .out_b0(b116to126_ping), .out_b1(b116to126_pong), .out_c(matrixC116), .b_data_valid_ping(b_data_valid_ping_delay116), .b_data_valid_pong(b_data_valid_pong_delay116));
processing_element pe117(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay18), .in_a(a116to117), .in_b(b107to117), .in_c(matrixC107), .out_a(a117to118), .out_b(b117to127), .out_b0(b117to127_ping), .out_b1(b117to127_pong), .out_c(matrixC117), .b_data_valid_ping(b_data_valid_ping_delay117), .b_data_valid_pong(b_data_valid_pong_delay117));
processing_element pe118(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay19), .in_a(a117to118), .in_b(b108to118), .in_c(matrixC108), .out_a(a118to119), .out_b(b118to128), .out_b0(b118to128_ping), .out_b1(b118to128_pong), .out_c(matrixC118), .b_data_valid_ping(b_data_valid_ping_delay118), .b_data_valid_pong(b_data_valid_pong_delay118));
processing_element pe119(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay20), .in_a(a118to119), .in_b(b109to119), .in_c(matrixC109), .out_a(a119to1110), .out_b(b119to129), .out_b0(b119to129_ping), .out_b1(b119to129_pong), .out_c(matrixC119), .b_data_valid_ping(b_data_valid_ping_delay119), .b_data_valid_pong(b_data_valid_pong_delay119));
processing_element pe1110(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay21), .in_a(a119to1110), .in_b(b1010to1110), .in_c(matrixC1010), .out_a(a1110to1111), .out_b(b1110to1210), .out_b0(b1110to1210_ping), .out_b1(b1110to1210_pong), .out_c(matrixC1110), .b_data_valid_ping(b_data_valid_ping_delay1110), .b_data_valid_pong(b_data_valid_pong_delay1110));
processing_element pe1111(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay22), .in_a(a1110to1111), .in_b(b1011to1111), .in_c(matrixC1011), .out_a(a1111to1112), .out_b(b1111to1211), .out_b0(b1111to1211_ping), .out_b1(b1111to1211_pong), .out_c(matrixC1111), .b_data_valid_ping(b_data_valid_ping_delay1111), .b_data_valid_pong(b_data_valid_pong_delay1111));
processing_element pe1112(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay23), .in_a(a1111to1112), .in_b(b1012to1112), .in_c(matrixC1012), .out_a(a1112to1113), .out_b(b1112to1212), .out_b0(b1112to1212_ping), .out_b1(b1112to1212_pong), .out_c(matrixC1112), .b_data_valid_ping(b_data_valid_ping_delay1112), .b_data_valid_pong(b_data_valid_pong_delay1112));
processing_element pe1113(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay24), .in_a(a1112to1113), .in_b(b1013to1113), .in_c(matrixC1013), .out_a(a1113to1114), .out_b(b1113to1213), .out_b0(b1113to1213_ping), .out_b1(b1113to1213_pong), .out_c(matrixC1113), .b_data_valid_ping(b_data_valid_ping_delay1113), .b_data_valid_pong(b_data_valid_pong_delay1113));
processing_element pe1114(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay25), .in_a(a1113to1114), .in_b(b1014to1114), .in_c(matrixC1014), .out_a(a1114to1115), .out_b(b1114to1214), .out_b0(b1114to1214_ping), .out_b1(b1114to1214_pong), .out_c(matrixC1114), .b_data_valid_ping(b_data_valid_ping_delay1114), .b_data_valid_pong(b_data_valid_pong_delay1114));
processing_element pe1115(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay26), .in_a(a1114to1115), .in_b(b1015to1115), .in_c(matrixC1015), .out_a(a1115to1116), .out_b(b1115to1215), .out_b0(b1115to1215_ping), .out_b1(b1115to1215_pong), .out_c(matrixC1115), .b_data_valid_ping(b_data_valid_ping_delay1115), .b_data_valid_pong(b_data_valid_pong_delay1115));

processing_element pe120(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay12), .in_a(a12),      .in_b(b110to120), .in_c(matrixC110), .out_a(a120to121), .out_b(b120to130), .out_b0(b120to130_ping), .out_b1(b120to130_pong), .out_c(matrixC120), .b_data_valid_ping(b_data_valid_ping_delay120), .b_data_valid_pong(b_data_valid_pong_delay120));
processing_element pe121(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay13), .in_a(a120to121), .in_b(b111to121), .in_c(matrixC111), .out_a(a121to122), .out_b(b121to131), .out_b0(b121to131_ping), .out_b1(b121to131_pong), .out_c(matrixC121), .b_data_valid_ping(b_data_valid_ping_delay121), .b_data_valid_pong(b_data_valid_pong_delay121));
processing_element pe122(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay14), .in_a(a121to122), .in_b(b112to122), .in_c(matrixC112), .out_a(a122to123), .out_b(b122to132), .out_b0(b122to132_ping), .out_b1(b122to132_pong), .out_c(matrixC122), .b_data_valid_ping(b_data_valid_ping_delay122), .b_data_valid_pong(b_data_valid_pong_delay122));
processing_element pe123(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay15), .in_a(a122to123), .in_b(b113to123), .in_c(matrixC113), .out_a(a123to124), .out_b(b123to133), .out_b0(b123to133_ping), .out_b1(b123to133_pong), .out_c(matrixC123), .b_data_valid_ping(b_data_valid_ping_delay123), .b_data_valid_pong(b_data_valid_pong_delay123));
processing_element pe124(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay16), .in_a(a123to124), .in_b(b114to124), .in_c(matrixC114), .out_a(a124to125), .out_b(b124to134), .out_b0(b124to134_ping), .out_b1(b124to134_pong), .out_c(matrixC124), .b_data_valid_ping(b_data_valid_ping_delay124), .b_data_valid_pong(b_data_valid_pong_delay124));
processing_element pe125(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay17), .in_a(a124to125), .in_b(b115to125), .in_c(matrixC115), .out_a(a125to126), .out_b(b125to135), .out_b0(b125to135_ping), .out_b1(b125to135_pong), .out_c(matrixC125), .b_data_valid_ping(b_data_valid_ping_delay125), .b_data_valid_pong(b_data_valid_pong_delay125));
processing_element pe126(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay18), .in_a(a125to126), .in_b(b116to126), .in_c(matrixC116), .out_a(a126to127), .out_b(b126to136), .out_b0(b126to136_ping), .out_b1(b126to136_pong), .out_c(matrixC126), .b_data_valid_ping(b_data_valid_ping_delay126), .b_data_valid_pong(b_data_valid_pong_delay126));
processing_element pe127(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay19), .in_a(a126to127), .in_b(b117to127), .in_c(matrixC117), .out_a(a127to128), .out_b(b127to137), .out_b0(b127to137_ping), .out_b1(b127to137_pong), .out_c(matrixC127), .b_data_valid_ping(b_data_valid_ping_delay127), .b_data_valid_pong(b_data_valid_pong_delay127));
processing_element pe128(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay20), .in_a(a127to128), .in_b(b118to128), .in_c(matrixC118), .out_a(a128to129), .out_b(b128to138), .out_b0(b128to138_ping), .out_b1(b128to138_pong), .out_c(matrixC128), .b_data_valid_ping(b_data_valid_ping_delay128), .b_data_valid_pong(b_data_valid_pong_delay128));
processing_element pe129(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay21), .in_a(a128to129), .in_b(b119to129), .in_c(matrixC119), .out_a(a129to1210), .out_b(b129to139), .out_b0(b129to139_ping), .out_b1(b129to139_pong), .out_c(matrixC129), .b_data_valid_ping(b_data_valid_ping_delay129), .b_data_valid_pong(b_data_valid_pong_delay129));
processing_element pe1210(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay22), .in_a(a129to1210), .in_b(b1110to1210), .in_c(matrixC1110), .out_a(a1210to1211), .out_b(b1210to1310), .out_b0(b1210to1310_ping), .out_b1(b1210to1310_pong), .out_c(matrixC1210), .b_data_valid_ping(b_data_valid_ping_delay1210), .b_data_valid_pong(b_data_valid_pong_delay1210));
processing_element pe1211(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay23), .in_a(a1210to1211), .in_b(b1111to1211), .in_c(matrixC1111), .out_a(a1211to1212), .out_b(b1211to1311), .out_b0(b1211to1311_ping), .out_b1(b1211to1311_pong), .out_c(matrixC1211), .b_data_valid_ping(b_data_valid_ping_delay1211), .b_data_valid_pong(b_data_valid_pong_delay1211));
processing_element pe1212(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay24), .in_a(a1211to1212), .in_b(b1112to1212), .in_c(matrixC1112), .out_a(a1212to1213), .out_b(b1212to1312), .out_b0(b1212to1312_ping), .out_b1(b1212to1312_pong), .out_c(matrixC1212), .b_data_valid_ping(b_data_valid_ping_delay1212), .b_data_valid_pong(b_data_valid_pong_delay1212));
processing_element pe1213(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay25), .in_a(a1212to1213), .in_b(b1113to1213), .in_c(matrixC1113), .out_a(a1213to1214), .out_b(b1213to1313), .out_b0(b1213to1313_ping), .out_b1(b1213to1313_pong), .out_c(matrixC1213), .b_data_valid_ping(b_data_valid_ping_delay1213), .b_data_valid_pong(b_data_valid_pong_delay1213));
processing_element pe1214(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay26), .in_a(a1213to1214), .in_b(b1114to1214), .in_c(matrixC1114), .out_a(a1214to1215), .out_b(b1214to1314), .out_b0(b1214to1314_ping), .out_b1(b1214to1314_pong), .out_c(matrixC1214), .b_data_valid_ping(b_data_valid_ping_delay1214), .b_data_valid_pong(b_data_valid_pong_delay1214));
processing_element pe1215(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay27), .in_a(a1214to1215), .in_b(b1115to1215), .in_c(matrixC1115), .out_a(a1215to1216), .out_b(b1215to1315), .out_b0(b1215to1315_ping), .out_b1(b1215to1315_pong), .out_c(matrixC1215), .b_data_valid_ping(b_data_valid_ping_delay1215), .b_data_valid_pong(b_data_valid_pong_delay1215));

processing_element pe130(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay13), .in_a(a13),      .in_b(b120to130), .in_c(matrixC120), .out_a(a130to131), .out_b(b130to140), .out_b0(b130to140_ping), .out_b1(b130to140_pong), .out_c(matrixC130), .b_data_valid_ping(b_data_valid_ping_delay130), .b_data_valid_pong(b_data_valid_pong_delay130));
processing_element pe131(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay14), .in_a(a130to131), .in_b(b121to131), .in_c(matrixC121), .out_a(a131to132), .out_b(b131to141), .out_b0(b131to141_ping), .out_b1(b131to141_pong), .out_c(matrixC131), .b_data_valid_ping(b_data_valid_ping_delay131), .b_data_valid_pong(b_data_valid_pong_delay131));
processing_element pe132(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay15), .in_a(a131to132), .in_b(b122to132), .in_c(matrixC122), .out_a(a132to133), .out_b(b132to142), .out_b0(b132to142_ping), .out_b1(b132to142_pong), .out_c(matrixC132), .b_data_valid_ping(b_data_valid_ping_delay132), .b_data_valid_pong(b_data_valid_pong_delay132));
processing_element pe133(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay16), .in_a(a132to133), .in_b(b123to133), .in_c(matrixC123), .out_a(a133to134), .out_b(b133to143), .out_b0(b133to143_ping), .out_b1(b133to143_pong), .out_c(matrixC133), .b_data_valid_ping(b_data_valid_ping_delay133), .b_data_valid_pong(b_data_valid_pong_delay133));
processing_element pe134(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay17), .in_a(a133to134), .in_b(b124to134), .in_c(matrixC124), .out_a(a134to135), .out_b(b134to144), .out_b0(b134to144_ping), .out_b1(b134to144_pong), .out_c(matrixC134), .b_data_valid_ping(b_data_valid_ping_delay134), .b_data_valid_pong(b_data_valid_pong_delay134));
processing_element pe135(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay18), .in_a(a134to135), .in_b(b125to135), .in_c(matrixC125), .out_a(a135to136), .out_b(b135to145), .out_b0(b135to145_ping), .out_b1(b135to145_pong), .out_c(matrixC135), .b_data_valid_ping(b_data_valid_ping_delay135), .b_data_valid_pong(b_data_valid_pong_delay135));
processing_element pe136(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay19), .in_a(a135to136), .in_b(b126to136), .in_c(matrixC126), .out_a(a136to137), .out_b(b136to146), .out_b0(b136to146_ping), .out_b1(b136to146_pong), .out_c(matrixC136), .b_data_valid_ping(b_data_valid_ping_delay136), .b_data_valid_pong(b_data_valid_pong_delay136));
processing_element pe137(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay20), .in_a(a136to137), .in_b(b127to137), .in_c(matrixC127), .out_a(a137to138), .out_b(b137to147), .out_b0(b137to147_ping), .out_b1(b137to147_pong), .out_c(matrixC137), .b_data_valid_ping(b_data_valid_ping_delay137), .b_data_valid_pong(b_data_valid_pong_delay137));
processing_element pe138(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay21), .in_a(a137to138), .in_b(b128to138), .in_c(matrixC128), .out_a(a138to139), .out_b(b138to148), .out_b0(b138to148_ping), .out_b1(b138to148_pong), .out_c(matrixC138), .b_data_valid_ping(b_data_valid_ping_delay138), .b_data_valid_pong(b_data_valid_pong_delay138));
processing_element pe139(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay22), .in_a(a138to139), .in_b(b129to139), .in_c(matrixC129), .out_a(a139to1310), .out_b(b139to149), .out_b0(b139to149_ping), .out_b1(b139to149_pong), .out_c(matrixC139), .b_data_valid_ping(b_data_valid_ping_delay139), .b_data_valid_pong(b_data_valid_pong_delay139));
processing_element pe1310(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay23), .in_a(a139to1310), .in_b(b1210to1310), .in_c(matrixC1210), .out_a(a1310to1311), .out_b(b1310to1410), .out_b0(b1310to1410_ping), .out_b1(b1310to1410_pong), .out_c(matrixC1310), .b_data_valid_ping(b_data_valid_ping_delay1310), .b_data_valid_pong(b_data_valid_pong_delay1310));
processing_element pe1311(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay24), .in_a(a1310to1311), .in_b(b1211to1311), .in_c(matrixC1211), .out_a(a1311to1312), .out_b(b1311to1411), .out_b0(b1311to1411_ping), .out_b1(b1311to1411_pong), .out_c(matrixC1311), .b_data_valid_ping(b_data_valid_ping_delay1311), .b_data_valid_pong(b_data_valid_pong_delay1311));
processing_element pe1312(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay25), .in_a(a1311to1312), .in_b(b1212to1312), .in_c(matrixC1212), .out_a(a1312to1313), .out_b(b1312to1412), .out_b0(b1312to1412_ping), .out_b1(b1312to1412_pong), .out_c(matrixC1312), .b_data_valid_ping(b_data_valid_ping_delay1312), .b_data_valid_pong(b_data_valid_pong_delay1312));
processing_element pe1313(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay26), .in_a(a1312to1313), .in_b(b1213to1313), .in_c(matrixC1213), .out_a(a1313to1314), .out_b(b1313to1413), .out_b0(b1313to1413_ping), .out_b1(b1313to1413_pong), .out_c(matrixC1313), .b_data_valid_ping(b_data_valid_ping_delay1313), .b_data_valid_pong(b_data_valid_pong_delay1313));
processing_element pe1314(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay27), .in_a(a1313to1314), .in_b(b1214to1314), .in_c(matrixC1214), .out_a(a1314to1315), .out_b(b1314to1414), .out_b0(b1314to1414_ping), .out_b1(b1314to1414_pong), .out_c(matrixC1314), .b_data_valid_ping(b_data_valid_ping_delay1314), .b_data_valid_pong(b_data_valid_pong_delay1314));
processing_element pe1315(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay28), .in_a(a1314to1315), .in_b(b1215to1315), .in_c(matrixC1215), .out_a(a1315to1316), .out_b(b1315to1415), .out_b0(b1315to1415_ping), .out_b1(b1315to1415_pong), .out_c(matrixC1315), .b_data_valid_ping(b_data_valid_ping_delay1315), .b_data_valid_pong(b_data_valid_pong_delay1315));

processing_element pe140(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay14), .in_a(a14),      .in_b(b130to140), .in_c(matrixC130), .out_a(a140to141), .out_b(b140to150), .out_b0(b140to150_ping), .out_b1(b140to150_pong), .out_c(matrixC140), .b_data_valid_ping(b_data_valid_ping_delay140), .b_data_valid_pong(b_data_valid_pong_delay140));
processing_element pe141(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay15), .in_a(a140to141), .in_b(b131to141), .in_c(matrixC131), .out_a(a141to142), .out_b(b141to151), .out_b0(b141to151_ping), .out_b1(b141to151_pong), .out_c(matrixC141), .b_data_valid_ping(b_data_valid_ping_delay141), .b_data_valid_pong(b_data_valid_pong_delay141));
processing_element pe142(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay16), .in_a(a141to142), .in_b(b132to142), .in_c(matrixC132), .out_a(a142to143), .out_b(b142to152), .out_b0(b142to152_ping), .out_b1(b142to152_pong), .out_c(matrixC142), .b_data_valid_ping(b_data_valid_ping_delay142), .b_data_valid_pong(b_data_valid_pong_delay142));
processing_element pe143(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay17), .in_a(a142to143), .in_b(b133to143), .in_c(matrixC133), .out_a(a143to144), .out_b(b143to153), .out_b0(b143to153_ping), .out_b1(b143to153_pong), .out_c(matrixC143), .b_data_valid_ping(b_data_valid_ping_delay143), .b_data_valid_pong(b_data_valid_pong_delay143));
processing_element pe144(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay18), .in_a(a143to144), .in_b(b134to144), .in_c(matrixC134), .out_a(a144to145), .out_b(b144to154), .out_b0(b144to154_ping), .out_b1(b144to154_pong), .out_c(matrixC144), .b_data_valid_ping(b_data_valid_ping_delay144), .b_data_valid_pong(b_data_valid_pong_delay144));
processing_element pe145(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay19), .in_a(a144to145), .in_b(b135to145), .in_c(matrixC135), .out_a(a145to146), .out_b(b145to155), .out_b0(b145to155_ping), .out_b1(b145to155_pong), .out_c(matrixC145), .b_data_valid_ping(b_data_valid_ping_delay145), .b_data_valid_pong(b_data_valid_pong_delay145));
processing_element pe146(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay20), .in_a(a145to146), .in_b(b136to146), .in_c(matrixC136), .out_a(a146to147), .out_b(b146to156), .out_b0(b146to156_ping), .out_b1(b146to156_pong), .out_c(matrixC146), .b_data_valid_ping(b_data_valid_ping_delay146), .b_data_valid_pong(b_data_valid_pong_delay146));
processing_element pe147(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay21), .in_a(a146to147), .in_b(b137to147), .in_c(matrixC137), .out_a(a147to148), .out_b(b147to157), .out_b0(b147to157_ping), .out_b1(b147to157_pong), .out_c(matrixC147), .b_data_valid_ping(b_data_valid_ping_delay147), .b_data_valid_pong(b_data_valid_pong_delay147));
processing_element pe148(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay22), .in_a(a147to148), .in_b(b138to148), .in_c(matrixC138), .out_a(a148to149), .out_b(b148to158), .out_b0(b148to158_ping), .out_b1(b148to158_pong), .out_c(matrixC148), .b_data_valid_ping(b_data_valid_ping_delay148), .b_data_valid_pong(b_data_valid_pong_delay148));
processing_element pe149(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay23), .in_a(a148to149), .in_b(b139to149), .in_c(matrixC139), .out_a(a149to1410), .out_b(b149to159), .out_b0(b149to159_ping), .out_b1(b149to159_pong), .out_c(matrixC149), .b_data_valid_ping(b_data_valid_ping_delay149), .b_data_valid_pong(b_data_valid_pong_delay149));
processing_element pe1410(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay24), .in_a(a149to1410), .in_b(b1310to1410), .in_c(matrixC1310), .out_a(a1410to1411), .out_b(b1410to1510), .out_b0(b1410to1510_ping), .out_b1(b1410to1510_pong), .out_c(matrixC1410), .b_data_valid_ping(b_data_valid_ping_delay1410), .b_data_valid_pong(b_data_valid_pong_delay1410));
processing_element pe1411(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay25), .in_a(a1410to1411), .in_b(b1311to1411), .in_c(matrixC1311), .out_a(a1411to1412), .out_b(b1411to1511), .out_b0(b1411to1511_ping), .out_b1(b1411to1511_pong), .out_c(matrixC1411), .b_data_valid_ping(b_data_valid_ping_delay1411), .b_data_valid_pong(b_data_valid_pong_delay1411));
processing_element pe1412(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay26), .in_a(a1411to1412), .in_b(b1312to1412), .in_c(matrixC1312), .out_a(a1412to1413), .out_b(b1412to1512), .out_b0(b1412to1512_ping), .out_b1(b1412to1512_pong), .out_c(matrixC1412), .b_data_valid_ping(b_data_valid_ping_delay1412), .b_data_valid_pong(b_data_valid_pong_delay1412));
processing_element pe1413(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay27), .in_a(a1412to1413), .in_b(b1313to1413), .in_c(matrixC1313), .out_a(a1413to1414), .out_b(b1413to1513), .out_b0(b1413to1513_ping), .out_b1(b1413to1513_pong), .out_c(matrixC1413), .b_data_valid_ping(b_data_valid_ping_delay1413), .b_data_valid_pong(b_data_valid_pong_delay1413));
processing_element pe1414(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay28), .in_a(a1413to1414), .in_b(b1314to1414), .in_c(matrixC1314), .out_a(a1414to1415), .out_b(b1414to1514), .out_b0(b1414to1514_ping), .out_b1(b1414to1514_pong), .out_c(matrixC1414), .b_data_valid_ping(b_data_valid_ping_delay1414), .b_data_valid_pong(b_data_valid_pong_delay1414));
processing_element pe1415(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay29), .in_a(a1414to1415), .in_b(b1315to1415), .in_c(matrixC1315), .out_a(a1415to1416), .out_b(b1415to1515), .out_b0(b1415to1515_ping), .out_b1(b1415to1515_pong), .out_c(matrixC1415), .b_data_valid_ping(b_data_valid_ping_delay1415), .b_data_valid_pong(b_data_valid_pong_delay1415));

processing_element pe150(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay15), .in_a(a15),      .in_b(b140to150), .in_c(matrixC140), .out_a(a150to151), .out_b(b150to160), .out_b0(b150to160_ping), .out_b1(b150to160_pong), .out_c(matrixC150), .b_data_valid_ping(b_data_valid_ping_delay150), .b_data_valid_pong(b_data_valid_pong_delay150));
processing_element pe151(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay16), .in_a(a150to151), .in_b(b141to151), .in_c(matrixC141), .out_a(a151to152), .out_b(b151to161), .out_b0(b151to161_ping), .out_b1(b151to161_pong), .out_c(matrixC151), .b_data_valid_ping(b_data_valid_ping_delay151), .b_data_valid_pong(b_data_valid_pong_delay151));
processing_element pe152(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay17), .in_a(a151to152), .in_b(b142to152), .in_c(matrixC142), .out_a(a152to153), .out_b(b152to162), .out_b0(b152to162_ping), .out_b1(b152to162_pong), .out_c(matrixC152), .b_data_valid_ping(b_data_valid_ping_delay152), .b_data_valid_pong(b_data_valid_pong_delay152));
processing_element pe153(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay18), .in_a(a152to153), .in_b(b143to153), .in_c(matrixC143), .out_a(a153to154), .out_b(b153to163), .out_b0(b153to163_ping), .out_b1(b153to163_pong), .out_c(matrixC153), .b_data_valid_ping(b_data_valid_ping_delay153), .b_data_valid_pong(b_data_valid_pong_delay153));
processing_element pe154(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay19), .in_a(a153to154), .in_b(b144to154), .in_c(matrixC144), .out_a(a154to155), .out_b(b154to164), .out_b0(b154to164_ping), .out_b1(b154to164_pong), .out_c(matrixC154), .b_data_valid_ping(b_data_valid_ping_delay154), .b_data_valid_pong(b_data_valid_pong_delay154));
processing_element pe155(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay20), .in_a(a154to155), .in_b(b145to155), .in_c(matrixC145), .out_a(a155to156), .out_b(b155to165), .out_b0(b155to165_ping), .out_b1(b155to165_pong), .out_c(matrixC155), .b_data_valid_ping(b_data_valid_ping_delay155), .b_data_valid_pong(b_data_valid_pong_delay155));
processing_element pe156(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay21), .in_a(a155to156), .in_b(b146to156), .in_c(matrixC146), .out_a(a156to157), .out_b(b156to166), .out_b0(b156to166_ping), .out_b1(b156to166_pong), .out_c(matrixC156), .b_data_valid_ping(b_data_valid_ping_delay156), .b_data_valid_pong(b_data_valid_pong_delay156));
processing_element pe157(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay22), .in_a(a156to157), .in_b(b147to157), .in_c(matrixC147), .out_a(a157to158), .out_b(b157to167), .out_b0(b157to167_ping), .out_b1(b157to167_pong), .out_c(matrixC157), .b_data_valid_ping(b_data_valid_ping_delay157), .b_data_valid_pong(b_data_valid_pong_delay157));
processing_element pe158(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay23), .in_a(a157to158), .in_b(b148to158), .in_c(matrixC148), .out_a(a158to159), .out_b(b158to168), .out_b0(b158to168_ping), .out_b1(b158to168_pong), .out_c(matrixC158), .b_data_valid_ping(b_data_valid_ping_delay158), .b_data_valid_pong(b_data_valid_pong_delay158));
processing_element pe159(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay24), .in_a(a158to159), .in_b(b149to159), .in_c(matrixC149), .out_a(a159to1510), .out_b(b159to169), .out_b0(b159to169_ping), .out_b1(b159to169_pong), .out_c(matrixC159), .b_data_valid_ping(b_data_valid_ping_delay159), .b_data_valid_pong(b_data_valid_pong_delay159));
processing_element pe1510(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay25), .in_a(a159to1510), .in_b(b1410to1510), .in_c(matrixC1410), .out_a(a1510to1511), .out_b(b1510to1610), .out_b0(b1510to1610_ping), .out_b1(b1510to1610_pong), .out_c(matrixC1510), .b_data_valid_ping(b_data_valid_ping_delay1510), .b_data_valid_pong(b_data_valid_pong_delay1510));
processing_element pe1511(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay26), .in_a(a1510to1511), .in_b(b1411to1511), .in_c(matrixC1411), .out_a(a1511to1512), .out_b(b1511to1611), .out_b0(b1511to1611_ping), .out_b1(b1511to1611_pong), .out_c(matrixC1511), .b_data_valid_ping(b_data_valid_ping_delay1511), .b_data_valid_pong(b_data_valid_pong_delay1511));
processing_element pe1512(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay27), .in_a(a1511to1512), .in_b(b1412to1512), .in_c(matrixC1412), .out_a(a1512to1513), .out_b(b1512to1612), .out_b0(b1512to1612_ping), .out_b1(b1512to1612_pong), .out_c(matrixC1512), .b_data_valid_ping(b_data_valid_ping_delay1512), .b_data_valid_pong(b_data_valid_pong_delay1512));
processing_element pe1513(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay28), .in_a(a1512to1513), .in_b(b1413to1513), .in_c(matrixC1413), .out_a(a1513to1514), .out_b(b1513to1613), .out_b0(b1513to1613_ping), .out_b1(b1513to1613_pong), .out_c(matrixC1513), .b_data_valid_ping(b_data_valid_ping_delay1513), .b_data_valid_pong(b_data_valid_pong_delay1513));
processing_element pe1514(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay29), .in_a(a1513to1514), .in_b(b1414to1514), .in_c(matrixC1414), .out_a(a1514to1515), .out_b(b1514to1614), .out_b0(b1514to1614_ping), .out_b1(b1514to1614_pong), .out_c(matrixC1514), .b_data_valid_ping(b_data_valid_ping_delay1514), .b_data_valid_pong(b_data_valid_pong_delay1514));
processing_element pe1515(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay30), .in_a(a1514to1515), .in_b(b1415to1515), .in_c(matrixC1415), .out_a(a1515to1516), .out_b(b1515to1615), .out_b0(b1515to1615_ping), .out_b1(b1515to1615_pong), .out_c(matrixC1515), .b_data_valid_ping(b_data_valid_ping_delay1515), .b_data_valid_pong(b_data_valid_pong_delay1515));

  
assign a_data_out = {a1515to1516, a1415to1416, a1315to1316, a1215to1216, a1115to1116, a1015to1016, a915to916, a815to816, a715to716, a615to616, a515to516, a415to416, a315to316, a215to216, a115to116, a015to016};
assign b_data_out = {b1515to1615, b1514to1614, b1513to1613, b1512to1612, b1511to1611, b1510to1610, b159to169, b158to168, b157to167, b156to166, b155to165, b154to164, b153to163, b152to162, b151to161, b150to160};

endmodule

//////////////////////////////////////////////////////////////////////////
// Processing element (PE)
//////////////////////////////////////////////////////////////////////////

module processing_element(
    reset, 
    clk, 
    b_data_sel,
    in_a,
    in_b,
    in_c,
    out_a,
    out_b, 
    out_b0,
    out_b1,
    out_c,
    b_data_valid_ping,
    b_data_valid_pong
 );

input reset;
input clk;
input b_data_sel;
input b_data_valid_ping;
input b_data_valid_pong;
input  [`DWIDTH-1:0] in_a;
input  [`DWIDTH-1:0] in_b; 
input  [`DWIDTH-1:0] in_c; 
output [`DWIDTH-1:0] out_a;
output [`DWIDTH-1:0] out_b;
output [`DWIDTH-1:0] out_b0;
output [`DWIDTH-1:0] out_b1;
output [`DWIDTH-1:0] out_c;  // reduced precision

reg [`DWIDTH-1:0] out_a;
reg [`DWIDTH-1:0] out_b;
reg [`DWIDTH-1:0] out_b0;
reg [`DWIDTH-1:0] out_b1;

wire [`DWIDTH-1:0] in_mac;
wire [`DWIDTH-1:0] out_c;
wire [`DWIDTH-1:0] out_mac;

assign out_c = out_mac;
assign in_mac = (b_data_sel==0)? out_b0 : out_b1;
        
seq_mac u_mac(.a(out_a), .b(in_mac), .c(in_c), .out(out_mac), .reset(reset), .clk(clk));

always @(posedge clk)begin
    if(reset) begin
        out_a<=0;
    end
    else begin  
        out_a<=in_a;
    end
end

always @(posedge clk)begin
    if(reset) begin
        out_b<=0;
    end
    else begin  
        out_b<=in_b;
    end
end

always @(posedge clk)begin 
    if (reset) begin
        out_b0<=0;
    end
    if(b_data_valid_ping == 1) begin
        out_b0<=in_b;
    end
end

always @(posedge clk)begin 
    if (reset) begin
        out_b1<=0;
    end
    if(b_data_valid_pong == 1) begin
        out_b1<=in_b;
    end
end

endmodule

//////////////////////////////////////////////////////////////////////////
// Multiply-and-accumulate (MAC) block
//////////////////////////////////////////////////////////////////////////

module seq_mac(a, b, c, out, reset, clk);

input [`DWIDTH-1:0] a;
input [`DWIDTH-1:0] b;
input [`DWIDTH-1:0] c;
input reset;
input clk;
output [`DWIDTH-1:0] out;

wire [`DWIDTH-1:0] mul_out;
wire [`DWIDTH-1:0] add_out;

reg [`DWIDTH-1:0] a_flopped;
reg [`DWIDTH-1:0] b_flopped;
reg [`DWIDTH-1:0] c_flopped;

wire [2*`DWIDTH-1:0] mul_out_temp;
wire [2*`DWIDTH-1:0] mul_out_temp_reg;

always @(posedge clk) begin
  if (reset) begin
    a_flopped <= 0;
    b_flopped <= 0;
    c_flopped <= 0;
  end else begin
    a_flopped <= a;
    b_flopped <= b;
    c_flopped <= c;
  end
end
  
// assign mul_out = a * b;
qmult mult_u1(.i_multiplicand(a_flopped), .i_multiplier(b_flopped), .o_result(mul_out_temp));


// down cast the result
// todo: do a fused multiply add. Truncate only once after the accumulation is complete
assign mul_out = 
    (mul_out_temp[2*`DWIDTH-1] == 0) ?  //positive number
        (
           (|(mul_out_temp[2*`DWIDTH-2 : `DWIDTH-1])) ?  //is any bit from 14:7 is 1, that means overlfow
             {mul_out_temp[2*`DWIDTH-1] , {(`DWIDTH-1){1'b1}}} : //sign bit and then all 1s
             {mul_out_temp[2*`DWIDTH-1] , mul_out_temp[`DWIDTH-2:0]} 
        )
        : //negative number
        (
           (|(mul_out_temp[2*`DWIDTH-2 : `DWIDTH-1])) ?  //is any bit from 14:7 is 0, that means overlfow
             {mul_out_temp[2*`DWIDTH-1] , mul_out_temp[`DWIDTH-2:0]} :
             {mul_out_temp[2*`DWIDTH-1] , {(`DWIDTH-1){1'b0}}} //sign bit and then all 0s
        );


// we just truncate the higher bits of the product
// assign out = mul_out + c_flopped;
qadd add_u1(.a(c_flopped), .b(mul_out), .c(out));

endmodule


//////////////////////////////////////////////////////////////////////////
// Multiplier
//////////////////////////////////////////////////////////////////////////

module qmult(i_multiplicand,i_multiplier,o_result);

input [`DWIDTH-1:0] i_multiplicand;
input [`DWIDTH-1:0] i_multiplier;
output [2*`DWIDTH-1:0] o_result;

assign o_result = i_multiplicand * i_multiplier;
//DW02_mult #(`DWIDTH,`DWIDTH) u_mult(.A(i_multiplicand), .B(i_multiplier), .TC(1'b1), .PRODUCT(o_result));

endmodule


//////////////////////////////////////////////////////////////////////////
// Adder
//////////////////////////////////////////////////////////////////////////
// todo: Output should have one extra bit as compared to the inputs

module qadd(a,b,c);

input [`DWIDTH-1:0] a;
input [`DWIDTH-1:0] b;
output [`DWIDTH-1:0] c;

assign c = a + b;
// DW01_add #(`DWIDTH) u_add(.A(a), .B(b), .CI(1'b0), .SUM(c), .CO());

endmodule
