`define MATMUL_SIZE_8


//////////////////////////

//defines.v 

//////////////////////////

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

`define BB_MAT_MUL_SIZE `MAT_MUL_SIZE
`define NUM_CYCLES_IN_MAC 3
`define MEM_ACCESS_LATENCY 1
`define REG_DATAWIDTH 32
`define REG_ADDRWIDTH 8
`define ADDR_STRIDE_WIDTH 8
`define MAX_BITS_POOL 3

/////////////////////////////////////////////////
//Register specification
/////////////////////////////////////////////////
//---------------------------------------
//Addr 0 : Register with enables for various blocks
//---------------------------------------
`define REG_ENABLES_ADDR 32'h0
//Bit 0: enable_matmul
//Bit 1: enable_norm
//Bit 2: enable_pool
//Bit 3: enable_activation

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
//Addr E: Register that stores the starting address of matrix A in BRAM A
//---------------------------------------
`define REG_MATRIX_A_ADDR 32'he
//Bit `AWIDTH-1:0 address_mat_a

//---------------------------------------
//Addr 12: Register that stores the starting address of matrix B in BRAM B
//---------------------------------------
`define REG_MATRIX_B_ADDR 32'h12
//Bit `AWIDTH-1:0 address_mat_b

//---------------------------------------
//Addr 16: Register that stores the starting address of matrix C in BRAM C
//---------------------------------------
`define REG_MATRIX_C_ADDR 32'h16
//Bit `AWIDTH-1:0 address_mat_c

//---------------------------------------
//Addr 20: Register that stores the mask of which parts of the matrices are valid.
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
`define REG_VALID_MASK_ADDR 32'h20
//Bit `MASK_WIDTH-1:0 mask for a row or column of both matrices

//---------------------------------------
//Addr 24: Register that controls the accumulation logic
//---------------------------------------
`define REG_ACCUM_ACTIONS_ADDR 32'h24
//Bit 0 save_output_to_accumulator
//Bit 1 add_accumulator_to_output

//---------------------------------------
//Addr 28: Register that stores the stride that should be taken to address
//elements in matrix A, after every MAT_MUL_SIZE worth of data has been fetched.
//See the diagram in "Meeting-16" notes in the EE382V project Onenote notebook.
//This stride is applied when incrementing addresses for matrix A in the vertical
//direction.
//---------------------------------------
`define REG_MATRIX_A_STRIDE_ADDR 32'h28
//Bit `ADDR_STRIDE_WIDTH-1:0 address_stride_a

//---------------------------------------
//Addr 32: Register that stores the stride that should be taken to address
//elements in matrix B, after every MAT_MUL_SIZE worth of data has been fetched.
//See the diagram in "Meeting-16" notes in the EE382V project Onenote notebook.
//This stride is applied when incrementing addresses for matrix B in the horizontal
//direction.
//---------------------------------------
`define REG_MATRIX_B_STRIDE_ADDR 32'h32
//Bit `ADDR_STRIDE_WIDTH-1:0 address_stride_b

//---------------------------------------
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

//Register defining pooling window size
//---------------------------------------
`define REG_POOL_KERNEL_SIZE 2
//Bit `MAX_BITS_POOL-1:0 pool window size



//////////////////////////

//8x8_gen.v 

//////////////////////////


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020-05-10 00:56:48.227838
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

