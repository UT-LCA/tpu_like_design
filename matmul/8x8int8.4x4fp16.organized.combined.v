
`timescale 1ns / 1ps

`define DWIDTH 8
`define AWIDTH 16
`define MEM_SIZE 2048

`define MAT_MUL_SIZE 8
`define MASK_WIDTH 8
`define LOG2_MAT_MUL_SIZE 3

`define BB_MAT_MUL_SIZE `MAT_MUL_SIZE
`define NUM_CYCLES_IN_MAC 3
`define MEM_ACCESS_LATENCY 1
`define REG_DATAWIDTH 32
`define REG_ADDRWIDTH 8
`define ADDR_STRIDE_WIDTH 16
`define MAX_BITS_POOL 3
`define DTYPE_INT8 0
`define DTYPE_FP16 1
`define SLICE_MODE_MATMUL 0
`define SLICE_MODE_INDIV_PE 1

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020-07-25 21:27:45.174821
// Design Name: 
// Module Name: matmul_8x8_systolic
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

module matmul_slice(
 clk,
 reset,
 pe_reset,
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
 validity_mask_a_rows,
 validity_mask_a_cols_b_rows,
 validity_mask_b_cols,
 slice_dtype,  //which data type/precision : 1 = fp16 or 0 = int8
 slice_mode,   //which mode : 0 as a matmul or 1 as individual PEs
 final_mat_mul_size,
 a_loc,
 b_loc
);

 input clk;
 input reset;
 input pe_reset;
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

 input [`MASK_WIDTH-1:0] validity_mask_a_rows;
 input [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows;
 input [`MASK_WIDTH-1:0] validity_mask_b_cols;
 input slice_dtype;
 input slice_mode;

//7:0 is okay here. We aren't going to make a matmul larger than 128x128
//In fact, these will get optimized out by the synthesis tool, because
//we hardcode them at the instantiation level.
 input [7:0] final_mat_mul_size;
 input [7:0] a_loc;
 input [7:0] b_loc;

//////////////////////////////////////////////////////////////////////////
// Create input list for PEs by concatenating all inputs 
//////////////////////////////////////////////////////////////////////////
wire [463:0] input_list_to_pes;
assign input_list_to_pes = {
 address_mat_a,  //448
 address_mat_b,  //432
 address_mat_c,  //416 <- direct_inputs_mode ends at address_mat_c[3] and direct_inputs_dtype starts at address_mat_c[4]
 address_stride_a, //400
 address_stride_b, //384 <- direct_inputs_mode starts at address_stride_b[0]
 address_stride_c, //368
 a_data, //304
 b_data, //240
 a_data_in, //176 <- direct_inputs_a ends at a_data_in[15] and direct_inputs_b starts at a_data_in[16]
 b_data_in, //112
 c_data_in, //48
 validity_mask_a_rows, //40
 validity_mask_a_cols_b_rows, //32
 validity_mask_b_cols, //24
 final_mat_mul_size, //16
 a_loc, //8
 b_loc  //0 <- Starting index <- direct_inputs_a starts at b_loc[0]
};

//////////////////////////////////////////////////////////////////////////
// Muxes for outputs 
//////////////////////////////////////////////////////////////////////////
wire [239:0] output_list_from_pes;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_out_internal;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out_internal;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out_internal;
wire [`AWIDTH-1:0] a_addr_internal;
wire [`AWIDTH-1:0] b_addr_internal;
wire [`AWIDTH-1:0] c_addr_internal;
assign c_data_out = (slice_mode == `SLICE_MODE_MATMUL) ? c_data_out_internal : output_list_from_pes[63:0];
assign a_data_out = (slice_mode == `SLICE_MODE_MATMUL) ? a_data_out_internal : output_list_from_pes[127:64];
assign b_data_out = (slice_mode == `SLICE_MODE_MATMUL) ? b_data_out_internal : output_list_from_pes[191:128];
assign a_addr     = (slice_mode == `SLICE_MODE_MATMUL) ? a_addr_internal     : output_list_from_pes[192+`AWIDTH-1:192];
assign b_addr     = (slice_mode == `SLICE_MODE_MATMUL) ? b_addr_internal     : output_list_from_pes[192+2*`AWIDTH-1:192+`AWIDTH];
assign c_addr     = (slice_mode == `SLICE_MODE_MATMUL) ? c_addr_internal     : output_list_from_pes[192+3*`AWIDTH-1:192+2*`AWIDTH];

//////////////////////////////////////////////////////////////////////////
// Logic for clock counting and when to assert done
//////////////////////////////////////////////////////////////////////////

reg done_mat_mul;
//This is 7 bits because the expectation is that clock count will be pretty
//small. For large matmuls, this will need to increased to have more bits.
//In general, a systolic multiplier takes 4*N-2+P cycles, where N is the size 
//of the matmul and P is the number of pipleine stages in the MAC block.
reg [7:0] clk_cnt;

//Finding out number of cycles to assert matmul done.
//When we have to save the outputs to accumulators, then we don't need to
//shift out data. So, we can assert done_mat_mul early.
//In the normal case, we have to include the time to shift out the results. 
//Note: the count expression used to contain "4*final_mat_mul_size", but 
//to avoid multiplication, we now use "final_mat_mul_size<<2"
wire [7:0] clk_cnt_for_done;

assign clk_cnt_for_done = 
                          ((final_mat_mul_size<<2) - 2 + `NUM_CYCLES_IN_MAC);  
    
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

wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed;

//////////////////////////////////////////////////////////////////////////
// Instantiation of systolic data setup
//////////////////////////////////////////////////////////////////////////
systolic_data_setup u_systolic_data_setup(
.clk(clk),
.reset(reset),
.start_mat_mul(start_mat_mul),
.a_addr(a_addr_internal),
.b_addr(b_addr_internal),
.address_mat_a(address_mat_a),
.address_mat_b(address_mat_b),
.address_stride_a(address_stride_a),
.address_stride_b(address_stride_b),
.a_data(a_data),
.b_data(b_data),
.clk_cnt(clk_cnt),
.a_data_delayed(a_data_delayed),
.b_data_delayed(b_data_delayed),
.validity_mask_a_rows(validity_mask_a_rows),
.validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
.validity_mask_b_cols(validity_mask_b_cols),
.slice_dtype(slice_dtype),
.final_mat_mul_size(final_mat_mul_size),
.a_loc(a_loc),
.b_loc(b_loc)
);

//////////////////////////////////////////////////////////////////////////
// Logic to mux data_in coming from neighboring matmuls
//////////////////////////////////////////////////////////////////////////
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_to_pes;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_to_pes;

assign a_data_to_pes = (b_loc==0) ? a_data_delayed : a_data_in;
assign b_data_to_pes = (a_loc==0) ? b_data_delayed : b_data_in;

//////////////////////////////////////////////////////////////////////////
// Instantiations of the actual PEs
//////////////////////////////////////////////////////////////////////////
wire [511:0] pe_data_out;
systolic_pe_matrix u_systolic_pe_matrix(
.clk(clk),
.reset(reset),
.pe_reset(pe_reset),
.a_data(a_data_to_pes),
.b_data(b_data_to_pes),
.slice_dtype(slice_dtype),
.slice_mode(slice_mode),
.pe_data_out(pe_data_out),
.a_data_out(a_data_out_internal),
.b_data_out(b_data_out_internal),
.input_list_to_pes(input_list_to_pes),
.output_list_from_pes(output_list_from_pes)
);

//////////////////////////////////////////////////////////////////////////
// Instantiation of the output logic
//////////////////////////////////////////////////////////////////////////
output_logic u_output_logic(
.start_mat_mul(start_mat_mul),
.done_mat_mul(done_mat_mul),
.address_mat_c(address_mat_c),
.address_stride_c(address_stride_c),
.c_data_out(c_data_out_internal),
.c_data_in(c_data_in),
.c_addr(c_addr_internal),
.c_data_available(c_data_available),
.clk_cnt(clk_cnt),
.final_mat_mul_size(final_mat_mul_size),
.pe_data_out(pe_data_out),
.slice_dtype(slice_dtype),
.clk(clk),
.reset(reset)
);

endmodule

//////////////////////////////////////////////////////////////////////////
// Output logic
//////////////////////////////////////////////////////////////////////////
module output_logic(
start_mat_mul,
done_mat_mul,
address_mat_c,
address_stride_c,
c_data_in,
c_data_out, //Data values going out to next matmul - systolic shifting
c_addr,
c_data_available,
clk_cnt,
final_mat_mul_size,
pe_data_out,
slice_dtype,
clk,
reset
);

input clk;
input reset;
input start_mat_mul;
input done_mat_mul;
input [`AWIDTH-1:0] address_mat_c;
input [`ADDR_STRIDE_WIDTH-1:0] address_stride_c;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_out;
output [`AWIDTH-1:0] c_addr;
output c_data_available;
input [7:0] clk_cnt;
input [7:0] final_mat_mul_size;
input [511:0] pe_data_out;
input slice_dtype;
wire row_latch_en;

//////////////////////////////////////////////////////////////////////////
// Logic to capture matrix C data from the PEs and shift it out
//////////////////////////////////////////////////////////////////////////
//assign row_latch_en = (clk_cnt==(`MAT_MUL_SIZE + (a_loc+b_loc) * `BB_MAT_MUL_SIZE + 10 +  `NUM_CYCLES_IN_MAC - 1));
//Writing the line above to avoid multiplication:
//assign row_latch_en = (clk_cnt==(`MAT_MUL_SIZE + ((a_loc+b_loc) << `LOG2_MAT_MUL_SIZE) + 10 +  `NUM_CYCLES_IN_MAC - 1));

