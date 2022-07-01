`define MATMUL_SIZE_8 
`define MORE_TESTS
`define DESIGN_SIZE_8
`define SIMULATION
`define layer_test

`define DWIDTH 8
`define AWIDTH 11
`define MEM_SIZE 2048

`ifdef MATMUL_SIZE_4
`define MAT_MUL_SIZE 4
`define MASK_WIDTH 4
`define LOG2_MAT_MUL_SIZE 2
`endif

`ifdef MATMUL_SIZE_8
`define MAT_MUL_SIZE 8
`define MASK_WIDTH 8
`define LOG2_MAT_MUL_SIZE 3
`endif

`ifdef MATMUL_SIZE_16
`define MAT_MUL_SIZE 16
`define MASK_WIDTH 16
`define LOG2_MAT_MUL_SIZE 4
`endif

`ifdef MATMUL_SIZE_32
`define MAT_MUL_SIZE 32
`define MASK_WIDTH 32
`define LOG2_MAT_MUL_SIZE 5
`endif

`ifdef DESIGN_SIZE_4
`define DESIGN_SIZE 4
`define LOG2_DESIGN_SIZE 2
`endif

`ifdef DESIGN_SIZE_8
`define DESIGN_SIZE 8
`define LOG2_DESIGN_SIZE 3
`endif

`ifdef DESIGN_SIZE_16
`define DESIGN_SIZE 16
`define LOG2_DESIGN_SIZE 4
`endif

`ifdef DESIGN_SIZE_32
`define DESIGN_SIZE 32
`define LOG2_DESIGN_SIZE 5
`endif

`define BB_MAT_MUL_SIZE `MAT_MUL_SIZE
`define NUM_CYCLES_IN_MAC 3
`define MEM_ACCESS_LATENCY 1
`define REG_DATAWIDTH 32
`define REG_ADDRWIDTH 8
`define ADDR_STRIDE_WIDTH 8
`define MAX_BITS_POOL 3

/////////////////////////////////////////////////
//How to use fully-connected mode?
/////////////////////////////////////////////////
//TODO: See layer test and accum test and write documentation

/////////////////////////////////////////////////
//How to use convolution mode?
/////////////////////////////////////////////////

//Matrix A (input activation matrix)
//----------------------------------
//* This matrix is the non-expanded matrix (ie. this contains 
//  the same number of elements as the input activation tensor).
//  It doesn't contain the expanded GEMM M matrix corresponding
//  to this convolution.
//* This matrix is expected to have been padded though. That is,
//  if there are any padding rows/columns to be added, the software
//  should do that and store the padded matrix in the BRAM. 
//* Initial address of matrix A is to be programmed once in the
//  beginning of calculation of each output tile. We don't have 
//  to reprogram the address of A every time during accumulation.
//* The register containing stride of the matrix A is not used 
//  in convolution mode. Address strides for each read are determined
//  on the basis of C,R,S values internally in the RTL. This is because
//  strides are not fixed. They vary for every read.
//* This matrix is laid out in NCHW format. 

//Matrix B (weight matrix)
//----------------------------------
//* This matrix is the non-expanded matrix (ie. this contains 
//  the same number of elements as the weight tensor).
//  It doesn't contain the expanded GEMM N matrix corresponding
//  to this convolution.
//* There is no concept of padding for this matrix.
//* Initial address of matrix B is to be programmed once in the
//  beginning of calculation of each output tile. We don't have 
//  to reprogram the address of B every time during accumulation.
//* The register containing stride of the matrix B is not used
//  in the RTL. Address strides for each read are determined
//  on the basis of C,R,S values internally in the RTL. 
//* This matrix is laid out in NCHW format, but it is transposed.
//  So technically, the format is WHCN. 

//Matrix C (output activation matrix)
//----------------------------------
//* This matrix is the non-expanded matrix (ie. this contains 
//  the same number of elements as the output activation tensor).
//  It contains the GEMM matrix corresponding
//  to this convolution.
//* There is no concept of padding for this matrix.
//* Initial address of matrix C is to be programmed in the
//  beginning of calculation of each output tile. 
//  There is no concept of programming the address of C for 
//  accumulation. We write the matrix C only after all accumulations
//  have finished.
//* The register containing stride of the matrix C is not used
//  in the RTL. That is because the stride is known and is equal to
//  out_img_width * out_img_height, and RTL just uses that directly.
//* This matrix is laid out in NCHW format.

/////////////////////////////////////////////////
//Register specification
/////////////////////////////////////////////////
//---------------------------------------
//Addr 0 : Register with enables for various blocks. 
//Includes mode of operation (convolution or fully_connected)
//---------------------------------------
`define REG_ENABLES_ADDR 32'h0
//Bit 0: enable_matmul
//Bit 1: enable_norm
//Bit 2: enable_pool
//Bit 3: enable_activation
//Bit 31: enable_conv_mode

//---------------------------------------
//Addr 4: Register that triggers the whole TPU
//---------------------------------------
`define REG_STDN_TPU_ADDR 32'h4
//Bit 0: start_tpu
//Bit 31: done_tpu

//---------------------------------------
//Addr 8: Register that stores the mean of the values
//---------------------------------------
`define REG_MEAN_ADDR 32'h8
//Bit 7:0: mean

//---------------------------------------
//Addr A: Register that stores the inverse variance of the values
//---------------------------------------
`define REG_INV_VAR_ADDR 32'hA
//Bit 7:0: inv_var

//---------------------------------------
//Addr E: Register that stores the starting address of matrix A in BRAM A.
//In fully-connected mode, this register should be programmed with the
//address of the matrix being currently multiplied. That is, the 
//address of the matrix of the matmul. So, this register will be
//programmed every time the matmul is kicked off during accumulation stages.
//Use the STRIDE registers to tell the matmul to increment addresses.
//In convolution mode, this register should be programmed with the 
//address of the input activation matrix. No need to configure
//this every time the matmul is kicked off for accmulation. Just program it 
//once it the beginning. Address increments are handled automatically .
//---------------------------------------
`define REG_MATRIX_A_ADDR 32'he
//Bit `AWIDTH-1:0 address_mat_a

//---------------------------------------
//Addr 12: Register that stores the starting address of matrix B in BRAM B.
//See detailed note on the usage of this register in REG_MATRIX_A_ADDR.
//---------------------------------------
`define REG_MATRIX_B_ADDR 32'h12
//Bit `AWIDTH-1:0 address_mat_b

//---------------------------------------
//Addr 16: Register that stores the starting address of matrix C in BRAM C.
//See detailed note on the usage of this register in REG_MATRIX_A_ADDR.
//---------------------------------------
`define REG_MATRIX_C_ADDR 32'h16
//Bit `AWIDTH-1:0 address_mat_c



//---------------------------------------
//Addr 24: Register that controls the accumulation logic
//---------------------------------------
`define REG_ACCUM_ACTIONS_ADDR 32'h24
//Bit 0 save_output_to_accumulator
//Bit 1 add_accumulator_to_output

//---------------------------------------
//(Only applicable in fully-connected mode)
//Addr 28: Register that stores the stride that should be taken to address
//elements in matrix A, after every MAT_MUL_SIZE worth of data has been fetched.
//See the diagram in "Meeting-16" notes in the EE382V project Onenote notebook.
//This stride is applied when incrementing addresses for matrix A in the vertical
//direction.
//---------------------------------------
`define REG_MATRIX_A_STRIDE_ADDR 32'h28
//Bit `ADDR_STRIDE_WIDTH-1:0 address_stride_a

//---------------------------------------
//(Only applicable in fully-connected mode)
//Addr 32: Register that stores the stride that should be taken to address
//elements in matrix B, after every MAT_MUL_SIZE worth of data has been fetched.
//See the diagram in "Meeting-16" notes in the EE382V project Onenote notebook.
//This stride is applied when incrementing addresses for matrix B in the horizontal
//direction.
//---------------------------------------
`define REG_MATRIX_B_STRIDE_ADDR 32'h32
//Bit `ADDR_STRIDE_WIDTH-1:0 address_stride_b

//---------------------------------------
//(Only applicable in fully-connected mode)
//Addr 36: Register that stores the stride that should be taken to address
//elements in matrix C, after every MAT_MUL_SIZE worth of data has been fetched.
//See the diagram in "Meeting-16" notes in the EE382V project Onenote notebook.
//This stride is applied when incrementing addresses for matrix C in the vertical
//direction (this is generally same as address_stride_a).
//---------------------------------------
`define REG_MATRIX_C_STRIDE_ADDR 32'h36
//Bit `ADDR_STRIDE_WIDTH-1:0 address_stride_c

//---------------------------------------
//Addr 3A: Register that controls the activation block. Currently, the available 
//settings are the selector of activation function that will be used. There are
//two options: ReLU and TanH. To use ReLU, clear the LSB of this register. To
//use TanH, set the LSB of this register.
//---------------------------------------
`define REG_ACTIVATION_CSR_ADDR 32'h3A

//---------------------------------------
//Addr 3E: Register defining pooling window size
//---------------------------------------
`define REG_POOL_WINDOW_ADDR 32'h3E
//Bit `MAX_BITS_POOL-1:0 pool window size

//---------------------------------------
//Addr 40: Register defining convolution parameters - 1
//----------------------------------------
`define REG_CONV_PARAMS_1_ADDR 32'h40
//Bits filter_height (R) 3:0
//Bits filter width (S)  7:4
//Bits stride_horizontal 11:8
//Bits stride_vertical 15:12
//Bits pad_left 19:16
//Bits pad_right 23:20
//Bits pad_top 27:24
//Bits pad_bottom 31:28

//---------------------------------------
//Addr 44: Register defining convolution parameters - 2
//----------------------------------------
`define REG_CONV_PARAMS_2_ADDR 32'h44
//Bits num_channels_input (C) 15:0
//Bits num_channels_output (K) 31:16

//---------------------------------------
//Addr 48: Register defining convolution parameters - 3
//----------------------------------------
`define REG_CONV_PARAMS_3_ADDR 32'h48
//Bits input_image_height (H) 15:0
//Bits input_image_width (W) 31:16

//---------------------------------------
//Addr 4C: Register defining convolution parameters - 4
//----------------------------------------
`define REG_CONV_PARAMS_4_ADDR 32'h4C
//Bits output_image_height (P) 15:0
//Bits output_image_width (Q) 31:16

//---------------------------------------
//Addr 50: Register defining batch size
//----------------------------------------
`define REG_BATCH_SIZE_ADDR 32'h50
//Bits 31:0 batch_size (number of images, N)

//---------------------------------------
//Addresses 54,58,5C: Registers that stores the mask of which parts of the matrices are valid.
//
//Some examples where this is useful:
//1. Input matrix is smaller than the matmul. 
//   Say we want to multiply a 6x6 using an 8x8 matmul.
//   The matmul still operates on the whole 8x8 part, so we need
//   to ensure that there are 0s in the BRAMs in the invalid parts.
//   But the mask is used by the blocks other than matmul. For ex,
//   norm block will use the mask to avoid applying mean and variance 
//   to invalid parts (so tha they stay 0). 
//2. When we start with large matrices, the size of the matrices can
//   reduce to something less than the matmul size because of pooling.
//   In that case for the next layer, we need to tell blocks like norm,
//   what is valid and what is not.
//
//Note: This masks is applied to both x and y directions and also
//applied to both input matrices - A and B.
//---------------------------------------
`define REG_VALID_MASK_A_ROWS_ADDR 32'h20
`define REG_VALID_MASK_A_COLS_B_ROWS_ADDR 32'h54
`define REG_VALID_MASK_B_COLS_ADDR 32'h58
//Bit `MASK_WIDTH-1:0 validity_mask

//---------------------------------------
//Addr 60-64: Register defining number of design sized matrices 
//that the input matrices can be divided into.
//----------------------------------------
`define REG_NUM_MATRICES_A_ADDR 32'h60
`define REG_NUM_MATRICES_B_ADDR 32'h64