reg a_mem_access;
reg [`AWIDTH-1:0] a_addr;

always @(posedge clk) begin
  if (reset || ~start_mat_mul) begin
    a_addr <= address_mat_a-address_stride_a;
    a_mem_access <= 0;
  end
  //else if (clk_cnt >= a_loc*`MAT_MUL_SIZE+final_mat_mul_size) begin
  //Writing the line above to avoid multiplication:
  else if (clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size) begin
    a_addr <= address_mat_a-address_stride_a;
    a_mem_access <= 0;
  end
  //else if ((clk_cnt >= a_loc*`MAT_MUL_SIZE) && (clk_cnt < a_loc*`MAT_MUL_SIZE+final_mat_mul_size)) begin
  //Writing the line above to avoid multiplication:
  else if ((clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)) && (clk_cnt < (a_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin
    a_addr <= a_addr + address_stride_a;
    a_mem_access <= 1;
  end
end

reg a_data_valid; //flag that tells whether the data from memory is valid
reg [7:0] a_mem_access_counter;
always @(posedge clk) begin
  if (reset || ~start_mat_mul) begin
    a_data_valid <= 0;
    a_mem_access_counter <= 0;
  end
  else if (a_mem_access == 1) begin
    a_mem_access_counter = a_mem_access_counter + 1;  
    if (a_mem_access_counter == `MEM_ACCESS_LATENCY) begin
      a_data_valid <= 1;
    end
  end
  else begin
    a_data_valid <= 0;
    a_mem_access_counter <= 0;
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

assign a0_data = a_data[1*`DWIDTH-1:0*`DWIDTH] & {`DWIDTH{a_data_valid}};
assign a1_data = a_data[2*`DWIDTH-1:1*`DWIDTH] & {`DWIDTH{a_data_valid}};
assign a2_data = a_data[3*`DWIDTH-1:2*`DWIDTH] & {`DWIDTH{a_data_valid}};
assign a3_data = a_data[4*`DWIDTH-1:3*`DWIDTH] & {`DWIDTH{a_data_valid}};
assign a4_data = a_data[5*`DWIDTH-1:4*`DWIDTH] & {`DWIDTH{a_data_valid}};
assign a5_data = a_data[6*`DWIDTH-1:5*`DWIDTH] & {`DWIDTH{a_data_valid}};
assign a6_data = a_data[7*`DWIDTH-1:6*`DWIDTH] & {`DWIDTH{a_data_valid}};
assign a7_data = a_data[8*`DWIDTH-1:7*`DWIDTH] & {`DWIDTH{a_data_valid}};

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
reg b_mem_access; //flag that tells whether the matmul is trying to access memory or not
always @(posedge clk) begin
  if (reset || ~start_mat_mul) begin
    b_addr <= address_mat_b-address_stride_b;
    b_mem_access <= 0;
  end
  //else if (clk_cnt >= b_loc*`MAT_MUL_SIZE+final_mat_mul_size) begin
  //Writing the line above to avoid multiplication:
  else if (clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size) begin
    b_addr <= address_mat_b-address_stride_b;
    b_mem_access <= 0;
  end
  //else if ((clk_cnt >= b_loc*`MAT_MUL_SIZE) && (clk_cnt < b_loc*`MAT_MUL_SIZE+final_mat_mul_size)) begin
  //Writing the line above to avoid multiplication:
  else if ((clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)) && (clk_cnt < (b_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin
    b_addr <= b_addr + address_stride_b;
    b_mem_access <= 1;
  end
end  

reg b_data_valid; //flag that tells whether the data from memory is valid
reg [7:0] b_mem_access_counter;
always @(posedge clk) begin
  if (reset || ~start_mat_mul) begin
    b_data_valid <= 0;
    b_mem_access_counter <= 0;
  end
  else if (b_mem_access == 1) begin
    b_mem_access_counter = b_mem_access_counter + 1;  
    if (b_mem_access_counter == `MEM_ACCESS_LATENCY) begin
      b_data_valid <= 1;
    end
  end
  else begin
    b_data_valid <= 0;
    b_mem_access_counter <= 0;
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

assign b0_data = b_data[1*`DWIDTH-1:0*`DWIDTH] & {`DWIDTH{b_data_valid}};
assign b1_data = b_data[2*`DWIDTH-1:1*`DWIDTH] & {`DWIDTH{b_data_valid}};
assign b2_data = b_data[3*`DWIDTH-1:2*`DWIDTH] & {`DWIDTH{b_data_valid}};
assign b3_data = b_data[4*`DWIDTH-1:3*`DWIDTH] & {`DWIDTH{b_data_valid}};
assign b4_data = b_data[5*`DWIDTH-1:4*`DWIDTH] & {`DWIDTH{b_data_valid}};
assign b5_data = b_data[6*`DWIDTH-1:5*`DWIDTH] & {`DWIDTH{b_data_valid}};
assign b6_data = b_data[7*`DWIDTH-1:6*`DWIDTH] & {`DWIDTH{b_data_valid}};
assign b7_data = b_data[8*`DWIDTH-1:7*`DWIDTH] & {`DWIDTH{b_data_valid}};

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
wire [`DWIDTH-1:0] matrixC00_added;
wire [`DWIDTH-1:0] matrixC01_added;
wire [`DWIDTH-1:0] matrixC02_added;
wire [`DWIDTH-1:0] matrixC03_added;
wire [`DWIDTH-1:0] matrixC04_added;
wire [`DWIDTH-1:0] matrixC05_added;
wire [`DWIDTH-1:0] matrixC06_added;
wire [`DWIDTH-1:0] matrixC07_added;
wire [`DWIDTH-1:0] matrixC10_added;
wire [`DWIDTH-1:0] matrixC11_added;
wire [`DWIDTH-1:0] matrixC12_added;
wire [`DWIDTH-1:0] matrixC13_added;
wire [`DWIDTH-1:0] matrixC14_added;
wire [`DWIDTH-1:0] matrixC15_added;
wire [`DWIDTH-1:0] matrixC16_added;
wire [`DWIDTH-1:0] matrixC17_added;
wire [`DWIDTH-1:0] matrixC20_added;
wire [`DWIDTH-1:0] matrixC21_added;
wire [`DWIDTH-1:0] matrixC22_added;
wire [`DWIDTH-1:0] matrixC23_added;
wire [`DWIDTH-1:0] matrixC24_added;
wire [`DWIDTH-1:0] matrixC25_added;
wire [`DWIDTH-1:0] matrixC26_added;
wire [`DWIDTH-1:0] matrixC27_added;
wire [`DWIDTH-1:0] matrixC30_added;
wire [`DWIDTH-1:0] matrixC31_added;
wire [`DWIDTH-1:0] matrixC32_added;
wire [`DWIDTH-1:0] matrixC33_added;
wire [`DWIDTH-1:0] matrixC34_added;
wire [`DWIDTH-1:0] matrixC35_added;
wire [`DWIDTH-1:0] matrixC36_added;
wire [`DWIDTH-1:0] matrixC37_added;
wire [`DWIDTH-1:0] matrixC40_added;
wire [`DWIDTH-1:0] matrixC41_added;
wire [`DWIDTH-1:0] matrixC42_added;
wire [`DWIDTH-1:0] matrixC43_added;
wire [`DWIDTH-1:0] matrixC44_added;
wire [`DWIDTH-1:0] matrixC45_added;
wire [`DWIDTH-1:0] matrixC46_added;
wire [`DWIDTH-1:0] matrixC47_added;
wire [`DWIDTH-1:0] matrixC50_added;
wire [`DWIDTH-1:0] matrixC51_added;
wire [`DWIDTH-1:0] matrixC52_added;
wire [`DWIDTH-1:0] matrixC53_added;
wire [`DWIDTH-1:0] matrixC54_added;
wire [`DWIDTH-1:0] matrixC55_added;
wire [`DWIDTH-1:0] matrixC56_added;
wire [`DWIDTH-1:0] matrixC57_added;
wire [`DWIDTH-1:0] matrixC60_added;
wire [`DWIDTH-1:0] matrixC61_added;
wire [`DWIDTH-1:0] matrixC62_added;
wire [`DWIDTH-1:0] matrixC63_added;
wire [`DWIDTH-1:0] matrixC64_added;
wire [`DWIDTH-1:0] matrixC65_added;
wire [`DWIDTH-1:0] matrixC66_added;
wire [`DWIDTH-1:0] matrixC67_added;
wire [`DWIDTH-1:0] matrixC70_added;
wire [`DWIDTH-1:0] matrixC71_added;
wire [`DWIDTH-1:0] matrixC72_added;
wire [`DWIDTH-1:0] matrixC73_added;
wire [`DWIDTH-1:0] matrixC74_added;
wire [`DWIDTH-1:0] matrixC75_added;
wire [`DWIDTH-1:0] matrixC76_added;
wire [`DWIDTH-1:0] matrixC77_added;


reg [`DWIDTH-1:0] matrixC00_accum;
reg [`DWIDTH-1:0] matrixC01_accum;
reg [`DWIDTH-1:0] matrixC02_accum;
reg [`DWIDTH-1:0] matrixC03_accum;
reg [`DWIDTH-1:0] matrixC04_accum;
reg [`DWIDTH-1:0] matrixC05_accum;
reg [`DWIDTH-1:0] matrixC06_accum;
reg [`DWIDTH-1:0] matrixC07_accum;
reg [`DWIDTH-1:0] matrixC10_accum;
reg [`DWIDTH-1:0] matrixC11_accum;
reg [`DWIDTH-1:0] matrixC12_accum;
reg [`DWIDTH-1:0] matrixC13_accum;
reg [`DWIDTH-1:0] matrixC14_accum;
reg [`DWIDTH-1:0] matrixC15_accum;
reg [`DWIDTH-1:0] matrixC16_accum;
reg [`DWIDTH-1:0] matrixC17_accum;
reg [`DWIDTH-1:0] matrixC20_accum;
reg [`DWIDTH-1:0] matrixC21_accum;
reg [`DWIDTH-1:0] matrixC22_accum;
reg [`DWIDTH-1:0] matrixC23_accum;
reg [`DWIDTH-1:0] matrixC24_accum;
reg [`DWIDTH-1:0] matrixC25_accum;
reg [`DWIDTH-1:0] matrixC26_accum;
reg [`DWIDTH-1:0] matrixC27_accum;
reg [`DWIDTH-1:0] matrixC30_accum;
reg [`DWIDTH-1:0] matrixC31_accum;
reg [`DWIDTH-1:0] matrixC32_accum;
reg [`DWIDTH-1:0] matrixC33_accum;
reg [`DWIDTH-1:0] matrixC34_accum;
reg [`DWIDTH-1:0] matrixC35_accum;
reg [`DWIDTH-1:0] matrixC36_accum;
reg [`DWIDTH-1:0] matrixC37_accum;
reg [`DWIDTH-1:0] matrixC40_accum;
reg [`DWIDTH-1:0] matrixC41_accum;
reg [`DWIDTH-1:0] matrixC42_accum;
reg [`DWIDTH-1:0] matrixC43_accum;
reg [`DWIDTH-1:0] matrixC44_accum;
reg [`DWIDTH-1:0] matrixC45_accum;
reg [`DWIDTH-1:0] matrixC46_accum;
reg [`DWIDTH-1:0] matrixC47_accum;
reg [`DWIDTH-1:0] matrixC50_accum;
reg [`DWIDTH-1:0] matrixC51_accum;
reg [`DWIDTH-1:0] matrixC52_accum;
reg [`DWIDTH-1:0] matrixC53_accum;
reg [`DWIDTH-1:0] matrixC54_accum;
reg [`DWIDTH-1:0] matrixC55_accum;
reg [`DWIDTH-1:0] matrixC56_accum;
reg [`DWIDTH-1:0] matrixC57_accum;
reg [`DWIDTH-1:0] matrixC60_accum;
reg [`DWIDTH-1:0] matrixC61_accum;
reg [`DWIDTH-1:0] matrixC62_accum;
reg [`DWIDTH-1:0] matrixC63_accum;
reg [`DWIDTH-1:0] matrixC64_accum;
reg [`DWIDTH-1:0] matrixC65_accum;
reg [`DWIDTH-1:0] matrixC66_accum;
reg [`DWIDTH-1:0] matrixC67_accum;
reg [`DWIDTH-1:0] matrixC70_accum;
reg [`DWIDTH-1:0] matrixC71_accum;
reg [`DWIDTH-1:0] matrixC72_accum;
reg [`DWIDTH-1:0] matrixC73_accum;
reg [`DWIDTH-1:0] matrixC74_accum;
reg [`DWIDTH-1:0] matrixC75_accum;
reg [`DWIDTH-1:0] matrixC76_accum;
reg [`DWIDTH-1:0] matrixC77_accum;

reg outputs_saved_to_accum;
reg outputs_added_to_accum;
wire reset_accum;

always @(posedge clk) begin
  if (reset || ~(save_output_to_accum || add_accum_to_output) || (reset_accum)) begin
matrixC00_accum <= 0;
matrixC01_accum <= 0;
matrixC02_accum <= 0;
matrixC03_accum <= 0;
matrixC04_accum <= 0;
matrixC05_accum <= 0;
matrixC06_accum <= 0;
matrixC07_accum <= 0;
matrixC10_accum <= 0;
matrixC11_accum <= 0;
matrixC12_accum <= 0;
matrixC13_accum <= 0;
matrixC14_accum <= 0;
matrixC15_accum <= 0;
matrixC16_accum <= 0;
matrixC17_accum <= 0;
matrixC20_accum <= 0;
matrixC21_accum <= 0;
matrixC22_accum <= 0;
matrixC23_accum <= 0;
matrixC24_accum <= 0;
matrixC25_accum <= 0;
matrixC26_accum <= 0;
matrixC27_accum <= 0;
matrixC30_accum <= 0;
matrixC31_accum <= 0;
matrixC32_accum <= 0;
matrixC33_accum <= 0;
matrixC34_accum <= 0;
matrixC35_accum <= 0;
matrixC36_accum <= 0;
matrixC37_accum <= 0;
matrixC40_accum <= 0;
matrixC41_accum <= 0;
matrixC42_accum <= 0;
matrixC43_accum <= 0;
matrixC44_accum <= 0;
matrixC45_accum <= 0;
matrixC46_accum <= 0;
matrixC47_accum <= 0;
matrixC50_accum <= 0;
matrixC51_accum <= 0;
matrixC52_accum <= 0;
matrixC53_accum <= 0;
matrixC54_accum <= 0;
matrixC55_accum <= 0;
matrixC56_accum <= 0;
matrixC57_accum <= 0;
matrixC60_accum <= 0;
matrixC61_accum <= 0;
matrixC62_accum <= 0;
matrixC63_accum <= 0;
matrixC64_accum <= 0;
matrixC65_accum <= 0;
matrixC66_accum <= 0;
matrixC67_accum <= 0;
matrixC70_accum <= 0;
matrixC71_accum <= 0;
matrixC72_accum <= 0;
matrixC73_accum <= 0;
matrixC74_accum <= 0;
matrixC75_accum <= 0;
matrixC76_accum <= 0;
matrixC77_accum <= 0;
 outputs_saved_to_accum <= 0;
    outputs_added_to_accum <= 0;
  end
  else if (row_latch_en && save_output_to_accum && add_accum_to_output) begin
	matrixC00_accum <= matrixC00_added;
	matrixC01_accum <= matrixC01_added;
	matrixC02_accum <= matrixC02_added;
	matrixC03_accum <= matrixC03_added;
	matrixC04_accum <= matrixC04_added;
	matrixC05_accum <= matrixC05_added;
	matrixC06_accum <= matrixC06_added;
	matrixC07_accum <= matrixC07_added;
	matrixC10_accum <= matrixC10_added;
	matrixC11_accum <= matrixC11_added;
	matrixC12_accum <= matrixC12_added;
	matrixC13_accum <= matrixC13_added;
	matrixC14_accum <= matrixC14_added;
	matrixC15_accum <= matrixC15_added;
	matrixC16_accum <= matrixC16_added;
	matrixC17_accum <= matrixC17_added;
	matrixC20_accum <= matrixC20_added;
	matrixC21_accum <= matrixC21_added;
	matrixC22_accum <= matrixC22_added;
	matrixC23_accum <= matrixC23_added;
	matrixC24_accum <= matrixC24_added;
	matrixC25_accum <= matrixC25_added;
	matrixC26_accum <= matrixC26_added;
	matrixC27_accum <= matrixC27_added;
	matrixC30_accum <= matrixC30_added;
	matrixC31_accum <= matrixC31_added;
	matrixC32_accum <= matrixC32_added;
	matrixC33_accum <= matrixC33_added;
	matrixC34_accum <= matrixC34_added;
	matrixC35_accum <= matrixC35_added;
	matrixC36_accum <= matrixC36_added;
	matrixC37_accum <= matrixC37_added;
	matrixC40_accum <= matrixC40_added;
	matrixC41_accum <= matrixC41_added;
	matrixC42_accum <= matrixC42_added;
	matrixC43_accum <= matrixC43_added;
	matrixC44_accum <= matrixC44_added;
	matrixC45_accum <= matrixC45_added;
	matrixC46_accum <= matrixC46_added;
	matrixC47_accum <= matrixC47_added;
	matrixC50_accum <= matrixC50_added;
	matrixC51_accum <= matrixC51_added;
	matrixC52_accum <= matrixC52_added;
	matrixC53_accum <= matrixC53_added;
	matrixC54_accum <= matrixC54_added;
	matrixC55_accum <= matrixC55_added;
	matrixC56_accum <= matrixC56_added;
	matrixC57_accum <= matrixC57_added;
	matrixC60_accum <= matrixC60_added;
	matrixC61_accum <= matrixC61_added;
	matrixC62_accum <= matrixC62_added;
	matrixC63_accum <= matrixC63_added;
	matrixC64_accum <= matrixC64_added;
	matrixC65_accum <= matrixC65_added;
	matrixC66_accum <= matrixC66_added;
	matrixC67_accum <= matrixC67_added;
	matrixC70_accum <= matrixC70_added;
	matrixC71_accum <= matrixC71_added;
	matrixC72_accum <= matrixC72_added;
	matrixC73_accum <= matrixC73_added;
	matrixC74_accum <= matrixC74_added;
	matrixC75_accum <= matrixC75_added;
	matrixC76_accum <= matrixC76_added;
	matrixC77_accum <= matrixC77_added;

    outputs_saved_to_accum <= 1;
    outputs_added_to_accum <= 1;
  end
  else if (row_latch_en && save_output_to_accum) begin
	matrixC00_accum <= matrixC00;
	matrixC01_accum <= matrixC01;
	matrixC02_accum <= matrixC02;
	matrixC03_accum <= matrixC03;
	matrixC04_accum <= matrixC04;
	matrixC05_accum <= matrixC05;
	matrixC06_accum <= matrixC06;
	matrixC07_accum <= matrixC07;
	matrixC10_accum <= matrixC10;
	matrixC11_accum <= matrixC11;
	matrixC12_accum <= matrixC12;
	matrixC13_accum <= matrixC13;
	matrixC14_accum <= matrixC14;
	matrixC15_accum <= matrixC15;
	matrixC16_accum <= matrixC16;
	matrixC17_accum <= matrixC17;
	matrixC20_accum <= matrixC20;
	matrixC21_accum <= matrixC21;
	matrixC22_accum <= matrixC22;
	matrixC23_accum <= matrixC23;
	matrixC24_accum <= matrixC24;
	matrixC25_accum <= matrixC25;
	matrixC26_accum <= matrixC26;
	matrixC27_accum <= matrixC27;
	matrixC30_accum <= matrixC30;
	matrixC31_accum <= matrixC31;
	matrixC32_accum <= matrixC32;
	matrixC33_accum <= matrixC33;
	matrixC34_accum <= matrixC34;
	matrixC35_accum <= matrixC35;
	matrixC36_accum <= matrixC36;
	matrixC37_accum <= matrixC37;
	matrixC40_accum <= matrixC40;
	matrixC41_accum <= matrixC41;
	matrixC42_accum <= matrixC42;
	matrixC43_accum <= matrixC43;
	matrixC44_accum <= matrixC44;
	matrixC45_accum <= matrixC45;
	matrixC46_accum <= matrixC46;
	matrixC47_accum <= matrixC47;
	matrixC50_accum <= matrixC50;
	matrixC51_accum <= matrixC51;
	matrixC52_accum <= matrixC52;
	matrixC53_accum <= matrixC53;
	matrixC54_accum <= matrixC54;
	matrixC55_accum <= matrixC55;
	matrixC56_accum <= matrixC56;
	matrixC57_accum <= matrixC57;
	matrixC60_accum <= matrixC60;
	matrixC61_accum <= matrixC61;
	matrixC62_accum <= matrixC62;
	matrixC63_accum <= matrixC63;
	matrixC64_accum <= matrixC64;
	matrixC65_accum <= matrixC65;
	matrixC66_accum <= matrixC66;
	matrixC67_accum <= matrixC67;
	matrixC70_accum <= matrixC70;
	matrixC71_accum <= matrixC71;
	matrixC72_accum <= matrixC72;
	matrixC73_accum <= matrixC73;
	matrixC74_accum <= matrixC74;
	matrixC75_accum <= matrixC75;
	matrixC76_accum <= matrixC76;
	matrixC77_accum <= matrixC77;

    outputs_saved_to_accum <= 1;
  end
  else if (row_latch_en && add_accum_to_output) begin
    outputs_added_to_accum <= 1;
  end
end
assign matrixC00_added = (add_accum_to_output) ? (matrixC00 + matrixC00_accum) : matrixC00;
assign matrixC01_added = (add_accum_to_output) ? (matrixC01 + matrixC01_accum) : matrixC01;
assign matrixC02_added = (add_accum_to_output) ? (matrixC02 + matrixC02_accum) : matrixC02;
assign matrixC03_added = (add_accum_to_output) ? (matrixC03 + matrixC03_accum) : matrixC03;
assign matrixC04_added = (add_accum_to_output) ? (matrixC04 + matrixC04_accum) : matrixC04;
assign matrixC05_added = (add_accum_to_output) ? (matrixC05 + matrixC05_accum) : matrixC05;
assign matrixC06_added = (add_accum_to_output) ? (matrixC06 + matrixC06_accum) : matrixC06;
assign matrixC07_added = (add_accum_to_output) ? (matrixC07 + matrixC07_accum) : matrixC07;
assign matrixC10_added = (add_accum_to_output) ? (matrixC10 + matrixC10_accum) : matrixC10;
assign matrixC11_added = (add_accum_to_output) ? (matrixC11 + matrixC11_accum) : matrixC11;
assign matrixC12_added = (add_accum_to_output) ? (matrixC12 + matrixC12_accum) : matrixC12;
assign matrixC13_added = (add_accum_to_output) ? (matrixC13 + matrixC13_accum) : matrixC13;
assign matrixC14_added = (add_accum_to_output) ? (matrixC14 + matrixC14_accum) : matrixC14;
assign matrixC15_added = (add_accum_to_output) ? (matrixC15 + matrixC15_accum) : matrixC15;
assign matrixC16_added = (add_accum_to_output) ? (matrixC16 + matrixC16_accum) : matrixC16;
assign matrixC17_added = (add_accum_to_output) ? (matrixC17 + matrixC17_accum) : matrixC17;
assign matrixC20_added = (add_accum_to_output) ? (matrixC20 + matrixC20_accum) : matrixC20;
assign matrixC21_added = (add_accum_to_output) ? (matrixC21 + matrixC21_accum) : matrixC21;
assign matrixC22_added = (add_accum_to_output) ? (matrixC22 + matrixC22_accum) : matrixC22;
assign matrixC23_added = (add_accum_to_output) ? (matrixC23 + matrixC23_accum) : matrixC23;
assign matrixC24_added = (add_accum_to_output) ? (matrixC24 + matrixC24_accum) : matrixC24;
assign matrixC25_added = (add_accum_to_output) ? (matrixC25 + matrixC25_accum) : matrixC25;
assign matrixC26_added = (add_accum_to_output) ? (matrixC26 + matrixC26_accum) : matrixC26;
assign matrixC27_added = (add_accum_to_output) ? (matrixC27 + matrixC27_accum) : matrixC27;
assign matrixC30_added = (add_accum_to_output) ? (matrixC30 + matrixC30_accum) : matrixC30;
assign matrixC31_added = (add_accum_to_output) ? (matrixC31 + matrixC31_accum) : matrixC31;
assign matrixC32_added = (add_accum_to_output) ? (matrixC32 + matrixC32_accum) : matrixC32;
assign matrixC33_added = (add_accum_to_output) ? (matrixC33 + matrixC33_accum) : matrixC33;
assign matrixC34_added = (add_accum_to_output) ? (matrixC34 + matrixC34_accum) : matrixC34;
assign matrixC35_added = (add_accum_to_output) ? (matrixC35 + matrixC35_accum) : matrixC35;
assign matrixC36_added = (add_accum_to_output) ? (matrixC36 + matrixC36_accum) : matrixC36;
assign matrixC37_added = (add_accum_to_output) ? (matrixC37 + matrixC37_accum) : matrixC37;
assign matrixC40_added = (add_accum_to_output) ? (matrixC40 + matrixC40_accum) : matrixC40;
assign matrixC41_added = (add_accum_to_output) ? (matrixC41 + matrixC41_accum) : matrixC41;
assign matrixC42_added = (add_accum_to_output) ? (matrixC42 + matrixC42_accum) : matrixC42;
assign matrixC43_added = (add_accum_to_output) ? (matrixC43 + matrixC43_accum) : matrixC43;
assign matrixC44_added = (add_accum_to_output) ? (matrixC44 + matrixC44_accum) : matrixC44;
assign matrixC45_added = (add_accum_to_output) ? (matrixC45 + matrixC45_accum) : matrixC45;
assign matrixC46_added = (add_accum_to_output) ? (matrixC46 + matrixC46_accum) : matrixC46;
assign matrixC47_added = (add_accum_to_output) ? (matrixC47 + matrixC47_accum) : matrixC47;
assign matrixC50_added = (add_accum_to_output) ? (matrixC50 + matrixC50_accum) : matrixC50;
assign matrixC51_added = (add_accum_to_output) ? (matrixC51 + matrixC51_accum) : matrixC51;
assign matrixC52_added = (add_accum_to_output) ? (matrixC52 + matrixC52_accum) : matrixC52;
assign matrixC53_added = (add_accum_to_output) ? (matrixC53 + matrixC53_accum) : matrixC53;
assign matrixC54_added = (add_accum_to_output) ? (matrixC54 + matrixC54_accum) : matrixC54;
assign matrixC55_added = (add_accum_to_output) ? (matrixC55 + matrixC55_accum) : matrixC55;
assign matrixC56_added = (add_accum_to_output) ? (matrixC56 + matrixC56_accum) : matrixC56;
assign matrixC57_added = (add_accum_to_output) ? (matrixC57 + matrixC57_accum) : matrixC57;
assign matrixC60_added = (add_accum_to_output) ? (matrixC60 + matrixC60_accum) : matrixC60;
assign matrixC61_added = (add_accum_to_output) ? (matrixC61 + matrixC61_accum) : matrixC61;
assign matrixC62_added = (add_accum_to_output) ? (matrixC62 + matrixC62_accum) : matrixC62;
assign matrixC63_added = (add_accum_to_output) ? (matrixC63 + matrixC63_accum) : matrixC63;
assign matrixC64_added = (add_accum_to_output) ? (matrixC64 + matrixC64_accum) : matrixC64;
assign matrixC65_added = (add_accum_to_output) ? (matrixC65 + matrixC65_accum) : matrixC65;
assign matrixC66_added = (add_accum_to_output) ? (matrixC66 + matrixC66_accum) : matrixC66;
assign matrixC67_added = (add_accum_to_output) ? (matrixC67 + matrixC67_accum) : matrixC67;
assign matrixC70_added = (add_accum_to_output) ? (matrixC70 + matrixC70_accum) : matrixC70;
assign matrixC71_added = (add_accum_to_output) ? (matrixC71 + matrixC71_accum) : matrixC71;
assign matrixC72_added = (add_accum_to_output) ? (matrixC72 + matrixC72_accum) : matrixC72;
assign matrixC73_added = (add_accum_to_output) ? (matrixC73 + matrixC73_accum) : matrixC73;
assign matrixC74_added = (add_accum_to_output) ? (matrixC74 + matrixC74_accum) : matrixC74;
assign matrixC75_added = (add_accum_to_output) ? (matrixC75 + matrixC75_accum) : matrixC75;
assign matrixC76_added = (add_accum_to_output) ? (matrixC76 + matrixC76_accum) : matrixC76;
assign matrixC77_added = (add_accum_to_output) ? (matrixC77 + matrixC77_accum) : matrixC77;

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
reg [8*`DWIDTH-1:0] c_data_out;

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
    c_data_out <= {matrixC70_added, matrixC60_added, matrixC50_added, matrixC40_added, matrixC30_added, matrixC20_added, matrixC10_added, matrixC00_added};

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
    		1: c_data_out <= {matrixC71_added, matrixC61_added, matrixC51_added, matrixC41_added, matrixC31_added, matrixC21_added, matrixC11_added, matrixC01_added};
		2: c_data_out <= {matrixC72_added, matrixC62_added, matrixC52_added, matrixC42_added, matrixC32_added, matrixC22_added, matrixC12_added, matrixC02_added};
		3: c_data_out <= {matrixC73_added, matrixC63_added, matrixC53_added, matrixC43_added, matrixC33_added, matrixC23_added, matrixC13_added, matrixC03_added};
		4: c_data_out <= {matrixC74_added, matrixC64_added, matrixC54_added, matrixC44_added, matrixC34_added, matrixC24_added, matrixC14_added, matrixC04_added};
		5: c_data_out <= {matrixC75_added, matrixC65_added, matrixC55_added, matrixC45_added, matrixC35_added, matrixC25_added, matrixC15_added, matrixC05_added};
		6: c_data_out <= {matrixC76_added, matrixC66_added, matrixC56_added, matrixC46_added, matrixC36_added, matrixC26_added, matrixC16_added, matrixC06_added};
		7: c_data_out <= {matrixC77_added, matrixC67_added, matrixC57_added, matrixC47_added, matrixC37_added, matrixC27_added, matrixC17_added, matrixC07_added};

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


//////////////////////////

//cfg.v 

//////////////////////////

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
    //TODO: We need to change the precision of compute to a larger 
    //number. For now, using the DWIDTH variable, but we need a 
    //HIGH_PRECISION_DWIDTH kind of thing
    output reg [`DWIDTH-1:0] mean,
    output reg [`DWIDTH-1:0] inv_var,
		output reg [`MAX_BITS_POOL-1:0] kernel_size,
		output reg [`AWIDTH-1:0] address_mat_a,
    output reg [`AWIDTH-1:0] address_mat_b,
    output reg [`AWIDTH-1:0] address_mat_c,
    output reg [`MASK_WIDTH-1:0] validity_mask,
    output reg save_output_to_accum,
    output reg add_accum_to_output,
    output reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_a,
    output reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_b,
    output reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_c,
    output reg activation_type,
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
    kernel_size <= 1;
		reg_dummy <= 0;
    address_mat_a <= 0;
    address_mat_b <= 0;
    address_mat_c <= 0;
    validity_mask <= {`MASK_WIDTH{1'b1}};
    save_output_to_accum <= 0;
    add_accum_to_output <= 0;
    address_stride_a <= `MAT_MUL_SIZE;
    address_stride_b <= `MAT_MUL_SIZE;
    address_stride_c <= `MAT_MUL_SIZE;
    activation_type <= 1;
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
      end

      `W_ENABLE : begin
        if (PSEL && PWRITE && PENABLE) begin
          case (PADDR)
          `REG_ENABLES_ADDR   : begin 
                                enable_activation <= PWDATA[3];
                                enable_pool       <= PWDATA[2];
                                enable_norm       <= PWDATA[1];
                                enable_matmul     <= PWDATA[0];
                                end
          `REG_STDN_TPU_ADDR  : start_tpu <= PWDATA[0];
          `REG_MEAN_ADDR      : mean <= PWDATA[`DWIDTH-1:0];
          `REG_INV_VAR_ADDR   : inv_var <= PWDATA[`DWIDTH-1:0];
          `REG_MATRIX_A_ADDR  : address_mat_a <= PWDATA[`AWIDTH-1:0];
          `REG_MATRIX_B_ADDR  : address_mat_b <= PWDATA[`AWIDTH-1:0];
          `REG_MATRIX_C_ADDR  : address_mat_c <= PWDATA[`AWIDTH-1:0];
          `REG_VALID_MASK_ADDR: validity_mask <= PWDATA[`MASK_WIDTH-1:0];
          `REG_POOL_KERNEL_SIZE: kernel_size <= PWDATA[`MAX_BITS_POOL-1:0];
					`REG_ACCUM_ACTIONS_ADDR: begin
                                   add_accum_to_output <= PWDATA[1];
                                   save_output_to_accum <= PWDATA[0];
                                   end
          `REG_MATRIX_A_STRIDE_ADDR : address_stride_a <= PWDATA[`ADDR_STRIDE_WIDTH-1:0];
          `REG_MATRIX_B_STRIDE_ADDR : address_stride_b <= PWDATA[`ADDR_STRIDE_WIDTH-1:0];
          `REG_MATRIX_C_STRIDE_ADDR : address_stride_c <= PWDATA[`ADDR_STRIDE_WIDTH-1:0];
          `REG_ACTIVATION_CSR_ADDR  : activation_type  <= PWDATA[0];
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
          `REG_VALID_MASK_ADDR: PRDATA <= validity_mask;
          `REG_POOL_KERNEL_SIZE : PRDATA <= kernel_size;
					`REG_ACCUM_ACTIONS_ADDR: PRDATA <= {30'b0, add_accum_to_output, save_output_to_accum};
          `REG_MATRIX_A_STRIDE_ADDR : PRDATA <= address_stride_a;
          `REG_MATRIX_B_STRIDE_ADDR : PRDATA <= address_stride_b;
          `REG_MATRIX_C_STRIDE_ADDR : PRDATA <= address_stride_c;
          `REG_ACTIVATION_CSR_ADDR  : PRDATA <= {31'b0, activation_type};
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


//////////////////////////

//norm.v 

//////////////////////////

module norm(
    input enable_norm,
    input [`DWIDTH-1:0] mean,
    input [`DWIDTH-1:0] inv_var,
    input in_data_available,
    input [`MAT_MUL_SIZE*`DWIDTH-1:0] inp_data,
    output [`MAT_MUL_SIZE*`DWIDTH-1:0] out_data,
    output out_data_available,
    input [`MASK_WIDTH-1:0] validity_mask,
    output done_norm,
    input clk,
    input reset
);

reg out_data_available_internal;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] out_data_internal;
reg [`MAT_MUL_SIZE*`DWIDTH-1:0] mean_applied_data;
reg [`MAT_MUL_SIZE*`DWIDTH-1:0] variance_applied_data;
reg done_norm_internal;
reg norm_in_progress;

