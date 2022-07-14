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
    wdata_accum0,
    wdata_accum1,
    wdata_accum2,
    wdata_accum3,
    wdata_accum4,
    wdata_accum5,
    wdata_accum6,
    wdata_accum7,
    raddr_accum0_pool,
    raddr_accum1_pool,
    raddr_accum2_pool,
    raddr_accum3_pool,
    raddr_accum4_pool,
    raddr_accum5_pool,
    raddr_accum6_pool,
    raddr_accum7_pool,
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
input [`DWIDTH-1:0] wdata_accum0;
input [`DWIDTH-1:0] wdata_accum1;
input [`DWIDTH-1:0] wdata_accum2;
input [`DWIDTH-1:0] wdata_accum3;
input [`DWIDTH-1:0] wdata_accum4;
input [`DWIDTH-1:0] wdata_accum5;
input [`DWIDTH-1:0] wdata_accum6;
input [`DWIDTH-1:0] wdata_accum7;
input [`AWIDTH-1:0] raddr_accum0_pool;
input [`AWIDTH-1:0] raddr_accum1_pool;
input [`AWIDTH-1:0] raddr_accum2_pool;
input [`AWIDTH-1:0] raddr_accum3_pool;
input [`AWIDTH-1:0] raddr_accum4_pool;
input [`AWIDTH-1:0] raddr_accum5_pool;
input [`AWIDTH-1:0] raddr_accum6_pool;
input [`AWIDTH-1:0] raddr_accum7_pool;
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

wire [`DWIDTH-1:0] rdata_buffer0_pong;
wire [`DWIDTH-1:0] rdata_buffer1_pong;
wire [`DWIDTH-1:0] rdata_buffer2_pong;
wire [`DWIDTH-1:0] rdata_buffer3_pong;
wire [`DWIDTH-1:0] rdata_buffer4_pong;
wire [`DWIDTH-1:0] rdata_buffer5_pong;
wire [`DWIDTH-1:0] rdata_buffer6_pong;
wire [`DWIDTH-1:0] rdata_buffer7_pong;
    
// Based on the Accumulator Adder MUX select signal either 0 or data read from the RAM goes into the Adder
assign wdata_accum0_in = (~add_accum_mux0)?  8'b0 : (buffer_select)? rdata_buffer0 : rdata_buffer0_pong;
assign wdata_accum1_in = (~add_accum_mux1)?  8'b0 : (buffer_select)? rdata_buffer1 : rdata_buffer1_pong;
assign wdata_accum2_in = (~add_accum_mux2)?  8'b0 : (buffer_select)? rdata_buffer2 : rdata_buffer2_pong;
assign wdata_accum3_in = (~add_accum_mux3)?  8'b0 : (buffer_select)? rdata_buffer3 : rdata_buffer3_pong;
assign wdata_accum4_in = (~add_accum_mux4)?  8'b0 : (buffer_select)? rdata_buffer4 : rdata_buffer4_pong;
assign wdata_accum5_in = (~add_accum_mux5)?  8'b0 : (buffer_select)? rdata_buffer5 : rdata_buffer5_pong;
assign wdata_accum6_in = (~add_accum_mux6)?  8'b0 : (buffer_select)? rdata_buffer6 : rdata_buffer6_pong;
assign wdata_accum7_in = (~add_accum_mux7)?  8'b0 : (buffer_select)? rdata_buffer7 : rdata_buffer7_pong;
  
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
  
