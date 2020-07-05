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
//Bit `MASK_WIDTH-1:0 validity_mask_a_rows
//Bit 2*`MASK_WIDTH-1:`MASK_WIDTH validity_mask_a_cols_b_rows
//Bit 3*`MASK_WIDTH-1:2*`MASK_WIDTH validity_mask_b_cols

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


//////////////////////////

//8x8_gen.v 

//////////////////////////


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020-07-05 15:55:15.367750
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
    a_mem_access_counter <= a_mem_access_counter + 1;  
    if ((validity_mask_a_cols_b_rows[0]==1'b0 && a_mem_access_counter==0) ||
        (validity_mask_a_cols_b_rows[1]==1'b0 && a_mem_access_counter==1) ||
        (validity_mask_a_cols_b_rows[2]==1'b0 && a_mem_access_counter==2) ||
        (validity_mask_a_cols_b_rows[3]==1'b0 && a_mem_access_counter==3) ||
        (validity_mask_a_cols_b_rows[4]==1'b0 && a_mem_access_counter==4) ||
        (validity_mask_a_cols_b_rows[5]==1'b0 && a_mem_access_counter==5) ||
        (validity_mask_a_cols_b_rows[6]==1'b0 && a_mem_access_counter==6) ||
        (validity_mask_a_cols_b_rows[7]==1'b0 && a_mem_access_counter==7)) begin
    
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
wire [`DWIDTH-1:0] a0_data;
wire [`DWIDTH-1:0] a1_data;
wire [`DWIDTH-1:0] a2_data;
wire [`DWIDTH-1:0] a3_data;
wire [`DWIDTH-1:0] a4_data;
wire [`DWIDTH-1:0] a5_data;
wire [`DWIDTH-1:0] a6_data;
wire [`DWIDTH-1:0] a7_data;

assign a0_data = a_data[1*`DWIDTH-1:0*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[0]}};
assign a1_data = a_data[2*`DWIDTH-1:1*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[1]}};
assign a2_data = a_data[3*`DWIDTH-1:2*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[2]}};
assign a3_data = a_data[4*`DWIDTH-1:3*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[3]}};
assign a4_data = a_data[5*`DWIDTH-1:4*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[4]}};
assign a5_data = a_data[6*`DWIDTH-1:5*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[5]}};
assign a6_data = a_data[7*`DWIDTH-1:6*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[6]}};
assign a7_data = a_data[8*`DWIDTH-1:7*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[7]}};

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
    b_mem_access_counter <= b_mem_access_counter + 1;  
    if ((validity_mask_a_cols_b_rows[0]==1'b0 && b_mem_access_counter==0) ||
        (validity_mask_a_cols_b_rows[1]==1'b0 && b_mem_access_counter==1) ||
        (validity_mask_a_cols_b_rows[2]==1'b0 && b_mem_access_counter==2) ||
        (validity_mask_a_cols_b_rows[3]==1'b0 && b_mem_access_counter==3) ||
        (validity_mask_a_cols_b_rows[4]==1'b0 && b_mem_access_counter==4) ||
        (validity_mask_a_cols_b_rows[5]==1'b0 && b_mem_access_counter==5) ||
        (validity_mask_a_cols_b_rows[6]==1'b0 && b_mem_access_counter==6) ||
        (validity_mask_a_cols_b_rows[7]==1'b0 && b_mem_access_counter==7)) begin
    
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
wire [`DWIDTH-1:0] b0_data;
wire [`DWIDTH-1:0] b1_data;
wire [`DWIDTH-1:0] b2_data;
wire [`DWIDTH-1:0] b3_data;
wire [`DWIDTH-1:0] b4_data;
wire [`DWIDTH-1:0] b5_data;
wire [`DWIDTH-1:0] b6_data;
wire [`DWIDTH-1:0] b7_data;

assign b0_data = b_data[1*`DWIDTH-1:0*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[0]}};
assign b1_data = b_data[2*`DWIDTH-1:1*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[1]}};
assign b2_data = b_data[3*`DWIDTH-1:2*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[2]}};
assign b3_data = b_data[4*`DWIDTH-1:3*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[3]}};
assign b4_data = b_data[5*`DWIDTH-1:4*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[4]}};
assign b5_data = b_data[6*`DWIDTH-1:5*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[5]}};
assign b6_data = b_data[7*`DWIDTH-1:6*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[6]}};
assign b7_data = b_data[8*`DWIDTH-1:7*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[7]}};

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



//////////////////////////////////////////////////////////////////////////
// Logic to handle accumulation of partial sums (accumulators)
//////////////////////////////////////////////////////////////////////////

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
wire [`DWIDTH-1:0] cin_row0;
wire [`DWIDTH-1:0] cin_row1;
wire [`DWIDTH-1:0] cin_row2;
wire [`DWIDTH-1:0] cin_row3;
wire [`DWIDTH-1:0] cin_row4;
wire [`DWIDTH-1:0] cin_row5;
wire [`DWIDTH-1:0] cin_row6;
wire [`DWIDTH-1:0] cin_row7;
wire row_latch_en;

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
assign cin_row0 = c_data_in[1*`DWIDTH-1:0*`DWIDTH];
assign cin_row1 = c_data_in[2*`DWIDTH-1:1*`DWIDTH];
assign cin_row2 = c_data_in[3*`DWIDTH-1:2*`DWIDTH];
assign cin_row3 = c_data_in[4*`DWIDTH-1:3*`DWIDTH];
assign cin_row4 = c_data_in[5*`DWIDTH-1:4*`DWIDTH];
assign cin_row5 = c_data_in[6*`DWIDTH-1:5*`DWIDTH];
assign cin_row6 = c_data_in[7*`DWIDTH-1:6*`DWIDTH];
assign cin_row7 = c_data_in[8*`DWIDTH-1:7*`DWIDTH];
wire [`DWIDTH-1:0] matrixC0_0_added;
wire [`DWIDTH-1:0] matrixC0_1_added;
wire [`DWIDTH-1:0] matrixC0_2_added;
wire [`DWIDTH-1:0] matrixC0_3_added;
wire [`DWIDTH-1:0] matrixC0_4_added;
wire [`DWIDTH-1:0] matrixC0_5_added;
wire [`DWIDTH-1:0] matrixC0_6_added;
wire [`DWIDTH-1:0] matrixC0_7_added;
wire [`DWIDTH-1:0] matrixC1_0_added;
wire [`DWIDTH-1:0] matrixC1_1_added;
wire [`DWIDTH-1:0] matrixC1_2_added;
wire [`DWIDTH-1:0] matrixC1_3_added;
wire [`DWIDTH-1:0] matrixC1_4_added;
wire [`DWIDTH-1:0] matrixC1_5_added;
wire [`DWIDTH-1:0] matrixC1_6_added;
wire [`DWIDTH-1:0] matrixC1_7_added;
wire [`DWIDTH-1:0] matrixC2_0_added;
wire [`DWIDTH-1:0] matrixC2_1_added;
wire [`DWIDTH-1:0] matrixC2_2_added;
wire [`DWIDTH-1:0] matrixC2_3_added;
wire [`DWIDTH-1:0] matrixC2_4_added;
wire [`DWIDTH-1:0] matrixC2_5_added;
wire [`DWIDTH-1:0] matrixC2_6_added;
wire [`DWIDTH-1:0] matrixC2_7_added;
wire [`DWIDTH-1:0] matrixC3_0_added;
wire [`DWIDTH-1:0] matrixC3_1_added;
wire [`DWIDTH-1:0] matrixC3_2_added;
wire [`DWIDTH-1:0] matrixC3_3_added;
wire [`DWIDTH-1:0] matrixC3_4_added;
wire [`DWIDTH-1:0] matrixC3_5_added;
wire [`DWIDTH-1:0] matrixC3_6_added;
wire [`DWIDTH-1:0] matrixC3_7_added;
wire [`DWIDTH-1:0] matrixC4_0_added;
wire [`DWIDTH-1:0] matrixC4_1_added;
wire [`DWIDTH-1:0] matrixC4_2_added;
wire [`DWIDTH-1:0] matrixC4_3_added;
wire [`DWIDTH-1:0] matrixC4_4_added;
wire [`DWIDTH-1:0] matrixC4_5_added;
wire [`DWIDTH-1:0] matrixC4_6_added;
wire [`DWIDTH-1:0] matrixC4_7_added;
wire [`DWIDTH-1:0] matrixC5_0_added;
wire [`DWIDTH-1:0] matrixC5_1_added;
wire [`DWIDTH-1:0] matrixC5_2_added;
wire [`DWIDTH-1:0] matrixC5_3_added;
wire [`DWIDTH-1:0] matrixC5_4_added;
wire [`DWIDTH-1:0] matrixC5_5_added;
wire [`DWIDTH-1:0] matrixC5_6_added;
wire [`DWIDTH-1:0] matrixC5_7_added;
wire [`DWIDTH-1:0] matrixC6_0_added;
wire [`DWIDTH-1:0] matrixC6_1_added;
wire [`DWIDTH-1:0] matrixC6_2_added;
wire [`DWIDTH-1:0] matrixC6_3_added;
wire [`DWIDTH-1:0] matrixC6_4_added;
wire [`DWIDTH-1:0] matrixC6_5_added;
wire [`DWIDTH-1:0] matrixC6_6_added;
wire [`DWIDTH-1:0] matrixC6_7_added;
wire [`DWIDTH-1:0] matrixC7_0_added;
wire [`DWIDTH-1:0] matrixC7_1_added;
wire [`DWIDTH-1:0] matrixC7_2_added;
wire [`DWIDTH-1:0] matrixC7_3_added;
wire [`DWIDTH-1:0] matrixC7_4_added;
wire [`DWIDTH-1:0] matrixC7_5_added;
wire [`DWIDTH-1:0] matrixC7_6_added;
wire [`DWIDTH-1:0] matrixC7_7_added;


reg [`DWIDTH-1:0] matrixC0_0_accum;
reg [`DWIDTH-1:0] matrixC0_1_accum;
reg [`DWIDTH-1:0] matrixC0_2_accum;
reg [`DWIDTH-1:0] matrixC0_3_accum;
reg [`DWIDTH-1:0] matrixC0_4_accum;
reg [`DWIDTH-1:0] matrixC0_5_accum;
reg [`DWIDTH-1:0] matrixC0_6_accum;
reg [`DWIDTH-1:0] matrixC0_7_accum;
reg [`DWIDTH-1:0] matrixC1_0_accum;
reg [`DWIDTH-1:0] matrixC1_1_accum;
reg [`DWIDTH-1:0] matrixC1_2_accum;
reg [`DWIDTH-1:0] matrixC1_3_accum;
reg [`DWIDTH-1:0] matrixC1_4_accum;
reg [`DWIDTH-1:0] matrixC1_5_accum;
reg [`DWIDTH-1:0] matrixC1_6_accum;
reg [`DWIDTH-1:0] matrixC1_7_accum;
reg [`DWIDTH-1:0] matrixC2_0_accum;
reg [`DWIDTH-1:0] matrixC2_1_accum;
reg [`DWIDTH-1:0] matrixC2_2_accum;
reg [`DWIDTH-1:0] matrixC2_3_accum;
reg [`DWIDTH-1:0] matrixC2_4_accum;
reg [`DWIDTH-1:0] matrixC2_5_accum;
reg [`DWIDTH-1:0] matrixC2_6_accum;
reg [`DWIDTH-1:0] matrixC2_7_accum;
reg [`DWIDTH-1:0] matrixC3_0_accum;
reg [`DWIDTH-1:0] matrixC3_1_accum;
reg [`DWIDTH-1:0] matrixC3_2_accum;
reg [`DWIDTH-1:0] matrixC3_3_accum;
reg [`DWIDTH-1:0] matrixC3_4_accum;
reg [`DWIDTH-1:0] matrixC3_5_accum;
reg [`DWIDTH-1:0] matrixC3_6_accum;
reg [`DWIDTH-1:0] matrixC3_7_accum;
reg [`DWIDTH-1:0] matrixC4_0_accum;
reg [`DWIDTH-1:0] matrixC4_1_accum;
reg [`DWIDTH-1:0] matrixC4_2_accum;
reg [`DWIDTH-1:0] matrixC4_3_accum;
reg [`DWIDTH-1:0] matrixC4_4_accum;
reg [`DWIDTH-1:0] matrixC4_5_accum;
reg [`DWIDTH-1:0] matrixC4_6_accum;
reg [`DWIDTH-1:0] matrixC4_7_accum;
reg [`DWIDTH-1:0] matrixC5_0_accum;
reg [`DWIDTH-1:0] matrixC5_1_accum;
reg [`DWIDTH-1:0] matrixC5_2_accum;
reg [`DWIDTH-1:0] matrixC5_3_accum;
reg [`DWIDTH-1:0] matrixC5_4_accum;
reg [`DWIDTH-1:0] matrixC5_5_accum;
reg [`DWIDTH-1:0] matrixC5_6_accum;
reg [`DWIDTH-1:0] matrixC5_7_accum;
reg [`DWIDTH-1:0] matrixC6_0_accum;
reg [`DWIDTH-1:0] matrixC6_1_accum;
reg [`DWIDTH-1:0] matrixC6_2_accum;
reg [`DWIDTH-1:0] matrixC6_3_accum;
reg [`DWIDTH-1:0] matrixC6_4_accum;
reg [`DWIDTH-1:0] matrixC6_5_accum;
reg [`DWIDTH-1:0] matrixC6_6_accum;
reg [`DWIDTH-1:0] matrixC6_7_accum;
reg [`DWIDTH-1:0] matrixC7_0_accum;
reg [`DWIDTH-1:0] matrixC7_1_accum;
reg [`DWIDTH-1:0] matrixC7_2_accum;
reg [`DWIDTH-1:0] matrixC7_3_accum;
reg [`DWIDTH-1:0] matrixC7_4_accum;
reg [`DWIDTH-1:0] matrixC7_5_accum;
reg [`DWIDTH-1:0] matrixC7_6_accum;
reg [`DWIDTH-1:0] matrixC7_7_accum;

reg outputs_saved_to_accum;
reg outputs_added_to_accum;
wire reset_accum;

always @(posedge clk) begin
  if (reset || ~(save_output_to_accum || add_accum_to_output) || (reset_accum)) begin
matrixC0_0_accum <= 0;
matrixC0_1_accum <= 0;
matrixC0_2_accum <= 0;
matrixC0_3_accum <= 0;
matrixC0_4_accum <= 0;
matrixC0_5_accum <= 0;
matrixC0_6_accum <= 0;
matrixC0_7_accum <= 0;
matrixC1_0_accum <= 0;
matrixC1_1_accum <= 0;
matrixC1_2_accum <= 0;
matrixC1_3_accum <= 0;
matrixC1_4_accum <= 0;
matrixC1_5_accum <= 0;
matrixC1_6_accum <= 0;
matrixC1_7_accum <= 0;
matrixC2_0_accum <= 0;
matrixC2_1_accum <= 0;
matrixC2_2_accum <= 0;
matrixC2_3_accum <= 0;
matrixC2_4_accum <= 0;
matrixC2_5_accum <= 0;
matrixC2_6_accum <= 0;
matrixC2_7_accum <= 0;
matrixC3_0_accum <= 0;
matrixC3_1_accum <= 0;
matrixC3_2_accum <= 0;
matrixC3_3_accum <= 0;
matrixC3_4_accum <= 0;
matrixC3_5_accum <= 0;
matrixC3_6_accum <= 0;
matrixC3_7_accum <= 0;
matrixC4_0_accum <= 0;
matrixC4_1_accum <= 0;
matrixC4_2_accum <= 0;
matrixC4_3_accum <= 0;
matrixC4_4_accum <= 0;
matrixC4_5_accum <= 0;
matrixC4_6_accum <= 0;
matrixC4_7_accum <= 0;
matrixC5_0_accum <= 0;
matrixC5_1_accum <= 0;
matrixC5_2_accum <= 0;
matrixC5_3_accum <= 0;
matrixC5_4_accum <= 0;
matrixC5_5_accum <= 0;
matrixC5_6_accum <= 0;
matrixC5_7_accum <= 0;
matrixC6_0_accum <= 0;
matrixC6_1_accum <= 0;
matrixC6_2_accum <= 0;
matrixC6_3_accum <= 0;
matrixC6_4_accum <= 0;
matrixC6_5_accum <= 0;
matrixC6_6_accum <= 0;
matrixC6_7_accum <= 0;
matrixC7_0_accum <= 0;
matrixC7_1_accum <= 0;
matrixC7_2_accum <= 0;
matrixC7_3_accum <= 0;
matrixC7_4_accum <= 0;
matrixC7_5_accum <= 0;
matrixC7_6_accum <= 0;
matrixC7_7_accum <= 0;
 outputs_saved_to_accum <= 0;
    outputs_added_to_accum <= 0;

    cur_c_saved <= 0;
    cur_r_saved <= 0;
    cur_s_saved <= 0;
  
  end
  else if (row_latch_en && save_output_to_accum && add_accum_to_output) begin
	matrixC0_0_accum <= matrixC0_0_added;
	matrixC0_1_accum <= matrixC0_1_added;
	matrixC0_2_accum <= matrixC0_2_added;
	matrixC0_3_accum <= matrixC0_3_added;
	matrixC0_4_accum <= matrixC0_4_added;
	matrixC0_5_accum <= matrixC0_5_added;
	matrixC0_6_accum <= matrixC0_6_added;
	matrixC0_7_accum <= matrixC0_7_added;
	matrixC1_0_accum <= matrixC1_0_added;
	matrixC1_1_accum <= matrixC1_1_added;
	matrixC1_2_accum <= matrixC1_2_added;
	matrixC1_3_accum <= matrixC1_3_added;
	matrixC1_4_accum <= matrixC1_4_added;
	matrixC1_5_accum <= matrixC1_5_added;
	matrixC1_6_accum <= matrixC1_6_added;
	matrixC1_7_accum <= matrixC1_7_added;
	matrixC2_0_accum <= matrixC2_0_added;
	matrixC2_1_accum <= matrixC2_1_added;
	matrixC2_2_accum <= matrixC2_2_added;
	matrixC2_3_accum <= matrixC2_3_added;
	matrixC2_4_accum <= matrixC2_4_added;
	matrixC2_5_accum <= matrixC2_5_added;
	matrixC2_6_accum <= matrixC2_6_added;
	matrixC2_7_accum <= matrixC2_7_added;
	matrixC3_0_accum <= matrixC3_0_added;
	matrixC3_1_accum <= matrixC3_1_added;
	matrixC3_2_accum <= matrixC3_2_added;
	matrixC3_3_accum <= matrixC3_3_added;
	matrixC3_4_accum <= matrixC3_4_added;
	matrixC3_5_accum <= matrixC3_5_added;
	matrixC3_6_accum <= matrixC3_6_added;
	matrixC3_7_accum <= matrixC3_7_added;
	matrixC4_0_accum <= matrixC4_0_added;
	matrixC4_1_accum <= matrixC4_1_added;
	matrixC4_2_accum <= matrixC4_2_added;
	matrixC4_3_accum <= matrixC4_3_added;
	matrixC4_4_accum <= matrixC4_4_added;
	matrixC4_5_accum <= matrixC4_5_added;
	matrixC4_6_accum <= matrixC4_6_added;
	matrixC4_7_accum <= matrixC4_7_added;
	matrixC5_0_accum <= matrixC5_0_added;
	matrixC5_1_accum <= matrixC5_1_added;
	matrixC5_2_accum <= matrixC5_2_added;
	matrixC5_3_accum <= matrixC5_3_added;
	matrixC5_4_accum <= matrixC5_4_added;
	matrixC5_5_accum <= matrixC5_5_added;
	matrixC5_6_accum <= matrixC5_6_added;
	matrixC5_7_accum <= matrixC5_7_added;
	matrixC6_0_accum <= matrixC6_0_added;
	matrixC6_1_accum <= matrixC6_1_added;
	matrixC6_2_accum <= matrixC6_2_added;
	matrixC6_3_accum <= matrixC6_3_added;
	matrixC6_4_accum <= matrixC6_4_added;
	matrixC6_5_accum <= matrixC6_5_added;
	matrixC6_6_accum <= matrixC6_6_added;
	matrixC6_7_accum <= matrixC6_7_added;
	matrixC7_0_accum <= matrixC7_0_added;
	matrixC7_1_accum <= matrixC7_1_added;
	matrixC7_2_accum <= matrixC7_2_added;
	matrixC7_3_accum <= matrixC7_3_added;
	matrixC7_4_accum <= matrixC7_4_added;
	matrixC7_5_accum <= matrixC7_5_added;
	matrixC7_6_accum <= matrixC7_6_added;
	matrixC7_7_accum <= matrixC7_7_added;

    outputs_saved_to_accum <= 1;
    outputs_added_to_accum <= 1;

    cur_c_saved <= c;
    cur_r_saved <= r;
    cur_s_saved <= s;
  
  end
  else if (row_latch_en && save_output_to_accum) begin
	matrixC0_0_accum <= matrixC0_0;
	matrixC0_1_accum <= matrixC0_1;
	matrixC0_2_accum <= matrixC0_2;
	matrixC0_3_accum <= matrixC0_3;
	matrixC0_4_accum <= matrixC0_4;
	matrixC0_5_accum <= matrixC0_5;
	matrixC0_6_accum <= matrixC0_6;
	matrixC0_7_accum <= matrixC0_7;
	matrixC1_0_accum <= matrixC1_0;
	matrixC1_1_accum <= matrixC1_1;
	matrixC1_2_accum <= matrixC1_2;
	matrixC1_3_accum <= matrixC1_3;
	matrixC1_4_accum <= matrixC1_4;
	matrixC1_5_accum <= matrixC1_5;
	matrixC1_6_accum <= matrixC1_6;
	matrixC1_7_accum <= matrixC1_7;
	matrixC2_0_accum <= matrixC2_0;
	matrixC2_1_accum <= matrixC2_1;
	matrixC2_2_accum <= matrixC2_2;
	matrixC2_3_accum <= matrixC2_3;
	matrixC2_4_accum <= matrixC2_4;
	matrixC2_5_accum <= matrixC2_5;
	matrixC2_6_accum <= matrixC2_6;
	matrixC2_7_accum <= matrixC2_7;
	matrixC3_0_accum <= matrixC3_0;
	matrixC3_1_accum <= matrixC3_1;
	matrixC3_2_accum <= matrixC3_2;
	matrixC3_3_accum <= matrixC3_3;
	matrixC3_4_accum <= matrixC3_4;
	matrixC3_5_accum <= matrixC3_5;
	matrixC3_6_accum <= matrixC3_6;
	matrixC3_7_accum <= matrixC3_7;
	matrixC4_0_accum <= matrixC4_0;
	matrixC4_1_accum <= matrixC4_1;
	matrixC4_2_accum <= matrixC4_2;
	matrixC4_3_accum <= matrixC4_3;
	matrixC4_4_accum <= matrixC4_4;
	matrixC4_5_accum <= matrixC4_5;
	matrixC4_6_accum <= matrixC4_6;
	matrixC4_7_accum <= matrixC4_7;
	matrixC5_0_accum <= matrixC5_0;
	matrixC5_1_accum <= matrixC5_1;
	matrixC5_2_accum <= matrixC5_2;
	matrixC5_3_accum <= matrixC5_3;
	matrixC5_4_accum <= matrixC5_4;
	matrixC5_5_accum <= matrixC5_5;
	matrixC5_6_accum <= matrixC5_6;
	matrixC5_7_accum <= matrixC5_7;
	matrixC6_0_accum <= matrixC6_0;
	matrixC6_1_accum <= matrixC6_1;
	matrixC6_2_accum <= matrixC6_2;
	matrixC6_3_accum <= matrixC6_3;
	matrixC6_4_accum <= matrixC6_4;
	matrixC6_5_accum <= matrixC6_5;
	matrixC6_6_accum <= matrixC6_6;
	matrixC6_7_accum <= matrixC6_7;
	matrixC7_0_accum <= matrixC7_0;
	matrixC7_1_accum <= matrixC7_1;
	matrixC7_2_accum <= matrixC7_2;
	matrixC7_3_accum <= matrixC7_3;
	matrixC7_4_accum <= matrixC7_4;
	matrixC7_5_accum <= matrixC7_5;
	matrixC7_6_accum <= matrixC7_6;
	matrixC7_7_accum <= matrixC7_7;

    outputs_saved_to_accum <= 1;

    cur_c_saved <= c;
    cur_r_saved <= r;
    cur_s_saved <= s;
  
  end
  else if (row_latch_en && add_accum_to_output) begin
    outputs_added_to_accum <= 1;
  end
end
assign matrixC0_0_added = (add_accum_to_output) ? (matrixC0_0 + matrixC0_0_accum) : matrixC0_0;
assign matrixC0_1_added = (add_accum_to_output) ? (matrixC0_1 + matrixC0_1_accum) : matrixC0_1;
assign matrixC0_2_added = (add_accum_to_output) ? (matrixC0_2 + matrixC0_2_accum) : matrixC0_2;
assign matrixC0_3_added = (add_accum_to_output) ? (matrixC0_3 + matrixC0_3_accum) : matrixC0_3;
assign matrixC0_4_added = (add_accum_to_output) ? (matrixC0_4 + matrixC0_4_accum) : matrixC0_4;
assign matrixC0_5_added = (add_accum_to_output) ? (matrixC0_5 + matrixC0_5_accum) : matrixC0_5;
assign matrixC0_6_added = (add_accum_to_output) ? (matrixC0_6 + matrixC0_6_accum) : matrixC0_6;
assign matrixC0_7_added = (add_accum_to_output) ? (matrixC0_7 + matrixC0_7_accum) : matrixC0_7;
assign matrixC1_0_added = (add_accum_to_output) ? (matrixC1_0 + matrixC1_0_accum) : matrixC1_0;
assign matrixC1_1_added = (add_accum_to_output) ? (matrixC1_1 + matrixC1_1_accum) : matrixC1_1;
assign matrixC1_2_added = (add_accum_to_output) ? (matrixC1_2 + matrixC1_2_accum) : matrixC1_2;
assign matrixC1_3_added = (add_accum_to_output) ? (matrixC1_3 + matrixC1_3_accum) : matrixC1_3;
assign matrixC1_4_added = (add_accum_to_output) ? (matrixC1_4 + matrixC1_4_accum) : matrixC1_4;
assign matrixC1_5_added = (add_accum_to_output) ? (matrixC1_5 + matrixC1_5_accum) : matrixC1_5;
assign matrixC1_6_added = (add_accum_to_output) ? (matrixC1_6 + matrixC1_6_accum) : matrixC1_6;
assign matrixC1_7_added = (add_accum_to_output) ? (matrixC1_7 + matrixC1_7_accum) : matrixC1_7;
assign matrixC2_0_added = (add_accum_to_output) ? (matrixC2_0 + matrixC2_0_accum) : matrixC2_0;
assign matrixC2_1_added = (add_accum_to_output) ? (matrixC2_1 + matrixC2_1_accum) : matrixC2_1;
assign matrixC2_2_added = (add_accum_to_output) ? (matrixC2_2 + matrixC2_2_accum) : matrixC2_2;
assign matrixC2_3_added = (add_accum_to_output) ? (matrixC2_3 + matrixC2_3_accum) : matrixC2_3;
assign matrixC2_4_added = (add_accum_to_output) ? (matrixC2_4 + matrixC2_4_accum) : matrixC2_4;
assign matrixC2_5_added = (add_accum_to_output) ? (matrixC2_5 + matrixC2_5_accum) : matrixC2_5;
assign matrixC2_6_added = (add_accum_to_output) ? (matrixC2_6 + matrixC2_6_accum) : matrixC2_6;
assign matrixC2_7_added = (add_accum_to_output) ? (matrixC2_7 + matrixC2_7_accum) : matrixC2_7;
assign matrixC3_0_added = (add_accum_to_output) ? (matrixC3_0 + matrixC3_0_accum) : matrixC3_0;
assign matrixC3_1_added = (add_accum_to_output) ? (matrixC3_1 + matrixC3_1_accum) : matrixC3_1;
assign matrixC3_2_added = (add_accum_to_output) ? (matrixC3_2 + matrixC3_2_accum) : matrixC3_2;
assign matrixC3_3_added = (add_accum_to_output) ? (matrixC3_3 + matrixC3_3_accum) : matrixC3_3;
assign matrixC3_4_added = (add_accum_to_output) ? (matrixC3_4 + matrixC3_4_accum) : matrixC3_4;
assign matrixC3_5_added = (add_accum_to_output) ? (matrixC3_5 + matrixC3_5_accum) : matrixC3_5;
assign matrixC3_6_added = (add_accum_to_output) ? (matrixC3_6 + matrixC3_6_accum) : matrixC3_6;
assign matrixC3_7_added = (add_accum_to_output) ? (matrixC3_7 + matrixC3_7_accum) : matrixC3_7;
assign matrixC4_0_added = (add_accum_to_output) ? (matrixC4_0 + matrixC4_0_accum) : matrixC4_0;
assign matrixC4_1_added = (add_accum_to_output) ? (matrixC4_1 + matrixC4_1_accum) : matrixC4_1;
assign matrixC4_2_added = (add_accum_to_output) ? (matrixC4_2 + matrixC4_2_accum) : matrixC4_2;
assign matrixC4_3_added = (add_accum_to_output) ? (matrixC4_3 + matrixC4_3_accum) : matrixC4_3;
assign matrixC4_4_added = (add_accum_to_output) ? (matrixC4_4 + matrixC4_4_accum) : matrixC4_4;
assign matrixC4_5_added = (add_accum_to_output) ? (matrixC4_5 + matrixC4_5_accum) : matrixC4_5;
assign matrixC4_6_added = (add_accum_to_output) ? (matrixC4_6 + matrixC4_6_accum) : matrixC4_6;
assign matrixC4_7_added = (add_accum_to_output) ? (matrixC4_7 + matrixC4_7_accum) : matrixC4_7;
assign matrixC5_0_added = (add_accum_to_output) ? (matrixC5_0 + matrixC5_0_accum) : matrixC5_0;
assign matrixC5_1_added = (add_accum_to_output) ? (matrixC5_1 + matrixC5_1_accum) : matrixC5_1;
assign matrixC5_2_added = (add_accum_to_output) ? (matrixC5_2 + matrixC5_2_accum) : matrixC5_2;
assign matrixC5_3_added = (add_accum_to_output) ? (matrixC5_3 + matrixC5_3_accum) : matrixC5_3;
assign matrixC5_4_added = (add_accum_to_output) ? (matrixC5_4 + matrixC5_4_accum) : matrixC5_4;
assign matrixC5_5_added = (add_accum_to_output) ? (matrixC5_5 + matrixC5_5_accum) : matrixC5_5;
assign matrixC5_6_added = (add_accum_to_output) ? (matrixC5_6 + matrixC5_6_accum) : matrixC5_6;
assign matrixC5_7_added = (add_accum_to_output) ? (matrixC5_7 + matrixC5_7_accum) : matrixC5_7;
assign matrixC6_0_added = (add_accum_to_output) ? (matrixC6_0 + matrixC6_0_accum) : matrixC6_0;
assign matrixC6_1_added = (add_accum_to_output) ? (matrixC6_1 + matrixC6_1_accum) : matrixC6_1;
assign matrixC6_2_added = (add_accum_to_output) ? (matrixC6_2 + matrixC6_2_accum) : matrixC6_2;
assign matrixC6_3_added = (add_accum_to_output) ? (matrixC6_3 + matrixC6_3_accum) : matrixC6_3;
assign matrixC6_4_added = (add_accum_to_output) ? (matrixC6_4 + matrixC6_4_accum) : matrixC6_4;
assign matrixC6_5_added = (add_accum_to_output) ? (matrixC6_5 + matrixC6_5_accum) : matrixC6_5;
assign matrixC6_6_added = (add_accum_to_output) ? (matrixC6_6 + matrixC6_6_accum) : matrixC6_6;
assign matrixC6_7_added = (add_accum_to_output) ? (matrixC6_7 + matrixC6_7_accum) : matrixC6_7;
assign matrixC7_0_added = (add_accum_to_output) ? (matrixC7_0 + matrixC7_0_accum) : matrixC7_0;
assign matrixC7_1_added = (add_accum_to_output) ? (matrixC7_1 + matrixC7_1_accum) : matrixC7_1;
assign matrixC7_2_added = (add_accum_to_output) ? (matrixC7_2 + matrixC7_2_accum) : matrixC7_2;
assign matrixC7_3_added = (add_accum_to_output) ? (matrixC7_3 + matrixC7_3_accum) : matrixC7_3;
assign matrixC7_4_added = (add_accum_to_output) ? (matrixC7_4 + matrixC7_4_accum) : matrixC7_4;
assign matrixC7_5_added = (add_accum_to_output) ? (matrixC7_5 + matrixC7_5_accum) : matrixC7_5;
assign matrixC7_6_added = (add_accum_to_output) ? (matrixC7_6 + matrixC7_6_accum) : matrixC7_6;
assign matrixC7_7_added = (add_accum_to_output) ? (matrixC7_7 + matrixC7_7_accum) : matrixC7_7;

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
    c_data_out <= {matrixC7_0_added, matrixC6_0_added, matrixC5_0_added, matrixC4_0_added, matrixC3_0_added, matrixC2_0_added, matrixC1_0_added, matrixC0_0_added};

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
    		1: c_data_out <= {matrixC7_1_added, matrixC6_1_added, matrixC5_1_added, matrixC4_1_added, matrixC3_1_added, matrixC2_1_added, matrixC1_1_added, matrixC0_1_added};
		2: c_data_out <= {matrixC7_2_added, matrixC6_2_added, matrixC5_2_added, matrixC4_2_added, matrixC3_2_added, matrixC2_2_added, matrixC1_2_added, matrixC0_2_added};
		3: c_data_out <= {matrixC7_3_added, matrixC6_3_added, matrixC5_3_added, matrixC4_3_added, matrixC3_3_added, matrixC2_3_added, matrixC1_3_added, matrixC0_3_added};
		4: c_data_out <= {matrixC7_4_added, matrixC6_4_added, matrixC5_4_added, matrixC4_4_added, matrixC3_4_added, matrixC2_4_added, matrixC1_4_added, matrixC0_4_added};
		5: c_data_out <= {matrixC7_5_added, matrixC6_5_added, matrixC5_5_added, matrixC4_5_added, matrixC3_5_added, matrixC2_5_added, matrixC1_5_added, matrixC0_5_added};
		6: c_data_out <= {matrixC7_6_added, matrixC6_6_added, matrixC5_6_added, matrixC4_6_added, matrixC3_6_added, matrixC2_6_added, matrixC1_6_added, matrixC0_6_added};
		7: c_data_out <= {matrixC7_7_added, matrixC6_7_added, matrixC5_7_added, matrixC4_7_added, matrixC3_7_added, matrixC2_7_added, matrixC1_7_added, matrixC0_7_added};

        default: c_data_out <= 0;
    endcase
  end
end
//////////////////////////////////////////////////////////////////////////
// Instantiations of the actual PEs
//////////////////////////////////////////////////////////////////////////
//For larger matmul, more PEs will be needed
wire effective_rst;
assign effective_rst = reset | ~start_mat_mul;

processing_element pe0_0(.reset(effective_rst), .clk(clk),  .in_a(a0),      .in_b(b0),  .out_a(a0_0to0_1), .out_b(b0_0to1_0), .out_c(matrixC0_0));
processing_element pe0_1(.reset(effective_rst), .clk(clk),  .in_a(a0_0to0_1), .in_b(b1),  .out_a(a0_1to0_2), .out_b(b0_1to1_1), .out_c(matrixC0_1));
processing_element pe0_2(.reset(effective_rst), .clk(clk),  .in_a(a0_1to0_2), .in_b(b2),  .out_a(a0_2to0_3), .out_b(b0_2to1_2), .out_c(matrixC0_2));
processing_element pe0_3(.reset(effective_rst), .clk(clk),  .in_a(a0_2to0_3), .in_b(b3),  .out_a(a0_3to0_4), .out_b(b0_3to1_3), .out_c(matrixC0_3));
processing_element pe0_4(.reset(effective_rst), .clk(clk),  .in_a(a0_3to0_4), .in_b(b4),  .out_a(a0_4to0_5), .out_b(b0_4to1_4), .out_c(matrixC0_4));
processing_element pe0_5(.reset(effective_rst), .clk(clk),  .in_a(a0_4to0_5), .in_b(b5),  .out_a(a0_5to0_6), .out_b(b0_5to1_5), .out_c(matrixC0_5));
processing_element pe0_6(.reset(effective_rst), .clk(clk),  .in_a(a0_5to0_6), .in_b(b6),  .out_a(a0_6to0_7), .out_b(b0_6to1_6), .out_c(matrixC0_6));
processing_element pe0_7(.reset(effective_rst), .clk(clk),  .in_a(a0_6to0_7), .in_b(b7),  .out_a(a0_7to0_8), .out_b(b0_7to1_7), .out_c(matrixC0_7));

processing_element pe1_0(.reset(effective_rst), .clk(clk),  .in_a(a1), .in_b(b0_0to1_0),  .out_a(a1_0to1_1), .out_b(b1_0to2_0), .out_c(matrixC1_0));
processing_element pe2_0(.reset(effective_rst), .clk(clk),  .in_a(a2), .in_b(b1_0to2_0),  .out_a(a2_0to2_1), .out_b(b2_0to3_0), .out_c(matrixC2_0));
processing_element pe3_0(.reset(effective_rst), .clk(clk),  .in_a(a3), .in_b(b2_0to3_0),  .out_a(a3_0to3_1), .out_b(b3_0to4_0), .out_c(matrixC3_0));
processing_element pe4_0(.reset(effective_rst), .clk(clk),  .in_a(a4), .in_b(b3_0to4_0),  .out_a(a4_0to4_1), .out_b(b4_0to5_0), .out_c(matrixC4_0));
processing_element pe5_0(.reset(effective_rst), .clk(clk),  .in_a(a5), .in_b(b4_0to5_0),  .out_a(a5_0to5_1), .out_b(b5_0to6_0), .out_c(matrixC5_0));
processing_element pe6_0(.reset(effective_rst), .clk(clk),  .in_a(a6), .in_b(b5_0to6_0),  .out_a(a6_0to6_1), .out_b(b6_0to7_0), .out_c(matrixC6_0));
processing_element pe7_0(.reset(effective_rst), .clk(clk),  .in_a(a7), .in_b(b6_0to7_0),  .out_a(a7_0to7_1), .out_b(b7_0to8_0), .out_c(matrixC7_0));

processing_element pe1_1(.reset(effective_rst), .clk(clk),  .in_a(a1_0to1_1), .in_b(b0_1to1_1),  .out_a(a1_1to1_2), .out_b(b1_1to2_1), .out_c(matrixC1_1));
processing_element pe1_2(.reset(effective_rst), .clk(clk),  .in_a(a1_1to1_2), .in_b(b0_2to1_2),  .out_a(a1_2to1_3), .out_b(b1_2to2_2), .out_c(matrixC1_2));
processing_element pe1_3(.reset(effective_rst), .clk(clk),  .in_a(a1_2to1_3), .in_b(b0_3to1_3),  .out_a(a1_3to1_4), .out_b(b1_3to2_3), .out_c(matrixC1_3));
processing_element pe1_4(.reset(effective_rst), .clk(clk),  .in_a(a1_3to1_4), .in_b(b0_4to1_4),  .out_a(a1_4to1_5), .out_b(b1_4to2_4), .out_c(matrixC1_4));
processing_element pe1_5(.reset(effective_rst), .clk(clk),  .in_a(a1_4to1_5), .in_b(b0_5to1_5),  .out_a(a1_5to1_6), .out_b(b1_5to2_5), .out_c(matrixC1_5));
processing_element pe1_6(.reset(effective_rst), .clk(clk),  .in_a(a1_5to1_6), .in_b(b0_6to1_6),  .out_a(a1_6to1_7), .out_b(b1_6to2_6), .out_c(matrixC1_6));
processing_element pe1_7(.reset(effective_rst), .clk(clk),  .in_a(a1_6to1_7), .in_b(b0_7to1_7),  .out_a(a1_7to1_8), .out_b(b1_7to2_7), .out_c(matrixC1_7));
processing_element pe2_1(.reset(effective_rst), .clk(clk),  .in_a(a2_0to2_1), .in_b(b1_1to2_1),  .out_a(a2_1to2_2), .out_b(b2_1to3_1), .out_c(matrixC2_1));
processing_element pe2_2(.reset(effective_rst), .clk(clk),  .in_a(a2_1to2_2), .in_b(b1_2to2_2),  .out_a(a2_2to2_3), .out_b(b2_2to3_2), .out_c(matrixC2_2));
processing_element pe2_3(.reset(effective_rst), .clk(clk),  .in_a(a2_2to2_3), .in_b(b1_3to2_3),  .out_a(a2_3to2_4), .out_b(b2_3to3_3), .out_c(matrixC2_3));
processing_element pe2_4(.reset(effective_rst), .clk(clk),  .in_a(a2_3to2_4), .in_b(b1_4to2_4),  .out_a(a2_4to2_5), .out_b(b2_4to3_4), .out_c(matrixC2_4));
processing_element pe2_5(.reset(effective_rst), .clk(clk),  .in_a(a2_4to2_5), .in_b(b1_5to2_5),  .out_a(a2_5to2_6), .out_b(b2_5to3_5), .out_c(matrixC2_5));
processing_element pe2_6(.reset(effective_rst), .clk(clk),  .in_a(a2_5to2_6), .in_b(b1_6to2_6),  .out_a(a2_6to2_7), .out_b(b2_6to3_6), .out_c(matrixC2_6));
processing_element pe2_7(.reset(effective_rst), .clk(clk),  .in_a(a2_6to2_7), .in_b(b1_7to2_7),  .out_a(a2_7to2_8), .out_b(b2_7to3_7), .out_c(matrixC2_7));
processing_element pe3_1(.reset(effective_rst), .clk(clk),  .in_a(a3_0to3_1), .in_b(b2_1to3_1),  .out_a(a3_1to3_2), .out_b(b3_1to4_1), .out_c(matrixC3_1));
processing_element pe3_2(.reset(effective_rst), .clk(clk),  .in_a(a3_1to3_2), .in_b(b2_2to3_2),  .out_a(a3_2to3_3), .out_b(b3_2to4_2), .out_c(matrixC3_2));
processing_element pe3_3(.reset(effective_rst), .clk(clk),  .in_a(a3_2to3_3), .in_b(b2_3to3_3),  .out_a(a3_3to3_4), .out_b(b3_3to4_3), .out_c(matrixC3_3));
processing_element pe3_4(.reset(effective_rst), .clk(clk),  .in_a(a3_3to3_4), .in_b(b2_4to3_4),  .out_a(a3_4to3_5), .out_b(b3_4to4_4), .out_c(matrixC3_4));
processing_element pe3_5(.reset(effective_rst), .clk(clk),  .in_a(a3_4to3_5), .in_b(b2_5to3_5),  .out_a(a3_5to3_6), .out_b(b3_5to4_5), .out_c(matrixC3_5));
processing_element pe3_6(.reset(effective_rst), .clk(clk),  .in_a(a3_5to3_6), .in_b(b2_6to3_6),  .out_a(a3_6to3_7), .out_b(b3_6to4_6), .out_c(matrixC3_6));
processing_element pe3_7(.reset(effective_rst), .clk(clk),  .in_a(a3_6to3_7), .in_b(b2_7to3_7),  .out_a(a3_7to3_8), .out_b(b3_7to4_7), .out_c(matrixC3_7));
processing_element pe4_1(.reset(effective_rst), .clk(clk),  .in_a(a4_0to4_1), .in_b(b3_1to4_1),  .out_a(a4_1to4_2), .out_b(b4_1to5_1), .out_c(matrixC4_1));
processing_element pe4_2(.reset(effective_rst), .clk(clk),  .in_a(a4_1to4_2), .in_b(b3_2to4_2),  .out_a(a4_2to4_3), .out_b(b4_2to5_2), .out_c(matrixC4_2));
processing_element pe4_3(.reset(effective_rst), .clk(clk),  .in_a(a4_2to4_3), .in_b(b3_3to4_3),  .out_a(a4_3to4_4), .out_b(b4_3to5_3), .out_c(matrixC4_3));
processing_element pe4_4(.reset(effective_rst), .clk(clk),  .in_a(a4_3to4_4), .in_b(b3_4to4_4),  .out_a(a4_4to4_5), .out_b(b4_4to5_4), .out_c(matrixC4_4));
processing_element pe4_5(.reset(effective_rst), .clk(clk),  .in_a(a4_4to4_5), .in_b(b3_5to4_5),  .out_a(a4_5to4_6), .out_b(b4_5to5_5), .out_c(matrixC4_5));
processing_element pe4_6(.reset(effective_rst), .clk(clk),  .in_a(a4_5to4_6), .in_b(b3_6to4_6),  .out_a(a4_6to4_7), .out_b(b4_6to5_6), .out_c(matrixC4_6));
processing_element pe4_7(.reset(effective_rst), .clk(clk),  .in_a(a4_6to4_7), .in_b(b3_7to4_7),  .out_a(a4_7to4_8), .out_b(b4_7to5_7), .out_c(matrixC4_7));
processing_element pe5_1(.reset(effective_rst), .clk(clk),  .in_a(a5_0to5_1), .in_b(b4_1to5_1),  .out_a(a5_1to5_2), .out_b(b5_1to6_1), .out_c(matrixC5_1));
processing_element pe5_2(.reset(effective_rst), .clk(clk),  .in_a(a5_1to5_2), .in_b(b4_2to5_2),  .out_a(a5_2to5_3), .out_b(b5_2to6_2), .out_c(matrixC5_2));
processing_element pe5_3(.reset(effective_rst), .clk(clk),  .in_a(a5_2to5_3), .in_b(b4_3to5_3),  .out_a(a5_3to5_4), .out_b(b5_3to6_3), .out_c(matrixC5_3));
processing_element pe5_4(.reset(effective_rst), .clk(clk),  .in_a(a5_3to5_4), .in_b(b4_4to5_4),  .out_a(a5_4to5_5), .out_b(b5_4to6_4), .out_c(matrixC5_4));
processing_element pe5_5(.reset(effective_rst), .clk(clk),  .in_a(a5_4to5_5), .in_b(b4_5to5_5),  .out_a(a5_5to5_6), .out_b(b5_5to6_5), .out_c(matrixC5_5));
processing_element pe5_6(.reset(effective_rst), .clk(clk),  .in_a(a5_5to5_6), .in_b(b4_6to5_6),  .out_a(a5_6to5_7), .out_b(b5_6to6_6), .out_c(matrixC5_6));
processing_element pe5_7(.reset(effective_rst), .clk(clk),  .in_a(a5_6to5_7), .in_b(b4_7to5_7),  .out_a(a5_7to5_8), .out_b(b5_7to6_7), .out_c(matrixC5_7));
processing_element pe6_1(.reset(effective_rst), .clk(clk),  .in_a(a6_0to6_1), .in_b(b5_1to6_1),  .out_a(a6_1to6_2), .out_b(b6_1to7_1), .out_c(matrixC6_1));
processing_element pe6_2(.reset(effective_rst), .clk(clk),  .in_a(a6_1to6_2), .in_b(b5_2to6_2),  .out_a(a6_2to6_3), .out_b(b6_2to7_2), .out_c(matrixC6_2));
processing_element pe6_3(.reset(effective_rst), .clk(clk),  .in_a(a6_2to6_3), .in_b(b5_3to6_3),  .out_a(a6_3to6_4), .out_b(b6_3to7_3), .out_c(matrixC6_3));
processing_element pe6_4(.reset(effective_rst), .clk(clk),  .in_a(a6_3to6_4), .in_b(b5_4to6_4),  .out_a(a6_4to6_5), .out_b(b6_4to7_4), .out_c(matrixC6_4));
processing_element pe6_5(.reset(effective_rst), .clk(clk),  .in_a(a6_4to6_5), .in_b(b5_5to6_5),  .out_a(a6_5to6_6), .out_b(b6_5to7_5), .out_c(matrixC6_5));
processing_element pe6_6(.reset(effective_rst), .clk(clk),  .in_a(a6_5to6_6), .in_b(b5_6to6_6),  .out_a(a6_6to6_7), .out_b(b6_6to7_6), .out_c(matrixC6_6));
processing_element pe6_7(.reset(effective_rst), .clk(clk),  .in_a(a6_6to6_7), .in_b(b5_7to6_7),  .out_a(a6_7to6_8), .out_b(b6_7to7_7), .out_c(matrixC6_7));
processing_element pe7_1(.reset(effective_rst), .clk(clk),  .in_a(a7_0to7_1), .in_b(b6_1to7_1),  .out_a(a7_1to7_2), .out_b(b7_1to8_1), .out_c(matrixC7_1));
processing_element pe7_2(.reset(effective_rst), .clk(clk),  .in_a(a7_1to7_2), .in_b(b6_2to7_2),  .out_a(a7_2to7_3), .out_b(b7_2to8_2), .out_c(matrixC7_2));
processing_element pe7_3(.reset(effective_rst), .clk(clk),  .in_a(a7_2to7_3), .in_b(b6_3to7_3),  .out_a(a7_3to7_4), .out_b(b7_3to8_3), .out_c(matrixC7_3));
processing_element pe7_4(.reset(effective_rst), .clk(clk),  .in_a(a7_3to7_4), .in_b(b6_4to7_4),  .out_a(a7_4to7_5), .out_b(b7_4to8_4), .out_c(matrixC7_4));
processing_element pe7_5(.reset(effective_rst), .clk(clk),  .in_a(a7_4to7_5), .in_b(b6_5to7_5),  .out_a(a7_5to7_6), .out_b(b7_5to8_5), .out_c(matrixC7_5));
processing_element pe7_6(.reset(effective_rst), .clk(clk),  .in_a(a7_5to7_6), .in_b(b6_6to7_6),  .out_a(a7_6to7_7), .out_b(b7_6to8_6), .out_c(matrixC7_6));
processing_element pe7_7(.reset(effective_rst), .clk(clk),  .in_a(a7_6to7_7), .in_b(b6_7to7_7),  .out_a(a7_7to7_8), .out_b(b7_7to8_7), .out_c(matrixC7_7));
assign a_data_out = {a7_7to7_8,a6_7to6_8,a5_7to5_8,a4_7to4_8,a3_7to3_8,a2_7to2_8,a1_7to1_8,a0_7to0_8};
assign b_data_out = {b7_7to8_7,b7_6to8_6,b7_5to8_5,b7_4to8_4,b7_3to8_3,b7_2to8_2,b7_1to8_1,b7_0to8_0};

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
//    output reg [15:0] cur_c,
//    output reg [3:0]  cur_r,
//    output reg [3:0]  cur_s,
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
    validity_mask_a_rows <= {`MASK_WIDTH{1'b1}};
    validity_mask_a_cols_b_rows <= {`MASK_WIDTH{1'b1}};
    validity_mask_b_cols <= {`MASK_WIDTH{1'b1}};
    save_output_to_accum <= 0;
    add_accum_to_output <= 0;
    address_stride_a <= `MAT_MUL_SIZE;
    address_stride_b <= `MAT_MUL_SIZE;
    address_stride_c <= `MAT_MUL_SIZE;
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
    //cur_c <= 0;
    //cur_r <= 0;
    //cur_s <= 0;
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
                                enable_conv_mode  <= PWDATA[31];
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
          `REG_VALID_MASK_ADDR: begin
                                validity_mask_a_rows <= PWDATA[`MASK_WIDTH-1:0];
                                validity_mask_a_cols_b_rows <= PWDATA[2*`MASK_WIDTH-1:`MASK_WIDTH];
                                validity_mask_b_cols <= PWDATA[3*`MASK_WIDTH-1:2*`MASK_WIDTH];
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
          //`REG_CUR_CRS_ADDR         : begin
          //                            cur_c <= PWDATA[15:0];
          //                            cur_r <= PWDATA[19:16];
          //                            cur_s <= PWDATA[23:20];
          //                            end
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
          `REG_VALID_MASK_ADDR: PRDATA <= {validity_mask_b_cols, validity_mask_a_cols_b_rows, validity_mask_a_rows};
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
          //`REG_CUR_CRS_ADDR         : PRDATA <= {8'b0, cur_s, cur_r, cur_c};
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
	input [`MAX_BITS_POOL-1:0] pool_window_size,
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

		case (pool_window_size)
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

reg  done_activation_internal;
reg  out_data_available_internal;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] out_data_internal;
reg [`MAT_MUL_SIZE*`DWIDTH-1:0] slope_applied_data_internal;
reg [`MAT_MUL_SIZE*`DWIDTH-1:0] intercept_applied_data_internal;
reg [`MAT_MUL_SIZE*`DWIDTH-1:0] relu_applied_data_internal;
integer i;
integer cycle_count;
reg activation_in_progress;

reg [(`MAT_MUL_SIZE*4)-1:0] address;
reg [(`MAT_MUL_SIZE*8)-1:0] data_slope;
reg [(`MAT_MUL_SIZE*8)-1:0] data_intercept;
reg [(`MAT_MUL_SIZE*8)-1:0] data_intercept_delayed;

// If the activation block is not enabled, just forward the input data
assign out_data             = enable_activation ? out_data_internal : inp_data;
assign done_activation      = enable_activation ? done_activation_internal : 1'b1;
assign out_data_available   = enable_activation ? out_data_available_internal : in_data_available;

always @(posedge clk) begin
   if (reset || ~enable_activation) begin
      slope_applied_data_internal     <= 0;
      intercept_applied_data_internal <= 0; 
      relu_applied_data_internal      <= 0; 
      data_intercept_delayed      <= 0;
      done_activation_internal    <= 0;
      out_data_available_internal <= 0;
      cycle_count                 <= 0;
      activation_in_progress      <= 0;
   end else if(in_data_available || activation_in_progress) begin
      cycle_count = cycle_count + 1;

      for (i = 0; i < `MAT_MUL_SIZE; i=i+1) begin
         if(activation_type==1'b1) begin // tanH
            slope_applied_data_internal[i*`DWIDTH +:`DWIDTH] <= data_slope[i*8 +: 8] * inp_data[i*`DWIDTH +:`DWIDTH];
            data_intercept_delayed[i*8 +: 8] <= data_intercept[i*8 +: 8];
            intercept_applied_data_internal[i*`DWIDTH +:`DWIDTH] <= slope_applied_data_internal[i*`DWIDTH +:`DWIDTH] + data_intercept_delayed[i*8 +: 8];
         end else begin // ReLU
            relu_applied_data_internal[i*`DWIDTH +:`DWIDTH] <= inp_data[i*`DWIDTH] ? {`DWIDTH{1'b0}} : inp_data[i*`DWIDTH +:`DWIDTH];
         end
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
        if(cycle_count==(`MAT_MUL_SIZE+1)) begin
           done_activation_internal <= 1'b1;
           activation_in_progress <= 0;
        end
        else begin
           activation_in_progress <= 1;
        end
      end else begin
        if(cycle_count==(`MAT_MUL_SIZE)) begin
           done_activation_internal <= 1'b1;
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
      done_activation_internal    <= 0;
      out_data_available_internal <= 0;
      cycle_count                 <= 0;
      activation_in_progress      <= 0;
   end
end

assign out_data_internal = (activation_type) ? intercept_applied_data_internal : relu_applied_data_internal;

//Our equation of tanh is Y=AX+B
//A is the slope and B is the intercept.
//We store A in one LUT and B in another.
//LUT for the slope
always @(address) begin
    for (i = 0; i < `MAT_MUL_SIZE; i=i+1) begin
    case (address[i*4+:4])
      4'b0000: data_slope[i*8+:8] = 8'd0;
      4'b0001: data_slope[i*8+:8] = 8'd0;
      4'b0010: data_slope[i*8+:8] = 8'd2;
      4'b0011: data_slope[i*8+:8] = 8'd3;
      4'b0100: data_slope[i*8+:8] = 8'd4;
      4'b0101: data_slope[i*8+:8] = 8'd0;
      4'b0110: data_slope[i*8+:8] = 8'd4;
      4'b0111: data_slope[i*8+:8] = 8'd3;
      4'b1000: data_slope[i*8+:8] = 8'd2;
      4'b1001: data_slope[i*8+:8] = 8'd0;
      4'b1010: data_slope[i*8+:8] = 8'd0;
      default: data_slope[i*8+:8] = 8'd0;
    endcase  
    end
end

//LUT for the intercept
always @(address) begin
    for (i = 0; i < `MAT_MUL_SIZE; i=i+1) begin
    case (address[i*4+:4])
      4'b0000: data_intercept[i*8+:8] = 8'd127;
      4'b0001: data_intercept[i*8+:8] = 8'd99;
      4'b0010: data_intercept[i*8+:8] = 8'd46;
      4'b0011: data_intercept[i*8+:8] = 8'd18;
      4'b0100: data_intercept[i*8+:8] = 8'd0;
      4'b0101: data_intercept[i*8+:8] = 8'd0;
      4'b0110: data_intercept[i*8+:8] = 8'd0;
      4'b0111: data_intercept[i*8+:8] = -8'd18;
      4'b1000: data_intercept[i*8+:8] = -8'd46;
      4'b1001: data_intercept[i*8+:8] = -8'd99;
      4'b1010: data_intercept[i*8+:8] = -8'd127;
      default: data_intercept[i*8+:8] = 8'd0;
    endcase  
    end
end

//Logic to find address
always @(inp_data) begin
    for (i = 0; i < `MAT_MUL_SIZE; i=i+1) begin
        if((inp_data[i*`DWIDTH +:`DWIDTH])>=90) begin
           address[i*4+:4] = 4'b0000;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])>=39 && (inp_data[i*`DWIDTH +:`DWIDTH])<90) begin
           address[i*4+:4] = 4'b0001;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])>=28 && (inp_data[i*`DWIDTH +:`DWIDTH])<39) begin
           address[i*4+:4] = 4'b0010;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])>=16 && (inp_data[i*`DWIDTH +:`DWIDTH])<28) begin
           address[i*4+:4] = 4'b0011;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])>=1 && (inp_data[i*`DWIDTH +:`DWIDTH])<16) begin
           address[i*4+:4] = 4'b0100;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])==0) begin
           address[i*4+:4] = 4'b0101;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])>-16 && (inp_data[i*`DWIDTH +:`DWIDTH])<=-1) begin
           address[i*4+:4] = 4'b0110;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])>-28 && (inp_data[i*`DWIDTH +:`DWIDTH])<=-16) begin
           address[i*4+:4] = 4'b0111;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])>-39 && (inp_data[i*`DWIDTH +:`DWIDTH])<=-28) begin
           address[i*4+:4] = 4'b1000;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])>-90 && (inp_data[i*`DWIDTH +:`DWIDTH])<=-39) begin
           address[i*4+:4] = 4'b1001;
        end
        else if ((inp_data[i*`DWIDTH +:`DWIDTH])<=-90) begin
           address[i*4+:4] = 4'b1010;
        end
        else begin
           address[i*4+:4] = 4'b0101;
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
//wire [15:0] cur_c;
//wire [3:0]  cur_r;
//wire [3:0]  cur_s;

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
  .enable_conv_mode(enable_conv_mode),
  .mean(mean),
  .inv_var(inv_var),
  .pool_window_size(pool_window_size),
	.address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
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
//  .cur_c(cur_c),
//  .cur_r(cur_r),
//  .cur_s(cur_s),
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
  .enable_conv_mode(enable_conv_mode),
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
  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
//  .cur_c(cur_c),
//  .cur_r(cur_r),
//  .cur_s(cur_s),
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
  .validity_mask(validity_mask_a_rows),
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
  .pool_window_size(pool_window_size),
	.inp_data(norm_data_out),
  .out_data(pool_data_out),
  .out_data_available(pool_out_data_available),
  .validity_mask(validity_mask_a_rows),
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
  .validity_mask(validity_mask_a_rows),
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
    if (enable_conv_mode) begin
      bram_wdata_a <= 0;
      bram_addr_a_for_writing <= address_mat_c - (out_img_height*out_img_width);
      bram_a_wdata_available <= 0;
    end
    else begin
      bram_wdata_a <= 0;
      bram_addr_a_for_writing <= address_mat_c-address_stride_c;
      bram_a_wdata_available <= 0;
    end
  end
  else if (activation_out_data_available) begin
    if (enable_conv_mode) begin
      bram_wdata_a <= activation_data_out;
      bram_addr_a_for_writing <= bram_addr_a_for_writing + (out_img_height*out_img_width);
      bram_a_wdata_available <= activation_out_data_available;
    end
    else begin
      bram_wdata_a <= activation_data_out;
      bram_addr_a_for_writing <= bram_addr_a_for_writing + address_stride_c;
      bram_a_wdata_available <= activation_out_data_available;
    end
  end
  else begin
    if (enable_conv_mode) begin
      bram_wdata_a <= 0;
      bram_addr_a_for_writing <= address_mat_c - (out_img_height*out_img_width);
      bram_a_wdata_available <= 0;
    end
    else begin
      bram_wdata_a <= 0;
      bram_addr_a_for_writing <= address_mat_c-address_stride_c;
      bram_a_wdata_available <= 0;
    end
  end
end  

endmodule