//Muxing logic to handle the case when this block is disabled
assign out_data_available = (enable_norm) ? out_data_available_internal : in_data_available;
assign out_data = (enable_norm) ? out_data_internal : inp_data;
assign done_norm = (enable_norm) ? done_norm_internal : 1'b1;

//inp_data will have multiple elements in it. the number of elements is the same as size of the matmul.
//on each clock edge, if in_data_available is 1, then we will normalize the inputs.

//the code uses the funky part-select syntax. example:
//wire [7:0] byteN = word[byte_num*8 +: 8];
//byte_num*8 is the starting point. 8 is the width is the part-select (has to be constant).in_data_available
//+: indicates the part-select increases from the starting point
//-: indicates the part-select decreases from the starting point
//another example:
//loc = 3;
//PA[loc -:4] = PA[loc+1 +:4];  // equivalent to PA[3:0] = PA[7:4];

integer cycle_count;
integer i;
always @(posedge clk) begin
    if ((reset || ~enable_norm)) begin
        mean_applied_data <= 0;
        variance_applied_data <= 0;
        out_data_available_internal <= 0;
        cycle_count <= 0;
        done_norm_internal <= 0;
        norm_in_progress <= 0;
    end else if (in_data_available || norm_in_progress) begin
        cycle_count = cycle_count + 1;
        //Let's apply mean and variance as the input data comes in.
        //We have a pipeline here. First stage does the add (to apply the mean)
        //and second stage does the multiplication (to apply the variance).
        //Note: the following loop is not a loop across multiple columns of data.
        //This loop will run in 2 cycle on the same column of data that comes into 
        //this module in 1 clock.
        for (i = 0; i < `MAT_MUL_SIZE; i=i+1) begin
            if (validity_mask[i] == 1'b1) begin
                mean_applied_data[i*`DWIDTH +: `DWIDTH] <= (inp_data[i*`DWIDTH +: `DWIDTH] - mean);
                variance_applied_data[i*`DWIDTH +: `DWIDTH] <= (mean_applied_data[i*`DWIDTH +: `DWIDTH] * inv_var);
            end 
            else begin
                mean_applied_data[i*`DWIDTH +: `DWIDTH] <= (inp_data[i*`DWIDTH +: `DWIDTH]);
                variance_applied_data[i*`DWIDTH +: `DWIDTH] <= (mean_applied_data[i*`DWIDTH +: `DWIDTH]);
            end
        end

        //Out data is available starting with the second clock cycle because 
        //in the first cycle, we only apply the mean.
        if(cycle_count==2) begin
            out_data_available_internal <= 1;
        end

        //When we've normalized values N times, where N is the matmul
        //size, that means we're done. But there is one additional cycle
        //that is taken in the beginning (when we are applying the mean to the first
        //column of data). We can call this the Initiation Interval of the pipeline.
        //So, for a 4x4 matmul, this block takes 5 cycles.
        if(cycle_count==(`MAT_MUL_SIZE+1)) begin
            done_norm_internal <= 1'b1;
            norm_in_progress <= 0;
        end
        else begin
            norm_in_progress <= 1;
        end
    end
    else begin
        mean_applied_data <= 0;
        variance_applied_data <= 0;
        out_data_available_internal <= 0;
        cycle_count <= 0;
        done_norm_internal <= 0;
        norm_in_progress <= 0;
    end