assign rdata_accum0_pool =  (buffer_select_pool)?  (buffer_select)? rdata_buffer0 : rdata_buffer0_pong : 8'b0;
assign rdata_accum1_pool =  (buffer_select_pool1)? (buffer_select)? rdata_buffer1 : rdata_buffer1_pong : 8'b0;
assign rdata_accum2_pool =  (buffer_select_pool2)? (buffer_select)? rdata_buffer2 : rdata_buffer2_pong : 8'b0;
assign rdata_accum3_pool =  (buffer_select_pool3)? (buffer_select)? rdata_buffer3 : rdata_buffer3_pong : 8'b0;
assign rdata_accum4_pool =  (buffer_select_pool4)? (buffer_select)? rdata_buffer4 : rdata_buffer4_pong : 8'b0;
assign rdata_accum5_pool =  (buffer_select_pool5)? (buffer_select)? rdata_buffer5 : rdata_buffer5_pong : 8'b0;
assign rdata_accum6_pool =  (buffer_select_pool6)? (buffer_select)? rdata_buffer6 : rdata_buffer6_pong : 8'b0;
assign rdata_accum7_pool =  (buffer_select_pool7)? (buffer_select)? rdata_buffer7 : rdata_buffer7_pong : 8'b0;
  
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
    .addr1(raddr_buffer0),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer0_pong), 
    .clk(clk)
);

qadd adder_accum_pong1 (wdata_accum1, wdata_accum1_in, wdata_accum1_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum1_pong (
    .addr0(waddr_accum1),
    .d0(wdata_accum1_pong), 
    .we0(wdata_en_pong1), 
    .q0(accum1_pong_q0_NC),
    .addr1(raddr_buffer1),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer1_pong), 
    .clk(clk)
);

qadd adder_accum_pong2 (wdata_accum2, wdata_accum2_in, wdata_accum2_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum2_pong (
    .addr0(waddr_accum2),
    .d0(wdata_accum2_pong), 
    .we0(wdata_en_pong2), 
    .q0(accum2_pong_q0_NC),
    .addr1(raddr_buffer2),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer2_pong), 
    .clk(clk)
);

qadd adder_accum_pong3 (wdata_accum3, wdata_accum3_in, wdata_accum3_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum3_pong (
    .addr0(waddr_accum3),
    .d0(wdata_accum3_pong), 
    .we0(wdata_en_pong3), 
    .q0(accum3_pong_q0_NC),
    .addr1(raddr_buffer3),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer3_pong), 
    .clk(clk)
);

qadd adder_accum_pong4 (wdata_accum4, wdata_accum4_in, wdata_accum4_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum4_pong (
    .addr0(waddr_accum4),
    .d0(wdata_accum4_pong), 
    .we0(wdata_en_pong4), 
    .q0(accum4_pong_q0_NC),
    .addr1(raddr_buffer4),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer4_pong), 
    .clk(clk)
);

qadd adder_accum_pong5 (wdata_accum5, wdata_accum5_in, wdata_accum5_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum5_pong (
    .addr0(waddr_accum5),
    .d0(wdata_accum5_pong), 
    .we0(wdata_en_pong5), 
    .q0(accum5_pong_q0_NC),
    .addr1(raddr_buffer5),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer5_pong), 
    .clk(clk)
);

qadd adder_accum_pong6 (wdata_accum6, wdata_accum6_in, wdata_accum6_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum6_pong (
    .addr0(waddr_accum6),
    .d0(wdata_accum6_pong), 
    .we0(wdata_en_pong6), 
    .q0(accum6_pong_q0_NC),
    .addr1(raddr_buffer6),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer6_pong), 
    .clk(clk)
);

