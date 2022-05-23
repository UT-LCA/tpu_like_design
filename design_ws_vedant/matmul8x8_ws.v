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
    matrixC70,
    matrixC71,
    matrixC72,
    matrixC73,
    matrixC74,
    matrixC75,
    matrixC76,
    matrixC77,
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
output [`DWIDTH-1:0] matrixC70;
output [`DWIDTH-1:0] matrixC71;
output [`DWIDTH-1:0] matrixC72;
output [`DWIDTH-1:0] matrixC73;
output [`DWIDTH-1:0] matrixC74;
output [`DWIDTH-1:0] matrixC75;
output [`DWIDTH-1:0] matrixC76;
output [`DWIDTH-1:0] matrixC77;
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
    .matrixC00(matrixC00),
    .matrixC01(matrixC01),
    .matrixC02(matrixC02),
    .matrixC03(matrixC03),
    .matrixC04(matrixC04),
    .matrixC05(matrixC05),
    .matrixC06(matrixC06),
    .matrixC07(matrixC07),
    .matrixC10(matrixC10),
    .matrixC11(matrixC11),
    .matrixC12(matrixC12),
    .matrixC13(matrixC13),
    .matrixC14(matrixC14),
    .matrixC15(matrixC15),
    .matrixC16(matrixC16),
    .matrixC17(matrixC17),
    .matrixC20(matrixC20),
    .matrixC21(matrixC21),
    .matrixC22(matrixC22),
    .matrixC23(matrixC23),
    .matrixC24(matrixC24),
    .matrixC25(matrixC25),
    .matrixC26(matrixC26),
    .matrixC27(matrixC27),
    .matrixC30(matrixC30),
    .matrixC31(matrixC31),
    .matrixC32(matrixC32),
    .matrixC33(matrixC33),
    .matrixC34(matrixC34),
    .matrixC35(matrixC35),
    .matrixC36(matrixC36),
    .matrixC37(matrixC37),
    .matrixC40(matrixC40),
    .matrixC41(matrixC41),
    .matrixC42(matrixC42),
    .matrixC43(matrixC43),
    .matrixC44(matrixC44),
    .matrixC45(matrixC45),
    .matrixC46(matrixC46),
    .matrixC47(matrixC47),
    .matrixC50(matrixC50),
    .matrixC51(matrixC51),
    .matrixC52(matrixC52),
    .matrixC53(matrixC53),
    .matrixC54(matrixC54),
    .matrixC55(matrixC55),
    .matrixC56(matrixC56),
    .matrixC57(matrixC57),
    .matrixC60(matrixC60),
    .matrixC61(matrixC61),
    .matrixC62(matrixC62),
    .matrixC63(matrixC63),
    .matrixC64(matrixC64),
    .matrixC65(matrixC65),
    .matrixC66(matrixC66),
    .matrixC67(matrixC67),
    .matrixC70(matrixC70),
    .matrixC71(matrixC71),
    .matrixC72(matrixC72),
    .matrixC73(matrixC73),
    .matrixC74(matrixC74),
    .matrixC75(matrixC75),
    .matrixC76(matrixC76),
    .matrixC77(matrixC77),
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
    start_mat_mul,
    b_data_sel,
    a0,    a1,    a2,    a3,    a4,    a5,    a6,    a7,
    b0,    b1,    b2,    b3,    b4,    b5,    b6,    b7,
    c0,    c1,    c2,    c3,    c4,    c5,    c6,    c7,
    matrixC00,
    matrixC01,
    matrixC02,
    matrixC03,
    matrixC04,
    matrixC05,
    matrixC06,
    matrixC07,
    matrixC10,
    matrixC11,
    matrixC12,
    matrixC13,
    matrixC14,
    matrixC15,
    matrixC16,
    matrixC17,
    matrixC20,
    matrixC21,
    matrixC22,
    matrixC23,
    matrixC24,
    matrixC25,
    matrixC26,
    matrixC27,
    matrixC30,
    matrixC31,
    matrixC32,
    matrixC33,
    matrixC34,
    matrixC35,
    matrixC36,
    matrixC37,
    matrixC40,
    matrixC41,
    matrixC42,
    matrixC43,
    matrixC44,
    matrixC45,
    matrixC46,
    matrixC47,
    matrixC50,
    matrixC51,
    matrixC52,
    matrixC53,
    matrixC54,
    matrixC55,
    matrixC56,
    matrixC57,
    matrixC60,
    matrixC61,
    matrixC62,
    matrixC63,
    matrixC64,
    matrixC65,
    matrixC66,
    matrixC67,
    matrixC70,
    matrixC71,
    matrixC72,
    matrixC73,
    matrixC74,
    matrixC75,
    matrixC76,
    matrixC77,
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
output [`DWIDTH-1:0] matrixC00;
output [`DWIDTH-1:0] matrixC01;
output [`DWIDTH-1:0] matrixC02;
output [`DWIDTH-1:0] matrixC03;
output [`DWIDTH-1:0] matrixC04;
output [`DWIDTH-1:0] matrixC05;
output [`DWIDTH-1:0] matrixC06;
output [`DWIDTH-1:0] matrixC07;
output [`DWIDTH-1:0] matrixC10;
output [`DWIDTH-1:0] matrixC11;
output [`DWIDTH-1:0] matrixC12;
output [`DWIDTH-1:0] matrixC13;
output [`DWIDTH-1:0] matrixC14;
output [`DWIDTH-1:0] matrixC15;
output [`DWIDTH-1:0] matrixC16;
output [`DWIDTH-1:0] matrixC17;
output [`DWIDTH-1:0] matrixC20;
output [`DWIDTH-1:0] matrixC21;
output [`DWIDTH-1:0] matrixC22;
output [`DWIDTH-1:0] matrixC23;
output [`DWIDTH-1:0] matrixC24;
output [`DWIDTH-1:0] matrixC25;
output [`DWIDTH-1:0] matrixC26;
output [`DWIDTH-1:0] matrixC27;
output [`DWIDTH-1:0] matrixC30;
output [`DWIDTH-1:0] matrixC31;
output [`DWIDTH-1:0] matrixC32;
output [`DWIDTH-1:0] matrixC33;
output [`DWIDTH-1:0] matrixC34;
output [`DWIDTH-1:0] matrixC35;
output [`DWIDTH-1:0] matrixC36;
output [`DWIDTH-1:0] matrixC37;
output [`DWIDTH-1:0] matrixC40;
output [`DWIDTH-1:0] matrixC41;
output [`DWIDTH-1:0] matrixC42;
output [`DWIDTH-1:0] matrixC43;
output [`DWIDTH-1:0] matrixC44;
output [`DWIDTH-1:0] matrixC45;
output [`DWIDTH-1:0] matrixC46;
output [`DWIDTH-1:0] matrixC47;
output [`DWIDTH-1:0] matrixC50;
output [`DWIDTH-1:0] matrixC51;
output [`DWIDTH-1:0] matrixC52;
output [`DWIDTH-1:0] matrixC53;
output [`DWIDTH-1:0] matrixC54;
output [`DWIDTH-1:0] matrixC55;
output [`DWIDTH-1:0] matrixC56;
output [`DWIDTH-1:0] matrixC57;
output [`DWIDTH-1:0] matrixC60;
output [`DWIDTH-1:0] matrixC61;
output [`DWIDTH-1:0] matrixC62;
output [`DWIDTH-1:0] matrixC63;
output [`DWIDTH-1:0] matrixC64;
output [`DWIDTH-1:0] matrixC65;
output [`DWIDTH-1:0] matrixC66;
output [`DWIDTH-1:0] matrixC67;
output [`DWIDTH-1:0] matrixC70;
output [`DWIDTH-1:0] matrixC71;
output [`DWIDTH-1:0] matrixC72;
output [`DWIDTH-1:0] matrixC73;
output [`DWIDTH-1:0] matrixC74;
output [`DWIDTH-1:0] matrixC75;
output [`DWIDTH-1:0] matrixC76;
output [`DWIDTH-1:0] matrixC77;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out;
  

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