//---------------------------------------
//Addr 68: Register defining the pooling constants
//----------------------------------------
`define REG_POOLING_ACCUM_ADDR 32'h68

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
input [7:0] a_loc;
input [7:0] b_loc;

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
input [7:0] a_loc;
input [7:0] b_loc;

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

//////////////////////////////////
// Configuration Module
//////////////////////////////////

module cfg(
    input                             PCLK,
    input                             PRESETn,
    input        [`REG_ADDRWIDTH-1:0] PADDR,
    input                             PWRITE,
    input                             PSEL,
    input                             PENABLE,
    input        [`REG_DATAWIDTH-1:0] PWDATA,
    output reg   [`REG_DATAWIDTH-1:0] PRDATA,
    output reg                        PREADY,
    output reg start_tpu,
    output reg enable_matmul,
    output reg enable_norm,
    output reg enable_pool,
    output reg enable_activation,
    output reg enable_conv_mode,
    //TODO: We need to change the precision of compute to a larger 
    //number. For now, using the DWIDTH variable, but we need a 
    //HIGH_PRECISION_DWIDTH kind of thing
    output reg [`DWIDTH-1:0] mean,
    output reg [`DWIDTH-1:0] inv_var,
    output reg [`MAX_BITS_POOL-1:0] pool_window_size,
	output reg [`AWIDTH-1:0] address_mat_a,
    output reg [`AWIDTH-1:0] address_mat_b,
    output reg [`AWIDTH-1:0] address_mat_c,
    output reg [31:0] num_matrices_A,
    output reg [31:0] num_matrices_B,
    output reg [`DWIDTH-1:0] matrix_size,
    output reg [`DWIDTH-1:0] filter_size,
    output reg pool_select,
    output reg [`DWIDTH-1:0] k_dimension,
    output reg accum_select,
    output reg [`MASK_WIDTH-1:0] validity_mask_a_rows,
    output reg [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows,
    output reg [`MASK_WIDTH-1:0] validity_mask_b_cols,
    output reg save_output_to_accum,
    output reg add_accum_to_output,
    output reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_a,
    output reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_b,
    output reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_c,
    output reg activation_type,
    output reg [3:0] conv_filter_height,
    output reg [3:0] conv_filter_width,
    output reg [3:0] conv_stride_horiz,
    output reg [3:0] conv_stride_verti,
    output reg [3:0] conv_padding_left,
    output reg [3:0] conv_padding_right,
    output reg [3:0] conv_padding_top,
    output reg [3:0] conv_padding_bottom,
    output reg [15:0] num_channels_inp,
    output reg [15:0] num_channels_out,
    output reg [15:0] inp_img_height,
    output reg [15:0] inp_img_width,
    output reg [15:0] out_img_height,
    output reg [15:0] out_img_width,
    output reg [31:0] batch_size,
    output reg pe_reset,
    input done_tpu
);

//Dummy register to sync all other invalid/unimplemented addresses
reg [`REG_DATAWIDTH-1:0] reg_dummy;


//////////////////////////////////////////////////////
//Using a simple APB interface. Taken from:
// https://github.com/maomran/APB-Slave
// https://research.ijcaonline.org/volume95/number21/pxc3897047.pdf

reg [1:0] State;
`define IDLE     2'b00
`define W_ENABLE  2'b01
`define R_ENABLE  2'b10

always @(posedge PCLK) begin
  if (PRESETn == 0) begin
    State <= `IDLE;
    PRDATA <= 0;
    PREADY <= 0;
    start_tpu <= 0;
    enable_matmul <= 0;
    enable_norm <= 0;
    enable_pool <= 0;
    enable_activation <= 0;
    mean <= 0;
    inv_var <= 0;
    pool_window_size <= 1;
		reg_dummy <= 0;
    address_mat_a <= 0;
    address_mat_b <= 0;
    address_mat_c <= 0;
    num_matrices_A <= 1;
    num_matrices_B <= 1;
    matrix_size <= 8;
    filter_size <= 2;
    pool_select <= 0;
    k_dimension <= 8;
    accum_select <= 1;
    validity_mask_a_rows <= {`MASK_WIDTH{1'b1}};
    validity_mask_a_cols_b_rows <= {`MASK_WIDTH{1'b1}};
    validity_mask_b_cols <= {`MASK_WIDTH{1'b1}};
    save_output_to_accum <= 0;
    add_accum_to_output <= 0;
    address_stride_a <= 1;
    address_stride_b <= 1;
    address_stride_c <= 1;
    activation_type <= 1;
    conv_filter_height <= 2;
    conv_filter_width  <= 2;
    conv_stride_horiz  <= 1;
    conv_stride_verti  <= 1;
    conv_padding_left  <= 0;
    conv_padding_right <= 0;
    conv_padding_top   <= 0;
    conv_padding_bottom<= 0;
    num_channels_inp <= 4;
    num_channels_out <= 4;
    inp_img_height   <= 8;
    inp_img_width    <= 8;
    out_img_height   <= 7;
    out_img_width    <= 7;
    batch_size       <= 2;
    enable_conv_mode <= 0;
    pe_reset <= 0;
  end

  else begin
    case (State)
      `IDLE : begin
        PRDATA <= 0;
        if (PSEL) begin
          if (PWRITE) begin
            State <= `W_ENABLE;
          end
          else begin
            State <= `R_ENABLE;
          end
        end
        PREADY <= 0;
        pe_reset <= 0; //this register bit auto resets itself
      end

      `W_ENABLE : begin
        if (PSEL && PWRITE && PENABLE) begin
          case (PADDR)
          `REG_ENABLES_ADDR   : begin 
                                enable_conv_mode  <= PWDATA[31];
                                enable_activation <= PWDATA[3];
                                enable_pool       <= PWDATA[2];
                                enable_norm       <= PWDATA[1];
                                enable_matmul     <= PWDATA[0];
                                end
          `REG_STDN_TPU_ADDR  : begin
                                start_tpu <= PWDATA[0];
                                pe_reset <= PWDATA[15]; 
                                end
          `REG_MEAN_ADDR      : mean <= PWDATA[`DWIDTH-1:0];
          `REG_INV_VAR_ADDR   : inv_var <= PWDATA[`DWIDTH-1:0];
          `REG_MATRIX_A_ADDR  : address_mat_a <= PWDATA[`AWIDTH-1:0];
          `REG_MATRIX_B_ADDR  : address_mat_b <= PWDATA[`AWIDTH-1:0];
          `REG_MATRIX_C_ADDR  : address_mat_c <= PWDATA[`AWIDTH-1:0];
          `REG_VALID_MASK_A_ROWS_ADDR: begin
                                validity_mask_a_rows <= PWDATA[`MASK_WIDTH-1:0];
                                end
          `REG_VALID_MASK_A_COLS_B_ROWS_ADDR: begin
                                validity_mask_a_cols_b_rows <= PWDATA[`MASK_WIDTH-1:0];
                                end
          `REG_VALID_MASK_B_COLS_ADDR: begin
                                validity_mask_b_cols <= PWDATA[`MASK_WIDTH-1:0];
                                end
          `REG_POOL_WINDOW_ADDR: pool_window_size <= PWDATA[`MAX_BITS_POOL-1:0];
					`REG_ACCUM_ACTIONS_ADDR: begin
                                   add_accum_to_output <= PWDATA[1];
                                   save_output_to_accum <= PWDATA[0];
                                   end
          `REG_MATRIX_A_STRIDE_ADDR : address_stride_a <= PWDATA[`ADDR_STRIDE_WIDTH-1:0];
          `REG_MATRIX_B_STRIDE_ADDR : address_stride_b <= PWDATA[`ADDR_STRIDE_WIDTH-1:0];
          `REG_MATRIX_C_STRIDE_ADDR : address_stride_c <= PWDATA[`ADDR_STRIDE_WIDTH-1:0];
          `REG_ACTIVATION_CSR_ADDR  : activation_type  <= PWDATA[0];
          `REG_CONV_PARAMS_1_ADDR   : begin
                                      conv_filter_height <= PWDATA[3:0]; 
                                      conv_filter_width  <= PWDATA[7:4];
                                      conv_stride_horiz  <= PWDATA[11:8];
                                      conv_stride_verti  <= PWDATA[15:12];
                                      conv_padding_left  <= PWDATA[19:16];
                                      conv_padding_right <= PWDATA[23:20];
                                      conv_padding_top   <= PWDATA[27:24];
                                      conv_padding_bottom<= PWDATA[31:28];
                                      end
          `REG_CONV_PARAMS_2_ADDR   : begin
                                      num_channels_inp <= PWDATA[15:0];
                                      num_channels_out <= PWDATA[31:16];
                                      end
          `REG_CONV_PARAMS_3_ADDR   : begin
                                      inp_img_height   <= PWDATA[15:0];
                                      inp_img_width    <= PWDATA[31:16];
                                      end
          `REG_CONV_PARAMS_4_ADDR   : begin
                                      out_img_height   <= PWDATA[15:0];
                                      out_img_width    <= PWDATA[31:16];
                                      end
          `REG_BATCH_SIZE_ADDR      : batch_size <= PWDATA[31:0];
          `REG_NUM_MATRICES_A_ADDR	: num_matrices_A <= PWDATA[31:0];
          `REG_NUM_MATRICES_B_ADDR	: num_matrices_B <= PWDATA[31:0];
          `REG_POOLING_ACCUM_ADDR	: begin
          							  pool_select <= PWDATA[0];
          							  filter_size <= PWDATA[8:1];
          							  matrix_size <= PWDATA[16:9];
          							  k_dimension <= PWDATA[24:17];
          							  accum_select <= PWDATA[25];
          							  end
          default: reg_dummy <= PWDATA; //sink writes to a dummy register
          endcase
          PREADY <=1;          
        end
        State <= `IDLE;
      end

      `R_ENABLE : begin
        if (PSEL && !PWRITE && PENABLE) begin
          PREADY <= 1;
          case (PADDR)
          `REG_ENABLES_ADDR   : PRDATA <= {28'b0, enable_activation, enable_pool, enable_norm, enable_matmul};
          `REG_STDN_TPU_ADDR  : PRDATA <= {done_tpu, 30'b0, start_tpu};
          `REG_MEAN_ADDR      : PRDATA <= mean;
          `REG_INV_VAR_ADDR   : PRDATA <= inv_var;
          `REG_MATRIX_A_ADDR  : PRDATA <= address_mat_a;
          `REG_MATRIX_B_ADDR  : PRDATA <= address_mat_b;
          `REG_MATRIX_C_ADDR  : PRDATA <= address_mat_c;
          `REG_VALID_MASK_A_ROWS_ADDR: PRDATA <= validity_mask_a_rows;
          `REG_VALID_MASK_A_COLS_B_ROWS_ADDR: PRDATA <= validity_mask_a_cols_b_rows;
          `REG_VALID_MASK_B_COLS_ADDR: PRDATA <= validity_mask_b_cols;
          `REG_POOL_WINDOW_ADDR : PRDATA <= pool_window_size;
					`REG_ACCUM_ACTIONS_ADDR: PRDATA <= {30'b0, add_accum_to_output, save_output_to_accum};
          `REG_MATRIX_A_STRIDE_ADDR : PRDATA <= address_stride_a;
          `REG_MATRIX_B_STRIDE_ADDR : PRDATA <= address_stride_b;
          `REG_MATRIX_C_STRIDE_ADDR : PRDATA <= address_stride_c;
          `REG_ACTIVATION_CSR_ADDR  : PRDATA <= {31'b0, activation_type};
          `REG_CONV_PARAMS_1_ADDR   : PRDATA <= {
                                      conv_filter_height,
                                      conv_filter_width,  
                                      conv_stride_horiz, 
                                      conv_stride_verti,  
                                      conv_padding_left,  
                                      conv_padding_right, 
                                      conv_padding_top,   
                                      conv_padding_bottom
                                      };
          `REG_CONV_PARAMS_2_ADDR   : PRDATA <= {
                                      num_channels_inp,
                                      num_channels_out
                                      };
          `REG_CONV_PARAMS_3_ADDR   : PRDATA <= {
                                      inp_img_height,
                                      inp_img_width 
                                      };
          `REG_CONV_PARAMS_4_ADDR   : PRDATA <= {
                                      out_img_height,
                                      out_img_width
                                      };
          `REG_BATCH_SIZE_ADDR      : PRDATA <= batch_size;
          `REG_NUM_MATRICES_A_ADDR	: PRDATA <= num_matrices_A;
          `REG_NUM_MATRICES_B_ADDR	: PRDATA <= num_matrices_B;
          `REG_POOLING_ACCUM_ADDR	: PRDATA <= {6'b0, accum_select, k_dimension, matrix_size, filter_size, pool_select};
          default             : PRDATA <= reg_dummy; //read the dummy register for undefined addresses
          endcase
        end
        State <= `IDLE;
      end
      default: begin
        State <= `IDLE;
      end
    endcase
  end
end 

endmodule

//////////////////////////////////
// Normalisation Module
//////////////////////////////////

module norm(
    input enable_norm,
    input enable_pool,
    input [`DWIDTH-1:0] mean,
    input [`DWIDTH-1:0] inv_var,
    input in_data_available,
    input [`DWIDTH-1:0] inp_data0,
    input [`DWIDTH-1:0] inp_data1,
    input [`DWIDTH-1:0] inp_data2,
    input [`DWIDTH-1:0] inp_data3,
    input [`DWIDTH-1:0] inp_data4,
    input [`DWIDTH-1:0] inp_data5,
    input [`DWIDTH-1:0] inp_data6,
    input [`DWIDTH-1:0] inp_data7,
    output [`DWIDTH-1:0] out_data0,
    output [`DWIDTH-1:0] out_data1,
    output [`DWIDTH-1:0] out_data2,
    output [`DWIDTH-1:0] out_data3,
    output [`DWIDTH-1:0] out_data4,
    output [`DWIDTH-1:0] out_data5,
    output [`DWIDTH-1:0] out_data6,
    output [`DWIDTH-1:0] out_data7,
    output out_data_available,
    input [`MASK_WIDTH-1:0] validity_mask,
    output done_norm,
    input clk,
    input reset
);

reg in_data_available1;
reg in_data_available2;
reg in_data_available3;
reg in_data_available4;
reg in_data_available5;
reg in_data_available6;
reg in_data_available7;

always @(posedge clk) begin
	in_data_available1 <= in_data_available;
	in_data_available2 <= in_data_available1;
	in_data_available3 <= in_data_available2;
	in_data_available4 <= in_data_available3;
	in_data_available5 <= in_data_available4;
	in_data_available6 <= in_data_available5;
	in_data_available7 <= in_data_available6;	
end

assign out_data_available = (enable_norm) ? out_data_available_internal : in_data_available;

wire out_data_available_internal;
wire out_data_available_NC;
wire out_data_available_final;

reg [`DWIDTH-1:0] done_count;
reg done_norm;

always @(posedge clk) begin
	if (reset) begin
		done_norm <= 0;
		done_count <= 0;
	end
	if (done_count == 4) begin
		done_norm <= 1;
	end
	if (out_data_available_final == 1) begin
		done_count <= done_count + 1;
	end
end
	
norm_sub norm0(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available),
    .inp_data(inp_data0),
    .out_data(out_data0),
    .out_data_available(out_data_available_internal),
    .validity_mask(validity_mask[0]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm1(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available1),
    .inp_data(inp_data1),
    .out_data(out_data1),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[1]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm2(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available2),
    .inp_data(inp_data2),
    .out_data(out_data2),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[2]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm3(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available3),
    .inp_data(inp_data3),
    .out_data(out_data3),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[3]),
    .clk(clk),
    .reset(reset)
);
norm_sub norm4(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available4),
    .inp_data(inp_data4),
    .out_data(out_data4),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[4]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm5(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available5),
    .inp_data(inp_data5),
    .out_data(out_data5),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[5]),
    .clk(clk),
    .reset(reset)
);
norm_sub norm6(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available6),
    .inp_data(inp_data6),
    .out_data(out_data6),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[6]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm7(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available7),
    .inp_data(inp_data7),
    .out_data(out_data7),
    .out_data_available(out_data_available_final),
    .validity_mask(validity_mask[7]),
    .clk(clk),
    .reset(reset)
);

endmodule

module norm_sub(
	input enable_norm,
    input [`DWIDTH-1:0] mean,
    input [`DWIDTH-1:0] inv_var,
    input in_data_available,
    input [`DWIDTH-1:0] inp_data,
    output [`DWIDTH-1:0] out_data,
    output out_data_available,
    input  validity_mask,
    input clk,
    input reset
);

reg out_data_available_internal;
wire [`DWIDTH-1:0] out_data_internal;
reg [`DWIDTH-1:0] mean_applied_data;
reg [`DWIDTH-1:0] variance_applied_data;
reg norm_in_progress;

//Muxing logic to handle the case when this block is disabled
assign out_data_available = (enable_norm) ? out_data_available_internal : in_data_available;
assign out_data = (enable_norm) ? out_data_internal : inp_data;

integer i;
always @(posedge clk) begin
    if ((reset || ~enable_norm)) begin
        mean_applied_data <= 0;
        variance_applied_data <= 0;
    end else if (in_data_available||norm_in_progress) begin
        //Let's apply mean and variance as the input data comes in.
        //We have a pipeline here. First stage does the add (to apply the mean)
        //and second stage does the multiplication (to apply the variance).
        //Note: the following loop is not a loop across multiple columns of data.
        //This loop will run in 2 cycle on the same column of data that comes into 
        //this module in 1 clock.
        if (validity_mask == 1'b1) begin
            mean_applied_data <= (inp_data - mean);
            variance_applied_data <= (mean_applied_data * inv_var);
        end 
        else begin
            mean_applied_data <= (inp_data);
            variance_applied_data <= (mean_applied_data);
        end
    end
    else begin
        mean_applied_data <= 0;
        variance_applied_data <= 0;
    end
end

//The data is normalized in two cycles so we are shifting in_data_available by 2 to generate out_data_available
always @(posedge clk) begin
	norm_in_progress <= in_data_available;
	out_data_available_internal <= norm_in_progress;
end

assign out_data_internal = variance_applied_data;

endmodule

//////////////////////////////////
// Dual port RAM
//////////////////////////////////

module ram (
        addr0, 
        d0, 
        we0, 
        q0,  
        addr1,
        d1,
        we1,
        q1,
        clk);
  
parameter AW = 11;
parameter MW = 8;
parameter DW = 8;

input [AW-1:0] addr0;
input [AW-1:0] addr1;
input [MW*DW-1:0] d0;
input [MW*DW-1:0] d1;
input [MW-1:0] we0;
input [MW-1:0] we1;
output reg [MW*DW-1:0] q0;
output reg [MW*DW-1:0] q1;
input clk;

`ifdef VCS
reg [MW*DW-1:0] ram[((1 << AW)-1):0];
integer i;
  
wire we0_coalesced;
assign we0_coalesced = |we0;
wire we1_coalesced;
assign we1_coalesced = |we1;

always @(posedge clk) begin 
    if (we0_coalesced) ram[addr0] <= d0; 
    q0 <= ram[addr0];    
end

always @(posedge clk) begin 
    if (we1_coalesced) ram[addr1] <= d1; 
    q1 <= ram[addr1];  
end
  
`else

/*
dual_port_ram u_dual_port_ram(
.addr1(addr0),
.we1(we0_coalesced),
.data1(d0),
.out1(q0),
.addr2(addr1),
.we2(we1_coalesced),
.data2(d1),
.out2(q1),
.clk(clk)
);
*/

`endif


endmodule //Top level state machine

//////////////////////////////////
// Control Signal Generation
//////////////////////////////////

module control(
    input clk,
    input reset,
    input start_tpu,
    input enable_matmul,
    input enable_norm,
    input enable_activation,
    input enable_pool,
    output reg start_mat_mul,
    input done_mat_mul,
    input done_norm,
    input done_pool,
    input done_activation,
    input save_output_to_accum,
    output reg done_tpu
);

reg [3:0] state;

`define STATE_INIT         4'b0000
`define STATE_MATMUL       4'b0001
`define STATE_NORM         4'b0010
`define STATE_POOL         4'b0011
`define STATE_ACTIVATION   4'b0100
`define STATE_DONE         4'b0101

//////////////////////////////////////////////////////
// Assumption: We will always run matmul first. That is, matmul is not optional. 
//             The other blocks - norm, act, pool - are optional.
// Assumption: Order is fixed: Matmul -> Norm -> Pool -> Activation
//////////////////////////////////////////////////////

always @( posedge clk) begin
    if (reset) begin
      state <= `STATE_INIT;
      start_mat_mul <= 1'b0;
      done_tpu <= 1'b0;
    end else begin
      case (state)
      `STATE_INIT: begin
        if ((start_tpu == 1'b1) && (done_tpu == 1'b0)) begin
          if (enable_matmul == 1'b1) begin
            start_mat_mul <= 1'b1;
            state <= `STATE_MATMUL;
          end  
        end  
      end
      
      //start_mat_mul is kinda used as a reset in some logic
      //inside the matmul unit. So, we can't make it 0 right away after
      //asserting it.
      `STATE_MATMUL: begin
        if (done_mat_mul == 1'b1) begin
            start_mat_mul <= 1'b0;
            if(save_output_to_accum) begin
              state <= `STATE_DONE;
            end
            else if (enable_norm) begin
              state <= `STATE_NORM;
            end 
            else if (enable_pool) begin
              state <= `STATE_POOL;
            end
            else if (enable_activation) begin
              state <= `STATE_ACTIVATION;
            end
            else begin
              state <= `STATE_DONE;
            end  
        end 
        else begin
          start_mat_mul <= 1'b1;	      
        end
      end      
      
      `STATE_NORM: begin                 
        if (done_norm == 1'b1) begin
          if (enable_pool) begin
            state <= `STATE_POOL;
          end
          else if (enable_activation) begin
            state <= `STATE_ACTIVATION;
          end
          else begin
            state <= `STATE_DONE;
          end
        end
      end

      `STATE_POOL: begin                 
        if (done_pool == 1'b1) begin
          if (enable_activation) begin
            state <= `STATE_ACTIVATION;
          end
          else begin
            state <= `STATE_DONE;
          end
        end
      end

      `STATE_ACTIVATION: begin                 
        if (done_activation == 1'b1) begin
          state <= `STATE_DONE;
        end
      end

      `STATE_DONE: begin
        //We need to write start_tpu to 0 in the CFG block to get out of this state
        if (start_tpu == 1'b0) begin
          state <= `STATE_INIT;
          done_tpu <= 0;
        end
        else begin
          done_tpu <= 1;
        end
      end
      endcase  
    end 
end
endmodule

//////////////////////////////////
// Accumulator Module
//////////////////////////////////

module accumulator (
    clk,
    resetn,
    start_waddr_accum0,
    start_waddr_accum1,
    start_waddr_accum2,
    start_waddr_accum3,
    start_waddr_accum4,
    start_waddr_accum5,
    start_waddr_accum6,
    start_waddr_accum7,
    wdata_accum0,
    wdata_accum1,
    wdata_accum2,
    wdata_accum3,
    wdata_accum4,
    wdata_accum5,
    wdata_accum6,
    wdata_accum7,
    raddr_accum0_matmul,
    raddr_accum1_matmul,
    raddr_accum2_matmul,
    raddr_accum3_matmul,
    raddr_accum4_matmul,
    raddr_accum5_matmul,
    raddr_accum6_matmul,
    raddr_accum7_matmul,
    raddr_accum0_pool,
    raddr_accum1_pool,
    raddr_accum2_pool,
    raddr_accum3_pool,
    raddr_accum4_pool,
    raddr_accum5_pool,
    raddr_accum6_pool,
    raddr_accum7_pool,
    rdata_accum0,
    rdata_accum1,
    rdata_accum2,
    rdata_accum3,
    rdata_accum4,
    rdata_accum5,
    rdata_accum6,
    rdata_accum7,
    rdata_accum0_pool,
    rdata_accum1_pool,
    rdata_accum2_pool,
    rdata_accum3_pool,
    rdata_accum4_pool,
    rdata_accum5_pool,
    rdata_accum6_pool,
    rdata_accum7_pool,
    wdata_available,
    k_dimension,
    buffer_select,
    start_pooling,
    done_pooling
);

input clk;
input resetn;
input [`AWIDTH-1:0] start_waddr_accum0;
input [`AWIDTH-1:0] start_waddr_accum1;
input [`AWIDTH-1:0] start_waddr_accum2;
input [`AWIDTH-1:0] start_waddr_accum3;
input [`AWIDTH-1:0] start_waddr_accum4;
input [`AWIDTH-1:0] start_waddr_accum5;
input [`AWIDTH-1:0] start_waddr_accum6;
input [`AWIDTH-1:0] start_waddr_accum7;
input [`DWIDTH-1:0] wdata_accum0;
input [`DWIDTH-1:0] wdata_accum1;
input [`DWIDTH-1:0] wdata_accum2;
input [`DWIDTH-1:0] wdata_accum3;
input [`DWIDTH-1:0] wdata_accum4;
input [`DWIDTH-1:0] wdata_accum5;
input [`DWIDTH-1:0] wdata_accum6;
input [`DWIDTH-1:0] wdata_accum7;
input [`AWIDTH-1:0] raddr_accum0_matmul;
input [`AWIDTH-1:0] raddr_accum1_matmul;
input [`AWIDTH-1:0] raddr_accum2_matmul;
input [`AWIDTH-1:0] raddr_accum3_matmul;
input [`AWIDTH-1:0] raddr_accum4_matmul;
input [`AWIDTH-1:0] raddr_accum5_matmul;
input [`AWIDTH-1:0] raddr_accum6_matmul;
input [`AWIDTH-1:0] raddr_accum7_matmul;
input [`AWIDTH-1:0] raddr_accum0_pool;
input [`AWIDTH-1:0] raddr_accum1_pool;
input [`AWIDTH-1:0] raddr_accum2_pool;
input [`AWIDTH-1:0] raddr_accum3_pool;
input [`AWIDTH-1:0] raddr_accum4_pool;
input [`AWIDTH-1:0] raddr_accum5_pool;
input [`AWIDTH-1:0] raddr_accum6_pool;
input [`AWIDTH-1:0] raddr_accum7_pool;
output [`DWIDTH-1:0] rdata_accum0;
output [`DWIDTH-1:0] rdata_accum1;
output [`DWIDTH-1:0] rdata_accum2;
output [`DWIDTH-1:0] rdata_accum3;
output [`DWIDTH-1:0] rdata_accum4;
output [`DWIDTH-1:0] rdata_accum5;
output [`DWIDTH-1:0] rdata_accum6;
output [`DWIDTH-1:0] rdata_accum7;
output [`DWIDTH-1:0] rdata_accum0_pool;
output [`DWIDTH-1:0] rdata_accum1_pool;
output [`DWIDTH-1:0] rdata_accum2_pool;
output [`DWIDTH-1:0] rdata_accum3_pool;
output [`DWIDTH-1:0] rdata_accum4_pool;
output [`DWIDTH-1:0] rdata_accum5_pool;
output [`DWIDTH-1:0] rdata_accum6_pool;
output [`DWIDTH-1:0] rdata_accum7_pool;
input wdata_available;
input [7:0] k_dimension; // Number of columns in Matrix A | Number of rows in Matrix B (Assumption: Maximum = 256, can be changed accordingly)
input buffer_select;
output start_pooling;
output done_pooling;
  

parameter MWIDTH = 1;

reg wdata_available1;
reg wdata_available2;
reg wdata_available3;
reg wdata_available4;
reg wdata_available5;
reg wdata_available6;
reg wdata_available7;

always @ (posedge clk) begin
    wdata_available1 <= wdata_available;
    wdata_available2 <= wdata_available1;
    wdata_available3 <= wdata_available2;
    wdata_available4 <= wdata_available3;
    wdata_available5 <= wdata_available4;
    wdata_available6 <= wdata_available5;
    wdata_available7 <= wdata_available6;
end

wire wdata_en_ping0;
wire wdata_en_ping1;
wire wdata_en_ping2;
wire wdata_en_ping3;
wire wdata_en_ping4;
wire wdata_en_ping5;
wire wdata_en_ping6;
wire wdata_en_ping7;
wire wdata_en_pong0;
wire wdata_en_pong1;
wire wdata_en_pong2;
wire wdata_en_pong3;
wire wdata_en_pong4;
wire wdata_en_pong5;
wire wdata_en_pong6;
wire wdata_en_pong7;

assign wdata_en_ping0 = wdata_available & buffer_select;
assign wdata_en_ping1 = wdata_available1 & buffer_select;
assign wdata_en_ping2 = wdata_available2 & buffer_select;
assign wdata_en_ping3 = wdata_available3 & buffer_select;
assign wdata_en_ping4 = wdata_available4 & buffer_select;
assign wdata_en_ping5 = wdata_available5 & buffer_select;
assign wdata_en_ping6 = wdata_available6 & buffer_select;
assign wdata_en_ping7 = wdata_available7 & buffer_select;

assign wdata_en_pong0 = wdata_available & ~buffer_select;
assign wdata_en_pong1 = wdata_available1 & ~buffer_select;
assign wdata_en_pong2 = wdata_available2 & ~buffer_select;
assign wdata_en_pong3 = wdata_available3 & ~buffer_select;
assign wdata_en_pong4 = wdata_available4 & ~buffer_select;
assign wdata_en_pong5 = wdata_available5 & ~buffer_select;
assign wdata_en_pong6 = wdata_available6 & ~buffer_select;
assign wdata_en_pong7 = wdata_available7 & ~buffer_select;

reg [7:0] addr_counter;
reg [`AWIDTH-1:0] waddr_accum0;
reg [`AWIDTH-1:0] waddr_accum1;
reg [`AWIDTH-1:0] waddr_accum2;
reg [`AWIDTH-1:0] waddr_accum3;
reg [`AWIDTH-1:0] waddr_accum4;
reg [`AWIDTH-1:0] waddr_accum5;
reg [`AWIDTH-1:0] waddr_accum6;
reg [`AWIDTH-1:0] waddr_accum7;
reg add_accum_mux0;
reg add_accum_mux1;
reg add_accum_mux2;
reg add_accum_mux3;
reg add_accum_mux4;
reg add_accum_mux5;
reg add_accum_mux6;
reg add_accum_mux7;

always @ (posedge clk) begin
    if (~wdata_available | (addr_counter == (k_dimension-1))) begin
        add_accum_mux0 <= 0;
        addr_counter <= 0;
    end
    else if (addr_counter == (`MAT_MUL_SIZE-1) & k_dimension != `MAT_MUL_SIZE) begin
        add_accum_mux0 <= 1;
        addr_counter <= addr_counter + 1;
    end
    else if (wdata_available)
        addr_counter <= addr_counter + 1;
end

reg start_pooling;
reg done_pooling;
reg [7:0] start_pooling_count;
always @ (posedge clk) begin
    if (~resetn)
        start_pooling <= 0;
    else if (start_pooling_count > 8'd14) begin
    	start_pooling <= 0;
    	done_pooling <= 1;
    end
    else if (waddr_accum2 != 0 & wdata_available2 == 0)
        start_pooling <= 1;
end
  
always @ (posedge clk) begin
    if (~resetn)
        start_pooling_count <= 0;
    else if (start_pooling)
        start_pooling_count <= start_pooling_count + 1;
end

reg buffer_select_accum;
wire buffer_select_pool;
reg start_pooling_d1;

always @ (posedge clk) begin
	if (buffer_select_pool)
		buffer_select_accum <= 0;
	else
		buffer_select_accum <= 1;
end

always @ (posedge clk) begin
	start_pooling_d1 <= start_pooling;
end

assign buffer_select_pool = start_pooling | start_pooling_d1;

always @ (posedge clk) begin
    add_accum_mux1 <= add_accum_mux0;
    add_accum_mux2 <= add_accum_mux1;
    add_accum_mux3 <= add_accum_mux2;
    add_accum_mux4 <= add_accum_mux3;
    add_accum_mux5 <= add_accum_mux4;
    add_accum_mux6 <= add_accum_mux5;
    add_accum_mux7 <= add_accum_mux6;
end
  
reg [7:0] waddr_kdim;
  
always @ (posedge clk) begin
    if (~resetn) 
        waddr_accum0 <= start_waddr_accum0;
    else if (((addr_counter & (`MAT_MUL_SIZE-1)) == (`MAT_MUL_SIZE-1)) & (waddr_kdim > 1)) begin
        waddr_accum0 <= waddr_accum0 - (`MAT_MUL_SIZE -1);
    end
    else if (wdata_available) 
        waddr_accum0 <= waddr_accum0 + 1;
end
  
always @ (posedge clk) begin
    if (~resetn | (((addr_counter & (`MAT_MUL_SIZE-1)) == (`MAT_MUL_SIZE-1)) & (waddr_kdim == 1))) begin
        waddr_kdim <= k_dimension >> `LOG2_MAT_MUL_SIZE;
    end
    else if (((addr_counter & (`MAT_MUL_SIZE-1)) == (`MAT_MUL_SIZE-1)) & (waddr_kdim > 1)) begin
        waddr_kdim <= waddr_kdim - 1;
    end
end
  
always @ (posedge clk) begin
    waddr_accum1 <= waddr_accum0;
    waddr_accum2 <= waddr_accum1;
    waddr_accum3 <= waddr_accum2;
    waddr_accum4 <= waddr_accum3;
    waddr_accum5 <= waddr_accum4;
    waddr_accum6 <= waddr_accum5;
    waddr_accum7 <= waddr_accum6;
end
   
// Data going into the Accumulator Adders
wire [`DWIDTH-1:0] wdata_accum0_in;
wire [`DWIDTH-1:0] wdata_accum1_in;
wire [`DWIDTH-1:0] wdata_accum2_in;
wire [`DWIDTH-1:0] wdata_accum3_in;
wire [`DWIDTH-1:0] wdata_accum4_in;
wire [`DWIDTH-1:0] wdata_accum5_in;
wire [`DWIDTH-1:0] wdata_accum6_in;
wire [`DWIDTH-1:0] wdata_accum7_in;

// Data written into the PING Accumulators
wire [`DWIDTH-1:0] wdata_accum0_ping;
wire [`DWIDTH-1:0] wdata_accum1_ping;
wire [`DWIDTH-1:0] wdata_accum2_ping;
wire [`DWIDTH-1:0] wdata_accum3_ping;
wire [`DWIDTH-1:0] wdata_accum4_ping;
wire [`DWIDTH-1:0] wdata_accum5_ping;
wire [`DWIDTH-1:0] wdata_accum6_ping;
wire [`DWIDTH-1:0] wdata_accum7_ping;
    
// Based on the Accumulator Adder MUX select signal either 0 or data read from the RAM goes into the Adder
assign wdata_accum0_in = (~add_accum_mux0)?  8'b0 : rdata_accum0;
assign wdata_accum1_in = (~add_accum_mux1)?  8'b0 : rdata_accum1;
assign wdata_accum2_in = (~add_accum_mux2)?  8'b0 : rdata_accum2;
assign wdata_accum3_in = (~add_accum_mux3)?  8'b0 : rdata_accum3;
assign wdata_accum4_in = (~add_accum_mux4)?  8'b0 : rdata_accum4;
assign wdata_accum5_in = (~add_accum_mux5)?  8'b0 : rdata_accum5;
assign wdata_accum6_in = (~add_accum_mux6)?  8'b0 : rdata_accum6;
assign wdata_accum7_in = (~add_accum_mux7)?  8'b0 : rdata_accum7;
  
reg [`AWIDTH-1:0] raddr_accum0;
reg [`AWIDTH-1:0] raddr_accum1;
reg [`AWIDTH-1:0] raddr_accum2;
reg [`AWIDTH-1:0] raddr_accum3;
reg [`AWIDTH-1:0] raddr_accum4;
reg [`AWIDTH-1:0] raddr_accum5;
reg [`AWIDTH-1:0] raddr_accum6;
reg [`AWIDTH-1:0] raddr_accum7;
  
// Start reading the address written to after 7 clock cycles to calculate partial sums
always @ (posedge clk) begin
    raddr_accum0 <= waddr_accum6; // waddr_accum6 = (waddr_accum0 delayed by 6 clock cycles)
    raddr_accum1 <= raddr_accum0;
    raddr_accum2 <= raddr_accum1;
    raddr_accum3 <= raddr_accum2;
    raddr_accum4 <= raddr_accum3;
    raddr_accum5 <= raddr_accum4;
    raddr_accum6 <= raddr_accum5;
    raddr_accum7 <= raddr_accum6;
end
  
// Port 0 for each RAM is used for writing the data coming from the matmul as of now, not used for reading
wire [`DWIDTH-1:0] accum0_ping_q0_NC;
wire [`DWIDTH-1:0] accum1_ping_q0_NC;
wire [`DWIDTH-1:0] accum2_ping_q0_NC;
wire [`DWIDTH-1:0] accum3_ping_q0_NC;
wire [`DWIDTH-1:0] accum4_ping_q0_NC;
wire [`DWIDTH-1:0] accum5_ping_q0_NC;
wire [`DWIDTH-1:0] accum6_ping_q0_NC;
wire [`DWIDTH-1:0] accum7_ping_q0_NC;
wire [`DWIDTH-1:0] accum0_pong_q0_NC;
wire [`DWIDTH-1:0] accum1_pong_q0_NC;
wire [`DWIDTH-1:0] accum2_pong_q0_NC;
wire [`DWIDTH-1:0] accum3_pong_q0_NC;
wire [`DWIDTH-1:0] accum4_pong_q0_NC;
wire [`DWIDTH-1:0] accum5_pong_q0_NC;
wire [`DWIDTH-1:0] accum6_pong_q0_NC;
wire [`DWIDTH-1:0] accum7_pong_q0_NC;

wire [`AWIDTH-1:0] raddr_buffer0;
wire [`AWIDTH-1:0] raddr_buffer1;
wire [`AWIDTH-1:0] raddr_buffer2;
wire [`AWIDTH-1:0] raddr_buffer3;
wire [`AWIDTH-1:0] raddr_buffer4;
wire [`AWIDTH-1:0] raddr_buffer5;
wire [`AWIDTH-1:0] raddr_buffer6;
wire [`AWIDTH-1:0] raddr_buffer7;

wire [`DWIDTH-1:0] rdata_buffer0;
wire [`DWIDTH-1:0] rdata_buffer1;
wire [`DWIDTH-1:0] rdata_buffer2;
wire [`DWIDTH-1:0] rdata_buffer3;
wire [`DWIDTH-1:0] rdata_buffer4;
wire [`DWIDTH-1:0] rdata_buffer5;
wire [`DWIDTH-1:0] rdata_buffer6;
wire [`DWIDTH-1:0] rdata_buffer7;

reg buffer_select_pool1;
reg buffer_select_pool2;
reg buffer_select_pool3;
reg buffer_select_pool4;
reg buffer_select_pool5;
reg buffer_select_pool6;
reg buffer_select_pool7;
  
always @ (posedge clk) begin
buffer_select_pool1 <= buffer_select_pool;
buffer_select_pool2 <= buffer_select_pool1;
buffer_select_pool3 <= buffer_select_pool2;
buffer_select_pool4 <= buffer_select_pool3;
buffer_select_pool5 <= buffer_select_pool4;
buffer_select_pool6 <= buffer_select_pool5;
buffer_select_pool7 <= buffer_select_pool6;
end

reg buffer_select_accum1;
reg buffer_select_accum2;
reg buffer_select_accum3;
reg buffer_select_accum4;
reg buffer_select_accum5;
reg buffer_select_accum6;
reg buffer_select_accum7;
  
always @ (posedge clk) begin
buffer_select_accum1 <= buffer_select_accum;
buffer_select_accum2 <= buffer_select_accum1;
buffer_select_accum3 <= buffer_select_accum2;
buffer_select_accum4 <= buffer_select_accum3;
buffer_select_accum5 <= buffer_select_accum4;
buffer_select_accum6 <= buffer_select_accum5;
buffer_select_accum7 <= buffer_select_accum6;
end


assign raddr_buffer0 = (buffer_select_pool)? raddr_accum0_pool : (buffer_select_accum)? raddr_accum0:11'bx;
assign raddr_buffer1 = (buffer_select_pool1)? raddr_accum1_pool : (buffer_select_accum1)? raddr_accum1:11'bx;
assign raddr_buffer2 = (buffer_select_pool2)? raddr_accum2_pool : (buffer_select_accum2)? raddr_accum2:11'bx;
assign raddr_buffer3 = (buffer_select_pool3)? raddr_accum3_pool : (buffer_select_accum3)? raddr_accum3:11'bx;
assign raddr_buffer4 = (buffer_select_pool4)? raddr_accum4_pool : (buffer_select_accum4)? raddr_accum4:11'bx;
assign raddr_buffer5 = (buffer_select_pool5)? raddr_accum5_pool : (buffer_select_accum5)? raddr_accum5:11'bx;
assign raddr_buffer6 = (buffer_select_pool6)? raddr_accum6_pool : (buffer_select_accum6)? raddr_accum6:11'bx;
assign raddr_buffer7 = (buffer_select_pool7)? raddr_accum7_pool : (buffer_select_accum7)? raddr_accum7:11'bx;
  
assign rdata_accum0_pool =  (buffer_select_pool)? rdata_buffer0 : 8'b0;
assign rdata_accum1_pool =  (buffer_select_pool1)? rdata_buffer1 : 8'b0;
assign rdata_accum2_pool =  (buffer_select_pool2)? rdata_buffer2 : 8'b0;
assign rdata_accum3_pool =  (buffer_select_pool3)? rdata_buffer3 : 8'b0;
assign rdata_accum4_pool =  (buffer_select_pool4)? rdata_buffer4 : 8'b0;
assign rdata_accum5_pool =  (buffer_select_pool5)? rdata_buffer5 : 8'b0;
assign rdata_accum6_pool =  (buffer_select_pool6)? rdata_buffer6 : 8'b0;
assign rdata_accum7_pool =  (buffer_select_pool7)? rdata_buffer7 : 8'b0;
  
////////////////////////////////////////////////
// PING ACCUMULATORS
////////////////////////////////////////////////

qadd adder_accum_ping0 (wdata_accum0, wdata_accum0_in, wdata_accum0_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum0_ping (
    .addr0(waddr_accum0),
    .d0(wdata_accum0_ping), 
    .we0(wdata_en_ping0), 
    .q0(accum0_ping_q0_NC),
    .addr1(raddr_buffer0),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer0), 
    .clk(clk)
);

qadd adder_accum_ping1 (wdata_accum1, wdata_accum1_in, wdata_accum1_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum1_ping (
    .addr0(waddr_accum1),
    .d0(wdata_accum1_ping), 
    .we0(wdata_en_ping1), 
    .q0(accum1_ping_q0_NC),
    .addr1(raddr_buffer1),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer1), 
    .clk(clk)
);

qadd adder_accum_ping2 (wdata_accum2, wdata_accum2_in, wdata_accum2_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum2_ping (
    .addr0(waddr_accum2),
    .d0(wdata_accum2_ping), 
    .we0(wdata_en_ping2), 
    .q0(accum2_ping_q0_NC),
    .addr1(raddr_buffer2),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer2), 
    .clk(clk)
);

qadd adder_accum_ping3 (wdata_accum3, wdata_accum3_in, wdata_accum3_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum3_ping (
    .addr0(waddr_accum3),
    .d0(wdata_accum3_ping), 
    .we0(wdata_en_ping3), 
    .q0(accum3_ping_q0_NC),
    .addr1(raddr_buffer3),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer3), 
    .clk(clk)
);

qadd adder_accum_ping4 (wdata_accum4, wdata_accum4_in, wdata_accum4_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum4_ping (
    .addr0(waddr_accum4),
    .d0(wdata_accum4_ping), 
    .we0(wdata_en_ping4), 
    .q0(accum4_ping_q0_NC),
    .addr1(raddr_buffer4),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer4), 
    .clk(clk)
);

qadd adder_accum_ping5 (wdata_accum5, wdata_accum5_in, wdata_accum5_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum5_ping (
    .addr0(waddr_accum5),
    .d0(wdata_accum5_ping), 
    .we0(wdata_en_ping5), 
    .q0(accum5_ping_q0_NC),
    .addr1(raddr_buffer5),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer5), 
    .clk(clk)
);

qadd adder_accum_ping6 (wdata_accum6, wdata_accum6_in, wdata_accum6_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum6_ping (
    .addr0(waddr_accum6),
    .d0(wdata_accum6_ping), 
    .we0(wdata_en_ping6), 
    .q0(accum6_ping_q0_NC),
    .addr1(raddr_buffer6),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer6), 
    .clk(clk)
);

qadd adder_accum_ping7 (wdata_accum7, wdata_accum7_in, wdata_accum7_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum7_ping (
    .addr0(waddr_accum7),
    .d0(wdata_accum7_ping), 
    .we0(wdata_en_ping7), 
    .q0(accum7_ping_q0_NC),
    .addr1(raddr_buffer7),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer7), 
    .clk(clk)
);

wire [`AWIDTH-1:0] raddr_accum0_pong;
wire [`AWIDTH-1:0] raddr_accum1_pong;
wire [`AWIDTH-1:0] raddr_accum2_pong;
wire [`AWIDTH-1:0] raddr_accum3_pong;
wire [`AWIDTH-1:0] raddr_accum4_pong;
wire [`AWIDTH-1:0] raddr_accum5_pong;
wire [`AWIDTH-1:0] raddr_accum6_pong;
wire [`AWIDTH-1:0] raddr_accum7_pong;

wire [`DWIDTH-1:0] rdata_accum0_pong;
wire [`DWIDTH-1:0] rdata_accum1_pong;
wire [`DWIDTH-1:0] rdata_accum2_pong;
wire [`DWIDTH-1:0] rdata_accum3_pong;
wire [`DWIDTH-1:0] rdata_accum4_pong;
wire [`DWIDTH-1:0] rdata_accum5_pong;
wire [`DWIDTH-1:0] rdata_accum6_pong;
wire [`DWIDTH-1:0] rdata_accum7_pong;

wire [`DWIDTH-1:0] wdata_accum0_pong;
wire [`DWIDTH-1:0] wdata_accum1_pong;
wire [`DWIDTH-1:0] wdata_accum2_pong;
wire [`DWIDTH-1:0] wdata_accum3_pong;
wire [`DWIDTH-1:0] wdata_accum4_pong;
wire [`DWIDTH-1:0] wdata_accum5_pong;
wire [`DWIDTH-1:0] wdata_accum6_pong;
wire [`DWIDTH-1:0] wdata_accum7_pong;

////////////////////////////////////////////////
// PONG ACCUMULATORS
////////////////////////////////////////////////

qadd adder_accum_pong0 (wdata_accum0, wdata_accum0_in, wdata_accum0_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum0_pong (
    .addr0(waddr_accum0),
    .d0(wdata_accum0_pong), 
    .we0(wdata_en_pong0), 
    .q0(accum0_pong_q0_NC),
    .addr1(raddr_accum0_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum0_pong), 
    .clk(clk)
);

qadd adder_accum_pong1 (wdata_accum1, wdata_accum1_in, wdata_accum1_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum1_pong (
    .addr0(waddr_accum1),
    .d0(wdata_accum1_pong), 
    .we0(wdata_en_pong1), 
    .q0(accum1_pong_q0_NC),
    .addr1(raddr_accum1_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum1_pong), 
    .clk(clk)
);

qadd adder_accum_pong2 (wdata_accum2, wdata_accum2_in, wdata_accum2_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum2_pong (
    .addr0(waddr_accum2),
    .d0(wdata_accum2_pong), 
    .we0(wdata_en_pong2), 
    .q0(accum2_pong_q0_NC),
    .addr1(raddr_accum2_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum2_pong), 
    .clk(clk)
);

qadd adder_accum_pong3 (wdata_accum3, wdata_accum3_in, wdata_accum3_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum3_pong (
    .addr0(waddr_accum3),
    .d0(wdata_accum3_pong), 
    .we0(wdata_en_pong3), 
    .q0(accum3_pong_q0_NC),
    .addr1(raddr_accum3_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum3_pong), 
    .clk(clk)
);

qadd adder_accum_pong4 (wdata_accum4, wdata_accum4_in, wdata_accum4_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum4_pong (
    .addr0(waddr_accum4),
    .d0(wdata_accum4_pong), 
    .we0(wdata_en_pong4), 
    .q0(accum4_pong_q0_NC),
    .addr1(raddr_accum4_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum4_pong), 
    .clk(clk)
);

qadd adder_accum_pong5 (wdata_accum5, wdata_accum5_in, wdata_accum5_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum5_pong (
    .addr0(waddr_accum5),
    .d0(wdata_accum5_pong), 
    .we0(wdata_en_pong5), 
    .q0(accum5_pong_q0_NC),
    .addr1(raddr_accum5_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum5_pong), 
    .clk(clk)
);

qadd adder_accum_pong6 (wdata_accum6, wdata_accum6_in, wdata_accum6_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum6_pong (
    .addr0(waddr_accum6),
    .d0(wdata_accum6_pong), 
    .we0(wdata_en_pong6), 
    .q0(accum6_pong_q0_NC),
    .addr1(raddr_accum6_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum6_pong), 
    .clk(clk)
);

qadd adder_accum_pong7 (wdata_accum7, wdata_accum7_in, wdata_accum7_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum7_pong (
    .addr0(waddr_accum7),
    .d0(wdata_accum7_pong), 
    .we0(wdata_en_pong7), 
    .q0(accum7_pong_q0_NC),
    .addr1(raddr_accum7_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum7_pong), 
    .clk(clk)
);


endmodule

//////////////////////////////////
// Pooling Module
//////////////////////////////////

module pooling(
    clk,
    resetn,
    start_pooling,
    pool_select,
    pool_norm_valid,
    enable_pool,
    rdata_accum0_pool,
    rdata_accum1_pool,
    rdata_accum2_pool,
    rdata_accum3_pool,
    rdata_accum4_pool,
    rdata_accum5_pool,
    rdata_accum6_pool,
    rdata_accum7_pool,
    raddr_accum0_pool,
    raddr_accum1_pool,
    raddr_accum2_pool,
    raddr_accum3_pool,
    raddr_accum4_pool,
    raddr_accum5_pool,
    raddr_accum6_pool,
    raddr_accum7_pool,
    pool0,
    pool1,
    pool2,
    pool3,
    pool4,
    pool5,
    pool6,
    pool7,
    matrix_size,
    filter_size
);

input clk;
input resetn;
input start_pooling;
input pool_select;
input enable_pool;
output pool_norm_valid;
output [`DWIDTH-1:0] pool0;
output [`DWIDTH-1:0] pool1;
output [`DWIDTH-1:0] pool2;
output [`DWIDTH-1:0] pool3;
output [`DWIDTH-1:0] pool4;
output [`DWIDTH-1:0] pool5;
output [`DWIDTH-1:0] pool6;
output [`DWIDTH-1:0] pool7;
input [`DWIDTH-1:0] rdata_accum0_pool;
input [`DWIDTH-1:0] rdata_accum1_pool;
input [`DWIDTH-1:0] rdata_accum2_pool;
input [`DWIDTH-1:0] rdata_accum3_pool;
input [`DWIDTH-1:0] rdata_accum4_pool;
input [`DWIDTH-1:0] rdata_accum5_pool;
input [`DWIDTH-1:0] rdata_accum6_pool;
input [`DWIDTH-1:0] rdata_accum7_pool;
output [`AWIDTH-1:0] raddr_accum0_pool;
output [`AWIDTH-1:0] raddr_accum1_pool;
output [`AWIDTH-1:0] raddr_accum2_pool;
output [`AWIDTH-1:0] raddr_accum3_pool;
output [`AWIDTH-1:0] raddr_accum4_pool;
output [`AWIDTH-1:0] raddr_accum5_pool;
output [`AWIDTH-1:0] raddr_accum6_pool;
output [`AWIDTH-1:0] raddr_accum7_pool;
input [`DWIDTH-1:0] matrix_size;
input [`DWIDTH-1:0] filter_size;

reg [`AWIDTH-1:0] raddr_accum1_pool;
reg [`AWIDTH-1:0] raddr_accum2_pool;
reg [`AWIDTH-1:0] raddr_accum3_pool;
reg [`AWIDTH-1:0] raddr_accum4_pool;
reg [`AWIDTH-1:0] raddr_accum5_pool;
reg [`AWIDTH-1:0] raddr_accum6_pool;
reg [`AWIDTH-1:0] raddr_accum7_pool;

reg [7:0] pool_count0;
reg [7:0] pool_count1;
reg [7:0] pool_count2;
reg [7:0] pool_count3;
reg [7:0] pool_count4;
reg [7:0] pool_count5;
reg [7:0] pool_count6;
reg [7:0] pool_count7;
reg [7:0] pool_count8;

wire [`DWIDTH-1:0] filter_size_int;
assign filter_size_int = (enable_pool)? filter_size : 8'b1;
wire [`DWIDTH-1:0] matrix_size_int;
assign matrix_size_int = (enable_pool)? matrix_size : 8'b1;

always @ (posedge clk) begin
    if (~resetn|~start_pooling) begin
        pool_count0 <= 0;
    end
    else if (pool_count0 == (filter_size_int*filter_size_int)) begin
        pool_count0 <= 1;
    end
    else if (start_pooling) begin
        pool_count0 <= pool_count0 + 1;
    end      
end

always @ (posedge clk) begin
    pool_count1 <= pool_count0;
    pool_count2 <= pool_count1;
    pool_count3 <= pool_count2;
    pool_count4 <= pool_count3;
    pool_count5 <= pool_count4;
    pool_count6 <= pool_count5;
    pool_count7 <= pool_count6;
    pool_count8 <= pool_count7;
end

wire [`DWIDTH-1:0] cmp0;
wire [`DWIDTH-1:0] cmp1;
wire [`DWIDTH-1:0] cmp2;
wire [`DWIDTH-1:0] cmp3;
wire [`DWIDTH-1:0] cmp4;
wire [`DWIDTH-1:0] cmp5;
wire [`DWIDTH-1:0] cmp6;
wire [`DWIDTH-1:0] cmp7;

reg [`DWIDTH-1:0] compare0;
reg [`DWIDTH-1:0] compare1;
reg [`DWIDTH-1:0] compare2;
reg [`DWIDTH-1:0] compare3;
reg [`DWIDTH-1:0] compare4;
reg [`DWIDTH-1:0] compare5;
reg [`DWIDTH-1:0] compare6;
reg [`DWIDTH-1:0] compare7;

wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg0;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg1;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg2;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg3;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg4;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg5;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg6;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg7;

reg [`DWIDTH+`MAT_MUL_SIZE-1:0] avg0_int;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] avg1_int;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] avg2_int;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] avg3_int;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] avg4_int;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] avg5_int;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] avg6_int;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] avg7_int;

wire [`DWIDTH+`MAT_MUL_SIZE-1:0] average0;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] average1;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] average2;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] average3;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] average4;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] average5;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] average6;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] average7;