end

assign out_data_internal = variance_applied_data;

endmodule

//////////////////////////

//ram.v 

//////////////////////////

//////////////////////////////////
//Dual port RAM
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

input [`AWIDTH-1:0] addr0;
input [`AWIDTH-1:0] addr1;
input [`MASK_WIDTH*`DWIDTH-1:0] d0;
input [`MASK_WIDTH*`DWIDTH-1:0] d1;
input [`MASK_WIDTH-1:0] we0;
input [`MASK_WIDTH-1:0] we1;
output reg [`MASK_WIDTH*`DWIDTH-1:0] q0;
output reg [`MASK_WIDTH*`DWIDTH-1:0] q1;
input clk;

`ifdef SIMULATION

reg [7:0] ram[((1<<`AWIDTH)-1):0];
integer i;

always @(posedge clk)  
begin 
    for (i = 0; i < `MASK_WIDTH; i=i+1) begin
        if (we0[i]) ram[addr0+i] <= d0[i*`DWIDTH +: `DWIDTH]; 
    end    
    for (i = 0; i < `MASK_WIDTH; i=i+1) begin
        q0[i*`DWIDTH +: `DWIDTH] <= ram[addr0+i];
    end    
end

always @(posedge clk)  
begin 
    for (i = 0; i < `MASK_WIDTH; i=i+1) begin
        if (we1[i]) ram[addr0+i] <= d1[i*`DWIDTH +: `DWIDTH]; 
    end    
    for (i = 0; i < `MASK_WIDTH; i=i+1) begin
        q1[i*`DWIDTH +: `DWIDTH] <= ram[addr1+i];
    end    