wire [`DWIDTH-1:0] b00to10_ping, b10to20_ping, b20to30_ping, b30to40_ping, b40to50_ping, b50to60_ping, b60to70_ping, b70to80_ping;
wire [`DWIDTH-1:0] b01to11_ping, b11to21_ping, b21to31_ping, b31to41_ping, b41to51_ping, b51to61_ping, b61to71_ping, b71to81_ping;
wire [`DWIDTH-1:0] b02to12_ping, b12to22_ping, b22to32_ping, b32to42_ping, b42to52_ping, b52to62_ping, b62to72_ping, b72to82_ping;
wire [`DWIDTH-1:0] b03to13_ping, b13to23_ping, b23to33_ping, b33to43_ping, b43to53_ping, b53to63_ping, b63to73_ping, b73to83_ping;
wire [`DWIDTH-1:0] b04to14_ping, b14to24_ping, b24to34_ping, b34to44_ping, b44to54_ping, b54to64_ping, b64to74_ping, b74to84_ping;
wire [`DWIDTH-1:0] b05to15_ping, b15to25_ping, b25to35_ping, b35to45_ping, b45to55_ping, b55to65_ping, b65to75_ping, b75to85_ping;
wire [`DWIDTH-1:0] b06to16_ping, b16to26_ping, b26to36_ping, b36to46_ping, b46to56_ping, b56to66_ping, b66to76_ping, b76to86_ping;
wire [`DWIDTH-1:0] b07to17_ping, b17to27_ping, b27to37_ping, b37to47_ping, b47to57_ping, b57to67_ping, b67to77_ping, b77to87_ping;

wire [`DWIDTH-1:0] b00to10_pong, b10to20_pong, b20to30_pong, b30to40_pong, b40to50_pong, b50to60_pong, b60to70_pong, b70to80_pong;
wire [`DWIDTH-1:0] b01to11_pong, b11to21_pong, b21to31_pong, b31to41_pong, b41to51_pong, b51to61_pong, b61to71_pong, b71to81_pong;
wire [`DWIDTH-1:0] b02to12_pong, b12to22_pong, b22to32_pong, b32to42_pong, b42to52_pong, b52to62_pong, b62to72_pong, b72to82_pong;
wire [`DWIDTH-1:0] b03to13_pong, b13to23_pong, b23to33_pong, b33to43_pong, b43to53_pong, b53to63_pong, b63to73_pong, b73to83_pong;
wire [`DWIDTH-1:0] b04to14_pong, b14to24_pong, b24to34_pong, b34to44_pong, b44to54_pong, b54to64_pong, b64to74_pong, b74to84_pong;
wire [`DWIDTH-1:0] b05to15_pong, b15to25_pong, b25to35_pong, b35to45_pong, b45to55_pong, b55to65_pong, b65to75_pong, b75to85_pong;
wire [`DWIDTH-1:0] b06to16_pong, b16to26_pong, b26to36_pong, b36to46_pong, b46to56_pong, b56to66_pong, b66to76_pong, b76to86_pong;
wire [`DWIDTH-1:0] b07to17_pong, b17to27_pong, b27to37_pong, b37to47_pong, b47to57_pong, b57to67_pong, b67to77_pong, b77to87_pong;

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
wire b_data_valid_pong_delay10;
wire b_data_valid_pong_delay20;
wire b_data_valid_pong_delay30;
wire b_data_valid_pong_delay40;
wire b_data_valid_pong_delay50;
wire b_data_valid_pong_delay60;
wire b_data_valid_pong_delay70;
wire b_data_valid_pong_delay11;
wire b_data_valid_pong_delay21;
wire b_data_valid_pong_delay31;
wire b_data_valid_pong_delay41;
wire b_data_valid_pong_delay51;
wire b_data_valid_pong_delay61;
wire b_data_valid_pong_delay71;
wire b_data_valid_pong_delay12;
wire b_data_valid_pong_delay22;
wire b_data_valid_pong_delay32;
wire b_data_valid_pong_delay42;
wire b_data_valid_pong_delay52;
wire b_data_valid_pong_delay62;
wire b_data_valid_pong_delay72;
wire b_data_valid_pong_delay13;
wire b_data_valid_pong_delay23;
wire b_data_valid_pong_delay33;
wire b_data_valid_pong_delay43;
wire b_data_valid_pong_delay53;
wire b_data_valid_pong_delay63;
wire b_data_valid_pong_delay73;
wire b_data_valid_pong_delay14;
wire b_data_valid_pong_delay24;
wire b_data_valid_pong_delay34;
wire b_data_valid_pong_delay44;
wire b_data_valid_pong_delay54;
wire b_data_valid_pong_delay64;
wire b_data_valid_pong_delay74;
wire b_data_valid_pong_delay15;
wire b_data_valid_pong_delay25;
wire b_data_valid_pong_delay35;
wire b_data_valid_pong_delay45;
wire b_data_valid_pong_delay55;
wire b_data_valid_pong_delay65;
wire b_data_valid_pong_delay75;
wire b_data_valid_pong_delay16;
wire b_data_valid_pong_delay26;
wire b_data_valid_pong_delay36;
wire b_data_valid_pong_delay46;
wire b_data_valid_pong_delay56;
wire b_data_valid_pong_delay66;
wire b_data_valid_pong_delay76;
wire b_data_valid_pong_delay17;
wire b_data_valid_pong_delay27;
wire b_data_valid_pong_delay37;
wire b_data_valid_pong_delay47;
wire b_data_valid_pong_delay57;
wire b_data_valid_pong_delay67;
wire b_data_valid_pong_delay77;
  
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