qadd adder_accum_pong7 (wdata_accum7, wdata_accum7_in, wdata_accum7_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum7_pong (
    .addr0(waddr_accum7),
    .d0(wdata_accum7_pong), 
    .we0(wdata_en_pong7), 
    .q0(accum7_pong_q0_NC),
    .addr1(raddr_buffer7),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer7_pong), 
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
reg [31:0] cycle_count;
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
wire [`DWIDTH-1:0] matrixC31_0;
wire [`DWIDTH-1:0] matrixC31_1;
wire [`DWIDTH-1:0] matrixC31_2;
wire [`DWIDTH-1:0] matrixC31_3;
wire [`DWIDTH-1:0] matrixC31_4;
wire [`DWIDTH-1:0] matrixC31_5;
wire [`DWIDTH-1:0] matrixC31_6;
wire [`DWIDTH-1:0] matrixC31_7;
wire [`DWIDTH-1:0] matrixC31_8;
wire [`DWIDTH-1:0] matrixC31_9;
wire [`DWIDTH-1:0] matrixC31_10;
wire [`DWIDTH-1:0] matrixC31_11;
wire [`DWIDTH-1:0] matrixC31_12;
wire [`DWIDTH-1:0] matrixC31_13;
wire [`DWIDTH-1:0] matrixC31_14;
wire [`DWIDTH-1:0] matrixC31_15;
wire [`DWIDTH-1:0] matrixC31_16;
wire [`DWIDTH-1:0] matrixC31_17;
wire [`DWIDTH-1:0] matrixC31_18;
wire [`DWIDTH-1:0] matrixC31_19;
wire [`DWIDTH-1:0] matrixC31_20;
wire [`DWIDTH-1:0] matrixC31_21;
wire [`DWIDTH-1:0] matrixC31_22;
wire [`DWIDTH-1:0] matrixC31_23;
wire [`DWIDTH-1:0] matrixC31_24;
wire [`DWIDTH-1:0] matrixC31_25;
wire [`DWIDTH-1:0] matrixC31_26;
wire [`DWIDTH-1:0] matrixC31_27;
wire [`DWIDTH-1:0] matrixC31_28;
wire [`DWIDTH-1:0] matrixC31_29;
wire [`DWIDTH-1:0] matrixC31_30;
wire [`DWIDTH-1:0] matrixC31_31;
`endif
`ifdef DESIGN_SIZE_16
wire [`DWIDTH-1:0] matrixC15_0;
wire [`DWIDTH-1:0] matrixC15_1;
wire [`DWIDTH-1:0] matrixC15_2;
wire [`DWIDTH-1:0] matrixC15_3;
wire [`DWIDTH-1:0] matrixC15_4;
wire [`DWIDTH-1:0] matrixC15_5;
wire [`DWIDTH-1:0] matrixC15_6;
wire [`DWIDTH-1:0] matrixC15_7;
wire [`DWIDTH-1:0] matrixC15_8;
wire [`DWIDTH-1:0] matrixC15_9;
wire [`DWIDTH-1:0] matrixC15_10;
wire [`DWIDTH-1:0] matrixC15_11;
wire [`DWIDTH-1:0] matrixC15_12;
wire [`DWIDTH-1:0] matrixC15_13;
wire [`DWIDTH-1:0] matrixC15_14;
wire [`DWIDTH-1:0] matrixC15_15;
`endif
`ifdef DESIGN_SIZE_8
wire [`DWIDTH-1:0] matrixC7_0;
wire [`DWIDTH-1:0] matrixC7_1;
wire [`DWIDTH-1:0] matrixC7_2;
wire [`DWIDTH-1:0] matrixC7_3;
wire [`DWIDTH-1:0] matrixC7_4;
wire [`DWIDTH-1:0] matrixC7_5;
wire [`DWIDTH-1:0] matrixC7_6;
wire [`DWIDTH-1:0] matrixC7_7;
`endif
`ifdef DESIGN_SIZE_4
wire [`DWIDTH-1:0] matrixC3_0;
wire [`DWIDTH-1:0] matrixC3_1;
wire [`DWIDTH-1:0] matrixC3_2;
wire [`DWIDTH-1:0] matrixC3_3;
`endif

wire [`AWIDTH-1:0] start_waddr_accum0;

assign start_waddr_accum0 = 11'b0;

`ifdef DESIGN_SIZE_8
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
`endif

`ifdef DESIGN_SIZE_16
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
`endif

