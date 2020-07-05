`define MATMUL_SIZE_16


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

//16x16_gen.v 

//////////////////////////


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020-07-05 13:58:28.365208
// Design Name: 
// Module Name: matmul_16x16
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
        (validity_mask_a_cols_b_rows[7]==1'b0 && a_mem_access_counter==7) ||
        (validity_mask_a_cols_b_rows[8]==1'b0 && a_mem_access_counter==8) ||
        (validity_mask_a_cols_b_rows[9]==1'b0 && a_mem_access_counter==9) ||
        (validity_mask_a_cols_b_rows[10]==1'b0 && a_mem_access_counter==10) ||
        (validity_mask_a_cols_b_rows[11]==1'b0 && a_mem_access_counter==11) ||
        (validity_mask_a_cols_b_rows[12]==1'b0 && a_mem_access_counter==12) ||
        (validity_mask_a_cols_b_rows[13]==1'b0 && a_mem_access_counter==13) ||
        (validity_mask_a_cols_b_rows[14]==1'b0 && a_mem_access_counter==14) ||
        (validity_mask_a_cols_b_rows[15]==1'b0 && a_mem_access_counter==15)) begin
    
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
wire [`DWIDTH-1:0] a8_data;
wire [`DWIDTH-1:0] a9_data;
wire [`DWIDTH-1:0] a10_data;
wire [`DWIDTH-1:0] a11_data;
wire [`DWIDTH-1:0] a12_data;
wire [`DWIDTH-1:0] a13_data;
wire [`DWIDTH-1:0] a14_data;
wire [`DWIDTH-1:0] a15_data;

assign a0_data = a_data[1*`DWIDTH-1:0*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[0]}};
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