assign b_data_valid_pong_delay10 = b_data_valid_pong & b_data_valid_pong_delay01;
assign b_data_valid_pong_delay20 = b_data_valid_pong & b_data_valid_pong_delay02;
assign b_data_valid_pong_delay30 = b_data_valid_pong & b_data_valid_pong_delay03;
assign b_data_valid_pong_delay40 = b_data_valid_pong & b_data_valid_pong_delay04;
assign b_data_valid_pong_delay50 = b_data_valid_pong & b_data_valid_pong_delay05;
assign b_data_valid_pong_delay60 = b_data_valid_pong & b_data_valid_pong_delay06;
assign b_data_valid_pong_delay70 = b_data_valid_pong & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay11 = b_data_valid_pong_delay01 & b_data_valid_pong_delay02;
assign b_data_valid_pong_delay21 = b_data_valid_pong_delay01 & b_data_valid_pong_delay03;
assign b_data_valid_pong_delay31 = b_data_valid_pong_delay01 & b_data_valid_pong_delay04;
assign b_data_valid_pong_delay41 = b_data_valid_pong_delay01 & b_data_valid_pong_delay05;
assign b_data_valid_pong_delay51 = b_data_valid_pong_delay01 & b_data_valid_pong_delay06;
assign b_data_valid_pong_delay61 = b_data_valid_pong_delay01 & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay71 = b_data_valid_pong_delay01 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay12 = b_data_valid_pong_delay02 & b_data_valid_pong_delay03;
assign b_data_valid_pong_delay22 = b_data_valid_pong_delay02 & b_data_valid_pong_delay04;
assign b_data_valid_pong_delay32 = b_data_valid_pong_delay02 & b_data_valid_pong_delay05;
assign b_data_valid_pong_delay42 = b_data_valid_pong_delay02 & b_data_valid_pong_delay06;
assign b_data_valid_pong_delay52 = b_data_valid_pong_delay02 & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay62 = b_data_valid_pong_delay02 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay72 = b_data_valid_pong_delay02 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay13 = b_data_valid_pong_delay03 & b_data_valid_pong_delay04;
assign b_data_valid_pong_delay23 = b_data_valid_pong_delay03 & b_data_valid_pong_delay05;
assign b_data_valid_pong_delay33 = b_data_valid_pong_delay03 & b_data_valid_pong_delay06;
assign b_data_valid_pong_delay43 = b_data_valid_pong_delay03 & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay53 = b_data_valid_pong_delay03 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay63 = b_data_valid_pong_delay03 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay73 = b_data_valid_pong_delay03 & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay14 = b_data_valid_pong_delay04 & b_data_valid_pong_delay05;
assign b_data_valid_pong_delay24 = b_data_valid_pong_delay04 & b_data_valid_pong_delay06;
assign b_data_valid_pong_delay34 = b_data_valid_pong_delay04 & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay44 = b_data_valid_pong_delay04 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay54 = b_data_valid_pong_delay04 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay64 = b_data_valid_pong_delay04 & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay74 = b_data_valid_pong_delay04 & b_data_valid_pong_delay011;
assign b_data_valid_pong_delay15 = b_data_valid_pong_delay05 & b_data_valid_pong_delay06;
assign b_data_valid_pong_delay25 = b_data_valid_pong_delay05 & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay35 = b_data_valid_pong_delay05 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay45 = b_data_valid_pong_delay05 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay55 = b_data_valid_pong_delay05 & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay65 = b_data_valid_pong_delay05 & b_data_valid_pong_delay011;
assign b_data_valid_pong_delay75 = b_data_valid_pong_delay05 & b_data_valid_pong_delay012;
assign b_data_valid_pong_delay16 = b_data_valid_pong_delay06 & b_data_valid_pong_delay07;
assign b_data_valid_pong_delay26 = b_data_valid_pong_delay06 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay36 = b_data_valid_pong_delay06 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay46 = b_data_valid_pong_delay06 & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay56 = b_data_valid_pong_delay06 & b_data_valid_pong_delay011;
assign b_data_valid_pong_delay66 = b_data_valid_pong_delay06 & b_data_valid_pong_delay012;
assign b_data_valid_pong_delay76 = b_data_valid_pong_delay06 & b_data_valid_pong_delay013;
assign b_data_valid_pong_delay17 = b_data_valid_pong_delay07 & b_data_valid_pong_delay08;
assign b_data_valid_pong_delay27 = b_data_valid_pong_delay07 & b_data_valid_pong_delay09;
assign b_data_valid_pong_delay37 = b_data_valid_pong_delay07 & b_data_valid_pong_delay010;
assign b_data_valid_pong_delay47 = b_data_valid_pong_delay07 & b_data_valid_pong_delay011;
assign b_data_valid_pong_delay57 = b_data_valid_pong_delay07 & b_data_valid_pong_delay012;
assign b_data_valid_pong_delay67 = b_data_valid_pong_delay07 & b_data_valid_pong_delay013;
assign b_data_valid_pong_delay77 = b_data_valid_pong_delay07 & b_data_valid_pong_delay014;

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
wire b_data_valid_ping_delay10;
wire b_data_valid_ping_delay20;
wire b_data_valid_ping_delay30;
wire b_data_valid_ping_delay40;
wire b_data_valid_ping_delay50;
wire b_data_valid_ping_delay60;
wire b_data_valid_ping_delay70;
wire b_data_valid_ping_delay11;
wire b_data_valid_ping_delay21;
wire b_data_valid_ping_delay31;
wire b_data_valid_ping_delay41;
wire b_data_valid_ping_delay51;
wire b_data_valid_ping_delay61;
wire b_data_valid_ping_delay71;
wire b_data_valid_ping_delay12;
wire b_data_valid_ping_delay22;
wire b_data_valid_ping_delay32;
wire b_data_valid_ping_delay42;
wire b_data_valid_ping_delay52;
wire b_data_valid_ping_delay62;
wire b_data_valid_ping_delay72;
wire b_data_valid_ping_delay13;
wire b_data_valid_ping_delay23;
wire b_data_valid_ping_delay33;
wire b_data_valid_ping_delay43;
wire b_data_valid_ping_delay53;
wire b_data_valid_ping_delay63;
wire b_data_valid_ping_delay73;
wire b_data_valid_ping_delay14;
wire b_data_valid_ping_delay24;
wire b_data_valid_ping_delay34;
wire b_data_valid_ping_delay44;
wire b_data_valid_ping_delay54;
wire b_data_valid_ping_delay64;
wire b_data_valid_ping_delay74;
wire b_data_valid_ping_delay15;
wire b_data_valid_ping_delay25;
wire b_data_valid_ping_delay35;
wire b_data_valid_ping_delay45;
wire b_data_valid_ping_delay55;
wire b_data_valid_ping_delay65;
wire b_data_valid_ping_delay75;
wire b_data_valid_ping_delay16;
wire b_data_valid_ping_delay26;
wire b_data_valid_ping_delay36;
wire b_data_valid_ping_delay46;
wire b_data_valid_ping_delay56;
wire b_data_valid_ping_delay66;
wire b_data_valid_ping_delay76;
wire b_data_valid_ping_delay17;
wire b_data_valid_ping_delay27;
wire b_data_valid_ping_delay37;
wire b_data_valid_ping_delay47;
wire b_data_valid_ping_delay57;
wire b_data_valid_ping_delay67;
wire b_data_valid_ping_delay77;
  
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