`ifdef DESIGN_SIZE_32
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
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
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
  .matrixC31_0(matrixC31_0),
  .matrixC31_1(matrixC31_1),
  .matrixC31_2(matrixC31_2),
  .matrixC31_3(matrixC31_3),
  .matrixC31_4(matrixC31_4),
  .matrixC31_5(matrixC31_5),
  .matrixC31_6(matrixC31_6),
  .matrixC31_7(matrixC31_7),
  .matrixC31_8(matrixC31_8),
  .matrixC31_9(matrixC31_9),
  .matrixC31_10(matrixC31_10),
  .matrixC31_11(matrixC31_11),
  .matrixC31_12(matrixC31_12),
  .matrixC31_13(matrixC31_13),
  .matrixC31_14(matrixC31_14),
  .matrixC31_15(matrixC31_15),
  .matrixC31_16(matrixC31_16),
  .matrixC31_17(matrixC31_17),
  .matrixC31_18(matrixC31_18),
  .matrixC31_19(matrixC31_19),
  .matrixC31_20(matrixC31_20),
  .matrixC31_21(matrixC31_21),
  .matrixC31_22(matrixC31_22),
  .matrixC31_23(matrixC31_23),
  .matrixC31_24(matrixC31_24),
  .matrixC31_25(matrixC31_25),
  .matrixC31_26(matrixC31_26),
  .matrixC31_27(matrixC31_27),
  .matrixC31_28(matrixC31_28),
  .matrixC31_29(matrixC31_29),
  .matrixC31_30(matrixC31_30),
  .matrixC31_31(matrixC31_31),
  `endif
  `ifdef DESIGN_SIZE_16
  .matrixC15_0(matrixC15_0),
  .matrixC15_1(matrixC15_1),
  .matrixC15_2(matrixC15_2),
  .matrixC15_3(matrixC15_3),
  .matrixC15_4(matrixC15_4),
  .matrixC15_5(matrixC15_5),
  .matrixC15_6(matrixC15_6),
  .matrixC15_7(matrixC15_7),
  .matrixC15_8(matrixC15_8),
  .matrixC15_9(matrixC15_9),
  .matrixC15_10(matrixC15_10),
  .matrixC15_11(matrixC15_11),
  .matrixC15_12(matrixC15_12),
  .matrixC15_13(matrixC15_13),
  .matrixC15_14(matrixC15_14),
  .matrixC15_15(matrixC15_15),
  `endif
  `ifdef DESIGN_SIZE_8
  .matrixC7_0(matrixC7_0),
  .matrixC7_1(matrixC7_1),
  .matrixC7_2(matrixC7_2),
  .matrixC7_3(matrixC7_3),
  .matrixC7_4(matrixC7_4),
  .matrixC7_5(matrixC7_5),
  .matrixC7_6(matrixC7_6),
  .matrixC7_7(matrixC7_7),
  `endif
  `ifdef DESIGN_SIZE_4
  .matrixC3_0(matrixC3_0),
  .matrixC3_1(matrixC3_1),
  .matrixC3_2(matrixC3_2),
  .matrixC3_3(matrixC3_3),
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
  .start_waddr_accum0(start_waddr_accum0),
  `ifdef DESIGN_SIZE_8
  .wdata_accum0(matrixC7_0),
  .wdata_accum1(matrixC7_1),
  .wdata_accum2(matrixC7_2),
  .wdata_accum3(matrixC7_3),
  .wdata_accum4(matrixC7_4),
  .wdata_accum5(matrixC7_5),
  .wdata_accum6(matrixC7_6),
  .wdata_accum7(matrixC7_7),
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
  .rdata_accum7_pool(rdata_accum7_pool)
  `endif
  `ifdef DESIGN_SIZE_16
  .wdata_accum0(matrixC15_0),
  .wdata_accum1(matrixC15_1),
  .wdata_accum2(matrixC15_2),
  .wdata_accum3(matrixC15_3),
  .wdata_accum4(matrixC15_4),
  .wdata_accum5(matrixC15_5),
  .wdata_accum6(matrixC15_6),
  .wdata_accum7(matrixC15_7),
  .wdata_accum8(matrixC15_8),
  .wdata_accum9(matrixC15_9),
  .wdata_accum10(matrixC15_10),
  .wdata_accum11(matrixC15_11),
  .wdata_accum12(matrixC15_12),
  .wdata_accum13(matrixC15_13),
  .wdata_accum14(matrixC15_14),
  .wdata_accum15(matrixC15_15),
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
  .wdata_accum0(matrixC31_0),
  .wdata_accum1(matrixC31_1),
  .wdata_accum2(matrixC31_2),
  .wdata_accum3(matrixC31_3),
  .wdata_accum4(matrixC31_4),
  .wdata_accum5(matrixC31_5),
  .wdata_accum6(matrixC31_6),
  .wdata_accum7(matrixC31_7),
  .wdata_accum8(matrixC31_8),
  .wdata_accum9(matrixC31_9),
  .wdata_accum10(matrixC31_10),
  .wdata_accum11(matrixC31_11),
  .wdata_accum12(matrixC31_12),
  .wdata_accum13(matrixC31_13),
  .wdata_accum14(matrixC31_14),
  .wdata_accum15(matrixC31_15),
  .wdata_accum16(matrixC31_16),
  .wdata_accum17(matrixC31_17),
  .wdata_accum18(matrixC31_18),
  .wdata_accum19(matrixC31_19),
  .wdata_accum20(matrixC31_20),
  .wdata_accum21(matrixC31_21),
  .wdata_accum22(matrixC31_22),
  .wdata_accum23(matrixC31_23),
  .wdata_accum24(matrixC31_24),
  .wdata_accum25(matrixC31_25),
  .wdata_accum26(matrixC31_26),
  .wdata_accum27(matrixC31_27),
  .wdata_accum28(matrixC31_28),
  .wdata_accum29(matrixC31_29),
  .wdata_accum30(matrixC31_30),
  .wdata_accum31(matrixC31_31),
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
  .pool15(pool15)
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
  .pool31(pool31)
  `endif
);


////////////////////////////////////////////////////////////////
// Normalization module
////////////////////////////////////////////////////////////////
norm u_norm(
  .enable_norm(enable_norm),
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

`ifdef DESIGN_SIZE_16
reg activation_out_data_available8;
reg activation_out_data_available9;
reg activation_out_data_available10;
reg activation_out_data_available11;
reg activation_out_data_available12;
reg activation_out_data_available13;
reg activation_out_data_available14;
reg activation_out_data_available15;
`endif

`ifdef DESIGN_SIZE_32
reg activation_out_data_available8;
reg activation_out_data_available9;
reg activation_out_data_available10;
reg activation_out_data_available11;
reg activation_out_data_available12;
reg activation_out_data_available13;
reg activation_out_data_available14;
reg activation_out_data_available15;
reg activation_out_data_available16;
reg activation_out_data_available17;
reg activation_out_data_available18;
reg activation_out_data_available19;
reg activation_out_data_available20;
reg activation_out_data_available21;
reg activation_out_data_available22;
reg activation_out_data_available23;
reg activation_out_data_available24;
reg activation_out_data_available25;
reg activation_out_data_available26;
reg activation_out_data_available27;
reg activation_out_data_available28;
reg activation_out_data_available29;
reg activation_out_data_available30;
reg activation_out_data_available31;
`endif

always @(posedge clk) begin
    activation_out_data_available1 <= activation_out_data_available;
    activation_out_data_available2 <= activation_out_data_available1;
    activation_out_data_available3 <= activation_out_data_available2;
    activation_out_data_available4 <= activation_out_data_available3;
    activation_out_data_available5 <= activation_out_data_available4;
    activation_out_data_available6 <= activation_out_data_available5;
    activation_out_data_available7 <= activation_out_data_available6;
end

`ifdef DESIGN_SIZE_16
always @(posedge clk) begin
    activation_out_data_available8 <= activation_out_data_available7;
    activation_out_data_available9 <= activation_out_data_available8;
    activation_out_data_available10 <= activation_out_data_available9;
    activation_out_data_available11 <= activation_out_data_available10;
    activation_out_data_available12 <= activation_out_data_available11;
    activation_out_data_available13 <= activation_out_data_available12;
    activation_out_data_available14 <= activation_out_data_available13;
    activation_out_data_available15 <= activation_out_data_available14;