assign a0_data_in = a_data_in[1*`DWIDTH-1:0*`DWIDTH];
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
	a3_data_delayed_1 <= a3_data;
	a4_data_delayed_1 <= a4_data;
	a5_data_delayed_1 <= a5_data;
	a6_data_delayed_1 <= a6_data;
	a7_data_delayed_1 <= a7_data;
	a8_data_delayed_1 <= a8_data;
	a9_data_delayed_1 <= a9_data;
	a10_data_delayed_1 <= a10_data;
	a11_data_delayed_1 <= a11_data;
	a12_data_delayed_1 <= a12_data;
	a13_data_delayed_1 <= a13_data;
	a14_data_delayed_1 <= a14_data;
	a15_data_delayed_1 <= a15_data;
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
	a8_data_delayed_2 <= a8_data_delayed_1;
	a8_data_delayed_3 <= a8_data_delayed_2;
	a8_data_delayed_4 <= a8_data_delayed_3;
	a8_data_delayed_5 <= a8_data_delayed_4;
	a8_data_delayed_6 <= a8_data_delayed_5;
	a8_data_delayed_7 <= a8_data_delayed_6;
	a8_data_delayed_8 <= a8_data_delayed_7;
	a9_data_delayed_2 <= a9_data_delayed_1;
	a9_data_delayed_3 <= a9_data_delayed_2;
	a9_data_delayed_4 <= a9_data_delayed_3;
	a9_data_delayed_5 <= a9_data_delayed_4;
	a9_data_delayed_6 <= a9_data_delayed_5;
	a9_data_delayed_7 <= a9_data_delayed_6;
	a9_data_delayed_8 <= a9_data_delayed_7;
	a9_data_delayed_9 <= a9_data_delayed_8;
	a10_data_delayed_2 <= a10_data_delayed_1;
	a10_data_delayed_3 <= a10_data_delayed_2;
	a10_data_delayed_4 <= a10_data_delayed_3;
	a10_data_delayed_5 <= a10_data_delayed_4;
	a10_data_delayed_6 <= a10_data_delayed_5;
	a10_data_delayed_7 <= a10_data_delayed_6;
	a10_data_delayed_8 <= a10_data_delayed_7;
	a10_data_delayed_9 <= a10_data_delayed_8;
	a10_data_delayed_10 <= a10_data_delayed_9;
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
        (validity_mask_a_cols_b_rows[7]==1'b0 && b_mem_access_counter==7) ||
        (validity_mask_a_cols_b_rows[8]==1'b0 && b_mem_access_counter==8) ||
        (validity_mask_a_cols_b_rows[9]==1'b0 && b_mem_access_counter==9) ||
        (validity_mask_a_cols_b_rows[10]==1'b0 && b_mem_access_counter==10) ||
        (validity_mask_a_cols_b_rows[11]==1'b0 && b_mem_access_counter==11) ||
        (validity_mask_a_cols_b_rows[12]==1'b0 && b_mem_access_counter==12) ||
        (validity_mask_a_cols_b_rows[13]==1'b0 && b_mem_access_counter==13) ||
        (validity_mask_a_cols_b_rows[14]==1'b0 && b_mem_access_counter==14) ||
        (validity_mask_a_cols_b_rows[15]==1'b0 && b_mem_access_counter==15)) begin
    
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
wire [`DWIDTH-1:0] b8_data;
wire [`DWIDTH-1:0] b9_data;
wire [`DWIDTH-1:0] b10_data;
wire [`DWIDTH-1:0] b11_data;
wire [`DWIDTH-1:0] b12_data;
wire [`DWIDTH-1:0] b13_data;
wire [`DWIDTH-1:0] b14_data;
wire [`DWIDTH-1:0] b15_data;

assign b0_data = b_data[1*`DWIDTH-1:0*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[0]}};
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

assign b0_data_in = b_data_in[1*`DWIDTH-1:0*`DWIDTH];
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
	b3_data_delayed_1 <= b3_data;
	b4_data_delayed_1 <= b4_data;
	b5_data_delayed_1 <= b5_data;
	b6_data_delayed_1 <= b6_data;
	b7_data_delayed_1 <= b7_data;
	b8_data_delayed_1 <= b8_data;
	b9_data_delayed_1 <= b9_data;
	b10_data_delayed_1 <= b10_data;
	b11_data_delayed_1 <= b11_data;
	b12_data_delayed_1 <= b12_data;
	b13_data_delayed_1 <= b13_data;
	b14_data_delayed_1 <= b14_data;
	b15_data_delayed_1 <= b15_data;
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
	b8_data_delayed_2 <= b8_data_delayed_1;
	b8_data_delayed_3 <= b8_data_delayed_2;
	b8_data_delayed_4 <= b8_data_delayed_3;
	b8_data_delayed_5 <= b8_data_delayed_4;
	b8_data_delayed_6 <= b8_data_delayed_5;
	b8_data_delayed_7 <= b8_data_delayed_6;
	b8_data_delayed_8 <= b8_data_delayed_7;
	b9_data_delayed_2 <= b9_data_delayed_1;
	b9_data_delayed_3 <= b9_data_delayed_2;
	b9_data_delayed_4 <= b9_data_delayed_3;
	b9_data_delayed_5 <= b9_data_delayed_4;
	b9_data_delayed_6 <= b9_data_delayed_5;
	b9_data_delayed_7 <= b9_data_delayed_6;
	b9_data_delayed_8 <= b9_data_delayed_7;
	b9_data_delayed_9 <= b9_data_delayed_8;
	b10_data_delayed_2 <= b10_data_delayed_1;
	b10_data_delayed_3 <= b10_data_delayed_2;
	b10_data_delayed_4 <= b10_data_delayed_3;
	b10_data_delayed_5 <= b10_data_delayed_4;
	b10_data_delayed_6 <= b10_data_delayed_5;
	b10_data_delayed_7 <= b10_data_delayed_6;
	b10_data_delayed_8 <= b10_data_delayed_7;
	b10_data_delayed_9 <= b10_data_delayed_8;
	b10_data_delayed_10 <= b10_data_delayed_9;
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



//////////////////////////////////////////////////////////////////////////
// Logic to handle accumulation of partial sums (accumulators)
//////////////////////////////////////////////////////////////////////////

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
wire [`DWIDTH-1:0] cin_row0;
wire [`DWIDTH-1:0] cin_row1;
wire [`DWIDTH-1:0] cin_row2;
wire [`DWIDTH-1:0] cin_row3;
wire [`DWIDTH-1:0] cin_row4;
wire [`DWIDTH-1:0] cin_row5;
wire [`DWIDTH-1:0] cin_row6;
wire [`DWIDTH-1:0] cin_row7;
wire [`DWIDTH-1:0] cin_row8;
wire [`DWIDTH-1:0] cin_row9;
wire [`DWIDTH-1:0] cin_row10;
wire [`DWIDTH-1:0] cin_row11;
wire [`DWIDTH-1:0] cin_row12;
wire [`DWIDTH-1:0] cin_row13;
wire [`DWIDTH-1:0] cin_row14;
wire [`DWIDTH-1:0] cin_row15;
wire row_latch_en;

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
assign cin_row0 = c_data_in[1*`DWIDTH-1:0*`DWIDTH];
assign cin_row1 = c_data_in[2*`DWIDTH-1:1*`DWIDTH];
assign cin_row2 = c_data_in[3*`DWIDTH-1:2*`DWIDTH];
assign cin_row3 = c_data_in[4*`DWIDTH-1:3*`DWIDTH];
assign cin_row4 = c_data_in[5*`DWIDTH-1:4*`DWIDTH];
assign cin_row5 = c_data_in[6*`DWIDTH-1:5*`DWIDTH];
assign cin_row6 = c_data_in[7*`DWIDTH-1:6*`DWIDTH];
assign cin_row7 = c_data_in[8*`DWIDTH-1:7*`DWIDTH];
assign cin_row8 = c_data_in[9*`DWIDTH-1:8*`DWIDTH];
assign cin_row9 = c_data_in[10*`DWIDTH-1:9*`DWIDTH];
assign cin_row10 = c_data_in[11*`DWIDTH-1:10*`DWIDTH];
assign cin_row11 = c_data_in[12*`DWIDTH-1:11*`DWIDTH];
assign cin_row12 = c_data_in[13*`DWIDTH-1:12*`DWIDTH];
assign cin_row13 = c_data_in[14*`DWIDTH-1:13*`DWIDTH];
assign cin_row14 = c_data_in[15*`DWIDTH-1:14*`DWIDTH];
assign cin_row15 = c_data_in[16*`DWIDTH-1:15*`DWIDTH];
wire [`DWIDTH-1:0] matrixC00_added;
wire [`DWIDTH-1:0] matrixC01_added;
wire [`DWIDTH-1:0] matrixC02_added;
wire [`DWIDTH-1:0] matrixC03_added;
wire [`DWIDTH-1:0] matrixC04_added;
wire [`DWIDTH-1:0] matrixC05_added;
wire [`DWIDTH-1:0] matrixC06_added;
wire [`DWIDTH-1:0] matrixC07_added;
wire [`DWIDTH-1:0] matrixC08_added;
wire [`DWIDTH-1:0] matrixC09_added;
wire [`DWIDTH-1:0] matrixC010_added;
wire [`DWIDTH-1:0] matrixC011_added;
wire [`DWIDTH-1:0] matrixC012_added;
wire [`DWIDTH-1:0] matrixC013_added;
wire [`DWIDTH-1:0] matrixC014_added;
wire [`DWIDTH-1:0] matrixC015_added;
wire [`DWIDTH-1:0] matrixC10_added;
wire [`DWIDTH-1:0] matrixC11_added;
wire [`DWIDTH-1:0] matrixC12_added;
wire [`DWIDTH-1:0] matrixC13_added;
wire [`DWIDTH-1:0] matrixC14_added;
wire [`DWIDTH-1:0] matrixC15_added;
wire [`DWIDTH-1:0] matrixC16_added;
wire [`DWIDTH-1:0] matrixC17_added;
wire [`DWIDTH-1:0] matrixC18_added;
wire [`DWIDTH-1:0] matrixC19_added;
wire [`DWIDTH-1:0] matrixC110_added;
wire [`DWIDTH-1:0] matrixC111_added;
wire [`DWIDTH-1:0] matrixC112_added;
wire [`DWIDTH-1:0] matrixC113_added;
wire [`DWIDTH-1:0] matrixC114_added;
wire [`DWIDTH-1:0] matrixC115_added;
wire [`DWIDTH-1:0] matrixC20_added;
wire [`DWIDTH-1:0] matrixC21_added;
wire [`DWIDTH-1:0] matrixC22_added;
wire [`DWIDTH-1:0] matrixC23_added;
wire [`DWIDTH-1:0] matrixC24_added;
wire [`DWIDTH-1:0] matrixC25_added;
wire [`DWIDTH-1:0] matrixC26_added;
wire [`DWIDTH-1:0] matrixC27_added;
wire [`DWIDTH-1:0] matrixC28_added;
wire [`DWIDTH-1:0] matrixC29_added;
wire [`DWIDTH-1:0] matrixC210_added;
wire [`DWIDTH-1:0] matrixC211_added;
wire [`DWIDTH-1:0] matrixC212_added;
wire [`DWIDTH-1:0] matrixC213_added;
wire [`DWIDTH-1:0] matrixC214_added;
wire [`DWIDTH-1:0] matrixC215_added;
wire [`DWIDTH-1:0] matrixC30_added;
wire [`DWIDTH-1:0] matrixC31_added;
wire [`DWIDTH-1:0] matrixC32_added;
wire [`DWIDTH-1:0] matrixC33_added;
wire [`DWIDTH-1:0] matrixC34_added;
wire [`DWIDTH-1:0] matrixC35_added;
wire [`DWIDTH-1:0] matrixC36_added;
wire [`DWIDTH-1:0] matrixC37_added;
wire [`DWIDTH-1:0] matrixC38_added;
wire [`DWIDTH-1:0] matrixC39_added;
wire [`DWIDTH-1:0] matrixC310_added;
wire [`DWIDTH-1:0] matrixC311_added;
wire [`DWIDTH-1:0] matrixC312_added;
wire [`DWIDTH-1:0] matrixC313_added;
wire [`DWIDTH-1:0] matrixC314_added;
wire [`DWIDTH-1:0] matrixC315_added;
wire [`DWIDTH-1:0] matrixC40_added;
wire [`DWIDTH-1:0] matrixC41_added;
wire [`DWIDTH-1:0] matrixC42_added;
wire [`DWIDTH-1:0] matrixC43_added;
wire [`DWIDTH-1:0] matrixC44_added;
wire [`DWIDTH-1:0] matrixC45_added;
wire [`DWIDTH-1:0] matrixC46_added;
wire [`DWIDTH-1:0] matrixC47_added;
wire [`DWIDTH-1:0] matrixC48_added;
wire [`DWIDTH-1:0] matrixC49_added;
wire [`DWIDTH-1:0] matrixC410_added;
wire [`DWIDTH-1:0] matrixC411_added;
wire [`DWIDTH-1:0] matrixC412_added;
wire [`DWIDTH-1:0] matrixC413_added;
wire [`DWIDTH-1:0] matrixC414_added;
wire [`DWIDTH-1:0] matrixC415_added;
wire [`DWIDTH-1:0] matrixC50_added;
wire [`DWIDTH-1:0] matrixC51_added;
wire [`DWIDTH-1:0] matrixC52_added;
wire [`DWIDTH-1:0] matrixC53_added;
wire [`DWIDTH-1:0] matrixC54_added;
wire [`DWIDTH-1:0] matrixC55_added;
wire [`DWIDTH-1:0] matrixC56_added;
wire [`DWIDTH-1:0] matrixC57_added;
wire [`DWIDTH-1:0] matrixC58_added;
wire [`DWIDTH-1:0] matrixC59_added;
wire [`DWIDTH-1:0] matrixC510_added;
wire [`DWIDTH-1:0] matrixC511_added;
wire [`DWIDTH-1:0] matrixC512_added;
wire [`DWIDTH-1:0] matrixC513_added;
wire [`DWIDTH-1:0] matrixC514_added;
wire [`DWIDTH-1:0] matrixC515_added;
wire [`DWIDTH-1:0] matrixC60_added;
wire [`DWIDTH-1:0] matrixC61_added;
wire [`DWIDTH-1:0] matrixC62_added;
wire [`DWIDTH-1:0] matrixC63_added;
wire [`DWIDTH-1:0] matrixC64_added;
wire [`DWIDTH-1:0] matrixC65_added;
wire [`DWIDTH-1:0] matrixC66_added;
wire [`DWIDTH-1:0] matrixC67_added;
wire [`DWIDTH-1:0] matrixC68_added;
wire [`DWIDTH-1:0] matrixC69_added;
wire [`DWIDTH-1:0] matrixC610_added;
wire [`DWIDTH-1:0] matrixC611_added;
wire [`DWIDTH-1:0] matrixC612_added;
wire [`DWIDTH-1:0] matrixC613_added;
wire [`DWIDTH-1:0] matrixC614_added;
wire [`DWIDTH-1:0] matrixC615_added;
wire [`DWIDTH-1:0] matrixC70_added;
wire [`DWIDTH-1:0] matrixC71_added;
wire [`DWIDTH-1:0] matrixC72_added;
wire [`DWIDTH-1:0] matrixC73_added;
wire [`DWIDTH-1:0] matrixC74_added;
wire [`DWIDTH-1:0] matrixC75_added;
wire [`DWIDTH-1:0] matrixC76_added;
wire [`DWIDTH-1:0] matrixC77_added;
wire [`DWIDTH-1:0] matrixC78_added;
wire [`DWIDTH-1:0] matrixC79_added;
wire [`DWIDTH-1:0] matrixC710_added;
wire [`DWIDTH-1:0] matrixC711_added;
wire [`DWIDTH-1:0] matrixC712_added;
wire [`DWIDTH-1:0] matrixC713_added;
wire [`DWIDTH-1:0] matrixC714_added;
wire [`DWIDTH-1:0] matrixC715_added;
wire [`DWIDTH-1:0] matrixC80_added;
wire [`DWIDTH-1:0] matrixC81_added;
wire [`DWIDTH-1:0] matrixC82_added;
wire [`DWIDTH-1:0] matrixC83_added;
wire [`DWIDTH-1:0] matrixC84_added;
wire [`DWIDTH-1:0] matrixC85_added;
wire [`DWIDTH-1:0] matrixC86_added;
wire [`DWIDTH-1:0] matrixC87_added;
wire [`DWIDTH-1:0] matrixC88_added;
wire [`DWIDTH-1:0] matrixC89_added;
wire [`DWIDTH-1:0] matrixC810_added;
wire [`DWIDTH-1:0] matrixC811_added;
wire [`DWIDTH-1:0] matrixC812_added;
wire [`DWIDTH-1:0] matrixC813_added;
wire [`DWIDTH-1:0] matrixC814_added;
wire [`DWIDTH-1:0] matrixC815_added;
wire [`DWIDTH-1:0] matrixC90_added;
wire [`DWIDTH-1:0] matrixC91_added;
wire [`DWIDTH-1:0] matrixC92_added;
wire [`DWIDTH-1:0] matrixC93_added;
wire [`DWIDTH-1:0] matrixC94_added;
wire [`DWIDTH-1:0] matrixC95_added;
wire [`DWIDTH-1:0] matrixC96_added;
wire [`DWIDTH-1:0] matrixC97_added;
wire [`DWIDTH-1:0] matrixC98_added;
wire [`DWIDTH-1:0] matrixC99_added;
wire [`DWIDTH-1:0] matrixC910_added;
wire [`DWIDTH-1:0] matrixC911_added;
wire [`DWIDTH-1:0] matrixC912_added;
wire [`DWIDTH-1:0] matrixC913_added;
wire [`DWIDTH-1:0] matrixC914_added;
wire [`DWIDTH-1:0] matrixC915_added;
wire [`DWIDTH-1:0] matrixC100_added;
wire [`DWIDTH-1:0] matrixC101_added;
wire [`DWIDTH-1:0] matrixC102_added;
wire [`DWIDTH-1:0] matrixC103_added;
wire [`DWIDTH-1:0] matrixC104_added;
wire [`DWIDTH-1:0] matrixC105_added;
wire [`DWIDTH-1:0] matrixC106_added;
wire [`DWIDTH-1:0] matrixC107_added;
wire [`DWIDTH-1:0] matrixC108_added;
wire [`DWIDTH-1:0] matrixC109_added;
wire [`DWIDTH-1:0] matrixC1010_added;
wire [`DWIDTH-1:0] matrixC1011_added;
wire [`DWIDTH-1:0] matrixC1012_added;
wire [`DWIDTH-1:0] matrixC1013_added;
wire [`DWIDTH-1:0] matrixC1014_added;
wire [`DWIDTH-1:0] matrixC1015_added;
wire [`DWIDTH-1:0] matrixC110_added;
wire [`DWIDTH-1:0] matrixC111_added;
wire [`DWIDTH-1:0] matrixC112_added;
wire [`DWIDTH-1:0] matrixC113_added;
wire [`DWIDTH-1:0] matrixC114_added;
wire [`DWIDTH-1:0] matrixC115_added;
wire [`DWIDTH-1:0] matrixC116_added;
wire [`DWIDTH-1:0] matrixC117_added;
wire [`DWIDTH-1:0] matrixC118_added;
wire [`DWIDTH-1:0] matrixC119_added;
wire [`DWIDTH-1:0] matrixC1110_added;
wire [`DWIDTH-1:0] matrixC1111_added;
wire [`DWIDTH-1:0] matrixC1112_added;
wire [`DWIDTH-1:0] matrixC1113_added;
wire [`DWIDTH-1:0] matrixC1114_added;
wire [`DWIDTH-1:0] matrixC1115_added;
wire [`DWIDTH-1:0] matrixC120_added;
wire [`DWIDTH-1:0] matrixC121_added;
wire [`DWIDTH-1:0] matrixC122_added;
wire [`DWIDTH-1:0] matrixC123_added;
wire [`DWIDTH-1:0] matrixC124_added;
wire [`DWIDTH-1:0] matrixC125_added;
wire [`DWIDTH-1:0] matrixC126_added;
wire [`DWIDTH-1:0] matrixC127_added;
wire [`DWIDTH-1:0] matrixC128_added;
wire [`DWIDTH-1:0] matrixC129_added;
wire [`DWIDTH-1:0] matrixC1210_added;
wire [`DWIDTH-1:0] matrixC1211_added;
wire [`DWIDTH-1:0] matrixC1212_added;
wire [`DWIDTH-1:0] matrixC1213_added;
wire [`DWIDTH-1:0] matrixC1214_added;
wire [`DWIDTH-1:0] matrixC1215_added;
wire [`DWIDTH-1:0] matrixC130_added;
wire [`DWIDTH-1:0] matrixC131_added;
wire [`DWIDTH-1:0] matrixC132_added;
wire [`DWIDTH-1:0] matrixC133_added;
wire [`DWIDTH-1:0] matrixC134_added;
wire [`DWIDTH-1:0] matrixC135_added;
wire [`DWIDTH-1:0] matrixC136_added;
wire [`DWIDTH-1:0] matrixC137_added;
wire [`DWIDTH-1:0] matrixC138_added;
wire [`DWIDTH-1:0] matrixC139_added;
wire [`DWIDTH-1:0] matrixC1310_added;
wire [`DWIDTH-1:0] matrixC1311_added;
wire [`DWIDTH-1:0] matrixC1312_added;
wire [`DWIDTH-1:0] matrixC1313_added;
wire [`DWIDTH-1:0] matrixC1314_added;
wire [`DWIDTH-1:0] matrixC1315_added;
wire [`DWIDTH-1:0] matrixC140_added;
wire [`DWIDTH-1:0] matrixC141_added;
wire [`DWIDTH-1:0] matrixC142_added;
wire [`DWIDTH-1:0] matrixC143_added;
wire [`DWIDTH-1:0] matrixC144_added;
wire [`DWIDTH-1:0] matrixC145_added;
wire [`DWIDTH-1:0] matrixC146_added;
wire [`DWIDTH-1:0] matrixC147_added;
wire [`DWIDTH-1:0] matrixC148_added;
wire [`DWIDTH-1:0] matrixC149_added;
wire [`DWIDTH-1:0] matrixC1410_added;
wire [`DWIDTH-1:0] matrixC1411_added;
wire [`DWIDTH-1:0] matrixC1412_added;
wire [`DWIDTH-1:0] matrixC1413_added;
wire [`DWIDTH-1:0] matrixC1414_added;
wire [`DWIDTH-1:0] matrixC1415_added;
wire [`DWIDTH-1:0] matrixC150_added;
wire [`DWIDTH-1:0] matrixC151_added;
wire [`DWIDTH-1:0] matrixC152_added;
wire [`DWIDTH-1:0] matrixC153_added;
wire [`DWIDTH-1:0] matrixC154_added;
wire [`DWIDTH-1:0] matrixC155_added;
wire [`DWIDTH-1:0] matrixC156_added;
wire [`DWIDTH-1:0] matrixC157_added;
wire [`DWIDTH-1:0] matrixC158_added;
wire [`DWIDTH-1:0] matrixC159_added;
wire [`DWIDTH-1:0] matrixC1510_added;
wire [`DWIDTH-1:0] matrixC1511_added;
wire [`DWIDTH-1:0] matrixC1512_added;
wire [`DWIDTH-1:0] matrixC1513_added;
wire [`DWIDTH-1:0] matrixC1514_added;
wire [`DWIDTH-1:0] matrixC1515_added;


reg [`DWIDTH-1:0] matrixC00_accum;
reg [`DWIDTH-1:0] matrixC01_accum;
reg [`DWIDTH-1:0] matrixC02_accum;
reg [`DWIDTH-1:0] matrixC03_accum;
reg [`DWIDTH-1:0] matrixC04_accum;
reg [`DWIDTH-1:0] matrixC05_accum;
reg [`DWIDTH-1:0] matrixC06_accum;
reg [`DWIDTH-1:0] matrixC07_accum;
reg [`DWIDTH-1:0] matrixC08_accum;
reg [`DWIDTH-1:0] matrixC09_accum;
reg [`DWIDTH-1:0] matrixC010_accum;
reg [`DWIDTH-1:0] matrixC011_accum;
reg [`DWIDTH-1:0] matrixC012_accum;
reg [`DWIDTH-1:0] matrixC013_accum;
reg [`DWIDTH-1:0] matrixC014_accum;
reg [`DWIDTH-1:0] matrixC015_accum;
reg [`DWIDTH-1:0] matrixC10_accum;
reg [`DWIDTH-1:0] matrixC11_accum;
reg [`DWIDTH-1:0] matrixC12_accum;
reg [`DWIDTH-1:0] matrixC13_accum;
reg [`DWIDTH-1:0] matrixC14_accum;
reg [`DWIDTH-1:0] matrixC15_accum;
reg [`DWIDTH-1:0] matrixC16_accum;
reg [`DWIDTH-1:0] matrixC17_accum;
reg [`DWIDTH-1:0] matrixC18_accum;
reg [`DWIDTH-1:0] matrixC19_accum;
reg [`DWIDTH-1:0] matrixC110_accum;
reg [`DWIDTH-1:0] matrixC111_accum;
reg [`DWIDTH-1:0] matrixC112_accum;
reg [`DWIDTH-1:0] matrixC113_accum;
reg [`DWIDTH-1:0] matrixC114_accum;
reg [`DWIDTH-1:0] matrixC115_accum;
reg [`DWIDTH-1:0] matrixC20_accum;
reg [`DWIDTH-1:0] matrixC21_accum;
reg [`DWIDTH-1:0] matrixC22_accum;
reg [`DWIDTH-1:0] matrixC23_accum;
reg [`DWIDTH-1:0] matrixC24_accum;
reg [`DWIDTH-1:0] matrixC25_accum;
reg [`DWIDTH-1:0] matrixC26_accum;
reg [`DWIDTH-1:0] matrixC27_accum;
reg [`DWIDTH-1:0] matrixC28_accum;
reg [`DWIDTH-1:0] matrixC29_accum;
reg [`DWIDTH-1:0] matrixC210_accum;
reg [`DWIDTH-1:0] matrixC211_accum;
reg [`DWIDTH-1:0] matrixC212_accum;
reg [`DWIDTH-1:0] matrixC213_accum;
reg [`DWIDTH-1:0] matrixC214_accum;
reg [`DWIDTH-1:0] matrixC215_accum;
reg [`DWIDTH-1:0] matrixC30_accum;
reg [`DWIDTH-1:0] matrixC31_accum;
reg [`DWIDTH-1:0] matrixC32_accum;
reg [`DWIDTH-1:0] matrixC33_accum;
reg [`DWIDTH-1:0] matrixC34_accum;
reg [`DWIDTH-1:0] matrixC35_accum;
reg [`DWIDTH-1:0] matrixC36_accum;
reg [`DWIDTH-1:0] matrixC37_accum;
reg [`DWIDTH-1:0] matrixC38_accum;
reg [`DWIDTH-1:0] matrixC39_accum;
reg [`DWIDTH-1:0] matrixC310_accum;
reg [`DWIDTH-1:0] matrixC311_accum;
reg [`DWIDTH-1:0] matrixC312_accum;
reg [`DWIDTH-1:0] matrixC313_accum;
reg [`DWIDTH-1:0] matrixC314_accum;
reg [`DWIDTH-1:0] matrixC315_accum;
reg [`DWIDTH-1:0] matrixC40_accum;
reg [`DWIDTH-1:0] matrixC41_accum;
reg [`DWIDTH-1:0] matrixC42_accum;
reg [`DWIDTH-1:0] matrixC43_accum;
reg [`DWIDTH-1:0] matrixC44_accum;
reg [`DWIDTH-1:0] matrixC45_accum;
reg [`DWIDTH-1:0] matrixC46_accum;
reg [`DWIDTH-1:0] matrixC47_accum;
reg [`DWIDTH-1:0] matrixC48_accum;
reg [`DWIDTH-1:0] matrixC49_accum;
reg [`DWIDTH-1:0] matrixC410_accum;
reg [`DWIDTH-1:0] matrixC411_accum;
reg [`DWIDTH-1:0] matrixC412_accum;
reg [`DWIDTH-1:0] matrixC413_accum;
reg [`DWIDTH-1:0] matrixC414_accum;
reg [`DWIDTH-1:0] matrixC415_accum;
reg [`DWIDTH-1:0] matrixC50_accum;
reg [`DWIDTH-1:0] matrixC51_accum;
reg [`DWIDTH-1:0] matrixC52_accum;
reg [`DWIDTH-1:0] matrixC53_accum;
reg [`DWIDTH-1:0] matrixC54_accum;
reg [`DWIDTH-1:0] matrixC55_accum;
reg [`DWIDTH-1:0] matrixC56_accum;
reg [`DWIDTH-1:0] matrixC57_accum;
reg [`DWIDTH-1:0] matrixC58_accum;
reg [`DWIDTH-1:0] matrixC59_accum;
reg [`DWIDTH-1:0] matrixC510_accum;
reg [`DWIDTH-1:0] matrixC511_accum;
reg [`DWIDTH-1:0] matrixC512_accum;
reg [`DWIDTH-1:0] matrixC513_accum;
reg [`DWIDTH-1:0] matrixC514_accum;
reg [`DWIDTH-1:0] matrixC515_accum;
reg [`DWIDTH-1:0] matrixC60_accum;
reg [`DWIDTH-1:0] matrixC61_accum;
reg [`DWIDTH-1:0] matrixC62_accum;
reg [`DWIDTH-1:0] matrixC63_accum;
reg [`DWIDTH-1:0] matrixC64_accum;
reg [`DWIDTH-1:0] matrixC65_accum;
reg [`DWIDTH-1:0] matrixC66_accum;
reg [`DWIDTH-1:0] matrixC67_accum;
reg [`DWIDTH-1:0] matrixC68_accum;
reg [`DWIDTH-1:0] matrixC69_accum;
reg [`DWIDTH-1:0] matrixC610_accum;
reg [`DWIDTH-1:0] matrixC611_accum;
reg [`DWIDTH-1:0] matrixC612_accum;
reg [`DWIDTH-1:0] matrixC613_accum;
reg [`DWIDTH-1:0] matrixC614_accum;
reg [`DWIDTH-1:0] matrixC615_accum;
reg [`DWIDTH-1:0] matrixC70_accum;
reg [`DWIDTH-1:0] matrixC71_accum;
reg [`DWIDTH-1:0] matrixC72_accum;
reg [`DWIDTH-1:0] matrixC73_accum;
reg [`DWIDTH-1:0] matrixC74_accum;
reg [`DWIDTH-1:0] matrixC75_accum;
reg [`DWIDTH-1:0] matrixC76_accum;
reg [`DWIDTH-1:0] matrixC77_accum;
reg [`DWIDTH-1:0] matrixC78_accum;
reg [`DWIDTH-1:0] matrixC79_accum;
reg [`DWIDTH-1:0] matrixC710_accum;
reg [`DWIDTH-1:0] matrixC711_accum;
reg [`DWIDTH-1:0] matrixC712_accum;
reg [`DWIDTH-1:0] matrixC713_accum;
reg [`DWIDTH-1:0] matrixC714_accum;
reg [`DWIDTH-1:0] matrixC715_accum;
reg [`DWIDTH-1:0] matrixC80_accum;
reg [`DWIDTH-1:0] matrixC81_accum;
reg [`DWIDTH-1:0] matrixC82_accum;
reg [`DWIDTH-1:0] matrixC83_accum;
reg [`DWIDTH-1:0] matrixC84_accum;
reg [`DWIDTH-1:0] matrixC85_accum;
reg [`DWIDTH-1:0] matrixC86_accum;
reg [`DWIDTH-1:0] matrixC87_accum;
reg [`DWIDTH-1:0] matrixC88_accum;
reg [`DWIDTH-1:0] matrixC89_accum;
reg [`DWIDTH-1:0] matrixC810_accum;
reg [`DWIDTH-1:0] matrixC811_accum;
reg [`DWIDTH-1:0] matrixC812_accum;
reg [`DWIDTH-1:0] matrixC813_accum;
reg [`DWIDTH-1:0] matrixC814_accum;
reg [`DWIDTH-1:0] matrixC815_accum;
reg [`DWIDTH-1:0] matrixC90_accum;
reg [`DWIDTH-1:0] matrixC91_accum;
reg [`DWIDTH-1:0] matrixC92_accum;
reg [`DWIDTH-1:0] matrixC93_accum;
reg [`DWIDTH-1:0] matrixC94_accum;
reg [`DWIDTH-1:0] matrixC95_accum;
reg [`DWIDTH-1:0] matrixC96_accum;
reg [`DWIDTH-1:0] matrixC97_accum;
reg [`DWIDTH-1:0] matrixC98_accum;
reg [`DWIDTH-1:0] matrixC99_accum;
reg [`DWIDTH-1:0] matrixC910_accum;
reg [`DWIDTH-1:0] matrixC911_accum;
reg [`DWIDTH-1:0] matrixC912_accum;
reg [`DWIDTH-1:0] matrixC913_accum;
reg [`DWIDTH-1:0] matrixC914_accum;
reg [`DWIDTH-1:0] matrixC915_accum;
reg [`DWIDTH-1:0] matrixC100_accum;
reg [`DWIDTH-1:0] matrixC101_accum;
reg [`DWIDTH-1:0] matrixC102_accum;
reg [`DWIDTH-1:0] matrixC103_accum;
reg [`DWIDTH-1:0] matrixC104_accum;
reg [`DWIDTH-1:0] matrixC105_accum;
reg [`DWIDTH-1:0] matrixC106_accum;
reg [`DWIDTH-1:0] matrixC107_accum;
reg [`DWIDTH-1:0] matrixC108_accum;
reg [`DWIDTH-1:0] matrixC109_accum;
reg [`DWIDTH-1:0] matrixC1010_accum;
reg [`DWIDTH-1:0] matrixC1011_accum;
reg [`DWIDTH-1:0] matrixC1012_accum;
reg [`DWIDTH-1:0] matrixC1013_accum;
reg [`DWIDTH-1:0] matrixC1014_accum;
reg [`DWIDTH-1:0] matrixC1015_accum;
reg [`DWIDTH-1:0] matrixC110_accum;
reg [`DWIDTH-1:0] matrixC111_accum;
reg [`DWIDTH-1:0] matrixC112_accum;
reg [`DWIDTH-1:0] matrixC113_accum;
reg [`DWIDTH-1:0] matrixC114_accum;
reg [`DWIDTH-1:0] matrixC115_accum;
reg [`DWIDTH-1:0] matrixC116_accum;
reg [`DWIDTH-1:0] matrixC117_accum;
reg [`DWIDTH-1:0] matrixC118_accum;
reg [`DWIDTH-1:0] matrixC119_accum;
reg [`DWIDTH-1:0] matrixC1110_accum;
reg [`DWIDTH-1:0] matrixC1111_accum;
reg [`DWIDTH-1:0] matrixC1112_accum;
reg [`DWIDTH-1:0] matrixC1113_accum;
reg [`DWIDTH-1:0] matrixC1114_accum;
reg [`DWIDTH-1:0] matrixC1115_accum;
reg [`DWIDTH-1:0] matrixC120_accum;
reg [`DWIDTH-1:0] matrixC121_accum;
reg [`DWIDTH-1:0] matrixC122_accum;
reg [`DWIDTH-1:0] matrixC123_accum;
reg [`DWIDTH-1:0] matrixC124_accum;
reg [`DWIDTH-1:0] matrixC125_accum;
reg [`DWIDTH-1:0] matrixC126_accum;
reg [`DWIDTH-1:0] matrixC127_accum;
reg [`DWIDTH-1:0] matrixC128_accum;
reg [`DWIDTH-1:0] matrixC129_accum;
reg [`DWIDTH-1:0] matrixC1210_accum;
reg [`DWIDTH-1:0] matrixC1211_accum;
reg [`DWIDTH-1:0] matrixC1212_accum;
reg [`DWIDTH-1:0] matrixC1213_accum;
reg [`DWIDTH-1:0] matrixC1214_accum;
reg [`DWIDTH-1:0] matrixC1215_accum;
reg [`DWIDTH-1:0] matrixC130_accum;
reg [`DWIDTH-1:0] matrixC131_accum;
reg [`DWIDTH-1:0] matrixC132_accum;
reg [`DWIDTH-1:0] matrixC133_accum;
reg [`DWIDTH-1:0] matrixC134_accum;
reg [`DWIDTH-1:0] matrixC135_accum;
reg [`DWIDTH-1:0] matrixC136_accum;
reg [`DWIDTH-1:0] matrixC137_accum;
reg [`DWIDTH-1:0] matrixC138_accum;
reg [`DWIDTH-1:0] matrixC139_accum;
reg [`DWIDTH-1:0] matrixC1310_accum;
reg [`DWIDTH-1:0] matrixC1311_accum;
reg [`DWIDTH-1:0] matrixC1312_accum;
reg [`DWIDTH-1:0] matrixC1313_accum;
reg [`DWIDTH-1:0] matrixC1314_accum;
reg [`DWIDTH-1:0] matrixC1315_accum;
reg [`DWIDTH-1:0] matrixC140_accum;
reg [`DWIDTH-1:0] matrixC141_accum;
reg [`DWIDTH-1:0] matrixC142_accum;
reg [`DWIDTH-1:0] matrixC143_accum;
reg [`DWIDTH-1:0] matrixC144_accum;
reg [`DWIDTH-1:0] matrixC145_accum;
reg [`DWIDTH-1:0] matrixC146_accum;
reg [`DWIDTH-1:0] matrixC147_accum;
reg [`DWIDTH-1:0] matrixC148_accum;
reg [`DWIDTH-1:0] matrixC149_accum;
reg [`DWIDTH-1:0] matrixC1410_accum;
reg [`DWIDTH-1:0] matrixC1411_accum;
reg [`DWIDTH-1:0] matrixC1412_accum;
reg [`DWIDTH-1:0] matrixC1413_accum;
reg [`DWIDTH-1:0] matrixC1414_accum;
reg [`DWIDTH-1:0] matrixC1415_accum;
reg [`DWIDTH-1:0] matrixC150_accum;
reg [`DWIDTH-1:0] matrixC151_accum;
reg [`DWIDTH-1:0] matrixC152_accum;
reg [`DWIDTH-1:0] matrixC153_accum;
reg [`DWIDTH-1:0] matrixC154_accum;
reg [`DWIDTH-1:0] matrixC155_accum;
reg [`DWIDTH-1:0] matrixC156_accum;
reg [`DWIDTH-1:0] matrixC157_accum;
reg [`DWIDTH-1:0] matrixC158_accum;
reg [`DWIDTH-1:0] matrixC159_accum;
reg [`DWIDTH-1:0] matrixC1510_accum;
reg [`DWIDTH-1:0] matrixC1511_accum;
reg [`DWIDTH-1:0] matrixC1512_accum;
reg [`DWIDTH-1:0] matrixC1513_accum;
reg [`DWIDTH-1:0] matrixC1514_accum;
reg [`DWIDTH-1:0] matrixC1515_accum;

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
matrixC08_accum <= 0;
matrixC09_accum <= 0;
matrixC010_accum <= 0;
matrixC011_accum <= 0;
matrixC012_accum <= 0;
matrixC013_accum <= 0;
matrixC014_accum <= 0;
matrixC015_accum <= 0;
matrixC10_accum <= 0;
matrixC11_accum <= 0;
matrixC12_accum <= 0;
matrixC13_accum <= 0;
matrixC14_accum <= 0;
matrixC15_accum <= 0;
matrixC16_accum <= 0;
matrixC17_accum <= 0;
matrixC18_accum <= 0;
matrixC19_accum <= 0;
matrixC110_accum <= 0;
matrixC111_accum <= 0;
matrixC112_accum <= 0;
matrixC113_accum <= 0;
matrixC114_accum <= 0;
matrixC115_accum <= 0;
matrixC20_accum <= 0;
matrixC21_accum <= 0;
matrixC22_accum <= 0;
matrixC23_accum <= 0;
matrixC24_accum <= 0;
matrixC25_accum <= 0;
matrixC26_accum <= 0;
matrixC27_accum <= 0;
matrixC28_accum <= 0;
matrixC29_accum <= 0;
matrixC210_accum <= 0;
matrixC211_accum <= 0;
matrixC212_accum <= 0;
matrixC213_accum <= 0;
matrixC214_accum <= 0;
matrixC215_accum <= 0;
matrixC30_accum <= 0;
matrixC31_accum <= 0;
matrixC32_accum <= 0;
matrixC33_accum <= 0;
matrixC34_accum <= 0;
matrixC35_accum <= 0;
matrixC36_accum <= 0;
matrixC37_accum <= 0;
matrixC38_accum <= 0;
matrixC39_accum <= 0;
matrixC310_accum <= 0;
matrixC311_accum <= 0;
matrixC312_accum <= 0;
matrixC313_accum <= 0;
matrixC314_accum <= 0;
matrixC315_accum <= 0;
matrixC40_accum <= 0;
matrixC41_accum <= 0;
matrixC42_accum <= 0;
matrixC43_accum <= 0;
matrixC44_accum <= 0;
matrixC45_accum <= 0;
matrixC46_accum <= 0;
matrixC47_accum <= 0;
matrixC48_accum <= 0;
matrixC49_accum <= 0;
matrixC410_accum <= 0;
matrixC411_accum <= 0;
matrixC412_accum <= 0;
matrixC413_accum <= 0;
matrixC414_accum <= 0;
matrixC415_accum <= 0;
matrixC50_accum <= 0;
matrixC51_accum <= 0;
matrixC52_accum <= 0;
matrixC53_accum <= 0;
matrixC54_accum <= 0;
matrixC55_accum <= 0;
matrixC56_accum <= 0;
matrixC57_accum <= 0;
matrixC58_accum <= 0;
matrixC59_accum <= 0;
matrixC510_accum <= 0;
matrixC511_accum <= 0;
matrixC512_accum <= 0;
matrixC513_accum <= 0;
matrixC514_accum <= 0;
matrixC515_accum <= 0;
matrixC60_accum <= 0;
matrixC61_accum <= 0;
matrixC62_accum <= 0;
matrixC63_accum <= 0;
matrixC64_accum <= 0;
matrixC65_accum <= 0;
matrixC66_accum <= 0;
matrixC67_accum <= 0;
matrixC68_accum <= 0;
matrixC69_accum <= 0;
matrixC610_accum <= 0;
matrixC611_accum <= 0;
matrixC612_accum <= 0;
matrixC613_accum <= 0;
matrixC614_accum <= 0;
matrixC615_accum <= 0;
matrixC70_accum <= 0;
matrixC71_accum <= 0;
matrixC72_accum <= 0;
matrixC73_accum <= 0;
matrixC74_accum <= 0;
matrixC75_accum <= 0;
matrixC76_accum <= 0;
matrixC77_accum <= 0;
matrixC78_accum <= 0;
matrixC79_accum <= 0;
matrixC710_accum <= 0;
matrixC711_accum <= 0;
matrixC712_accum <= 0;
matrixC713_accum <= 0;
matrixC714_accum <= 0;
matrixC715_accum <= 0;
matrixC80_accum <= 0;
matrixC81_accum <= 0;
matrixC82_accum <= 0;
matrixC83_accum <= 0;
matrixC84_accum <= 0;
matrixC85_accum <= 0;
matrixC86_accum <= 0;
matrixC87_accum <= 0;
matrixC88_accum <= 0;
matrixC89_accum <= 0;
matrixC810_accum <= 0;
matrixC811_accum <= 0;
matrixC812_accum <= 0;
matrixC813_accum <= 0;
matrixC814_accum <= 0;
matrixC815_accum <= 0;
matrixC90_accum <= 0;
matrixC91_accum <= 0;
matrixC92_accum <= 0;
matrixC93_accum <= 0;
matrixC94_accum <= 0;
matrixC95_accum <= 0;
matrixC96_accum <= 0;
matrixC97_accum <= 0;
matrixC98_accum <= 0;
matrixC99_accum <= 0;
matrixC910_accum <= 0;
matrixC911_accum <= 0;
matrixC912_accum <= 0;
matrixC913_accum <= 0;
matrixC914_accum <= 0;
matrixC915_accum <= 0;
matrixC100_accum <= 0;
matrixC101_accum <= 0;
matrixC102_accum <= 0;
matrixC103_accum <= 0;
matrixC104_accum <= 0;
matrixC105_accum <= 0;
matrixC106_accum <= 0;
matrixC107_accum <= 0;
matrixC108_accum <= 0;
matrixC109_accum <= 0;
matrixC1010_accum <= 0;
matrixC1011_accum <= 0;
matrixC1012_accum <= 0;
matrixC1013_accum <= 0;
matrixC1014_accum <= 0;
matrixC1015_accum <= 0;
matrixC110_accum <= 0;
matrixC111_accum <= 0;
matrixC112_accum <= 0;
matrixC113_accum <= 0;
matrixC114_accum <= 0;
matrixC115_accum <= 0;
matrixC116_accum <= 0;
matrixC117_accum <= 0;
matrixC118_accum <= 0;
matrixC119_accum <= 0;
matrixC1110_accum <= 0;
matrixC1111_accum <= 0;
matrixC1112_accum <= 0;
matrixC1113_accum <= 0;
matrixC1114_accum <= 0;
matrixC1115_accum <= 0;
matrixC120_accum <= 0;
matrixC121_accum <= 0;
matrixC122_accum <= 0;
matrixC123_accum <= 0;
matrixC124_accum <= 0;
matrixC125_accum <= 0;
matrixC126_accum <= 0;
matrixC127_accum <= 0;
matrixC128_accum <= 0;
matrixC129_accum <= 0;
matrixC1210_accum <= 0;
matrixC1211_accum <= 0;
matrixC1212_accum <= 0;
matrixC1213_accum <= 0;
matrixC1214_accum <= 0;
matrixC1215_accum <= 0;
matrixC130_accum <= 0;
matrixC131_accum <= 0;
matrixC132_accum <= 0;
matrixC133_accum <= 0;
matrixC134_accum <= 0;
matrixC135_accum <= 0;
matrixC136_accum <= 0;
matrixC137_accum <= 0;
matrixC138_accum <= 0;
matrixC139_accum <= 0;
matrixC1310_accum <= 0;
matrixC1311_accum <= 0;
matrixC1312_accum <= 0;
matrixC1313_accum <= 0;
matrixC1314_accum <= 0;
matrixC1315_accum <= 0;
matrixC140_accum <= 0;
matrixC141_accum <= 0;
matrixC142_accum <= 0;
matrixC143_accum <= 0;
matrixC144_accum <= 0;
matrixC145_accum <= 0;
matrixC146_accum <= 0;
matrixC147_accum <= 0;
matrixC148_accum <= 0;
matrixC149_accum <= 0;
matrixC1410_accum <= 0;
matrixC1411_accum <= 0;
matrixC1412_accum <= 0;
matrixC1413_accum <= 0;
matrixC1414_accum <= 0;
matrixC1415_accum <= 0;
matrixC150_accum <= 0;
matrixC151_accum <= 0;
matrixC152_accum <= 0;
matrixC153_accum <= 0;
matrixC154_accum <= 0;
matrixC155_accum <= 0;
matrixC156_accum <= 0;
matrixC157_accum <= 0;
matrixC158_accum <= 0;
matrixC159_accum <= 0;
matrixC1510_accum <= 0;
matrixC1511_accum <= 0;
matrixC1512_accum <= 0;
matrixC1513_accum <= 0;
matrixC1514_accum <= 0;
matrixC1515_accum <= 0;
 outputs_saved_to_accum <= 0;
    outputs_added_to_accum <= 0;

    cur_c_saved <= 0;
    cur_r_saved <= 0;
    cur_s_saved <= 0;
  
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
	matrixC08_accum <= matrixC08_added;
	matrixC09_accum <= matrixC09_added;
	matrixC010_accum <= matrixC010_added;
	matrixC011_accum <= matrixC011_added;
	matrixC012_accum <= matrixC012_added;
	matrixC013_accum <= matrixC013_added;
	matrixC014_accum <= matrixC014_added;
	matrixC015_accum <= matrixC015_added;
	matrixC10_accum <= matrixC10_added;
	matrixC11_accum <= matrixC11_added;
	matrixC12_accum <= matrixC12_added;
	matrixC13_accum <= matrixC13_added;
	matrixC14_accum <= matrixC14_added;
	matrixC15_accum <= matrixC15_added;
	matrixC16_accum <= matrixC16_added;
	matrixC17_accum <= matrixC17_added;
	matrixC18_accum <= matrixC18_added;
	matrixC19_accum <= matrixC19_added;
	matrixC110_accum <= matrixC110_added;
	matrixC111_accum <= matrixC111_added;
	matrixC112_accum <= matrixC112_added;
	matrixC113_accum <= matrixC113_added;
	matrixC114_accum <= matrixC114_added;
	matrixC115_accum <= matrixC115_added;
	matrixC20_accum <= matrixC20_added;
	matrixC21_accum <= matrixC21_added;
	matrixC22_accum <= matrixC22_added;
	matrixC23_accum <= matrixC23_added;
	matrixC24_accum <= matrixC24_added;
	matrixC25_accum <= matrixC25_added;
	matrixC26_accum <= matrixC26_added;
	matrixC27_accum <= matrixC27_added;
	matrixC28_accum <= matrixC28_added;
	matrixC29_accum <= matrixC29_added;
	matrixC210_accum <= matrixC210_added;
	matrixC211_accum <= matrixC211_added;
	matrixC212_accum <= matrixC212_added;
	matrixC213_accum <= matrixC213_added;
	matrixC214_accum <= matrixC214_added;
	matrixC215_accum <= matrixC215_added;
	matrixC30_accum <= matrixC30_added;
	matrixC31_accum <= matrixC31_added;
	matrixC32_accum <= matrixC32_added;
	matrixC33_accum <= matrixC33_added;
	matrixC34_accum <= matrixC34_added;
	matrixC35_accum <= matrixC35_added;
	matrixC36_accum <= matrixC36_added;
	matrixC37_accum <= matrixC37_added;
	matrixC38_accum <= matrixC38_added;
	matrixC39_accum <= matrixC39_added;
	matrixC310_accum <= matrixC310_added;
	matrixC311_accum <= matrixC311_added;
	matrixC312_accum <= matrixC312_added;
	matrixC313_accum <= matrixC313_added;
	matrixC314_accum <= matrixC314_added;
	matrixC315_accum <= matrixC315_added;
	matrixC40_accum <= matrixC40_added;
	matrixC41_accum <= matrixC41_added;
	matrixC42_accum <= matrixC42_added;
	matrixC43_accum <= matrixC43_added;
	matrixC44_accum <= matrixC44_added;
	matrixC45_accum <= matrixC45_added;
	matrixC46_accum <= matrixC46_added;
	matrixC47_accum <= matrixC47_added;
	matrixC48_accum <= matrixC48_added;
	matrixC49_accum <= matrixC49_added;
	matrixC410_accum <= matrixC410_added;
	matrixC411_accum <= matrixC411_added;
	matrixC412_accum <= matrixC412_added;
	matrixC413_accum <= matrixC413_added;
	matrixC414_accum <= matrixC414_added;
	matrixC415_accum <= matrixC415_added;
	matrixC50_accum <= matrixC50_added;
	matrixC51_accum <= matrixC51_added;
	matrixC52_accum <= matrixC52_added;
	matrixC53_accum <= matrixC53_added;
	matrixC54_accum <= matrixC54_added;
	matrixC55_accum <= matrixC55_added;
	matrixC56_accum <= matrixC56_added;
	matrixC57_accum <= matrixC57_added;
	matrixC58_accum <= matrixC58_added;
	matrixC59_accum <= matrixC59_added;
	matrixC510_accum <= matrixC510_added;
	matrixC511_accum <= matrixC511_added;
	matrixC512_accum <= matrixC512_added;
	matrixC513_accum <= matrixC513_added;
	matrixC514_accum <= matrixC514_added;
	matrixC515_accum <= matrixC515_added;
	matrixC60_accum <= matrixC60_added;
	matrixC61_accum <= matrixC61_added;
	matrixC62_accum <= matrixC62_added;
	matrixC63_accum <= matrixC63_added;
	matrixC64_accum <= matrixC64_added;
	matrixC65_accum <= matrixC65_added;
	matrixC66_accum <= matrixC66_added;
	matrixC67_accum <= matrixC67_added;
	matrixC68_accum <= matrixC68_added;
	matrixC69_accum <= matrixC69_added;
	matrixC610_accum <= matrixC610_added;
	matrixC611_accum <= matrixC611_added;
	matrixC612_accum <= matrixC612_added;
	matrixC613_accum <= matrixC613_added;
	matrixC614_accum <= matrixC614_added;
	matrixC615_accum <= matrixC615_added;
	matrixC70_accum <= matrixC70_added;
	matrixC71_accum <= matrixC71_added;
	matrixC72_accum <= matrixC72_added;
	matrixC73_accum <= matrixC73_added;
	matrixC74_accum <= matrixC74_added;
	matrixC75_accum <= matrixC75_added;
	matrixC76_accum <= matrixC76_added;
	matrixC77_accum <= matrixC77_added;
	matrixC78_accum <= matrixC78_added;
	matrixC79_accum <= matrixC79_added;
	matrixC710_accum <= matrixC710_added;
	matrixC711_accum <= matrixC711_added;
	matrixC712_accum <= matrixC712_added;
	matrixC713_accum <= matrixC713_added;
	matrixC714_accum <= matrixC714_added;
	matrixC715_accum <= matrixC715_added;
	matrixC80_accum <= matrixC80_added;
	matrixC81_accum <= matrixC81_added;
	matrixC82_accum <= matrixC82_added;
	matrixC83_accum <= matrixC83_added;
	matrixC84_accum <= matrixC84_added;
	matrixC85_accum <= matrixC85_added;
	matrixC86_accum <= matrixC86_added;
	matrixC87_accum <= matrixC87_added;
	matrixC88_accum <= matrixC88_added;
	matrixC89_accum <= matrixC89_added;
	matrixC810_accum <= matrixC810_added;
	matrixC811_accum <= matrixC811_added;
	matrixC812_accum <= matrixC812_added;
	matrixC813_accum <= matrixC813_added;
	matrixC814_accum <= matrixC814_added;
	matrixC815_accum <= matrixC815_added;
	matrixC90_accum <= matrixC90_added;
	matrixC91_accum <= matrixC91_added;
	matrixC92_accum <= matrixC92_added;
	matrixC93_accum <= matrixC93_added;
	matrixC94_accum <= matrixC94_added;
	matrixC95_accum <= matrixC95_added;
	matrixC96_accum <= matrixC96_added;
	matrixC97_accum <= matrixC97_added;
	matrixC98_accum <= matrixC98_added;
	matrixC99_accum <= matrixC99_added;
	matrixC910_accum <= matrixC910_added;
	matrixC911_accum <= matrixC911_added;
	matrixC912_accum <= matrixC912_added;
	matrixC913_accum <= matrixC913_added;
	matrixC914_accum <= matrixC914_added;
	matrixC915_accum <= matrixC915_added;
	matrixC100_accum <= matrixC100_added;
	matrixC101_accum <= matrixC101_added;
	matrixC102_accum <= matrixC102_added;
	matrixC103_accum <= matrixC103_added;
	matrixC104_accum <= matrixC104_added;
	matrixC105_accum <= matrixC105_added;
	matrixC106_accum <= matrixC106_added;
	matrixC107_accum <= matrixC107_added;
	matrixC108_accum <= matrixC108_added;
	matrixC109_accum <= matrixC109_added;
	matrixC1010_accum <= matrixC1010_added;
	matrixC1011_accum <= matrixC1011_added;
	matrixC1012_accum <= matrixC1012_added;
	matrixC1013_accum <= matrixC1013_added;
	matrixC1014_accum <= matrixC1014_added;
	matrixC1015_accum <= matrixC1015_added;
	matrixC110_accum <= matrixC110_added;
	matrixC111_accum <= matrixC111_added;
	matrixC112_accum <= matrixC112_added;
	matrixC113_accum <= matrixC113_added;
	matrixC114_accum <= matrixC114_added;
	matrixC115_accum <= matrixC115_added;
	matrixC116_accum <= matrixC116_added;
	matrixC117_accum <= matrixC117_added;
	matrixC118_accum <= matrixC118_added;
	matrixC119_accum <= matrixC119_added;
	matrixC1110_accum <= matrixC1110_added;
	matrixC1111_accum <= matrixC1111_added;
	matrixC1112_accum <= matrixC1112_added;
	matrixC1113_accum <= matrixC1113_added;
	matrixC1114_accum <= matrixC1114_added;
	matrixC1115_accum <= matrixC1115_added;
	matrixC120_accum <= matrixC120_added;
	matrixC121_accum <= matrixC121_added;
	matrixC122_accum <= matrixC122_added;
	matrixC123_accum <= matrixC123_added;
	matrixC124_accum <= matrixC124_added;
	matrixC125_accum <= matrixC125_added;
	matrixC126_accum <= matrixC126_added;
	matrixC127_accum <= matrixC127_added;
	matrixC128_accum <= matrixC128_added;
	matrixC129_accum <= matrixC129_added;
	matrixC1210_accum <= matrixC1210_added;
	matrixC1211_accum <= matrixC1211_added;
	matrixC1212_accum <= matrixC1212_added;
	matrixC1213_accum <= matrixC1213_added;
	matrixC1214_accum <= matrixC1214_added;
	matrixC1215_accum <= matrixC1215_added;
	matrixC130_accum <= matrixC130_added;
	matrixC131_accum <= matrixC131_added;
	matrixC132_accum <= matrixC132_added;
	matrixC133_accum <= matrixC133_added;
	matrixC134_accum <= matrixC134_added;
	matrixC135_accum <= matrixC135_added;
	matrixC136_accum <= matrixC136_added;
	matrixC137_accum <= matrixC137_added;
	matrixC138_accum <= matrixC138_added;
	matrixC139_accum <= matrixC139_added;
	matrixC1310_accum <= matrixC1310_added;
	matrixC1311_accum <= matrixC1311_added;
	matrixC1312_accum <= matrixC1312_added;
	matrixC1313_accum <= matrixC1313_added;
	matrixC1314_accum <= matrixC1314_added;
	matrixC1315_accum <= matrixC1315_added;
	matrixC140_accum <= matrixC140_added;
	matrixC141_accum <= matrixC141_added;
	matrixC142_accum <= matrixC142_added;
	matrixC143_accum <= matrixC143_added;
	matrixC144_accum <= matrixC144_added;
	matrixC145_accum <= matrixC145_added;
	matrixC146_accum <= matrixC146_added;
	matrixC147_accum <= matrixC147_added;
	matrixC148_accum <= matrixC148_added;
	matrixC149_accum <= matrixC149_added;
	matrixC1410_accum <= matrixC1410_added;
	matrixC1411_accum <= matrixC1411_added;
	matrixC1412_accum <= matrixC1412_added;
	matrixC1413_accum <= matrixC1413_added;
	matrixC1414_accum <= matrixC1414_added;
	matrixC1415_accum <= matrixC1415_added;
	matrixC150_accum <= matrixC150_added;
	matrixC151_accum <= matrixC151_added;
	matrixC152_accum <= matrixC152_added;
	matrixC153_accum <= matrixC153_added;
	matrixC154_accum <= matrixC154_added;
	matrixC155_accum <= matrixC155_added;
	matrixC156_accum <= matrixC156_added;
	matrixC157_accum <= matrixC157_added;
	matrixC158_accum <= matrixC158_added;
	matrixC159_accum <= matrixC159_added;
	matrixC1510_accum <= matrixC1510_added;
	matrixC1511_accum <= matrixC1511_added;
	matrixC1512_accum <= matrixC1512_added;
	matrixC1513_accum <= matrixC1513_added;
	matrixC1514_accum <= matrixC1514_added;
	matrixC1515_accum <= matrixC1515_added;

    outputs_saved_to_accum <= 1;
    outputs_added_to_accum <= 1;

    cur_c_saved <= c;
    cur_r_saved <= r;
    cur_s_saved <= s;
  
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
	matrixC08_accum <= matrixC08;
	matrixC09_accum <= matrixC09;
	matrixC010_accum <= matrixC010;
	matrixC011_accum <= matrixC011;
	matrixC012_accum <= matrixC012;
	matrixC013_accum <= matrixC013;
	matrixC014_accum <= matrixC014;
	matrixC015_accum <= matrixC015;
	matrixC10_accum <= matrixC10;
	matrixC11_accum <= matrixC11;
	matrixC12_accum <= matrixC12;
	matrixC13_accum <= matrixC13;
	matrixC14_accum <= matrixC14;
	matrixC15_accum <= matrixC15;
	matrixC16_accum <= matrixC16;
	matrixC17_accum <= matrixC17;
	matrixC18_accum <= matrixC18;
	matrixC19_accum <= matrixC19;
	matrixC110_accum <= matrixC110;
	matrixC111_accum <= matrixC111;
	matrixC112_accum <= matrixC112;
	matrixC113_accum <= matrixC113;
	matrixC114_accum <= matrixC114;
	matrixC115_accum <= matrixC115;
	matrixC20_accum <= matrixC20;
	matrixC21_accum <= matrixC21;
	matrixC22_accum <= matrixC22;
	matrixC23_accum <= matrixC23;
	matrixC24_accum <= matrixC24;
	matrixC25_accum <= matrixC25;
	matrixC26_accum <= matrixC26;
	matrixC27_accum <= matrixC27;
	matrixC28_accum <= matrixC28;
	matrixC29_accum <= matrixC29;
	matrixC210_accum <= matrixC210;
	matrixC211_accum <= matrixC211;
	matrixC212_accum <= matrixC212;
	matrixC213_accum <= matrixC213;
	matrixC214_accum <= matrixC214;
	matrixC215_accum <= matrixC215;
	matrixC30_accum <= matrixC30;
	matrixC31_accum <= matrixC31;
	matrixC32_accum <= matrixC32;
	matrixC33_accum <= matrixC33;
	matrixC34_accum <= matrixC34;
	matrixC35_accum <= matrixC35;
	matrixC36_accum <= matrixC36;
	matrixC37_accum <= matrixC37;
	matrixC38_accum <= matrixC38;
	matrixC39_accum <= matrixC39;
	matrixC310_accum <= matrixC310;
	matrixC311_accum <= matrixC311;
	matrixC312_accum <= matrixC312;
	matrixC313_accum <= matrixC313;
	matrixC314_accum <= matrixC314;
	matrixC315_accum <= matrixC315;
	matrixC40_accum <= matrixC40;
	matrixC41_accum <= matrixC41;
	matrixC42_accum <= matrixC42;
	matrixC43_accum <= matrixC43;
	matrixC44_accum <= matrixC44;
	matrixC45_accum <= matrixC45;
	matrixC46_accum <= matrixC46;
	matrixC47_accum <= matrixC47;
	matrixC48_accum <= matrixC48;
	matrixC49_accum <= matrixC49;
	matrixC410_accum <= matrixC410;
	matrixC411_accum <= matrixC411;
	matrixC412_accum <= matrixC412;
	matrixC413_accum <= matrixC413;
	matrixC414_accum <= matrixC414;
	matrixC415_accum <= matrixC415;
	matrixC50_accum <= matrixC50;
	matrixC51_accum <= matrixC51;
	matrixC52_accum <= matrixC52;
	matrixC53_accum <= matrixC53;
	matrixC54_accum <= matrixC54;
	matrixC55_accum <= matrixC55;
	matrixC56_accum <= matrixC56;
	matrixC57_accum <= matrixC57;
	matrixC58_accum <= matrixC58;
	matrixC59_accum <= matrixC59;
	matrixC510_accum <= matrixC510;
	matrixC511_accum <= matrixC511;
	matrixC512_accum <= matrixC512;
	matrixC513_accum <= matrixC513;
	matrixC514_accum <= matrixC514;
	matrixC515_accum <= matrixC515;
	matrixC60_accum <= matrixC60;
	matrixC61_accum <= matrixC61;
	matrixC62_accum <= matrixC62;
	matrixC63_accum <= matrixC63;
	matrixC64_accum <= matrixC64;
	matrixC65_accum <= matrixC65;
	matrixC66_accum <= matrixC66;
	matrixC67_accum <= matrixC67;
	matrixC68_accum <= matrixC68;
	matrixC69_accum <= matrixC69;
	matrixC610_accum <= matrixC610;
	matrixC611_accum <= matrixC611;
	matrixC612_accum <= matrixC612;
	matrixC613_accum <= matrixC613;
	matrixC614_accum <= matrixC614;
	matrixC615_accum <= matrixC615;
	matrixC70_accum <= matrixC70;
	matrixC71_accum <= matrixC71;
	matrixC72_accum <= matrixC72;
	matrixC73_accum <= matrixC73;
	matrixC74_accum <= matrixC74;
	matrixC75_accum <= matrixC75;
	matrixC76_accum <= matrixC76;
	matrixC77_accum <= matrixC77;
	matrixC78_accum <= matrixC78;
	matrixC79_accum <= matrixC79;
	matrixC710_accum <= matrixC710;
	matrixC711_accum <= matrixC711;
	matrixC712_accum <= matrixC712;
	matrixC713_accum <= matrixC713;
	matrixC714_accum <= matrixC714;
	matrixC715_accum <= matrixC715;
	matrixC80_accum <= matrixC80;
	matrixC81_accum <= matrixC81;
	matrixC82_accum <= matrixC82;
	matrixC83_accum <= matrixC83;
	matrixC84_accum <= matrixC84;
	matrixC85_accum <= matrixC85;
	matrixC86_accum <= matrixC86;
	matrixC87_accum <= matrixC87;
	matrixC88_accum <= matrixC88;
	matrixC89_accum <= matrixC89;
	matrixC810_accum <= matrixC810;
	matrixC811_accum <= matrixC811;
	matrixC812_accum <= matrixC812;
	matrixC813_accum <= matrixC813;
	matrixC814_accum <= matrixC814;
	matrixC815_accum <= matrixC815;
	matrixC90_accum <= matrixC90;
	matrixC91_accum <= matrixC91;
	matrixC92_accum <= matrixC92;
	matrixC93_accum <= matrixC93;
	matrixC94_accum <= matrixC94;
	matrixC95_accum <= matrixC95;
	matrixC96_accum <= matrixC96;
	matrixC97_accum <= matrixC97;
	matrixC98_accum <= matrixC98;
	matrixC99_accum <= matrixC99;
	matrixC910_accum <= matrixC910;
	matrixC911_accum <= matrixC911;
	matrixC912_accum <= matrixC912;
	matrixC913_accum <= matrixC913;
	matrixC914_accum <= matrixC914;
	matrixC915_accum <= matrixC915;
	matrixC100_accum <= matrixC100;
	matrixC101_accum <= matrixC101;
	matrixC102_accum <= matrixC102;
	matrixC103_accum <= matrixC103;
	matrixC104_accum <= matrixC104;
	matrixC105_accum <= matrixC105;
	matrixC106_accum <= matrixC106;
	matrixC107_accum <= matrixC107;
	matrixC108_accum <= matrixC108;
	matrixC109_accum <= matrixC109;
	matrixC1010_accum <= matrixC1010;
	matrixC1011_accum <= matrixC1011;
	matrixC1012_accum <= matrixC1012;
	matrixC1013_accum <= matrixC1013;
	matrixC1014_accum <= matrixC1014;
	matrixC1015_accum <= matrixC1015;
	matrixC110_accum <= matrixC110;
	matrixC111_accum <= matrixC111;
	matrixC112_accum <= matrixC112;
	matrixC113_accum <= matrixC113;
	matrixC114_accum <= matrixC114;
	matrixC115_accum <= matrixC115;
	matrixC116_accum <= matrixC116;
	matrixC117_accum <= matrixC117;
	matrixC118_accum <= matrixC118;
	matrixC119_accum <= matrixC119;
	matrixC1110_accum <= matrixC1110;
	matrixC1111_accum <= matrixC1111;
	matrixC1112_accum <= matrixC1112;
	matrixC1113_accum <= matrixC1113;
	matrixC1114_accum <= matrixC1114;
	matrixC1115_accum <= matrixC1115;
	matrixC120_accum <= matrixC120;
	matrixC121_accum <= matrixC121;
	matrixC122_accum <= matrixC122;
	matrixC123_accum <= matrixC123;
	matrixC124_accum <= matrixC124;
	matrixC125_accum <= matrixC125;
	matrixC126_accum <= matrixC126;
	matrixC127_accum <= matrixC127;
	matrixC128_accum <= matrixC128;
	matrixC129_accum <= matrixC129;
	matrixC1210_accum <= matrixC1210;
	matrixC1211_accum <= matrixC1211;
	matrixC1212_accum <= matrixC1212;
	matrixC1213_accum <= matrixC1213;
	matrixC1214_accum <= matrixC1214;
	matrixC1215_accum <= matrixC1215;
	matrixC130_accum <= matrixC130;
	matrixC131_accum <= matrixC131;
	matrixC132_accum <= matrixC132;
	matrixC133_accum <= matrixC133;
	matrixC134_accum <= matrixC134;
	matrixC135_accum <= matrixC135;
	matrixC136_accum <= matrixC136;
	matrixC137_accum <= matrixC137;
	matrixC138_accum <= matrixC138;
	matrixC139_accum <= matrixC139;
	matrixC1310_accum <= matrixC1310;
	matrixC1311_accum <= matrixC1311;
	matrixC1312_accum <= matrixC1312;
	matrixC1313_accum <= matrixC1313;
	matrixC1314_accum <= matrixC1314;
	matrixC1315_accum <= matrixC1315;
	matrixC140_accum <= matrixC140;
	matrixC141_accum <= matrixC141;
	matrixC142_accum <= matrixC142;
	matrixC143_accum <= matrixC143;
	matrixC144_accum <= matrixC144;
	matrixC145_accum <= matrixC145;
	matrixC146_accum <= matrixC146;
	matrixC147_accum <= matrixC147;
	matrixC148_accum <= matrixC148;
	matrixC149_accum <= matrixC149;
	matrixC1410_accum <= matrixC1410;
	matrixC1411_accum <= matrixC1411;
	matrixC1412_accum <= matrixC1412;
	matrixC1413_accum <= matrixC1413;
	matrixC1414_accum <= matrixC1414;
	matrixC1415_accum <= matrixC1415;
	matrixC150_accum <= matrixC150;
	matrixC151_accum <= matrixC151;
	matrixC152_accum <= matrixC152;
	matrixC153_accum <= matrixC153;
	matrixC154_accum <= matrixC154;
	matrixC155_accum <= matrixC155;
	matrixC156_accum <= matrixC156;
	matrixC157_accum <= matrixC157;
	matrixC158_accum <= matrixC158;
	matrixC159_accum <= matrixC159;
	matrixC1510_accum <= matrixC1510;
	matrixC1511_accum <= matrixC1511;
	matrixC1512_accum <= matrixC1512;
	matrixC1513_accum <= matrixC1513;
	matrixC1514_accum <= matrixC1514;
	matrixC1515_accum <= matrixC1515;

    outputs_saved_to_accum <= 1;

    cur_c_saved <= c;
    cur_r_saved <= r;
    cur_s_saved <= s;
  
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
assign matrixC08_added = (add_accum_to_output) ? (matrixC08 + matrixC08_accum) : matrixC08;
assign matrixC09_added = (add_accum_to_output) ? (matrixC09 + matrixC09_accum) : matrixC09;
assign matrixC010_added = (add_accum_to_output) ? (matrixC010 + matrixC010_accum) : matrixC010;
assign matrixC011_added = (add_accum_to_output) ? (matrixC011 + matrixC011_accum) : matrixC011;
assign matrixC012_added = (add_accum_to_output) ? (matrixC012 + matrixC012_accum) : matrixC012;
assign matrixC013_added = (add_accum_to_output) ? (matrixC013 + matrixC013_accum) : matrixC013;
assign matrixC014_added = (add_accum_to_output) ? (matrixC014 + matrixC014_accum) : matrixC014;
assign matrixC015_added = (add_accum_to_output) ? (matrixC015 + matrixC015_accum) : matrixC015;
assign matrixC10_added = (add_accum_to_output) ? (matrixC10 + matrixC10_accum) : matrixC10;
assign matrixC11_added = (add_accum_to_output) ? (matrixC11 + matrixC11_accum) : matrixC11;
assign matrixC12_added = (add_accum_to_output) ? (matrixC12 + matrixC12_accum) : matrixC12;
assign matrixC13_added = (add_accum_to_output) ? (matrixC13 + matrixC13_accum) : matrixC13;
assign matrixC14_added = (add_accum_to_output) ? (matrixC14 + matrixC14_accum) : matrixC14;
assign matrixC15_added = (add_accum_to_output) ? (matrixC15 + matrixC15_accum) : matrixC15;
assign matrixC16_added = (add_accum_to_output) ? (matrixC16 + matrixC16_accum) : matrixC16;
assign matrixC17_added = (add_accum_to_output) ? (matrixC17 + matrixC17_accum) : matrixC17;
assign matrixC18_added = (add_accum_to_output) ? (matrixC18 + matrixC18_accum) : matrixC18;
assign matrixC19_added = (add_accum_to_output) ? (matrixC19 + matrixC19_accum) : matrixC19;
assign matrixC110_added = (add_accum_to_output) ? (matrixC110 + matrixC110_accum) : matrixC110;
assign matrixC111_added = (add_accum_to_output) ? (matrixC111 + matrixC111_accum) : matrixC111;
assign matrixC112_added = (add_accum_to_output) ? (matrixC112 + matrixC112_accum) : matrixC112;
assign matrixC113_added = (add_accum_to_output) ? (matrixC113 + matrixC113_accum) : matrixC113;
assign matrixC114_added = (add_accum_to_output) ? (matrixC114 + matrixC114_accum) : matrixC114;
assign matrixC115_added = (add_accum_to_output) ? (matrixC115 + matrixC115_accum) : matrixC115;
assign matrixC20_added = (add_accum_to_output) ? (matrixC20 + matrixC20_accum) : matrixC20;
assign matrixC21_added = (add_accum_to_output) ? (matrixC21 + matrixC21_accum) : matrixC21;
assign matrixC22_added = (add_accum_to_output) ? (matrixC22 + matrixC22_accum) : matrixC22;
assign matrixC23_added = (add_accum_to_output) ? (matrixC23 + matrixC23_accum) : matrixC23;
assign matrixC24_added = (add_accum_to_output) ? (matrixC24 + matrixC24_accum) : matrixC24;
assign matrixC25_added = (add_accum_to_output) ? (matrixC25 + matrixC25_accum) : matrixC25;
assign matrixC26_added = (add_accum_to_output) ? (matrixC26 + matrixC26_accum) : matrixC26;
assign matrixC27_added = (add_accum_to_output) ? (matrixC27 + matrixC27_accum) : matrixC27;
assign matrixC28_added = (add_accum_to_output) ? (matrixC28 + matrixC28_accum) : matrixC28;
assign matrixC29_added = (add_accum_to_output) ? (matrixC29 + matrixC29_accum) : matrixC29;
assign matrixC210_added = (add_accum_to_output) ? (matrixC210 + matrixC210_accum) : matrixC210;
assign matrixC211_added = (add_accum_to_output) ? (matrixC211 + matrixC211_accum) : matrixC211;
assign matrixC212_added = (add_accum_to_output) ? (matrixC212 + matrixC212_accum) : matrixC212;
assign matrixC213_added = (add_accum_to_output) ? (matrixC213 + matrixC213_accum) : matrixC213;
assign matrixC214_added = (add_accum_to_output) ? (matrixC214 + matrixC214_accum) : matrixC214;
assign matrixC215_added = (add_accum_to_output) ? (matrixC215 + matrixC215_accum) : matrixC215;
assign matrixC30_added = (add_accum_to_output) ? (matrixC30 + matrixC30_accum) : matrixC30;
assign matrixC31_added = (add_accum_to_output) ? (matrixC31 + matrixC31_accum) : matrixC31;
assign matrixC32_added = (add_accum_to_output) ? (matrixC32 + matrixC32_accum) : matrixC32;
assign matrixC33_added = (add_accum_to_output) ? (matrixC33 + matrixC33_accum) : matrixC33;
assign matrixC34_added = (add_accum_to_output) ? (matrixC34 + matrixC34_accum) : matrixC34;
assign matrixC35_added = (add_accum_to_output) ? (matrixC35 + matrixC35_accum) : matrixC35;
assign matrixC36_added = (add_accum_to_output) ? (matrixC36 + matrixC36_accum) : matrixC36;
assign matrixC37_added = (add_accum_to_output) ? (matrixC37 + matrixC37_accum) : matrixC37;
assign matrixC38_added = (add_accum_to_output) ? (matrixC38 + matrixC38_accum) : matrixC38;
assign matrixC39_added = (add_accum_to_output) ? (matrixC39 + matrixC39_accum) : matrixC39;
assign matrixC310_added = (add_accum_to_output) ? (matrixC310 + matrixC310_accum) : matrixC310;
assign matrixC311_added = (add_accum_to_output) ? (matrixC311 + matrixC311_accum) : matrixC311;
assign matrixC312_added = (add_accum_to_output) ? (matrixC312 + matrixC312_accum) : matrixC312;
assign matrixC313_added = (add_accum_to_output) ? (matrixC313 + matrixC313_accum) : matrixC313;
assign matrixC314_added = (add_accum_to_output) ? (matrixC314 + matrixC314_accum) : matrixC314;
assign matrixC315_added = (add_accum_to_output) ? (matrixC315 + matrixC315_accum) : matrixC315;
assign matrixC40_added = (add_accum_to_output) ? (matrixC40 + matrixC40_accum) : matrixC40;
assign matrixC41_added = (add_accum_to_output) ? (matrixC41 + matrixC41_accum) : matrixC41;
assign matrixC42_added = (add_accum_to_output) ? (matrixC42 + matrixC42_accum) : matrixC42;
assign matrixC43_added = (add_accum_to_output) ? (matrixC43 + matrixC43_accum) : matrixC43;
assign matrixC44_added = (add_accum_to_output) ? (matrixC44 + matrixC44_accum) : matrixC44;
assign matrixC45_added = (add_accum_to_output) ? (matrixC45 + matrixC45_accum) : matrixC45;
assign matrixC46_added = (add_accum_to_output) ? (matrixC46 + matrixC46_accum) : matrixC46;
assign matrixC47_added = (add_accum_to_output) ? (matrixC47 + matrixC47_accum) : matrixC47;
assign matrixC48_added = (add_accum_to_output) ? (matrixC48 + matrixC48_accum) : matrixC48;
assign matrixC49_added = (add_accum_to_output) ? (matrixC49 + matrixC49_accum) : matrixC49;
assign matrixC410_added = (add_accum_to_output) ? (matrixC410 + matrixC410_accum) : matrixC410;
assign matrixC411_added = (add_accum_to_output) ? (matrixC411 + matrixC411_accum) : matrixC411;
assign matrixC412_added = (add_accum_to_output) ? (matrixC412 + matrixC412_accum) : matrixC412;
assign matrixC413_added = (add_accum_to_output) ? (matrixC413 + matrixC413_accum) : matrixC413;
assign matrixC414_added = (add_accum_to_output) ? (matrixC414 + matrixC414_accum) : matrixC414;
assign matrixC415_added = (add_accum_to_output) ? (matrixC415 + matrixC415_accum) : matrixC415;
assign matrixC50_added = (add_accum_to_output) ? (matrixC50 + matrixC50_accum) : matrixC50;
assign matrixC51_added = (add_accum_to_output) ? (matrixC51 + matrixC51_accum) : matrixC51;
assign matrixC52_added = (add_accum_to_output) ? (matrixC52 + matrixC52_accum) : matrixC52;
assign matrixC53_added = (add_accum_to_output) ? (matrixC53 + matrixC53_accum) : matrixC53;
assign matrixC54_added = (add_accum_to_output) ? (matrixC54 + matrixC54_accum) : matrixC54;
assign matrixC55_added = (add_accum_to_output) ? (matrixC55 + matrixC55_accum) : matrixC55;
assign matrixC56_added = (add_accum_to_output) ? (matrixC56 + matrixC56_accum) : matrixC56;
assign matrixC57_added = (add_accum_to_output) ? (matrixC57 + matrixC57_accum) : matrixC57;
assign matrixC58_added = (add_accum_to_output) ? (matrixC58 + matrixC58_accum) : matrixC58;
assign matrixC59_added = (add_accum_to_output) ? (matrixC59 + matrixC59_accum) : matrixC59;
assign matrixC510_added = (add_accum_to_output) ? (matrixC510 + matrixC510_accum) : matrixC510;
assign matrixC511_added = (add_accum_to_output) ? (matrixC511 + matrixC511_accum) : matrixC511;
assign matrixC512_added = (add_accum_to_output) ? (matrixC512 + matrixC512_accum) : matrixC512;
assign matrixC513_added = (add_accum_to_output) ? (matrixC513 + matrixC513_accum) : matrixC513;
assign matrixC514_added = (add_accum_to_output) ? (matrixC514 + matrixC514_accum) : matrixC514;
assign matrixC515_added = (add_accum_to_output) ? (matrixC515 + matrixC515_accum) : matrixC515;
assign matrixC60_added = (add_accum_to_output) ? (matrixC60 + matrixC60_accum) : matrixC60;
assign matrixC61_added = (add_accum_to_output) ? (matrixC61 + matrixC61_accum) : matrixC61;
assign matrixC62_added = (add_accum_to_output) ? (matrixC62 + matrixC62_accum) : matrixC62;
assign matrixC63_added = (add_accum_to_output) ? (matrixC63 + matrixC63_accum) : matrixC63;
assign matrixC64_added = (add_accum_to_output) ? (matrixC64 + matrixC64_accum) : matrixC64;
assign matrixC65_added = (add_accum_to_output) ? (matrixC65 + matrixC65_accum) : matrixC65;
assign matrixC66_added = (add_accum_to_output) ? (matrixC66 + matrixC66_accum) : matrixC66;
assign matrixC67_added = (add_accum_to_output) ? (matrixC67 + matrixC67_accum) : matrixC67;
assign matrixC68_added = (add_accum_to_output) ? (matrixC68 + matrixC68_accum) : matrixC68;
assign matrixC69_added = (add_accum_to_output) ? (matrixC69 + matrixC69_accum) : matrixC69;
assign matrixC610_added = (add_accum_to_output) ? (matrixC610 + matrixC610_accum) : matrixC610;
assign matrixC611_added = (add_accum_to_output) ? (matrixC611 + matrixC611_accum) : matrixC611;
assign matrixC612_added = (add_accum_to_output) ? (matrixC612 + matrixC612_accum) : matrixC612;
assign matrixC613_added = (add_accum_to_output) ? (matrixC613 + matrixC613_accum) : matrixC613;
assign matrixC614_added = (add_accum_to_output) ? (matrixC614 + matrixC614_accum) : matrixC614;
assign matrixC615_added = (add_accum_to_output) ? (matrixC615 + matrixC615_accum) : matrixC615;
assign matrixC70_added = (add_accum_to_output) ? (matrixC70 + matrixC70_accum) : matrixC70;
assign matrixC71_added = (add_accum_to_output) ? (matrixC71 + matrixC71_accum) : matrixC71;
assign matrixC72_added = (add_accum_to_output) ? (matrixC72 + matrixC72_accum) : matrixC72;
assign matrixC73_added = (add_accum_to_output) ? (matrixC73 + matrixC73_accum) : matrixC73;
assign matrixC74_added = (add_accum_to_output) ? (matrixC74 + matrixC74_accum) : matrixC74;
assign matrixC75_added = (add_accum_to_output) ? (matrixC75 + matrixC75_accum) : matrixC75;
assign matrixC76_added = (add_accum_to_output) ? (matrixC76 + matrixC76_accum) : matrixC76;
assign matrixC77_added = (add_accum_to_output) ? (matrixC77 + matrixC77_accum) : matrixC77;
assign matrixC78_added = (add_accum_to_output) ? (matrixC78 + matrixC78_accum) : matrixC78;
assign matrixC79_added = (add_accum_to_output) ? (matrixC79 + matrixC79_accum) : matrixC79;
assign matrixC710_added = (add_accum_to_output) ? (matrixC710 + matrixC710_accum) : matrixC710;
assign matrixC711_added = (add_accum_to_output) ? (matrixC711 + matrixC711_accum) : matrixC711;
assign matrixC712_added = (add_accum_to_output) ? (matrixC712 + matrixC712_accum) : matrixC712;
assign matrixC713_added = (add_accum_to_output) ? (matrixC713 + matrixC713_accum) : matrixC713;
assign matrixC714_added = (add_accum_to_output) ? (matrixC714 + matrixC714_accum) : matrixC714;
assign matrixC715_added = (add_accum_to_output) ? (matrixC715 + matrixC715_accum) : matrixC715;
assign matrixC80_added = (add_accum_to_output) ? (matrixC80 + matrixC80_accum) : matrixC80;
assign matrixC81_added = (add_accum_to_output) ? (matrixC81 + matrixC81_accum) : matrixC81;
assign matrixC82_added = (add_accum_to_output) ? (matrixC82 + matrixC82_accum) : matrixC82;
assign matrixC83_added = (add_accum_to_output) ? (matrixC83 + matrixC83_accum) : matrixC83;
assign matrixC84_added = (add_accum_to_output) ? (matrixC84 + matrixC84_accum) : matrixC84;
assign matrixC85_added = (add_accum_to_output) ? (matrixC85 + matrixC85_accum) : matrixC85;
assign matrixC86_added = (add_accum_to_output) ? (matrixC86 + matrixC86_accum) : matrixC86;
assign matrixC87_added = (add_accum_to_output) ? (matrixC87 + matrixC87_accum) : matrixC87;
assign matrixC88_added = (add_accum_to_output) ? (matrixC88 + matrixC88_accum) : matrixC88;
assign matrixC89_added = (add_accum_to_output) ? (matrixC89 + matrixC89_accum) : matrixC89;
assign matrixC810_added = (add_accum_to_output) ? (matrixC810 + matrixC810_accum) : matrixC810;
assign matrixC811_added = (add_accum_to_output) ? (matrixC811 + matrixC811_accum) : matrixC811;
assign matrixC812_added = (add_accum_to_output) ? (matrixC812 + matrixC812_accum) : matrixC812;
assign matrixC813_added = (add_accum_to_output) ? (matrixC813 + matrixC813_accum) : matrixC813;
assign matrixC814_added = (add_accum_to_output) ? (matrixC814 + matrixC814_accum) : matrixC814;
assign matrixC815_added = (add_accum_to_output) ? (matrixC815 + matrixC815_accum) : matrixC815;
assign matrixC90_added = (add_accum_to_output) ? (matrixC90 + matrixC90_accum) : matrixC90;
assign matrixC91_added = (add_accum_to_output) ? (matrixC91 + matrixC91_accum) : matrixC91;
assign matrixC92_added = (add_accum_to_output) ? (matrixC92 + matrixC92_accum) : matrixC92;
assign matrixC93_added = (add_accum_to_output) ? (matrixC93 + matrixC93_accum) : matrixC93;
assign matrixC94_added = (add_accum_to_output) ? (matrixC94 + matrixC94_accum) : matrixC94;
assign matrixC95_added = (add_accum_to_output) ? (matrixC95 + matrixC95_accum) : matrixC95;
assign matrixC96_added = (add_accum_to_output) ? (matrixC96 + matrixC96_accum) : matrixC96;
assign matrixC97_added = (add_accum_to_output) ? (matrixC97 + matrixC97_accum) : matrixC97;
assign matrixC98_added = (add_accum_to_output) ? (matrixC98 + matrixC98_accum) : matrixC98;
assign matrixC99_added = (add_accum_to_output) ? (matrixC99 + matrixC99_accum) : matrixC99;
assign matrixC910_added = (add_accum_to_output) ? (matrixC910 + matrixC910_accum) : matrixC910;
assign matrixC911_added = (add_accum_to_output) ? (matrixC911 + matrixC911_accum) : matrixC911;
assign matrixC912_added = (add_accum_to_output) ? (matrixC912 + matrixC912_accum) : matrixC912;
assign matrixC913_added = (add_accum_to_output) ? (matrixC913 + matrixC913_accum) : matrixC913;
assign matrixC914_added = (add_accum_to_output) ? (matrixC914 + matrixC914_accum) : matrixC914;
assign matrixC915_added = (add_accum_to_output) ? (matrixC915 + matrixC915_accum) : matrixC915;
assign matrixC100_added = (add_accum_to_output) ? (matrixC100 + matrixC100_accum) : matrixC100;
assign matrixC101_added = (add_accum_to_output) ? (matrixC101 + matrixC101_accum) : matrixC101;
assign matrixC102_added = (add_accum_to_output) ? (matrixC102 + matrixC102_accum) : matrixC102;
assign matrixC103_added = (add_accum_to_output) ? (matrixC103 + matrixC103_accum) : matrixC103;
assign matrixC104_added = (add_accum_to_output) ? (matrixC104 + matrixC104_accum) : matrixC104;
assign matrixC105_added = (add_accum_to_output) ? (matrixC105 + matrixC105_accum) : matrixC105;
assign matrixC106_added = (add_accum_to_output) ? (matrixC106 + matrixC106_accum) : matrixC106;
assign matrixC107_added = (add_accum_to_output) ? (matrixC107 + matrixC107_accum) : matrixC107;
assign matrixC108_added = (add_accum_to_output) ? (matrixC108 + matrixC108_accum) : matrixC108;
assign matrixC109_added = (add_accum_to_output) ? (matrixC109 + matrixC109_accum) : matrixC109;
assign matrixC1010_added = (add_accum_to_output) ? (matrixC1010 + matrixC1010_accum) : matrixC1010;
assign matrixC1011_added = (add_accum_to_output) ? (matrixC1011 + matrixC1011_accum) : matrixC1011;
assign matrixC1012_added = (add_accum_to_output) ? (matrixC1012 + matrixC1012_accum) : matrixC1012;
assign matrixC1013_added = (add_accum_to_output) ? (matrixC1013 + matrixC1013_accum) : matrixC1013;
assign matrixC1014_added = (add_accum_to_output) ? (matrixC1014 + matrixC1014_accum) : matrixC1014;
assign matrixC1015_added = (add_accum_to_output) ? (matrixC1015 + matrixC1015_accum) : matrixC1015;
assign matrixC110_added = (add_accum_to_output) ? (matrixC110 + matrixC110_accum) : matrixC110;
assign matrixC111_added = (add_accum_to_output) ? (matrixC111 + matrixC111_accum) : matrixC111;
assign matrixC112_added = (add_accum_to_output) ? (matrixC112 + matrixC112_accum) : matrixC112;
assign matrixC113_added = (add_accum_to_output) ? (matrixC113 + matrixC113_accum) : matrixC113;
assign matrixC114_added = (add_accum_to_output) ? (matrixC114 + matrixC114_accum) : matrixC114;
assign matrixC115_added = (add_accum_to_output) ? (matrixC115 + matrixC115_accum) : matrixC115;
assign matrixC116_added = (add_accum_to_output) ? (matrixC116 + matrixC116_accum) : matrixC116;
assign matrixC117_added = (add_accum_to_output) ? (matrixC117 + matrixC117_accum) : matrixC117;
assign matrixC118_added = (add_accum_to_output) ? (matrixC118 + matrixC118_accum) : matrixC118;
assign matrixC119_added = (add_accum_to_output) ? (matrixC119 + matrixC119_accum) : matrixC119;
assign matrixC1110_added = (add_accum_to_output) ? (matrixC1110 + matrixC1110_accum) : matrixC1110;
assign matrixC1111_added = (add_accum_to_output) ? (matrixC1111 + matrixC1111_accum) : matrixC1111;
assign matrixC1112_added = (add_accum_to_output) ? (matrixC1112 + matrixC1112_accum) : matrixC1112;
assign matrixC1113_added = (add_accum_to_output) ? (matrixC1113 + matrixC1113_accum) : matrixC1113;
assign matrixC1114_added = (add_accum_to_output) ? (matrixC1114 + matrixC1114_accum) : matrixC1114;
assign matrixC1115_added = (add_accum_to_output) ? (matrixC1115 + matrixC1115_accum) : matrixC1115;
assign matrixC120_added = (add_accum_to_output) ? (matrixC120 + matrixC120_accum) : matrixC120;
assign matrixC121_added = (add_accum_to_output) ? (matrixC121 + matrixC121_accum) : matrixC121;
assign matrixC122_added = (add_accum_to_output) ? (matrixC122 + matrixC122_accum) : matrixC122;
assign matrixC123_added = (add_accum_to_output) ? (matrixC123 + matrixC123_accum) : matrixC123;
assign matrixC124_added = (add_accum_to_output) ? (matrixC124 + matrixC124_accum) : matrixC124;
assign matrixC125_added = (add_accum_to_output) ? (matrixC125 + matrixC125_accum) : matrixC125;
assign matrixC126_added = (add_accum_to_output) ? (matrixC126 + matrixC126_accum) : matrixC126;
assign matrixC127_added = (add_accum_to_output) ? (matrixC127 + matrixC127_accum) : matrixC127;
assign matrixC128_added = (add_accum_to_output) ? (matrixC128 + matrixC128_accum) : matrixC128;
assign matrixC129_added = (add_accum_to_output) ? (matrixC129 + matrixC129_accum) : matrixC129;
assign matrixC1210_added = (add_accum_to_output) ? (matrixC1210 + matrixC1210_accum) : matrixC1210;
assign matrixC1211_added = (add_accum_to_output) ? (matrixC1211 + matrixC1211_accum) : matrixC1211;
assign matrixC1212_added = (add_accum_to_output) ? (matrixC1212 + matrixC1212_accum) : matrixC1212;
assign matrixC1213_added = (add_accum_to_output) ? (matrixC1213 + matrixC1213_accum) : matrixC1213;
assign matrixC1214_added = (add_accum_to_output) ? (matrixC1214 + matrixC1214_accum) : matrixC1214;
assign matrixC1215_added = (add_accum_to_output) ? (matrixC1215 + matrixC1215_accum) : matrixC1215;
assign matrixC130_added = (add_accum_to_output) ? (matrixC130 + matrixC130_accum) : matrixC130;
assign matrixC131_added = (add_accum_to_output) ? (matrixC131 + matrixC131_accum) : matrixC131;
assign matrixC132_added = (add_accum_to_output) ? (matrixC132 + matrixC132_accum) : matrixC132;
assign matrixC133_added = (add_accum_to_output) ? (matrixC133 + matrixC133_accum) : matrixC133;
assign matrixC134_added = (add_accum_to_output) ? (matrixC134 + matrixC134_accum) : matrixC134;
assign matrixC135_added = (add_accum_to_output) ? (matrixC135 + matrixC135_accum) : matrixC135;
assign matrixC136_added = (add_accum_to_output) ? (matrixC136 + matrixC136_accum) : matrixC136;
assign matrixC137_added = (add_accum_to_output) ? (matrixC137 + matrixC137_accum) : matrixC137;
assign matrixC138_added = (add_accum_to_output) ? (matrixC138 + matrixC138_accum) : matrixC138;
assign matrixC139_added = (add_accum_to_output) ? (matrixC139 + matrixC139_accum) : matrixC139;
assign matrixC1310_added = (add_accum_to_output) ? (matrixC1310 + matrixC1310_accum) : matrixC1310;
assign matrixC1311_added = (add_accum_to_output) ? (matrixC1311 + matrixC1311_accum) : matrixC1311;
assign matrixC1312_added = (add_accum_to_output) ? (matrixC1312 + matrixC1312_accum) : matrixC1312;
assign matrixC1313_added = (add_accum_to_output) ? (matrixC1313 + matrixC1313_accum) : matrixC1313;
assign matrixC1314_added = (add_accum_to_output) ? (matrixC1314 + matrixC1314_accum) : matrixC1314;
assign matrixC1315_added = (add_accum_to_output) ? (matrixC1315 + matrixC1315_accum) : matrixC1315;
assign matrixC140_added = (add_accum_to_output) ? (matrixC140 + matrixC140_accum) : matrixC140;
assign matrixC141_added = (add_accum_to_output) ? (matrixC141 + matrixC141_accum) : matrixC141;
assign matrixC142_added = (add_accum_to_output) ? (matrixC142 + matrixC142_accum) : matrixC142;
assign matrixC143_added = (add_accum_to_output) ? (matrixC143 + matrixC143_accum) : matrixC143;
assign matrixC144_added = (add_accum_to_output) ? (matrixC144 + matrixC144_accum) : matrixC144;
assign matrixC145_added = (add_accum_to_output) ? (matrixC145 + matrixC145_accum) : matrixC145;
assign matrixC146_added = (add_accum_to_output) ? (matrixC146 + matrixC146_accum) : matrixC146;
assign matrixC147_added = (add_accum_to_output) ? (matrixC147 + matrixC147_accum) : matrixC147;
assign matrixC148_added = (add_accum_to_output) ? (matrixC148 + matrixC148_accum) : matrixC148;
assign matrixC149_added = (add_accum_to_output) ? (matrixC149 + matrixC149_accum) : matrixC149;
assign matrixC1410_added = (add_accum_to_output) ? (matrixC1410 + matrixC1410_accum) : matrixC1410;
assign matrixC1411_added = (add_accum_to_output) ? (matrixC1411 + matrixC1411_accum) : matrixC1411;
assign matrixC1412_added = (add_accum_to_output) ? (matrixC1412 + matrixC1412_accum) : matrixC1412;
assign matrixC1413_added = (add_accum_to_output) ? (matrixC1413 + matrixC1413_accum) : matrixC1413;
assign matrixC1414_added = (add_accum_to_output) ? (matrixC1414 + matrixC1414_accum) : matrixC1414;
assign matrixC1415_added = (add_accum_to_output) ? (matrixC1415 + matrixC1415_accum) : matrixC1415;
assign matrixC150_added = (add_accum_to_output) ? (matrixC150 + matrixC150_accum) : matrixC150;
assign matrixC151_added = (add_accum_to_output) ? (matrixC151 + matrixC151_accum) : matrixC151;
assign matrixC152_added = (add_accum_to_output) ? (matrixC152 + matrixC152_accum) : matrixC152;
assign matrixC153_added = (add_accum_to_output) ? (matrixC153 + matrixC153_accum) : matrixC153;
assign matrixC154_added = (add_accum_to_output) ? (matrixC154 + matrixC154_accum) : matrixC154;
assign matrixC155_added = (add_accum_to_output) ? (matrixC155 + matrixC155_accum) : matrixC155;
assign matrixC156_added = (add_accum_to_output) ? (matrixC156 + matrixC156_accum) : matrixC156;
assign matrixC157_added = (add_accum_to_output) ? (matrixC157 + matrixC157_accum) : matrixC157;
assign matrixC158_added = (add_accum_to_output) ? (matrixC158 + matrixC158_accum) : matrixC158;
assign matrixC159_added = (add_accum_to_output) ? (matrixC159 + matrixC159_accum) : matrixC159;
assign matrixC1510_added = (add_accum_to_output) ? (matrixC1510 + matrixC1510_accum) : matrixC1510;
assign matrixC1511_added = (add_accum_to_output) ? (matrixC1511 + matrixC1511_accum) : matrixC1511;
assign matrixC1512_added = (add_accum_to_output) ? (matrixC1512 + matrixC1512_accum) : matrixC1512;
assign matrixC1513_added = (add_accum_to_output) ? (matrixC1513 + matrixC1513_accum) : matrixC1513;
assign matrixC1514_added = (add_accum_to_output) ? (matrixC1514 + matrixC1514_accum) : matrixC1514;
assign matrixC1515_added = (add_accum_to_output) ? (matrixC1515 + matrixC1515_accum) : matrixC1515;

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
reg [16*`DWIDTH-1:0] c_data_out;

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
    c_data_out <= {matrixC150_added, matrixC140_added, matrixC130_added, matrixC120_added, matrixC110_added, matrixC100_added, matrixC90_added, matrixC80_added, matrixC70_added, matrixC60_added, matrixC50_added, matrixC40_added, matrixC30_added, matrixC20_added, matrixC10_added, matrixC00_added};

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
    		1: c_data_out <= {matrixC151_added, matrixC141_added, matrixC131_added, matrixC121_added, matrixC111_added, matrixC101_added, matrixC91_added, matrixC81_added, matrixC71_added, matrixC61_added, matrixC51_added, matrixC41_added, matrixC31_added, matrixC21_added, matrixC11_added, matrixC01_added};
		2: c_data_out <= {matrixC152_added, matrixC142_added, matrixC132_added, matrixC122_added, matrixC112_added, matrixC102_added, matrixC92_added, matrixC82_added, matrixC72_added, matrixC62_added, matrixC52_added, matrixC42_added, matrixC32_added, matrixC22_added, matrixC12_added, matrixC02_added};
		3: c_data_out <= {matrixC153_added, matrixC143_added, matrixC133_added, matrixC123_added, matrixC113_added, matrixC103_added, matrixC93_added, matrixC83_added, matrixC73_added, matrixC63_added, matrixC53_added, matrixC43_added, matrixC33_added, matrixC23_added, matrixC13_added, matrixC03_added};
		4: c_data_out <= {matrixC154_added, matrixC144_added, matrixC134_added, matrixC124_added, matrixC114_added, matrixC104_added, matrixC94_added, matrixC84_added, matrixC74_added, matrixC64_added, matrixC54_added, matrixC44_added, matrixC34_added, matrixC24_added, matrixC14_added, matrixC04_added};
		5: c_data_out <= {matrixC155_added, matrixC145_added, matrixC135_added, matrixC125_added, matrixC115_added, matrixC105_added, matrixC95_added, matrixC85_added, matrixC75_added, matrixC65_added, matrixC55_added, matrixC45_added, matrixC35_added, matrixC25_added, matrixC15_added, matrixC05_added};
		6: c_data_out <= {matrixC156_added, matrixC146_added, matrixC136_added, matrixC126_added, matrixC116_added, matrixC106_added, matrixC96_added, matrixC86_added, matrixC76_added, matrixC66_added, matrixC56_added, matrixC46_added, matrixC36_added, matrixC26_added, matrixC16_added, matrixC06_added};
		7: c_data_out <= {matrixC157_added, matrixC147_added, matrixC137_added, matrixC127_added, matrixC117_added, matrixC107_added, matrixC97_added, matrixC87_added, matrixC77_added, matrixC67_added, matrixC57_added, matrixC47_added, matrixC37_added, matrixC27_added, matrixC17_added, matrixC07_added};
		8: c_data_out <= {matrixC158_added, matrixC148_added, matrixC138_added, matrixC128_added, matrixC118_added, matrixC108_added, matrixC98_added, matrixC88_added, matrixC78_added, matrixC68_added, matrixC58_added, matrixC48_added, matrixC38_added, matrixC28_added, matrixC18_added, matrixC08_added};
		9: c_data_out <= {matrixC159_added, matrixC149_added, matrixC139_added, matrixC129_added, matrixC119_added, matrixC109_added, matrixC99_added, matrixC89_added, matrixC79_added, matrixC69_added, matrixC59_added, matrixC49_added, matrixC39_added, matrixC29_added, matrixC19_added, matrixC09_added};
		10: c_data_out <= {matrixC1510_added, matrixC1410_added, matrixC1310_added, matrixC1210_added, matrixC1110_added, matrixC1010_added, matrixC910_added, matrixC810_added, matrixC710_added, matrixC610_added, matrixC510_added, matrixC410_added, matrixC310_added, matrixC210_added, matrixC110_added, matrixC010_added};
		11: c_data_out <= {matrixC1511_added, matrixC1411_added, matrixC1311_added, matrixC1211_added, matrixC1111_added, matrixC1011_added, matrixC911_added, matrixC811_added, matrixC711_added, matrixC611_added, matrixC511_added, matrixC411_added, matrixC311_added, matrixC211_added, matrixC111_added, matrixC011_added};
		12: c_data_out <= {matrixC1512_added, matrixC1412_added, matrixC1312_added, matrixC1212_added, matrixC1112_added, matrixC1012_added, matrixC912_added, matrixC812_added, matrixC712_added, matrixC612_added, matrixC512_added, matrixC412_added, matrixC312_added, matrixC212_added, matrixC112_added, matrixC012_added};
		13: c_data_out <= {matrixC1513_added, matrixC1413_added, matrixC1313_added, matrixC1213_added, matrixC1113_added, matrixC1013_added, matrixC913_added, matrixC813_added, matrixC713_added, matrixC613_added, matrixC513_added, matrixC413_added, matrixC313_added, matrixC213_added, matrixC113_added, matrixC013_added};
		14: c_data_out <= {matrixC1514_added, matrixC1414_added, matrixC1314_added, matrixC1214_added, matrixC1114_added, matrixC1014_added, matrixC914_added, matrixC814_added, matrixC714_added, matrixC614_added, matrixC514_added, matrixC414_added, matrixC314_added, matrixC214_added, matrixC114_added, matrixC014_added};
		15: c_data_out <= {matrixC1515_added, matrixC1415_added, matrixC1315_added, matrixC1215_added, matrixC1115_added, matrixC1015_added, matrixC915_added, matrixC815_added, matrixC715_added, matrixC615_added, matrixC515_added, matrixC415_added, matrixC315_added, matrixC215_added, matrixC115_added, matrixC015_added};

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

processing_element pe00(.reset(effective_rst), .clk(clk),  .in_a(a0),      .in_b(b0),  .out_a(a00to01), .out_b(b00to10), .out_c(matrixC00));
processing_element pe01(.reset(effective_rst), .clk(clk),  .in_a(a00to01), .in_b(b1),  .out_a(a01to02), .out_b(b01to11), .out_c(matrixC01));
processing_element pe02(.reset(effective_rst), .clk(clk),  .in_a(a01to02), .in_b(b2),  .out_a(a02to03), .out_b(b02to12), .out_c(matrixC02));
processing_element pe03(.reset(effective_rst), .clk(clk),  .in_a(a02to03), .in_b(b3),  .out_a(a03to04), .out_b(b03to13), .out_c(matrixC03));
processing_element pe04(.reset(effective_rst), .clk(clk),  .in_a(a03to04), .in_b(b4),  .out_a(a04to05), .out_b(b04to14), .out_c(matrixC04));
processing_element pe05(.reset(effective_rst), .clk(clk),  .in_a(a04to05), .in_b(b5),  .out_a(a05to06), .out_b(b05to15), .out_c(matrixC05));
processing_element pe06(.reset(effective_rst), .clk(clk),  .in_a(a05to06), .in_b(b6),  .out_a(a06to07), .out_b(b06to16), .out_c(matrixC06));
processing_element pe07(.reset(effective_rst), .clk(clk),  .in_a(a06to07), .in_b(b7),  .out_a(a07to08), .out_b(b07to17), .out_c(matrixC07));
processing_element pe08(.reset(effective_rst), .clk(clk),  .in_a(a07to08), .in_b(b8),  .out_a(a08to09), .out_b(b08to18), .out_c(matrixC08));
processing_element pe09(.reset(effective_rst), .clk(clk),  .in_a(a08to09), .in_b(b9),  .out_a(a09to010), .out_b(b09to19), .out_c(matrixC09));
processing_element pe010(.reset(effective_rst), .clk(clk),  .in_a(a09to010), .in_b(b10),  .out_a(a010to011), .out_b(b010to110), .out_c(matrixC010));
processing_element pe011(.reset(effective_rst), .clk(clk),  .in_a(a010to011), .in_b(b11),  .out_a(a011to012), .out_b(b011to111), .out_c(matrixC011));
processing_element pe012(.reset(effective_rst), .clk(clk),  .in_a(a011to012), .in_b(b12),  .out_a(a012to013), .out_b(b012to112), .out_c(matrixC012));
processing_element pe013(.reset(effective_rst), .clk(clk),  .in_a(a012to013), .in_b(b13),  .out_a(a013to014), .out_b(b013to113), .out_c(matrixC013));
processing_element pe014(.reset(effective_rst), .clk(clk),  .in_a(a013to014), .in_b(b14),  .out_a(a014to015), .out_b(b014to114), .out_c(matrixC014));
processing_element pe015(.reset(effective_rst), .clk(clk),  .in_a(a014to015), .in_b(b15),  .out_a(a015to016), .out_b(b015to115), .out_c(matrixC015));

processing_element pe10(.reset(effective_rst), .clk(clk),  .in_a(a1), .in_b(b00to10),  .out_a(a10to11), .out_b(b10to20), .out_c(matrixC10));
processing_element pe20(.reset(effective_rst), .clk(clk),  .in_a(a2), .in_b(b10to20),  .out_a(a20to21), .out_b(b20to30), .out_c(matrixC20));
processing_element pe30(.reset(effective_rst), .clk(clk),  .in_a(a3), .in_b(b20to30),  .out_a(a30to31), .out_b(b30to40), .out_c(matrixC30));
processing_element pe40(.reset(effective_rst), .clk(clk),  .in_a(a4), .in_b(b30to40),  .out_a(a40to41), .out_b(b40to50), .out_c(matrixC40));
processing_element pe50(.reset(effective_rst), .clk(clk),  .in_a(a5), .in_b(b40to50),  .out_a(a50to51), .out_b(b50to60), .out_c(matrixC50));
processing_element pe60(.reset(effective_rst), .clk(clk),  .in_a(a6), .in_b(b50to60),  .out_a(a60to61), .out_b(b60to70), .out_c(matrixC60));
processing_element pe70(.reset(effective_rst), .clk(clk),  .in_a(a7), .in_b(b60to70),  .out_a(a70to71), .out_b(b70to80), .out_c(matrixC70));
processing_element pe80(.reset(effective_rst), .clk(clk),  .in_a(a8), .in_b(b70to80),  .out_a(a80to81), .out_b(b80to90), .out_c(matrixC80));
processing_element pe90(.reset(effective_rst), .clk(clk),  .in_a(a9), .in_b(b80to90),  .out_a(a90to91), .out_b(b90to100), .out_c(matrixC90));
processing_element pe100(.reset(effective_rst), .clk(clk),  .in_a(a10), .in_b(b90to100),  .out_a(a100to101), .out_b(b100to110), .out_c(matrixC100));
processing_element pe110(.reset(effective_rst), .clk(clk),  .in_a(a11), .in_b(b100to110),  .out_a(a110to111), .out_b(b110to120), .out_c(matrixC110));
processing_element pe120(.reset(effective_rst), .clk(clk),  .in_a(a12), .in_b(b110to120),  .out_a(a120to121), .out_b(b120to130), .out_c(matrixC120));
processing_element pe130(.reset(effective_rst), .clk(clk),  .in_a(a13), .in_b(b120to130),  .out_a(a130to131), .out_b(b130to140), .out_c(matrixC130));
processing_element pe140(.reset(effective_rst), .clk(clk),  .in_a(a14), .in_b(b130to140),  .out_a(a140to141), .out_b(b140to150), .out_c(matrixC140));
processing_element pe150(.reset(effective_rst), .clk(clk),  .in_a(a15), .in_b(b140to150),  .out_a(a150to151), .out_b(b150to160), .out_c(matrixC150));

processing_element pe11(.reset(effective_rst), .clk(clk),  .in_a(a10to11), .in_b(b01to11),  .out_a(a11to12), .out_b(b11to21), .out_c(matrixC11));
processing_element pe12(.reset(effective_rst), .clk(clk),  .in_a(a11to12), .in_b(b02to12),  .out_a(a12to13), .out_b(b12to22), .out_c(matrixC12));
processing_element pe13(.reset(effective_rst), .clk(clk),  .in_a(a12to13), .in_b(b03to13),  .out_a(a13to14), .out_b(b13to23), .out_c(matrixC13));
processing_element pe14(.reset(effective_rst), .clk(clk),  .in_a(a13to14), .in_b(b04to14),  .out_a(a14to15), .out_b(b14to24), .out_c(matrixC14));
processing_element pe15(.reset(effective_rst), .clk(clk),  .in_a(a14to15), .in_b(b05to15),  .out_a(a15to16), .out_b(b15to25), .out_c(matrixC15));
processing_element pe16(.reset(effective_rst), .clk(clk),  .in_a(a15to16), .in_b(b06to16),  .out_a(a16to17), .out_b(b16to26), .out_c(matrixC16));
processing_element pe17(.reset(effective_rst), .clk(clk),  .in_a(a16to17), .in_b(b07to17),  .out_a(a17to18), .out_b(b17to27), .out_c(matrixC17));
processing_element pe18(.reset(effective_rst), .clk(clk),  .in_a(a17to18), .in_b(b08to18),  .out_a(a18to19), .out_b(b18to28), .out_c(matrixC18));
processing_element pe19(.reset(effective_rst), .clk(clk),  .in_a(a18to19), .in_b(b09to19),  .out_a(a19to110), .out_b(b19to29), .out_c(matrixC19));
processing_element pe110(.reset(effective_rst), .clk(clk),  .in_a(a19to110), .in_b(b010to110),  .out_a(a110to111), .out_b(b110to210), .out_c(matrixC110));
processing_element pe111(.reset(effective_rst), .clk(clk),  .in_a(a110to111), .in_b(b011to111),  .out_a(a111to112), .out_b(b111to211), .out_c(matrixC111));
processing_element pe112(.reset(effective_rst), .clk(clk),  .in_a(a111to112), .in_b(b012to112),  .out_a(a112to113), .out_b(b112to212), .out_c(matrixC112));
processing_element pe113(.reset(effective_rst), .clk(clk),  .in_a(a112to113), .in_b(b013to113),  .out_a(a113to114), .out_b(b113to213), .out_c(matrixC113));
processing_element pe114(.reset(effective_rst), .clk(clk),  .in_a(a113to114), .in_b(b014to114),  .out_a(a114to115), .out_b(b114to214), .out_c(matrixC114));
processing_element pe115(.reset(effective_rst), .clk(clk),  .in_a(a114to115), .in_b(b015to115),  .out_a(a115to116), .out_b(b115to215), .out_c(matrixC115));
processing_element pe21(.reset(effective_rst), .clk(clk),  .in_a(a20to21), .in_b(b11to21),  .out_a(a21to22), .out_b(b21to31), .out_c(matrixC21));
processing_element pe22(.reset(effective_rst), .clk(clk),  .in_a(a21to22), .in_b(b12to22),  .out_a(a22to23), .out_b(b22to32), .out_c(matrixC22));
processing_element pe23(.reset(effective_rst), .clk(clk),  .in_a(a22to23), .in_b(b13to23),  .out_a(a23to24), .out_b(b23to33), .out_c(matrixC23));
processing_element pe24(.reset(effective_rst), .clk(clk),  .in_a(a23to24), .in_b(b14to24),  .out_a(a24to25), .out_b(b24to34), .out_c(matrixC24));
processing_element pe25(.reset(effective_rst), .clk(clk),  .in_a(a24to25), .in_b(b15to25),  .out_a(a25to26), .out_b(b25to35), .out_c(matrixC25));
processing_element pe26(.reset(effective_rst), .clk(clk),  .in_a(a25to26), .in_b(b16to26),  .out_a(a26to27), .out_b(b26to36), .out_c(matrixC26));
processing_element pe27(.reset(effective_rst), .clk(clk),  .in_a(a26to27), .in_b(b17to27),  .out_a(a27to28), .out_b(b27to37), .out_c(matrixC27));
processing_element pe28(.reset(effective_rst), .clk(clk),  .in_a(a27to28), .in_b(b18to28),  .out_a(a28to29), .out_b(b28to38), .out_c(matrixC28));
processing_element pe29(.reset(effective_rst), .clk(clk),  .in_a(a28to29), .in_b(b19to29),  .out_a(a29to210), .out_b(b29to39), .out_c(matrixC29));
processing_element pe210(.reset(effective_rst), .clk(clk),  .in_a(a29to210), .in_b(b110to210),  .out_a(a210to211), .out_b(b210to310), .out_c(matrixC210));
processing_element pe211(.reset(effective_rst), .clk(clk),  .in_a(a210to211), .in_b(b111to211),  .out_a(a211to212), .out_b(b211to311), .out_c(matrixC211));
processing_element pe212(.reset(effective_rst), .clk(clk),  .in_a(a211to212), .in_b(b112to212),  .out_a(a212to213), .out_b(b212to312), .out_c(matrixC212));
processing_element pe213(.reset(effective_rst), .clk(clk),  .in_a(a212to213), .in_b(b113to213),  .out_a(a213to214), .out_b(b213to313), .out_c(matrixC213));
processing_element pe214(.reset(effective_rst), .clk(clk),  .in_a(a213to214), .in_b(b114to214),  .out_a(a214to215), .out_b(b214to314), .out_c(matrixC214));
processing_element pe215(.reset(effective_rst), .clk(clk),  .in_a(a214to215), .in_b(b115to215),  .out_a(a215to216), .out_b(b215to315), .out_c(matrixC215));
processing_element pe31(.reset(effective_rst), .clk(clk),  .in_a(a30to31), .in_b(b21to31),  .out_a(a31to32), .out_b(b31to41), .out_c(matrixC31));
processing_element pe32(.reset(effective_rst), .clk(clk),  .in_a(a31to32), .in_b(b22to32),  .out_a(a32to33), .out_b(b32to42), .out_c(matrixC32));
processing_element pe33(.reset(effective_rst), .clk(clk),  .in_a(a32to33), .in_b(b23to33),  .out_a(a33to34), .out_b(b33to43), .out_c(matrixC33));
processing_element pe34(.reset(effective_rst), .clk(clk),  .in_a(a33to34), .in_b(b24to34),  .out_a(a34to35), .out_b(b34to44), .out_c(matrixC34));
processing_element pe35(.reset(effective_rst), .clk(clk),  .in_a(a34to35), .in_b(b25to35),  .out_a(a35to36), .out_b(b35to45), .out_c(matrixC35));
processing_element pe36(.reset(effective_rst), .clk(clk),  .in_a(a35to36), .in_b(b26to36),  .out_a(a36to37), .out_b(b36to46), .out_c(matrixC36));
processing_element pe37(.reset(effective_rst), .clk(clk),  .in_a(a36to37), .in_b(b27to37),  .out_a(a37to38), .out_b(b37to47), .out_c(matrixC37));
processing_element pe38(.reset(effective_rst), .clk(clk),  .in_a(a37to38), .in_b(b28to38),  .out_a(a38to39), .out_b(b38to48), .out_c(matrixC38));
processing_element pe39(.reset(effective_rst), .clk(clk),  .in_a(a38to39), .in_b(b29to39),  .out_a(a39to310), .out_b(b39to49), .out_c(matrixC39));
processing_element pe310(.reset(effective_rst), .clk(clk),  .in_a(a39to310), .in_b(b210to310),  .out_a(a310to311), .out_b(b310to410), .out_c(matrixC310));
processing_element pe311(.reset(effective_rst), .clk(clk),  .in_a(a310to311), .in_b(b211to311),  .out_a(a311to312), .out_b(b311to411), .out_c(matrixC311));
processing_element pe312(.reset(effective_rst), .clk(clk),  .in_a(a311to312), .in_b(b212to312),  .out_a(a312to313), .out_b(b312to412), .out_c(matrixC312));
processing_element pe313(.reset(effective_rst), .clk(clk),  .in_a(a312to313), .in_b(b213to313),  .out_a(a313to314), .out_b(b313to413), .out_c(matrixC313));
processing_element pe314(.reset(effective_rst), .clk(clk),  .in_a(a313to314), .in_b(b214to314),  .out_a(a314to315), .out_b(b314to414), .out_c(matrixC314));
processing_element pe315(.reset(effective_rst), .clk(clk),  .in_a(a314to315), .in_b(b215to315),  .out_a(a315to316), .out_b(b315to415), .out_c(matrixC315));
processing_element pe41(.reset(effective_rst), .clk(clk),  .in_a(a40to41), .in_b(b31to41),  .out_a(a41to42), .out_b(b41to51), .out_c(matrixC41));
processing_element pe42(.reset(effective_rst), .clk(clk),  .in_a(a41to42), .in_b(b32to42),  .out_a(a42to43), .out_b(b42to52), .out_c(matrixC42));
processing_element pe43(.reset(effective_rst), .clk(clk),  .in_a(a42to43), .in_b(b33to43),  .out_a(a43to44), .out_b(b43to53), .out_c(matrixC43));
processing_element pe44(.reset(effective_rst), .clk(clk),  .in_a(a43to44), .in_b(b34to44),  .out_a(a44to45), .out_b(b44to54), .out_c(matrixC44));
processing_element pe45(.reset(effective_rst), .clk(clk),  .in_a(a44to45), .in_b(b35to45),  .out_a(a45to46), .out_b(b45to55), .out_c(matrixC45));
processing_element pe46(.reset(effective_rst), .clk(clk),  .in_a(a45to46), .in_b(b36to46),  .out_a(a46to47), .out_b(b46to56), .out_c(matrixC46));
processing_element pe47(.reset(effective_rst), .clk(clk),  .in_a(a46to47), .in_b(b37to47),  .out_a(a47to48), .out_b(b47to57), .out_c(matrixC47));
processing_element pe48(.reset(effective_rst), .clk(clk),  .in_a(a47to48), .in_b(b38to48),  .out_a(a48to49), .out_b(b48to58), .out_c(matrixC48));
processing_element pe49(.reset(effective_rst), .clk(clk),  .in_a(a48to49), .in_b(b39to49),  .out_a(a49to410), .out_b(b49to59), .out_c(matrixC49));
processing_element pe410(.reset(effective_rst), .clk(clk),  .in_a(a49to410), .in_b(b310to410),  .out_a(a410to411), .out_b(b410to510), .out_c(matrixC410));
processing_element pe411(.reset(effective_rst), .clk(clk),  .in_a(a410to411), .in_b(b311to411),  .out_a(a411to412), .out_b(b411to511), .out_c(matrixC411));
processing_element pe412(.reset(effective_rst), .clk(clk),  .in_a(a411to412), .in_b(b312to412),  .out_a(a412to413), .out_b(b412to512), .out_c(matrixC412));
processing_element pe413(.reset(effective_rst), .clk(clk),  .in_a(a412to413), .in_b(b313to413),  .out_a(a413to414), .out_b(b413to513), .out_c(matrixC413));
processing_element pe414(.reset(effective_rst), .clk(clk),  .in_a(a413to414), .in_b(b314to414),  .out_a(a414to415), .out_b(b414to514), .out_c(matrixC414));
processing_element pe415(.reset(effective_rst), .clk(clk),  .in_a(a414to415), .in_b(b315to415),  .out_a(a415to416), .out_b(b415to515), .out_c(matrixC415));
processing_element pe51(.reset(effective_rst), .clk(clk),  .in_a(a50to51), .in_b(b41to51),  .out_a(a51to52), .out_b(b51to61), .out_c(matrixC51));
processing_element pe52(.reset(effective_rst), .clk(clk),  .in_a(a51to52), .in_b(b42to52),  .out_a(a52to53), .out_b(b52to62), .out_c(matrixC52));
processing_element pe53(.reset(effective_rst), .clk(clk),  .in_a(a52to53), .in_b(b43to53),  .out_a(a53to54), .out_b(b53to63), .out_c(matrixC53));
processing_element pe54(.reset(effective_rst), .clk(clk),  .in_a(a53to54), .in_b(b44to54),  .out_a(a54to55), .out_b(b54to64), .out_c(matrixC54));
processing_element pe55(.reset(effective_rst), .clk(clk),  .in_a(a54to55), .in_b(b45to55),  .out_a(a55to56), .out_b(b55to65), .out_c(matrixC55));
processing_element pe56(.reset(effective_rst), .clk(clk),  .in_a(a55to56), .in_b(b46to56),  .out_a(a56to57), .out_b(b56to66), .out_c(matrixC56));
processing_element pe57(.reset(effective_rst), .clk(clk),  .in_a(a56to57), .in_b(b47to57),  .out_a(a57to58), .out_b(b57to67), .out_c(matrixC57));
processing_element pe58(.reset(effective_rst), .clk(clk),  .in_a(a57to58), .in_b(b48to58),  .out_a(a58to59), .out_b(b58to68), .out_c(matrixC58));
processing_element pe59(.reset(effective_rst), .clk(clk),  .in_a(a58to59), .in_b(b49to59),  .out_a(a59to510), .out_b(b59to69), .out_c(matrixC59));
processing_element pe510(.reset(effective_rst), .clk(clk),  .in_a(a59to510), .in_b(b410to510),  .out_a(a510to511), .out_b(b510to610), .out_c(matrixC510));
processing_element pe511(.reset(effective_rst), .clk(clk),  .in_a(a510to511), .in_b(b411to511),  .out_a(a511to512), .out_b(b511to611), .out_c(matrixC511));
processing_element pe512(.reset(effective_rst), .clk(clk),  .in_a(a511to512), .in_b(b412to512),  .out_a(a512to513), .out_b(b512to612), .out_c(matrixC512));
processing_element pe513(.reset(effective_rst), .clk(clk),  .in_a(a512to513), .in_b(b413to513),  .out_a(a513to514), .out_b(b513to613), .out_c(matrixC513));
processing_element pe514(.reset(effective_rst), .clk(clk),  .in_a(a513to514), .in_b(b414to514),  .out_a(a514to515), .out_b(b514to614), .out_c(matrixC514));
processing_element pe515(.reset(effective_rst), .clk(clk),  .in_a(a514to515), .in_b(b415to515),  .out_a(a515to516), .out_b(b515to615), .out_c(matrixC515));
processing_element pe61(.reset(effective_rst), .clk(clk),  .in_a(a60to61), .in_b(b51to61),  .out_a(a61to62), .out_b(b61to71), .out_c(matrixC61));
processing_element pe62(.reset(effective_rst), .clk(clk),  .in_a(a61to62), .in_b(b52to62),  .out_a(a62to63), .out_b(b62to72), .out_c(matrixC62));
processing_element pe63(.reset(effective_rst), .clk(clk),  .in_a(a62to63), .in_b(b53to63),  .out_a(a63to64), .out_b(b63to73), .out_c(matrixC63));
processing_element pe64(.reset(effective_rst), .clk(clk),  .in_a(a63to64), .in_b(b54to64),  .out_a(a64to65), .out_b(b64to74), .out_c(matrixC64));
processing_element pe65(.reset(effective_rst), .clk(clk),  .in_a(a64to65), .in_b(b55to65),  .out_a(a65to66), .out_b(b65to75), .out_c(matrixC65));
processing_element pe66(.reset(effective_rst), .clk(clk),  .in_a(a65to66), .in_b(b56to66),  .out_a(a66to67), .out_b(b66to76), .out_c(matrixC66));
processing_element pe67(.reset(effective_rst), .clk(clk),  .in_a(a66to67), .in_b(b57to67),  .out_a(a67to68), .out_b(b67to77), .out_c(matrixC67));
processing_element pe68(.reset(effective_rst), .clk(clk),  .in_a(a67to68), .in_b(b58to68),  .out_a(a68to69), .out_b(b68to78), .out_c(matrixC68));
processing_element pe69(.reset(effective_rst), .clk(clk),  .in_a(a68to69), .in_b(b59to69),  .out_a(a69to610), .out_b(b69to79), .out_c(matrixC69));
processing_element pe610(.reset(effective_rst), .clk(clk),  .in_a(a69to610), .in_b(b510to610),  .out_a(a610to611), .out_b(b610to710), .out_c(matrixC610));
processing_element pe611(.reset(effective_rst), .clk(clk),  .in_a(a610to611), .in_b(b511to611),  .out_a(a611to612), .out_b(b611to711), .out_c(matrixC611));
processing_element pe612(.reset(effective_rst), .clk(clk),  .in_a(a611to612), .in_b(b512to612),  .out_a(a612to613), .out_b(b612to712), .out_c(matrixC612));
processing_element pe613(.reset(effective_rst), .clk(clk),  .in_a(a612to613), .in_b(b513to613),  .out_a(a613to614), .out_b(b613to713), .out_c(matrixC613));
processing_element pe614(.reset(effective_rst), .clk(clk),  .in_a(a613to614), .in_b(b514to614),  .out_a(a614to615), .out_b(b614to714), .out_c(matrixC614));
processing_element pe615(.reset(effective_rst), .clk(clk),  .in_a(a614to615), .in_b(b515to615),  .out_a(a615to616), .out_b(b615to715), .out_c(matrixC615));
processing_element pe71(.reset(effective_rst), .clk(clk),  .in_a(a70to71), .in_b(b61to71),  .out_a(a71to72), .out_b(b71to81), .out_c(matrixC71));
processing_element pe72(.reset(effective_rst), .clk(clk),  .in_a(a71to72), .in_b(b62to72),  .out_a(a72to73), .out_b(b72to82), .out_c(matrixC72));
processing_element pe73(.reset(effective_rst), .clk(clk),  .in_a(a72to73), .in_b(b63to73),  .out_a(a73to74), .out_b(b73to83), .out_c(matrixC73));
processing_element pe74(.reset(effective_rst), .clk(clk),  .in_a(a73to74), .in_b(b64to74),  .out_a(a74to75), .out_b(b74to84), .out_c(matrixC74));
processing_element pe75(.reset(effective_rst), .clk(clk),  .in_a(a74to75), .in_b(b65to75),  .out_a(a75to76), .out_b(b75to85), .out_c(matrixC75));
processing_element pe76(.reset(effective_rst), .clk(clk),  .in_a(a75to76), .in_b(b66to76),  .out_a(a76to77), .out_b(b76to86), .out_c(matrixC76));
processing_element pe77(.reset(effective_rst), .clk(clk),  .in_a(a76to77), .in_b(b67to77),  .out_a(a77to78), .out_b(b77to87), .out_c(matrixC77));
processing_element pe78(.reset(effective_rst), .clk(clk),  .in_a(a77to78), .in_b(b68to78),  .out_a(a78to79), .out_b(b78to88), .out_c(matrixC78));
processing_element pe79(.reset(effective_rst), .clk(clk),  .in_a(a78to79), .in_b(b69to79),  .out_a(a79to710), .out_b(b79to89), .out_c(matrixC79));
processing_element pe710(.reset(effective_rst), .clk(clk),  .in_a(a79to710), .in_b(b610to710),  .out_a(a710to711), .out_b(b710to810), .out_c(matrixC710));
processing_element pe711(.reset(effective_rst), .clk(clk),  .in_a(a710to711), .in_b(b611to711),  .out_a(a711to712), .out_b(b711to811), .out_c(matrixC711));
processing_element pe712(.reset(effective_rst), .clk(clk),  .in_a(a711to712), .in_b(b612to712),  .out_a(a712to713), .out_b(b712to812), .out_c(matrixC712));
processing_element pe713(.reset(effective_rst), .clk(clk),  .in_a(a712to713), .in_b(b613to713),  .out_a(a713to714), .out_b(b713to813), .out_c(matrixC713));
processing_element pe714(.reset(effective_rst), .clk(clk),  .in_a(a713to714), .in_b(b614to714),  .out_a(a714to715), .out_b(b714to814), .out_c(matrixC714));
processing_element pe715(.reset(effective_rst), .clk(clk),  .in_a(a714to715), .in_b(b615to715),  .out_a(a715to716), .out_b(b715to815), .out_c(matrixC715));
processing_element pe81(.reset(effective_rst), .clk(clk),  .in_a(a80to81), .in_b(b71to81),  .out_a(a81to82), .out_b(b81to91), .out_c(matrixC81));
processing_element pe82(.reset(effective_rst), .clk(clk),  .in_a(a81to82), .in_b(b72to82),  .out_a(a82to83), .out_b(b82to92), .out_c(matrixC82));
processing_element pe83(.reset(effective_rst), .clk(clk),  .in_a(a82to83), .in_b(b73to83),  .out_a(a83to84), .out_b(b83to93), .out_c(matrixC83));
processing_element pe84(.reset(effective_rst), .clk(clk),  .in_a(a83to84), .in_b(b74to84),  .out_a(a84to85), .out_b(b84to94), .out_c(matrixC84));
processing_element pe85(.reset(effective_rst), .clk(clk),  .in_a(a84to85), .in_b(b75to85),  .out_a(a85to86), .out_b(b85to95), .out_c(matrixC85));
processing_element pe86(.reset(effective_rst), .clk(clk),  .in_a(a85to86), .in_b(b76to86),  .out_a(a86to87), .out_b(b86to96), .out_c(matrixC86));
processing_element pe87(.reset(effective_rst), .clk(clk),  .in_a(a86to87), .in_b(b77to87),  .out_a(a87to88), .out_b(b87to97), .out_c(matrixC87));
processing_element pe88(.reset(effective_rst), .clk(clk),  .in_a(a87to88), .in_b(b78to88),  .out_a(a88to89), .out_b(b88to98), .out_c(matrixC88));
processing_element pe89(.reset(effective_rst), .clk(clk),  .in_a(a88to89), .in_b(b79to89),  .out_a(a89to810), .out_b(b89to99), .out_c(matrixC89));
processing_element pe810(.reset(effective_rst), .clk(clk),  .in_a(a89to810), .in_b(b710to810),  .out_a(a810to811), .out_b(b810to910), .out_c(matrixC810));
processing_element pe811(.reset(effective_rst), .clk(clk),  .in_a(a810to811), .in_b(b711to811),  .out_a(a811to812), .out_b(b811to911), .out_c(matrixC811));
processing_element pe812(.reset(effective_rst), .clk(clk),  .in_a(a811to812), .in_b(b712to812),  .out_a(a812to813), .out_b(b812to912), .out_c(matrixC812));
processing_element pe813(.reset(effective_rst), .clk(clk),  .in_a(a812to813), .in_b(b713to813),  .out_a(a813to814), .out_b(b813to913), .out_c(matrixC813));
processing_element pe814(.reset(effective_rst), .clk(clk),  .in_a(a813to814), .in_b(b714to814),  .out_a(a814to815), .out_b(b814to914), .out_c(matrixC814));
processing_element pe815(.reset(effective_rst), .clk(clk),  .in_a(a814to815), .in_b(b715to815),  .out_a(a815to816), .out_b(b815to915), .out_c(matrixC815));
processing_element pe91(.reset(effective_rst), .clk(clk),  .in_a(a90to91), .in_b(b81to91),  .out_a(a91to92), .out_b(b91to101), .out_c(matrixC91));
processing_element pe92(.reset(effective_rst), .clk(clk),  .in_a(a91to92), .in_b(b82to92),  .out_a(a92to93), .out_b(b92to102), .out_c(matrixC92));
processing_element pe93(.reset(effective_rst), .clk(clk),  .in_a(a92to93), .in_b(b83to93),  .out_a(a93to94), .out_b(b93to103), .out_c(matrixC93));
processing_element pe94(.reset(effective_rst), .clk(clk),  .in_a(a93to94), .in_b(b84to94),  .out_a(a94to95), .out_b(b94to104), .out_c(matrixC94));
processing_element pe95(.reset(effective_rst), .clk(clk),  .in_a(a94to95), .in_b(b85to95),  .out_a(a95to96), .out_b(b95to105), .out_c(matrixC95));
processing_element pe96(.reset(effective_rst), .clk(clk),  .in_a(a95to96), .in_b(b86to96),  .out_a(a96to97), .out_b(b96to106), .out_c(matrixC96));
processing_element pe97(.reset(effective_rst), .clk(clk),  .in_a(a96to97), .in_b(b87to97),  .out_a(a97to98), .out_b(b97to107), .out_c(matrixC97));
processing_element pe98(.reset(effective_rst), .clk(clk),  .in_a(a97to98), .in_b(b88to98),  .out_a(a98to99), .out_b(b98to108), .out_c(matrixC98));
processing_element pe99(.reset(effective_rst), .clk(clk),  .in_a(a98to99), .in_b(b89to99),  .out_a(a99to910), .out_b(b99to109), .out_c(matrixC99));
processing_element pe910(.reset(effective_rst), .clk(clk),  .in_a(a99to910), .in_b(b810to910),  .out_a(a910to911), .out_b(b910to1010), .out_c(matrixC910));
processing_element pe911(.reset(effective_rst), .clk(clk),  .in_a(a910to911), .in_b(b811to911),  .out_a(a911to912), .out_b(b911to1011), .out_c(matrixC911));
processing_element pe912(.reset(effective_rst), .clk(clk),  .in_a(a911to912), .in_b(b812to912),  .out_a(a912to913), .out_b(b912to1012), .out_c(matrixC912));
processing_element pe913(.reset(effective_rst), .clk(clk),  .in_a(a912to913), .in_b(b813to913),  .out_a(a913to914), .out_b(b913to1013), .out_c(matrixC913));
processing_element pe914(.reset(effective_rst), .clk(clk),  .in_a(a913to914), .in_b(b814to914),  .out_a(a914to915), .out_b(b914to1014), .out_c(matrixC914));
processing_element pe915(.reset(effective_rst), .clk(clk),  .in_a(a914to915), .in_b(b815to915),  .out_a(a915to916), .out_b(b915to1015), .out_c(matrixC915));
processing_element pe101(.reset(effective_rst), .clk(clk),  .in_a(a100to101), .in_b(b91to101),  .out_a(a101to102), .out_b(b101to111), .out_c(matrixC101));
processing_element pe102(.reset(effective_rst), .clk(clk),  .in_a(a101to102), .in_b(b92to102),  .out_a(a102to103), .out_b(b102to112), .out_c(matrixC102));
processing_element pe103(.reset(effective_rst), .clk(clk),  .in_a(a102to103), .in_b(b93to103),  .out_a(a103to104), .out_b(b103to113), .out_c(matrixC103));
processing_element pe104(.reset(effective_rst), .clk(clk),  .in_a(a103to104), .in_b(b94to104),  .out_a(a104to105), .out_b(b104to114), .out_c(matrixC104));
processing_element pe105(.reset(effective_rst), .clk(clk),  .in_a(a104to105), .in_b(b95to105),  .out_a(a105to106), .out_b(b105to115), .out_c(matrixC105));
processing_element pe106(.reset(effective_rst), .clk(clk),  .in_a(a105to106), .in_b(b96to106),  .out_a(a106to107), .out_b(b106to116), .out_c(matrixC106));
processing_element pe107(.reset(effective_rst), .clk(clk),  .in_a(a106to107), .in_b(b97to107),  .out_a(a107to108), .out_b(b107to117), .out_c(matrixC107));
processing_element pe108(.reset(effective_rst), .clk(clk),  .in_a(a107to108), .in_b(b98to108),  .out_a(a108to109), .out_b(b108to118), .out_c(matrixC108));
processing_element pe109(.reset(effective_rst), .clk(clk),  .in_a(a108to109), .in_b(b99to109),  .out_a(a109to1010), .out_b(b109to119), .out_c(matrixC109));
processing_element pe1010(.reset(effective_rst), .clk(clk),  .in_a(a109to1010), .in_b(b910to1010),  .out_a(a1010to1011), .out_b(b1010to1110), .out_c(matrixC1010));
processing_element pe1011(.reset(effective_rst), .clk(clk),  .in_a(a1010to1011), .in_b(b911to1011),  .out_a(a1011to1012), .out_b(b1011to1111), .out_c(matrixC1011));
processing_element pe1012(.reset(effective_rst), .clk(clk),  .in_a(a1011to1012), .in_b(b912to1012),  .out_a(a1012to1013), .out_b(b1012to1112), .out_c(matrixC1012));
processing_element pe1013(.reset(effective_rst), .clk(clk),  .in_a(a1012to1013), .in_b(b913to1013),  .out_a(a1013to1014), .out_b(b1013to1113), .out_c(matrixC1013));
processing_element pe1014(.reset(effective_rst), .clk(clk),  .in_a(a1013to1014), .in_b(b914to1014),  .out_a(a1014to1015), .out_b(b1014to1114), .out_c(matrixC1014));
processing_element pe1015(.reset(effective_rst), .clk(clk),  .in_a(a1014to1015), .in_b(b915to1015),  .out_a(a1015to1016), .out_b(b1015to1115), .out_c(matrixC1015));
processing_element pe111(.reset(effective_rst), .clk(clk),  .in_a(a110to111), .in_b(b101to111),  .out_a(a111to112), .out_b(b111to121), .out_c(matrixC111));
processing_element pe112(.reset(effective_rst), .clk(clk),  .in_a(a111to112), .in_b(b102to112),  .out_a(a112to113), .out_b(b112to122), .out_c(matrixC112));
processing_element pe113(.reset(effective_rst), .clk(clk),  .in_a(a112to113), .in_b(b103to113),  .out_a(a113to114), .out_b(b113to123), .out_c(matrixC113));
processing_element pe114(.reset(effective_rst), .clk(clk),  .in_a(a113to114), .in_b(b104to114),  .out_a(a114to115), .out_b(b114to124), .out_c(matrixC114));
processing_element pe115(.reset(effective_rst), .clk(clk),  .in_a(a114to115), .in_b(b105to115),  .out_a(a115to116), .out_b(b115to125), .out_c(matrixC115));
processing_element pe116(.reset(effective_rst), .clk(clk),  .in_a(a115to116), .in_b(b106to116),  .out_a(a116to117), .out_b(b116to126), .out_c(matrixC116));
processing_element pe117(.reset(effective_rst), .clk(clk),  .in_a(a116to117), .in_b(b107to117),  .out_a(a117to118), .out_b(b117to127), .out_c(matrixC117));
processing_element pe118(.reset(effective_rst), .clk(clk),  .in_a(a117to118), .in_b(b108to118),  .out_a(a118to119), .out_b(b118to128), .out_c(matrixC118));
processing_element pe119(.reset(effective_rst), .clk(clk),  .in_a(a118to119), .in_b(b109to119),  .out_a(a119to1110), .out_b(b119to129), .out_c(matrixC119));
processing_element pe1110(.reset(effective_rst), .clk(clk),  .in_a(a119to1110), .in_b(b1010to1110),  .out_a(a1110to1111), .out_b(b1110to1210), .out_c(matrixC1110));
processing_element pe1111(.reset(effective_rst), .clk(clk),  .in_a(a1110to1111), .in_b(b1011to1111),  .out_a(a1111to1112), .out_b(b1111to1211), .out_c(matrixC1111));
processing_element pe1112(.reset(effective_rst), .clk(clk),  .in_a(a1111to1112), .in_b(b1012to1112),  .out_a(a1112to1113), .out_b(b1112to1212), .out_c(matrixC1112));
processing_element pe1113(.reset(effective_rst), .clk(clk),  .in_a(a1112to1113), .in_b(b1013to1113),  .out_a(a1113to1114), .out_b(b1113to1213), .out_c(matrixC1113));
processing_element pe1114(.reset(effective_rst), .clk(clk),  .in_a(a1113to1114), .in_b(b1014to1114),  .out_a(a1114to1115), .out_b(b1114to1214), .out_c(matrixC1114));
processing_element pe1115(.reset(effective_rst), .clk(clk),  .in_a(a1114to1115), .in_b(b1015to1115),  .out_a(a1115to1116), .out_b(b1115to1215), .out_c(matrixC1115));
processing_element pe121(.reset(effective_rst), .clk(clk),  .in_a(a120to121), .in_b(b111to121),  .out_a(a121to122), .out_b(b121to131), .out_c(matrixC121));
processing_element pe122(.reset(effective_rst), .clk(clk),  .in_a(a121to122), .in_b(b112to122),  .out_a(a122to123), .out_b(b122to132), .out_c(matrixC122));
processing_element pe123(.reset(effective_rst), .clk(clk),  .in_a(a122to123), .in_b(b113to123),  .out_a(a123to124), .out_b(b123to133), .out_c(matrixC123));
processing_element pe124(.reset(effective_rst), .clk(clk),  .in_a(a123to124), .in_b(b114to124),  .out_a(a124to125), .out_b(b124to134), .out_c(matrixC124));
processing_element pe125(.reset(effective_rst), .clk(clk),  .in_a(a124to125), .in_b(b115to125),  .out_a(a125to126), .out_b(b125to135), .out_c(matrixC125));
processing_element pe126(.reset(effective_rst), .clk(clk),  .in_a(a125to126), .in_b(b116to126),  .out_a(a126to127), .out_b(b126to136), .out_c(matrixC126));
processing_element pe127(.reset(effective_rst), .clk(clk),  .in_a(a126to127), .in_b(b117to127),  .out_a(a127to128), .out_b(b127to137), .out_c(matrixC127));
processing_element pe128(.reset(effective_rst), .clk(clk),  .in_a(a127to128), .in_b(b118to128),  .out_a(a128to129), .out_b(b128to138), .out_c(matrixC128));
processing_element pe129(.reset(effective_rst), .clk(clk),  .in_a(a128to129), .in_b(b119to129),  .out_a(a129to1210), .out_b(b129to139), .out_c(matrixC129));
processing_element pe1210(.reset(effective_rst), .clk(clk),  .in_a(a129to1210), .in_b(b1110to1210),  .out_a(a1210to1211), .out_b(b1210to1310), .out_c(matrixC1210));
processing_element pe1211(.reset(effective_rst), .clk(clk),  .in_a(a1210to1211), .in_b(b1111to1211),  .out_a(a1211to1212), .out_b(b1211to1311), .out_c(matrixC1211));
processing_element pe1212(.reset(effective_rst), .clk(clk),  .in_a(a1211to1212), .in_b(b1112to1212),  .out_a(a1212to1213), .out_b(b1212to1312), .out_c(matrixC1212));
processing_element pe1213(.reset(effective_rst), .clk(clk),  .in_a(a1212to1213), .in_b(b1113to1213),  .out_a(a1213to1214), .out_b(b1213to1313), .out_c(matrixC1213));
processing_element pe1214(.reset(effective_rst), .clk(clk),  .in_a(a1213to1214), .in_b(b1114to1214),  .out_a(a1214to1215), .out_b(b1214to1314), .out_c(matrixC1214));
processing_element pe1215(.reset(effective_rst), .clk(clk),  .in_a(a1214to1215), .in_b(b1115to1215),  .out_a(a1215to1216), .out_b(b1215to1315), .out_c(matrixC1215));
processing_element pe131(.reset(effective_rst), .clk(clk),  .in_a(a130to131), .in_b(b121to131),  .out_a(a131to132), .out_b(b131to141), .out_c(matrixC131));
processing_element pe132(.reset(effective_rst), .clk(clk),  .in_a(a131to132), .in_b(b122to132),  .out_a(a132to133), .out_b(b132to142), .out_c(matrixC132));
processing_element pe133(.reset(effective_rst), .clk(clk),  .in_a(a132to133), .in_b(b123to133),  .out_a(a133to134), .out_b(b133to143), .out_c(matrixC133));
processing_element pe134(.reset(effective_rst), .clk(clk),  .in_a(a133to134), .in_b(b124to134),  .out_a(a134to135), .out_b(b134to144), .out_c(matrixC134));
processing_element pe135(.reset(effective_rst), .clk(clk),  .in_a(a134to135), .in_b(b125to135),  .out_a(a135to136), .out_b(b135to145), .out_c(matrixC135));
processing_element pe136(.reset(effective_rst), .clk(clk),  .in_a(a135to136), .in_b(b126to136),  .out_a(a136to137), .out_b(b136to146), .out_c(matrixC136));
processing_element pe137(.reset(effective_rst), .clk(clk),  .in_a(a136to137), .in_b(b127to137),  .out_a(a137to138), .out_b(b137to147), .out_c(matrixC137));
processing_element pe138(.reset(effective_rst), .clk(clk),  .in_a(a137to138), .in_b(b128to138),  .out_a(a138to139), .out_b(b138to148), .out_c(matrixC138));
processing_element pe139(.reset(effective_rst), .clk(clk),  .in_a(a138to139), .in_b(b129to139),  .out_a(a139to1310), .out_b(b139to149), .out_c(matrixC139));
processing_element pe1310(.reset(effective_rst), .clk(clk),  .in_a(a139to1310), .in_b(b1210to1310),  .out_a(a1310to1311), .out_b(b1310to1410), .out_c(matrixC1310));
processing_element pe1311(.reset(effective_rst), .clk(clk),  .in_a(a1310to1311), .in_b(b1211to1311),  .out_a(a1311to1312), .out_b(b1311to1411), .out_c(matrixC1311));
processing_element pe1312(.reset(effective_rst), .clk(clk),  .in_a(a1311to1312), .in_b(b1212to1312),  .out_a(a1312to1313), .out_b(b1312to1412), .out_c(matrixC1312));
processing_element pe1313(.reset(effective_rst), .clk(clk),  .in_a(a1312to1313), .in_b(b1213to1313),  .out_a(a1313to1314), .out_b(b1313to1413), .out_c(matrixC1313));
processing_element pe1314(.reset(effective_rst), .clk(clk),  .in_a(a1313to1314), .in_b(b1214to1314),  .out_a(a1314to1315), .out_b(b1314to1414), .out_c(matrixC1314));
processing_element pe1315(.reset(effective_rst), .clk(clk),  .in_a(a1314to1315), .in_b(b1215to1315),  .out_a(a1315to1316), .out_b(b1315to1415), .out_c(matrixC1315));
processing_element pe141(.reset(effective_rst), .clk(clk),  .in_a(a140to141), .in_b(b131to141),  .out_a(a141to142), .out_b(b141to151), .out_c(matrixC141));
processing_element pe142(.reset(effective_rst), .clk(clk),  .in_a(a141to142), .in_b(b132to142),  .out_a(a142to143), .out_b(b142to152), .out_c(matrixC142));
processing_element pe143(.reset(effective_rst), .clk(clk),  .in_a(a142to143), .in_b(b133to143),  .out_a(a143to144), .out_b(b143to153), .out_c(matrixC143));
processing_element pe144(.reset(effective_rst), .clk(clk),  .in_a(a143to144), .in_b(b134to144),  .out_a(a144to145), .out_b(b144to154), .out_c(matrixC144));
processing_element pe145(.reset(effective_rst), .clk(clk),  .in_a(a144to145), .in_b(b135to145),  .out_a(a145to146), .out_b(b145to155), .out_c(matrixC145));
processing_element pe146(.reset(effective_rst), .clk(clk),  .in_a(a145to146), .in_b(b136to146),  .out_a(a146to147), .out_b(b146to156), .out_c(matrixC146));
processing_element pe147(.reset(effective_rst), .clk(clk),  .in_a(a146to147), .in_b(b137to147),  .out_a(a147to148), .out_b(b147to157), .out_c(matrixC147));
processing_element pe148(.reset(effective_rst), .clk(clk),  .in_a(a147to148), .in_b(b138to148),  .out_a(a148to149), .out_b(b148to158), .out_c(matrixC148));
processing_element pe149(.reset(effective_rst), .clk(clk),  .in_a(a148to149), .in_b(b139to149),  .out_a(a149to1410), .out_b(b149to159), .out_c(matrixC149));
processing_element pe1410(.reset(effective_rst), .clk(clk),  .in_a(a149to1410), .in_b(b1310to1410),  .out_a(a1410to1411), .out_b(b1410to1510), .out_c(matrixC1410));
processing_element pe1411(.reset(effective_rst), .clk(clk),  .in_a(a1410to1411), .in_b(b1311to1411),  .out_a(a1411to1412), .out_b(b1411to1511), .out_c(matrixC1411));
processing_element pe1412(.reset(effective_rst), .clk(clk),  .in_a(a1411to1412), .in_b(b1312to1412),  .out_a(a1412to1413), .out_b(b1412to1512), .out_c(matrixC1412));
processing_element pe1413(.reset(effective_rst), .clk(clk),  .in_a(a1412to1413), .in_b(b1313to1413),  .out_a(a1413to1414), .out_b(b1413to1513), .out_c(matrixC1413));
processing_element pe1414(.reset(effective_rst), .clk(clk),  .in_a(a1413to1414), .in_b(b1314to1414),  .out_a(a1414to1415), .out_b(b1414to1514), .out_c(matrixC1414));
processing_element pe1415(.reset(effective_rst), .clk(clk),  .in_a(a1414to1415), .in_b(b1315to1415),  .out_a(a1415to1416), .out_b(b1415to1515), .out_c(matrixC1415));
processing_element pe151(.reset(effective_rst), .clk(clk),  .in_a(a150to151), .in_b(b141to151),  .out_a(a151to152), .out_b(b151to161), .out_c(matrixC151));
processing_element pe152(.reset(effective_rst), .clk(clk),  .in_a(a151to152), .in_b(b142to152),  .out_a(a152to153), .out_b(b152to162), .out_c(matrixC152));
processing_element pe153(.reset(effective_rst), .clk(clk),  .in_a(a152to153), .in_b(b143to153),  .out_a(a153to154), .out_b(b153to163), .out_c(matrixC153));
processing_element pe154(.reset(effective_rst), .clk(clk),  .in_a(a153to154), .in_b(b144to154),  .out_a(a154to155), .out_b(b154to164), .out_c(matrixC154));
processing_element pe155(.reset(effective_rst), .clk(clk),  .in_a(a154to155), .in_b(b145to155),  .out_a(a155to156), .out_b(b155to165), .out_c(matrixC155));
processing_element pe156(.reset(effective_rst), .clk(clk),  .in_a(a155to156), .in_b(b146to156),  .out_a(a156to157), .out_b(b156to166), .out_c(matrixC156));
processing_element pe157(.reset(effective_rst), .clk(clk),  .in_a(a156to157), .in_b(b147to157),  .out_a(a157to158), .out_b(b157to167), .out_c(matrixC157));
processing_element pe158(.reset(effective_rst), .clk(clk),  .in_a(a157to158), .in_b(b148to158),  .out_a(a158to159), .out_b(b158to168), .out_c(matrixC158));
processing_element pe159(.reset(effective_rst), .clk(clk),  .in_a(a158to159), .in_b(b149to159),  .out_a(a159to1510), .out_b(b159to169), .out_c(matrixC159));
processing_element pe1510(.reset(effective_rst), .clk(clk),  .in_a(a159to1510), .in_b(b1410to1510),  .out_a(a1510to1511), .out_b(b1510to1610), .out_c(matrixC1510));
processing_element pe1511(.reset(effective_rst), .clk(clk),  .in_a(a1510to1511), .in_b(b1411to1511),  .out_a(a1511to1512), .out_b(b1511to1611), .out_c(matrixC1511));
processing_element pe1512(.reset(effective_rst), .clk(clk),  .in_a(a1511to1512), .in_b(b1412to1512),  .out_a(a1512to1513), .out_b(b1512to1612), .out_c(matrixC1512));
processing_element pe1513(.reset(effective_rst), .clk(clk),  .in_a(a1512to1513), .in_b(b1413to1513),  .out_a(a1513to1514), .out_b(b1513to1613), .out_c(matrixC1513));
processing_element pe1514(.reset(effective_rst), .clk(clk),  .in_a(a1513to1514), .in_b(b1414to1514),  .out_a(a1514to1515), .out_b(b1514to1614), .out_c(matrixC1514));
processing_element pe1515(.reset(effective_rst), .clk(clk),  .in_a(a1514to1515), .in_b(b1415to1515),  .out_a(a1515to1516), .out_b(b1515to1615), .out_c(matrixC1515));
assign a_data_out = {a1515to1516,a1415to1416,a1315to1316,a1215to1216,a1115to1116,a1015to1016,a915to916,a815to816,a715to716,a615to616,a515to516,a415to416,a315to316,a215to216,a115to116,a015to016};
assign b_data_out = {b1515to1615,b1514to1614,b1513to1613,b1512to1612,b1511to1611,b1510to1610,b159to169,b158to168,b157to167,b156to166,b155to165,b154to164,b153to163,b152to162,b151to161,b150to160};

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
  .final_mat_mul_size(8'd16),
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


