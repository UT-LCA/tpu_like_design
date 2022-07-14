////////////////////////////////////////////////////////////////////////////////
// THIS FILE WAS AUTOMATICALLY GENERATED FROM generate_matmul.v.mako
// DO NOT EDIT
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns
`define DWIDTH 8
`define AWIDTH 11
`define MEM_SIZE 2048

`define MAT_MUL_SIZE 8
`define MASK_WIDTH 8
`define LOG2_MAT_MUL_SIZE 3

`define BB_MAT_MUL_SIZE `MAT_MUL_SIZE
`define NUM_CYCLES_IN_MAC 3
`define MEM_ACCESS_LATENCY 1
`define REG_DATAWIDTH 32
`define REG_ADDRWIDTH 8
`define ADDR_STRIDE_WIDTH 8
`define MAX_BITS_POOL 3
`define VCS

module matmul_8x8_systolic(
    clk,
    reset,
    pe_reset,
    start_mat_mul,
    done_mat_mul,
    num_matrices_A,
    num_matrices_B,
    address_mat_a,
    address_mat_b,
    address_stride_a,
    address_stride_b,
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
    matrixC7_0,
    matrixC7_1,
    matrixC7_2,
    matrixC7_3,
    matrixC7_4,
    matrixC7_5,
    matrixC7_6,
    matrixC7_7,
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
input [31:0] num_matrices_A; // Number of 8x8 matrices the input matrix can be divided into
input [31:0] num_matrices_B; // Number of 8x8 matrices the weight matrix can be divided into
input [`AWIDTH-1:0] address_mat_a;
input [`AWIDTH-1:0] address_mat_b;
input [`ADDR_STRIDE_WIDTH-1:0] address_stride_a;
input [`ADDR_STRIDE_WIDTH-1:0] address_stride_b;
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
output [`DWIDTH-1:0] matrixC7_0;
output [`DWIDTH-1:0] matrixC7_1;
output [`DWIDTH-1:0] matrixC7_2;
output [`DWIDTH-1:0] matrixC7_3;
output [`DWIDTH-1:0] matrixC7_4;
output [`DWIDTH-1:0] matrixC7_5;
output [`DWIDTH-1:0] matrixC7_6;
output [`DWIDTH-1:0] matrixC7_7;
input [`MASK_WIDTH-1:0] validity_mask_a_rows;
input [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows;
input [`MASK_WIDTH-1:0] validity_mask_b_cols;
input [15:0] a_loc;
input [15:0] b_loc;

//////////////////////////////////////////////////////////////////////////
// Logic for clock counting and when to assert done
//////////////////////////////////////////////////////////////////////////

reg done_mat_mul;
// This is set to 15 bits in accordance with the previous simulations.
// In general, a systolic multiplier takes 4*N-2+P cycles, where N is the size 
// of the matmul and P is the number of pipeline stages in the MAC block.
reg [15:0] clk_cnt;

// Finding out number of cycles to assert matmul done.
// When we have to save the outputs to accumulators, then we don't need to
// shift out data. So, we can assert done_mat_mul early.
// Note: the count expression used to contain "num_matrices_8x8*8", but 
// to avoid multiplication, we now use "num_matrices_8x8 << 3"
wire [15:0] clk_cnt_for_done;
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
wire [`DWIDTH-1:0] b0_data;
wire [`DWIDTH-1:0] b1_data;
wire [`DWIDTH-1:0] b2_data;
wire [`DWIDTH-1:0] b3_data;
wire [`DWIDTH-1:0] b4_data;
wire [`DWIDTH-1:0] b5_data;
wire [`DWIDTH-1:0] b6_data;
wire [`DWIDTH-1:0] b7_data;
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
    .b0_data(b0_data),
    .b1_data_delayed_1(b1_data_delayed_1),
    .b2_data_delayed_2(b2_data_delayed_2),
    .b3_data_delayed_3(b3_data_delayed_3),
    .b4_data_delayed_4(b4_data_delayed_4),
    .b5_data_delayed_5(b5_data_delayed_5),
    .b6_data_delayed_6(b6_data_delayed_6),
    .b7_data_delayed_7(b7_data_delayed_7),
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
wire [`DWIDTH-1:0] b0;
wire [`DWIDTH-1:0] b1;
wire [`DWIDTH-1:0] b2;
wire [`DWIDTH-1:0] b3;
wire [`DWIDTH-1:0] b4;
wire [`DWIDTH-1:0] b5;
wire [`DWIDTH-1:0] b6;
wire [`DWIDTH-1:0] b7;
wire [`DWIDTH-1:0] c0;
wire [`DWIDTH-1:0] c1;
wire [`DWIDTH-1:0] c2;
wire [`DWIDTH-1:0] c3;
wire [`DWIDTH-1:0] c4;
wire [`DWIDTH-1:0] c5;
wire [`DWIDTH-1:0] c6;
wire [`DWIDTH-1:0] c7;

wire [`DWIDTH-1:0] a0_data_in;
wire [`DWIDTH-1:0] a1_data_in;
wire [`DWIDTH-1:0] a2_data_in;
wire [`DWIDTH-1:0] a3_data_in;
wire [`DWIDTH-1:0] a4_data_in;
wire [`DWIDTH-1:0] a5_data_in;
wire [`DWIDTH-1:0] a6_data_in;
wire [`DWIDTH-1:0] a7_data_in;
assign a0_data_in = a_data_in[`DWIDTH-1:0];
assign a1_data_in = a_data_in[2*`DWIDTH-1:1*`DWIDTH];
assign a2_data_in = a_data_in[3*`DWIDTH-1:2*`DWIDTH];
assign a3_data_in = a_data_in[4*`DWIDTH-1:3*`DWIDTH];
assign a4_data_in = a_data_in[5*`DWIDTH-1:4*`DWIDTH];
assign a5_data_in = a_data_in[6*`DWIDTH-1:5*`DWIDTH];
assign a6_data_in = a_data_in[7*`DWIDTH-1:6*`DWIDTH];
assign a7_data_in = a_data_in[8*`DWIDTH-1:7*`DWIDTH];

wire [`DWIDTH-1:0] b0_data_in;
wire [`DWIDTH-1:0] b1_data_in;
wire [`DWIDTH-1:0] b2_data_in;
wire [`DWIDTH-1:0] b3_data_in;
wire [`DWIDTH-1:0] b4_data_in;
wire [`DWIDTH-1:0] b5_data_in;
wire [`DWIDTH-1:0] b6_data_in;
wire [`DWIDTH-1:0] b7_data_in;
assign b0_data_in = b_data_in[`DWIDTH-1:0];
assign b1_data_in = b_data_in[2*`DWIDTH-1:1*`DWIDTH];
assign b2_data_in = b_data_in[3*`DWIDTH-1:2*`DWIDTH];
assign b3_data_in = b_data_in[4*`DWIDTH-1:3*`DWIDTH];
assign b4_data_in = b_data_in[5*`DWIDTH-1:4*`DWIDTH];
assign b5_data_in = b_data_in[6*`DWIDTH-1:5*`DWIDTH];
assign b6_data_in = b_data_in[7*`DWIDTH-1:6*`DWIDTH];
assign b7_data_in = b_data_in[8*`DWIDTH-1:7*`DWIDTH];

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

assign c0 = c_data_in[`DWIDTH-1:0];
assign c1 = c_data_in[2*`DWIDTH-1:1*`DWIDTH];
assign c2 = c_data_in[3*`DWIDTH-1:2*`DWIDTH];
assign c3 = c_data_in[4*`DWIDTH-1:3*`DWIDTH];
assign c4 = c_data_in[5*`DWIDTH-1:4*`DWIDTH];
assign c5 = c_data_in[6*`DWIDTH-1:5*`DWIDTH];
assign c6 = c_data_in[7*`DWIDTH-1:6*`DWIDTH];
assign c7 = c_data_in[8*`DWIDTH-1:7*`DWIDTH];

wire [`DWIDTH-1:0] matrixC0_0;
wire [`DWIDTH-1:0] matrixC0_1;
wire [`DWIDTH-1:0] matrixC0_2;
wire [`DWIDTH-1:0] matrixC0_3;
wire [`DWIDTH-1:0] matrixC0_4;
wire [`DWIDTH-1:0] matrixC0_5;
wire [`DWIDTH-1:0] matrixC0_6;
wire [`DWIDTH-1:0] matrixC0_7;
wire [`DWIDTH-1:0] matrixC1_0;
wire [`DWIDTH-1:0] matrixC1_1;
wire [`DWIDTH-1:0] matrixC1_2;
wire [`DWIDTH-1:0] matrixC1_3;
wire [`DWIDTH-1:0] matrixC1_4;
wire [`DWIDTH-1:0] matrixC1_5;
wire [`DWIDTH-1:0] matrixC1_6;
wire [`DWIDTH-1:0] matrixC1_7;
wire [`DWIDTH-1:0] matrixC2_0;
wire [`DWIDTH-1:0] matrixC2_1;
wire [`DWIDTH-1:0] matrixC2_2;
wire [`DWIDTH-1:0] matrixC2_3;
wire [`DWIDTH-1:0] matrixC2_4;
wire [`DWIDTH-1:0] matrixC2_5;
wire [`DWIDTH-1:0] matrixC2_6;
wire [`DWIDTH-1:0] matrixC2_7;
wire [`DWIDTH-1:0] matrixC3_0;
wire [`DWIDTH-1:0] matrixC3_1;
wire [`DWIDTH-1:0] matrixC3_2;
wire [`DWIDTH-1:0] matrixC3_3;
wire [`DWIDTH-1:0] matrixC3_4;
wire [`DWIDTH-1:0] matrixC3_5;
wire [`DWIDTH-1:0] matrixC3_6;
wire [`DWIDTH-1:0] matrixC3_7;
wire [`DWIDTH-1:0] matrixC4_0;
wire [`DWIDTH-1:0] matrixC4_1;
wire [`DWIDTH-1:0] matrixC4_2;
wire [`DWIDTH-1:0] matrixC4_3;
wire [`DWIDTH-1:0] matrixC4_4;
wire [`DWIDTH-1:0] matrixC4_5;
wire [`DWIDTH-1:0] matrixC4_6;
wire [`DWIDTH-1:0] matrixC4_7;
wire [`DWIDTH-1:0] matrixC5_0;
wire [`DWIDTH-1:0] matrixC5_1;
wire [`DWIDTH-1:0] matrixC5_2;
wire [`DWIDTH-1:0] matrixC5_3;
wire [`DWIDTH-1:0] matrixC5_4;
wire [`DWIDTH-1:0] matrixC5_5;
wire [`DWIDTH-1:0] matrixC5_6;
wire [`DWIDTH-1:0] matrixC5_7;
wire [`DWIDTH-1:0] matrixC6_0;
wire [`DWIDTH-1:0] matrixC6_1;
wire [`DWIDTH-1:0] matrixC6_2;
wire [`DWIDTH-1:0] matrixC6_3;
wire [`DWIDTH-1:0] matrixC6_4;
wire [`DWIDTH-1:0] matrixC6_5;
wire [`DWIDTH-1:0] matrixC6_6;
wire [`DWIDTH-1:0] matrixC6_7;
wire [`DWIDTH-1:0] matrixC7_0;
wire [`DWIDTH-1:0] matrixC7_1;
wire [`DWIDTH-1:0] matrixC7_2;
wire [`DWIDTH-1:0] matrixC7_3;
wire [`DWIDTH-1:0] matrixC7_4;
wire [`DWIDTH-1:0] matrixC7_5;
wire [`DWIDTH-1:0] matrixC7_6;
wire [`DWIDTH-1:0] matrixC7_7;

//////////////////////////////////////////////////////////////////////////
// Instantiations of the actual PEs
//////////////////////////////////////////////////////////////////////////
systolic_pe_matrix u_systolic_pe_matrix(
    .reset(reset),
    .clk(clk),
    .pe_reset(pe_reset),
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
    .b0(b0),
    .b1(b1),
    .b2(b2),
    .b3(b3),
    .b4(b4),
    .b5(b5),
    .b6(b6),
    .b7(b7),
    .c0(c0),
    .c1(c1),
    .c2(c2),
    .c3(c3),
    .c4(c4),
    .c5(c5),
    .c6(c6),
    .c7(c7),
    .matrixC0_0(matrixC0_0),
    .matrixC0_1(matrixC0_1),
    .matrixC0_2(matrixC0_2),
    .matrixC0_3(matrixC0_3),
    .matrixC0_4(matrixC0_4),
    .matrixC0_5(matrixC0_5),
    .matrixC0_6(matrixC0_6),
    .matrixC0_7(matrixC0_7),
    .matrixC1_0(matrixC1_0),
    .matrixC1_1(matrixC1_1),
    .matrixC1_2(matrixC1_2),
    .matrixC1_3(matrixC1_3),
    .matrixC1_4(matrixC1_4),
    .matrixC1_5(matrixC1_5),
    .matrixC1_6(matrixC1_6),
    .matrixC1_7(matrixC1_7),
    .matrixC2_0(matrixC2_0),
    .matrixC2_1(matrixC2_1),
    .matrixC2_2(matrixC2_2),
    .matrixC2_3(matrixC2_3),
    .matrixC2_4(matrixC2_4),
    .matrixC2_5(matrixC2_5),
    .matrixC2_6(matrixC2_6),
    .matrixC2_7(matrixC2_7),
    .matrixC3_0(matrixC3_0),
    .matrixC3_1(matrixC3_1),
    .matrixC3_2(matrixC3_2),
    .matrixC3_3(matrixC3_3),
    .matrixC3_4(matrixC3_4),
    .matrixC3_5(matrixC3_5),
    .matrixC3_6(matrixC3_6),
    .matrixC3_7(matrixC3_7),
    .matrixC4_0(matrixC4_0),
    .matrixC4_1(matrixC4_1),
    .matrixC4_2(matrixC4_2),
    .matrixC4_3(matrixC4_3),
    .matrixC4_4(matrixC4_4),
    .matrixC4_5(matrixC4_5),
    .matrixC4_6(matrixC4_6),
    .matrixC4_7(matrixC4_7),
    .matrixC5_0(matrixC5_0),
    .matrixC5_1(matrixC5_1),
    .matrixC5_2(matrixC5_2),
    .matrixC5_3(matrixC5_3),
    .matrixC5_4(matrixC5_4),
    .matrixC5_5(matrixC5_5),
    .matrixC5_6(matrixC5_6),
    .matrixC5_7(matrixC5_7),
    .matrixC6_0(matrixC6_0),
    .matrixC6_1(matrixC6_1),
    .matrixC6_2(matrixC6_2),
    .matrixC6_3(matrixC6_3),
    .matrixC6_4(matrixC6_4),
    .matrixC6_5(matrixC6_5),
    .matrixC6_6(matrixC6_6),
    .matrixC6_7(matrixC6_7),
    .matrixC7_0(matrixC7_0),
    .matrixC7_1(matrixC7_1),
    .matrixC7_2(matrixC7_2),
    .matrixC7_3(matrixC7_3),
    .matrixC7_4(matrixC7_4),
    .matrixC7_5(matrixC7_5),
    .matrixC7_6(matrixC7_6),
    .matrixC7_7(matrixC7_7),
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
    b0_data,
    b1_data_delayed_1,
    b2_data_delayed_2,
    b3_data_delayed_3,
    b4_data_delayed_4,
    b5_data_delayed_5,
    b6_data_delayed_6,
    b7_data_delayed_7,
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
input [15:0] clk_cnt;
output [`DWIDTH-1:0] a0_data;
output [`DWIDTH-1:0] a1_data_delayed_1;
output [`DWIDTH-1:0] a2_data_delayed_2;
output [`DWIDTH-1:0] a3_data_delayed_3;
output [`DWIDTH-1:0] a4_data_delayed_4;
output [`DWIDTH-1:0] a5_data_delayed_5;
output [`DWIDTH-1:0] a6_data_delayed_6;
output [`DWIDTH-1:0] a7_data_delayed_7;
output [`DWIDTH-1:0] b0_data;
output [`DWIDTH-1:0] b1_data_delayed_1;
output [`DWIDTH-1:0] b2_data_delayed_2;
output [`DWIDTH-1:0] b3_data_delayed_3;
output [`DWIDTH-1:0] b4_data_delayed_4;
output [`DWIDTH-1:0] b5_data_delayed_5;
output [`DWIDTH-1:0] b6_data_delayed_6;
output [`DWIDTH-1:0] b7_data_delayed_7;
input [`MASK_WIDTH-1:0] validity_mask_a_rows;
input [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows;
input [`MASK_WIDTH-1:0] validity_mask_b_cols;
input [31:0] num_matrices_A;
input [31:0] num_matrices_B;
input [15:0] a_loc;
input [15:0] b_loc;

wire [`DWIDTH-1:0] a0_data;
wire [`DWIDTH-1:0] a1_data;
wire [`DWIDTH-1:0] a2_data;
wire [`DWIDTH-1:0] a3_data;
wire [`DWIDTH-1:0] a4_data;
wire [`DWIDTH-1:0] a5_data;
wire [`DWIDTH-1:0] a6_data;
wire [`DWIDTH-1:0] a7_data;
wire [`DWIDTH-1:0] b0_data;
wire [`DWIDTH-1:0] b1_data;
wire [`DWIDTH-1:0] b2_data;
wire [`DWIDTH-1:0] b3_data;
wire [`DWIDTH-1:0] b4_data;
wire [`DWIDTH-1:0] b5_data;
wire [`DWIDTH-1:0] b6_data;
wire [`DWIDTH-1:0] b7_data;

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

reg [15:0] a_mem_access_counter;

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
        (validity_mask_a_cols_b_rows[7]==1'b0 && a_mem_access_counter==8)) ?
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
        (validity_mask_a_cols_b_rows[7]==1'b0 && b_mem_access_counter==8)) ?
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
    b_data_sel,
    a0,    a1,    a2,    a3,    a4,    a5,    a6,    a7,
    b0,    b1,    b2,    b3,    b4,    b5,    b6,    b7,
    c0,    c1,    c2,    c3,    c4,    c5,    c6,    c7,
    matrixC0_0,
    matrixC0_1,
    matrixC0_2,
    matrixC0_3,
    matrixC0_4,
    matrixC0_5,
    matrixC0_6,
    matrixC0_7,
    matrixC1_0,
    matrixC1_1,
    matrixC1_2,
    matrixC1_3,
    matrixC1_4,
    matrixC1_5,
    matrixC1_6,
    matrixC1_7,
    matrixC2_0,
    matrixC2_1,
    matrixC2_2,
    matrixC2_3,
    matrixC2_4,
    matrixC2_5,
    matrixC2_6,
    matrixC2_7,
    matrixC3_0,
    matrixC3_1,
    matrixC3_2,
    matrixC3_3,
    matrixC3_4,
    matrixC3_5,
    matrixC3_6,
    matrixC3_7,
    matrixC4_0,
    matrixC4_1,
    matrixC4_2,
    matrixC4_3,
    matrixC4_4,
    matrixC4_5,
    matrixC4_6,
    matrixC4_7,
    matrixC5_0,
    matrixC5_1,
    matrixC5_2,
    matrixC5_3,
    matrixC5_4,
    matrixC5_5,
    matrixC5_6,
    matrixC5_7,
    matrixC6_0,
    matrixC6_1,
    matrixC6_2,
    matrixC6_3,
    matrixC6_4,
    matrixC6_5,
    matrixC6_6,
    matrixC6_7,
    matrixC7_0,
    matrixC7_1,
    matrixC7_2,
    matrixC7_3,
    matrixC7_4,
    matrixC7_5,
    matrixC7_6,
    matrixC7_7,
    a_data_out,
    b_data_out,
    b_data_valid_ping,
    b_data_valid_pong
);

input clk;
input reset;
input pe_reset;
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
input [`DWIDTH-1:0] b0;
input [`DWIDTH-1:0] b1;
input [`DWIDTH-1:0] b2;
input [`DWIDTH-1:0] b3;
input [`DWIDTH-1:0] b4;
input [`DWIDTH-1:0] b5;
input [`DWIDTH-1:0] b6;
input [`DWIDTH-1:0] b7;
input [`DWIDTH-1:0] c0;
input [`DWIDTH-1:0] c1;
input [`DWIDTH-1:0] c2;
input [`DWIDTH-1:0] c3;
input [`DWIDTH-1:0] c4;
input [`DWIDTH-1:0] c5;
input [`DWIDTH-1:0] c6;
input [`DWIDTH-1:0] c7;
output [`DWIDTH-1:0] matrixC0_0;
output [`DWIDTH-1:0] matrixC0_1;
output [`DWIDTH-1:0] matrixC0_2;
output [`DWIDTH-1:0] matrixC0_3;
output [`DWIDTH-1:0] matrixC0_4;
output [`DWIDTH-1:0] matrixC0_5;
output [`DWIDTH-1:0] matrixC0_6;
output [`DWIDTH-1:0] matrixC0_7;
output [`DWIDTH-1:0] matrixC1_0;
output [`DWIDTH-1:0] matrixC1_1;
output [`DWIDTH-1:0] matrixC1_2;
output [`DWIDTH-1:0] matrixC1_3;
output [`DWIDTH-1:0] matrixC1_4;
output [`DWIDTH-1:0] matrixC1_5;
output [`DWIDTH-1:0] matrixC1_6;
output [`DWIDTH-1:0] matrixC1_7;
output [`DWIDTH-1:0] matrixC2_0;
output [`DWIDTH-1:0] matrixC2_1;
output [`DWIDTH-1:0] matrixC2_2;
output [`DWIDTH-1:0] matrixC2_3;
output [`DWIDTH-1:0] matrixC2_4;
output [`DWIDTH-1:0] matrixC2_5;
output [`DWIDTH-1:0] matrixC2_6;
output [`DWIDTH-1:0] matrixC2_7;
output [`DWIDTH-1:0] matrixC3_0;
output [`DWIDTH-1:0] matrixC3_1;
output [`DWIDTH-1:0] matrixC3_2;
output [`DWIDTH-1:0] matrixC3_3;
output [`DWIDTH-1:0] matrixC3_4;
output [`DWIDTH-1:0] matrixC3_5;
output [`DWIDTH-1:0] matrixC3_6;
output [`DWIDTH-1:0] matrixC3_7;
output [`DWIDTH-1:0] matrixC4_0;
output [`DWIDTH-1:0] matrixC4_1;
output [`DWIDTH-1:0] matrixC4_2;
output [`DWIDTH-1:0] matrixC4_3;
output [`DWIDTH-1:0] matrixC4_4;
output [`DWIDTH-1:0] matrixC4_5;
output [`DWIDTH-1:0] matrixC4_6;
output [`DWIDTH-1:0] matrixC4_7;
output [`DWIDTH-1:0] matrixC5_0;
output [`DWIDTH-1:0] matrixC5_1;
output [`DWIDTH-1:0] matrixC5_2;
output [`DWIDTH-1:0] matrixC5_3;
output [`DWIDTH-1:0] matrixC5_4;
output [`DWIDTH-1:0] matrixC5_5;
output [`DWIDTH-1:0] matrixC5_6;
output [`DWIDTH-1:0] matrixC5_7;
output [`DWIDTH-1:0] matrixC6_0;
output [`DWIDTH-1:0] matrixC6_1;
output [`DWIDTH-1:0] matrixC6_2;
output [`DWIDTH-1:0] matrixC6_3;
output [`DWIDTH-1:0] matrixC6_4;
output [`DWIDTH-1:0] matrixC6_5;
output [`DWIDTH-1:0] matrixC6_6;
output [`DWIDTH-1:0] matrixC6_7;
output [`DWIDTH-1:0] matrixC7_0;
output [`DWIDTH-1:0] matrixC7_1;
output [`DWIDTH-1:0] matrixC7_2;
output [`DWIDTH-1:0] matrixC7_3;
output [`DWIDTH-1:0] matrixC7_4;
output [`DWIDTH-1:0] matrixC7_5;
output [`DWIDTH-1:0] matrixC7_6;
output [`DWIDTH-1:0] matrixC7_7;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out;
  

wire [`DWIDTH-1:0] a0_0to0_1, a0_1to0_2, a0_2to0_3, a0_3to0_4, a0_4to0_5, a0_5to0_6, a0_6to0_7, a0_7to0_8;
wire [`DWIDTH-1:0] a1_0to1_1, a1_1to1_2, a1_2to1_3, a1_3to1_4, a1_4to1_5, a1_5to1_6, a1_6to1_7, a1_7to1_8;
wire [`DWIDTH-1:0] a2_0to2_1, a2_1to2_2, a2_2to2_3, a2_3to2_4, a2_4to2_5, a2_5to2_6, a2_6to2_7, a2_7to2_8;
wire [`DWIDTH-1:0] a3_0to3_1, a3_1to3_2, a3_2to3_3, a3_3to3_4, a3_4to3_5, a3_5to3_6, a3_6to3_7, a3_7to3_8;
wire [`DWIDTH-1:0] a4_0to4_1, a4_1to4_2, a4_2to4_3, a4_3to4_4, a4_4to4_5, a4_5to4_6, a4_6to4_7, a4_7to4_8;
wire [`DWIDTH-1:0] a5_0to5_1, a5_1to5_2, a5_2to5_3, a5_3to5_4, a5_4to5_5, a5_5to5_6, a5_6to5_7, a5_7to5_8;
wire [`DWIDTH-1:0] a6_0to6_1, a6_1to6_2, a6_2to6_3, a6_3to6_4, a6_4to6_5, a6_5to6_6, a6_6to6_7, a6_7to6_8;
wire [`DWIDTH-1:0] a7_0to7_1, a7_1to7_2, a7_2to7_3, a7_3to7_4, a7_4to7_5, a7_5to7_6, a7_6to7_7, a7_7to7_8;

wire [`DWIDTH-1:0] b0_0to1_0, b1_0to2_0, b2_0to3_0, b3_0to4_0, b4_0to5_0, b5_0to6_0, b6_0to7_0, b7_0to8_0;
wire [`DWIDTH-1:0] b0_1to1_1, b1_1to2_1, b2_1to3_1, b3_1to4_1, b4_1to5_1, b5_1to6_1, b6_1to7_1, b7_1to8_1;
wire [`DWIDTH-1:0] b0_2to1_2, b1_2to2_2, b2_2to3_2, b3_2to4_2, b4_2to5_2, b5_2to6_2, b6_2to7_2, b7_2to8_2;
wire [`DWIDTH-1:0] b0_3to1_3, b1_3to2_3, b2_3to3_3, b3_3to4_3, b4_3to5_3, b5_3to6_3, b6_3to7_3, b7_3to8_3;
wire [`DWIDTH-1:0] b0_4to1_4, b1_4to2_4, b2_4to3_4, b3_4to4_4, b4_4to5_4, b5_4to6_4, b6_4to7_4, b7_4to8_4;
wire [`DWIDTH-1:0] b0_5to1_5, b1_5to2_5, b2_5to3_5, b3_5to4_5, b4_5to5_5, b5_5to6_5, b6_5to7_5, b7_5to8_5;
wire [`DWIDTH-1:0] b0_6to1_6, b1_6to2_6, b2_6to3_6, b3_6to4_6, b4_6to5_6, b5_6to6_6, b6_6to7_6, b7_6to8_6;
wire [`DWIDTH-1:0] b0_7to1_7, b1_7to2_7, b2_7to3_7, b3_7to4_7, b4_7to5_7, b5_7to6_7, b6_7to7_7, b7_7to8_7;

wire [`DWIDTH-1:0] b0_0to1_0_ping, b1_0to2_0_ping, b2_0to3_0_ping, b3_0to4_0_ping, b4_0to5_0_ping, b5_0to6_0_ping, b6_0to7_0_ping, b7_0to8_0_ping;
wire [`DWIDTH-1:0] b0_1to1_1_ping, b1_1to2_1_ping, b2_1to3_1_ping, b3_1to4_1_ping, b4_1to5_1_ping, b5_1to6_1_ping, b6_1to7_1_ping, b7_1to8_1_ping;
wire [`DWIDTH-1:0] b0_2to1_2_ping, b1_2to2_2_ping, b2_2to3_2_ping, b3_2to4_2_ping, b4_2to5_2_ping, b5_2to6_2_ping, b6_2to7_2_ping, b7_2to8_2_ping;
wire [`DWIDTH-1:0] b0_3to1_3_ping, b1_3to2_3_ping, b2_3to3_3_ping, b3_3to4_3_ping, b4_3to5_3_ping, b5_3to6_3_ping, b6_3to7_3_ping, b7_3to8_3_ping;
wire [`DWIDTH-1:0] b0_4to1_4_ping, b1_4to2_4_ping, b2_4to3_4_ping, b3_4to4_4_ping, b4_4to5_4_ping, b5_4to6_4_ping, b6_4to7_4_ping, b7_4to8_4_ping;
wire [`DWIDTH-1:0] b0_5to1_5_ping, b1_5to2_5_ping, b2_5to3_5_ping, b3_5to4_5_ping, b4_5to5_5_ping, b5_5to6_5_ping, b6_5to7_5_ping, b7_5to8_5_ping;
wire [`DWIDTH-1:0] b0_6to1_6_ping, b1_6to2_6_ping, b2_6to3_6_ping, b3_6to4_6_ping, b4_6to5_6_ping, b5_6to6_6_ping, b6_6to7_6_ping, b7_6to8_6_ping;
wire [`DWIDTH-1:0] b0_7to1_7_ping, b1_7to2_7_ping, b2_7to3_7_ping, b3_7to4_7_ping, b4_7to5_7_ping, b5_7to6_7_ping, b6_7to7_7_ping, b7_7to8_7_ping;

wire [`DWIDTH-1:0] b0_0to1_0_pong, b1_0to2_0_pong, b2_0to3_0_pong, b3_0to4_0_pong, b4_0to5_0_pong, b5_0to6_0_pong, b6_0to7_0_pong, b7_0to8_0_pong;
wire [`DWIDTH-1:0] b0_1to1_1_pong, b1_1to2_1_pong, b2_1to3_1_pong, b3_1to4_1_pong, b4_1to5_1_pong, b5_1to6_1_pong, b6_1to7_1_pong, b7_1to8_1_pong;
wire [`DWIDTH-1:0] b0_2to1_2_pong, b1_2to2_2_pong, b2_2to3_2_pong, b3_2to4_2_pong, b4_2to5_2_pong, b5_2to6_2_pong, b6_2to7_2_pong, b7_2to8_2_pong;
wire [`DWIDTH-1:0] b0_3to1_3_pong, b1_3to2_3_pong, b2_3to3_3_pong, b3_3to4_3_pong, b4_3to5_3_pong, b5_3to6_3_pong, b6_3to7_3_pong, b7_3to8_3_pong;
wire [`DWIDTH-1:0] b0_4to1_4_pong, b1_4to2_4_pong, b2_4to3_4_pong, b3_4to4_4_pong, b4_4to5_4_pong, b5_4to6_4_pong, b6_4to7_4_pong, b7_4to8_4_pong;
wire [`DWIDTH-1:0] b0_5to1_5_pong, b1_5to2_5_pong, b2_5to3_5_pong, b3_5to4_5_pong, b4_5to5_5_pong, b5_5to6_5_pong, b6_5to7_5_pong, b7_5to8_5_pong;
wire [`DWIDTH-1:0] b0_6to1_6_pong, b1_6to2_6_pong, b2_6to3_6_pong, b3_6to4_6_pong, b4_6to5_6_pong, b5_6to6_6_pong, b6_6to7_6_pong, b7_6to8_6_pong;
wire [`DWIDTH-1:0] b0_7to1_7_pong, b1_7to2_7_pong, b2_7to3_7_pong, b3_7to4_7_pong, b4_7to5_7_pong, b5_7to6_7_pong, b6_7to7_7_pong, b7_7to8_7_pong;

reg [`DWIDTH-1:0] b0_data, b1_data, b2_data, b3_data, b4_data, b5_data, b6_data, b7_data; 

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
wire b_data_valid_pong_delay1_0;
wire b_data_valid_pong_delay2_0;
wire b_data_valid_pong_delay3_0;
wire b_data_valid_pong_delay4_0;
wire b_data_valid_pong_delay5_0;
wire b_data_valid_pong_delay6_0;
wire b_data_valid_pong_delay7_0;
wire b_data_valid_pong_delay1_1;
wire b_data_valid_pong_delay2_1;
wire b_data_valid_pong_delay3_1;
wire b_data_valid_pong_delay4_1;
wire b_data_valid_pong_delay5_1;
wire b_data_valid_pong_delay6_1;
wire b_data_valid_pong_delay7_1;
wire b_data_valid_pong_delay1_2;
wire b_data_valid_pong_delay2_2;
wire b_data_valid_pong_delay3_2;
wire b_data_valid_pong_delay4_2;
wire b_data_valid_pong_delay5_2;
wire b_data_valid_pong_delay6_2;
wire b_data_valid_pong_delay7_2;
wire b_data_valid_pong_delay1_3;
wire b_data_valid_pong_delay2_3;
wire b_data_valid_pong_delay3_3;
wire b_data_valid_pong_delay4_3;
wire b_data_valid_pong_delay5_3;
wire b_data_valid_pong_delay6_3;
wire b_data_valid_pong_delay7_3;
wire b_data_valid_pong_delay1_4;
wire b_data_valid_pong_delay2_4;
wire b_data_valid_pong_delay3_4;
wire b_data_valid_pong_delay4_4;
wire b_data_valid_pong_delay5_4;
wire b_data_valid_pong_delay6_4;
wire b_data_valid_pong_delay7_4;
wire b_data_valid_pong_delay1_5;
wire b_data_valid_pong_delay2_5;
wire b_data_valid_pong_delay3_5;
wire b_data_valid_pong_delay4_5;
wire b_data_valid_pong_delay5_5;
wire b_data_valid_pong_delay6_5;
wire b_data_valid_pong_delay7_5;
wire b_data_valid_pong_delay1_6;
wire b_data_valid_pong_delay2_6;
wire b_data_valid_pong_delay3_6;
wire b_data_valid_pong_delay4_6;
wire b_data_valid_pong_delay5_6;
wire b_data_valid_pong_delay6_6;
wire b_data_valid_pong_delay7_6;
wire b_data_valid_pong_delay1_7;
wire b_data_valid_pong_delay2_7;
wire b_data_valid_pong_delay3_7;
wire b_data_valid_pong_delay4_7;
wire b_data_valid_pong_delay5_7;
wire b_data_valid_pong_delay6_7;
wire b_data_valid_pong_delay7_7;
  
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
end

assign b_data_valid_pong_delay1_0 = b_data_valid_pong & b_data_valid_pong_delay01;
assign b_data_valid_pong_delay2_0 = b_data_valid_pong & b_data_valid_pong_delay02;
assign b_data_valid_pong_delay3_0 = b_data_valid_pong & b_data_valid_pong_delay03;
assign b_data_valid_pong_delay4_0 = b_data_valid_pong & b_data_valid_pong_delay04;
assign b_data_valid_pong_delay5_0 = b_data_valid_pong & b_data_valid_pong_delay05;
assign b_data_valid_pong_delay6_0 = b_data_valid_pong & b_data_valid_pong_delay06;
assign b_data_valid_pong_delay7_0 = b_data_valid_pong & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay1_1 = b_data_valid_pong_delay01 & b_data_valid_pong_delay02;
assign b_data_valid_pong_delay2_1 = b_data_valid_pong_delay01 & b_data_valid_pong_delay03;
assign b_data_valid_pong_delay3_1 = b_data_valid_pong_delay01 & b_data_valid_pong_delay04;
assign b_data_valid_pong_delay4_1 = b_data_valid_pong_delay01 & b_data_valid_pong_delay05;
assign b_data_valid_pong_delay5_1 = b_data_valid_pong_delay01 & b_data_valid_pong_delay06;
assign b_data_valid_pong_delay6_1 = b_data_valid_pong_delay01 & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay7_1 = b_data_valid_pong_delay01 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay1_2 = b_data_valid_pong_delay02 & b_data_valid_pong_delay03;
assign b_data_valid_pong_delay2_2 = b_data_valid_pong_delay02 & b_data_valid_pong_delay04;
assign b_data_valid_pong_delay3_2 = b_data_valid_pong_delay02 & b_data_valid_pong_delay05;
assign b_data_valid_pong_delay4_2 = b_data_valid_pong_delay02 & b_data_valid_pong_delay06;
assign b_data_valid_pong_delay5_2 = b_data_valid_pong_delay02 & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay6_2 = b_data_valid_pong_delay02 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay7_2 = b_data_valid_pong_delay02 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay1_3 = b_data_valid_pong_delay03 & b_data_valid_pong_delay04;
assign b_data_valid_pong_delay2_3 = b_data_valid_pong_delay03 & b_data_valid_pong_delay05;
assign b_data_valid_pong_delay3_3 = b_data_valid_pong_delay03 & b_data_valid_pong_delay06;
assign b_data_valid_pong_delay4_3 = b_data_valid_pong_delay03 & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay5_3 = b_data_valid_pong_delay03 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay6_3 = b_data_valid_pong_delay03 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay7_3 = b_data_valid_pong_delay03 & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay1_4 = b_data_valid_pong_delay04 & b_data_valid_pong_delay05;
assign b_data_valid_pong_delay2_4 = b_data_valid_pong_delay04 & b_data_valid_pong_delay06;
assign b_data_valid_pong_delay3_4 = b_data_valid_pong_delay04 & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay4_4 = b_data_valid_pong_delay04 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay5_4 = b_data_valid_pong_delay04 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay6_4 = b_data_valid_pong_delay04 & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay7_4 = b_data_valid_pong_delay04 & b_data_valid_pong_delay011;
assign b_data_valid_pong_delay1_5 = b_data_valid_pong_delay05 & b_data_valid_pong_delay06;
assign b_data_valid_pong_delay2_5 = b_data_valid_pong_delay05 & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay3_5 = b_data_valid_pong_delay05 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay4_5 = b_data_valid_pong_delay05 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay5_5 = b_data_valid_pong_delay05 & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay6_5 = b_data_valid_pong_delay05 & b_data_valid_pong_delay011;
assign b_data_valid_pong_delay7_5 = b_data_valid_pong_delay05 & b_data_valid_pong_delay012;
assign b_data_valid_pong_delay1_6 = b_data_valid_pong_delay06 & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay2_6 = b_data_valid_pong_delay06 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay3_6 = b_data_valid_pong_delay06 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay4_6 = b_data_valid_pong_delay06 & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay5_6 = b_data_valid_pong_delay06 & b_data_valid_pong_delay011;
assign b_data_valid_pong_delay6_6 = b_data_valid_pong_delay06 & b_data_valid_pong_delay012;
assign b_data_valid_pong_delay7_6 = b_data_valid_pong_delay06 & b_data_valid_pong_delay013;
assign b_data_valid_pong_delay1_7 = b_data_valid_pong_delay07 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay2_7 = b_data_valid_pong_delay07 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay3_7 = b_data_valid_pong_delay07 & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay4_7 = b_data_valid_pong_delay07 & b_data_valid_pong_delay011;
assign b_data_valid_pong_delay5_7 = b_data_valid_pong_delay07 & b_data_valid_pong_delay012;
assign b_data_valid_pong_delay6_7 = b_data_valid_pong_delay07 & b_data_valid_pong_delay013;
assign b_data_valid_pong_delay7_7 = b_data_valid_pong_delay07 & b_data_valid_pong_delay014;

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
wire b_data_valid_ping_delay1_0;
wire b_data_valid_ping_delay2_0;
wire b_data_valid_ping_delay3_0;
wire b_data_valid_ping_delay4_0;
wire b_data_valid_ping_delay5_0;
wire b_data_valid_ping_delay6_0;
wire b_data_valid_ping_delay7_0;
wire b_data_valid_ping_delay1_1;
wire b_data_valid_ping_delay2_1;
wire b_data_valid_ping_delay3_1;
wire b_data_valid_ping_delay4_1;
wire b_data_valid_ping_delay5_1;
wire b_data_valid_ping_delay6_1;
wire b_data_valid_ping_delay7_1;
wire b_data_valid_ping_delay1_2;
wire b_data_valid_ping_delay2_2;
wire b_data_valid_ping_delay3_2;
wire b_data_valid_ping_delay4_2;
wire b_data_valid_ping_delay5_2;
wire b_data_valid_ping_delay6_2;
wire b_data_valid_ping_delay7_2;
wire b_data_valid_ping_delay1_3;
wire b_data_valid_ping_delay2_3;
wire b_data_valid_ping_delay3_3;
wire b_data_valid_ping_delay4_3;
wire b_data_valid_ping_delay5_3;
wire b_data_valid_ping_delay6_3;
wire b_data_valid_ping_delay7_3;
wire b_data_valid_ping_delay1_4;
wire b_data_valid_ping_delay2_4;
wire b_data_valid_ping_delay3_4;
wire b_data_valid_ping_delay4_4;
wire b_data_valid_ping_delay5_4;
wire b_data_valid_ping_delay6_4;
wire b_data_valid_ping_delay7_4;
wire b_data_valid_ping_delay1_5;
wire b_data_valid_ping_delay2_5;
wire b_data_valid_ping_delay3_5;
wire b_data_valid_ping_delay4_5;
wire b_data_valid_ping_delay5_5;
wire b_data_valid_ping_delay6_5;
wire b_data_valid_ping_delay7_5;
wire b_data_valid_ping_delay1_6;
wire b_data_valid_ping_delay2_6;
wire b_data_valid_ping_delay3_6;
wire b_data_valid_ping_delay4_6;
wire b_data_valid_ping_delay5_6;
wire b_data_valid_ping_delay6_6;
wire b_data_valid_ping_delay7_6;
wire b_data_valid_ping_delay1_7;
wire b_data_valid_ping_delay2_7;
wire b_data_valid_ping_delay3_7;
wire b_data_valid_ping_delay4_7;
wire b_data_valid_ping_delay5_7;
wire b_data_valid_ping_delay6_7;
wire b_data_valid_ping_delay7_7;
  
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
end

assign b_data_valid_ping_delay1_0 = b_data_valid_ping & b_data_valid_ping_delay01;
assign b_data_valid_ping_delay2_0 = b_data_valid_ping & b_data_valid_ping_delay02;
assign b_data_valid_ping_delay3_0 = b_data_valid_ping & b_data_valid_ping_delay03;
assign b_data_valid_ping_delay4_0 = b_data_valid_ping & b_data_valid_ping_delay04;
assign b_data_valid_ping_delay5_0 = b_data_valid_ping & b_data_valid_ping_delay05;
assign b_data_valid_ping_delay6_0 = b_data_valid_ping & b_data_valid_ping_delay06;
assign b_data_valid_ping_delay7_0 = b_data_valid_ping & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay1_1 = b_data_valid_ping_delay01 & b_data_valid_ping_delay02;
assign b_data_valid_ping_delay2_1 = b_data_valid_ping_delay01 & b_data_valid_ping_delay03;
assign b_data_valid_ping_delay3_1 = b_data_valid_ping_delay01 & b_data_valid_ping_delay04;
assign b_data_valid_ping_delay4_1 = b_data_valid_ping_delay01 & b_data_valid_ping_delay05;
assign b_data_valid_ping_delay5_1 = b_data_valid_ping_delay01 & b_data_valid_ping_delay06;
assign b_data_valid_ping_delay6_1 = b_data_valid_ping_delay01 & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay7_1 = b_data_valid_ping_delay01 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay1_2 = b_data_valid_ping_delay02 & b_data_valid_ping_delay03;
assign b_data_valid_ping_delay2_2 = b_data_valid_ping_delay02 & b_data_valid_ping_delay04;
assign b_data_valid_ping_delay3_2 = b_data_valid_ping_delay02 & b_data_valid_ping_delay05;
assign b_data_valid_ping_delay4_2 = b_data_valid_ping_delay02 & b_data_valid_ping_delay06;
assign b_data_valid_ping_delay5_2 = b_data_valid_ping_delay02 & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay6_2 = b_data_valid_ping_delay02 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay7_2 = b_data_valid_ping_delay02 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay1_3 = b_data_valid_ping_delay03 & b_data_valid_ping_delay04;
assign b_data_valid_ping_delay2_3 = b_data_valid_ping_delay03 & b_data_valid_ping_delay05;
assign b_data_valid_ping_delay3_3 = b_data_valid_ping_delay03 & b_data_valid_ping_delay06;
assign b_data_valid_ping_delay4_3 = b_data_valid_ping_delay03 & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay5_3 = b_data_valid_ping_delay03 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay6_3 = b_data_valid_ping_delay03 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay7_3 = b_data_valid_ping_delay03 & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay1_4 = b_data_valid_ping_delay04 & b_data_valid_ping_delay05;
assign b_data_valid_ping_delay2_4 = b_data_valid_ping_delay04 & b_data_valid_ping_delay06;
assign b_data_valid_ping_delay3_4 = b_data_valid_ping_delay04 & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay4_4 = b_data_valid_ping_delay04 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay5_4 = b_data_valid_ping_delay04 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay6_4 = b_data_valid_ping_delay04 & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay7_4 = b_data_valid_ping_delay04 & b_data_valid_ping_delay011;
assign b_data_valid_ping_delay1_5 = b_data_valid_ping_delay05 & b_data_valid_ping_delay06;
assign b_data_valid_ping_delay2_5 = b_data_valid_ping_delay05 & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay3_5 = b_data_valid_ping_delay05 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay4_5 = b_data_valid_ping_delay05 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay5_5 = b_data_valid_ping_delay05 & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay6_5 = b_data_valid_ping_delay05 & b_data_valid_ping_delay011;
assign b_data_valid_ping_delay7_5 = b_data_valid_ping_delay05 & b_data_valid_ping_delay012;
assign b_data_valid_ping_delay1_6 = b_data_valid_ping_delay06 & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay2_6 = b_data_valid_ping_delay06 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay3_6 = b_data_valid_ping_delay06 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay4_6 = b_data_valid_ping_delay06 & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay5_6 = b_data_valid_ping_delay06 & b_data_valid_ping_delay011;
assign b_data_valid_ping_delay6_6 = b_data_valid_ping_delay06 & b_data_valid_ping_delay012;
assign b_data_valid_ping_delay7_6 = b_data_valid_ping_delay06 & b_data_valid_ping_delay013;
assign b_data_valid_ping_delay1_7 = b_data_valid_ping_delay07 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay2_7 = b_data_valid_ping_delay07 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay3_7 = b_data_valid_ping_delay07 & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay4_7 = b_data_valid_ping_delay07 & b_data_valid_ping_delay011;
assign b_data_valid_ping_delay5_7 = b_data_valid_ping_delay07 & b_data_valid_ping_delay012;
assign b_data_valid_ping_delay6_7 = b_data_valid_ping_delay07 & b_data_valid_ping_delay013;
assign b_data_valid_ping_delay7_7 = b_data_valid_ping_delay07 & b_data_valid_ping_delay014;

processing_element pe0_0(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel),        .in_a(a0),      .in_b(b0),      .in_c(c0),        .out_a(a0_0to0_1), .out_b(b0_0to1_0), .out_b0(b0_0to1_0_ping), .out_b1(b0_0to1_0_pong), .out_c(matrixC0_0), .b_data_valid_ping(b_data_valid_ping),         .b_data_valid_pong(b_data_valid_pong        ));
processing_element pe0_1(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay1), .in_a(a0_0to0_1), .in_b(b1),      .in_c(c1),        .out_a(a0_1to0_2), .out_b(b0_1to1_1), .out_b0(b0_1to1_1_ping), .out_b1(b0_1to1_1_pong), .out_c(matrixC0_1), .b_data_valid_ping(b_data_valid_ping_delay0_1), .b_data_valid_pong(b_data_valid_pong_delay0_1));
processing_element pe0_2(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay2), .in_a(a0_1to0_2), .in_b(b2),      .in_c(c2),        .out_a(a0_2to0_3), .out_b(b0_2to1_2), .out_b0(b0_2to1_2_ping), .out_b1(b0_2to1_2_pong), .out_c(matrixC0_2), .b_data_valid_ping(b_data_valid_ping_delay0_2), .b_data_valid_pong(b_data_valid_pong_delay0_2));
processing_element pe0_3(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay3), .in_a(a0_2to0_3), .in_b(b3),      .in_c(c3),        .out_a(a0_3to0_4), .out_b(b0_3to1_3), .out_b0(b0_3to1_3_ping), .out_b1(b0_3to1_3_pong), .out_c(matrixC0_3), .b_data_valid_ping(b_data_valid_ping_delay0_3), .b_data_valid_pong(b_data_valid_pong_delay0_3));
processing_element pe0_4(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay4), .in_a(a0_3to0_4), .in_b(b4),      .in_c(c4),        .out_a(a0_4to0_5), .out_b(b0_4to1_4), .out_b0(b0_4to1_4_ping), .out_b1(b0_4to1_4_pong), .out_c(matrixC0_4), .b_data_valid_ping(b_data_valid_ping_delay0_4), .b_data_valid_pong(b_data_valid_pong_delay0_4));
processing_element pe0_5(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay5), .in_a(a0_4to0_5), .in_b(b5),      .in_c(c5),        .out_a(a0_5to0_6), .out_b(b0_5to1_5), .out_b0(b0_5to1_5_ping), .out_b1(b0_5to1_5_pong), .out_c(matrixC0_5), .b_data_valid_ping(b_data_valid_ping_delay0_5), .b_data_valid_pong(b_data_valid_pong_delay0_5));
processing_element pe0_6(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a0_5to0_6), .in_b(b6),      .in_c(c6),        .out_a(a0_6to0_7), .out_b(b0_6to1_6), .out_b0(b0_6to1_6_ping), .out_b1(b0_6to1_6_pong), .out_c(matrixC0_6), .b_data_valid_ping(b_data_valid_ping_delay0_6), .b_data_valid_pong(b_data_valid_pong_delay0_6));
processing_element pe0_7(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a0_6to0_7), .in_b(b7),      .in_c(c7),        .out_a(a0_7to0_8), .out_b(b0_7to1_7), .out_b0(b0_7to1_7_ping), .out_b1(b0_7to1_7_pong), .out_c(matrixC0_7), .b_data_valid_ping(b_data_valid_ping_delay0_7), .b_data_valid_pong(b_data_valid_pong_delay0_7));

processing_element pe1_0(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay1), .in_a(a1),      .in_b(b0_0to1_0), .in_c(matrixC0_0), .out_a(a1_0to1_1), .out_b(b1_0to2_0), .out_b0(b1_0to2_0_ping), .out_b1(b1_0to2_0_pong), .out_c(matrixC1_0), .b_data_valid_ping(b_data_valid_ping_delay1_0), .b_data_valid_pong(b_data_valid_pong_delay1_0));
processing_element pe1_1(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay2), .in_a(a1_0to1_1), .in_b(b0_1to1_1), .in_c(matrixC0_1), .out_a(a1_1to1_2), .out_b(b1_1to2_1), .out_b0(b1_1to2_1_ping), .out_b1(b1_1to2_1_pong), .out_c(matrixC1_1), .b_data_valid_ping(b_data_valid_ping_delay1_1), .b_data_valid_pong(b_data_valid_pong_delay1_1));
processing_element pe1_2(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay3), .in_a(a1_1to1_2), .in_b(b0_2to1_2), .in_c(matrixC0_2), .out_a(a1_2to1_3), .out_b(b1_2to2_2), .out_b0(b1_2to2_2_ping), .out_b1(b1_2to2_2_pong), .out_c(matrixC1_2), .b_data_valid_ping(b_data_valid_ping_delay1_2), .b_data_valid_pong(b_data_valid_pong_delay1_2));
processing_element pe1_3(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay4), .in_a(a1_2to1_3), .in_b(b0_3to1_3), .in_c(matrixC0_3), .out_a(a1_3to1_4), .out_b(b1_3to2_3), .out_b0(b1_3to2_3_ping), .out_b1(b1_3to2_3_pong), .out_c(matrixC1_3), .b_data_valid_ping(b_data_valid_ping_delay1_3), .b_data_valid_pong(b_data_valid_pong_delay1_3));
processing_element pe1_4(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay5), .in_a(a1_3to1_4), .in_b(b0_4to1_4), .in_c(matrixC0_4), .out_a(a1_4to1_5), .out_b(b1_4to2_4), .out_b0(b1_4to2_4_ping), .out_b1(b1_4to2_4_pong), .out_c(matrixC1_4), .b_data_valid_ping(b_data_valid_ping_delay1_4), .b_data_valid_pong(b_data_valid_pong_delay1_4));
processing_element pe1_5(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a1_4to1_5), .in_b(b0_5to1_5), .in_c(matrixC0_5), .out_a(a1_5to1_6), .out_b(b1_5to2_5), .out_b0(b1_5to2_5_ping), .out_b1(b1_5to2_5_pong), .out_c(matrixC1_5), .b_data_valid_ping(b_data_valid_ping_delay1_5), .b_data_valid_pong(b_data_valid_pong_delay1_5));
processing_element pe1_6(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a1_5to1_6), .in_b(b0_6to1_6), .in_c(matrixC0_6), .out_a(a1_6to1_7), .out_b(b1_6to2_6), .out_b0(b1_6to2_6_ping), .out_b1(b1_6to2_6_pong), .out_c(matrixC1_6), .b_data_valid_ping(b_data_valid_ping_delay1_6), .b_data_valid_pong(b_data_valid_pong_delay1_6));
processing_element pe1_7(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a1_6to1_7), .in_b(b0_7to1_7), .in_c(matrixC0_7), .out_a(a1_7to1_8), .out_b(b1_7to2_7), .out_b0(b1_7to2_7_ping), .out_b1(b1_7to2_7_pong), .out_c(matrixC1_7), .b_data_valid_ping(b_data_valid_ping_delay1_7), .b_data_valid_pong(b_data_valid_pong_delay1_7));

processing_element pe2_0(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay2), .in_a(a2),      .in_b(b1_0to2_0), .in_c(matrixC1_0), .out_a(a2_0to2_1), .out_b(b2_0to3_0), .out_b0(b2_0to3_0_ping), .out_b1(b2_0to3_0_pong), .out_c(matrixC2_0), .b_data_valid_ping(b_data_valid_ping_delay2_0), .b_data_valid_pong(b_data_valid_pong_delay2_0));
processing_element pe2_1(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay3), .in_a(a2_0to2_1), .in_b(b1_1to2_1), .in_c(matrixC1_1), .out_a(a2_1to2_2), .out_b(b2_1to3_1), .out_b0(b2_1to3_1_ping), .out_b1(b2_1to3_1_pong), .out_c(matrixC2_1), .b_data_valid_ping(b_data_valid_ping_delay2_1), .b_data_valid_pong(b_data_valid_pong_delay2_1));
processing_element pe2_2(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay4), .in_a(a2_1to2_2), .in_b(b1_2to2_2), .in_c(matrixC1_2), .out_a(a2_2to2_3), .out_b(b2_2to3_2), .out_b0(b2_2to3_2_ping), .out_b1(b2_2to3_2_pong), .out_c(matrixC2_2), .b_data_valid_ping(b_data_valid_ping_delay2_2), .b_data_valid_pong(b_data_valid_pong_delay2_2));
processing_element pe2_3(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay5), .in_a(a2_2to2_3), .in_b(b1_3to2_3), .in_c(matrixC1_3), .out_a(a2_3to2_4), .out_b(b2_3to3_3), .out_b0(b2_3to3_3_ping), .out_b1(b2_3to3_3_pong), .out_c(matrixC2_3), .b_data_valid_ping(b_data_valid_ping_delay2_3), .b_data_valid_pong(b_data_valid_pong_delay2_3));
processing_element pe2_4(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a2_3to2_4), .in_b(b1_4to2_4), .in_c(matrixC1_4), .out_a(a2_4to2_5), .out_b(b2_4to3_4), .out_b0(b2_4to3_4_ping), .out_b1(b2_4to3_4_pong), .out_c(matrixC2_4), .b_data_valid_ping(b_data_valid_ping_delay2_4), .b_data_valid_pong(b_data_valid_pong_delay2_4));
processing_element pe2_5(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a2_4to2_5), .in_b(b1_5to2_5), .in_c(matrixC1_5), .out_a(a2_5to2_6), .out_b(b2_5to3_5), .out_b0(b2_5to3_5_ping), .out_b1(b2_5to3_5_pong), .out_c(matrixC2_5), .b_data_valid_ping(b_data_valid_ping_delay2_5), .b_data_valid_pong(b_data_valid_pong_delay2_5));
processing_element pe2_6(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a2_5to2_6), .in_b(b1_6to2_6), .in_c(matrixC1_6), .out_a(a2_6to2_7), .out_b(b2_6to3_6), .out_b0(b2_6to3_6_ping), .out_b1(b2_6to3_6_pong), .out_c(matrixC2_6), .b_data_valid_ping(b_data_valid_ping_delay2_6), .b_data_valid_pong(b_data_valid_pong_delay2_6));
processing_element pe2_7(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a2_6to2_7), .in_b(b1_7to2_7), .in_c(matrixC1_7), .out_a(a2_7to2_8), .out_b(b2_7to3_7), .out_b0(b2_7to3_7_ping), .out_b1(b2_7to3_7_pong), .out_c(matrixC2_7), .b_data_valid_ping(b_data_valid_ping_delay2_7), .b_data_valid_pong(b_data_valid_pong_delay2_7));

processing_element pe3_0(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay3), .in_a(a3),      .in_b(b2_0to3_0), .in_c(matrixC2_0), .out_a(a3_0to3_1), .out_b(b3_0to4_0), .out_b0(b3_0to4_0_ping), .out_b1(b3_0to4_0_pong), .out_c(matrixC3_0), .b_data_valid_ping(b_data_valid_ping_delay3_0), .b_data_valid_pong(b_data_valid_pong_delay3_0));
processing_element pe3_1(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay4), .in_a(a3_0to3_1), .in_b(b2_1to3_1), .in_c(matrixC2_1), .out_a(a3_1to3_2), .out_b(b3_1to4_1), .out_b0(b3_1to4_1_ping), .out_b1(b3_1to4_1_pong), .out_c(matrixC3_1), .b_data_valid_ping(b_data_valid_ping_delay3_1), .b_data_valid_pong(b_data_valid_pong_delay3_1));
processing_element pe3_2(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay5), .in_a(a3_1to3_2), .in_b(b2_2to3_2), .in_c(matrixC2_2), .out_a(a3_2to3_3), .out_b(b3_2to4_2), .out_b0(b3_2to4_2_ping), .out_b1(b3_2to4_2_pong), .out_c(matrixC3_2), .b_data_valid_ping(b_data_valid_ping_delay3_2), .b_data_valid_pong(b_data_valid_pong_delay3_2));
processing_element pe3_3(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a3_2to3_3), .in_b(b2_3to3_3), .in_c(matrixC2_3), .out_a(a3_3to3_4), .out_b(b3_3to4_3), .out_b0(b3_3to4_3_ping), .out_b1(b3_3to4_3_pong), .out_c(matrixC3_3), .b_data_valid_ping(b_data_valid_ping_delay3_3), .b_data_valid_pong(b_data_valid_pong_delay3_3));
processing_element pe3_4(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a3_3to3_4), .in_b(b2_4to3_4), .in_c(matrixC2_4), .out_a(a3_4to3_5), .out_b(b3_4to4_4), .out_b0(b3_4to4_4_ping), .out_b1(b3_4to4_4_pong), .out_c(matrixC3_4), .b_data_valid_ping(b_data_valid_ping_delay3_4), .b_data_valid_pong(b_data_valid_pong_delay3_4));
processing_element pe3_5(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a3_4to3_5), .in_b(b2_5to3_5), .in_c(matrixC2_5), .out_a(a3_5to3_6), .out_b(b3_5to4_5), .out_b0(b3_5to4_5_ping), .out_b1(b3_5to4_5_pong), .out_c(matrixC3_5), .b_data_valid_ping(b_data_valid_ping_delay3_5), .b_data_valid_pong(b_data_valid_pong_delay3_5));
processing_element pe3_6(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a3_5to3_6), .in_b(b2_6to3_6), .in_c(matrixC2_6), .out_a(a3_6to3_7), .out_b(b3_6to4_6), .out_b0(b3_6to4_6_ping), .out_b1(b3_6to4_6_pong), .out_c(matrixC3_6), .b_data_valid_ping(b_data_valid_ping_delay3_6), .b_data_valid_pong(b_data_valid_pong_delay3_6));
processing_element pe3_7(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a3_6to3_7), .in_b(b2_7to3_7), .in_c(matrixC2_7), .out_a(a3_7to3_8), .out_b(b3_7to4_7), .out_b0(b3_7to4_7_ping), .out_b1(b3_7to4_7_pong), .out_c(matrixC3_7), .b_data_valid_ping(b_data_valid_ping_delay3_7), .b_data_valid_pong(b_data_valid_pong_delay3_7));

processing_element pe4_0(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay4), .in_a(a4),      .in_b(b3_0to4_0), .in_c(matrixC3_0), .out_a(a4_0to4_1), .out_b(b4_0to5_0), .out_b0(b4_0to5_0_ping), .out_b1(b4_0to5_0_pong), .out_c(matrixC4_0), .b_data_valid_ping(b_data_valid_ping_delay4_0), .b_data_valid_pong(b_data_valid_pong_delay4_0));
processing_element pe4_1(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay5), .in_a(a4_0to4_1), .in_b(b3_1to4_1), .in_c(matrixC3_1), .out_a(a4_1to4_2), .out_b(b4_1to5_1), .out_b0(b4_1to5_1_ping), .out_b1(b4_1to5_1_pong), .out_c(matrixC4_1), .b_data_valid_ping(b_data_valid_ping_delay4_1), .b_data_valid_pong(b_data_valid_pong_delay4_1));
processing_element pe4_2(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a4_1to4_2), .in_b(b3_2to4_2), .in_c(matrixC3_2), .out_a(a4_2to4_3), .out_b(b4_2to5_2), .out_b0(b4_2to5_2_ping), .out_b1(b4_2to5_2_pong), .out_c(matrixC4_2), .b_data_valid_ping(b_data_valid_ping_delay4_2), .b_data_valid_pong(b_data_valid_pong_delay4_2));
processing_element pe4_3(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a4_2to4_3), .in_b(b3_3to4_3), .in_c(matrixC3_3), .out_a(a4_3to4_4), .out_b(b4_3to5_3), .out_b0(b4_3to5_3_ping), .out_b1(b4_3to5_3_pong), .out_c(matrixC4_3), .b_data_valid_ping(b_data_valid_ping_delay4_3), .b_data_valid_pong(b_data_valid_pong_delay4_3));
processing_element pe4_4(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a4_3to4_4), .in_b(b3_4to4_4), .in_c(matrixC3_4), .out_a(a4_4to4_5), .out_b(b4_4to5_4), .out_b0(b4_4to5_4_ping), .out_b1(b4_4to5_4_pong), .out_c(matrixC4_4), .b_data_valid_ping(b_data_valid_ping_delay4_4), .b_data_valid_pong(b_data_valid_pong_delay4_4));
processing_element pe4_5(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a4_4to4_5), .in_b(b3_5to4_5), .in_c(matrixC3_5), .out_a(a4_5to4_6), .out_b(b4_5to5_5), .out_b0(b4_5to5_5_ping), .out_b1(b4_5to5_5_pong), .out_c(matrixC4_5), .b_data_valid_ping(b_data_valid_ping_delay4_5), .b_data_valid_pong(b_data_valid_pong_delay4_5));
processing_element pe4_6(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a4_5to4_6), .in_b(b3_6to4_6), .in_c(matrixC3_6), .out_a(a4_6to4_7), .out_b(b4_6to5_6), .out_b0(b4_6to5_6_ping), .out_b1(b4_6to5_6_pong), .out_c(matrixC4_6), .b_data_valid_ping(b_data_valid_ping_delay4_6), .b_data_valid_pong(b_data_valid_pong_delay4_6));
processing_element pe4_7(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a4_6to4_7), .in_b(b3_7to4_7), .in_c(matrixC3_7), .out_a(a4_7to4_8), .out_b(b4_7to5_7), .out_b0(b4_7to5_7_ping), .out_b1(b4_7to5_7_pong), .out_c(matrixC4_7), .b_data_valid_ping(b_data_valid_ping_delay4_7), .b_data_valid_pong(b_data_valid_pong_delay4_7));

processing_element pe5_0(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay5), .in_a(a5),      .in_b(b4_0to5_0), .in_c(matrixC4_0), .out_a(a5_0to5_1), .out_b(b5_0to6_0), .out_b0(b5_0to6_0_ping), .out_b1(b5_0to6_0_pong), .out_c(matrixC5_0), .b_data_valid_ping(b_data_valid_ping_delay5_0), .b_data_valid_pong(b_data_valid_pong_delay5_0));
processing_element pe5_1(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a5_0to5_1), .in_b(b4_1to5_1), .in_c(matrixC4_1), .out_a(a5_1to5_2), .out_b(b5_1to6_1), .out_b0(b5_1to6_1_ping), .out_b1(b5_1to6_1_pong), .out_c(matrixC5_1), .b_data_valid_ping(b_data_valid_ping_delay5_1), .b_data_valid_pong(b_data_valid_pong_delay5_1));
processing_element pe5_2(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a5_1to5_2), .in_b(b4_2to5_2), .in_c(matrixC4_2), .out_a(a5_2to5_3), .out_b(b5_2to6_2), .out_b0(b5_2to6_2_ping), .out_b1(b5_2to6_2_pong), .out_c(matrixC5_2), .b_data_valid_ping(b_data_valid_ping_delay5_2), .b_data_valid_pong(b_data_valid_pong_delay5_2));
processing_element pe5_3(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a5_2to5_3), .in_b(b4_3to5_3), .in_c(matrixC4_3), .out_a(a5_3to5_4), .out_b(b5_3to6_3), .out_b0(b5_3to6_3_ping), .out_b1(b5_3to6_3_pong), .out_c(matrixC5_3), .b_data_valid_ping(b_data_valid_ping_delay5_3), .b_data_valid_pong(b_data_valid_pong_delay5_3));
processing_element pe5_4(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a5_3to5_4), .in_b(b4_4to5_4), .in_c(matrixC4_4), .out_a(a5_4to5_5), .out_b(b5_4to6_4), .out_b0(b5_4to6_4_ping), .out_b1(b5_4to6_4_pong), .out_c(matrixC5_4), .b_data_valid_ping(b_data_valid_ping_delay5_4), .b_data_valid_pong(b_data_valid_pong_delay5_4));
processing_element pe5_5(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a5_4to5_5), .in_b(b4_5to5_5), .in_c(matrixC4_5), .out_a(a5_5to5_6), .out_b(b5_5to6_5), .out_b0(b5_5to6_5_ping), .out_b1(b5_5to6_5_pong), .out_c(matrixC5_5), .b_data_valid_ping(b_data_valid_ping_delay5_5), .b_data_valid_pong(b_data_valid_pong_delay5_5));
processing_element pe5_6(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a5_5to5_6), .in_b(b4_6to5_6), .in_c(matrixC4_6), .out_a(a5_6to5_7), .out_b(b5_6to6_6), .out_b0(b5_6to6_6_ping), .out_b1(b5_6to6_6_pong), .out_c(matrixC5_6), .b_data_valid_ping(b_data_valid_ping_delay5_6), .b_data_valid_pong(b_data_valid_pong_delay5_6));
processing_element pe5_7(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay12), .in_a(a5_6to5_7), .in_b(b4_7to5_7), .in_c(matrixC4_7), .out_a(a5_7to5_8), .out_b(b5_7to6_7), .out_b0(b5_7to6_7_ping), .out_b1(b5_7to6_7_pong), .out_c(matrixC5_7), .b_data_valid_ping(b_data_valid_ping_delay5_7), .b_data_valid_pong(b_data_valid_pong_delay5_7));

processing_element pe6_0(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a6),      .in_b(b5_0to6_0), .in_c(matrixC5_0), .out_a(a6_0to6_1), .out_b(b6_0to7_0), .out_b0(b6_0to7_0_ping), .out_b1(b6_0to7_0_pong), .out_c(matrixC6_0), .b_data_valid_ping(b_data_valid_ping_delay6_0), .b_data_valid_pong(b_data_valid_pong_delay6_0));
processing_element pe6_1(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a6_0to6_1), .in_b(b5_1to6_1), .in_c(matrixC5_1), .out_a(a6_1to6_2), .out_b(b6_1to7_1), .out_b0(b6_1to7_1_ping), .out_b1(b6_1to7_1_pong), .out_c(matrixC6_1), .b_data_valid_ping(b_data_valid_ping_delay6_1), .b_data_valid_pong(b_data_valid_pong_delay6_1));
processing_element pe6_2(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a6_1to6_2), .in_b(b5_2to6_2), .in_c(matrixC5_2), .out_a(a6_2to6_3), .out_b(b6_2to7_2), .out_b0(b6_2to7_2_ping), .out_b1(b6_2to7_2_pong), .out_c(matrixC6_2), .b_data_valid_ping(b_data_valid_ping_delay6_2), .b_data_valid_pong(b_data_valid_pong_delay6_2));
processing_element pe6_3(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a6_2to6_3), .in_b(b5_3to6_3), .in_c(matrixC5_3), .out_a(a6_3to6_4), .out_b(b6_3to7_3), .out_b0(b6_3to7_3_ping), .out_b1(b6_3to7_3_pong), .out_c(matrixC6_3), .b_data_valid_ping(b_data_valid_ping_delay6_3), .b_data_valid_pong(b_data_valid_pong_delay6_3));
processing_element pe6_4(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a6_3to6_4), .in_b(b5_4to6_4), .in_c(matrixC5_4), .out_a(a6_4to6_5), .out_b(b6_4to7_4), .out_b0(b6_4to7_4_ping), .out_b1(b6_4to7_4_pong), .out_c(matrixC6_4), .b_data_valid_ping(b_data_valid_ping_delay6_4), .b_data_valid_pong(b_data_valid_pong_delay6_4));
processing_element pe6_5(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a6_4to6_5), .in_b(b5_5to6_5), .in_c(matrixC5_5), .out_a(a6_5to6_6), .out_b(b6_5to7_5), .out_b0(b6_5to7_5_ping), .out_b1(b6_5to7_5_pong), .out_c(matrixC6_5), .b_data_valid_ping(b_data_valid_ping_delay6_5), .b_data_valid_pong(b_data_valid_pong_delay6_5));
processing_element pe6_6(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay12), .in_a(a6_5to6_6), .in_b(b5_6to6_6), .in_c(matrixC5_6), .out_a(a6_6to6_7), .out_b(b6_6to7_6), .out_b0(b6_6to7_6_ping), .out_b1(b6_6to7_6_pong), .out_c(matrixC6_6), .b_data_valid_ping(b_data_valid_ping_delay6_6), .b_data_valid_pong(b_data_valid_pong_delay6_6));
processing_element pe6_7(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay13), .in_a(a6_6to6_7), .in_b(b5_7to6_7), .in_c(matrixC5_7), .out_a(a6_7to6_8), .out_b(b6_7to7_7), .out_b0(b6_7to7_7_ping), .out_b1(b6_7to7_7_pong), .out_c(matrixC6_7), .b_data_valid_ping(b_data_valid_ping_delay6_7), .b_data_valid_pong(b_data_valid_pong_delay6_7));

processing_element pe7_0(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a7),      .in_b(b6_0to7_0), .in_c(matrixC6_0), .out_a(a7_0to7_1), .out_b(b7_0to8_0), .out_b0(b7_0to8_0_ping), .out_b1(b7_0to8_0_pong), .out_c(matrixC7_0), .b_data_valid_ping(b_data_valid_ping_delay7_0), .b_data_valid_pong(b_data_valid_pong_delay7_0));
processing_element pe7_1(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a7_0to7_1), .in_b(b6_1to7_1), .in_c(matrixC6_1), .out_a(a7_1to7_2), .out_b(b7_1to8_1), .out_b0(b7_1to8_1_ping), .out_b1(b7_1to8_1_pong), .out_c(matrixC7_1), .b_data_valid_ping(b_data_valid_ping_delay7_1), .b_data_valid_pong(b_data_valid_pong_delay7_1));
processing_element pe7_2(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a7_1to7_2), .in_b(b6_2to7_2), .in_c(matrixC6_2), .out_a(a7_2to7_3), .out_b(b7_2to8_2), .out_b0(b7_2to8_2_ping), .out_b1(b7_2to8_2_pong), .out_c(matrixC7_2), .b_data_valid_ping(b_data_valid_ping_delay7_2), .b_data_valid_pong(b_data_valid_pong_delay7_2));
processing_element pe7_3(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a7_2to7_3), .in_b(b6_3to7_3), .in_c(matrixC6_3), .out_a(a7_3to7_4), .out_b(b7_3to8_3), .out_b0(b7_3to8_3_ping), .out_b1(b7_3to8_3_pong), .out_c(matrixC7_3), .b_data_valid_ping(b_data_valid_ping_delay7_3), .b_data_valid_pong(b_data_valid_pong_delay7_3));
processing_element pe7_4(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a7_3to7_4), .in_b(b6_4to7_4), .in_c(matrixC6_4), .out_a(a7_4to7_5), .out_b(b7_4to8_4), .out_b0(b7_4to8_4_ping), .out_b1(b7_4to8_4_pong), .out_c(matrixC7_4), .b_data_valid_ping(b_data_valid_ping_delay7_4), .b_data_valid_pong(b_data_valid_pong_delay7_4));
processing_element pe7_5(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay12), .in_a(a7_4to7_5), .in_b(b6_5to7_5), .in_c(matrixC6_5), .out_a(a7_5to7_6), .out_b(b7_5to8_5), .out_b0(b7_5to8_5_ping), .out_b1(b7_5to8_5_pong), .out_c(matrixC7_5), .b_data_valid_ping(b_data_valid_ping_delay7_5), .b_data_valid_pong(b_data_valid_pong_delay7_5));
processing_element pe7_6(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay13), .in_a(a7_5to7_6), .in_b(b6_6to7_6), .in_c(matrixC6_6), .out_a(a7_6to7_7), .out_b(b7_6to8_6), .out_b0(b7_6to8_6_ping), .out_b1(b7_6to8_6_pong), .out_c(matrixC7_6), .b_data_valid_ping(b_data_valid_ping_delay7_6), .b_data_valid_pong(b_data_valid_pong_delay7_6));
processing_element pe7_7(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay14), .in_a(a7_6to7_7), .in_b(b6_7to7_7), .in_c(matrixC6_7), .out_a(a7_7to7_8), .out_b(b7_7to8_7), .out_b0(b7_7to8_7_ping), .out_b1(b7_7to8_7_pong), .out_c(matrixC7_7), .b_data_valid_ping(b_data_valid_ping_delay7_7), .b_data_valid_pong(b_data_valid_pong_delay7_7));

  
assign a_data_out = {a7_7to7_8, a6_7to6_8, a5_7to5_8, a4_7to4_8, a3_7to3_8, a2_7to2_8, a1_7to1_8, a0_7to0_8};
assign b_data_out = {b7_7to8_7, b7_6to8_6, b7_5to8_5, b7_4to8_4, b7_3to8_3, b7_2to8_2, b7_1to8_1, b7_0to8_0};

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