assign b_data_valid_ping_delay10 = b_data_valid_ping & b_data_valid_ping_delay01;
assign b_data_valid_ping_delay20 = b_data_valid_ping & b_data_valid_ping_delay02;
assign b_data_valid_ping_delay30 = b_data_valid_ping & b_data_valid_ping_delay03;
assign b_data_valid_ping_delay40 = b_data_valid_ping & b_data_valid_ping_delay04;
assign b_data_valid_ping_delay50 = b_data_valid_ping & b_data_valid_ping_delay05;
assign b_data_valid_ping_delay60 = b_data_valid_ping & b_data_valid_ping_delay06;
assign b_data_valid_ping_delay70 = b_data_valid_ping & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay11 = b_data_valid_ping_delay01 & b_data_valid_ping_delay02;
assign b_data_valid_ping_delay21 = b_data_valid_ping_delay01 & b_data_valid_ping_delay03;
assign b_data_valid_ping_delay31 = b_data_valid_ping_delay01 & b_data_valid_ping_delay04;
assign b_data_valid_ping_delay41 = b_data_valid_ping_delay01 & b_data_valid_ping_delay05;
assign b_data_valid_ping_delay51 = b_data_valid_ping_delay01 & b_data_valid_ping_delay06;
assign b_data_valid_ping_delay61 = b_data_valid_ping_delay01 & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay71 = b_data_valid_ping_delay01 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay12 = b_data_valid_ping_delay02 & b_data_valid_ping_delay03;
assign b_data_valid_ping_delay22 = b_data_valid_ping_delay02 & b_data_valid_ping_delay04;
assign b_data_valid_ping_delay32 = b_data_valid_ping_delay02 & b_data_valid_ping_delay05;
assign b_data_valid_ping_delay42 = b_data_valid_ping_delay02 & b_data_valid_ping_delay06;
assign b_data_valid_ping_delay52 = b_data_valid_ping_delay02 & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay62 = b_data_valid_ping_delay02 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay72 = b_data_valid_ping_delay02 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay13 = b_data_valid_ping_delay03 & b_data_valid_ping_delay04;
assign b_data_valid_ping_delay23 = b_data_valid_ping_delay03 & b_data_valid_ping_delay05;
assign b_data_valid_ping_delay33 = b_data_valid_ping_delay03 & b_data_valid_ping_delay06;
assign b_data_valid_ping_delay43 = b_data_valid_ping_delay03 & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay53 = b_data_valid_ping_delay03 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay63 = b_data_valid_ping_delay03 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay73 = b_data_valid_ping_delay03 & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay14 = b_data_valid_ping_delay04 & b_data_valid_ping_delay05;
assign b_data_valid_ping_delay24 = b_data_valid_ping_delay04 & b_data_valid_ping_delay06;
assign b_data_valid_ping_delay34 = b_data_valid_ping_delay04 & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay44 = b_data_valid_ping_delay04 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay54 = b_data_valid_ping_delay04 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay64 = b_data_valid_ping_delay04 & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay74 = b_data_valid_ping_delay04 & b_data_valid_ping_delay011;
assign b_data_valid_ping_delay15 = b_data_valid_ping_delay05 & b_data_valid_ping_delay06;
assign b_data_valid_ping_delay25 = b_data_valid_ping_delay05 & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay35 = b_data_valid_ping_delay05 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay45 = b_data_valid_ping_delay05 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay55 = b_data_valid_ping_delay05 & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay65 = b_data_valid_ping_delay05 & b_data_valid_ping_delay011;
assign b_data_valid_ping_delay75 = b_data_valid_ping_delay05 & b_data_valid_ping_delay012;
assign b_data_valid_ping_delay16 = b_data_valid_ping_delay06 & b_data_valid_ping_delay07;
assign b_data_valid_ping_delay26 = b_data_valid_ping_delay06 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay36 = b_data_valid_ping_delay06 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay46 = b_data_valid_ping_delay06 & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay56 = b_data_valid_ping_delay06 & b_data_valid_ping_delay011;
assign b_data_valid_ping_delay66 = b_data_valid_ping_delay06 & b_data_valid_ping_delay012;
assign b_data_valid_ping_delay76 = b_data_valid_ping_delay06 & b_data_valid_ping_delay013;
assign b_data_valid_ping_delay17 = b_data_valid_ping_delay07 & b_data_valid_ping_delay08;
assign b_data_valid_ping_delay27 = b_data_valid_ping_delay07 & b_data_valid_ping_delay09;
assign b_data_valid_ping_delay37 = b_data_valid_ping_delay07 & b_data_valid_ping_delay010;
assign b_data_valid_ping_delay47 = b_data_valid_ping_delay07 & b_data_valid_ping_delay011;
assign b_data_valid_ping_delay57 = b_data_valid_ping_delay07 & b_data_valid_ping_delay012;
assign b_data_valid_ping_delay67 = b_data_valid_ping_delay07 & b_data_valid_ping_delay013;
assign b_data_valid_ping_delay77 = b_data_valid_ping_delay07 & b_data_valid_ping_delay014;