end
`endif

`ifdef DESIGN_SIZE_32
always @(posedge clk) begin
    activation_out_data_available8 <= activation_out_data_available7;
    activation_out_data_available9 <= activation_out_data_available8;
    activation_out_data_available10 <= activation_out_data_available9;
    activation_out_data_available11 <= activation_out_data_available10;
    activation_out_data_available12 <= activation_out_data_available11;
    activation_out_data_available13 <= activation_out_data_available12;
    activation_out_data_available14 <= activation_out_data_available13;
    activation_out_data_available15 <= activation_out_data_available14;
    activation_out_data_available16 <= activation_out_data_available15;
    activation_out_data_available17 <= activation_out_data_available16;
    activation_out_data_available18 <= activation_out_data_available17;
    activation_out_data_available19 <= activation_out_data_available18;
    activation_out_data_available20 <= activation_out_data_available19;
    activation_out_data_available21 <= activation_out_data_available20;
    activation_out_data_available22 <= activation_out_data_available21;
    activation_out_data_available23 <= activation_out_data_available22;
    activation_out_data_available24 <= activation_out_data_available23;
    activation_out_data_available25 <= activation_out_data_available24;
    activation_out_data_available26 <= activation_out_data_available25;
    activation_out_data_available27 <= activation_out_data_available26;
    activation_out_data_available28 <= activation_out_data_available27;
    activation_out_data_available29 <= activation_out_data_available28;
    activation_out_data_available30 <= activation_out_data_available29;
    activation_out_data_available31 <= activation_out_data_available30;