end

`else
//BRAMs available in VTR FPGA architectures have one bit write-enables.
//So let's combine multiple bits into 1. We don't have a usecase of
//writing/not-writing only parts of the word anyway.
wire we0_coalesced;
assign we0_coalesced = |we0;
wire we1_coalesced;
assign we1_coalesced = |we1;

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

`endif


endmodule

//////////////////////////

//control.v 

//////////////////////////

//Top level state machine
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

//////////////////////////

//pool.v 

//////////////////////////

module pool(
    input enable_pool,
    input in_data_available,
		input [`MAX_BITS_POOL-1:0] kernel_size,
    input [`MAT_MUL_SIZE*`DWIDTH-1:0] inp_data,
    output [`MAT_MUL_SIZE*`DWIDTH-1:0] out_data,
    output out_data_available,
    input [`MASK_WIDTH-1:0] validity_mask,
    output done_pool,
    input clk,
    input reset
);

reg [`MAT_MUL_SIZE*`DWIDTH-1:0] out_data_temp;
reg done_pool_temp;
reg out_data_available_temp;
integer i,j;
integer cycle_count;

always @(posedge clk) begin
	if (reset || ~enable_pool || ~in_data_available) begin
		out_data_temp <= 0;
		done_pool_temp <= 0;
		out_data_available_temp <= 0;
		cycle_count <= 0;
	end

	else if (in_data_available) begin
        cycle_count = cycle_count + 1;
		out_data_available_temp <= 1;

		case (kernel_size)
			1: begin
				out_data_temp <= inp_data;
			end
			2: begin
				for (i = 0; i < `MAT_MUL_SIZE/2; i = i + 8) begin
					out_data_temp[ i +: 8] <= (inp_data[i*2 +: 8]  + inp_data[i*2 + 8 +: 8]) >> 1; 
				end
			end
			4: begin	
				for (i = 0; i < `MAT_MUL_SIZE/4; i = i + 8) begin
					//TODO: If 3 adders are the critical path, break into 2 cycles
					out_data_temp[ i +: 8] <= (inp_data[i*4 +: 8]  + inp_data[i*4 + 8 +: 8] + inp_data[i*4 + 16 +: 8]  + inp_data[i*4 + 24 +: 8]) >> 2; 
				end
			end
		endcase			

        if(cycle_count==`MAT_MUL_SIZE) begin	 
            done_pool_temp <= 1'b1;	      
        end	  
	end
end

assign out_data = enable_pool ? out_data_temp : inp_data; 
assign out_data_available = enable_pool ? out_data_available_temp : in_data_available;
assign done_pool = enable_pool ? done_pool_temp : 1'b1;

//Adding a dummy signal to use validity_mask input, to make ODIN happy
wire [`MASK_WIDTH-1:0] dummy;
assign dummy = validity_mask;