assign pool_norm_valid = (pool_count1 == (filter_size_int*filter_size_int))?1'b1:1'b0;

reg [`AWIDTH-1:0] x;
reg [`AWIDTH-1:0] y;
reg [`AWIDTH-1:0] k;
assign raddr_accum0_pool = (~resetn|~start_pooling)? 11'h7ff: ((matrix_size_int)*y + x + k);

always @(posedge clk) begin
    if(~resetn|~start_pooling) begin
        x<=0;
        y<=0;
        k<=0;
    end
    else if (y == (matrix_size_int-1) & x==(filter_size_int-1)) begin
        k<=k+filter_size_int;
        y<=0;
        x<=0;
    end
    else if (x==(filter_size_int-1)) begin
        y<=y+1;
        x<=0;
    end
    else if (start_pooling) begin
        x<=x+1;
    end
end

always @ (posedge clk) begin
    raddr_accum1_pool <= raddr_accum0_pool;
    raddr_accum2_pool <= raddr_accum1_pool;
    raddr_accum3_pool <= raddr_accum2_pool;
    raddr_accum4_pool <= raddr_accum3_pool;
    raddr_accum5_pool <= raddr_accum4_pool;
    raddr_accum6_pool <= raddr_accum5_pool;
    raddr_accum7_pool <= raddr_accum6_pool;
end

always @ (posedge clk) begin
    if (~resetn) begin
        compare0 <= 0;
    end
    else if (rdata_accum0_pool > cmp0) begin
        compare0 <= rdata_accum0_pool;
    end
    else if (rdata_accum0_pool < cmp0) begin
        compare0 <= cmp0;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        avg0_int <= 0;
    end
    else begin
        avg0_int <= avg0 + rdata_accum0_pool;
    end
end

//TODO: For now, we are approximating divide by 9 (multiplication by 0.111) with a divide by 8 (>> 3) in all the pooling blocks

assign cmp0 = (pool_count0 == 1)? 0 : compare0;
assign avg0 = (pool_count0 == 1)? 0 : avg0_int;
assign average0 = (filter_size_int == 8'b1)? avg0_int : (filter_size_int == 8'b10)? avg0_int >> 2 : (filter_size_int == 8'b11)? avg0_int >> 3 : (filter_size_int == 8'b100)? avg0_int >> 4 : avg0_int;
assign pool0 = (pool_count1 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare0 : average0) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare1 <= 0;
    end
    else if (rdata_accum1_pool > cmp1) begin
        compare1 <= rdata_accum1_pool;
    end
    else if (rdata_accum1_pool < cmp1) begin
        compare1 <= cmp1;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        avg1_int <= 0;
    end
    else begin
        avg1_int <= avg1 + rdata_accum1_pool;
    end
end

assign cmp1 = (pool_count1 == 1)? 0 : compare1;
assign avg1 = (pool_count1 == 1)? 0 : avg1_int;
assign average1 = (filter_size_int == 8'b1)? avg1_int : (filter_size_int == 8'b10)? avg1_int >> 2 : (filter_size_int == 8'b11)? avg1_int >> 3 : (filter_size_int == 8'b100)? avg1_int >> 4 : avg1_int;
assign pool1 = (pool_count2 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare1 : average1) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare2 <= 0;
    end
    else if (rdata_accum2_pool > cmp2) begin
        compare2 <= rdata_accum2_pool;
    end
    else if (rdata_accum2_pool < cmp2) begin
        compare2 <= cmp2;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        avg2_int <= 0;
    end
    else begin
        avg2_int <= avg2 + rdata_accum2_pool;
    end
end

assign cmp2 = (pool_count2 == 1)? 0 : compare2;
assign avg2 = (pool_count2 == 1)? 0 : avg2_int;
assign average2 = (filter_size_int == 8'b1)? avg2_int : (filter_size_int == 8'b10)? avg2_int >> 2 : (filter_size_int == 8'b11)? avg2_int >> 3 : (filter_size_int == 8'b100)? avg2_int >> 4 : avg2_int;
assign pool2 = (pool_count3 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare2 : average2) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare3 <= 0;
    end
    else if (rdata_accum3_pool > cmp3) begin
        compare3 <= rdata_accum3_pool;
    end
    else if (rdata_accum3_pool < cmp3) begin
        compare3 <= cmp3;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        avg3_int <= 0;
    end
    else begin
        avg3_int <= avg3 + rdata_accum3_pool;
    end
end

assign cmp3 = (pool_count3 == 1)? 0 : compare3;
assign avg3 = (pool_count3 == 1)? 0 : avg3_int;
assign average3 = (filter_size_int == 8'b1)? avg3_int : (filter_size_int == 8'b10)? avg3_int >> 2 : (filter_size_int == 8'b11)? avg3_int >> 3 : (filter_size_int == 8'b100)? avg3_int >> 4 : avg3_int;
assign pool3 = (pool_count4 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare3 : average3) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare4 <= 0;
    end
    else if (rdata_accum4_pool > cmp4) begin
        compare4 <= rdata_accum4_pool;
    end
    else if (rdata_accum4_pool < cmp4) begin
        compare4 <= cmp4;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        avg4_int <= 0;
    end
    else begin
        avg4_int <= avg4 + rdata_accum4_pool;
    end
end

assign cmp4 = (pool_count4 == 1)? 0 : compare4;
assign avg4 = (pool_count4 == 1)? 0 : avg4_int;
assign average4 = (filter_size_int == 8'b1)? avg4_int : (filter_size_int == 8'b10)? avg4_int >> 2 : (filter_size_int == 8'b11)? avg4_int >> 3 : (filter_size_int == 8'b100)? avg4_int >> 4 : avg4_int;
assign pool4 = (pool_count5 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare4 : average4) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare5 <= 0;
    end
    else if (rdata_accum5_pool > cmp5) begin
        compare5 <= rdata_accum5_pool;
    end
    else if (rdata_accum5_pool < cmp5) begin
        compare5 <= cmp5;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        avg5_int <= 0;
    end
    else begin
        avg5_int <= avg5 + rdata_accum5_pool;
    end
end

assign cmp5 = (pool_count5 == 1)? 0 : compare5;
assign avg5 = (pool_count5 == 1)? 0 : avg5_int;
assign average5 = (filter_size_int == 8'b1)? avg5_int : (filter_size_int == 8'b10)? avg5_int >> 2 : (filter_size_int == 8'b11)? avg5_int >> 3 : (filter_size_int == 8'b100)? avg5_int >> 4 : avg5_int;
assign pool5 = (pool_count6 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare5 : average5) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare6 <= 0;
    end
    else if (rdata_accum6_pool > cmp6) begin
        compare6 <= rdata_accum6_pool;
    end
    else if (rdata_accum6_pool < cmp6) begin
        compare6 <= cmp6;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        avg6_int <= 0;
    end
    else begin
        avg6_int <= avg6 + rdata_accum6_pool;
    end
end

assign cmp6 = (pool_count6 == 1)? 0 : compare6;
assign avg6 = (pool_count6 == 1)? 0 : avg6_int;
assign average6 = (filter_size_int == 8'b1)? avg6_int : (filter_size_int == 8'b10)? avg6_int >> 2 : (filter_size_int == 8'b11)? avg6_int >> 3 : (filter_size_int == 8'b100)? avg6_int >> 4 : avg6_int;
assign pool6 = (pool_count7 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare6 : average6) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare7 <= 0;
    end
    else if (rdata_accum7_pool > cmp7) begin
        compare7 <= rdata_accum7_pool;
    end
    else if (rdata_accum7_pool < cmp7) begin
        compare7 <= cmp7;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        avg7_int <= 0;
    end
    else begin
        avg7_int <= avg7 + rdata_accum7_pool;
    end
end

assign cmp7 = (pool_count7 == 1)? 0 : compare7;
assign avg7 = (pool_count7 == 1)? 0 : avg7_int;
assign average7 = (filter_size_int == 8'b1)? avg7_int : (filter_size_int == 8'b10)? avg7_int >> 2 : (filter_size_int == 8'b11)? avg7_int >> 3 : (filter_size_int == 8'b100)? avg7_int >> 4 : avg7_int;
assign pool7 = (pool_count8 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare7 : average7) : 8'b0;


endmodule

//////////////////////////////////
// Activation Module
//////////////////////////////////

module activation(
    input activation_type,
    input enable_activation,
    input enable_pool,
    input in_data_available,
    input [`DWIDTH-1:0] inp_data0,
    input [`DWIDTH-1:0] inp_data1,
    input [`DWIDTH-1:0] inp_data2,
    input [`DWIDTH-1:0] inp_data3,
    input [`DWIDTH-1:0] inp_data4,
    input [`DWIDTH-1:0] inp_data5,
    input [`DWIDTH-1:0] inp_data6,
    input [`DWIDTH-1:0] inp_data7,
    output [`DWIDTH-1:0] out_data0,
    output [`DWIDTH-1:0] out_data1,
    output [`DWIDTH-1:0] out_data2,
    output [`DWIDTH-1:0] out_data3,
    output [`DWIDTH-1:0] out_data4,
    output [`DWIDTH-1:0] out_data5,
    output [`DWIDTH-1:0] out_data6,
    output [`DWIDTH-1:0] out_data7,
    output out_data_available,
    input [`MASK_WIDTH-1:0] validity_mask,
    output done_activation,
    input clk,
    input reset
);