end
`endif

reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data0;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data1;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data2;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data3;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data4;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data5;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data6;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data7;

`ifdef DESIGN_SIZE_16
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data8;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data9;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data10;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data11;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data12;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data13;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data14;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data15;
`endif

`ifdef DESIGN_SIZE_32
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data8;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data9;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data10;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data11;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data12;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data13;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data14;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data15;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data16;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data17;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data18;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data19;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data20;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data21;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data22;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data23;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data24;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data25;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data26;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data27;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data28;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data29;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data30;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data31;
`endif

always @(posedge clk) begin
    if (reset) begin
        final_data0 <= 0;
    end
    else if (activation_out_data_available) begin
        final_data0 <= {act_data_out0[7:0],final_data0[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data1 <= 0;
    end
    else if (activation_out_data_available1) begin
        final_data1 <= {act_data_out1[7:0],final_data1[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data2 <= 0;
    end
    else if (activation_out_data_available2) begin
        final_data2 <= {act_data_out2[7:0],final_data2[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data3 <= 0;
    end
    else if (activation_out_data_available3) begin
        final_data3 <= {act_data_out3[7:0],final_data3[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data4 <= 0;
    end
    else if (activation_out_data_available4) begin
        final_data4 <= {act_data_out4[7:0],final_data4[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data5 <= 0;
    end
    else if (activation_out_data_available5) begin
        final_data5 <= {act_data_out5[7:0],final_data5[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data6 <= 0;
    end
    else if (activation_out_data_available6) begin
        final_data6 <= {act_data_out6[7:0],final_data6[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data7 <= 0;
    end
    else if (activation_out_data_available7) begin
        final_data7 <= {act_data_out7[7:0],final_data7[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

`ifdef DESIGN_SIZE_16
always @(posedge clk) begin
    if (reset) begin
        final_data8 <= 0;
    end
    else if (activation_out_data_available8) begin
        final_data8 <= {act_data_out8[7:0],final_data8[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data9 <= 0;
    end
    else if (activation_out_data_available9) begin
        final_data9 <= {act_data_out9[7:0],final_data9[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data10 <= 0;
    end
    else if (activation_out_data_available10) begin
        final_data10 <= {act_data_out10[7:0],final_data10[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data11 <= 0;
    end
    else if (activation_out_data_available11) begin
        final_data11 <= {act_data_out11[7:0],final_data11[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data12 <= 0;
    end
    else if (activation_out_data_available12) begin
        final_data12 <= {act_data_out12[7:0],final_data12[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data13 <= 0;
    end
    else if (activation_out_data_available13) begin
        final_data13 <= {act_data_out13[7:0],final_data13[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data14 <= 0;
    end
    else if (activation_out_data_available14) begin
        final_data14 <= {act_data_out14[7:0],final_data14[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data15 <= 0;
    end
    else if (activation_out_data_available15) begin
        final_data15 <= {act_data_out15[7:0],final_data15[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end
`endif

`ifdef DESIGN_SIZE_32
always @(posedge clk) begin
    if (reset) begin
        final_data8 <= 0;
    end
    else if (activation_out_data_available8) begin
        final_data8 <= {act_data_out8[7:0],final_data8[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data9 <= 0;
    end
    else if (activation_out_data_available9) begin
        final_data9 <= {act_data_out9[7:0],final_data9[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data10 <= 0;
    end
    else if (activation_out_data_available10) begin
        final_data10 <= {act_data_out10[7:0],final_data10[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data11 <= 0;
    end
    else if (activation_out_data_available11) begin
        final_data11 <= {act_data_out11[7:0],final_data11[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data12 <= 0;
    end
    else if (activation_out_data_available12) begin
        final_data12 <= {act_data_out12[7:0],final_data12[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data13 <= 0;
    end
    else if (activation_out_data_available13) begin
        final_data13 <= {act_data_out13[7:0],final_data13[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data14 <= 0;
    end
    else if (activation_out_data_available14) begin
        final_data14 <= {act_data_out14[7:0],final_data14[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data15 <= 0;
    end
    else if (activation_out_data_available15) begin
        final_data15 <= {act_data_out15[7:0],final_data15[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data16 <= 0;
    end
    else if (activation_out_data_available16) begin
        final_data16 <= {act_data_out16[7:0],final_data16[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data17 <= 0;
    end
    else if (activation_out_data_available17) begin
        final_data17 <= {act_data_out17[7:0],final_data17[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data18 <= 0;
    end
    else if (activation_out_data_available18) begin
        final_data18 <= {act_data_out18[7:0],final_data18[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data19 <= 0;
    end
    else if (activation_out_data_available19) begin
        final_data19 <= {act_data_out19[7:0],final_data19[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data20 <= 0;
    end
    else if (activation_out_data_available20) begin
        final_data20 <= {act_data_out20[7:0],final_data20[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data21 <= 0;
    end
    else if (activation_out_data_available21) begin
        final_data21 <= {act_data_out21[7:0],final_data21[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data22 <= 0;
    end
    else if (activation_out_data_available22) begin
        final_data22 <= {act_data_out22[7:0],final_data22[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data23 <= 0;
    end
    else if (activation_out_data_available23) begin
        final_data23 <= {act_data_out23[7:0],final_data23[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data24 <= 0;
    end
    else if (activation_out_data_available24) begin
        final_data24 <= {act_data_out24[7:0],final_data24[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data25 <= 0;
    end
    else if (activation_out_data_available25) begin
        final_data25 <= {act_data_out25[7:0],final_data25[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data26 <= 0;
    end
    else if (activation_out_data_available26) begin
        final_data26 <= {act_data_out26[7:0],final_data26[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data27 <= 0;
    end
    else if (activation_out_data_available27) begin
        final_data27 <= {act_data_out27[7:0],final_data27[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data28 <= 0;
    end
    else if (activation_out_data_available28) begin
        final_data28 <= {act_data_out28[7:0],final_data28[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data29 <= 0;
    end
    else if (activation_out_data_available29) begin
        final_data29 <= {act_data_out29[7:0],final_data29[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data30 <= 0;
    end
    else if (activation_out_data_available30) begin
        final_data30 <= {act_data_out30[7:0],final_data30[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data31 <= 0;
    end
    else if (activation_out_data_available31) begin
        final_data31 <= {act_data_out31[7:0],final_data31[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end
`endif

reg [31:0] i;
  always @(posedge clk) begin
    if (reset) begin
        i <= 0;
        bram_wdata_a <= 0;
        bram_addr_a_for_writing <= address_mat_c + address_stride_c;
        bram_a_wdata_available <= 0;
      end
    else if (done_activation) begin
        i <= i + 1;
        case(i)
        `ifdef DESIGN_SIZE_8
        0: begin bram_wdata_a <= final_data0; end
        1: begin bram_wdata_a <= final_data1; end
        2: begin bram_wdata_a <= final_data2; end
        3: begin bram_wdata_a <= final_data3; end
        4: begin bram_wdata_a <= final_data4; end
        5: begin bram_wdata_a <= final_data5; end
        6: begin bram_wdata_a <= final_data6; end
        7: begin bram_wdata_a <= final_data7; end
        default : begin bram_wdata_a <= final_data7; end
        `endif
        `ifdef DESIGN_SIZE_16
        0: begin bram_wdata_a <= final_data0; end
        1: begin bram_wdata_a <= final_data1; end
        2: begin bram_wdata_a <= final_data2; end
        3: begin bram_wdata_a <= final_data3; end
        4: begin bram_wdata_a <= final_data4; end
        5: begin bram_wdata_a <= final_data5; end
        6: begin bram_wdata_a <= final_data6; end
        7: begin bram_wdata_a <= final_data7; end
        8: begin bram_wdata_a <= final_data8; end
        9: begin bram_wdata_a <= final_data9; end
        10: begin bram_wdata_a <= final_data10; end
        11: begin bram_wdata_a <= final_data11; end
        12: begin bram_wdata_a <= final_data12; end
        13: begin bram_wdata_a <= final_data13; end
        14: begin bram_wdata_a <= final_data14; end
        15: begin bram_wdata_a <= final_data15; end
        default : begin bram_wdata_a <= final_data15; end
        `endif 
        `ifdef DESIGN_SIZE_32
        0: begin bram_wdata_a <= final_data0; end
        1: begin bram_wdata_a <= final_data1; end
        2: begin bram_wdata_a <= final_data2; end
        3: begin bram_wdata_a <= final_data3; end
        4: begin bram_wdata_a <= final_data4; end
        5: begin bram_wdata_a <= final_data5; end
        6: begin bram_wdata_a <= final_data6; end
        7: begin bram_wdata_a <= final_data7; end
        8: begin bram_wdata_a <= final_data8; end
        9: begin bram_wdata_a <= final_data9; end
        10: begin bram_wdata_a <= final_data10; end
        11: begin bram_wdata_a <= final_data11; end
        12: begin bram_wdata_a <= final_data12; end
        13: begin bram_wdata_a <= final_data13; end
        14: begin bram_wdata_a <= final_data14; end
        15: begin bram_wdata_a <= final_data15; end
        16: begin bram_wdata_a <= final_data16; end
        17: begin bram_wdata_a <= final_data17; end
        18: begin bram_wdata_a <= final_data18; end
        19: begin bram_wdata_a <= final_data19; end
        20: begin bram_wdata_a <= final_data20; end
        21: begin bram_wdata_a <= final_data21; end
        22: begin bram_wdata_a <= final_data22; end
        23: begin bram_wdata_a <= final_data23; end
        24: begin bram_wdata_a <= final_data24; end
        25: begin bram_wdata_a <= final_data25; end
        26: begin bram_wdata_a <= final_data26; end
        27: begin bram_wdata_a <= final_data27; end
        28: begin bram_wdata_a <= final_data28; end
        29: begin bram_wdata_a <= final_data29; end
        30: begin bram_wdata_a <= final_data30; end
        31: begin bram_wdata_a <= final_data31; end
        default : begin bram_wdata_a <= final_data31; end
        `endif
        endcase
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