processing_element pe00(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel),        .in_a(a0),      .in_b(b0),      .in_c(c0),        .out_a(a00to01), .out_b(b00to10), .out_b0(b00to10_ping), .out_b1(b00to10_pong), .out_c(matrixC00), .b_data_valid_ping(b_data_valid_ping),         .b_data_valid_pong(b_data_valid_pong        ));
processing_element pe01(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay1), .in_a(a00to01), .in_b(b1),      .in_c(c1),        .out_a(a01to02), .out_b(b01to11), .out_b0(b01to11_ping), .out_b1(b01to11_pong), .out_c(matrixC01), .b_data_valid_ping(b_data_valid_ping_delay01), .b_data_valid_pong(b_data_valid_pong_delay01));
processing_element pe02(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay2), .in_a(a01to02), .in_b(b2),      .in_c(c2),        .out_a(a02to03), .out_b(b02to12), .out_b0(b02to12_ping), .out_b1(b02to12_pong), .out_c(matrixC02), .b_data_valid_ping(b_data_valid_ping_delay02), .b_data_valid_pong(b_data_valid_pong_delay02));
processing_element pe03(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay3), .in_a(a02to03), .in_b(b3),      .in_c(c3),        .out_a(a03to04), .out_b(b03to13), .out_b0(b03to13_ping), .out_b1(b03to13_pong), .out_c(matrixC03), .b_data_valid_ping(b_data_valid_ping_delay03), .b_data_valid_pong(b_data_valid_pong_delay03));
processing_element pe04(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay4), .in_a(a03to04), .in_b(b4),      .in_c(c4),        .out_a(a04to05), .out_b(b04to14), .out_b0(b04to14_ping), .out_b1(b04to14_pong), .out_c(matrixC04), .b_data_valid_ping(b_data_valid_ping_delay04), .b_data_valid_pong(b_data_valid_pong_delay04));
processing_element pe05(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay5), .in_a(a04to05), .in_b(b5),      .in_c(c5),        .out_a(a05to06), .out_b(b05to15), .out_b0(b05to15_ping), .out_b1(b05to15_pong), .out_c(matrixC05), .b_data_valid_ping(b_data_valid_ping_delay05), .b_data_valid_pong(b_data_valid_pong_delay05));
processing_element pe06(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a05to06), .in_b(b6),      .in_c(c6),        .out_a(a06to07), .out_b(b06to16), .out_b0(b06to16_ping), .out_b1(b06to16_pong), .out_c(matrixC06), .b_data_valid_ping(b_data_valid_ping_delay06), .b_data_valid_pong(b_data_valid_pong_delay06));
processing_element pe07(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a06to07), .in_b(b7),      .in_c(c7),        .out_a(a07to08), .out_b(b07to17), .out_b0(b07to17_ping), .out_b1(b07to17_pong), .out_c(matrixC07), .b_data_valid_ping(b_data_valid_ping_delay07), .b_data_valid_pong(b_data_valid_pong_delay07));

processing_element pe10(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay1), .in_a(a1),      .in_b(b00to10), .in_c(matrixC00), .out_a(a10to11), .out_b(b10to20), .out_b0(b10to20_ping), .out_b1(b10to20_pong), .out_c(matrixC10), .b_data_valid_ping(b_data_valid_ping_delay10), .b_data_valid_pong(b_data_valid_pong_delay10));
processing_element pe11(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay2), .in_a(a10to11), .in_b(b01to11), .in_c(matrixC01), .out_a(a11to12), .out_b(b11to21), .out_b0(b11to21_ping), .out_b1(b11to21_pong), .out_c(matrixC11), .b_data_valid_ping(b_data_valid_ping_delay11), .b_data_valid_pong(b_data_valid_pong_delay11));
processing_element pe12(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay3), .in_a(a11to12), .in_b(b02to12), .in_c(matrixC02), .out_a(a12to13), .out_b(b12to22), .out_b0(b12to22_ping), .out_b1(b12to22_pong), .out_c(matrixC12), .b_data_valid_ping(b_data_valid_ping_delay12), .b_data_valid_pong(b_data_valid_pong_delay12));
processing_element pe13(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay4), .in_a(a12to13), .in_b(b03to13), .in_c(matrixC03), .out_a(a13to14), .out_b(b13to23), .out_b0(b13to23_ping), .out_b1(b13to23_pong), .out_c(matrixC13), .b_data_valid_ping(b_data_valid_ping_delay13), .b_data_valid_pong(b_data_valid_pong_delay13));
processing_element pe14(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay5), .in_a(a13to14), .in_b(b04to14), .in_c(matrixC04), .out_a(a14to15), .out_b(b14to24), .out_b0(b14to24_ping), .out_b1(b14to24_pong), .out_c(matrixC14), .b_data_valid_ping(b_data_valid_ping_delay14), .b_data_valid_pong(b_data_valid_pong_delay14));
processing_element pe15(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a14to15), .in_b(b05to15), .in_c(matrixC05), .out_a(a15to16), .out_b(b15to25), .out_b0(b15to25_ping), .out_b1(b15to25_pong), .out_c(matrixC15), .b_data_valid_ping(b_data_valid_ping_delay15), .b_data_valid_pong(b_data_valid_pong_delay15));
processing_element pe16(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a15to16), .in_b(b06to16), .in_c(matrixC06), .out_a(a16to17), .out_b(b16to26), .out_b0(b16to26_ping), .out_b1(b16to26_pong), .out_c(matrixC16), .b_data_valid_ping(b_data_valid_ping_delay16), .b_data_valid_pong(b_data_valid_pong_delay16));
processing_element pe17(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a16to17), .in_b(b07to17), .in_c(matrixC07), .out_a(a17to18), .out_b(b17to27), .out_b0(b17to27_ping), .out_b1(b17to27_pong), .out_c(matrixC17), .b_data_valid_ping(b_data_valid_ping_delay17), .b_data_valid_pong(b_data_valid_pong_delay17));