reg in_data_available1;
reg in_data_available2;
reg in_data_available3;
reg in_data_available4;
reg in_data_available5;
reg in_data_available6;
reg in_data_available7;

always @(posedge clk) begin
	in_data_available1 <= in_data_available;
	in_data_available2 <= in_data_available1;
	in_data_available3 <= in_data_available2;
	in_data_available4 <= in_data_available3;
	in_data_available5 <= in_data_available4;
	in_data_available6 <= in_data_available5;
	in_data_available7 <= in_data_available6;	
end

wire out_data_available_internal;
assign out_data_available   = enable_pool? enable_activation ? out_data_available_internal : in_data_available : in_data_available2;


wire out_data_available_NC;
wire out_data_available_final;
reg [`DWIDTH-1:0] act_count;
reg done_activation;
reg [`DWIDTH-1:0] done_activation_count;

always @(posedge clk) begin
	if (reset) begin
		done_activation <= 0;
      done_activation_count <= 0;
		act_count <= 0;
	end
   else if (done_activation_count == `MAT_MUL_SIZE)
      done_activation <= 0;
	else if (act_count == 4) begin
		done_activation <= 1;
      done_activation_count <= done_activation_count + 1;
	end
	else if (out_data_available_final == 1) begin
		act_count <= act_count + 1;
	end
end

sub_activation activation0(
  .activation_type(activation_type),
  .enable_activation(enable_activation),
  .in_data_available(in_data_available),
  .inp_data(inp_data0),
  .out_data(out_data0),
  .out_data_available(out_data_available_internal),
  .validity_mask(validity_mask[0]),
  .clk(clk),
  .reset(reset)
);

sub_activation activation1(
  .activation_type(activation_type),
  .enable_activation(enable_activation),
  .in_data_available(in_data_available1),
  .inp_data(inp_data1),
  .out_data(out_data1),
  .out_data_available(out_data_available_NC),
  .validity_mask(validity_mask[1]),
  .clk(clk),
  .reset(reset)
);

sub_activation activation2(
  .activation_type(activation_type),
  .enable_activation(enable_activation),
  .in_data_available(in_data_available2),
  .inp_data(inp_data2),
  .out_data(out_data2),
  .out_data_available(out_data_available_NC),
  .validity_mask(validity_mask[2]),
  .clk(clk),
  .reset(reset)
);

sub_activation activation3(
  .activation_type(activation_type),
  .enable_activation(enable_activation),
  .in_data_available(in_data_available3),
  .inp_data(inp_data3),
  .out_data(out_data3),
  .out_data_available(out_data_available_NC),
  .validity_mask(validity_mask[3]),
  .clk(clk),
  .reset(reset)
);

sub_activation activation4(
  .activation_type(activation_type),
  .enable_activation(enable_activation),
  .in_data_available(in_data_available4),
  .inp_data(inp_data4),
  .out_data(out_data4),
  .out_data_available(out_data_available_NC),
  .validity_mask(validity_mask[4]),
  .clk(clk),
  .reset(reset)
);

sub_activation activation5(
  .activation_type(activation_type),
  .enable_activation(enable_activation),
  .in_data_available(in_data_available5),
  .inp_data(inp_data5),
  .out_data(out_data5),
  .out_data_available(out_data_available_NC),
  .validity_mask(validity_mask[5]),
  .clk(clk),
  .reset(reset)
);

sub_activation activation6(
  .activation_type(activation_type),
  .enable_activation(enable_activation),
  .in_data_available(in_data_available6),
  .inp_data(inp_data6),
  .out_data(out_data6),
  .out_data_available(out_data_available_NC),
  .validity_mask(validity_mask[6]),
  .clk(clk),
  .reset(reset)
);

sub_activation activation7(
  .activation_type(activation_type),
  .enable_activation(enable_activation),
  .in_data_available(in_data_available7),
  .inp_data(inp_data7),
  .out_data(out_data7),
  .out_data_available(out_data_available_final),
  .validity_mask(validity_mask[7]),
  .clk(clk),
  .reset(reset)
);

endmodule

module sub_activation(
    input activation_type,
    input enable_activation,
    input in_data_available,
    input [`DWIDTH-1:0] inp_data,
    output [`DWIDTH-1:0] out_data,
    output out_data_available,
    input validity_mask,
    input clk,
    input reset
);

reg  out_data_available_internal;
reg [`DWIDTH-1:0] out_data_internal;
reg [`DWIDTH-1:0] slope_applied_data_internal;
reg [`DWIDTH-1:0] intercept_applied_data_internal;
reg [`DWIDTH-1:0] relu_applied_data_internal;
integer i;
integer cycle_count;
reg activation_in_progress;

reg [3:0] address;
reg [`DWIDTH-1:0] data_slope;
reg [`DWIDTH-1:0] data_intercept;
reg [`DWIDTH-1:0] data_intercept_delayed;

// If the activation block is not enabled, just forward the input data
assign out_data             = enable_activation ? out_data_internal : inp_data;
assign out_data_available   = enable_activation ? out_data_available_internal : in_data_available;