assign row_latch_en =  
                       ((clk_cnt == ((final_mat_mul_size<<2) - final_mat_mul_size - 1 +`NUM_CYCLES_IN_MAC)));
    
reg c_data_available;
reg [`AWIDTH-1:0] c_addr;
reg start_capturing_c_data;
integer counter;
reg [8*`DWIDTH-1:0] c_data_out;
reg [8*`DWIDTH-1:0] c_data_out_1;
reg [8*`DWIDTH-1:0] c_data_out_2;
reg [8*`DWIDTH-1:0] c_data_out_3;
reg [8*`DWIDTH-1:0] c_data_out_4;
reg [8*`DWIDTH-1:0] c_data_out_5;
reg [8*`DWIDTH-1:0] c_data_out_6;
reg [8*`DWIDTH-1:0] c_data_out_7;
wire condition_to_start_shifting_output;
assign condition_to_start_shifting_output = 
                          row_latch_en ;  

  
//For larger matmuls, this logic will have more entries in the case statement
always @(posedge clk) begin
  if (reset | ~start_mat_mul) begin
    start_capturing_c_data <= 1'b0;
    c_data_available <= 1'b0;
    c_addr <= address_mat_c + address_stride_c;
    c_data_out <= 0;
    counter <= 0;

    c_data_out_1 <= 0;
    c_data_out_2 <= 0;
    c_data_out_3 <= 0;
    c_data_out_4 <= 0;
    c_data_out_5 <= 0;
    c_data_out_6 <= 0;
    c_data_out_7 <= 0;
  end else if (condition_to_start_shifting_output) begin
    start_capturing_c_data <= 1'b1;
    c_data_available <= 1'b1;
    c_addr <= c_addr - address_stride_c;
    if (slice_dtype == `DTYPE_INT8) begin
    c_data_out   <= {pe_data_out[32+7*64+7:32+7*64], pe_data_out[32+6*64+7:32+6*64], pe_data_out[32+5*64+7:32+5*64], pe_data_out[32+4*64+7:32+4*64], pe_data_out[32+3*64+7:32+3*64], pe_data_out[32+2*64+7:32+2*64], pe_data_out[32+64+7:32+64], pe_data_out[32+7:32]};
    c_data_out_1 <= {pe_data_out[40+7*64+7:40+7*64], pe_data_out[40+6*64+7:40+6*64], pe_data_out[40+5*64+7:40+5*64], pe_data_out[40+4*64+7:40+4*64], pe_data_out[40+3*64+7:40+3*64], pe_data_out[40+2*64+7:40+2*64], pe_data_out[40+64+7:40+64], pe_data_out[40+7:40]};
    c_data_out_2 <= {pe_data_out[48+7*64+7:48+7*64], pe_data_out[48+6*64+7:48+6*64], pe_data_out[48+5*64+7:48+5*64], pe_data_out[48+4*64+7:48+4*64], pe_data_out[48+3*64+7:48+3*64], pe_data_out[48+2*64+7:48+2*64], pe_data_out[48+64+7:48+64], pe_data_out[48+7:48]};
    c_data_out_3 <= {pe_data_out[56+7*64+7:56+7*64], pe_data_out[56+6*64+7:56+6*64], pe_data_out[56+5*64+7:56+5*64], pe_data_out[56+4*64+7:56+4*64], pe_data_out[56+3*64+7:56+3*64], pe_data_out[56+2*64+7:56+2*64], pe_data_out[56+64+7:56+64], pe_data_out[56+7:56]};
    c_data_out_4 <= {pe_data_out[0+7*64+7:0+7*64], pe_data_out[0+6*64+7:0+6*64], pe_data_out[0+5*64+7:0+5*64], pe_data_out[0+4*64+7:0+4*64], pe_data_out[0+3*64+7:0+3*64], pe_data_out[0+2*64+7:0+2*64], pe_data_out[0+64+7:0+64], pe_data_out[0+7:0]};
    c_data_out_5 <= {pe_data_out[8+7*64+7:8+7*64], pe_data_out[8+6*64+7:8+6*64], pe_data_out[8+5*64+7:8+5*64], pe_data_out[8+4*64+7:8+4*64], pe_data_out[8+3*64+7:8+3*64], pe_data_out[8+2*64+7:8+2*64], pe_data_out[8+64+7:8+64], pe_data_out[8+7:8]};
    c_data_out_6 <= {pe_data_out[16+7*64+7:16+7*64], pe_data_out[16+6*64+7:16+6*64], pe_data_out[16+5*64+7:16+5*64], pe_data_out[16+4*64+7:16+4*64], pe_data_out[16+3*64+7:16+3*64], pe_data_out[16+2*64+7:16+2*64], pe_data_out[16+64+7:16+64], pe_data_out[16+7:16]};
    c_data_out_7 <= {pe_data_out[24+7*64+7:24+7*64], pe_data_out[24+6*64+7:24+6*64], pe_data_out[24+5*64+7:24+5*64], pe_data_out[24+4*64+7:24+4*64], pe_data_out[24+3*64+7:24+3*64], pe_data_out[24+2*64+7:24+2*64], pe_data_out[24+64+7:24+64], pe_data_out[24+7:24]};
    end 
    else begin
    c_data_out   <= {pe_data_out[96+3*128+15:96+3*128], pe_data_out[96+2*128+15:96+2*128], pe_data_out[96+128+15:96+128], pe_data_out[96+15:96]};
    c_data_out_1 <= {pe_data_out[64+3*128+15:64+3*128], pe_data_out[64+2*128+15:64+2*128], pe_data_out[64+128+15:64+128], pe_data_out[64+15:64]};
    c_data_out_2 <= {pe_data_out[32+3*128+15:32+3*128], pe_data_out[32+2*128+15:32+2*128], pe_data_out[32+128+15:32+128], pe_data_out[32+15:32]};
    c_data_out_3 <= {pe_data_out[0+3*128+15:0+3*128], pe_data_out[0+2*128+15:0+2*128], pe_data_out[0+128+15:0+128], pe_data_out[0+15:0]};
    c_data_out_4 <= 0;
    c_data_out_5 <= 0;
    c_data_out_6 <= 0;
    c_data_out_7 <= 0;
    end
      //c_data_out <= {matrixC7_7, matrixC6_7, matrixC5_7, matrixC4_7, matrixC3_7, matrixC2_7, matrixC1_7, matrixC0_7};
      //c_data_out_1 <= {matrixC7_6, matrixC6_6, matrixC5_6, matrixC4_6, matrixC3_6, matrixC2_6, matrixC1_6, matrixC0_6};
      //c_data_out_2 <= {matrixC7_5, matrixC6_5, matrixC5_5, matrixC4_5, matrixC3_5, matrixC2_5, matrixC1_5, matrixC0_5};
      //c_data_out_3 <= {matrixC7_4, matrixC6_4, matrixC5_4, matrixC4_4, matrixC3_4, matrixC2_4, matrixC1_4, matrixC0_4};
      //c_data_out_4 <= {matrixC7_3, matrixC6_3, matrixC5_3, matrixC4_3, matrixC3_3, matrixC2_3, matrixC1_3, matrixC0_3};
      //c_data_out_5 <= {matrixC7_2, matrixC6_2, matrixC5_2, matrixC4_2, matrixC3_2, matrixC2_2, matrixC1_2, matrixC0_2};
      //c_data_out_6 <= {matrixC7_1, matrixC6_1, matrixC5_1, matrixC4_1, matrixC3_1, matrixC2_1, matrixC1_1, matrixC0_1};
      //c_data_out_7 <= {matrixC7_0, matrixC6_0, matrixC5_0, matrixC4_0, matrixC3_0, matrixC2_0, matrixC1_0, matrixC0_0};

    counter <= counter + 1;
  end else if (done_mat_mul) begin
    start_capturing_c_data <= 1'b0;
    c_data_available <= 1'b0;
    c_addr <= address_mat_c + address_stride_c;
    c_data_out <= 0;

    c_data_out_1 <= 0;
    c_data_out_2 <= 0;
    c_data_out_3 <= 0;
    c_data_out_4 <= 0;
    c_data_out_5 <= 0;
    c_data_out_6 <= 0;
    c_data_out_7 <= 0;
  end 
  else if (counter >= `MAT_MUL_SIZE) begin
    c_data_out <= c_data_out_1;
    c_addr <= c_addr - address_stride_c; 

    c_data_out_1 <= c_data_out_2;
    c_data_out_2 <= c_data_out_3;
    c_data_out_3 <= c_data_out_4;
    c_data_out_4 <= c_data_out_5;
    c_data_out_5 <= c_data_out_6;
    c_data_out_6 <= c_data_out_7;
    c_data_out_7 <= c_data_in;
  end
  else if (start_capturing_c_data) begin
    c_data_available <= 1'b1;
    c_addr <= c_addr - address_stride_c; 
    counter <= counter + 1;
    c_data_out <= c_data_out_1;

    c_data_out_1 <= c_data_out_2;
    c_data_out_2 <= c_data_out_3;
    c_data_out_3 <= c_data_out_4;
    c_data_out_4 <= c_data_out_5;
    c_data_out_5 <= c_data_out_6;
    c_data_out_6 <= c_data_out_7;
    c_data_out_7 <= c_data_in;
  end
end

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
a_data_delayed,
b_data_delayed,
validity_mask_a_rows,
validity_mask_a_cols_b_rows,
validity_mask_b_cols,
slice_dtype,
final_mat_mul_size,
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
input [7:0] clk_cnt;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed;
input [`MASK_WIDTH-1:0] validity_mask_a_rows;
input [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows;
input [`MASK_WIDTH-1:0] validity_mask_b_cols;
input slice_dtype;
input [7:0] final_mat_mul_size;
input [7:0] a_loc;
input [7:0] b_loc;

//////////////////////////////////////////////////////////////////////////
// Logic to generate addresses to BRAM A
//////////////////////////////////////////////////////////////////////////
reg [`AWIDTH-1:0] a_addr;
reg a_mem_access; //flag that tells whether the matmul is trying to access memory or not

always @(posedge clk) begin
  //(clk_cnt >= a_loc*`MAT_MUL_SIZE+final_mat_mul_size) begin
  //Writing the line above to avoid multiplication:

  if (reset || ~start_mat_mul || (clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin
  
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

//////////////////////////////////////////////////////////////////////////
// Logic to generate valid signals for data coming from BRAM A
//////////////////////////////////////////////////////////////////////////
reg [7:0] a_mem_access_counter;
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

wire a_data_valid_part1;
assign a_data_valid_part1 = 
     ((validity_mask_a_cols_b_rows[0]==1'b0 && a_mem_access_counter==1) ||
      (validity_mask_a_cols_b_rows[1]==1'b0 && a_mem_access_counter==2) ||
      (validity_mask_a_cols_b_rows[2]==1'b0 && a_mem_access_counter==3) ||
      (validity_mask_a_cols_b_rows[3]==1'b0 && a_mem_access_counter==4));

wire a_data_valid_part2;
assign a_data_valid_part2 = 
     ((validity_mask_a_cols_b_rows[4]==1'b0 && a_mem_access_counter==5) ||
      (validity_mask_a_cols_b_rows[5]==1'b0 && a_mem_access_counter==6) ||
      (validity_mask_a_cols_b_rows[6]==1'b0 && a_mem_access_counter==7) ||
      (validity_mask_a_cols_b_rows[7]==1'b0 && a_mem_access_counter==8));


wire a_data_valid; //flag that tells whether the data from memory is valid
assign a_data_valid = 
      (
        (slice_dtype == `DTYPE_FP16) ? a_data_valid_part1 :
        (a_data_valid_part1 || a_data_valid_part2)
      ) ?
       1'b0 : (a_mem_access_counter >= `MEM_ACCESS_LATENCY);


//////////////////////////////////////////////////////////////////////////
// Logic to delay certain parts of the data received from BRAM A (systolic data setup)
//////////////////////////////////////////////////////////////////////////
wire [`MASK_WIDTH-1:0] validity_mask_a_rows_internal;
assign validity_mask_a_rows_internal = (slice_dtype == `DTYPE_INT8) ? 
                                      validity_mask_a_rows : 
                                     {validity_mask_a_rows[3],
                                      validity_mask_a_rows[3], 
                                      validity_mask_a_rows[2],
                                      validity_mask_a_rows[2], 
                                      validity_mask_a_rows[1],
                                      validity_mask_a_rows[1], 
                                      validity_mask_a_rows[0],
                                      validity_mask_a_rows[0]};

wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_validated;
assign a_data_validated[1*`DWIDTH-1:0*`DWIDTH] = (a_data_valid & validity_mask_a_rows_internal[0]) ? a_data[1*`DWIDTH-1:0*`DWIDTH] : {`DWIDTH{1'b0}};
assign a_data_validated[2*`DWIDTH-1:1*`DWIDTH] = (a_data_valid & validity_mask_a_rows_internal[1]) ? a_data[2*`DWIDTH-1:1*`DWIDTH] : {`DWIDTH{1'b0}};
assign a_data_validated[3*`DWIDTH-1:2*`DWIDTH] = (a_data_valid & validity_mask_a_rows_internal[2]) ? a_data[3*`DWIDTH-1:2*`DWIDTH] : {`DWIDTH{1'b0}};
assign a_data_validated[4*`DWIDTH-1:3*`DWIDTH] = (a_data_valid & validity_mask_a_rows_internal[3]) ? a_data[4*`DWIDTH-1:3*`DWIDTH] : {`DWIDTH{1'b0}};
assign a_data_validated[5*`DWIDTH-1:4*`DWIDTH] = (a_data_valid & validity_mask_a_rows_internal[4]) ? a_data[5*`DWIDTH-1:4*`DWIDTH] : {`DWIDTH{1'b0}};
assign a_data_validated[6*`DWIDTH-1:5*`DWIDTH] = (a_data_valid & validity_mask_a_rows_internal[5]) ? a_data[6*`DWIDTH-1:5*`DWIDTH] : {`DWIDTH{1'b0}};
assign a_data_validated[7*`DWIDTH-1:6*`DWIDTH] = (a_data_valid & validity_mask_a_rows_internal[6]) ? a_data[7*`DWIDTH-1:6*`DWIDTH] : {`DWIDTH{1'b0}};
assign a_data_validated[8*`DWIDTH-1:7*`DWIDTH] = (a_data_valid & validity_mask_a_rows_internal[7]) ? a_data[8*`DWIDTH-1:7*`DWIDTH] : {`DWIDTH{1'b0}};


wire flop_rst;
assign flop_rst = (reset || ~start_mat_mul || clk_cnt==0);

wire [`DWIDTH-1:0] a_one_clk_del_int8;
wire [`DWIDTH-1:0] a_two_clk_del_int8;
wire [`DWIDTH-1:0] a_thr_clk_del_int8;
wire [`DWIDTH-1:0] a_fou_clk_del_int8;
wire [`DWIDTH-1:0] a_fiv_clk_del_int8;
wire [`DWIDTH-1:0] a_six_clk_del_int8;
wire [`DWIDTH-1:0] a_sev_clk_del_int8;
wire [`DWIDTH-1:0] a_one_clk_del_fp16;
wire [`DWIDTH-1:0] a_two_clk_del_fp16;
wire [`DWIDTH-1:0] a_thr_clk_del_fp16;
wire [`DWIDTH-1:0] a_fou_clk_del_fp16;
wire [`DWIDTH-1:0] a_fiv_clk_del_fp16;
wire [`DWIDTH-1:0] a_six_clk_del_fp16;
wire [`DWIDTH-1:0] a_sev_clk_del_fp16;

one_clk_delay    u_a_one_clk_delay     (.clk(clk), .rst(flop_rst), .in(a_data_validated[2*`DWIDTH-1:1*`DWIDTH]), .out_int8(a_one_clk_del_int8), .out_fp16(a_one_clk_del_fp16));
two_clk_delay    u_a_two_clk_delay     (.clk(clk), .rst(flop_rst), .in(a_data_validated[3*`DWIDTH-1:2*`DWIDTH]), .out_int8(a_two_clk_del_int8), .out_fp16(a_two_clk_del_fp16));
three_clk_delay  u_a_three_clk_delay   (.clk(clk), .rst(flop_rst), .in(a_data_validated[4*`DWIDTH-1:3*`DWIDTH]), .out_int8(a_thr_clk_del_int8), .out_fp16(a_thr_clk_del_fp16));
four_clk_delay   u_a_four_clk_delay    (.clk(clk), .rst(flop_rst), .in(a_data_validated[5*`DWIDTH-1:4*`DWIDTH]), .out_int8(a_fou_clk_del_int8), .out_fp16(a_fou_clk_del_fp16));
five_clk_delay   u_a_five_clk_delay    (.clk(clk), .rst(flop_rst), .in(a_data_validated[6*`DWIDTH-1:5*`DWIDTH]), .out_int8(a_fiv_clk_del_int8), .out_fp16(a_fiv_clk_del_fp16));
six_clk_delay    u_a_six_clk_delay     (.clk(clk), .rst(flop_rst), .in(a_data_validated[7*`DWIDTH-1:6*`DWIDTH]), .out_int8(a_six_clk_del_int8), .out_fp16(a_six_clk_del_fp16));
seven_clk_delay  u_a_seven_clk_delay   (.clk(clk), .rst(flop_rst), .in(a_data_validated[8*`DWIDTH-1:7*`DWIDTH]), .out_int8(a_sev_clk_del_int8), .out_fp16(a_sev_clk_del_fp16));

assign a_data_delayed[`DWIDTH-1:0]           = a_data_validated[`DWIDTH-1:0];
assign a_data_delayed[2*`DWIDTH-1:1*`DWIDTH] = (slice_dtype == `DTYPE_INT8)? a_one_clk_del_int8 : a_one_clk_del_fp16;
assign a_data_delayed[3*`DWIDTH-1:2*`DWIDTH] = (slice_dtype == `DTYPE_INT8)? a_two_clk_del_int8 : a_two_clk_del_fp16;
assign a_data_delayed[4*`DWIDTH-1:3*`DWIDTH] = (slice_dtype == `DTYPE_INT8)? a_thr_clk_del_int8 : a_thr_clk_del_fp16;
assign a_data_delayed[5*`DWIDTH-1:4*`DWIDTH] = (slice_dtype == `DTYPE_INT8)? a_fou_clk_del_int8 : a_fou_clk_del_fp16;
assign a_data_delayed[6*`DWIDTH-1:5*`DWIDTH] = (slice_dtype == `DTYPE_INT8)? a_fiv_clk_del_int8 : a_fiv_clk_del_fp16;
assign a_data_delayed[7*`DWIDTH-1:6*`DWIDTH] = (slice_dtype == `DTYPE_INT8)? a_six_clk_del_int8 : a_six_clk_del_fp16;
assign a_data_delayed[8*`DWIDTH-1:7*`DWIDTH] = (slice_dtype == `DTYPE_INT8)? a_sev_clk_del_int8 : a_sev_clk_del_fp16;


//////////////////////////////////////////////////////////////////////////
// Logic to generate addresses to BRAM B
//////////////////////////////////////////////////////////////////////////
reg [`AWIDTH-1:0] b_addr;
reg b_mem_access; //flag that tells whether the matmul is trying to access memory or not
always @(posedge clk) begin
  //else if (clk_cnt >= b_loc*`MAT_MUL_SIZE+final_mat_mul_size) begin
  //Writing the line above to avoid multiplication:

  if ((reset || ~start_mat_mul) || (clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin

      b_addr <= address_mat_b - address_stride_b;
  
    b_mem_access <= 0;
  end
  //else if ((clk_cnt >= b_loc*`MAT_MUL_SIZE) && (clk_cnt < b_loc*`MAT_MUL_SIZE+final_mat_mul_size)) begin
  //Writing the line above to avoid multiplication:

  else if ((clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)) && (clk_cnt < (b_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin

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

wire b_data_valid_part1;
assign b_data_valid_part1 = 
     ((validity_mask_a_cols_b_rows[0]==1'b0 && b_mem_access_counter==1) ||
      (validity_mask_a_cols_b_rows[1]==1'b0 && b_mem_access_counter==2) ||
      (validity_mask_a_cols_b_rows[2]==1'b0 && b_mem_access_counter==3) ||
      (validity_mask_a_cols_b_rows[3]==1'b0 && b_mem_access_counter==4));

wire b_data_valid_part2;
assign b_data_valid_part2 = 
     ((validity_mask_a_cols_b_rows[4]==1'b0 && b_mem_access_counter==5) ||
      (validity_mask_a_cols_b_rows[5]==1'b0 && b_mem_access_counter==6) ||
      (validity_mask_a_cols_b_rows[6]==1'b0 && b_mem_access_counter==7) ||
      (validity_mask_a_cols_b_rows[7]==1'b0 && b_mem_access_counter==8));


wire b_data_valid; //flag that tells whether the data from memory is valid
assign b_data_valid = 
      (
        (slice_dtype == `DTYPE_FP16) ? b_data_valid_part1 :
        (b_data_valid_part1 || b_data_valid_part2)
      ) ?
        1'b0 : (b_mem_access_counter >= `MEM_ACCESS_LATENCY);

//////////////////////////////////////////////////////////////////////////
// Logic to delay certain parts of the data received from BRAM B (systolic data setup)
//////////////////////////////////////////////////////////////////////////
wire [`MASK_WIDTH-1:0] validity_mask_b_cols_internal;
assign validity_mask_b_cols_internal = (slice_dtype == `DTYPE_INT8) ? validity_mask_b_cols : {validity_mask_b_cols[3],validity_mask_b_cols[3], validity_mask_b_cols[2],validity_mask_b_cols[2], validity_mask_b_cols[1],validity_mask_b_cols[1], validity_mask_b_cols[0],validity_mask_b_cols[0]};

wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_validated;
assign b_data_validated[1*`DWIDTH-1:0*`DWIDTH] = (b_data_valid & validity_mask_b_cols_internal[0]) ? b_data[1*`DWIDTH-1:0*`DWIDTH] : {`DWIDTH{1'b0}};
assign b_data_validated[2*`DWIDTH-1:1*`DWIDTH] = (b_data_valid & validity_mask_b_cols_internal[1]) ? b_data[2*`DWIDTH-1:1*`DWIDTH] : {`DWIDTH{1'b0}};
assign b_data_validated[3*`DWIDTH-1:2*`DWIDTH] = (b_data_valid & validity_mask_b_cols_internal[2]) ? b_data[3*`DWIDTH-1:2*`DWIDTH] : {`DWIDTH{1'b0}};
assign b_data_validated[4*`DWIDTH-1:3*`DWIDTH] = (b_data_valid & validity_mask_b_cols_internal[3]) ? b_data[4*`DWIDTH-1:3*`DWIDTH] : {`DWIDTH{1'b0}};
assign b_data_validated[5*`DWIDTH-1:4*`DWIDTH] = (b_data_valid & validity_mask_b_cols_internal[4]) ? b_data[5*`DWIDTH-1:4*`DWIDTH] : {`DWIDTH{1'b0}};
assign b_data_validated[6*`DWIDTH-1:5*`DWIDTH] = (b_data_valid & validity_mask_b_cols_internal[5]) ? b_data[6*`DWIDTH-1:5*`DWIDTH] : {`DWIDTH{1'b0}};
assign b_data_validated[7*`DWIDTH-1:6*`DWIDTH] = (b_data_valid & validity_mask_b_cols_internal[6]) ? b_data[7*`DWIDTH-1:6*`DWIDTH] : {`DWIDTH{1'b0}};
assign b_data_validated[8*`DWIDTH-1:7*`DWIDTH] = (b_data_valid & validity_mask_b_cols_internal[7]) ? b_data[8*`DWIDTH-1:7*`DWIDTH] : {`DWIDTH{1'b0}};


wire [`DWIDTH-1:0] b_one_clk_del_int8;
wire [`DWIDTH-1:0] b_two_clk_del_int8;
wire [`DWIDTH-1:0] b_thr_clk_del_int8;
wire [`DWIDTH-1:0] b_fou_clk_del_int8;
wire [`DWIDTH-1:0] b_fiv_clk_del_int8;
wire [`DWIDTH-1:0] b_six_clk_del_int8;
wire [`DWIDTH-1:0] b_sev_clk_del_int8;
wire [`DWIDTH-1:0] b_one_clk_del_fp16;
wire [`DWIDTH-1:0] b_two_clk_del_fp16;
wire [`DWIDTH-1:0] b_thr_clk_del_fp16;
wire [`DWIDTH-1:0] b_fou_clk_del_fp16;
wire [`DWIDTH-1:0] b_fiv_clk_del_fp16;
wire [`DWIDTH-1:0] b_six_clk_del_fp16;
wire [`DWIDTH-1:0] b_sev_clk_del_fp16;

one_clk_delay   u_b_one_clk_delay     (.clk(clk), .rst(flop_rst), .in(b_data_validated[2*`DWIDTH-1:1*`DWIDTH]), .out_int8(b_one_clk_del_int8), .out_fp16(b_one_clk_del_fp16));
two_clk_delay   u_b_two_clk_delay     (.clk(clk), .rst(flop_rst), .in(b_data_validated[3*`DWIDTH-1:2*`DWIDTH]), .out_int8(b_two_clk_del_int8), .out_fp16(b_two_clk_del_fp16));
three_clk_delay u_b_three_clk_delay   (.clk(clk), .rst(flop_rst), .in(b_data_validated[4*`DWIDTH-1:3*`DWIDTH]), .out_int8(b_thr_clk_del_int8), .out_fp16(b_thr_clk_del_fp16));
four_clk_delay  u_b_four_clk_delay    (.clk(clk), .rst(flop_rst), .in(b_data_validated[5*`DWIDTH-1:4*`DWIDTH]), .out_int8(b_fou_clk_del_int8), .out_fp16(b_fou_clk_del_fp16));
five_clk_delay  u_b_five_clk_delay    (.clk(clk), .rst(flop_rst), .in(b_data_validated[6*`DWIDTH-1:5*`DWIDTH]), .out_int8(b_fiv_clk_del_int8), .out_fp16(b_fiv_clk_del_fp16));
six_clk_delay   u_b_six_clk_delay     (.clk(clk), .rst(flop_rst), .in(b_data_validated[7*`DWIDTH-1:6*`DWIDTH]), .out_int8(b_six_clk_del_int8), .out_fp16(b_six_clk_del_fp16));
seven_clk_delay u_b_seven_clk_delay   (.clk(clk), .rst(flop_rst), .in(b_data_validated[8*`DWIDTH-1:7*`DWIDTH]), .out_int8(b_sev_clk_del_int8), .out_fp16(b_sev_clk_del_fp16));

assign b_data_delayed[`DWIDTH-1:0]           = b_data_validated[`DWIDTH-1:0];
assign b_data_delayed[2*`DWIDTH-1:1*`DWIDTH] = (slice_dtype == `DTYPE_INT8)? b_one_clk_del_int8 : b_one_clk_del_fp16;
assign b_data_delayed[3*`DWIDTH-1:2*`DWIDTH] = (slice_dtype == `DTYPE_INT8)? b_two_clk_del_int8 : b_two_clk_del_fp16;
assign b_data_delayed[4*`DWIDTH-1:3*`DWIDTH] = (slice_dtype == `DTYPE_INT8)? b_thr_clk_del_int8 : b_thr_clk_del_fp16;
assign b_data_delayed[5*`DWIDTH-1:4*`DWIDTH] = (slice_dtype == `DTYPE_INT8)? b_fou_clk_del_int8 : b_fou_clk_del_fp16;
assign b_data_delayed[6*`DWIDTH-1:5*`DWIDTH] = (slice_dtype == `DTYPE_INT8)? b_fiv_clk_del_int8 : b_fiv_clk_del_fp16;
assign b_data_delayed[7*`DWIDTH-1:6*`DWIDTH] = (slice_dtype == `DTYPE_INT8)? b_six_clk_del_int8 : b_six_clk_del_fp16;
assign b_data_delayed[8*`DWIDTH-1:7*`DWIDTH] = (slice_dtype == `DTYPE_INT8)? b_sev_clk_del_int8 : b_sev_clk_del_fp16;

endmodule

//////////////////////////////////////////////
// Delay modules - Flops to delay for various number of clocks
//////////////////////////////////////////////
module one_clk_delay(
  input clk,
  input rst,
  input [`DWIDTH-1:0] in,
  output reg [`DWIDTH-1:0] out_int8,
  output [`DWIDTH-1:0] out_fp16
);
//1 clk delay in int8, 0 clk delay in fp16
assign out_fp16 = in;
always @(posedge clk) begin
  if (rst) begin
    out_int8 <= 0;
  end
  else begin
    out_int8 <= in;
  end
end
endmodule

//////////////////////////////////////////////
module two_clk_delay(
  input clk,
  input rst,
  input [`DWIDTH-1:0] in,
  output reg [`DWIDTH-1:0] out_int8,
  output [`DWIDTH-1:0] out_fp16
);
//2 clk delay in int8, 1 clk delay in fp16
reg [`DWIDTH-1:0] in_delayed;
assign out_fp16 = in_delayed;
always @(posedge clk) begin
  if (rst) begin
    in_delayed <= 0;
    out_int8 <= 0;
  end
  else begin
    in_delayed <= in;
    out_int8 <= in_delayed;
  end
end
endmodule

//////////////////////////////////////////////
module three_clk_delay(
  input clk,
  input rst,
  input [`DWIDTH-1:0] in,
  output reg [`DWIDTH-1:0] out_int8,
  output [`DWIDTH-1:0] out_fp16
);
//3 clk delay in int8, 1 clk delay in fp16
reg [`DWIDTH-1:0] in_delayed_1;
reg [`DWIDTH-1:0] in_delayed_2;

assign out_fp16 = in_delayed_1;
always @(posedge clk) begin
  if (rst) begin
    in_delayed_1 <= 0;
    in_delayed_2 <= 0;
    out_int8 <= 0;
  end
  else begin
    in_delayed_1 <= in;
    in_delayed_2 <= in_delayed_1;
    out_int8 <= in_delayed_2;
  end
end
endmodule

//////////////////////////////////////////////
module four_clk_delay(
  input clk,
  input rst,
  input [`DWIDTH-1:0] in,
  output reg [`DWIDTH-1:0] out_int8,
  output [`DWIDTH-1:0] out_fp16
);
//4 clk delay in int8, 2 clk delay in fp16
reg [`DWIDTH-1:0] in_delayed_1;
reg [`DWIDTH-1:0] in_delayed_2;
reg [`DWIDTH-1:0] in_delayed_3;

assign out_fp16 = in_delayed_2;
always @(posedge clk) begin
  if (rst) begin
    in_delayed_1 <= 0;
    in_delayed_2 <= 0;
    in_delayed_3 <= 0;
    out_int8 <= 0;
  end
  else begin
    in_delayed_1 <= in;
    in_delayed_2 <= in_delayed_1;
    in_delayed_3 <= in_delayed_2;
    out_int8 <= in_delayed_3;
  end
end
endmodule

//////////////////////////////////////////////
module five_clk_delay(
  input clk,
  input rst,
  input [`DWIDTH-1:0] in,
  output reg [`DWIDTH-1:0] out_int8,
  output [`DWIDTH-1:0] out_fp16
);
//5 clk delay in int8, 2 clk delay in fp16
reg [`DWIDTH-1:0] in_delayed_1;
reg [`DWIDTH-1:0] in_delayed_2;
reg [`DWIDTH-1:0] in_delayed_3;
reg [`DWIDTH-1:0] in_delayed_4;

assign out_fp16 = in_delayed_2;
always @(posedge clk) begin
  if (rst) begin
    out_int8 <= 0;
    in_delayed_1 <= 0;
    in_delayed_2 <= 0;
    in_delayed_3 <= 0;
    in_delayed_4 <= 0;
  end
  else begin
    in_delayed_1 <= in;
    in_delayed_2 <= in_delayed_1;
    in_delayed_3 <= in_delayed_2;
    in_delayed_4 <= in_delayed_3;
    out_int8 <= in_delayed_4;
  end
end
endmodule

//////////////////////////////////////////////
module six_clk_delay(
  input clk,
  input rst,
  input [`DWIDTH-1:0] in,
  output reg [`DWIDTH-1:0] out_int8,
  output [`DWIDTH-1:0] out_fp16
);
//6 clk delay in int8, 3 clk delay in fp16
reg [`DWIDTH-1:0] in_delayed_1;
reg [`DWIDTH-1:0] in_delayed_2;
reg [`DWIDTH-1:0] in_delayed_3;
reg [`DWIDTH-1:0] in_delayed_4;
reg [`DWIDTH-1:0] in_delayed_5;

assign out_fp16 = in_delayed_3;
always @(posedge clk) begin
  if (rst) begin
    out_int8 <= 0;
    in_delayed_1 <= 0;
    in_delayed_2 <= 0;
    in_delayed_3 <= 0;
    in_delayed_4 <= 0;
    in_delayed_5 <= 0;
  end
  else begin
    in_delayed_1 <= in;
    in_delayed_2 <= in_delayed_1;
    in_delayed_3 <= in_delayed_2;
    in_delayed_4 <= in_delayed_3;
    in_delayed_5 <= in_delayed_4;
    out_int8 <= in_delayed_5;
  end
end
endmodule

//////////////////////////////////////////////
module seven_clk_delay(
  input clk,
  input rst,
  input [`DWIDTH-1:0] in,
  output reg [`DWIDTH-1:0] out_int8,
  output [`DWIDTH-1:0] out_fp16
);
//7 clk delay in int8, 3 clk delay in fp16
reg [`DWIDTH-1:0] in_delayed_1;
reg [`DWIDTH-1:0] in_delayed_2;
reg [`DWIDTH-1:0] in_delayed_3;
reg [`DWIDTH-1:0] in_delayed_4;
reg [`DWIDTH-1:0] in_delayed_5;
reg [`DWIDTH-1:0] in_delayed_6;

assign out_fp16 = in_delayed_3;
always @(posedge clk) begin
  if (rst) begin
    out_int8 <= 0;
    in_delayed_1 <= 0;
    in_delayed_2 <= 0;
    in_delayed_3 <= 0;
    in_delayed_4 <= 0;
    in_delayed_5 <= 0;
    in_delayed_6 <= 0;
  end
  else begin
    in_delayed_1 <= in;
    in_delayed_2 <= in_delayed_1;
    in_delayed_3 <= in_delayed_2;
    in_delayed_4 <= in_delayed_3;
    in_delayed_5 <= in_delayed_4;
    in_delayed_6 <= in_delayed_5;
    out_int8 <= in_delayed_6;
  end
end
endmodule

//////////////////////////////////////////////////////////////////////////
// Systolically connected PEs
//////////////////////////////////////////////////////////////////////////
module systolic_pe_matrix(
clk,
reset,
pe_reset,
a_data,
b_data,
slice_dtype,
slice_mode,
pe_data_out,
a_data_out,
b_data_out,
input_list_to_pes,
output_list_from_pes
);

input clk;
input reset;
input pe_reset;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data;
input slice_dtype;
input slice_mode;
output [511:0] pe_data_out;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out;
input [463:0] input_list_to_pes;
output [239:0] output_list_from_pes;

//////////////////////////////////////////////////////////////////////////
// Instantiations of the actual PEs
//////////////////////////////////////////////////////////////////////////
wire effective_rst;
assign effective_rst = reset | pe_reset;

wire [2*`DWIDTH-1:0] in_a_pe00;
wire [4*`DWIDTH-1:0] in_b_pe00;
wire [2*`DWIDTH-1:0] out_a_pe00;
wire [4*`DWIDTH-1:0] out_b_pe00;
wire [4*`DWIDTH-1:0] out_c_pe00;

wire [2*`DWIDTH-1:0] in_a_pe01;
wire [4*`DWIDTH-1:0] in_b_pe01;
wire [2*`DWIDTH-1:0] out_a_pe01;
wire [4*`DWIDTH-1:0] out_b_pe01;
wire [4*`DWIDTH-1:0] out_c_pe01;

wire [2*`DWIDTH-1:0] in_a_pe02;
wire [4*`DWIDTH-1:0] in_b_pe02;
wire [2*`DWIDTH-1:0] out_a_pe02;
wire [4*`DWIDTH-1:0] out_b_pe02;
wire [4*`DWIDTH-1:0] out_c_pe02;

wire [2*`DWIDTH-1:0] in_a_pe03;
wire [4*`DWIDTH-1:0] in_b_pe03;
wire [2*`DWIDTH-1:0] out_a_pe03;
wire [4*`DWIDTH-1:0] out_b_pe03;
wire [4*`DWIDTH-1:0] out_c_pe03;

wire [2*`DWIDTH-1:0] in_a_pe10;
wire [4*`DWIDTH-1:0] in_b_pe10;
wire [2*`DWIDTH-1:0] out_a_pe10;
wire [4*`DWIDTH-1:0] out_b_pe10;
wire [4*`DWIDTH-1:0] out_c_pe10;

wire [2*`DWIDTH-1:0] in_a_pe11;
wire [4*`DWIDTH-1:0] in_b_pe11;
wire [2*`DWIDTH-1:0] out_a_pe11;
wire [4*`DWIDTH-1:0] out_b_pe11;
wire [4*`DWIDTH-1:0] out_c_pe11;

wire [2*`DWIDTH-1:0] in_a_pe12;
wire [4*`DWIDTH-1:0] in_b_pe12;
wire [2*`DWIDTH-1:0] out_a_pe12;
wire [4*`DWIDTH-1:0] out_b_pe12;
wire [4*`DWIDTH-1:0] out_c_pe12;

wire [2*`DWIDTH-1:0] in_a_pe13;
wire [4*`DWIDTH-1:0] in_b_pe13;
wire [2*`DWIDTH-1:0] out_a_pe13;
wire [4*`DWIDTH-1:0] out_b_pe13;
wire [4*`DWIDTH-1:0] out_c_pe13;

wire [2*`DWIDTH-1:0] in_a_pe20;
wire [4*`DWIDTH-1:0] in_b_pe20;
wire [2*`DWIDTH-1:0] out_a_pe20;
wire [4*`DWIDTH-1:0] out_b_pe20;
wire [4*`DWIDTH-1:0] out_c_pe20;

wire [2*`DWIDTH-1:0] in_a_pe21;
wire [4*`DWIDTH-1:0] in_b_pe21;
wire [2*`DWIDTH-1:0] out_a_pe21;
wire [4*`DWIDTH-1:0] out_b_pe21;
wire [4*`DWIDTH-1:0] out_c_pe21;

wire [2*`DWIDTH-1:0] in_a_pe22;
wire [4*`DWIDTH-1:0] in_b_pe22;
wire [2*`DWIDTH-1:0] out_a_pe22;
wire [4*`DWIDTH-1:0] out_b_pe22;
wire [4*`DWIDTH-1:0] out_c_pe22;

wire [2*`DWIDTH-1:0] in_a_pe23;
wire [4*`DWIDTH-1:0] in_b_pe23;
wire [2*`DWIDTH-1:0] out_a_pe23;
wire [4*`DWIDTH-1:0] out_b_pe23;
wire [4*`DWIDTH-1:0] out_c_pe23;

wire [2*`DWIDTH-1:0] in_a_pe30;
wire [4*`DWIDTH-1:0] in_b_pe30;
wire [2*`DWIDTH-1:0] out_a_pe30;
wire [4*`DWIDTH-1:0] out_b_pe30;
wire [4*`DWIDTH-1:0] out_c_pe30;

wire [2*`DWIDTH-1:0] in_a_pe31;
wire [4*`DWIDTH-1:0] in_b_pe31;
wire [2*`DWIDTH-1:0] out_a_pe31;
wire [4*`DWIDTH-1:0] out_b_pe31;
wire [4*`DWIDTH-1:0] out_c_pe31;

wire [2*`DWIDTH-1:0] in_a_pe32;
wire [4*`DWIDTH-1:0] in_b_pe32;
wire [2*`DWIDTH-1:0] out_a_pe32;
wire [4*`DWIDTH-1:0] out_b_pe32;
wire [4*`DWIDTH-1:0] out_c_pe32;

wire [2*`DWIDTH-1:0] in_a_pe33;
wire [4*`DWIDTH-1:0] in_b_pe33;
wire [2*`DWIDTH-1:0] out_a_pe33;
wire [4*`DWIDTH-1:0] out_b_pe33;
wire [4*`DWIDTH-1:0] out_c_pe33;

assign pe_data_out =  {
                      out_c_pe33[31:0], out_c_pe32[31:0], out_c_pe31[31:0], out_c_pe30[31:0],
                      out_c_pe23[31:0], out_c_pe22[31:0], out_c_pe21[31:0], out_c_pe20[31:0],
                      out_c_pe13[31:0], out_c_pe12[31:0], out_c_pe11[31:0], out_c_pe10[31:0],
                      out_c_pe03[31:0], out_c_pe02[31:0], out_c_pe01[31:0], out_c_pe00[31:0]
                      };
                                              
assign a_data_out = {out_a_pe33, out_a_pe23, out_a_pe13, out_a_pe03};
assign b_data_out = {out_b_pe33, out_b_pe23, out_b_pe13, out_b_pe03};

///////////////////////////////////////////
// First row of PEs 
///////////////////////////////////////////
assign in_a_pe00 = (slice_dtype == `DTYPE_FP16) ? a_data[15:0] : {8'b0, a_data[7:0]};
assign in_b_pe00 = (slice_dtype == `DTYPE_FP16) ? b_data[15:0] : {b_data[7:0], b_data[15:8], b_data[23:16], b_data[31:24]};

wire [2*`DWIDTH-1:0] a0_0to0_1_fp16;
wire [1*`DWIDTH-1:0] a0_3to0_4_int8;
assign a0_0to0_1_fp16 = out_a_pe00;
assign a0_3to0_4_int8 = out_a_pe00[7:0];
assign in_a_pe01 = (slice_dtype == `DTYPE_FP16) ? a0_0to0_1_fp16 : {8'b0, a0_3to0_4_int8};
assign in_b_pe01 = (slice_dtype == `DTYPE_FP16) ? b_data[31:16] : {b_data[39:32], b_data[47:40], b_data[55:48], b_data[63:56]};

wire [2*`DWIDTH-1:0] a0_1to0_2_fp16;
assign a0_1to0_2_fp16 = out_a_pe01;
assign in_a_pe02 = (slice_dtype == `DTYPE_FP16) ? a0_1to0_2_fp16 : {8'b0, a_data[15:8]};
assign in_b_pe02 = (slice_dtype == `DTYPE_FP16) ? b_data[47:32] : out_b_pe00;

wire [2*`DWIDTH-1:0] a0_2to0_3_fp16;
wire [1*`DWIDTH-1:0] a1_3to1_4_int8;
assign a0_2to0_3_fp16 = out_a_pe02;
assign a1_3to1_4_int8 = out_a_pe02[7:0];
assign in_a_pe03 = (slice_dtype == `DTYPE_FP16) ? a0_2to0_3_fp16 : a1_3to1_4_int8;
assign in_b_pe03 = (slice_dtype == `DTYPE_FP16) ? b_data[63:48] : out_b_pe01;


///////////////////////////////////////////
// Second row of PEs 
///////////////////////////////////////////
wire [2*`DWIDTH-1:0] b0_0to1_0_fp16;
assign b0_0to1_0_fp16 = out_b_pe00[15:0];
assign in_a_pe10 = (slice_dtype == `DTYPE_FP16) ? a_data[31:16] : {8'b0, a_data[23:16]};
assign in_b_pe10 = (slice_dtype == `DTYPE_FP16) ? b0_0to1_0_fp16 : out_b_pe02;

wire [2*`DWIDTH-1:0] a1_0to1_1_fp16;
wire [1*`DWIDTH-1:0] a2_3to2_4_int8;
wire [2*`DWIDTH-1:0] b0_1to1_1_fp16;
assign a1_0to1_1_fp16 = out_a_pe10;
assign a2_3to2_4_int8 = out_a_pe10[7:0];
assign b0_1to1_1_fp16 = out_b_pe01[15:0];
assign in_a_pe11 = (slice_dtype == `DTYPE_FP16) ? a1_0to1_1_fp16 : a2_3to2_4_int8;
assign in_b_pe11 = (slice_dtype == `DTYPE_FP16) ? b0_1to1_1_fp16 : out_b_pe03;

wire [2*`DWIDTH-1:0] a1_1to1_2_fp16;
wire [2*`DWIDTH-1:0] b0_2to1_2_fp16;
assign a1_1to1_2_fp16 = out_a_pe11;
assign b0_2to1_2_fp16 = out_b_pe02[15:0];
assign in_a_pe12 = (slice_dtype == `DTYPE_FP16) ? a1_1to1_2_fp16 : {8'b0, a_data[31:24]};
assign in_b_pe12 = (slice_dtype == `DTYPE_FP16) ? b0_2to1_2_fp16 : out_b_pe10;

wire [2*`DWIDTH-1:0] a1_2to1_3_fp16;
wire [1*`DWIDTH-1:0] a3_3to3_4_int8;
wire [2*`DWIDTH-1:0] b0_3to1_3_fp16;
assign a1_2to1_3_fp16 = out_a_pe12;
assign a3_3to3_4_int8 = out_a_pe12[7:0];
assign b0_3to1_3_fp16 = out_b_pe03[15:0];
assign in_a_pe13 = (slice_dtype == `DTYPE_FP16) ? a1_2to1_3_fp16 : {8'b0, a3_3to3_4_int8};
assign in_b_pe13 = (slice_dtype == `DTYPE_FP16) ? b0_3to1_3_fp16 : out_b_pe11;


///////////////////////////////////////////
// Third row of PEs 
///////////////////////////////////////////
wire [2*`DWIDTH-1:0] b1_0to2_0_fp16;
assign b1_0to2_0_fp16 = out_b_pe10[15:0];
assign in_a_pe20 = (slice_dtype == `DTYPE_FP16) ? a_data[47:32] : {8'b0, a_data[39:32]};
assign in_b_pe20 = (slice_dtype == `DTYPE_FP16) ? b1_0to2_0_fp16 : out_b_pe12;

wire [2*`DWIDTH-1:0] a2_0to2_1_fp16;
wire [1*`DWIDTH-1:0] a4_3to4_4_int8;
wire [2*`DWIDTH-1:0] b1_1to2_1_fp16;
assign a2_0to2_1_fp16 = out_a_pe20; 
assign a4_3to4_4_int8 = out_a_pe20[7:0];
assign b1_1to2_1_fp16 = out_b_pe11[15:0];
assign in_a_pe21 = (slice_dtype == `DTYPE_FP16) ? a2_0to2_1_fp16 : a4_3to4_4_int8;
assign in_b_pe21 = (slice_dtype == `DTYPE_FP16) ? b1_1to2_1_fp16 : out_b_pe13;

wire [2*`DWIDTH-1:0] a2_1to2_2_fp16;
wire [2*`DWIDTH-1:0] b1_2to2_2_fp16;
assign a2_1to2_2_fp16 = out_a_pe21;
assign b1_2to2_2_fp16 = out_b_pe12[15:0];
assign in_a_pe22 = (slice_dtype == `DTYPE_FP16) ? a2_1to2_2_fp16 : {8'b0, a_data[47:40]};
assign in_b_pe22 = (slice_dtype == `DTYPE_FP16) ? b1_2to2_2_fp16 : out_b_pe20;

wire [2*`DWIDTH-1:0] a2_2to2_3_fp16;
wire [1*`DWIDTH-1:0] a5_3to5_4_int8;
wire [2*`DWIDTH-1:0] b1_3to2_3_fp16;
assign a2_2to2_3_fp16 = out_a_pe22;
assign a5_3to5_4_int8 = out_a_pe22[7:0];
assign b1_3to2_3_fp16 = out_b_pe13[15:0];
assign in_a_pe23 = (slice_dtype == `DTYPE_FP16) ? a2_2to2_3_fp16 : {8'b0, a5_3to5_4_int8};
assign in_b_pe23 = (slice_dtype == `DTYPE_FP16) ? b1_3to2_3_fp16 : out_b_pe21;


///////////////////////////////////////////
// Fourth row of PEs 
///////////////////////////////////////////
wire [2*`DWIDTH-1:0] b2_0to3_0_fp16;
assign b2_0to3_0_fp16 = out_b_pe20[15:0];
assign in_a_pe30 = (slice_dtype == `DTYPE_FP16) ? a_data[63:48] : {8'b0, a_data[55:48]};
assign in_b_pe30 = (slice_dtype == `DTYPE_FP16) ? b2_0to3_0_fp16 : out_b_pe22;

wire [2*`DWIDTH-1:0] a3_0to3_1_fp16;
wire [1*`DWIDTH-1:0] a6_3to6_4_int8;
wire [2*`DWIDTH-1:0] b2_1to3_1_fp16;
assign a3_0to3_1_fp16 = out_a_pe30;
assign a6_3to6_4_int8 = out_a_pe30[7:0];
assign b2_1to3_1_fp16 = out_b_pe21[15:0];
assign in_a_pe31 = (slice_dtype == `DTYPE_FP16) ? a3_0to3_1_fp16 : a6_3to6_4_int8;
assign in_b_pe31 = (slice_dtype == `DTYPE_FP16) ? b2_1to3_1_fp16 : out_b_pe23;

wire [2*`DWIDTH-1:0] a3_1to3_2_fp16;
wire [2*`DWIDTH-1:0] b2_2to3_2_fp16;
assign a3_1to3_2_fp16 = out_a_pe31;
assign b2_2to3_2_fp16 = out_b_pe22[15:0];
assign in_a_pe32 = (slice_dtype == `DTYPE_FP16) ? a3_1to3_2_fp16 : {8'b0, a_data[63:56]};
assign in_b_pe32 = (slice_dtype == `DTYPE_FP16) ? b2_2to3_2_fp16 : out_b_pe30;

wire [2*`DWIDTH-1:0] a3_2to3_3_fp16;
wire [1*`DWIDTH-1:0] a7_3to7_4_int8;
wire [2*`DWIDTH-1:0] b2_3to3_3_fp16;
assign a3_2to3_3_fp16 = out_a_pe32;
assign a7_3to7_4_int8 = out_a_pe32[7:0];
assign b2_3to3_3_fp16 = out_b_pe23[15:0];
assign in_a_pe33 = (slice_dtype == `DTYPE_FP16) ? a3_2to3_3_fp16 : {8'b0, a7_3to7_4_int8};
assign in_b_pe33 = (slice_dtype == `DTYPE_FP16) ? b2_3to3_3_fp16 : out_b_pe31;


///////////////////////////////////////////////////////////////////////////////////
//Direct input outputs
///////////////////////////////////////////////////////////////////////////////////
//Although we can reuse 4 int8 PEs and 1 fp16 from each combined processing element, 
//we only use 2 int8 PEs and 1 fp16 from each combined processing element in the Individual PE mode.
//
//We have total 464 inputs. Dividing those between in_a, in_b, mode and dtype, we get:
//Per PE: in_a = 16, in_b = 16, mode = 3, dtype = 1
//We can expose 464/(16+16+3+1) = 12.8. That is 12 combined PEs can be exposed.
wire [255:0] direct_inputs_a;     
wire [255:0] direct_inputs_b;    
wire [47:0] direct_inputs_mode;
wire [15:0] direct_inputs_dtype;
assign direct_inputs_a[191:0]     = input_list_to_pes[12*16*1-1 : 12*16*0];
assign direct_inputs_b[191:0]     = input_list_to_pes[12*16*2-1 : 12*16*1];
assign direct_inputs_mode[35:0]   = input_list_to_pes[384+3*12-1 : 384];
assign direct_inputs_dtype[11:0]  = input_list_to_pes[420+12-1: 420];
assign direct_inputs_a[255:192]   = 64'b0;
assign direct_inputs_b[255:192]   = 64'b0;
assign direct_inputs_mode[47:36]  = 12'b0;
assign direct_inputs_dtype[15:12] = 4'b0;

//We have total 240 outputs. From each combined PE, we'll use 16 bits of outputs.
//Since we are exposing 12 combined PEs, we need 12*16 = 192 outputs.
wire [15:0] pe00_direct_out_NC;
wire [15:0] pe01_direct_out_NC;
wire [15:0] pe02_direct_out_NC;
wire [15:0] pe03_direct_out_NC;
wire [15:0] pe10_direct_out_NC;
wire [15:0] pe11_direct_out_NC;
wire [15:0] pe12_direct_out_NC;
wire [15:0] pe13_direct_out_NC;
wire [15:0] pe20_direct_out_NC;
wire [15:0] pe21_direct_out_NC;
wire [15:0] pe22_direct_out_NC;
wire [15:0] pe23_direct_out_NC;
wire [15:0] pe30_direct_out_NC;
wire [15:0] pe31_direct_out_NC;
wire [15:0] pe32_direct_out_NC;
wire [15:0] pe33_direct_out_NC;
wire [15:0] pe00_direct_out;
wire [15:0] pe01_direct_out;
wire [15:0] pe02_direct_out;
wire [15:0] pe03_direct_out;
wire [15:0] pe10_direct_out;
wire [15:0] pe11_direct_out;
wire [15:0] pe12_direct_out;
wire [15:0] pe13_direct_out;
wire [15:0] pe20_direct_out;
wire [15:0] pe21_direct_out;
wire [15:0] pe22_direct_out;
wire [15:0] pe23_direct_out;
wire [15:0] pe30_direct_out;
wire [15:0] pe31_direct_out;
wire [15:0] pe32_direct_out;
wire [15:0] pe33_direct_out;

assign output_list_from_pes = {
  48'b0,
  pe23_direct_out,
  pe22_direct_out,
  pe21_direct_out,
  pe20_direct_out,
  pe13_direct_out,
  pe12_direct_out,
  pe11_direct_out,
  pe10_direct_out,
  pe03_direct_out,
  pe02_direct_out,
  pe01_direct_out,
  pe00_direct_out
};

//                                                                                                               16 bits               32 bits           16 bits             32 bits          32 bits               32 bits                                             32 bits                                    32 bits                                                                                                                           
processing_element pe00(.reset(effective_rst), .clk(clk),  .slice_dtype(slice_dtype), .slice_mode(slice_mode), .in_a(in_a_pe00), .in_b(in_b_pe00), .out_a(out_a_pe00), .out_b(out_b_pe00), .out_c(out_c_pe00), .direct_a({16'b0, direct_inputs_a[16*1 -1:16*0 ]}), .direct_b({16'b0, direct_inputs_b[16*1 -1:16*0 ]}), .direct_out({pe00_direct_out_NC, pe00_direct_out}), .direct_dtype(direct_inputs_dtype[0 ]), .direct_mode(direct_inputs_mode[2:0]));
processing_element pe01(.reset(effective_rst), .clk(clk),  .slice_dtype(slice_dtype), .slice_mode(slice_mode), .in_a(in_a_pe01), .in_b(in_b_pe01), .out_a(out_a_pe01), .out_b(out_b_pe01), .out_c(out_c_pe01), .direct_a({16'b0, direct_inputs_a[16*2 -1:16*1 ]}), .direct_b({16'b0, direct_inputs_b[16*2 -1:16*1 ]}), .direct_out({pe01_direct_out_NC, pe01_direct_out}), .direct_dtype(direct_inputs_dtype[1 ]), .direct_mode(direct_inputs_mode[5:3]));
processing_element pe02(.reset(effective_rst), .clk(clk),  .slice_dtype(slice_dtype), .slice_mode(slice_mode), .in_a(in_a_pe02), .in_b(in_b_pe02), .out_a(out_a_pe02), .out_b(out_b_pe02), .out_c(out_c_pe02), .direct_a({16'b0, direct_inputs_a[16*3 -1:16*2 ]}), .direct_b({16'b0, direct_inputs_b[16*3 -1:16*2 ]}), .direct_out({pe02_direct_out_NC, pe02_direct_out}), .direct_dtype(direct_inputs_dtype[2 ]), .direct_mode(direct_inputs_mode[8:6]));
processing_element pe03(.reset(effective_rst), .clk(clk),  .slice_dtype(slice_dtype), .slice_mode(slice_mode), .in_a(in_a_pe03), .in_b(in_b_pe03), .out_a(out_a_pe03), .out_b(out_b_pe03), .out_c(out_c_pe03), .direct_a({16'b0, direct_inputs_a[16*4 -1:16*3 ]}), .direct_b({16'b0, direct_inputs_b[16*4 -1:16*3 ]}), .direct_out({pe03_direct_out_NC, pe03_direct_out}), .direct_dtype(direct_inputs_dtype[3 ]), .direct_mode(direct_inputs_mode[11:9]));
processing_element pe10(.reset(effective_rst), .clk(clk),  .slice_dtype(slice_dtype), .slice_mode(slice_mode), .in_a(in_a_pe10), .in_b(in_b_pe10), .out_a(out_a_pe10), .out_b(out_b_pe10), .out_c(out_c_pe10), .direct_a({16'b0, direct_inputs_a[16*5 -1:16*4 ]}), .direct_b({16'b0, direct_inputs_b[16*5 -1:16*4 ]}), .direct_out({pe10_direct_out_NC, pe10_direct_out}), .direct_dtype(direct_inputs_dtype[4 ]), .direct_mode(direct_inputs_mode[14:12]));
processing_element pe11(.reset(effective_rst), .clk(clk),  .slice_dtype(slice_dtype), .slice_mode(slice_mode), .in_a(in_a_pe11), .in_b(in_b_pe11), .out_a(out_a_pe11), .out_b(out_b_pe11), .out_c(out_c_pe11), .direct_a({16'b0, direct_inputs_a[16*6 -1:16*5 ]}), .direct_b({16'b0, direct_inputs_b[16*6 -1:16*5 ]}), .direct_out({pe11_direct_out_NC, pe11_direct_out}), .direct_dtype(direct_inputs_dtype[5 ]), .direct_mode(direct_inputs_mode[17:15]));
processing_element pe12(.reset(effective_rst), .clk(clk),  .slice_dtype(slice_dtype), .slice_mode(slice_mode), .in_a(in_a_pe12), .in_b(in_b_pe12), .out_a(out_a_pe12), .out_b(out_b_pe12), .out_c(out_c_pe12), .direct_a({16'b0, direct_inputs_a[16*7 -1:16*6 ]}), .direct_b({16'b0, direct_inputs_b[16*7 -1:16*6 ]}), .direct_out({pe12_direct_out_NC, pe12_direct_out}), .direct_dtype(direct_inputs_dtype[6 ]), .direct_mode(direct_inputs_mode[20:18]));
processing_element pe13(.reset(effective_rst), .clk(clk),  .slice_dtype(slice_dtype), .slice_mode(slice_mode), .in_a(in_a_pe13), .in_b(in_b_pe13), .out_a(out_a_pe13), .out_b(out_b_pe13), .out_c(out_c_pe13), .direct_a({16'b0, direct_inputs_a[16*8 -1:16*7 ]}), .direct_b({16'b0, direct_inputs_b[16*8 -1:16*7 ]}), .direct_out({pe13_direct_out_NC, pe13_direct_out}), .direct_dtype(direct_inputs_dtype[7 ]), .direct_mode(direct_inputs_mode[23:21]));
processing_element pe20(.reset(effective_rst), .clk(clk),  .slice_dtype(slice_dtype), .slice_mode(slice_mode), .in_a(in_a_pe20), .in_b(in_b_pe20), .out_a(out_a_pe20), .out_b(out_b_pe20), .out_c(out_c_pe20), .direct_a({16'b0, direct_inputs_a[16*9 -1:16*8 ]}), .direct_b({16'b0, direct_inputs_b[16*9 -1:16*8 ]}), .direct_out({pe20_direct_out_NC, pe20_direct_out}), .direct_dtype(direct_inputs_dtype[8 ]), .direct_mode(direct_inputs_mode[26:24]));
processing_element pe21(.reset(effective_rst), .clk(clk),  .slice_dtype(slice_dtype), .slice_mode(slice_mode), .in_a(in_a_pe21), .in_b(in_b_pe21), .out_a(out_a_pe21), .out_b(out_b_pe21), .out_c(out_c_pe21), .direct_a({16'b0, direct_inputs_a[16*10-1:16*9 ]}), .direct_b({16'b0, direct_inputs_b[16*10-1:16*9 ]}), .direct_out({pe21_direct_out_NC, pe21_direct_out}), .direct_dtype(direct_inputs_dtype[9 ]), .direct_mode(direct_inputs_mode[29:27]));
processing_element pe22(.reset(effective_rst), .clk(clk),  .slice_dtype(slice_dtype), .slice_mode(slice_mode), .in_a(in_a_pe22), .in_b(in_b_pe22), .out_a(out_a_pe22), .out_b(out_b_pe22), .out_c(out_c_pe22), .direct_a({16'b0, direct_inputs_a[16*11-1:16*10]}), .direct_b({16'b0, direct_inputs_b[16*11-1:16*10]}), .direct_out({pe22_direct_out_NC, pe22_direct_out}), .direct_dtype(direct_inputs_dtype[10]), .direct_mode(direct_inputs_mode[32:30]));
processing_element pe23(.reset(effective_rst), .clk(clk),  .slice_dtype(slice_dtype), .slice_mode(slice_mode), .in_a(in_a_pe23), .in_b(in_b_pe23), .out_a(out_a_pe23), .out_b(out_b_pe23), .out_c(out_c_pe23), .direct_a({16'b0, direct_inputs_a[16*12-1:16*11]}), .direct_b({16'b0, direct_inputs_b[16*12-1:16*11]}), .direct_out({pe23_direct_out_NC, pe23_direct_out}), .direct_dtype(direct_inputs_dtype[11]), .direct_mode(direct_inputs_mode[35:33]));
processing_element pe30(.reset(effective_rst), .clk(clk),  .slice_dtype(slice_dtype), .slice_mode(slice_mode), .in_a(in_a_pe30), .in_b(in_b_pe30), .out_a(out_a_pe30), .out_b(out_b_pe30), .out_c(out_c_pe30), .direct_a({16'b0, direct_inputs_a[16*13-1:16*12]}), .direct_b({16'b0, direct_inputs_b[16*13-1:16*12]}), .direct_out({pe30_direct_out_NC, pe30_direct_out}), .direct_dtype(direct_inputs_dtype[12]), .direct_mode(direct_inputs_mode[38:36]));
processing_element pe31(.reset(effective_rst), .clk(clk),  .slice_dtype(slice_dtype), .slice_mode(slice_mode), .in_a(in_a_pe31), .in_b(in_b_pe31), .out_a(out_a_pe31), .out_b(out_b_pe31), .out_c(out_c_pe31), .direct_a({16'b0, direct_inputs_a[16*14-1:16*13]}), .direct_b({16'b0, direct_inputs_b[16*14-1:16*13]}), .direct_out({pe31_direct_out_NC, pe31_direct_out}), .direct_dtype(direct_inputs_dtype[13]), .direct_mode(direct_inputs_mode[41:39]));
processing_element pe32(.reset(effective_rst), .clk(clk),  .slice_dtype(slice_dtype), .slice_mode(slice_mode), .in_a(in_a_pe32), .in_b(in_b_pe32), .out_a(out_a_pe32), .out_b(out_b_pe32), .out_c(out_c_pe32), .direct_a({16'b0, direct_inputs_a[16*15-1:16*14]}), .direct_b({16'b0, direct_inputs_b[16*15-1:16*14]}), .direct_out({pe32_direct_out_NC, pe32_direct_out}), .direct_dtype(direct_inputs_dtype[14]), .direct_mode(direct_inputs_mode[44:42]));
processing_element pe33(.reset(effective_rst), .clk(clk),  .slice_dtype(slice_dtype), .slice_mode(slice_mode), .in_a(in_a_pe33), .in_b(in_b_pe33), .out_a(out_a_pe33), .out_b(out_b_pe33), .out_c(out_c_pe33), .direct_a({16'b0, direct_inputs_a[16*16-1:16*15]}), .direct_b({16'b0, direct_inputs_b[16*16-1:16*15]}), .direct_out({pe33_direct_out_NC, pe33_direct_out}), .direct_dtype(direct_inputs_dtype[15]), .direct_mode(direct_inputs_mode[47:45]));
endmodule

// This PE acts as one fp16 PE and 4 int8 PEs (connected horizontally)
module processing_element(
 reset, 
 clk, 
 slice_dtype,
 slice_mode,
 in_a,
 in_b,
 out_a,
 out_b,
 out_c,
 direct_a,
 direct_b,
 direct_out,
 direct_dtype,
 direct_mode
 );

 input reset;
 input clk;
 input slice_dtype;
 input slice_mode;
 // Total number of bits:
 // fp16 (one PE):
 // 16 bits of in_a
 // 16 bits of in_b
 // 16 bits of out_a
 // 16 bits of out_b
 // 16 bits of out_c
 // int8 (4 PEs connected horizontally):
 // 8 bits of in_a
 // 32 bits of in_b
 // 8 bits of out_a
 // 32 bits of out_b
 // 32 bits of out_c
 // union:
 // in - 40 bits
 // out - 72 bits
 // definition:
 // fp16 mode:
 // in_a -> in_a[15:0]
 // in_b -> in_b[15:0]
 // out_a -> out_a[15:0]
 // out_b -> out_b[15:0]
 // out_c -> out_c[15:0]
 // int8 mode:
 // in_a -> in_a[7:0]
 // in_b_0 -> in_b[7:0]
 // in_b_1 -> in_b[15:8]
 // in_b_2 -> in_b[23:16]
 // in_b_3 -> in_b[31:24]
 // out_a -> out[7:0]
 // out_b_0 -> out_b[7:0]
 // out_b_1 -> out_b[15:8]
 // out_b_2 -> out_b[23:16]
 // out_b_3 -> out_b[31:24]
 // out_c_0 -> out_c[7:0]
 // out_c_1 -> out_c[15:8]
 // out_c_2 -> out_c[23:16]
 // out_c_3 -> out_c[31:24]
 input  [15:0] in_a; 
 input  [31:0] in_b; 
 output [15:0] out_a;
 output [31:0] out_b;
 output [31:0] out_c;
 input [4*`DWIDTH-1:0] direct_a;
 input [4*`DWIDTH-1:0] direct_b;
 output [4*`DWIDTH-1:0] direct_out;
 input direct_dtype;
 input [2:0] direct_mode;

 reg [2*`DWIDTH-1:0] out_a;
 reg [4*`DWIDTH-1:0] out_b;

 wire [4*`DWIDTH-1:0] out_mac;
 wire [4*`DWIDTH-1:0] a_seq_mac;
 wire [4*`DWIDTH-1:0] b_seq_mac;

 reg [`DWIDTH-1: 0] out_a_0to1;
 reg [`DWIDTH-1: 0] out_a_1to2;
 reg [`DWIDTH-1: 0] out_a_2to3;

 assign a_seq_mac = (slice_dtype == `DTYPE_FP16) ? {16'b0, in_a[15:0]} : {in_a[7:0], out_a_0to1, out_a_1to2, out_a_2to3 };
 assign b_seq_mac = (slice_dtype == `DTYPE_FP16) ? {16'b0, in_b[15:0]} : {in_b[31:24], in_b[23:16], in_b[15:8], in_b[7:0]};

 seq_mac u_mac( .clk(clk), 
                .reset(reset), 
                .a(a_seq_mac), 
                .b(b_seq_mac), 
                .out(out_mac),
                .dtype(slice_dtype), 
                .mode(slice_mode),
                .direct_a(direct_a),
                .direct_b(direct_b),
                .direct_out(direct_out),
                .direct_dtype(direct_dtype),
                .direct_mode(direct_mode));

 //assign out_c[15:0]  = (slice_dtype == `DTYPE_FP16) ? out_mac[15:0] : {out_mac[15:8],  out_mac[7:0]};
 //assign out_c[31:16] = (slice_dtype == `DTYPE_FP16) ? {16{1'b0}}    : {out_mac[31:24], out_mac[23:16]} ;
 //We don't need the muxing above really.
 assign out_c[31:0] = out_mac[31:0];

 always @(posedge clk)begin
    if(reset) begin
      out_a <= 0;
      out_b <= 0;
      out_a_0to1 <= 0;
      out_a_1to2 <= 0;
      out_a_2to3 <= 0;
    end
    else begin  
      out_a[7:0]   <= (slice_dtype == `DTYPE_FP16) ? in_a[7:0]  : out_a_2to3;
      out_a[15:8]  <= (slice_dtype == `DTYPE_FP16) ? in_a[15:8] : 8'b0;
      out_b[7:0]   <= in_b[7:0];
      out_b[15:8]  <= in_b[15:8];
      out_b[23:16] <= (slice_dtype == `DTYPE_FP16) ? 8'b0 : in_b[23:16];
      out_b[31:24] <= (slice_dtype == `DTYPE_FP16) ? 8'b0 : in_b[31:24];
      
      out_a_0to1 <= in_a;
      out_a_1to2 <= out_a_0to1;
      out_a_2to3 <= out_a_1to2;
    end
 end
 
endmodule

// mode - Mode of the whole slice - MATMUL mode or Individual PE mode
// a,b,out - Inputs and outputs in MATMUl mode
// dtype - Precision of the PE in MATMUL mode
// direct_a/direct*out - Inputs and outputs in Individual PE mode
//         31:0  : direct_a
//         31:0  : direct_b
//         31:0  : direct_out
// direct_dtype - Precision in Individual PE mode 
// direct_mode - Mode of operation for the PE in Individiual PE mode
//        [1:0] 
//         00 : MAC mode
//         01 : Multiply mode
//         10 : Adder mode
//        [2]
//          0 : Combinatorial  
//          1 : Sequential 
module seq_mac(clk, reset, a, b, out, dtype, mode, direct_a, direct_b, direct_out, direct_dtype, direct_mode);
input clk;
input reset;
input [4*`DWIDTH-1:0] a;
input [4*`DWIDTH-1:0] b;
output [4*`DWIDTH-1:0] out;
input dtype;
input mode;
input [4*`DWIDTH-1:0] direct_a;
input [4*`DWIDTH-1:0] direct_b;
output [4*`DWIDTH-1:0] direct_out;
input direct_dtype;
input [2:0] direct_mode;

wire indiv_pe_mode;
assign indiv_pe_mode = (mode == `SLICE_MODE_INDIV_PE);

wire comb_mode;
assign comb_mode = ~direct_mode[2];

wire indiv_adder_mode;
assign indiv_adder_mode = indiv_pe_mode && direct_mode[1] && (~direct_mode[0]);

wire indiv_mult_mode;
assign indiv_mult_mode = indiv_pe_mode && (~direct_mode[1]) && direct_mode[0];

wire muxed_dtype;
assign muxed_dtype = indiv_pe_mode ? direct_dtype : dtype;

wire [4*`DWIDTH-1:0] mux1a_out; //32 bits
wire [4*`DWIDTH-1:0] mux1b_out; //32 bits
assign mux1a_out = (indiv_pe_mode ? direct_a : a);
assign mux1b_out = (indiv_pe_mode ? direct_b : b);

reg [4*`DWIDTH-1:0] a_flopped; //32 bits
reg [4*`DWIDTH-1:0] b_flopped; //32 bits

always @(posedge clk) begin
  if (reset) begin
    a_flopped <= 0;
    b_flopped <= 0;
  end else begin
    a_flopped <= mux1a_out;
    b_flopped <= mux1b_out;
  end
end

wire [4*`DWIDTH-1:0] mux2a_out; //32 bits
wire [4*`DWIDTH-1:0] mux2b_out; //32 bits
assign mux2a_out = comb_mode ? mux1a_out: a_flopped;
assign mux2b_out = comb_mode ? mux1b_out: b_flopped;

wire [8*`DWIDTH-1:0] mul_out; //64 bits
//                            32 bits                   32 bits              64 bits
qmult mult_u1(.i_multiplicand(mux2a_out), .i_multiplier(mux2b_out), .o_result(mul_out), .dtype(muxed_dtype), .dont_convert_fp16_to_fp32(indiv_mult_mode));

reg [8*`DWIDTH-1:0] mul_out_reg;
always @(posedge clk) begin
  if (reset) begin
    mul_out_reg <= 0;
  end else begin
    mul_out_reg <= mul_out;
  end
end

wire [8*`DWIDTH-1:0] mux3_out;
//Disabling this mux. This was applicable only in the combinatorial MAC mode.
//But with this mux in place, we get a critical path containing both the adder and
//the multiplier. Removing the mux means we will have a flop stage in between the
//multiplier and the adder, in the combinatorial MAC mode. So, combinatorial MAC
//mode refers to the mode in which there are no flop stages on the IOs. There are
//flop stages inside though.
//assign mux3_out = comb_mode ? mul_out : mul_out_reg;
assign mux3_out = mul_out_reg;

wire [8*`DWIDTH-1:0] mux4_out;
assign mux4_out = indiv_adder_mode ? mux2a_out : mux3_out;

reg [8*`DWIDTH-1:0] out_temp;
wire [8*`DWIDTH-1:0] mux7_out;
assign mux7_out = indiv_adder_mode ? mux2b_out : out_temp;

wire [8*`DWIDTH-1:0] add_out;
//             64 bits       64 bits         64 bits
qadd add_u1(.a(mux7_out), .b(mux4_out), .c(add_out), .dtype(muxed_dtype), .convert_fp16_to_fp32(indiv_adder_mode));

wire [8*`DWIDTH-1:0] mux5_out;
assign mux5_out = indiv_mult_mode ? mul_out : add_out;

always @(posedge clk) begin
  if (reset) begin
    out_temp <= 0;
  end else begin
    out_temp <= mux5_out;
  end
end

wire [8*`DWIDTH-1:0] mux6_out;
assign mux6_out = comb_mode ? mux5_out : out_temp;

//fp32 to fp16 conversion
wire [31:0] fpadd_32_result;
wire [15:0] fpadd_16_result;
fp32_to_fp16 u_32to16 (.a(fpadd_32_result), .b(fpadd_16_result));

//int16 to int8 conversion
wire [7:0] int8_add_result0;
wire [7:0] int8_add_result1;
wire [7:0] int8_add_result2;
wire [7:0] int8_add_result3;
int16_to_int8 u_16to8_0(.a(mux6_out[15:0]),  .b(int8_add_result0));
int16_to_int8 u_16to8_1(.a(mux6_out[31:16]), .b(int8_add_result1));
int16_to_int8 u_16to8_2(.a(mux6_out[47:32]), .b(int8_add_result2));
int16_to_int8 u_16to8_3(.a(mux6_out[63:48]), .b(int8_add_result3));

//Reduce precision
assign out[4*`DWIDTH-1:0] = (muxed_dtype == `DTYPE_INT8) ? {int8_add_result3, int8_add_result2, int8_add_result1, int8_add_result0} : fpadd_16_result;

// direct_out will go straight to the primary IO of the slice
assign direct_out = out;
endmodule

/////////////////////////////////////////
// Converter for int16 to int8
/////////////////////////////////////////
module int16_to_int8(
  input [15:0] a,
  output [7:0] b
);

//down cast the result
assign b = 
    (a[2*`DWIDTH-1] == 0) ?  //positive number
        (
           (|(a[2*`DWIDTH-2 : `DWIDTH-1])) ?  //is any bit from 14:7 is 1, that means overlfow
             {a[2*`DWIDTH-1] , {(`DWIDTH-1){1'b1}}} : //sign bit and then all 1s
             {a[2*`DWIDTH-1] , a[`DWIDTH-2:0]} 
        )
        : //negative number
        (
           (|(a[2*`DWIDTH-2 : `DWIDTH-1])) ?  //is any bit from 14:7 is 0, that means overlfow
             {a[2*`DWIDTH-1] , a[`DWIDTH-2:0]} :
             {a[2*`DWIDTH-1] , {(`DWIDTH-1){1'b0}}} //sign bit and then all 0s
        );
endmodule

/////////////////////////////////////////
// For int8:
// Multiplication: 8 bits * 8 bits -> 16 bits  
// Addition:       16 bits + 16 bits -> 16 bits (then cast this to  bits)
// We can provide an option to do accumulation/addition 
// in 8 bits, but that can come later.
//
// For fp16:
// Multiplication: 16 bits * 16 bits -> 16 bits (then cast this to 32 bits)
// Addition:       32 bits + 32 bits -> 32 bits (then cast this to 16 bits)
// We can provide an option to do accumulation/addition 
// in 16 bits, but that can come later.

//4 int8 multipliers, one fp16 multiplier
module qmult(i_multiplicand, i_multiplier, o_result, dtype, dont_convert_fp16_to_fp32);
input [4*`DWIDTH-1:0] i_multiplicand;
input [4*`DWIDTH-1:0] i_multiplier;
output [8*`DWIDTH-1:0] o_result;
input dtype;
input dont_convert_fp16_to_fp32;

  //reg [8*`DWIDTH-1:0] o_result;
  //reg [8*`DWIDTH-1:0] o_result_temp;
  
  //always @(*) begin
  //  if (dtype == `DTYPE_INT8) begin
  //    o_result[15:0]  = i_multiplicand[7:0]   * i_multiplier[7:0];
  //    o_result[31:16] = i_multiplicand[15:8]  * i_multiplier[15:8];
  //    o_result[47:32] = i_multiplicand[23:16] * i_multiplier[23:16];
  //    o_result[63:48] = i_multiplicand[31:24] * i_multiplier[31:24];
  //  end
  //  else begin
  //    //Fake fp multiplication.
  //    //Also, fake casting from 16 to 32 bits here
  //    o_result_temp[31:0] = i_multiplicand[15:0] * i_multiplier[15:0];
  //    o_result[31:0] = {15'b0, o_result_temp[15:0]};
  //  end
  //end
  
	wire [10:0] fixed_pt_mantissa_mult_inp_a;
	wire [10:0] fixed_pt_mantissa_mult_inp_b;
  wire [7:0] mult_shared_in_a_1;
  wire [7:0] mult_shared_in_a_2;
  wire [7:0] mult_shared_in_a_3;
  wire [7:0] mult_shared_in_a_4;
  wire [7:0] mult_shared_in_b_1;
  wire [7:0] mult_shared_in_b_2;
  wire [7:0] mult_shared_in_b_3;
  wire [7:0] mult_shared_in_b_4;
  wire [15:0] mult_shared_out_1;
  wire [15:0] mult_shared_out_2;
  wire [15:0] mult_shared_out_3;
  wire [15:0] mult_shared_out_4;

  //These are the 4 actual multipliers. They are shared in fixed point and floating point modes.
  //In fixed point mode, they act as 8 bit * 8 bit multipliers.
  //In floating point mode, we only need 1 multiplier, but that is 11 bit x 11 bit. So, we split that
  //over 4 8 bit * 8 bit multipliers. We split 11 bits into 5 bits and 6 bits.
  assign mult_shared_out_1 = mult_shared_in_a_1 * mult_shared_in_b_1;
  assign mult_shared_out_2 = mult_shared_in_a_2 * mult_shared_in_b_2;
  assign mult_shared_out_3 = mult_shared_in_a_3 * mult_shared_in_b_3;
  assign mult_shared_out_4 = mult_shared_in_a_4 * mult_shared_in_b_4;

  assign mult_shared_in_a_1 = (dtype == `DTYPE_INT8) ? i_multiplicand[7:0]  : {2'b0, fixed_pt_mantissa_mult_inp_a[5:0]};
  assign mult_shared_in_b_1 = (dtype == `DTYPE_INT8) ? i_multiplier[7:0]    : {2'b0, fixed_pt_mantissa_mult_inp_b[5:0]};

  assign mult_shared_in_a_2 = (dtype == `DTYPE_INT8) ? i_multiplicand[15:8] : {3'b0, fixed_pt_mantissa_mult_inp_a[10:6]};
  assign mult_shared_in_b_2 = (dtype == `DTYPE_INT8) ? i_multiplier[15:8]   : {3'b0, fixed_pt_mantissa_mult_inp_b[10:6]};

  assign mult_shared_in_a_3 = (dtype == `DTYPE_INT8) ? i_multiplicand[23:16] : {2'b0, fixed_pt_mantissa_mult_inp_a[5:0]};
  assign mult_shared_in_b_3 = (dtype == `DTYPE_INT8) ? i_multiplier[23:16]   : {3'b0, fixed_pt_mantissa_mult_inp_b[10:6]};

  assign mult_shared_in_a_4 = (dtype == `DTYPE_INT8) ? i_multiplicand[31:24] : {3'b0, fixed_pt_mantissa_mult_inp_a[10:6]};
  assign mult_shared_in_b_4 = (dtype == `DTYPE_INT8) ? i_multiplier[31:24]   : {2'b0, fixed_pt_mantissa_mult_inp_b[5:0]};

  //Logic only for floating point mode:
  //Now, let's add the 4 partial sums. Take only few bits that we need, not all area required. Need to shift as well.
  //                                               6+5 bits                        6+5 bits                               5+5 bits                         6+6 bits
  //                                           shifted by 6 bits               shifted by 6 bits                      shifted by 6+6 bits                 not shifted
  //assign fixed_pt_mantissa_mult_out = (mult_shared_out_4[10:0] << 3'd6) + (mult_shared_out_3[10:0] << 3'd6) + (mult_shared_out_2[9:0] << 4'd12) + mult_shared_out_1[11:0]

  //Let's split into smaller additions, instead of adding in one line and leaving it on synthesis tool to synthesize.
  wire [11:0] fixed_pt_mantissa_mult_temp1;
  assign fixed_pt_mantissa_mult_temp1 = (mult_shared_out_4[10:0] + mult_shared_out_3[10:0]);
  wire [17:0] fixed_pt_mantissa_mult_temp2;
  assign fixed_pt_mantissa_mult_temp2 = {fixed_pt_mantissa_mult_temp1, 6'b000000};
  wire [21:0] fixed_pt_mantissa_mult_temp3;
  assign fixed_pt_mantissa_mult_temp3 = {mult_shared_out_2[9:0], 12'b000000000000};
  wire [21:0] fixed_pt_mantissa_mult_temp4;
  assign fixed_pt_mantissa_mult_temp4 = fixed_pt_mantissa_mult_temp3 + mult_shared_out_1[11:0];
  wire [21:0] fixed_pt_mantissa_mult_out;
  assign fixed_pt_mantissa_mult_out = fixed_pt_mantissa_mult_temp3 + fixed_pt_mantissa_mult_temp4;

  wire [4:0] fpmult_16_flags_NC;
  wire fpmult_16_clk_NC;
  wire fpmult_16_rst_NC;
  wire [15:0] fpmult_16_result;

  FPMult_16 u_fpmult_16(
    .clk(fpmult_16_clk_NC),
    .rst(fpmult_16_rst_NC),
    .a(i_multiplicand[15:0]),
    .b(i_multiplier[15:0]),
    .result(fpmult_16_result),
    .flags(fpmult_16_flags_NC),
    .fixed_pt_mantissa_mult_inp_a(fixed_pt_mantissa_mult_inp_a),
    .fixed_pt_mantissa_mult_inp_b(fixed_pt_mantissa_mult_inp_b),
    .fixed_pt_mantissa_mult_out(fixed_pt_mantissa_mult_out)
  );

  //Convert fp16 to fp32
  wire [31:0] fpmult_32_result;
  fp16_to_fp32 u_16to32 (.a(fpmult_16_result), .b(fpmult_32_result));

  //In fixed point, the outputs of the 8 bit multipliers above is the output.
  //In floating point, the output comes from the FPMult instance above and it converted to 32bits in the module above.
  assign o_result = (dtype == `DTYPE_INT8) ? {mult_shared_out_4, mult_shared_out_3, mult_shared_out_2, mult_shared_out_1} : 
                    ( dont_convert_fp16_to_fp32 ? {48'b0, fpmult_16_result} :  {32'b0, fpmult_32_result} );

endmodule

//4 int8 adders (actually int16 adders because we support accumulation in higher precision), one fp16 adder (actually fp32 adder)
module qadd(a, b, c, dtype, convert_fp16_to_fp32);
input [8*`DWIDTH-1:0] a;
input [8*`DWIDTH-1:0] b;
output [8*`DWIDTH-1:0] c;
input dtype;
input convert_fp16_to_fp32;

//reg [8*`DWIDTH-1:0] c;
//
//always @(*) begin
//  if (dtype == `DTYPE_INT8) begin
//    c[15:0]  = a[15:0]  + b[15:0];
//    c[31:16] = a[31:16] + b[31:16];
//    c[47:32] = a[47:32] + b[47:32];
//    c[63:48] = a[63:48] + b[63:48];
//  end
//  else begin
//    Fake fp32 addition
//    c[31:0] = a[31:0] + b[31:0];
//  end
//end

//Actual adders. These adders are shared in fixed point and floating point modes
//We needed 4 16-bit adders for the fixed point mode, and 1 32-bit floating point adder.
//Inside the 32-bit floating point adder, we have some fixed point adders that we will share with the 16-bit fixed point adders.
//We are instantiating 8 8-bit adders. 
//In fixed point mode, these 8 8-bit adders will combine to be used as 4 16-bit adders.
//In floating point mode, the 32-floating point adder (instantiated below) requires 4 fixed point adders:
// Adder 1  -> 8 bit fixed point adder
// Adder 2  -> 8 bit fixed point adder
// Adder 34 -> 24 bit fixed point adder
// Adder 5  -> 8 bit fixed point adder

wire [7:0] add_shared_a_1;
wire [7:0] add_shared_b_1;
wire       add_shared_cin_1;
wire [7:0] add_shared_out_1;
wire       add_shared_cout_1;
wire       add_shared_op_1;

wire [7:0] add_shared_a_2;
wire [7:0] add_shared_b_2;
wire       add_shared_cin_2;
wire [7:0] add_shared_out_2;
wire       add_shared_cout_2;
wire       add_shared_op_2;

wire [7:0] add_shared_a_3;
wire [7:0] add_shared_b_3;
wire       add_shared_cin_3;
wire [7:0] add_shared_out_3;
wire       add_shared_cout_3;
wire       add_shared_op_3;

wire [7:0] add_shared_a_4;
wire [7:0] add_shared_b_4;
wire       add_shared_cin_4;
wire [7:0] add_shared_out_4;
wire       add_shared_cout_4;
wire       add_shared_op_4;

wire [7:0] add_shared_a_5;
wire [7:0] add_shared_b_5;
wire       add_shared_cin_5;
wire [7:0] add_shared_out_5;
wire       add_shared_cout_5;
wire       add_shared_op_5;

wire [7:0] add_shared_a_6;
wire [7:0] add_shared_b_6;
wire       add_shared_cin_6;
wire [7:0] add_shared_out_6;
wire       add_shared_cout_6;
wire       add_shared_op_6;

wire [7:0] add_shared_a_7;
wire [7:0] add_shared_b_7;
wire       add_shared_cin_7;
wire [7:0] add_shared_out_7;
wire       add_shared_cout_7;
wire       add_shared_op_7;

wire [7:0] add_shared_a_8;
wire [7:0] add_shared_b_8;
wire       add_shared_cin_8;
wire [7:0] add_shared_out_8;
wire       add_shared_cout_8;
wire       add_shared_op_8;


addsub_8bit  u_addsub_8bit_1 (.a(add_shared_a_1), .b(add_shared_b_1), .cin(add_shared_cin_1), .out(add_shared_out_1), .cout(add_shared_cout_1), .op(add_shared_op_1));
addsub_8bit  u_addsub_8bit_2 (.a(add_shared_a_2), .b(add_shared_b_2), .cin(add_shared_cin_2), .out(add_shared_out_2), .cout(add_shared_cout_2), .op(add_shared_op_2));
addsub_8bit  u_addsub_8bit_3 (.a(add_shared_a_3), .b(add_shared_b_1), .cin(add_shared_cin_3), .out(add_shared_out_3), .cout(add_shared_cout_3), .op(add_shared_op_3));
addsub_8bit  u_addsub_8bit_4 (.a(add_shared_a_4), .b(add_shared_b_2), .cin(add_shared_cin_4), .out(add_shared_out_4), .cout(add_shared_cout_4), .op(add_shared_op_4));
addsub_8bit  u_addsub_8bit_5 (.a(add_shared_a_5), .b(add_shared_b_1), .cin(add_shared_cin_5), .out(add_shared_out_5), .cout(add_shared_cout_5), .op(add_shared_op_5));
addsub_8bit  u_addsub_8bit_6 (.a(add_shared_a_6), .b(add_shared_b_2), .cin(add_shared_cin_6), .out(add_shared_out_6), .cout(add_shared_cout_6), .op(add_shared_op_6));
addsub_8bit  u_addsub_8bit_7 (.a(add_shared_a_7), .b(add_shared_b_1), .cin(add_shared_cin_7), .out(add_shared_out_7), .cout(add_shared_cout_7), .op(add_shared_op_7));
addsub_8bit  u_addsub_8bit_8 (.a(add_shared_a_8), .b(add_shared_b_2), .cin(add_shared_cin_8), .out(add_shared_out_8), .cout(add_shared_cout_8), .op(add_shared_op_8));

wire [7:0] fixed_pt_adder1_in_a;
wire [7:0] fixed_pt_adder1_in_b;
wire       fixed_pt_adder1_mode;
wire       fixed_pt_adder1_cin;
wire [7:0] fixed_pt_adder1_out;
wire       fixed_pt_adder1_cout;

wire [7:0] fixed_pt_adder2_in_a;
wire [7:0] fixed_pt_adder2_in_b;
wire       fixed_pt_adder2_mode;
wire       fixed_pt_adder2_cin;
wire [7:0] fixed_pt_adder2_out;
wire       fixed_pt_adder2_cout;

wire [23:0] fixed_pt_adder34_in_a;
wire [23:0] fixed_pt_adder34_in_b;
wire        fixed_pt_adder34_mode;
wire        fixed_pt_adder34_cin;
wire [23:0] fixed_pt_adder34_out;
wire        fixed_pt_adder34_cout;

wire [7:0] fixed_pt_adder5_in_a;
wire [7:0] fixed_pt_adder5_in_b;
wire       fixed_pt_adder5_mode;
wire       fixed_pt_adder5_cin;
wire [7:0] fixed_pt_adder5_out;
wire       fixed_pt_adder5_cout;

wire [4:0] fpadd_32_flags_NC;
wire fpadd_32_clk_NC;
wire fpadd_32_rst_NC;
wire [31:0] fpadd_32_result;

//Convert fp16 to fp32 (in case of individual adder mode because the input that comes in is actually fp16)
wire [31:0] fp32_in_a;
wire [31:0] fp32_in_b;
fp16_to_fp32 u_16to32_1 (.a(a[15:0]), .b(fp32_in_a));
fp16_to_fp32 u_16to32_2 (.a(b[15:0]), .b(fp32_in_b));

wire [31:0] actual_fp32_in_a;
wire [31:0] actual_fp32_in_b;
assign actual_fp32_in_a = convert_fp16_to_fp32 ? fp32_in_a : a[31:0];
assign actual_fp32_in_b = convert_fp16_to_fp32 ? fp32_in_b : b[31:0];

//Instantiation of the floating point adder block
FPAddSub u_fpaddsub_32(
  .clk(fpadd_32_clk_NC),
  .rst(fpadd_32_rst_NC),
  .a(actual_fp32_in_a),
  .b(actual_fp32_in_b),
  .operation(1'b0), //addition
  .result(fpadd_32_result),
  .flags(fpadd_32_flags_NC), 
    //8 bit adder exposed outside
  .fixed_pt_adder1_in_a(fixed_pt_adder1_in_a),
  .fixed_pt_adder1_in_b(fixed_pt_adder1_in_b),
  .fixed_pt_adder1_mode(fixed_pt_adder1_mode),
  .fixed_pt_adder1_cin(fixed_pt_adder1_cin),
  .fixed_pt_adder1_out(fixed_pt_adder1_out),
  .fixed_pt_adder1_cout(fixed_pt_adder1_cout),
    //8 bit adder exposed outside
  .fixed_pt_adder2_in_a(fixed_pt_adder2_in_a),
  .fixed_pt_adder2_in_b(fixed_pt_adder2_in_b),
  .fixed_pt_adder2_mode(fixed_pt_adder2_mode),
  .fixed_pt_adder2_cin(fixed_pt_adder2_cin),
  .fixed_pt_adder2_out(fixed_pt_adder2_out),
  .fixed_pt_adder2_cout(fixed_pt_adder2_cout),
    //24 bit adder exposed outside
  .fixed_pt_adder34_in_a(fixed_pt_adder34_in_a),
  .fixed_pt_adder34_in_b(fixed_pt_adder34_in_b),
  .fixed_pt_adder34_mode(fixed_pt_adder34_mode),
  .fixed_pt_adder34_cin(fixed_pt_adder34_cin),
  .fixed_pt_adder34_out(fixed_pt_adder34_out),
  .fixed_pt_adder34_cout(fixed_pt_adder34_cout),
    //8 bit adder exposed outside
  .fixed_pt_adder5_in_a(fixed_pt_adder5_in_a),
  .fixed_pt_adder5_in_b(fixed_pt_adder5_in_b),
  .fixed_pt_adder5_mode(fixed_pt_adder5_mode),
  .fixed_pt_adder5_cin(fixed_pt_adder5_cin),
  .fixed_pt_adder5_out(fixed_pt_adder5_out),
  .fixed_pt_adder5_cout(fixed_pt_adder5_cout)
	);

assign add_shared_a_1 = (dtype == `DTYPE_INT8) ? a[7:0]   : fixed_pt_adder1_in_a;
assign add_shared_a_2 = (dtype == `DTYPE_INT8) ? a[15:8]  : fixed_pt_adder2_in_a;
assign add_shared_a_3 = (dtype == `DTYPE_INT8) ? a[23:16] : fixed_pt_adder5_in_a;
assign add_shared_a_4 = (dtype == `DTYPE_INT8) ? a[31:24] : fixed_pt_adder34_in_a[7:0];
assign add_shared_a_5 = (dtype == `DTYPE_INT8) ? a[39:32] : fixed_pt_adder34_in_a[15:8];
assign add_shared_a_6 = (dtype == `DTYPE_INT8) ? a[47:40] : fixed_pt_adder34_in_a[23:16];
assign add_shared_a_7 = (dtype == `DTYPE_INT8) ? a[55:48] : 8'b0;
assign add_shared_a_8 = (dtype == `DTYPE_INT8) ? a[63:56] : 8'b0;

assign add_shared_b_1 = (dtype == `DTYPE_INT8) ? b[7:0]   : fixed_pt_adder1_in_b;
assign add_shared_b_2 = (dtype == `DTYPE_INT8) ? b[15:8]  : fixed_pt_adder2_in_b;
assign add_shared_b_3 = (dtype == `DTYPE_INT8) ? b[23:16] : fixed_pt_adder5_in_b;
assign add_shared_b_4 = (dtype == `DTYPE_INT8) ? b[31:24] : fixed_pt_adder34_in_b[7:0];
assign add_shared_b_5 = (dtype == `DTYPE_INT8) ? b[39:32] : fixed_pt_adder34_in_b[15:8];
assign add_shared_b_6 = (dtype == `DTYPE_INT8) ? b[47:40] : fixed_pt_adder34_in_b[23:16];
assign add_shared_b_7 = (dtype == `DTYPE_INT8) ? b[55:48] : 8'b0;
assign add_shared_b_8 = (dtype == `DTYPE_INT8) ? b[63:56] : 8'b0;

assign add_shared_cin_1 = (dtype == `DTYPE_INT8) ? 1'b0 : fixed_pt_adder1_cin;
//Minor hack here. In individual PE adder more, we want to expose 2 8-bit adders. 
//So we don't want to connect the cout from LSB adder to the next one.
//Signal convert_fp16_to_fp32 is a proxy for individual PE adder mode.
assign add_shared_cin_2 = (dtype == `DTYPE_INT8) ? ( convert_fp16_to_fp32 ? 1'b0 : add_shared_cout_1 ) : fixed_pt_adder2_cin;
assign add_shared_cin_3 = (dtype == `DTYPE_INT8) ? 1'b0 : fixed_pt_adder5_cin;
assign add_shared_cin_4 = (dtype == `DTYPE_INT8) ? add_shared_cout_3 : fixed_pt_adder34_cin;
assign add_shared_cin_5 = (dtype == `DTYPE_INT8) ? 1'b0 : add_shared_cout_4;
assign add_shared_cin_6 = (dtype == `DTYPE_INT8) ? add_shared_cout_5 : add_shared_cout_5;
assign add_shared_cin_7 = (dtype == `DTYPE_INT8) ? 1'b0 : 1'b0;
assign add_shared_cin_8 = (dtype == `DTYPE_INT8) ? add_shared_cout_7 : 1'b0;

assign add_shared_op_1 = (dtype == `DTYPE_INT8) ? 1'b0 : fixed_pt_adder1_mode;
assign add_shared_op_2 = (dtype == `DTYPE_INT8) ? 1'b0 : fixed_pt_adder2_mode;
assign add_shared_op_3 = (dtype == `DTYPE_INT8) ? 1'b0 : fixed_pt_adder5_mode;
assign add_shared_op_4 = (dtype == `DTYPE_INT8) ? 1'b0 : fixed_pt_adder34_mode;
assign add_shared_op_5 = (dtype == `DTYPE_INT8) ? 1'b0 : fixed_pt_adder34_mode;
assign add_shared_op_6 = (dtype == `DTYPE_INT8) ? 1'b0 : fixed_pt_adder34_mode;
assign add_shared_op_7 = (dtype == `DTYPE_INT8) ? 1'b0 : 1'b0;
assign add_shared_op_8 = (dtype == `DTYPE_INT8) ? 1'b0 : 1'b0;

assign c[15:0 ] = (dtype == `DTYPE_INT8) ? {add_shared_out_2, add_shared_out_1} : fpadd_32_result[15:0];
assign c[31:16] = (dtype == `DTYPE_INT8) ? {add_shared_out_4, add_shared_out_3} : fpadd_32_result[31:16];
assign c[47:32] = (dtype == `DTYPE_INT8) ? {add_shared_out_6, add_shared_out_5} : 15'b0;
assign c[63:48] = (dtype == `DTYPE_INT8) ? {add_shared_out_8, add_shared_out_7} : 15'b0;

assign fixed_pt_adder1_out = add_shared_out_1;
assign fixed_pt_adder1_cout = add_shared_cout_1;
assign fixed_pt_adder2_out = add_shared_out_2;
assign fixed_pt_adder2_cout = add_shared_cout_2;
assign fixed_pt_adder5_out = add_shared_out_3;
assign fixed_pt_adder5_cout = add_shared_cout_3;
assign fixed_pt_adder34_out = {add_shared_out_6, add_shared_out_5, add_shared_out_4};
assign fixed_pt_adder34_cout = add_shared_cout_6;

endmodule

/////////////////////////////////////////
// Adder/Subtractor module (8bit integer)
/////////////////////////////////////////
module addsub_8bit(a,b,cin,out,cout,op);
input [7:0] a;
input [7:0] b;
input cin;
output [7:0] out;
output cout;
input op; //0 means addition, 1 means subtraction

assign {cout, out} = (op==0) ? (a + b + cin) : (a - b - cin);

endmodule