processing_element pe20(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay2), .in_a(a2),      .in_b(b10to20), .in_c(matrixC10), .out_a(a20to21), .out_b(b20to30), .out_b0(b20to30_ping), .out_b1(b20to30_pong), .out_c(matrixC20), .b_data_valid_ping(b_data_valid_ping_delay20), .b_data_valid_pong(b_data_valid_pong_delay20));
processing_element pe21(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay3), .in_a(a20to21), .in_b(b11to21), .in_c(matrixC11), .out_a(a21to22), .out_b(b21to31), .out_b0(b21to31_ping), .out_b1(b21to31_pong), .out_c(matrixC21), .b_data_valid_ping(b_data_valid_ping_delay21), .b_data_valid_pong(b_data_valid_pong_delay21));
processing_element pe22(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay4), .in_a(a21to22), .in_b(b12to22), .in_c(matrixC12), .out_a(a22to23), .out_b(b22to32), .out_b0(b22to32_ping), .out_b1(b22to32_pong), .out_c(matrixC22), .b_data_valid_ping(b_data_valid_ping_delay22), .b_data_valid_pong(b_data_valid_pong_delay22));
processing_element pe23(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay5), .in_a(a22to23), .in_b(b13to23), .in_c(matrixC13), .out_a(a23to24), .out_b(b23to33), .out_b0(b23to33_ping), .out_b1(b23to33_pong), .out_c(matrixC23), .b_data_valid_ping(b_data_valid_ping_delay23), .b_data_valid_pong(b_data_valid_pong_delay23));
processing_element pe24(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a23to24), .in_b(b14to24), .in_c(matrixC14), .out_a(a24to25), .out_b(b24to34), .out_b0(b24to34_ping), .out_b1(b24to34_pong), .out_c(matrixC24), .b_data_valid_ping(b_data_valid_ping_delay24), .b_data_valid_pong(b_data_valid_pong_delay24));
processing_element pe25(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a24to25), .in_b(b15to25), .in_c(matrixC15), .out_a(a25to26), .out_b(b25to35), .out_b0(b25to35_ping), .out_b1(b25to35_pong), .out_c(matrixC25), .b_data_valid_ping(b_data_valid_ping_delay25), .b_data_valid_pong(b_data_valid_pong_delay25));
processing_element pe26(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a25to26), .in_b(b16to26), .in_c(matrixC16), .out_a(a26to27), .out_b(b26to36), .out_b0(b26to36_ping), .out_b1(b26to36_pong), .out_c(matrixC26), .b_data_valid_ping(b_data_valid_ping_delay26), .b_data_valid_pong(b_data_valid_pong_delay26));
processing_element pe27(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a26to27), .in_b(b17to27), .in_c(matrixC17), .out_a(a27to28), .out_b(b27to37), .out_b0(b27to37_ping), .out_b1(b27to37_pong), .out_c(matrixC27), .b_data_valid_ping(b_data_valid_ping_delay27), .b_data_valid_pong(b_data_valid_pong_delay27));

processing_element pe30(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay3), .in_a(a3),      .in_b(b20to30), .in_c(matrixC20), .out_a(a30to31), .out_b(b30to40), .out_b0(b30to40_ping), .out_b1(b30to40_pong), .out_c(matrixC30), .b_data_valid_ping(b_data_valid_ping_delay30), .b_data_valid_pong(b_data_valid_pong_delay30));
processing_element pe31(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay4), .in_a(a30to31), .in_b(b21to31), .in_c(matrixC21), .out_a(a31to32), .out_b(b31to41), .out_b0(b31to41_ping), .out_b1(b31to41_pong), .out_c(matrixC31), .b_data_valid_ping(b_data_valid_ping_delay31), .b_data_valid_pong(b_data_valid_pong_delay31));
processing_element pe32(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay5), .in_a(a31to32), .in_b(b22to32), .in_c(matrixC22), .out_a(a32to33), .out_b(b32to42), .out_b0(b32to42_ping), .out_b1(b32to42_pong), .out_c(matrixC32), .b_data_valid_ping(b_data_valid_ping_delay32), .b_data_valid_pong(b_data_valid_pong_delay32));
processing_element pe33(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a32to33), .in_b(b23to33), .in_c(matrixC23), .out_a(a33to34), .out_b(b33to43), .out_b0(b33to43_ping), .out_b1(b33to43_pong), .out_c(matrixC33), .b_data_valid_ping(b_data_valid_ping_delay33), .b_data_valid_pong(b_data_valid_pong_delay33));
processing_element pe34(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a33to34), .in_b(b24to34), .in_c(matrixC24), .out_a(a34to35), .out_b(b34to44), .out_b0(b34to44_ping), .out_b1(b34to44_pong), .out_c(matrixC34), .b_data_valid_ping(b_data_valid_ping_delay34), .b_data_valid_pong(b_data_valid_pong_delay34));
processing_element pe35(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a34to35), .in_b(b25to35), .in_c(matrixC25), .out_a(a35to36), .out_b(b35to45), .out_b0(b35to45_ping), .out_b1(b35to45_pong), .out_c(matrixC35), .b_data_valid_ping(b_data_valid_ping_delay35), .b_data_valid_pong(b_data_valid_pong_delay35));
processing_element pe36(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a35to36), .in_b(b26to36), .in_c(matrixC26), .out_a(a36to37), .out_b(b36to46), .out_b0(b36to46_ping), .out_b1(b36to46_pong), .out_c(matrixC36), .b_data_valid_ping(b_data_valid_ping_delay36), .b_data_valid_pong(b_data_valid_pong_delay36));
processing_element pe37(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a36to37), .in_b(b27to37), .in_c(matrixC27), .out_a(a37to38), .out_b(b37to47), .out_b0(b37to47_ping), .out_b1(b37to47_pong), .out_c(matrixC37), .b_data_valid_ping(b_data_valid_ping_delay37), .b_data_valid_pong(b_data_valid_pong_delay37));