always @(posedge clk) begin
   if (reset || ~enable_activation) begin
      slope_applied_data_internal     <= 0;
      intercept_applied_data_internal <= 0; 
      relu_applied_data_internal      <= 0; 
      data_intercept_delayed      <= 0;
      out_data_available_internal <= 0;
      cycle_count                 <= 0;
      activation_in_progress      <= 0;      
   end 
   else if(in_data_available || activation_in_progress) begin
      cycle_count <= cycle_count + 1;
      if(activation_type==1'b1) begin // tanH
        slope_applied_data_internal <= data_slope * inp_data;
        data_intercept_delayed <= data_intercept;
        intercept_applied_data_internal <= slope_applied_data_internal + data_intercept_delayed;
      end else begin // ReLU
        relu_applied_data_internal <= (inp_data)? {`DWIDTH{1'b0}} : inp_data;
      end 
      
      //TANH needs 1 extra cycle
      if (activation_type==1'b1) begin
         if (cycle_count==2) begin
            out_data_available_internal <= 1;
         end
      end else begin
         if (cycle_count==1) begin
           out_data_available_internal <= 1;
         end
      end

      //TANH needs 1 extra cycle
      if (activation_type==1'b1) begin
        if(cycle_count==2) begin
           activation_in_progress <= 0;
        end
        else begin
           activation_in_progress <= 1;
        end
      end else begin
        if(cycle_count==1) begin
           activation_in_progress <= 0;
        end
        else begin
           activation_in_progress <= 1;
        end
      end
   end   
   else begin
      slope_applied_data_internal     <= 0;
      intercept_applied_data_internal <= 0; 
      relu_applied_data_internal      <= 0; 
      data_intercept_delayed      <= 0;
      out_data_available_internal <= 0;
      cycle_count                 <= 0;
      activation_in_progress      <= 0;
   end
end

always @ (posedge clk) begin
   if (activation_type == 1'b1)
      out_data_internal <= intercept_applied_data_internal;
   else
      out_data_internal <= relu_applied_data_internal;
end

//Our equation of tanh is Y=AX+B
//A is the slope and B is the intercept.
//We store A in one LUT and B in another.
//LUT for the slope
always @(address) begin
    case (address)
      4'b0000: data_slope = 8'd0;
      4'b0001: data_slope = 8'd0;
      4'b0010: data_slope = 8'd2;
      4'b0011: data_slope = 8'd3;
      4'b0100: data_slope = 8'd4;
      4'b0101: data_slope = 8'd0;
      4'b0110: data_slope = 8'd4;
      4'b0111: data_slope = 8'd3;
      4'b1000: data_slope = 8'd2;
      4'b1001: data_slope = 8'd0;
      4'b1010: data_slope = 8'd0;
      default: data_slope = 8'd0;
    endcase  
end

//LUT for the intercept
always @(address) begin
    case (address)
      4'b0000: data_intercept = 8'd127;
      4'b0001: data_intercept = 8'd99;
      4'b0010: data_intercept = 8'd46;
      4'b0011: data_intercept = 8'd18;
      4'b0100: data_intercept = 8'd0;
      4'b0101: data_intercept = 8'd0;
      4'b0110: data_intercept = 8'd0;
      4'b0111: data_intercept = -8'd18;
      4'b1000: data_intercept = -8'd46;
      4'b1001: data_intercept = -8'd99;
      4'b1010: data_intercept = -8'd127;
      default: data_intercept = 8'd0;
    endcase  
end

//Logic to find address
always @(inp_data) begin
        if((inp_data)>=90) begin
           address = 4'b0000;
        end
        else if ((inp_data)>=39 && (inp_data)<90) begin
           address = 4'b0001;
        end
        else if ((inp_data)>=28 && (inp_data)<39) begin
           address = 4'b0010;
        end
        else if ((inp_data)>=16 && (inp_data)<28) begin
           address = 4'b0011;
        end
        else if ((inp_data)>=1 && (inp_data)<16) begin
           address = 4'b0100;
        end
        else if ((inp_data)==0) begin
           address = 4'b0101;
        end
        else if ((inp_data)>-16 && (inp_data)<=-1) begin
           address = 4'b0110;
        end
        else if ((inp_data)>-28 && (inp_data)<=-16) begin
           address = 4'b0111;
        end
        else if ((inp_data)>-39 && (inp_data)<=-28) begin
           address = 4'b1000;
        end
        else if ((inp_data)>-90 && (inp_data)<=-39) begin
           address = 4'b1001;
        end
        else if ((inp_data)<=-90) begin
           address = 4'b1010;
        end
        else begin
           address = 4'b0101;
        end
end

//Adding a dummy signal to use validity_mask input, to make ODIN happy
//TODO: Need to correctly use validity_mask
wire [`MASK_WIDTH-1:0] dummy;
assign dummy = validity_mask;


endmodule

//////////////////////////////////
// Top Module
//////////////////////////////////

module top(
    input  clk,
    input  clk_mem,
    input  reset,
    input  resetn,
    input  [`REG_ADDRWIDTH-1:0] PADDR,
    input  PWRITE,
    input  PSEL,
    input  PENABLE,
    input  [`REG_DATAWIDTH-1:0] PWDATA,
    output [`REG_DATAWIDTH-1:0] PRDATA,
    output PREADY,
    input  [`AWIDTH-1:0] bram_addr_a_ext,
    output [`DESIGN_SIZE*`DWIDTH-1:0] bram_rdata_a_ext,
    input  [`DESIGN_SIZE*`DWIDTH-1:0] bram_wdata_a_ext,
    input  [`DESIGN_SIZE-1:0] bram_we_a_ext,
    input  [`AWIDTH-1:0] bram_addr_b_ext,
    output [`DESIGN_SIZE*`DWIDTH-1:0] bram_rdata_b_ext,
    input  [`DESIGN_SIZE*`DWIDTH-1:0] bram_wdata_b_ext,
    input  [`DESIGN_SIZE-1:0] bram_we_b_ext
);

wire [`AWIDTH-1:0] bram_addr_a;
wire [`AWIDTH-1:0] bram_addr_a_for_reading;
reg [`AWIDTH-1:0] bram_addr_a_for_writing;
wire [`DESIGN_SIZE*`DWIDTH-1:0] bram_rdata_a;
reg [`DESIGN_SIZE*`DWIDTH-1:0] bram_wdata_a;
wire [`DESIGN_SIZE-1:0] bram_we_a;
wire bram_en_a;
wire [`AWIDTH-1:0] bram_addr_b;
wire [`DESIGN_SIZE*`DWIDTH-1:0] bram_rdata_b;
wire [`DESIGN_SIZE*`DWIDTH-1:0] bram_wdata_b;
wire [`DESIGN_SIZE-1:0] bram_we_b;
wire bram_en_b;
reg bram_a_wdata_available;
wire [`AWIDTH-1:0] bram_addr_c_NC;
wire start_tpu;
wire done_tpu;
wire start_mat_mul;
wire done_mat_mul;
wire norm_out_data_available;
wire done_norm;
wire pool_out_data_available;
wire done_pool;
wire activation_out_data_available;
wire done_activation;
wire enable_matmul;
wire enable_norm;
wire enable_activation;
wire enable_pool;
wire [31:0] num_matrices_A;
wire [31:0] num_matrices_B;
wire [`DWIDTH-1:0] matrix_size;
wire [`DWIDTH-1:0] filter_size;
wire pool_select;
wire [`DWIDTH-1:0] k_dimension;
wire accum_select;
wire [`DESIGN_SIZE*`DWIDTH-1:0] matmul_c_data_out;
wire [`DESIGN_SIZE*`DWIDTH-1:0] pool_data_out;
wire [`DESIGN_SIZE*`DWIDTH-1:0] activation_data_out;
wire matmul_c_data_available;
wire [`DESIGN_SIZE*`DWIDTH-1:0] a_data_out_NC;
wire [`DESIGN_SIZE*`DWIDTH-1:0] b_data_out_NC;
wire [`DESIGN_SIZE*`DWIDTH-1:0] a_data_in_NC;
wire [`DESIGN_SIZE*`DWIDTH-1:0] b_data_in_NC;
wire [`DWIDTH-1:0] mean;
wire [`DWIDTH-1:0] inv_var;
wire [`AWIDTH-1:0] address_mat_a;
wire [`AWIDTH-1:0] address_mat_b;
wire [`AWIDTH-1:0] address_mat_c;
wire [`MASK_WIDTH-1:0] validity_mask_a_rows;
wire [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows;
wire [`MASK_WIDTH-1:0] validity_mask_b_cols;
wire save_output_to_accum;
wire add_accum_to_output;
wire [`ADDR_STRIDE_WIDTH-1:0] address_stride_a;
wire [`ADDR_STRIDE_WIDTH-1:0] address_stride_b;
wire [`ADDR_STRIDE_WIDTH-1:0] address_stride_c;
wire [`MAX_BITS_POOL-1:0] pool_window_size;
wire activation_type;
wire [3:0] conv_filter_height;
wire [3:0] conv_filter_width;
wire [3:0] conv_stride_horiz;
wire [3:0] conv_stride_verti;
wire [3:0] conv_padding_left;
wire [3:0] conv_padding_right;
wire [3:0] conv_padding_top;
wire [3:0] conv_padding_bottom;
wire [15:0] num_channels_inp;
wire [15:0] num_channels_out;
wire [15:0] inp_img_height;
wire [15:0] inp_img_width;
wire [15:0] out_img_height;
wire [15:0] out_img_width;
wire [31:0] batch_size;
wire enable_conv_mode;
wire pe_reset;
wire start_pool;
wire pool_norm_valid;

`ifdef DESIGN_SIZE_32
wire [`DWIDTH-1:0] matrixC310;
wire [`DWIDTH-1:0] matrixC311;
wire [`DWIDTH-1:0] matrixC312;
wire [`DWIDTH-1:0] matrixC313;
wire [`DWIDTH-1:0] matrixC314;
wire [`DWIDTH-1:0] matrixC315;
wire [`DWIDTH-1:0] matrixC316;
wire [`DWIDTH-1:0] matrixC317;
wire [`DWIDTH-1:0] matrixC318;
wire [`DWIDTH-1:0] matrixC319;
wire [`DWIDTH-1:0] matrixC3110;
wire [`DWIDTH-1:0] matrixC3111;
wire [`DWIDTH-1:0] matrixC3112;
wire [`DWIDTH-1:0] matrixC3113;
wire [`DWIDTH-1:0] matrixC3114;
wire [`DWIDTH-1:0] matrixC3115;
wire [`DWIDTH-1:0] matrixC3116;
wire [`DWIDTH-1:0] matrixC3117;
wire [`DWIDTH-1:0] matrixC3118;
wire [`DWIDTH-1:0] matrixC3119;
wire [`DWIDTH-1:0] matrixC3120;
wire [`DWIDTH-1:0] matrixC3121;
wire [`DWIDTH-1:0] matrixC3122;
wire [`DWIDTH-1:0] matrixC3123;
wire [`DWIDTH-1:0] matrixC3124;
wire [`DWIDTH-1:0] matrixC3125;
wire [`DWIDTH-1:0] matrixC3126;
wire [`DWIDTH-1:0] matrixC3127;
wire [`DWIDTH-1:0] matrixC3128;
wire [`DWIDTH-1:0] matrixC3129;
wire [`DWIDTH-1:0] matrixC3130;
wire [`DWIDTH-1:0] matrixC3131;
`endif
`ifdef DESIGN_SIZE_16
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
`endif
`ifdef DESIGN_SIZE_8
wire [`DWIDTH-1:0] matrixC70;
wire [`DWIDTH-1:0] matrixC71;
wire [`DWIDTH-1:0] matrixC72;
wire [`DWIDTH-1:0] matrixC73;
wire [`DWIDTH-1:0] matrixC74;
wire [`DWIDTH-1:0] matrixC75;
wire [`DWIDTH-1:0] matrixC76;
wire [`DWIDTH-1:0] matrixC77;
`endif
`ifdef DESIGN_SIZE_4
wire [`DWIDTH-1:0] matrixC30;
wire [`DWIDTH-1:0] matrixC31;
wire [`DWIDTH-1:0] matrixC32;
wire [`DWIDTH-1:0] matrixC33;
`endif

`ifdef DESIGN_SIZE_8
wire [`AWIDTH-1:0] start_waddr_accum0;
wire [`AWIDTH-1:0] start_waddr_accum1;
wire [`AWIDTH-1:0] start_waddr_accum2;
wire [`AWIDTH-1:0] start_waddr_accum3;
wire [`AWIDTH-1:0] start_waddr_accum4;
wire [`AWIDTH-1:0] start_waddr_accum5;
wire [`AWIDTH-1:0] start_waddr_accum6;
wire [`AWIDTH-1:0] start_waddr_accum7;

assign start_waddr_accum0 = 11'b0;
assign start_waddr_accum1 = 11'b0;
assign start_waddr_accum2 = 11'b0;
assign start_waddr_accum3 = 11'b0;
assign start_waddr_accum4 = 11'b0;
assign start_waddr_accum5 = 11'b0;
assign start_waddr_accum6 = 11'b0;
assign start_waddr_accum7 = 11'b0;

wire [`DWIDTH-1:0] rdata_accum0_pool;
wire [`DWIDTH-1:0] rdata_accum1_pool;
wire [`DWIDTH-1:0] rdata_accum2_pool;
wire [`DWIDTH-1:0] rdata_accum3_pool;
wire [`DWIDTH-1:0] rdata_accum4_pool;
wire [`DWIDTH-1:0] rdata_accum5_pool;
wire [`DWIDTH-1:0] rdata_accum6_pool;
wire [`DWIDTH-1:0] rdata_accum7_pool;
wire [`AWIDTH-1:0] raddr_accum0_pool;
wire [`AWIDTH-1:0] raddr_accum1_pool;
wire [`AWIDTH-1:0] raddr_accum2_pool;
wire [`AWIDTH-1:0] raddr_accum3_pool;
wire [`AWIDTH-1:0] raddr_accum4_pool;
wire [`AWIDTH-1:0] raddr_accum5_pool;
wire [`AWIDTH-1:0] raddr_accum6_pool;
wire [`AWIDTH-1:0] raddr_accum7_pool;

wire [`DWIDTH-1:0] rdata_accum0;
wire [`DWIDTH-1:0] rdata_accum1;
wire [`DWIDTH-1:0] rdata_accum2;
wire [`DWIDTH-1:0] rdata_accum3;
wire [`DWIDTH-1:0] rdata_accum4;
wire [`DWIDTH-1:0] rdata_accum5;
wire [`DWIDTH-1:0] rdata_accum6;
wire [`DWIDTH-1:0] rdata_accum7;
wire [`AWIDTH-1:0] raddr_accum0_matmul;
wire [`AWIDTH-1:0] raddr_accum1_matmul;
wire [`AWIDTH-1:0] raddr_accum2_matmul;
wire [`AWIDTH-1:0] raddr_accum3_matmul;
wire [`AWIDTH-1:0] raddr_accum4_matmul;
wire [`AWIDTH-1:0] raddr_accum5_matmul;
wire [`AWIDTH-1:0] raddr_accum6_matmul;
wire [`AWIDTH-1:0] raddr_accum7_matmul;
`endif

`ifdef DESIGN_SIZE_16
wire [`AWIDTH-1:0] start_waddr_accum0;
wire [`AWIDTH-1:0] start_waddr_accum1;
wire [`AWIDTH-1:0] start_waddr_accum2;
wire [`AWIDTH-1:0] start_waddr_accum3;
wire [`AWIDTH-1:0] start_waddr_accum4;
wire [`AWIDTH-1:0] start_waddr_accum5;
wire [`AWIDTH-1:0] start_waddr_accum6;
wire [`AWIDTH-1:0] start_waddr_accum7;
wire [`AWIDTH-1:0] start_waddr_accum8;
wire [`AWIDTH-1:0] start_waddr_accum9;
wire [`AWIDTH-1:0] start_waddr_accum10;
wire [`AWIDTH-1:0] start_waddr_accum11;
wire [`AWIDTH-1:0] start_waddr_accum12;
wire [`AWIDTH-1:0] start_waddr_accum13;
wire [`AWIDTH-1:0] start_waddr_accum14;
wire [`AWIDTH-1:0] start_waddr_accum15;

assign start_waddr_accum0 = 11'b0;
assign start_waddr_accum1 = 11'b0;
assign start_waddr_accum2 = 11'b0;
assign start_waddr_accum3 = 11'b0;
assign start_waddr_accum4 = 11'b0;
assign start_waddr_accum5 = 11'b0;
assign start_waddr_accum6 = 11'b0;
assign start_waddr_accum7 = 11'b0;
assign start_waddr_accum8 = 11'b0;
assign start_waddr_accum9 = 11'b0;
assign start_waddr_accum10 = 11'b0;
assign start_waddr_accum11 = 11'b0;
assign start_waddr_accum12 = 11'b0;
assign start_waddr_accum13 = 11'b0;
assign start_waddr_accum14 = 11'b0;
assign start_waddr_accum15 = 11'b0;

wire [`DWIDTH-1:0] rdata_accum0_pool;
wire [`DWIDTH-1:0] rdata_accum1_pool;
wire [`DWIDTH-1:0] rdata_accum2_pool;
wire [`DWIDTH-1:0] rdata_accum3_pool;
wire [`DWIDTH-1:0] rdata_accum4_pool;
wire [`DWIDTH-1:0] rdata_accum5_pool;
wire [`DWIDTH-1:0] rdata_accum6_pool;
wire [`DWIDTH-1:0] rdata_accum7_pool;
wire [`DWIDTH-1:0] rdata_accum8_pool;
wire [`DWIDTH-1:0] rdata_accum9_pool;
wire [`DWIDTH-1:0] rdata_accum10_pool;
wire [`DWIDTH-1:0] rdata_accum11_pool;
wire [`DWIDTH-1:0] rdata_accum12_pool;
wire [`DWIDTH-1:0] rdata_accum13_pool;
wire [`DWIDTH-1:0] rdata_accum14_pool;
wire [`DWIDTH-1:0] rdata_accum15_pool;
wire [`AWIDTH-1:0] raddr_accum0_pool;
wire [`AWIDTH-1:0] raddr_accum1_pool;
wire [`AWIDTH-1:0] raddr_accum2_pool;
wire [`AWIDTH-1:0] raddr_accum3_pool;
wire [`AWIDTH-1:0] raddr_accum4_pool;
wire [`AWIDTH-1:0] raddr_accum5_pool;
wire [`AWIDTH-1:0] raddr_accum6_pool;
wire [`AWIDTH-1:0] raddr_accum7_pool;
wire [`AWIDTH-1:0] raddr_accum8_pool;
wire [`AWIDTH-1:0] raddr_accum9_pool;
wire [`AWIDTH-1:0] raddr_accum10_pool;
wire [`AWIDTH-1:0] raddr_accum11_pool;
wire [`AWIDTH-1:0] raddr_accum12_pool;
wire [`AWIDTH-1:0] raddr_accum13_pool;
wire [`AWIDTH-1:0] raddr_accum14_pool;
wire [`AWIDTH-1:0] raddr_accum15_pool;

wire [`DWIDTH-1:0] rdata_accum0;
wire [`DWIDTH-1:0] rdata_accum1;
wire [`DWIDTH-1:0] rdata_accum2;
wire [`DWIDTH-1:0] rdata_accum3;
wire [`DWIDTH-1:0] rdata_accum4;
wire [`DWIDTH-1:0] rdata_accum5;
wire [`DWIDTH-1:0] rdata_accum6;
wire [`DWIDTH-1:0] rdata_accum7;
wire [`DWIDTH-1:0] rdata_accum8;
wire [`DWIDTH-1:0] rdata_accum9;
wire [`DWIDTH-1:0] rdata_accum10;
wire [`DWIDTH-1:0] rdata_accum11;
wire [`DWIDTH-1:0] rdata_accum12;
wire [`DWIDTH-1:0] rdata_accum13;
wire [`DWIDTH-1:0] rdata_accum14;
wire [`DWIDTH-1:0] rdata_accum15;
wire [`AWIDTH-1:0] raddr_accum0_matmul;
wire [`AWIDTH-1:0] raddr_accum1_matmul;
wire [`AWIDTH-1:0] raddr_accum2_matmul;
wire [`AWIDTH-1:0] raddr_accum3_matmul;
wire [`AWIDTH-1:0] raddr_accum4_matmul;
wire [`AWIDTH-1:0] raddr_accum5_matmul;
wire [`AWIDTH-1:0] raddr_accum6_matmul;
wire [`AWIDTH-1:0] raddr_accum7_matmul;
wire [`AWIDTH-1:0] raddr_accum8_matmul;
wire [`AWIDTH-1:0] raddr_accum9_matmul;
wire [`AWIDTH-1:0] raddr_accum10_matmul;
wire [`AWIDTH-1:0] raddr_accum11_matmul;
wire [`AWIDTH-1:0] raddr_accum12_matmul;
wire [`AWIDTH-1:0] raddr_accum13_matmul;
wire [`AWIDTH-1:0] raddr_accum14_matmul;
wire [`AWIDTH-1:0] raddr_accum15_matmul;
`endif

`ifdef DESIGN_SIZE_32
wire [`AWIDTH-1:0] start_waddr_accum0;
wire [`AWIDTH-1:0] start_waddr_accum1;
wire [`AWIDTH-1:0] start_waddr_accum2;
wire [`AWIDTH-1:0] start_waddr_accum3;
wire [`AWIDTH-1:0] start_waddr_accum4;
wire [`AWIDTH-1:0] start_waddr_accum5;
wire [`AWIDTH-1:0] start_waddr_accum6;
wire [`AWIDTH-1:0] start_waddr_accum7;
wire [`AWIDTH-1:0] start_waddr_accum8;
wire [`AWIDTH-1:0] start_waddr_accum9;
wire [`AWIDTH-1:0] start_waddr_accum10;
wire [`AWIDTH-1:0] start_waddr_accum11;
wire [`AWIDTH-1:0] start_waddr_accum12;
wire [`AWIDTH-1:0] start_waddr_accum13;
wire [`AWIDTH-1:0] start_waddr_accum14;
wire [`AWIDTH-1:0] start_waddr_accum15;
wire [`AWIDTH-1:0] start_waddr_accum16;
wire [`AWIDTH-1:0] start_waddr_accum17;
wire [`AWIDTH-1:0] start_waddr_accum18;
wire [`AWIDTH-1:0] start_waddr_accum19;
wire [`AWIDTH-1:0] start_waddr_accum20;
wire [`AWIDTH-1:0] start_waddr_accum21;
wire [`AWIDTH-1:0] start_waddr_accum22;
wire [`AWIDTH-1:0] start_waddr_accum23;
wire [`AWIDTH-1:0] start_waddr_accum24;
wire [`AWIDTH-1:0] start_waddr_accum25;
wire [`AWIDTH-1:0] start_waddr_accum26;
wire [`AWIDTH-1:0] start_waddr_accum27;
wire [`AWIDTH-1:0] start_waddr_accum28;
wire [`AWIDTH-1:0] start_waddr_accum29;
wire [`AWIDTH-1:0] start_waddr_accum30;
wire [`AWIDTH-1:0] start_waddr_accum31;

assign start_waddr_accum0 = 11'b0;
assign start_waddr_accum1 = 11'b0;
assign start_waddr_accum2 = 11'b0;
assign start_waddr_accum3 = 11'b0;
assign start_waddr_accum4 = 11'b0;
assign start_waddr_accum5 = 11'b0;
assign start_waddr_accum6 = 11'b0;
assign start_waddr_accum7 = 11'b0;
assign start_waddr_accum8 = 11'b0;
assign start_waddr_accum9 = 11'b0;
assign start_waddr_accum10 = 11'b0;
assign start_waddr_accum11 = 11'b0;
assign start_waddr_accum12 = 11'b0;
assign start_waddr_accum13 = 11'b0;
assign start_waddr_accum14 = 11'b0;
assign start_waddr_accum15 = 11'b0;
assign start_waddr_accum16 = 11'b0;
assign start_waddr_accum17 = 11'b0;
assign start_waddr_accum18 = 11'b0;
assign start_waddr_accum19 = 11'b0;
assign start_waddr_accum20 = 11'b0;
assign start_waddr_accum21 = 11'b0;
assign start_waddr_accum22 = 11'b0;
assign start_waddr_accum23 = 11'b0;
assign start_waddr_accum24 = 11'b0;
assign start_waddr_accum25 = 11'b0;
assign start_waddr_accum26 = 11'b0;
assign start_waddr_accum27 = 11'b0;
assign start_waddr_accum28 = 11'b0;
assign start_waddr_accum29 = 11'b0;
assign start_waddr_accum30 = 11'b0;
assign start_waddr_accum31 = 11'b0;

wire [`DWIDTH-1:0] rdata_accum0_pool;
wire [`DWIDTH-1:0] rdata_accum1_pool;
wire [`DWIDTH-1:0] rdata_accum2_pool;
wire [`DWIDTH-1:0] rdata_accum3_pool;
wire [`DWIDTH-1:0] rdata_accum4_pool;
wire [`DWIDTH-1:0] rdata_accum5_pool;
wire [`DWIDTH-1:0] rdata_accum6_pool;
wire [`DWIDTH-1:0] rdata_accum7_pool;
wire [`DWIDTH-1:0] rdata_accum8_pool;
wire [`DWIDTH-1:0] rdata_accum9_pool;
wire [`DWIDTH-1:0] rdata_accum10_pool;
wire [`DWIDTH-1:0] rdata_accum11_pool;
wire [`DWIDTH-1:0] rdata_accum12_pool;
wire [`DWIDTH-1:0] rdata_accum13_pool;
wire [`DWIDTH-1:0] rdata_accum14_pool;
wire [`DWIDTH-1:0] rdata_accum15_pool;
wire [`DWIDTH-1:0] rdata_accum16_pool;
wire [`DWIDTH-1:0] rdata_accum17_pool;
wire [`DWIDTH-1:0] rdata_accum18_pool;
wire [`DWIDTH-1:0] rdata_accum19_pool;
wire [`DWIDTH-1:0] rdata_accum20_pool;
wire [`DWIDTH-1:0] rdata_accum21_pool;
wire [`DWIDTH-1:0] rdata_accum22_pool;
wire [`DWIDTH-1:0] rdata_accum23_pool;
wire [`DWIDTH-1:0] rdata_accum24_pool;
wire [`DWIDTH-1:0] rdata_accum25_pool;
wire [`DWIDTH-1:0] rdata_accum26_pool;
wire [`DWIDTH-1:0] rdata_accum27_pool;
wire [`DWIDTH-1:0] rdata_accum28_pool;
wire [`DWIDTH-1:0] rdata_accum29_pool;
wire [`DWIDTH-1:0] rdata_accum30_pool;
wire [`DWIDTH-1:0] rdata_accum31_pool;
wire [`AWIDTH-1:0] raddr_accum0_pool;
wire [`AWIDTH-1:0] raddr_accum1_pool;
wire [`AWIDTH-1:0] raddr_accum2_pool;
wire [`AWIDTH-1:0] raddr_accum3_pool;
wire [`AWIDTH-1:0] raddr_accum4_pool;
wire [`AWIDTH-1:0] raddr_accum5_pool;
wire [`AWIDTH-1:0] raddr_accum6_pool;
wire [`AWIDTH-1:0] raddr_accum7_pool;
wire [`AWIDTH-1:0] raddr_accum8_pool;
wire [`AWIDTH-1:0] raddr_accum9_pool;
wire [`AWIDTH-1:0] raddr_accum10_pool;
wire [`AWIDTH-1:0] raddr_accum11_pool;
wire [`AWIDTH-1:0] raddr_accum12_pool;
wire [`AWIDTH-1:0] raddr_accum13_pool;
wire [`AWIDTH-1:0] raddr_accum14_pool;
wire [`AWIDTH-1:0] raddr_accum15_pool;
wire [`AWIDTH-1:0] raddr_accum16_pool;
wire [`AWIDTH-1:0] raddr_accum17_pool;
wire [`AWIDTH-1:0] raddr_accum18_pool;
wire [`AWIDTH-1:0] raddr_accum19_pool;
wire [`AWIDTH-1:0] raddr_accum20_pool;
wire [`AWIDTH-1:0] raddr_accum21_pool;
wire [`AWIDTH-1:0] raddr_accum22_pool;
wire [`AWIDTH-1:0] raddr_accum23_pool;
wire [`AWIDTH-1:0] raddr_accum24_pool;
wire [`AWIDTH-1:0] raddr_accum25_pool;
wire [`AWIDTH-1:0] raddr_accum26_pool;
wire [`AWIDTH-1:0] raddr_accum27_pool;
wire [`AWIDTH-1:0] raddr_accum28_pool;
wire [`AWIDTH-1:0] raddr_accum29_pool;
wire [`AWIDTH-1:0] raddr_accum30_pool;
wire [`AWIDTH-1:0] raddr_accum31_pool;

wire [`DWIDTH-1:0] rdata_accum0;
wire [`DWIDTH-1:0] rdata_accum1;
wire [`DWIDTH-1:0] rdata_accum2;
wire [`DWIDTH-1:0] rdata_accum3;
wire [`DWIDTH-1:0] rdata_accum4;
wire [`DWIDTH-1:0] rdata_accum5;
wire [`DWIDTH-1:0] rdata_accum6;
wire [`DWIDTH-1:0] rdata_accum7;
wire [`DWIDTH-1:0] rdata_accum8;
wire [`DWIDTH-1:0] rdata_accum9;
wire [`DWIDTH-1:0] rdata_accum10;
wire [`DWIDTH-1:0] rdata_accum11;
wire [`DWIDTH-1:0] rdata_accum12;
wire [`DWIDTH-1:0] rdata_accum13;
wire [`DWIDTH-1:0] rdata_accum14;
wire [`DWIDTH-1:0] rdata_accum15;
wire [`DWIDTH-1:0] rdata_accum16;
wire [`DWIDTH-1:0] rdata_accum17;
wire [`DWIDTH-1:0] rdata_accum18;
wire [`DWIDTH-1:0] rdata_accum19;
wire [`DWIDTH-1:0] rdata_accum20;
wire [`DWIDTH-1:0] rdata_accum21;
wire [`DWIDTH-1:0] rdata_accum22;
wire [`DWIDTH-1:0] rdata_accum23;
wire [`DWIDTH-1:0] rdata_accum24;
wire [`DWIDTH-1:0] rdata_accum25;
wire [`DWIDTH-1:0] rdata_accum26;
wire [`DWIDTH-1:0] rdata_accum27;
wire [`DWIDTH-1:0] rdata_accum28;
wire [`DWIDTH-1:0] rdata_accum29;
wire [`DWIDTH-1:0] rdata_accum30;
wire [`DWIDTH-1:0] rdata_accum31;
wire [`AWIDTH-1:0] raddr_accum0_matmul;
wire [`AWIDTH-1:0] raddr_accum1_matmul;
wire [`AWIDTH-1:0] raddr_accum2_matmul;
wire [`AWIDTH-1:0] raddr_accum3_matmul;
wire [`AWIDTH-1:0] raddr_accum4_matmul;
wire [`AWIDTH-1:0] raddr_accum5_matmul;
wire [`AWIDTH-1:0] raddr_accum6_matmul;
wire [`AWIDTH-1:0] raddr_accum7_matmul;
wire [`AWIDTH-1:0] raddr_accum8_matmul;
wire [`AWIDTH-1:0] raddr_accum9_matmul;
wire [`AWIDTH-1:0] raddr_accum10_matmul;
wire [`AWIDTH-1:0] raddr_accum11_matmul;
wire [`AWIDTH-1:0] raddr_accum12_matmul;
wire [`AWIDTH-1:0] raddr_accum13_matmul;
wire [`AWIDTH-1:0] raddr_accum14_matmul;
wire [`AWIDTH-1:0] raddr_accum15_matmul;
wire [`AWIDTH-1:0] raddr_accum16_matmul;
wire [`AWIDTH-1:0] raddr_accum17_matmul;
wire [`AWIDTH-1:0] raddr_accum18_matmul;
wire [`AWIDTH-1:0] raddr_accum19_matmul;
wire [`AWIDTH-1:0] raddr_accum20_matmul;
wire [`AWIDTH-1:0] raddr_accum21_matmul;
wire [`AWIDTH-1:0] raddr_accum22_matmul;
wire [`AWIDTH-1:0] raddr_accum23_matmul;
wire [`AWIDTH-1:0] raddr_accum24_matmul;
wire [`AWIDTH-1:0] raddr_accum25_matmul;
wire [`AWIDTH-1:0] raddr_accum26_matmul;
wire [`AWIDTH-1:0] raddr_accum27_matmul;
wire [`AWIDTH-1:0] raddr_accum28_matmul;
wire [`AWIDTH-1:0] raddr_accum29_matmul;
wire [`AWIDTH-1:0] raddr_accum30_matmul;
wire [`AWIDTH-1:0] raddr_accum31_matmul;
`endif

//Connections for bram a (activation/input matrix)
//bram_addr_a -> connected to u_matmul_4x4
//bram_rdata_a -> connected to u_matmul_4x4
//bram_wdata_a -> will come from the last block that is enabled
//bram_we_a -> will be 1 when the last block's data is available
//bram_en_a -> hardcoded to 1
assign bram_addr_a = (bram_a_wdata_available) ? bram_addr_a_for_writing : bram_addr_a_for_reading;
assign bram_en_a = 1'b1;
assign bram_we_a = (bram_a_wdata_available) ? {`DESIGN_SIZE{1'b1}} : {`DESIGN_SIZE{1'b0}};  
  
//Connections for bram b (weights matrix)
//bram_addr_b -> connected to u_matmul_4x4
//bram_rdata_b -> connected to u_matmul_4x4
//bram_wdata_b -> hardcoded to 0 (this block only reads from bram b)
//bram_we_b -> hardcoded to 0 (this block only reads from bram b)
//bram_en_b -> hardcoded to 1
assign bram_wdata_b = {`DESIGN_SIZE*`DWIDTH{1'b0}};
assign bram_en_b = 1'b1;
assign bram_we_b = {`DESIGN_SIZE{1'b0}};
  
////////////////////////////////////////////////////////////////
// BRAM matrix A (inputs/activations)
////////////////////////////////////////////////////////////////
ram #(.AW(`AWIDTH), .MW(`MASK_WIDTH), .DW(`DWIDTH)) matrix_A (
  .addr0(bram_addr_a),
  .d0(bram_wdata_a), 
  .we0(bram_we_a), 
  .q0(bram_rdata_a), 
  .addr1(bram_addr_a_ext),
  .d1(bram_wdata_a_ext), 
  .we1(bram_we_a_ext), 
  .q1(bram_rdata_a_ext), 
  .clk(clk_mem));

////////////////////////////////////////////////////////////////
// BRAM matrix B (weights)
////////////////////////////////////////////////////////////////
ram #(.AW(`AWIDTH), .MW(`MASK_WIDTH), .DW(`DWIDTH)) matrix_B (
  .addr0(bram_addr_b),
  .d0(bram_wdata_b), 
  .we0(bram_we_b), 
  .q0(bram_rdata_b), 
  .addr1(bram_addr_b_ext),
  .d1(bram_wdata_b_ext), 
  .we1(bram_we_b_ext), 
  .q1(bram_rdata_b_ext), 
  .clk(clk_mem));

////////////////////////////////////////////////////////////////
// Control logic that directs all the operation
////////////////////////////////////////////////////////////////
control u_control(
  .clk(clk),
  .reset(reset),
  .start_tpu(start_tpu),
  .enable_matmul(enable_matmul),
  .enable_norm(enable_norm),
  .enable_activation(enable_activation),
  .enable_pool(enable_pool),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul),
  .done_norm(done_norm),
  .done_pool(done_pool), 
  .done_activation(done_activation),
  .save_output_to_accum(save_output_to_accum),
  .done_tpu(done_tpu)
);

////////////////////////////////////////////////////////////////
// Configuration (register) block
////////////////////////////////////////////////////////////////
cfg u_cfg(
  .PCLK(clk),
  .PRESETn(resetn),
  .PADDR(PADDR),
  .PWRITE(PWRITE),
  .PSEL(PSEL),
  .PENABLE(PENABLE),
  .PWDATA(PWDATA),
  .PRDATA(PRDATA),
  .PREADY(PREADY),
  .start_tpu(start_tpu),
  .enable_matmul(enable_matmul),
  .enable_norm(enable_norm),
  .enable_pool(enable_pool),
  .enable_activation(enable_activation),
  .enable_conv_mode(enable_conv_mode),
  .mean(mean),
  .inv_var(inv_var),
  .pool_window_size(pool_window_size),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .num_matrices_A(num_matrices_A),
  .num_matrices_B(num_matrices_B),
  .matrix_size(matrix_size),
  .filter_size(filter_size),
  .pool_select(pool_select),
  .k_dimension(k_dimension), // Dimension of A = m x k, Dimension of B = k x n
  .accum_select(accum_select),
  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .save_output_to_accum(save_output_to_accum),
  .add_accum_to_output(add_accum_to_output),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .activation_type(activation_type),
  .conv_filter_height(conv_filter_height),
  .conv_filter_width(conv_filter_width),
  .conv_stride_horiz(conv_stride_horiz),
  .conv_stride_verti(conv_stride_verti),
  .conv_padding_left(conv_padding_left),
  .conv_padding_right(conv_padding_right),
  .conv_padding_top(conv_padding_top),
  .conv_padding_bottom(conv_padding_bottom),
  .num_channels_inp(num_channels_inp),
  .num_channels_out(num_channels_out),
  .inp_img_height(inp_img_height),
  .inp_img_width(inp_img_width),
  .out_img_height(out_img_height),
  .out_img_width(out_img_width),
  .batch_size(batch_size),
  .pe_reset(pe_reset),
  .done_tpu(done_tpu)
);

//TODO: We want to move the data setup part
//and the interface to BRAM_A and BRAM_B outside
//into its own modules. For now, it is all inside
//the matmul block

////////////////////////////////////////////////////////////////
//Matrix multiplier
//Note: the ports on this module to write data to bram c
//are not used in this top module. 
////////////////////////////////////////////////////////////////
`ifdef DESIGN_SIZE_32
matmul_32x32_systolic u_matmul(
`endif
`ifdef DESIGN_SIZE_16
matmul_16x16_systolic u_matmul(
`endif
`ifdef DESIGN_SIZE_8
matmul_8x8_systolic u_matmul(
`endif
`ifdef DESIGN_SIZE_4
matmul_4x4_systolic u_matmul(
`endif
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul),
  .num_matrices_A(num_matrices_A),
  .num_matrices_B(num_matrices_B),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .a_data(bram_rdata_a),
  .b_data(bram_rdata_b),
  .a_data_in(a_data_in_NC),
  .b_data_in(b_data_in_NC),
  .c_data_in({`DESIGN_SIZE*`DWIDTH{1'b0}}),
  .c_data_out(matmul_c_data_out),
  .a_data_out(a_data_out_NC),
  .b_data_out(b_data_out_NC),
  .a_addr(bram_addr_a_for_reading),
  .b_addr(bram_addr_b),
  .c_addr(bram_addr_c_NC),
  .c_data_available(matmul_c_data_available),
  `ifdef DESIGN_SIZE_32
  .matrixC310(matrixC310),
  .matrixC311(matrixC311),
  .matrixC312(matrixC312),
  .matrixC313(matrixC313),
  .matrixC314(matrixC314),
  .matrixC315(matrixC315),
  .matrixC316(matrixC316),
  .matrixC317(matrixC317),
  .matrixC318(matrixC318),
  .matrixC319(matrixC319),
  .matrixC3110(matrixC3110),
  .matrixC3111(matrixC3111),
  .matrixC3112(matrixC3112),
  .matrixC3113(matrixC3113),
  .matrixC3114(matrixC3114),
  .matrixC3115(matrixC3115),
  .matrixC3116(matrixC3116),
  .matrixC3117(matrixC3117),
  .matrixC3118(matrixC3118),
  .matrixC3119(matrixC3119),
  .matrixC3120(matrixC3120),
  .matrixC3121(matrixC3121),
  .matrixC3122(matrixC3122),
  .matrixC3123(matrixC3123),
  .matrixC3124(matrixC3124),
  .matrixC3125(matrixC3125),
  .matrixC3126(matrixC3126),
  .matrixC3127(matrixC3127),
  .matrixC3128(matrixC3128),
  .matrixC3129(matrixC3129),
  .matrixC3130(matrixC3130),
  .matrixC3131(matrixC3131),
  `endif
  `ifdef DESIGN_SIZE_16
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
  `endif
  `ifdef DESIGN_SIZE_8
  .matrixC70(matrixC70),
  .matrixC71(matrixC71),
  .matrixC72(matrixC72),
  .matrixC73(matrixC73),
  .matrixC74(matrixC74),
  .matrixC75(matrixC75),
  .matrixC76(matrixC76),
  .matrixC77(matrixC77),
  `endif
  `ifdef DESIGN_SIZE_4
  .matrixC30(matrixC30),
  .matrixC31(matrixC31),
  .matrixC32(matrixC32),
  .matrixC33(matrixC33),
  `endif
  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .a_loc(8'd0),
  .b_loc(8'd0)
);

////////////////////////////////////////////////////////////////
// Accumulator module
////////////////////////////////////////////////////////////////
accumulator u_accum (
  .clk(clk),
  .resetn(resetn),
  .k_dimension(k_dimension), // Dimension of A = m x k, Dimension of B = k x n
  .buffer_select(accum_select),
  .start_pooling(start_pool),  
  .done_pooling(done_pool),
  .wdata_available(matmul_c_data_available),
  `ifdef DESIGN_SIZE_8
  .start_waddr_accum0(start_waddr_accum0),
  .start_waddr_accum1(start_waddr_accum1),
  .start_waddr_accum2(start_waddr_accum2),
  .start_waddr_accum3(start_waddr_accum3),
  .start_waddr_accum4(start_waddr_accum4),
  .start_waddr_accum5(start_waddr_accum5),
  .start_waddr_accum6(start_waddr_accum6),
  .start_waddr_accum7(start_waddr_accum7),
  .wdata_accum0(matrixC70),
  .wdata_accum1(matrixC71),
  .wdata_accum2(matrixC72),
  .wdata_accum3(matrixC73),
  .wdata_accum4(matrixC74),
  .wdata_accum5(matrixC75),
  .wdata_accum6(matrixC76),
  .wdata_accum7(matrixC77),
  .raddr_accum0_matmul(raddr_accum0_matmul),
  .raddr_accum1_matmul(raddr_accum1_matmul),
  .raddr_accum2_matmul(raddr_accum2_matmul),
  .raddr_accum3_matmul(raddr_accum3_matmul),
  .raddr_accum4_matmul(raddr_accum4_matmul),
  .raddr_accum5_matmul(raddr_accum5_matmul),
  .raddr_accum6_matmul(raddr_accum6_matmul),
  .raddr_accum7_matmul(raddr_accum7_matmul),
  .raddr_accum0_pool(raddr_accum0_pool),
  .raddr_accum1_pool(raddr_accum1_pool),
  .raddr_accum2_pool(raddr_accum2_pool),
  .raddr_accum3_pool(raddr_accum3_pool),
  .raddr_accum4_pool(raddr_accum4_pool),
  .raddr_accum5_pool(raddr_accum5_pool),
  .raddr_accum6_pool(raddr_accum6_pool),
  .raddr_accum7_pool(raddr_accum7_pool),
  .rdata_accum0(rdata_accum0),
  .rdata_accum1(rdata_accum1),
  .rdata_accum2(rdata_accum2),
  .rdata_accum3(rdata_accum3),
  .rdata_accum4(rdata_accum4),
  .rdata_accum5(rdata_accum5),
  .rdata_accum6(rdata_accum6),
  .rdata_accum7(rdata_accum7),
  .rdata_accum0_pool(rdata_accum0_pool),
  .rdata_accum1_pool(rdata_accum1_pool),
  .rdata_accum2_pool(rdata_accum2_pool),
  .rdata_accum3_pool(rdata_accum3_pool),
  .rdata_accum4_pool(rdata_accum4_pool),
  .rdata_accum5_pool(rdata_accum5_pool),
  .rdata_accum6_pool(rdata_accum6_pool),
  .rdata_accum7_pool(rdata_accum7_pool)
  `endif
  `ifdef DESIGN_SIZE_16
  .start_waddr_accum0(start_waddr_accum0),
  .start_waddr_accum1(start_waddr_accum1),
  .start_waddr_accum2(start_waddr_accum2),
  .start_waddr_accum3(start_waddr_accum3),
  .start_waddr_accum4(start_waddr_accum4),
  .start_waddr_accum5(start_waddr_accum5),
  .start_waddr_accum6(start_waddr_accum6),
  .start_waddr_accum7(start_waddr_accum7),
  .start_waddr_accum8(start_waddr_accum8),
  .start_waddr_accum9(start_waddr_accum9),
  .start_waddr_accum10(start_waddr_accum10),
  .start_waddr_accum11(start_waddr_accum11),
  .start_waddr_accum12(start_waddr_accum12),
  .start_waddr_accum13(start_waddr_accum13),
  .start_waddr_accum14(start_waddr_accum14),
  .start_waddr_accum15(start_waddr_accum15),
  .wdata_accum0(matrixC150),
  .wdata_accum1(matrixC151),
  .wdata_accum2(matrixC152),
  .wdata_accum3(matrixC153),
  .wdata_accum4(matrixC154),
  .wdata_accum5(matrixC155),
  .wdata_accum6(matrixC156),
  .wdata_accum7(matrixC157),
  .wdata_accum8(matrixC158),
  .wdata_accum9(matrixC159),
  .wdata_accum10(matrixC1510),
  .wdata_accum11(matrixC1511),
  .wdata_accum12(matrixC1512),
  .wdata_accum13(matrixC1513),
  .wdata_accum14(matrixC1514),
  .wdata_accum15(matrixC1515),
  .raddr_accum0_matmul(raddr_accum0_matmul),
  .raddr_accum1_matmul(raddr_accum1_matmul),
  .raddr_accum2_matmul(raddr_accum2_matmul),
  .raddr_accum3_matmul(raddr_accum3_matmul),
  .raddr_accum4_matmul(raddr_accum4_matmul),
  .raddr_accum5_matmul(raddr_accum5_matmul),
  .raddr_accum6_matmul(raddr_accum6_matmul),
  .raddr_accum7_matmul(raddr_accum7_matmul),
  .raddr_accum9_matmul(raddr_accum9_matmul),
  .raddr_accum10_matmul(raddr_accum10_matmul),
  .raddr_accum11_matmul(raddr_accum11_matmul),
  .raddr_accum12_matmul(raddr_accum12_matmul),
  .raddr_accum13_matmul(raddr_accum13_matmul),
  .raddr_accum14_matmul(raddr_accum14_matmul),
  .raddr_accum15_matmul(raddr_accum15_matmul),
  .raddr_accum0_pool(raddr_accum0_pool),
  .raddr_accum1_pool(raddr_accum1_pool),
  .raddr_accum2_pool(raddr_accum2_pool),
  .raddr_accum3_pool(raddr_accum3_pool),
  .raddr_accum4_pool(raddr_accum4_pool),
  .raddr_accum5_pool(raddr_accum5_pool),
  .raddr_accum6_pool(raddr_accum6_pool),
  .raddr_accum7_pool(raddr_accum7_pool),
  .raddr_accum8_pool(raddr_accum8_pool),
  .raddr_accum9_pool(raddr_accum9_pool),
  .raddr_accum10_pool(raddr_accum10_pool),
  .raddr_accum11_pool(raddr_accum11_pool),
  .raddr_accum12_pool(raddr_accum12_pool),
  .raddr_accum13_pool(raddr_accum13_pool),
  .raddr_accum14_pool(raddr_accum14_pool),
  .raddr_accum15_pool(raddr_accum15_pool),
  .rdata_accum0(rdata_accum0),
  .rdata_accum1(rdata_accum1),
  .rdata_accum2(rdata_accum2),
  .rdata_accum3(rdata_accum3),
  .rdata_accum4(rdata_accum4),
  .rdata_accum5(rdata_accum5),
  .rdata_accum6(rdata_accum6),
  .rdata_accum7(rdata_accum7),
  .rdata_accum8(rdata_accum8),
  .rdata_accum9(rdata_accum9),
  .rdata_accum10(rdata_accum10),
  .rdata_accum11(rdata_accum11),
  .rdata_accum12(rdata_accum12),
  .rdata_accum13(rdata_accum13),
  .rdata_accum14(rdata_accum14),
  .rdata_accum15(rdata_accum15),
  .rdata_accum0_pool(rdata_accum0_pool),
  .rdata_accum1_pool(rdata_accum1_pool),
  .rdata_accum2_pool(rdata_accum2_pool),
  .rdata_accum3_pool(rdata_accum3_pool),
  .rdata_accum4_pool(rdata_accum4_pool),
  .rdata_accum5_pool(rdata_accum5_pool),
  .rdata_accum6_pool(rdata_accum6_pool),
  .rdata_accum7_pool(rdata_accum7_pool),
  .rdata_accum8_pool(rdata_accum8_pool),
  .rdata_accum9_pool(rdata_accum9_pool),
  .rdata_accum10_pool(rdata_accum10_pool),
  .rdata_accum11_pool(rdata_accum11_pool),
  .rdata_accum12_pool(rdata_accum12_pool),
  .rdata_accum13_pool(rdata_accum13_pool),
  .rdata_accum14_pool(rdata_accum14_pool),
  .rdata_accum15_pool(rdata_accum15_pool)
  `endif
  `ifdef DESIGN_SIZE_32
  .start_waddr_accum0(start_waddr_accum0),
  .start_waddr_accum1(start_waddr_accum1),
  .start_waddr_accum2(start_waddr_accum2),
  .start_waddr_accum3(start_waddr_accum3),
  .start_waddr_accum4(start_waddr_accum4),
  .start_waddr_accum5(start_waddr_accum5),
  .start_waddr_accum6(start_waddr_accum6),
  .start_waddr_accum7(start_waddr_accum7),
  .start_waddr_accum8(start_waddr_accum8),
  .start_waddr_accum9(start_waddr_accum9),
  .start_waddr_accum10(start_waddr_accum10),
  .start_waddr_accum11(start_waddr_accum11),
  .start_waddr_accum12(start_waddr_accum12),
  .start_waddr_accum13(start_waddr_accum13),
  .start_waddr_accum14(start_waddr_accum14),
  .start_waddr_accum15(start_waddr_accum15),
  .start_waddr_accum16(start_waddr_accum16),
  .start_waddr_accum17(start_waddr_accum17),
  .start_waddr_accum18(start_waddr_accum18),
  .start_waddr_accum19(start_waddr_accum19),
  .start_waddr_accum20(start_waddr_accum20),
  .start_waddr_accum21(start_waddr_accum21),
  .start_waddr_accum22(start_waddr_accum22),
  .start_waddr_accum23(start_waddr_accum23),
  .start_waddr_accum24(start_waddr_accum24),
  .start_waddr_accum25(start_waddr_accum25),
  .start_waddr_accum26(start_waddr_accum26),
  .start_waddr_accum27(start_waddr_accum27),
  .start_waddr_accum28(start_waddr_accum28),
  .start_waddr_accum29(start_waddr_accum29),
  .start_waddr_accum30(start_waddr_accum30),
  .start_waddr_accum31(start_waddr_accum31),
  .wdata_accum0(matrixC310),
  .wdata_accum1(matrixC311),
  .wdata_accum2(matrixC312),
  .wdata_accum3(matrixC313),
  .wdata_accum4(matrixC314),
  .wdata_accum5(matrixC315),
  .wdata_accum6(matrixC316),
  .wdata_accum7(matrixC317),
  .wdata_accum8(matrixC318),
  .wdata_accum9(matrixC319),
  .wdata_accum10(matrixC3110),
  .wdata_accum11(matrixC3111),
  .wdata_accum12(matrixC3112),
  .wdata_accum13(matrixC3113),
  .wdata_accum14(matrixC3114),
  .wdata_accum15(matrixC3115),
  .wdata_accum16(matrixC3116),
  .wdata_accum17(matrixC3117),
  .wdata_accum18(matrixC3118),
  .wdata_accum19(matrixC3119),
  .wdata_accum20(matrixC3120),
  .wdata_accum21(matrixC3121),
  .wdata_accum22(matrixC3122),
  .wdata_accum23(matrixC3123),
  .wdata_accum24(matrixC3124),
  .wdata_accum25(matrixC3125),
  .wdata_accum26(matrixC3126),
  .wdata_accum27(matrixC3127),
  .wdata_accum28(matrixC3128),
  .wdata_accum29(matrixC3129),
  .wdata_accum30(matrixC3130),
  .wdata_accum31(matrixC3131),
  .raddr_accum0_matmul(raddr_accum0_matmul),
  .raddr_accum1_matmul(raddr_accum1_matmul),
  .raddr_accum2_matmul(raddr_accum2_matmul),
  .raddr_accum3_matmul(raddr_accum3_matmul),
  .raddr_accum4_matmul(raddr_accum4_matmul),
  .raddr_accum5_matmul(raddr_accum5_matmul),
  .raddr_accum6_matmul(raddr_accum6_matmul),
  .raddr_accum7_matmul(raddr_accum7_matmul),
  .rdata_accum0_matmul(rdata_accum0_matmul),
  .raddr_accum9_matmul(raddr_accum9_matmul),
  .raddr_accum10_matmul(raddr_accum10_matmul),
  .raddr_accum11_matmul(raddr_accum11_matmul),
  .raddr_accum12_matmul(raddr_accum12_matmul),
  .raddr_accum13_matmul(raddr_accum13_matmul),
  .raddr_accum14_matmul(raddr_accum14_matmul),
  .raddr_accum15_matmul(raddr_accum15_matmul),
  .raddr_accum16_matmul(raddr_accum16_matmul),
  .raddr_accum17_matmul(raddr_accum17_matmul),
  .raddr_accum18_matmul(raddr_accum18_matmul),
  .raddr_accum19_matmul(raddr_accum19_matmul),
  .raddr_accum20_matmul(raddr_accum20_matmul),
  .raddr_accum21_matmul(raddr_accum21_matmul),
  .raddr_accum22_matmul(raddr_accum22_matmul),
  .raddr_accum23_matmul(raddr_accum23_matmul),
  .raddr_accum24_matmul(raddr_accum24_matmul),
  .raddr_accum25_matmul(raddr_accum25_matmul),
  .raddr_accum26_matmul(raddr_accum26_matmul),
  .raddr_accum27_matmul(raddr_accum27_matmul),
  .raddr_accum28_matmul(raddr_accum28_matmul),
  .raddr_accum29_matmul(raddr_accum29_matmul),
  .raddr_accum30_matmul(raddr_accum30_matmul),
  .raddr_accum31_matmul(raddr_accum31_matmul),
  .raddr_accum0_pool(raddr_accum0_pool),
  .raddr_accum1_pool(raddr_accum1_pool),
  .raddr_accum2_pool(raddr_accum2_pool),
  .raddr_accum3_pool(raddr_accum3_pool),
  .raddr_accum4_pool(raddr_accum4_pool),
  .raddr_accum5_pool(raddr_accum5_pool),
  .raddr_accum6_pool(raddr_accum6_pool),
  .raddr_accum7_pool(raddr_accum7_pool),
  .raddr_accum8_pool(raddr_accum8_pool),
  .raddr_accum9_pool(raddr_accum9_pool),
  .raddr_accum10_pool(raddr_accum10_pool),
  .raddr_accum11_pool(raddr_accum11_pool),
  .raddr_accum12_pool(raddr_accum12_pool),
  .raddr_accum13_pool(raddr_accum13_pool),
  .raddr_accum14_pool(raddr_accum14_pool),
  .raddr_accum15_pool(raddr_accum15_pool),
  .raddr_accum16_pool(raddr_accum16_pool),
  .raddr_accum17_pool(raddr_accum17_pool),
  .raddr_accum18_pool(raddr_accum18_pool),
  .raddr_accum19_pool(raddr_accum19_pool),
  .raddr_accum20_pool(raddr_accum20_pool),
  .raddr_accum21_pool(raddr_accum21_pool),
  .raddr_accum22_pool(raddr_accum22_pool),
  .raddr_accum23_pool(raddr_accum23_pool),
  .raddr_accum24_pool(raddr_accum24_pool),
  .raddr_accum25_pool(raddr_accum25_pool),
  .raddr_accum26_pool(raddr_accum26_pool),
  .raddr_accum27_pool(raddr_accum27_pool),
  .raddr_accum28_pool(raddr_accum28_pool),
  .raddr_accum29_pool(raddr_accum29_pool),
  .raddr_accum30_pool(raddr_accum30_pool),
  .raddr_accum31_pool(raddr_accum31_pool),
  .rdata_accum0(rdata_accum0),
  .rdata_accum1(rdata_accum1),
  .rdata_accum2(rdata_accum2),
  .rdata_accum3(rdata_accum3),
  .rdata_accum4(rdata_accum4),
  .rdata_accum5(rdata_accum5),
  .rdata_accum6(rdata_accum6),
  .rdata_accum7(rdata_accum7),
  .rdata_accum8(rdata_accum8),
  .rdata_accum9(rdata_accum9),
  .rdata_accum10(rdata_accum10),
  .rdata_accum11(rdata_accum11),
  .rdata_accum12(rdata_accum12),
  .rdata_accum13(rdata_accum13),
  .rdata_accum14(rdata_accum14),
  .rdata_accum15(rdata_accum15),
  .rdata_accum16(rdata_accum16),
  .rdata_accum17(rdata_accum17),
  .rdata_accum18(rdata_accum18),
  .rdata_accum19(rdata_accum19),
  .rdata_accum20(rdata_accum20),
  .rdata_accum21(rdata_accum21),
  .rdata_accum22(rdata_accum22),
  .rdata_accum23(rdata_accum23),
  .rdata_accum24(rdata_accum24),
  .rdata_accum25(rdata_accum25),
  .rdata_accum26(rdata_accum26),
  .rdata_accum27(rdata_accum27),
  .rdata_accum28(rdata_accum28),
  .rdata_accum29(rdata_accum29),
  .rdata_accum30(rdata_accum30),
  .rdata_accum31(rdata_accum31),
  .rdata_accum0_pool(rdata_accum0_pool),
  .rdata_accum1_pool(rdata_accum1_pool),
  .rdata_accum2_pool(rdata_accum2_pool),
  .rdata_accum3_pool(rdata_accum3_pool),
  .rdata_accum4_pool(rdata_accum4_pool),
  .rdata_accum5_pool(rdata_accum5_pool),
  .rdata_accum6_pool(rdata_accum6_pool),
  .rdata_accum7_pool(rdata_accum7_pool),
  .rdata_accum8_pool(rdata_accum8_pool),
  .rdata_accum9_pool(rdata_accum9_pool),
  .rdata_accum10_pool(rdata_accum10_pool),
  .rdata_accum11_pool(rdata_accum11_pool),
  .rdata_accum12_pool(rdata_accum12_pool),
  .rdata_accum13_pool(rdata_accum13_pool),
  .rdata_accum14_pool(rdata_accum14_pool),
  .rdata_accum15_pool(rdata_accum15_pool),
  .rdata_accum16_pool(rdata_accum16_pool),
  .rdata_accum17_pool(rdata_accum17_pool),
  .rdata_accum18_pool(rdata_accum18_pool),
  .rdata_accum19_pool(rdata_accum19_pool),
  .rdata_accum20_pool(rdata_accum20_pool),
  .rdata_accum21_pool(rdata_accum21_pool),
  .rdata_accum22_pool(rdata_accum22_pool),
  .rdata_accum23_pool(rdata_accum23_pool),
  .rdata_accum24_pool(rdata_accum24_pool),
  .rdata_accum25_pool(rdata_accum25_pool),
  .rdata_accum26_pool(rdata_accum26_pool),
  .rdata_accum27_pool(rdata_accum27_pool),
  .rdata_accum28_pool(rdata_accum28_pool),
  .rdata_accum29_pool(rdata_accum29_pool),
  .rdata_accum30_pool(rdata_accum30_pool),
  .rdata_accum31_pool(rdata_accum31_pool)
  `endif
);

wire [`DWIDTH-1:0] pool0;
wire [`DWIDTH-1:0] pool1;
wire [`DWIDTH-1:0] pool2;
wire [`DWIDTH-1:0] pool3;
wire [`DWIDTH-1:0] pool4;
wire [`DWIDTH-1:0] pool5;
wire [`DWIDTH-1:0] pool6;
wire [`DWIDTH-1:0] pool7;
wire [`DWIDTH-1:0] pool8;
wire [`DWIDTH-1:0] pool9;
wire [`DWIDTH-1:0] pool10;
wire [`DWIDTH-1:0] pool11;
wire [`DWIDTH-1:0] pool12;
wire [`DWIDTH-1:0] pool13;
wire [`DWIDTH-1:0] pool14;
wire [`DWIDTH-1:0] pool15;
wire [`DWIDTH-1:0] pool16;
wire [`DWIDTH-1:0] pool17;
wire [`DWIDTH-1:0] pool18;
wire [`DWIDTH-1:0] pool19;
wire [`DWIDTH-1:0] pool20;
wire [`DWIDTH-1:0] pool21;
wire [`DWIDTH-1:0] pool22;
wire [`DWIDTH-1:0] pool23;
wire [`DWIDTH-1:0] pool24;
wire [`DWIDTH-1:0] pool25;
wire [`DWIDTH-1:0] pool26;
wire [`DWIDTH-1:0] pool27;
wire [`DWIDTH-1:0] pool28;
wire [`DWIDTH-1:0] pool29;
wire [`DWIDTH-1:0] pool30;
wire [`DWIDTH-1:0] pool31;

wire [`DWIDTH-1:0] norm_data_out0;
wire [`DWIDTH-1:0] norm_data_out1;
wire [`DWIDTH-1:0] norm_data_out2;
wire [`DWIDTH-1:0] norm_data_out3;
wire [`DWIDTH-1:0] norm_data_out4;
wire [`DWIDTH-1:0] norm_data_out5;
wire [`DWIDTH-1:0] norm_data_out6;
wire [`DWIDTH-1:0] norm_data_out7;
wire [`DWIDTH-1:0] norm_data_out8;
wire [`DWIDTH-1:0] norm_data_out9;
wire [`DWIDTH-1:0] norm_data_out10;
wire [`DWIDTH-1:0] norm_data_out11;
wire [`DWIDTH-1:0] norm_data_out12;
wire [`DWIDTH-1:0] norm_data_out13;
wire [`DWIDTH-1:0] norm_data_out14;
wire [`DWIDTH-1:0] norm_data_out15;
wire [`DWIDTH-1:0] norm_data_out16;
wire [`DWIDTH-1:0] norm_data_out17;
wire [`DWIDTH-1:0] norm_data_out18;
wire [`DWIDTH-1:0] norm_data_out19;
wire [`DWIDTH-1:0] norm_data_out20;
wire [`DWIDTH-1:0] norm_data_out21;
wire [`DWIDTH-1:0] norm_data_out22;
wire [`DWIDTH-1:0] norm_data_out23;
wire [`DWIDTH-1:0] norm_data_out24;
wire [`DWIDTH-1:0] norm_data_out25;
wire [`DWIDTH-1:0] norm_data_out26;
wire [`DWIDTH-1:0] norm_data_out27;
wire [`DWIDTH-1:0] norm_data_out28;
wire [`DWIDTH-1:0] norm_data_out29;
wire [`DWIDTH-1:0] norm_data_out30;
wire [`DWIDTH-1:0] norm_data_out31;

wire [`DWIDTH-1:0] act_data_out0;
wire [`DWIDTH-1:0] act_data_out1;
wire [`DWIDTH-1:0] act_data_out2;
wire [`DWIDTH-1:0] act_data_out3;
wire [`DWIDTH-1:0] act_data_out4;
wire [`DWIDTH-1:0] act_data_out5;
wire [`DWIDTH-1:0] act_data_out6;
wire [`DWIDTH-1:0] act_data_out7;
wire [`DWIDTH-1:0] act_data_out8;
wire [`DWIDTH-1:0] act_data_out9;
wire [`DWIDTH-1:0] act_data_out10;
wire [`DWIDTH-1:0] act_data_out11;
wire [`DWIDTH-1:0] act_data_out12;
wire [`DWIDTH-1:0] act_data_out13;
wire [`DWIDTH-1:0] act_data_out14;
wire [`DWIDTH-1:0] act_data_out15;
wire [`DWIDTH-1:0] act_data_out16;
wire [`DWIDTH-1:0] act_data_out17;
wire [`DWIDTH-1:0] act_data_out18;
wire [`DWIDTH-1:0] act_data_out19;
wire [`DWIDTH-1:0] act_data_out20;
wire [`DWIDTH-1:0] act_data_out21;
wire [`DWIDTH-1:0] act_data_out22;
wire [`DWIDTH-1:0] act_data_out23;
wire [`DWIDTH-1:0] act_data_out24;
wire [`DWIDTH-1:0] act_data_out25;
wire [`DWIDTH-1:0] act_data_out26;
wire [`DWIDTH-1:0] act_data_out27;
wire [`DWIDTH-1:0] act_data_out28;
wire [`DWIDTH-1:0] act_data_out29;
wire [`DWIDTH-1:0] act_data_out30;
wire [`DWIDTH-1:0] act_data_out31;

////////////////////////////////////////////////////////////////
// Pooling module
////////////////////////////////////////////////////////////////
pooling u_pooling (
  .clk(clk),
  .resetn(resetn),
  .matrix_size(matrix_size),
  .filter_size(filter_size),
  .enable_pool(enable_pool),
  .pool_select(pool_select),
  .start_pooling(start_pool),
  .pool_norm_valid(pool_norm_valid),
  `ifdef DESIGN_SIZE_8
  .raddr_accum0_pool(raddr_accum0_pool),
  .raddr_accum1_pool(raddr_accum1_pool),
  .raddr_accum2_pool(raddr_accum2_pool),
  .raddr_accum3_pool(raddr_accum3_pool),
  .raddr_accum4_pool(raddr_accum4_pool),
  .raddr_accum5_pool(raddr_accum5_pool),
  .raddr_accum6_pool(raddr_accum6_pool),
  .raddr_accum7_pool(raddr_accum7_pool),
  .rdata_accum0_pool(rdata_accum0_pool),
  .rdata_accum1_pool(rdata_accum1_pool),
  .rdata_accum2_pool(rdata_accum2_pool),
  .rdata_accum3_pool(rdata_accum3_pool),
  .rdata_accum4_pool(rdata_accum4_pool),
  .rdata_accum5_pool(rdata_accum5_pool),
  .rdata_accum6_pool(rdata_accum6_pool),
  .rdata_accum7_pool(rdata_accum7_pool),
  .pool0(pool0),
  .pool1(pool1),
  .pool2(pool2),
  .pool3(pool3),
  .pool4(pool4),
  .pool5(pool5),
  .pool6(pool6),
  .pool7(pool7)  
  `endif
  `ifdef DESIGN_SIZE_16
  .raddr_accum0_pool(raddr_accum0_pool),
  .raddr_accum1_pool(raddr_accum1_pool),
  .raddr_accum2_pool(raddr_accum2_pool),
  .raddr_accum3_pool(raddr_accum3_pool),
  .raddr_accum4_pool(raddr_accum4_pool),
  .raddr_accum5_pool(raddr_accum5_pool),
  .raddr_accum6_pool(raddr_accum6_pool),
  .raddr_accum7_pool(raddr_accum7_pool),
  .raddr_accum8_pool(raddr_accum8_pool),
  .raddr_accum9_pool(raddr_accum9_pool),
  .raddr_accum10_pool(raddr_accum10_pool),
  .raddr_accum11_pool(raddr_accum11_pool),
  .raddr_accum12_pool(raddr_accum12_pool),
  .raddr_accum13_pool(raddr_accum13_pool),
  .raddr_accum14_pool(raddr_accum14_pool),
  .raddr_accum15_pool(raddr_accum15_pool),
  .pool0(pool0),
  .pool1(pool1),
  .pool2(pool2),
  .pool3(pool3),
  .pool4(pool4),
  .pool5(pool5),
  .pool6(pool6),
  .pool7(pool7),
  .pool8(pool8),
  .pool9(pool9),
  .pool10(pool10),
  .pool11(pool11),
  .pool12(pool12),
  .pool13(pool13),
  .pool14(pool14),
  .pool15(pool15),
  `endif
  `ifdef DESIGN_SIZE_32
  .raddr_accum0_pool(raddr_accum0_pool),
  .raddr_accum1_pool(raddr_accum1_pool),
  .raddr_accum2_pool(raddr_accum2_pool),
  .raddr_accum3_pool(raddr_accum3_pool),
  .raddr_accum4_pool(raddr_accum4_pool),
  .raddr_accum5_pool(raddr_accum5_pool),
  .raddr_accum6_pool(raddr_accum6_pool),
  .raddr_accum7_pool(raddr_accum7_pool),
  .raddr_accum8_pool(raddr_accum8_pool),
  .raddr_accum9_pool(raddr_accum9_pool),
  .raddr_accum10_pool(raddr_accum10_pool),
  .raddr_accum11_pool(raddr_accum11_pool),
  .raddr_accum12_pool(raddr_accum12_pool),
  .raddr_accum13_pool(raddr_accum13_pool),
  .raddr_accum14_pool(raddr_accum14_pool),
  .raddr_accum15_pool(raddr_accum15_pool),
  .raddr_accum16_pool(raddr_accum16_pool),
  .raddr_accum17_pool(raddr_accum17_pool),
  .raddr_accum18_pool(raddr_accum18_pool),
  .raddr_accum19_pool(raddr_accum19_pool),
  .raddr_accum20_pool(raddr_accum20_pool),
  .raddr_accum21_pool(raddr_accum21_pool),
  .raddr_accum22_pool(raddr_accum22_pool),
  .raddr_accum23_pool(raddr_accum23_pool),
  .raddr_accum24_pool(raddr_accum24_pool),
  .raddr_accum25_pool(raddr_accum25_pool),
  .raddr_accum26_pool(raddr_accum26_pool),
  .raddr_accum27_pool(raddr_accum27_pool),
  .raddr_accum28_pool(raddr_accum28_pool),
  .raddr_accum29_pool(raddr_accum29_pool),
  .raddr_accum30_pool(raddr_accum30_pool),
  .raddr_accum31_pool(raddr_accum31_pool),
  .pool0(pool0),
  .pool1(pool1),
  .pool2(pool2),
  .pool3(pool3),
  .pool4(pool4),
  .pool5(pool5),
  .pool6(pool6),
  .pool7(pool7),
  .pool8(pool8),
  .pool9(pool9),
  .pool10(pool10),
  .pool11(pool11),
  .pool12(pool12),
  .pool13(pool13),
  .pool14(pool14),
  .pool15(pool15),
  .pool16(pool16),
  .pool17(pool17),
  .pool18(pool18),
  .pool19(pool19),
  .pool20(pool20),
  .pool21(pool21),
  .pool22(pool22),
  .pool23(pool23),
  .pool24(pool24),
  .pool25(pool25),
  .pool26(pool26),
  .pool27(pool27),
  .pool28(pool28),
  .pool29(pool29),
  .pool30(pool30),
  .pool31(pool31),
  `endif
);


////////////////////////////////////////////////////////////////
// Normalization module
////////////////////////////////////////////////////////////////
norm u_norm(
  .enable_norm(enable_norm),
  .enable_pool(enable_pool),
  .mean(mean),
  .inv_var(inv_var),
  .in_data_available(pool_norm_valid),
  `ifdef DESIGN_SIZE_8
  .inp_data0(pool0),
  .inp_data1(pool1),
  .inp_data2(pool2),
  .inp_data3(pool3),
  .inp_data4(pool4),
  .inp_data5(pool5),
  .inp_data6(pool6),
  .inp_data7(pool7),
  .out_data0(norm_data_out0),
  .out_data1(norm_data_out1),
  .out_data2(norm_data_out2),
  .out_data3(norm_data_out3),
  .out_data4(norm_data_out4),
  .out_data5(norm_data_out5),
  .out_data6(norm_data_out6),
  .out_data7(norm_data_out7),
  `endif
  `ifdef DESIGN_SIZE_16
  .inp_data0(pool0),
  .inp_data1(pool1),
  .inp_data2(pool2),
  .inp_data3(pool3),
  .inp_data4(pool4),
  .inp_data5(pool5),
  .inp_data6(pool6),
  .inp_data7(pool7),
  .inp_data8(pool8),
  .inp_data9(pool9),
  .inp_data10(pool10),
  .inp_data11(pool11),
  .inp_data12(pool12),
  .inp_data13(pool13),
  .inp_data14(pool14),
  .inp_data15(pool15),
  .out_data0(norm_data_out0),
  .out_data1(norm_data_out1),
  .out_data2(norm_data_out2),
  .out_data3(norm_data_out3),
  .out_data4(norm_data_out4),
  .out_data5(norm_data_out5),
  .out_data6(norm_data_out6),
  .out_data7(norm_data_out7),
  .out_data8(norm_data_out8),
  .out_data9(norm_data_out9),
  .out_data10(norm_data_out10),
  .out_data11(norm_data_out11),
  .out_data12(norm_data_out12),
  .out_data13(norm_data_out13),
  .out_data14(norm_data_out14),
  .out_data15(norm_data_out15),
  `endif
  `ifdef DESIGN_SIZE_32
  .inp_data0(pool0),
  .inp_data1(pool1),
  .inp_data2(pool2),
  .inp_data3(pool3),
  .inp_data4(pool4),
  .inp_data5(pool5),
  .inp_data6(pool6),
  .inp_data7(pool7),
  .inp_data8(pool8),
  .inp_data9(pool9),
  .inp_data10(pool10),
  .inp_data11(pool11),
  .inp_data12(pool12),
  .inp_data13(pool13),
  .inp_data14(pool14),
  .inp_data15(pool15),
  .inp_data16(pool16),
  .inp_data17(pool17),
  .inp_data18(pool18),
  .inp_data19(pool19),
  .inp_data20(pool20),
  .inp_data21(pool21),
  .inp_data22(pool22),
  .inp_data23(pool23),
  .inp_data24(pool24),
  .inp_data25(pool25),
  .inp_data26(pool26),
  .inp_data27(pool27),
  .inp_data28(pool28),
  .inp_data29(pool29),
  .inp_data30(pool30),
  .inp_data31(pool31),
  .out_data0(norm_data_out0),
  .out_data1(norm_data_out1),
  .out_data2(norm_data_out2),
  .out_data3(norm_data_out3),
  .out_data4(norm_data_out4),
  .out_data5(norm_data_out5),
  .out_data6(norm_data_out6),
  .out_data7(norm_data_out7),
  .out_data8(norm_data_out8),
  .out_data9(norm_data_out9),
  .out_data10(norm_data_out10),
  .out_data11(norm_data_out11),
  .out_data12(norm_data_out12),
  .out_data13(norm_data_out13),
  .out_data14(norm_data_out14),
  .out_data15(norm_data_out15),
  .out_data16(norm_data_out16),
  .out_data17(norm_data_out17),
  .out_data18(norm_data_out18),
  .out_data19(norm_data_out19),
  .out_data20(norm_data_out20),
  .out_data21(norm_data_out21),
  .out_data22(norm_data_out22),
  .out_data23(norm_data_out23),
  .out_data24(norm_data_out24),
  .out_data25(norm_data_out25),
  .out_data26(norm_data_out26),
  .out_data27(norm_data_out27),
  .out_data28(norm_data_out28),
  .out_data29(norm_data_out29),
  .out_data30(norm_data_out30),
  .out_data31(norm_data_out31),
  `endif
  .out_data_available(norm_out_data_available),
  .validity_mask(validity_mask_a_rows),
  .done_norm(done_norm),
  .clk(clk),
  .reset(reset)
);

////////////////////////////////////////////////////////////////
// Activation module
////////////////////////////////////////////////////////////////
activation u_activation(
  .activation_type(activation_type),
  .enable_activation(enable_activation),
  .enable_pool(enable_pool),
  .in_data_available(norm_out_data_available),
  `ifdef DESIGN_SIZE_8
  .inp_data0(norm_data_out0),
  .inp_data1(norm_data_out1),
  .inp_data2(norm_data_out2),
  .inp_data3(norm_data_out3),
  .inp_data4(norm_data_out4),
  .inp_data5(norm_data_out5),
  .inp_data6(norm_data_out6),
  .inp_data7(norm_data_out7),
  .out_data0(act_data_out0),
  .out_data1(act_data_out1),
  .out_data2(act_data_out2),
  .out_data3(act_data_out3),
  .out_data4(act_data_out4),
  .out_data5(act_data_out5),
  .out_data6(act_data_out6),
  .out_data7(act_data_out7),
  `endif
  `ifdef DESIGN_SIZE_16
  .inp_data0(norm_data_out0),
  .inp_data1(norm_data_out1),
  .inp_data2(norm_data_out2),
  .inp_data3(norm_data_out3),
  .inp_data4(norm_data_out4),
  .inp_data5(norm_data_out5),
  .inp_data6(norm_data_out6),
  .inp_data7(norm_data_out7),
  .inp_data8(norm_data_out8),
  .inp_data9(norm_data_out9),
  .inp_data10(norm_data_out10),
  .inp_data11(norm_data_out11),
  .inp_data12(norm_data_out12),
  .inp_data13(norm_data_out13),
  .inp_data14(norm_data_out14),
  .inp_data15(norm_data_out15),
  .out_data0(act_data_out0),
  .out_data1(act_data_out1),
  .out_data2(act_data_out2),
  .out_data3(act_data_out3),
  .out_data4(act_data_out4),
  .out_data5(act_data_out5),
  .out_data6(act_data_out6),
  .out_data7(act_data_out7),
  .out_data8(act_data_out8),
  .out_data9(act_data_out9),
  .out_data10(act_data_out10),
  .out_data11(act_data_out11),
  .out_data12(act_data_out12),
  .out_data13(act_data_out13),
  .out_data14(act_data_out14),
  .out_data15(act_data_out15),
  `endif
  `ifdef DESIGN_SIZE_32
  .inp_data0(norm_data_out0),
  .inp_data1(norm_data_out1),
  .inp_data2(norm_data_out2),
  .inp_data3(norm_data_out3),
  .inp_data4(norm_data_out4),
  .inp_data5(norm_data_out5),
  .inp_data6(norm_data_out6),
  .inp_data7(norm_data_out7),
  .inp_data8(norm_data_out8),
  .inp_data9(norm_data_out9),
  .inp_data10(norm_data_out10),
  .inp_data11(norm_data_out11),
  .inp_data12(norm_data_out12),
  .inp_data13(norm_data_out13),
  .inp_data14(norm_data_out14),
  .inp_data15(norm_data_out15),
  .inp_data16(norm_data_out16),
  .inp_data17(norm_data_out17),
  .inp_data18(norm_data_out18),
  .inp_data19(norm_data_out19),
  .inp_data20(norm_data_out20),
  .inp_data21(norm_data_out21),
  .inp_data22(norm_data_out22),
  .inp_data23(norm_data_out23),
  .inp_data24(norm_data_out24),
  .inp_data25(norm_data_out25),
  .inp_data26(norm_data_out26),
  .inp_data27(norm_data_out27),
  .inp_data28(norm_data_out28),
  .inp_data29(norm_data_out29),
  .inp_data30(norm_data_out30),
  .inp_data31(norm_data_out31),
  .out_data0(act_data_out0),
  .out_data1(act_data_out1),
  .out_data2(act_data_out2),
  .out_data3(act_data_out3),
  .out_data4(act_data_out4),
  .out_data5(act_data_out5),
  .out_data6(act_data_out6),
  .out_data7(act_data_out7),
  .out_data8(act_data_out8),
  .out_data9(act_data_out9),
  .out_data10(act_data_out10),
  .out_data11(act_data_out11),
  .out_data12(act_data_out12),
  .out_data13(act_data_out13),
  .out_data14(act_data_out14),
  .out_data15(act_data_out15),
  .out_data16(act_data_out16),
  .out_data17(act_data_out17),
  .out_data18(act_data_out18),
  .out_data19(act_data_out19),
  .out_data20(act_data_out20),
  .out_data21(act_data_out21),
  .out_data22(act_data_out22),
  .out_data23(act_data_out23),
  .out_data24(act_data_out24),
  .out_data25(act_data_out25),
  .out_data26(act_data_out26),
  .out_data27(act_data_out27),
  .out_data28(act_data_out28),
  .out_data29(act_data_out29),
  .out_data30(act_data_out30),
  .out_data31(act_data_out31),
  `endif
  .out_data_available(activation_out_data_available),
  .validity_mask(validity_mask_a_rows),
  .done_activation(done_activation),
  .clk(clk),
  .reset(reset)
);

//Interface to BRAM to write the output.
//Ideally, we could remove this flop stage. But then we'd
//have to generate the address for the output BRAM in each
//block that could potentially write the output. 

reg activation_out_data_available1;
reg activation_out_data_available2;
reg activation_out_data_available3;
reg activation_out_data_available4;
reg activation_out_data_available5;
reg activation_out_data_available6;
reg activation_out_data_available7;

always @(posedge clk) begin
    activation_out_data_available1 <= activation_out_data_available;
    activation_out_data_available2 <= activation_out_data_available1;
    activation_out_data_available3 <= activation_out_data_available2;
    activation_out_data_available4 <= activation_out_data_available3;
    activation_out_data_available5 <= activation_out_data_available4;
    activation_out_data_available6 <= activation_out_data_available5;
    activation_out_data_available7 <= activation_out_data_available6;
end

reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data0;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data1;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data2;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data3;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data4;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data5;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data6;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data7;

always @(posedge clk) begin
    if (reset) begin
        final_data0 <= `MAT_MUL_SIZE*`DWIDTH'b0;
    end
    if (activation_out_data_available) begin
        final_data0 <= {act_data_out0[7:0],final_data0[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data1 <= `MAT_MUL_SIZE*`DWIDTH'b0;
    end
    if (activation_out_data_available1) begin
        final_data1 <= {act_data_out1[7:0],final_data1[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data2 <= `MAT_MUL_SIZE*`DWIDTH'b0;
    end
    if (activation_out_data_available2) begin
        final_data2 <= {act_data_out2[7:0],final_data2[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data3 <= `MAT_MUL_SIZE*`DWIDTH'b0;
    end
    if (activation_out_data_available3) begin
        final_data3 <= {act_data_out3[7:0],final_data3[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data4 <= `MAT_MUL_SIZE*`DWIDTH'b0;
    end
    if (activation_out_data_available4) begin
        final_data4 <= {act_data_out4[7:0],final_data4[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data5 <= `MAT_MUL_SIZE*`DWIDTH'b0;
    end
    if (activation_out_data_available5) begin
        final_data5 <= {act_data_out5[7:0],final_data5[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data6 <= `MAT_MUL_SIZE*`DWIDTH'b0;
    end
    if (activation_out_data_available6) begin
        final_data6 <= {act_data_out6[7:0],final_data6[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data7 <= `MAT_MUL_SIZE*`DWIDTH'b0;
    end
    if (activation_out_data_available7) begin
        final_data7 <= {act_data_out7[7:0],final_data7[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

wire [(`MAT_MUL_SIZE*`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data;
assign final_data = {final_data7,final_data6,final_data5,final_data4,final_data3,final_data2,final_data1,final_data0};

integer i;
  always @(posedge clk) begin
    if (reset) begin
        i = -1;
        bram_wdata_a <= 0;
        bram_addr_a_for_writing <= address_mat_c + address_stride_c;
        bram_a_wdata_available <= 0;
      end
    else if (done_activation) begin
        i = i + 1;
        bram_wdata_a <= final_data[i*`MAT_MUL_SIZE*`DWIDTH +:`MAT_MUL_SIZE*`DWIDTH];
        bram_addr_a_for_writing <= bram_addr_a_for_writing - address_stride_c;
        bram_a_wdata_available <= done_activation;
    end
    else begin
        bram_wdata_a <= 0;
        bram_addr_a_for_writing <= address_mat_c + address_stride_c;
        bram_a_wdata_available <= 0;
    end
  end
 

endmodule