endmodule


//////////////////////////

//activation.v 

//////////////////////////

module activation(
    input activation_type,
    input enable_activation,
    input in_data_available,
    input [`MAT_MUL_SIZE*`DWIDTH-1:0] inp_data,
    output [`MAT_MUL_SIZE*`DWIDTH-1:0] out_data,
    output out_data_available,
    input [`MASK_WIDTH-1:0] validity_mask,
    output done_activation,
    input clk,
    input reset
);

reg  finish_activation;
reg  out_data_valid;
reg  [`MAT_MUL_SIZE*`DWIDTH-1:0] out_activation;
integer i;

reg [3:0] address[`MAT_MUL_SIZE-1:0];
reg [7:0] data_slope[`MAT_MUL_SIZE-1:0];
reg [7:0] data_intercept[`MAT_MUL_SIZE-1:0];

// If the activation block is not enabled, just forward the input data
assign out_data             = enable_activation ? out_activation    : inp_data;
assign done_activation      = enable_activation ? finish_activation : 1'b1;
assign out_data_available   = enable_activation ? out_data_valid    : in_data_available;

always @(posedge clk) begin
    if (reset) begin
      out_activation   <= {`MAT_MUL_SIZE*`DWIDTH-1{1'b0}};
      finish_activation<= 1'b0;
      out_data_valid   <= 1'b0;
    end
    else begin
       if(in_data_available) begin
           for (i = 0; i < `MAT_MUL_SIZE; i=i+1) begin
               if(activation_type==1'b1) begin // tanH
                    out_activation[i*`DWIDTH +:`DWIDTH] <= data_slope[i] * inp_data[i*`DWIDTH +:`DWIDTH] + data_intercept[i];
               end
               else begin // ReLU
                    out_activation[i*`DWIDTH +:`DWIDTH] <= inp_data[i*`DWIDTH-1] ? {`DWIDTH{1'b0}} : inp_data[i*`DWIDTH +:`DWIDTH];
               end
           end 
           finish_activation<= 1'b1;
           out_data_valid   <= 1'b1;
       end
       else begin
           out_activation   <= {`MAT_MUL_SIZE*`DWIDTH-1{1'b0}};
           finish_activation<= 1'b0;
           out_data_valid   <= 1'b0;
       end
    end
end

//Our equation of tanh is Y=AX+B
//A is the slope and B is the intercept.
//We store A in one LUT and B in another.
//LUT for the slope
always @(address) begin
    for (i = 0; i < `MAT_MUL_SIZE; i=i+1) begin
    case (address[i])
      4'b0000: data_slope[i][7:0] = 8'd0;
      4'b0001: data_slope[i][7:0] = 8'd0;
      4'b0010: data_slope[i][7:0] = 8'd2;
      4'b0011: data_slope[i][7:0] = 8'd3;
      4'b0100: data_slope[i][7:0] = 8'd4;
      4'b0101: data_slope[i][7:0] = 8'd0;
      4'b0110: data_slope[i][7:0] = 8'd4;
      4'b0111: data_slope[i][7:0] = 8'd3;
      4'b1000: data_slope[i][7:0] = 8'd2;
      4'b1001: data_slope[i][7:0] = 8'd0;
      4'b1010: data_slope[i][7:0] = 8'd0;
      default: data_slope[i][7:0] = 8'd0;
    endcase  
    end
end

//LUT for the intercept
always @(address) begin
    for (i = 0; i < `MAT_MUL_SIZE; i=i+1) begin
    case (address[i])
      4'b0000: data_intercept[i][7:0] = 8'd127;
      4'b0001: data_intercept[i][7:0] = 8'd99;
      4'b0010: data_intercept[i][7:0] = 8'd46;
      4'b0011: data_intercept[i][7:0] = 8'd18;
      4'b0100: data_intercept[i][7:0] = 8'd0;
      4'b0101: data_intercept[i][7:0] = 8'd0;
      4'b0110: data_intercept[i][7:0] = 8'd0;
      4'b0111: data_intercept[i][7:0] = -8'd18;
      4'b1000: data_intercept[i][7:0] = -8'd46;
      4'b1001: data_intercept[i][7:0] = -8'd99;
      4'b1010: data_intercept[i][7:0] = -8'd127;
      default: data_intercept[i][7:0] = 8'd0;
    endcase  
    end
end

//Logic to find address
always @(inp_data) begin
    for (i = 0; i < `MAT_MUL_SIZE; i=i+1) begin
        if((inp_data[i*`DWIDTH +:`DWIDTH])>=90) begin
           address[i][3:0] = 4'b0000;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])>=39 && (inp_data[i*`DWIDTH +:`DWIDTH])<90) begin
           address[i][3:0] = 4'b0001;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])>=28 && (inp_data[i*`DWIDTH +:`DWIDTH])<39) begin
           address[i][3:0] = 4'b0010;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])>=16 && (inp_data[i*`DWIDTH +:`DWIDTH])<28) begin
           address[i][3:0] = 4'b0011;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])>=1 && (inp_data[i*`DWIDTH +:`DWIDTH])<16) begin
           address[i][3:0] = 4'b0100;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])==0) begin
           address[i][3:0] = 4'b0101;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])>-16 && (inp_data[i*`DWIDTH +:`DWIDTH])<=-1) begin
           address[i][3:0] = 4'b0110;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])>-28 && (inp_data[i*`DWIDTH +:`DWIDTH])<=-16) begin
           address[i][3:0] = 4'b0111;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])>-39 && (inp_data[i*`DWIDTH +:`DWIDTH])<=-28) begin
           address[i][3:0] = 4'b1000;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])>-90 && (inp_data[i*`DWIDTH +:`DWIDTH])<=-39) begin
           address[i][3:0] = 4'b1001;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])<=-90) begin
           address[i][3:0] = 4'b1010;
        end
        else begin
           address[i][3:0] = 4'b0101;
        end
    end
end

//Adding a dummy signal to use validity_mask input, to make ODIN happy
//TODO: Need to correctly use validity_mask
wire [`MASK_WIDTH-1:0] dummy;
assign dummy = validity_mask;

// generate multiple ReLU block based on the MAT_MUL_SIZE
//genvar i;
//generate 
//  for (i = 1; i <= `MAT_MUL_SIZE; i = i + 1) begin : loop_gen_ReLU
//        ReLU ReLUinst (.inp_data(inp_data[i*`DWIDTH-1 -:`DWIDTH]), .out_data(temp[i*`DWIDTH-1 -:`DWIDTH]));
//  end
//endgenerate

endmodule

//module ReLU(
//    input [`DWIDTH-1:0] inp_data,
//    output[`DWIDTH-1:0] out_data
//);
//
//assign out_data = inp_data[`DWIDTH-1] ? {`DWIDTH{1'b0}} : inp_data;
//
//endmodule


//////////////////////////

//top.v 

//////////////////////////

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
    output [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_ext,
    input  [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_ext,
    input  [`MASK_WIDTH-1:0] bram_we_a_ext,
    input  [`AWIDTH-1:0] bram_addr_b_ext,
    output [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_ext,
    input  [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_ext,
    input  [`MASK_WIDTH-1:0] bram_we_b_ext
);

wire [`AWIDTH-1:0] bram_addr_a;
wire [`AWIDTH-1:0] bram_addr_a_for_reading;
reg [`AWIDTH-1:0] bram_addr_a_for_writing;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a;
reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a;
wire [`MASK_WIDTH-1:0] bram_we_a;
wire bram_en_a;
wire [`AWIDTH-1:0] bram_addr_b;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b;
wire [`MASK_WIDTH-1:0] bram_we_b;
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
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] matmul_c_data_out;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] norm_data_out;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] pool_data_out;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] activation_data_out;
wire matmul_c_data_available;
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out_NC;
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out_NC;
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_NC;
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_NC;
wire [`DWIDTH-1:0] mean;
wire [`DWIDTH-1:0] inv_var;
wire [`AWIDTH-1:0] address_mat_a;
wire [`AWIDTH-1:0] address_mat_b;
wire [`AWIDTH-1:0] address_mat_c;
wire [`MASK_WIDTH-1:0] validity_mask;
wire save_output_to_accum;
wire add_accum_to_output;
wire [`ADDR_STRIDE_WIDTH-1:0] address_stride_a;
wire [`ADDR_STRIDE_WIDTH-1:0] address_stride_b;
wire [`ADDR_STRIDE_WIDTH-1:0] address_stride_c;
wire [`MAX_BITS_POOL-1:0] kernel_size;
wire activation_type;

//Connections for bram a (activation/input matrix)
//bram_addr_a -> connected to u_matmul_4x4
//bram_rdata_a -> connected to u_matmul_4x4
//bram_wdata_a -> will come from the last block that is enabled
//bram_we_a -> will be 1 when the last block's data is available
//bram_en_a -> hardcoded to 1
assign bram_addr_a = (bram_a_wdata_available) ? bram_addr_a_for_writing : bram_addr_a_for_reading;
assign bram_en_a = 1'b1;
assign bram_we_a = (bram_a_wdata_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  
  
//Connections for bram b (weights matrix)
//bram_addr_b -> connected to u_matmul_4x4
//bram_rdata_b -> connected to u_matmul_4x4
//bram_wdata_b -> hardcoded to 0 (this block only reads from bram b)
//bram_we_b -> hardcoded to 0 (this block only reads from bram b)
//bram_en_b -> hardcoded to 1
assign bram_wdata_b = {`BB_MAT_MUL_SIZE*`DWIDTH{1'b0}};
assign bram_en_b = 1'b1;
assign bram_we_b = {`MASK_WIDTH{1'b0}};
  
////////////////////////////////////////////////////////////////
// BRAM matrix A (inputs/activations)
////////////////////////////////////////////////////////////////
ram matrix_A (
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
ram matrix_B (
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
  .mean(mean),
  .inv_var(inv_var),
  .kernel_size(kernel_size),
	.address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .validity_mask(validity_mask),
  .save_output_to_accum(save_output_to_accum),
  .add_accum_to_output(add_accum_to_output),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .activation_type(activation_type),
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
matmul u_matmul(
  .clk(clk),
  .reset(reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul),
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
  .c_data_in({`BB_MAT_MUL_SIZE*`DWIDTH{1'b0}}),
  .c_data_out(matmul_c_data_out),
  .a_data_out(a_data_out_NC),
  .b_data_out(b_data_out_NC),
  .a_addr(bram_addr_a_for_reading),
  .b_addr(bram_addr_b),
  .c_addr(bram_addr_c_NC),
  .c_data_available(matmul_c_data_available),
  .save_output_to_accum(save_output_to_accum),
  .add_accum_to_output(add_accum_to_output),
  .final_mat_mul_size(8'd8),
  .a_loc(8'd0),
  .b_loc(8'd0)
);

////////////////////////////////////////////////////////////////
// Normalization module
////////////////////////////////////////////////////////////////
norm u_norm(
  .enable_norm(enable_norm),
  .mean(mean),
  .inv_var(inv_var),
  .in_data_available(matmul_c_data_available),
  .inp_data(matmul_c_data_out),
  .out_data(norm_data_out),
  .out_data_available(norm_out_data_available),
  .validity_mask(validity_mask),
  .done_norm(done_norm),
  .clk(clk),
  .reset(reset)
);

////////////////////////////////////////////////////////////////
// Pooling module
////////////////////////////////////////////////////////////////
pool u_pool(
  .enable_pool(enable_pool),
  .in_data_available(norm_out_data_available),
  .kernel_size(kernel_size),
	.inp_data(norm_data_out),
  .out_data(pool_data_out),
  .out_data_available(pool_out_data_available),
  .validity_mask(validity_mask),
  .done_pool(done_pool),
  .clk(clk),
  .reset(reset)
);

////////////////////////////////////////////////////////////////
// Activation module
////////////////////////////////////////////////////////////////
activation u_activation(
  .activation_type(activation_type),
  .enable_activation(enable_activation),
  .in_data_available(pool_out_data_available),
  .inp_data(pool_data_out),
  .out_data(activation_data_out),
  .out_data_available(activation_out_data_available),
  .validity_mask(validity_mask),
  .done_activation(done_activation),
  .clk(clk),
  .reset(reset)
);

//Interface to BRAM to write the output.
//Ideally, we could remove this flop stage. But then we'd
//have to generate the address for the output BRAM in each
//block that could potentially write the output.
always @(posedge clk) begin
  if (reset) begin
    bram_wdata_a <= 0;
    bram_addr_a_for_writing <= address_mat_c-address_stride_c;
    bram_a_wdata_available <= 0;
  end
  else if (activation_out_data_available) begin
    bram_wdata_a <= activation_data_out;
    bram_addr_a_for_writing <= bram_addr_a_for_writing + address_stride_c;
    bram_a_wdata_available <= activation_out_data_available;
  end
  else begin
    bram_wdata_a <= 0;
    bram_addr_a_for_writing <= address_mat_c-address_stride_c;
    bram_a_wdata_available <= 0;
  end
end  

endmodule