processing_element pe40(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay4), .in_a(a4),      .in_b(b30to40), .in_c(matrixC30), .out_a(a40to41), .out_b(b40to50), .out_b0(b40to50_ping), .out_b1(b40to50_pong), .out_c(matrixC40), .b_data_valid_ping(b_data_valid_ping_delay40), .b_data_valid_pong(b_data_valid_pong_delay40));
processing_element pe41(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay5), .in_a(a40to41), .in_b(b31to41), .in_c(matrixC31), .out_a(a41to42), .out_b(b41to51), .out_b0(b41to51_ping), .out_b1(b41to51_pong), .out_c(matrixC41), .b_data_valid_ping(b_data_valid_ping_delay41), .b_data_valid_pong(b_data_valid_pong_delay41));
processing_element pe42(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a41to42), .in_b(b32to42), .in_c(matrixC32), .out_a(a42to43), .out_b(b42to52), .out_b0(b42to52_ping), .out_b1(b42to52_pong), .out_c(matrixC42), .b_data_valid_ping(b_data_valid_ping_delay42), .b_data_valid_pong(b_data_valid_pong_delay42));
processing_element pe43(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a42to43), .in_b(b33to43), .in_c(matrixC33), .out_a(a43to44), .out_b(b43to53), .out_b0(b43to53_ping), .out_b1(b43to53_pong), .out_c(matrixC43), .b_data_valid_ping(b_data_valid_ping_delay43), .b_data_valid_pong(b_data_valid_pong_delay43));
processing_element pe44(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a43to44), .in_b(b34to44), .in_c(matrixC34), .out_a(a44to45), .out_b(b44to54), .out_b0(b44to54_ping), .out_b1(b44to54_pong), .out_c(matrixC44), .b_data_valid_ping(b_data_valid_ping_delay44), .b_data_valid_pong(b_data_valid_pong_delay44));
processing_element pe45(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a44to45), .in_b(b35to45), .in_c(matrixC35), .out_a(a45to46), .out_b(b45to55), .out_b0(b45to55_ping), .out_b1(b45to55_pong), .out_c(matrixC45), .b_data_valid_ping(b_data_valid_ping_delay45), .b_data_valid_pong(b_data_valid_pong_delay45));
processing_element pe46(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a45to46), .in_b(b36to46), .in_c(matrixC36), .out_a(a46to47), .out_b(b46to56), .out_b0(b46to56_ping), .out_b1(b46to56_pong), .out_c(matrixC46), .b_data_valid_ping(b_data_valid_ping_delay46), .b_data_valid_pong(b_data_valid_pong_delay46));
processing_element pe47(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a46to47), .in_b(b37to47), .in_c(matrixC37), .out_a(a47to48), .out_b(b47to57), .out_b0(b47to57_ping), .out_b1(b47to57_pong), .out_c(matrixC47), .b_data_valid_ping(b_data_valid_ping_delay47), .b_data_valid_pong(b_data_valid_pong_delay47));

processing_element pe50(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay5), .in_a(a5),      .in_b(b40to50), .in_c(matrixC40), .out_a(a50to51), .out_b(b50to60), .out_b0(b50to60_ping), .out_b1(b50to60_pong), .out_c(matrixC50), .b_data_valid_ping(b_data_valid_ping_delay50), .b_data_valid_pong(b_data_valid_pong_delay50));
processing_element pe51(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a50to51), .in_b(b41to51), .in_c(matrixC41), .out_a(a51to52), .out_b(b51to61), .out_b0(b51to61_ping), .out_b1(b51to61_pong), .out_c(matrixC51), .b_data_valid_ping(b_data_valid_ping_delay51), .b_data_valid_pong(b_data_valid_pong_delay51));
processing_element pe52(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a51to52), .in_b(b42to52), .in_c(matrixC42), .out_a(a52to53), .out_b(b52to62), .out_b0(b52to62_ping), .out_b1(b52to62_pong), .out_c(matrixC52), .b_data_valid_ping(b_data_valid_ping_delay52), .b_data_valid_pong(b_data_valid_pong_delay52));
processing_element pe53(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a52to53), .in_b(b43to53), .in_c(matrixC43), .out_a(a53to54), .out_b(b53to63), .out_b0(b53to63_ping), .out_b1(b53to63_pong), .out_c(matrixC53), .b_data_valid_ping(b_data_valid_ping_delay53), .b_data_valid_pong(b_data_valid_pong_delay53));
processing_element pe54(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a53to54), .in_b(b44to54), .in_c(matrixC44), .out_a(a54to55), .out_b(b54to64), .out_b0(b54to64_ping), .out_b1(b54to64_pong), .out_c(matrixC54), .b_data_valid_ping(b_data_valid_ping_delay54), .b_data_valid_pong(b_data_valid_pong_delay54));
processing_element pe55(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a54to55), .in_b(b45to55), .in_c(matrixC45), .out_a(a55to56), .out_b(b55to65), .out_b0(b55to65_ping), .out_b1(b55to65_pong), .out_c(matrixC55), .b_data_valid_ping(b_data_valid_ping_delay55), .b_data_valid_pong(b_data_valid_pong_delay55));
processing_element pe56(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a55to56), .in_b(b46to56), .in_c(matrixC46), .out_a(a56to57), .out_b(b56to66), .out_b0(b56to66_ping), .out_b1(b56to66_pong), .out_c(matrixC56), .b_data_valid_ping(b_data_valid_ping_delay56), .b_data_valid_pong(b_data_valid_pong_delay56));
processing_element pe57(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay12), .in_a(a56to57), .in_b(b47to57), .in_c(matrixC47), .out_a(a57to58), .out_b(b57to67), .out_b0(b57to67_ping), .out_b1(b57to67_pong), .out_c(matrixC57), .b_data_valid_ping(b_data_valid_ping_delay57), .b_data_valid_pong(b_data_valid_pong_delay57));

processing_element pe60(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay6), .in_a(a6),      .in_b(b50to60), .in_c(matrixC50), .out_a(a60to61), .out_b(b60to70), .out_b0(b60to70_ping), .out_b1(b60to70_pong), .out_c(matrixC60), .b_data_valid_ping(b_data_valid_ping_delay60), .b_data_valid_pong(b_data_valid_pong_delay60));
processing_element pe61(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a60to61), .in_b(b51to61), .in_c(matrixC51), .out_a(a61to62), .out_b(b61to71), .out_b0(b61to71_ping), .out_b1(b61to71_pong), .out_c(matrixC61), .b_data_valid_ping(b_data_valid_ping_delay61), .b_data_valid_pong(b_data_valid_pong_delay61));
processing_element pe62(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a61to62), .in_b(b52to62), .in_c(matrixC52), .out_a(a62to63), .out_b(b62to72), .out_b0(b62to72_ping), .out_b1(b62to72_pong), .out_c(matrixC62), .b_data_valid_ping(b_data_valid_ping_delay62), .b_data_valid_pong(b_data_valid_pong_delay62));
processing_element pe63(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a62to63), .in_b(b53to63), .in_c(matrixC53), .out_a(a63to64), .out_b(b63to73), .out_b0(b63to73_ping), .out_b1(b63to73_pong), .out_c(matrixC63), .b_data_valid_ping(b_data_valid_ping_delay63), .b_data_valid_pong(b_data_valid_pong_delay63));
processing_element pe64(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a63to64), .in_b(b54to64), .in_c(matrixC54), .out_a(a64to65), .out_b(b64to74), .out_b0(b64to74_ping), .out_b1(b64to74_pong), .out_c(matrixC64), .b_data_valid_ping(b_data_valid_ping_delay64), .b_data_valid_pong(b_data_valid_pong_delay64));
processing_element pe65(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a64to65), .in_b(b55to65), .in_c(matrixC55), .out_a(a65to66), .out_b(b65to75), .out_b0(b65to75_ping), .out_b1(b65to75_pong), .out_c(matrixC65), .b_data_valid_ping(b_data_valid_ping_delay65), .b_data_valid_pong(b_data_valid_pong_delay65));
processing_element pe66(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay12), .in_a(a65to66), .in_b(b56to66), .in_c(matrixC56), .out_a(a66to67), .out_b(b66to76), .out_b0(b66to76_ping), .out_b1(b66to76_pong), .out_c(matrixC66), .b_data_valid_ping(b_data_valid_ping_delay66), .b_data_valid_pong(b_data_valid_pong_delay66));
processing_element pe67(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay13), .in_a(a66to67), .in_b(b57to67), .in_c(matrixC57), .out_a(a67to68), .out_b(b67to77), .out_b0(b67to77_ping), .out_b1(b67to77_pong), .out_c(matrixC67), .b_data_valid_ping(b_data_valid_ping_delay67), .b_data_valid_pong(b_data_valid_pong_delay67));

processing_element pe70(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay7), .in_a(a7),      .in_b(b60to70), .in_c(matrixC60), .out_a(a70to71), .out_b(b70to80), .out_b0(b70to80_ping), .out_b1(b70to80_pong), .out_c(matrixC70), .b_data_valid_ping(b_data_valid_ping_delay70), .b_data_valid_pong(b_data_valid_pong_delay70));
processing_element pe71(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay8), .in_a(a70to71), .in_b(b61to71), .in_c(matrixC61), .out_a(a71to72), .out_b(b71to81), .out_b0(b71to81_ping), .out_b1(b71to81_pong), .out_c(matrixC71), .b_data_valid_ping(b_data_valid_ping_delay71), .b_data_valid_pong(b_data_valid_pong_delay71));
processing_element pe72(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay9), .in_a(a71to72), .in_b(b62to72), .in_c(matrixC62), .out_a(a72to73), .out_b(b72to82), .out_b0(b72to82_ping), .out_b1(b72to82_pong), .out_c(matrixC72), .b_data_valid_ping(b_data_valid_ping_delay72), .b_data_valid_pong(b_data_valid_pong_delay72));
processing_element pe73(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay10), .in_a(a72to73), .in_b(b63to73), .in_c(matrixC63), .out_a(a73to74), .out_b(b73to83), .out_b0(b73to83_ping), .out_b1(b73to83_pong), .out_c(matrixC73), .b_data_valid_ping(b_data_valid_ping_delay73), .b_data_valid_pong(b_data_valid_pong_delay73));
processing_element pe74(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay11), .in_a(a73to74), .in_b(b64to74), .in_c(matrixC64), .out_a(a74to75), .out_b(b74to84), .out_b0(b74to84_ping), .out_b1(b74to84_pong), .out_c(matrixC74), .b_data_valid_ping(b_data_valid_ping_delay74), .b_data_valid_pong(b_data_valid_pong_delay74));
processing_element pe75(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay12), .in_a(a74to75), .in_b(b65to75), .in_c(matrixC65), .out_a(a75to76), .out_b(b75to85), .out_b0(b75to85_ping), .out_b1(b75to85_pong), .out_c(matrixC75), .b_data_valid_ping(b_data_valid_ping_delay75), .b_data_valid_pong(b_data_valid_pong_delay75));
processing_element pe76(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay13), .in_a(a75to76), .in_b(b66to76), .in_c(matrixC66), .out_a(a76to77), .out_b(b76to86), .out_b0(b76to86_ping), .out_b1(b76to86_pong), .out_c(matrixC76), .b_data_valid_ping(b_data_valid_ping_delay76), .b_data_valid_pong(b_data_valid_pong_delay76));
processing_element pe77(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay14), .in_a(a76to77), .in_b(b67to77), .in_c(matrixC67), .out_a(a77to78), .out_b(b77to87), .out_b0(b77to87_ping), .out_b1(b77to87_pong), .out_c(matrixC77), .b_data_valid_ping(b_data_valid_ping_delay77), .b_data_valid_pong(b_data_valid_pong_delay77));

  
assign a_data_out = {a77to78, a67to68, a57to58, a47to48, a37to38, a27to28, a17to18, a07to08};
assign b_data_out = {b77to87, b76to86, b75to85, b74to84, b73to83, b72to82, b71to81, b70to80};

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
