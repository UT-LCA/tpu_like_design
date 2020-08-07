
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
qmult mult_u1(.i_multiplicand(mux2a_out), .i_multiplier(mux2b_out), .o_result(mul_out), .dtype(muxed_dtype));

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
qadd add_u1(.a(mux7_out), .b(mux4_out), .c(add_out), .dtype(muxed_dtype));

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

//Reduce precision
//TODO: For now, this is just faking it
assign out[4*`DWIDTH-1:0] = (muxed_dtype == `DTYPE_INT8) ? {mux6_out[55:48], mux6_out[39:32], mux6_out[23:16], mux6_out[7:0]} : fpadd_16_result;

// direct_out will go straight to the primary IO of the slice
assign direct_out = out;
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
module qmult(i_multiplicand, i_multiplier, o_result, dtype);
input [4*`DWIDTH-1:0] i_multiplicand;
input [4*`DWIDTH-1:0] i_multiplier;
output [8*`DWIDTH-1:0] o_result;
input dtype;

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
  assign o_result = (dtype == `DTYPE_INT8) ? {mult_shared_out_4, mult_shared_out_3, mult_shared_out_2, mult_shared_out_1} : {31'b0, fpmult_32_result};

endmodule

//4 int8 adders (actually int16 adders because we support accumulation in higher precision), one fp16 adder (actually fp32 adder)
module qadd(a, b, c, dtype);
input [8*`DWIDTH-1:0] a;
input [8*`DWIDTH-1:0] b;
output [8*`DWIDTH-1:0] c;
input dtype;

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

//Instantiation of the floating point adder block
FPAddSub u_fpaddsub_32(
  .clk(fpadd_32_clk_NC),
  .rst(fpadd_32_rst_NC),
  .a(a[31:0]),
  .b(b[31:0]),
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
assign add_shared_cin_2 = (dtype == `DTYPE_INT8) ? add_shared_cout_1 : fixed_pt_adder2_cin;
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

module addsub_8bit(a,b,cin,out,cout,op);
input [7:0] a;
input [7:0] b;
input cin;
output [7:0] out;
output cout;
input op; //0 means addition, 1 means subtraction

assign {cout, out} = (op==0) ? (a + b + cin) : (a - b - cin);

endmodule


`timescale 1ns/1ns
//`define DWIDTH 8
//`define AWIDTH 11
//`define MEM_SIZE 2048
//
//`define MAT_MUL_SIZE 8
//`define MASK_WIDTH 8
//`define LOG2_MAT_MUL_SIZE 3
//
//`define BB_MAT_MUL_SIZE `MAT_MUL_SIZE
//`define NUM_CYCLES_IN_MAC 3
//`define MEM_ACCESS_LATENCY 1
//`define REG_DATAWIDTH 32
//`define REG_ADDRWIDTH 8
//`define ADDR_STRIDE_WIDTH 8
//`define MAX_BITS_POOL 3

//Design with memories
module matrix_multiplication(
  clk, 
  clk_mem, 
  resetn, 
  pe_resetn,
  address_mat_a,
  address_mat_b,
  address_mat_c,
  address_stride_a,
  address_stride_b,
  address_stride_c,
  validity_mask_a_rows,
  validity_mask_a_cols_b_rows,
  validity_mask_b_cols,
  bram_addr_a_ext,
  bram_rdata_a_ext,
  bram_wdata_a_ext,
  bram_we_a_ext,
  bram_addr_b_ext,
  bram_rdata_b_ext,
  bram_wdata_b_ext,
  bram_we_b_ext,
  bram_addr_c_ext,
  bram_rdata_c_ext,
  bram_wdata_c_ext,
  bram_we_c_ext,
  start_reg,
  clear_done_reg,
  slice_dtype,
  slice_mode,
  final_mat_mul_size,
  a_loc,
  b_loc,
  a_data_in,
  b_data_in,
  c_data_in
);

  input clk;
  input clk_mem;
  input resetn;
  input pe_resetn;
  input [`AWIDTH-1:0] address_mat_a;
  input [`AWIDTH-1:0] address_mat_b;
  input [`AWIDTH-1:0] address_mat_c;
  input [`ADDR_STRIDE_WIDTH-1:0] address_stride_a;
  input [`ADDR_STRIDE_WIDTH-1:0] address_stride_b;
  input [`ADDR_STRIDE_WIDTH-1:0] address_stride_c;
  input [`MASK_WIDTH-1:0] validity_mask_a_rows;
  input [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows;
  input [`MASK_WIDTH-1:0] validity_mask_b_cols;
  input  [`AWIDTH-1:0] bram_addr_a_ext;
  output [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_ext;
  input  [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_ext;
  input  [`MASK_WIDTH-1:0] bram_we_a_ext;
  input  [`AWIDTH-1:0] bram_addr_b_ext;
  output [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_ext;
  input  [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_ext;
  input  [`MASK_WIDTH-1:0] bram_we_b_ext;
  input  [`AWIDTH-1:0] bram_addr_c_ext;
  output [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_ext;
  input  [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_ext;
  input  [`MASK_WIDTH-1:0] bram_we_c_ext;
  input start_reg;
  input clear_done_reg;
  input slice_dtype;
  input slice_mode;
  input [7:0] final_mat_mul_size;
  input [7:0] a_loc;
  input [7:0] b_loc;
  input [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in;
  input [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in;
  input [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in;

	wire [`AWIDTH-1:0] bram_addr_a;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a;
	wire [`MASK_WIDTH-1:0] bram_we_a;
	wire bram_en_a;

	wire [`AWIDTH-1:0] bram_addr_b;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b;
	wire [`MASK_WIDTH-1:0] bram_we_b;
	wire bram_en_b;
	
	wire [`AWIDTH-1:0] bram_addr_c;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c;
	wire [`MASK_WIDTH-1:0] bram_we_c;
	wire bram_en_c;

  reg [3:0] state;

////////////////////////////////////////////////////////////////
// BRAM matrix A 
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
// BRAM matrix B 
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
// BRAM matrix C 
////////////////////////////////////////////////////////////////
ram matrix_C (
  .addr0(bram_addr_c),
  .d0(bram_wdata_c), 
  .we0(bram_we_c), 
  .q0(bram_rdata_c), 
  .addr1(bram_addr_c_ext),
  .d1(bram_wdata_c_ext), 
  .we1(bram_we_c_ext), 
  .q1(bram_rdata_c_ext), 
  .clk(clk_mem));

reg start_mat_mul;
wire done_mat_mul;
	
	always @( posedge clk) begin
      if (resetn == 1'b0) begin
        state <= 4'b0000;
        start_mat_mul <= 1'b0;
      end else begin
        case (state)
        4'b0000: begin
          start_mat_mul <= 1'b0;
          if (start_reg == 1'b1) begin
            state <= 4'b0001;
          end else begin
            state <= 4'b0000;
          end
        end
        
        4'b0001: begin
          start_mat_mul <= 1'b1;	      
          state <= 4'b1010;                    
        end      
        
        
        4'b1010: begin                 
          if (done_mat_mul == 1'b1) begin
            start_mat_mul <= 1'b0;
            state <= 4'b1000;
          end
          else begin
            state <= 4'b1010;
          end
        end

       4'b1000: begin
         if (clear_done_reg == 1'b1) begin
           state <= 4'b0000;
         end
         else begin
           state <= 4'b1000;
         end
       end
      endcase  
	end 
  end

wire c_data_available;

//Connections for bram c (output matrix)
//bram_addr_c -> connected to u_matmul_4x4 block
//bram_rdata_c -> not used
//bram_wdata_c -> connected to u_matmul_4x4 block
//bram_we_c -> set to 1 when c_data is available
//bram_en_c -> hardcoded to 1 

  assign bram_en_c = 1'b1;
  assign bram_we_c = (c_data_available) ? 8'b11111111 : 8'b00000000;  

//Connections for bram a (first input matrix)
//bram_addr_a -> connected to u_matmul_4x4
//bram_rdata_a -> connected to u_matmul_4x4
//bram_wdata_a -> hardcoded to 0 (this block only reads from bram a)
//bram_we_a -> hardcoded to 0 (this block only reads from bram a)
//bram_en_a -> hardcoded to 1

  assign bram_wdata_a = 32'b0;
  assign bram_en_a = 1'b1;
  assign bram_we_a = 8'b0;
  
//Connections for bram b (second input matrix)
//bram_addr_b -> connected to u_matmul_4x4
//bram_rdata_b -> connected to u_matmul_4x4
//bram_wdata_b -> hardcoded to 0 (this block only reads from bram b)
//bram_we_b -> hardcoded to 0 (this block only reads from bram b)
//bram_en_b -> hardcoded to 1

  assign bram_wdata_b = 32'b0;
  assign bram_en_b = 1'b1;
  assign bram_we_b = 8'b0;
  
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out_NC;
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out_NC;

wire reset;
assign reset = ~resetn;
wire pe_reset;
assign pe_reset = ~pe_resetn;

matmul_slice u_matmul_8x8(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
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
  .a_data_in(a_data_in),
  .b_data_in(b_data_in),
  .c_data_in(c_data_in),
  .c_data_out(bram_wdata_c),
  .a_data_out(a_data_out_NC),
  .b_data_out(b_data_out_NC),
  .a_addr(bram_addr_a),
  .b_addr(bram_addr_b),
  .c_addr(bram_addr_c),
  .c_data_available(c_data_available),
  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .slice_dtype(slice_dtype),
  .slice_mode(slice_mode),
  .final_mat_mul_size(final_mat_mul_size),
  .a_loc(a_loc),
  .b_loc(b_loc)
);

endmodule  

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

`ifdef VCS
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

`timescale 1ns / 1ps
`define EXPONENT 5
`define MANTISSA 10
`define ACTUAL_MANTISSA 11
`define EXPONENT_LSB 10
`define EXPONENT_MSB 14
`define MANTISSA_LSB 0
`define MANTISSA_MSB 9
`define MANTISSA_MUL_SPLIT_LSB 3
`define MANTISSA_MUL_SPLIT_MSB 9
`define SIGN 1
`define SIGN_LOC 15
`define FP_DWIDTH (`SIGN+`EXPONENT+`MANTISSA)
`define IEEE_COMPLIANCE 1
//////////////////////////////////////////////////////////////////////////////////
//
// Create Date:    08:40:21 09/19/2012 
// Module Name:    FPMult
// Project Name: 	 Floating Point Project
// Author:			 Fredrik Brosser
//
//////////////////////////////////////////////////////////////////////////////////

module FPMult_16(
		clk,
		rst,
		a,
		b,
		result,
		flags,
		fixed_pt_mantissa_mult_inp_a,
		fixed_pt_mantissa_mult_inp_b,
		fixed_pt_mantissa_mult_out
    );
	
	// Input Ports
	input clk ;							// Clock
	input rst ;							// Reset signal
	input [`FP_DWIDTH-1:0] a;					// Input A, a 32-bit floating point number
	input [`FP_DWIDTH-1:0] b;					// Input B, a 32-bit floating point number
	
	// Output ports
	output [`FP_DWIDTH-1:0] result ;					// Product, result of the operation, 32-bit FP number
	output [4:0] flags ;				// Flags indicating exceptions according to IEEE754
	
    // Sending multiplication inputs outside, doing the actual multiplication outside and then getting the product back in
	output [`MANTISSA:0] fixed_pt_mantissa_mult_inp_a;
	output [`MANTISSA:0] fixed_pt_mantissa_mult_inp_b;
	input [2*`MANTISSA+1:0] fixed_pt_mantissa_mult_out;	

	// Internal signals
	wire [31:0] Z_int ;				// Product, result of the operation, 32-bit FP number
	wire [4:0] Flags_int ;			// Flags indicating exceptions according to IEEE754
	
	wire Sa ;							// A's sign
	wire Sb ;							// B's sign
	wire Sp ;							// Product sign
	wire [`EXPONENT-1:0] Ea ;					// A's exponent
	wire [`EXPONENT-1:0] Eb ;					// B's exponent
	wire [2*`MANTISSA+1:0] Mp ;					// Product mantissa
	wire [4:0] InputExc ;			// Exceptions in inputs
	wire [`MANTISSA-1:0] NormM ;				// Normalized mantissa
	wire [`EXPONENT:0] NormE ;				// Normalized exponent
	wire [`MANTISSA:0] RoundM ;				// Normalized mantissa
	wire [`EXPONENT:0] RoundE ;				// Normalized exponent
	wire [`MANTISSA:0] RoundMP ;				// Normalized mantissa
	wire [`EXPONENT:0] RoundEP ;				// Normalized exponent
	wire GRS ;

	//reg [63:0] pipe_0;			// Pipeline register Input->Prep
	reg [2*`FP_DWIDTH-1:0] pipe_0;			// Pipeline register Input->Prep

	//reg [92:0] pipe_1;			// Pipeline register Prep->Execute
	reg [3*`MANTISSA+2*`EXPONENT+7:0] pipe_1;			// Pipeline register Prep->Execute

	//reg [38:0] pipe_2;			// Pipeline register Execute->Normalize
	reg [`MANTISSA+`EXPONENT+7:0] pipe_2;			// Pipeline register Execute->Normalize
	
	//reg [72:0] pipe_3;			// Pipeline register Normalize->Round
	reg [2*`MANTISSA+2*`EXPONENT+10:0] pipe_3;			// Pipeline register Normalize->Round

	//reg [36:0] pipe_4;			// Pipeline register Round->Output
	reg [`FP_DWIDTH+4:0] pipe_4;			// Pipeline register Round->Output
	
	assign result = pipe_4[`FP_DWIDTH+4:5] ;
	assign flags = pipe_4[4:0] ;
	
	// Prepare the operands for alignment and check for exceptions
	FPMult_PrepModule PrepModule(clk, rst, pipe_0[2*`FP_DWIDTH-1:`FP_DWIDTH], pipe_0[`FP_DWIDTH-1:0], Sa, Sb, Ea[`EXPONENT-1:0], Eb[`EXPONENT-1:0], Mp[2*`MANTISSA+1:0], InputExc[4:0],
	                             fixed_pt_mantissa_mult_inp_a, fixed_pt_mantissa_mult_inp_b, fixed_pt_mantissa_mult_out) ;

	// Perform (unsigned) mantissa multiplication
	FPMult_ExecuteModule ExecuteModule(pipe_1[3*`MANTISSA+`EXPONENT*2+7:2*`MANTISSA+2*`EXPONENT+8], pipe_1[2*`MANTISSA+2*`EXPONENT+7:2*`MANTISSA+7], pipe_1[2*`MANTISSA+6:5], pipe_1[2*`MANTISSA+2*`EXPONENT+6:2*`MANTISSA+`EXPONENT+7], pipe_1[2*`MANTISSA+`EXPONENT+6:2*`MANTISSA+7], pipe_1[2*`MANTISSA+2*`EXPONENT+8], pipe_1[2*`MANTISSA+2*`EXPONENT+7], Sp, NormE[`EXPONENT:0], NormM[`MANTISSA-1:0], GRS) ;

	// Round result and if necessary, perform a second (post-rounding) normalization step
	FPMult_NormalizeModule NormalizeModule(pipe_2[`MANTISSA-1:0], pipe_2[`MANTISSA+`EXPONENT:`MANTISSA], RoundE[`EXPONENT:0], RoundEP[`EXPONENT:0], RoundM[`MANTISSA:0], RoundMP[`MANTISSA:0]) ;		

	// Round result and if necessary, perform a second (post-rounding) normalization step
	//FPMult_RoundModule RoundModule(pipe_3[47:24], pipe_3[23:0], pipe_3[65:57], pipe_3[56:48], pipe_3[66], pipe_3[67], pipe_3[72:68], Z_int[31:0], Flags_int[4:0]) ;		
	FPMult_RoundModule RoundModule(pipe_3[2*`MANTISSA+1:`MANTISSA+1], pipe_3[`MANTISSA:0], pipe_3[2*`MANTISSA+2*`EXPONENT+3:2*`MANTISSA+`EXPONENT+3], pipe_3[2*`MANTISSA+`EXPONENT+2:2*`MANTISSA+2], pipe_3[2*`MANTISSA+2*`EXPONENT+4], pipe_3[2*`MANTISSA+2*`EXPONENT+5], pipe_3[2*`MANTISSA+2*`EXPONENT+10:2*`MANTISSA+2*`EXPONENT+6], Z_int[`FP_DWIDTH-1:0], Flags_int[4:0]) ;		

	always @ (*) begin	
		if(rst) begin
			pipe_0 = 0;
			pipe_1 = 0;
			pipe_2 = 0; 
			pipe_3 = 0;
			pipe_4 = 0;
		end 
		else begin		
			/* PIPE 0
				[63:32] A
				[31:0] B
			*/
            pipe_0 = {a, b} ;

			/* PIPE 1
				[70] Sa
				[69] Sb
				[68:61] Ea
				[60:53] Eb
				[52:5] Mp
				[4:0] InputExc
			*/
			//pipe_1 <= {pipe_0[`FP_DWIDTH+`MANTISSA-1:`FP_DWIDTH], pipe_0[`MANTISSA_MUL_SPLIT_LSB-1:0], Sa, Sb, Ea[`EXPONENT-1:0], Eb[`EXPONENT-1:0], Mp[2*`MANTISSA-1:0], InputExc[4:0]} ;
			pipe_1 = {pipe_0[`FP_DWIDTH+`MANTISSA-1:`FP_DWIDTH], pipe_0[8:0], Sa, Sb, Ea[`EXPONENT-1:0], Eb[`EXPONENT-1:0], Mp[2*`MANTISSA+1:0], InputExc[4:0]} ;
			/* PIPE 2
				[38:34] InputExc
				[33] GRS
				[32] Sp
				[31:23] NormE
				[22:0] NormM
			*/
			pipe_2 = {pipe_1[4:0], GRS, Sp, NormE[`EXPONENT:0], NormM[`MANTISSA-1:0]} ;
			/* PIPE 3
				[72:68] InputExc
				[67] GRS
				[66] Sp	
				[65:57] RoundE
				[56:48] RoundEP
				[47:24] RoundM
				[23:0] RoundMP
			*/
			pipe_3 = {pipe_2[`EXPONENT+`MANTISSA+7:`EXPONENT+`MANTISSA+1], RoundE[`EXPONENT:0], RoundEP[`EXPONENT:0], RoundM[`MANTISSA:0], RoundMP[`MANTISSA:0]} ;
			/* PIPE 4
				[36:5] Z
				[4:0] Flags
			*/				
			pipe_4 = {Z_int[`FP_DWIDTH-1:0], Flags_int[4:0]} ;
		end
	end
		
endmodule


module FPMult_PrepModule (
		clk,
		rst,
		a,
		b,
		Sa,
		Sb,
		Ea,
		Eb,
		Mp,
		InputExc,
		fixed_pt_mantissa_mult_inp_a,
		fixed_pt_mantissa_mult_inp_b,
		fixed_pt_mantissa_mult_out
	);
	
	// Input ports
	input clk ;
	input rst ;
	input [`FP_DWIDTH-1:0] a ;								// Input A, a 32-bit floating point number
	input [`FP_DWIDTH-1:0] b ;								// Input B, a 32-bit floating point number
	
	// Output ports
	output Sa ;										// A's sign
	output Sb ;										// B's sign
	output [`EXPONENT-1:0] Ea ;								// A's exponent
	output [`EXPONENT-1:0] Eb ;								// B's exponent
	output [2*`MANTISSA+1:0] Mp ;							// Mantissa product
	output [4:0] InputExc ;						// Input numbers are exceptions

    // Sending multiplication inputs outside, doing the actual multiplication outside and then getting the product back in
	output [`MANTISSA:0] fixed_pt_mantissa_mult_inp_a;
	output [`MANTISSA:0] fixed_pt_mantissa_mult_inp_b;
	input [2*`MANTISSA+1:0] fixed_pt_mantissa_mult_out;	

	wire dummy;
	assign dummy = clk | rst;
	
	// Internal signals							// If signal is high...
	wire ANaN ;										// A is a signalling NaN
	wire BNaN ;										// B is a signalling NaN
	wire AInf ;										// A is infinity
	wire BInf ;										// B is infinity
    wire [`MANTISSA-1:0] Ma;
    wire [`MANTISSA-1:0] Mb;
	
	assign ANaN = &(a[`FP_DWIDTH-2:`MANTISSA]) &  |(a[`FP_DWIDTH-2:`MANTISSA]) ;			// All one exponent and not all zero mantissa - NaN
	assign BNaN = &(b[`FP_DWIDTH-2:`MANTISSA]) &  |(b[`MANTISSA-1:0]);			// All one exponent and not all zero mantissa - NaN
	assign AInf = &(a[`FP_DWIDTH-2:`MANTISSA]) & ~|(a[`FP_DWIDTH-2:`MANTISSA]) ;		// All one exponent and all zero mantissa - Infinity
	assign BInf = &(b[`FP_DWIDTH-2:`MANTISSA]) & ~|(b[`FP_DWIDTH-2:`MANTISSA]) ;		// All one exponent and all zero mantissa - Infinity
	
	// Check for any exceptions and put all flags into exception vector
	assign InputExc = {(ANaN | BNaN | AInf | BInf), ANaN, BNaN, AInf, BInf} ;
	//assign InputExc = {(ANaN | ANaN | BNaN |BNaN), ANaN, ANaN, BNaN,BNaN} ;
	
	// Take input numbers apart
	assign Sa = a[`FP_DWIDTH-1] ;							// A's sign
	assign Sb = b[`FP_DWIDTH-1] ;							// B's sign
	assign Ea = a[`FP_DWIDTH-2:`MANTISSA];						// Store A's exponent in Ea, unless A is an exception
	assign Eb = b[`FP_DWIDTH-2:`MANTISSA];						// Store B's exponent in Eb, unless B is an exception	
//    assign Ma = a[`MANTISSA_MSB:`MANTISSA_LSB];
  //  assign Mb = b[`MANTISSA_MSB:`MANTISSA_LSB];
	


	//assign Mp = ({4'b0001, a[`MANTISSA-1:0]}*{4'b0001, b[`MANTISSA-1:9]}) ;
	//For fp16, this is a 10 bit x 10 bit multiplier
	//assign Mp = ({1'b1,a[`MANTISSA-1:0]}*{1'b1, b[`MANTISSA-1:0]}) ;
	assign fixed_pt_mantissa_mult_inp_a = {1'b1, b[`MANTISSA-1:0]};
	assign fixed_pt_mantissa_mult_inp_b = {1'b1, a[`MANTISSA-1:0]};
	assign Mp = fixed_pt_mantissa_mult_out;

	
    //We multiply part of the mantissa here
    //Full mantissa of A
    //Bits MANTISSA_MUL_SPLIT_MSB:MANTISSA_MUL_SPLIT_LSB of B
   // wire [`ACTUAL_MANTISSA-1:0] inp_A;
   // wire [`ACTUAL_MANTISSA-1:0] inp_B;
   // assign inp_A = {1'b1, Ma};
   // assign inp_B = {{(`MANTISSA-(`MANTISSA_MUL_SPLIT_MSB-`MANTISSA_MUL_SPLIT_LSB+1)){1'b0}}, 1'b1, Mb[`MANTISSA_MUL_SPLIT_MSB:`MANTISSA_MUL_SPLIT_LSB]};
   // DW02_mult #(`ACTUAL_MANTISSA,`ACTUAL_MANTISSA) u_mult(.A(inp_A), .B(inp_B), .TC(1'b0), .PRODUCT(Mp));
endmodule


module FPMult_ExecuteModule(
		a,
		b,
		MpC,
		Ea,
		Eb,
		Sa,
		Sb,
		Sp,
		NormE,
		NormM,
		GRS
    );

	// Input ports
	input [`MANTISSA-1:0] a ;
	input [2*`EXPONENT:0] b ;
	input [2*`MANTISSA+1:0] MpC ;
	input [`EXPONENT-1:0] Ea ;						// A's exponent
	input [`EXPONENT-1:0] Eb ;						// B's exponent
	input Sa ;								// A's sign
	input Sb ;								// B's sign
	
	// Output ports
	output Sp ;								// Product sign
	output [`EXPONENT:0] NormE ;													// Normalized exponent
	output [`MANTISSA-1:0] NormM ;												// Normalized mantissa
	output GRS ;
	
	wire [2*`MANTISSA+1:0] Mp ;

	wire dummy;
	assign dummy = a | b;
	
	assign Sp = (Sa ^ Sb) ;												// Equal signs give a positive product
	
   // wire [`ACTUAL_MANTISSA-1:0] inp_a;
   // wire [`ACTUAL_MANTISSA-1:0] inp_b;
   // assign inp_a = {1'b1, a};
   // assign inp_b = {{(`MANTISSA-`MANTISSA_MUL_SPLIT_LSB){1'b0}}, 1'b0, b};
   // DW02_mult #(`ACTUAL_MANTISSA,`ACTUAL_MANTISSA) u_mult(.A(inp_a), .B(inp_b), .TC(1'b0), .PRODUCT(Mp_temp));
   // DW01_add #(2*`ACTUAL_MANTISSA) u_add(.A(Mp_temp), .B(MpC<<`MANTISSA_MUL_SPLIT_LSB), .CI(1'b0), .SUM(Mp), .CO());

	//assign Mp = (MpC<<(2*`EXPONENT+1)) + ({4'b0001, a[`MANTISSA-1:0]}*{1'b0, b[2*`EXPONENT:0]}) ;
	assign Mp = MpC;


	assign NormM = (Mp[2*`MANTISSA+1] ? Mp[2*`MANTISSA:`MANTISSA+1] : Mp[2*`MANTISSA-1:`MANTISSA]); 	// Check for overflow
	assign NormE = (Ea + Eb + Mp[2*`MANTISSA+1]);								// If so, increment exponent
	
	assign GRS = ((Mp[`MANTISSA]&(Mp[`MANTISSA+1]))|(|Mp[`MANTISSA-1:0])) ;
	
endmodule

module FPMult_NormalizeModule(
		NormM,
		NormE,
		RoundE,
		RoundEP,
		RoundM,
		RoundMP
    );

	// Input Ports
	input [`MANTISSA-1:0] NormM ;									// Normalized mantissa
	input [`EXPONENT:0] NormE ;									// Normalized exponent

	// Output Ports
	output [`EXPONENT:0] RoundE ;
	output [`EXPONENT:0] RoundEP ;
	output [`MANTISSA:0] RoundM ;
	output [`MANTISSA:0] RoundMP ; 
	
	assign RoundE = NormE - 15 ;
	assign RoundEP = NormE - 14 ;
	assign RoundM = NormM ;
	assign RoundMP = NormM ;

endmodule

module FPMult_RoundModule(
		RoundM,
		RoundMP,
		RoundE,
		RoundEP,
		Sp,
		GRS,
		InputExc,
		Z,
		Flags
    );

	// Input Ports
	input [`MANTISSA:0] RoundM ;									// Normalized mantissa
	input [`MANTISSA:0] RoundMP ;									// Normalized exponent
	input [`EXPONENT:0] RoundE ;									// Normalized mantissa + 1
	input [`EXPONENT:0] RoundEP ;									// Normalized exponent + 1
	input Sp ;												// Product sign
	input GRS ;
	input [4:0] InputExc ;
	
	// Output Ports
	output [`FP_DWIDTH-1:0] Z ;										// Final product
	output [4:0] Flags ;
	
	// Internal Signals
	wire [`EXPONENT:0] FinalE ;									// Rounded exponent
	wire [`MANTISSA:0] FinalM;
	wire [`MANTISSA:0] PreShiftM;
	
	assign PreShiftM = GRS ? RoundMP : RoundM ;	// Round up if R and (G or S)
	
	// Post rounding normalization (potential one bit shift> use shifted mantissa if there is overflow)
	assign FinalM = (PreShiftM[`MANTISSA] ? {1'b0, PreShiftM[`MANTISSA:1]} : PreShiftM[`MANTISSA:0]) ;
	
	assign FinalE = (PreShiftM[`MANTISSA] ? RoundEP : RoundE) ; // Increment exponent if a shift was done
	
	assign Z = {Sp, FinalE[`EXPONENT-1:0], FinalM[`MANTISSA-1:0]} ;   // Putting the pieces together
	assign Flags = InputExc[4:0];

endmodule

/*
module FPMult_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [`FP_DWIDTH-1:0] a;
	reg [`FP_DWIDTH-1:0] b;

	// Outputs
	wire [`FP_DWIDTH-1:0] result;
	wire [4:0] flags;
	
	integer i ;

	// Instantiate the Unit Under Test (UUT)
	FPMult_16 uut (
		.clk(clk), 
		.rst(rst), 
		.a(a), 
		.b(b), 
		.result(result), 
		.flags(flags)
	);

	always begin
		#5 clk = ~clk;
	end
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		a = 0;
		b = 0;

		// Wait 10 ns for global reset to finish
		#10;
        
		// Add stimulus here

		// expected: 1987h
		#10 a = 16'h1234; b = 16'h4321;
		
		// expected: c244h
		#10 a = 16'hE37B; b = 16'h1AB4; 	
		
		// expected: 0859h
		#10 a = 16'hABCD; b = 16'h9876;


		#100 

		#10 $finish; 

	end
      
endmodule
*/`timescale 1ns / 1ps
module FPAddSub(
		clk,
		rst,
		a,
		b,
		operation,
		result,
		flags, 

        //8 bit adder exposed outside
	    fixed_pt_adder1_in_a,
	    fixed_pt_adder1_in_b,
	    fixed_pt_adder1_mode,
	    fixed_pt_adder1_cin,
	    fixed_pt_adder1_out,
	    fixed_pt_adder1_cout,

        //8 bit adder exposed outside
	    fixed_pt_adder2_in_a,
	    fixed_pt_adder2_in_b,
	    fixed_pt_adder2_mode,
	    fixed_pt_adder2_cin,
	    fixed_pt_adder2_out,
	    fixed_pt_adder2_cout,

        //24 bit adder exposed outside
	    fixed_pt_adder34_in_a,
	    fixed_pt_adder34_in_b,
	    fixed_pt_adder34_mode,
	    fixed_pt_adder34_cin,
	    fixed_pt_adder34_out,
	    fixed_pt_adder34_cout,

	    fixed_pt_adder5_in_a,
	    fixed_pt_adder5_in_b,
	    fixed_pt_adder5_mode,
	    fixed_pt_adder5_cin,
	    fixed_pt_adder5_out,
	    fixed_pt_adder5_cout
	);

// Clock and reset
	input clk ;										// Clock signal
	input rst ;										// Reset (active high, resets pipeline registers)
	
	// Input ports
	input [31:0] a ;								// Input A, a 32-bit floating point number
	input [31:0] b ;								// Input B, a 32-bit floating point number
	input operation ;								// Operation select signal
	
	// Output ports
	output [31:0] result ;						// Result of the operation
	output [4:0] flags ;							// Flags indicating exceptions according to IEEE754

	output [7:0] fixed_pt_adder1_in_a;
	output [7:0] fixed_pt_adder1_in_b;
	output       fixed_pt_adder1_mode;
	output       fixed_pt_adder1_cin;
	input  [7:0] fixed_pt_adder1_out;
	input        fixed_pt_adder1_cout;

	output [7:0] fixed_pt_adder2_in_a;
	output [7:0] fixed_pt_adder2_in_b;
	output       fixed_pt_adder2_mode;
	output       fixed_pt_adder2_cin;
	input  [7:0] fixed_pt_adder2_out;
	input        fixed_pt_adder2_cout;

	output [23:0] fixed_pt_adder34_in_a;
	output [23:0] fixed_pt_adder34_in_b;
	output        fixed_pt_adder34_mode;
	output        fixed_pt_adder34_cin;
	input  [23:0] fixed_pt_adder34_out;
	input         fixed_pt_adder34_cout;

	output [7:0] fixed_pt_adder5_in_a;
	output [7:0] fixed_pt_adder5_in_b;
	output       fixed_pt_adder5_mode;
	output       fixed_pt_adder5_cin;
	input  [7:0] fixed_pt_adder5_out;
	input        fixed_pt_adder5_cout;

	wire [68:0]pipe_1;
	wire [54:0]pipe_2;
	wire [45:0]pipe_3;

wire dummy;
assign dummy = clk | rst;

//internal module wires

//output ports
	wire Opout;
	wire Sa;
	wire Sb;
	wire MaxAB;
	wire [7:0] CExp;
	wire [4:0] Shift;
	wire [22:0] Mmax;
	wire [4:0] InputExc;
	wire [23:0] Mmin_3;

	wire [32:0] SumS_5 ;
	wire [4:0] Shift_1;							
	wire PSgn ;							
	wire Opr ;	
	
	wire [22:0] NormM ;				// Normalized mantissa
	wire [8:0] NormE ;					// Adjusted exponent
	wire ZeroSum ;						// Zero flag
	wire NegE ;							// Flag indicating negative exponent
	wire R ;								// Round bit
	wire S ;								// Final sticky bit
	wire FG ;

FPAddSub_a M1(a,b,operation,Opout,Sa,Sb,MaxAB,CExp,Shift,Mmax,InputExc,Mmin_3,
	    fixed_pt_adder1_in_a,
	    fixed_pt_adder1_in_b,
	    fixed_pt_adder1_mode,
	    fixed_pt_adder1_cin,
	    fixed_pt_adder1_out,
	    fixed_pt_adder1_cout,

	    fixed_pt_adder2_in_a,
	    fixed_pt_adder2_in_b,
	    fixed_pt_adder2_mode,
	    fixed_pt_adder2_cin,
	    fixed_pt_adder2_out,
	    fixed_pt_adder2_cout);

FpAddSub_b M2(pipe_1[51:29],pipe_1[23:0],pipe_1[67],pipe_1[66],pipe_1[65],pipe_1[68],SumS_5,Shift_1,PSgn,Opr,
	    fixed_pt_adder34_in_a,
	    fixed_pt_adder34_in_b,
	    fixed_pt_adder34_mode,
	    fixed_pt_adder34_cin,
	    fixed_pt_adder34_out,
	    fixed_pt_adder34_cout);

FPAddSub_c M3(pipe_2[54:22],pipe_2[21:17],pipe_2[16:9],NormM,NormE,ZeroSum,NegE,R,S,FG,
	    fixed_pt_adder5_in_a,
	    fixed_pt_adder5_in_b,
	    fixed_pt_adder5_mode,
	    fixed_pt_adder5_cin,
	    fixed_pt_adder5_out,
	    fixed_pt_adder5_cout);

FPAddSub_d M4(pipe_3[13],pipe_3[22:14],pipe_3[45:23],pipe_3[11],pipe_3[10],pipe_3[9],pipe_3[8],pipe_3[7],pipe_3[6],pipe_3[5],pipe_3[12],pipe_3[4:0],result,flags );


/*
pipe_1:
	[68] Opout;
	[67] Sa;
	[66] Sb;
	[65] MaxAB;
	[64:57] CExp;
	[56:52] Shift;
	[51:29] Mmax;
	[28:24] InputExc;
	[23:0] Mmin_3;	

*/

assign pipe_1 = {Opout,Sa,Sb,MaxAB,CExp,Shift,Mmax,InputExc,Mmin_3};

/*
pipe_2:
	[54:22]SumS_5;
	[21:17]Shift;
	[16:9]CExp;	
	[8]Sa;
	[7]Sb;
	[6]operation;
	[5]MaxAB;	
	[4:0]InputExc
*/

assign pipe_2 = {SumS_5,Shift_1,pipe_1[64:57], pipe_1[67], pipe_1[66], pipe_1[68], pipe_1[65], pipe_1[28:24] };

/*
pipe_3:
	[45:23] NormM ;				
	[22:14] NormE ;					
	[13]ZeroSum ;						
	[12]NegE ;							
	[11]R ;								
	[10]S ;								
	[9]FG ;
	[8]Sa;
	[7]Sb;
	[6]operation;
	[5]MaxAB;	
	[4:0]InputExc
*/

assign pipe_3 = {NormM,NormE,ZeroSum,NegE,R,S,FG, pipe_2[8], pipe_2[7], pipe_2[6], pipe_2[5], pipe_2[4:0] };


endmodule
`timescale 1ns / 1ps
// Prealign + Align + Shift 1 + Shift 2
module FPAddSub_a(
		A,
		B,
		operation,
		Opout,
		Sa,
		Sb,
		MaxAB,
		CExp,
		Shift,
		Mmax,
		InputExc,
		Mmin_3,
	    fixed_pt_adder1_in_a,
	    fixed_pt_adder1_in_b,
	    fixed_pt_adder1_mode,
	    fixed_pt_adder1_cin,
	    fixed_pt_adder1_out,
	    fixed_pt_adder1_cout,

	    fixed_pt_adder2_in_a,
	    fixed_pt_adder2_in_b,
	    fixed_pt_adder2_mode,
	    fixed_pt_adder2_cin,
	    fixed_pt_adder2_out,
	    fixed_pt_adder2_cout
	);
	
	// Input ports
	input [31:0] A ;										// Input A, a 32-bit floating point number
	input [31:0] B ;										// Input B, a 32-bit floating point number
	input operation ;
	
	//output ports
	output Opout;
	output Sa;
	output Sb;
	output MaxAB;
	output [7:0] CExp;
	output [4:0] Shift;
	output [22:0] Mmax;
	output [4:0] InputExc;
	output [23:0] Mmin_3;

	output [7:0] fixed_pt_adder1_in_a;
	output [7:0] fixed_pt_adder1_in_b;
	output       fixed_pt_adder1_mode;
	output       fixed_pt_adder1_cin;
	input  [7:0] fixed_pt_adder1_out;
	input        fixed_pt_adder1_cout;

	output [7:0] fixed_pt_adder2_in_a;
	output [7:0] fixed_pt_adder2_in_b;
	output       fixed_pt_adder2_mode;
	output       fixed_pt_adder2_cin;
	input  [7:0] fixed_pt_adder2_out;
	input        fixed_pt_adder2_cout;
							
	wire [9:0] ShiftDet ;							
	wire [30:0] Aout ;
	wire [30:0] Bout ;
	

	// Internal signals									// If signal is high...
	wire ANaN ;												// A is a NaN (Not-a-Number)
	wire BNaN ;												// B is a NaN
	wire AInf ;												// A is infinity
	wire BInf ;												// B is infinity
	wire [7:0] DAB ;										// ExpA - ExpB					
	wire [7:0] DBA ;										// ExpB - ExpA	
	
	assign ANaN = &(A[30:23]) & |(A[22:0]) ;		// All one exponent and not all zero mantissa - NaN
	assign BNaN = &(B[30:23]) & |(B[22:0]);		// All one exponent and not all zero mantissa - NaN
	assign AInf = &(A[30:23]) & ~|(A[22:0]) ;	// All one exponent and all zero mantissa - Infinity
	assign BInf = &(B[30:23]) & ~|(B[22:0]) ;	// All one exponent and all zero mantissa - Infinity
	
	// Put all flags into exception vector
	assign InputExc = {(ANaN | BNaN | AInf | BInf), ANaN, BNaN, AInf, BInf} ;
	
	//assign DAB = (A[30:23] - B[30:23]) ;
	//assign DBA = (B[30:23] - A[30:23]) ;
	//`ifndef SYNTHESIS_
  //assign DAB = (A[30:23] + ~(B[30:23]) + 1) ;
	//assign DBA = (B[30:23] + ~(A[30:23]) + 1) ;
  //`else
  //DW01_add #(8) u_add1(.A(A[30:23]), .B(~(B[30:23])), .CI(1'b1), .SUM(DAB), .CO());
  //DW01_add #(8) u_add2(.A(B[30:23]), .B(~(A[30:23])), .CI(1'b1), .SUM(DBA), .CO());
	//`endif
  // Sending addition inputs outside, doing the actual multiplication outside and then getting the sum back in

	wire DAB_cout;
	assign fixed_pt_adder1_in_a = A[30:23];
	assign fixed_pt_adder1_in_b = B[30:23];
	assign fixed_pt_adder1_mode = 1'b1; //subtractor
	assign fixed_pt_adder1_cin  = 1'b0;
	assign DAB = fixed_pt_adder1_out;
	assign DAB_cout = fixed_pt_adder1_cout;

	wire DBA_cout;
	assign fixed_pt_adder2_in_a = B[30:23];
	assign fixed_pt_adder2_in_b = A[30:23];
	assign fixed_pt_adder2_mode = 1'b1; //subtractor
	assign fixed_pt_adder2_cin  = 1'b0;
	assign DBA = fixed_pt_adder2_out;
	assign DBA_cout = fixed_pt_adder2_cout;
	
	assign Sa = A[31] ;									// A's sign bit
	assign Sb = B[31] ;									// B's sign	bit
	assign ShiftDet = {DBA[4:0], DAB[4:0]} ;		// Shift data
	assign Opout = operation ;
	assign Aout = A[30:0] ;
	assign Bout = B[30:0] ;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Output ports
													// Number of steps to smaller mantissa shift right
	wire [22:0] Mmin_1 ;							// Smaller mantissa 
	
	// Internal signals
	//wire BOF ;										// Check for shifting overflow if B is larger
	//wire AOF ;										// Check for shifting overflow if A is larger
	
	assign MaxAB = (Aout[30:0] < Bout[30:0]) ;	
	//assign BOF = ShiftDet[9:5] < 25 ;		// Cannot shift more than 25 bits
	//assign AOF = ShiftDet[4:0] < 25 ;		// Cannot shift more than 25 bits
	
	// Determine final shift value
	//assign Shift = MaxAB ? (BOF ? ShiftDet[9:5] : 5'b11001) : (AOF ? ShiftDet[4:0] : 5'b11001) ;
	
	assign Shift = MaxAB ? ShiftDet[9:5] : ShiftDet[4:0] ;
	
	// Take out smaller mantissa and append shift space
	assign Mmin_1 = MaxAB ? Aout[22:0] : Bout[22:0] ; 
	
	// Take out larger mantissa	
	assign Mmax = MaxAB ? Bout[22:0]: Aout[22:0] ;	
	
	// Common exponent
	assign CExp = (MaxAB ? Bout[30:23] : Aout[30:23]) ;	

// Input ports
					// Smaller mantissa after 16|12|8|4 shift
	wire [2:0] Shift_1 ;						// Shift amount
	
	assign Shift_1 = Shift [4:2];

	wire [23:0] Mmin_2 ;						// The smaller mantissa
	
	// Internal signals
	reg	  [23:0]		Lvl1;
	reg	  [23:0]		Lvl2;
	wire    [47:0]    Stage1;	
	integer           i;                // Loop variable
	
	always @(*) begin						
		// Rotate by 16?
		Lvl1 <= Shift_1[2] ? {17'b00000000000000001, Mmin_1[22:16]} : {1'b1, Mmin_1}; 
	end
	
	assign Stage1 = {Lvl1, Lvl1};
	
	always @(*) begin    					// Rotate {0 | 4 | 8 | 12} bits
	  case (Shift_1[1:0])
			// Rotate by 0	
			2'b00:  Lvl2 <= Stage1[23:0];       			
			// Rotate by 4	
			2'b01:  begin for (i=0; i<=23; i=i+1) begin Lvl2[i] <= Stage1[i+4]; end /*Lvl2[23:19] <= 0;*/ end
			// Rotate by 8
			2'b10:  begin for (i=0; i<=23; i=i+1) begin Lvl2[i] <= Stage1[i+8]; end /*Lvl2[23:15] <= 0;*/ end
			// Rotate by 12	
			2'b11:  begin for (i=0; i<=23; i=i+1) begin Lvl2[i] <= Stage1[i+12]; end /*Lvl2[23:11] <= 0;*/ end
	  endcase
	end
	
	// Assign output to next shift stage
	assign Mmin_2 = Lvl2;
								// Smaller mantissa after 16|12|8|4 shift
	wire [1:0] Shift_2 ;						// Shift amount
	
	assign Shift_2 =Shift  [1:0] ;
					// The smaller mantissa
	
	// Internal Signal
	reg	  [23:0]		Lvl3;
	wire    [47:0]    Stage2;	
	integer           j;               // Loop variable
	
	assign Stage2 = {Mmin_2, Mmin_2};

	always @(*) begin    // Rotate {0 | 1 | 2 | 3} bits
	  case (Shift_2[1:0])
			// Rotate by 0
			2'b00:  Lvl3 <= Stage2[23:0];   
			// Rotate by 1
			2'b01:  begin for (j=0; j<=23; j=j+1)  begin Lvl3[j] <= Stage2[j+1]; end /*Lvl3[23] <= 0;*/ end 
			// Rotate by 2
			2'b10:  begin for (j=0; j<=23; j=j+1)  begin Lvl3[j] <= Stage2[j+2]; end /*Lvl3[23:22] <= 0;*/ end 
			// Rotate by 3
			2'b11:  begin for (j=0; j<=23; j=j+1)  begin Lvl3[j] <= Stage2[j+3]; end /*Lvl3[23:21] <= 0;*/ end 	  
	  endcase
	end
	
	// Assign output
	assign Mmin_3 = Lvl3;	

	
endmodule
`timescale 1ns / 1ps

module FpAddSub_b(
		Mmax,
		Mmin,
		Sa,
		Sb,
		MaxAB,
		OpMode,
		SumS_5,
		Shift,
		PSgn,
		Opr,

	    fixed_pt_adder34_in_a,
	    fixed_pt_adder34_in_b,
	    fixed_pt_adder34_mode,
	    fixed_pt_adder34_cin,
	    fixed_pt_adder34_out,
	    fixed_pt_adder34_cout
);
	input [22:0] Mmax ;					// The larger mantissa
	input [23:0] Mmin ;					// The smaller mantissa
	input Sa ;								// Sign bit of larger number
	input Sb ;								// Sign bit of smaller number
	input MaxAB ;							// Indicates the larger number (0/A, 1/B)
	input OpMode ;							// Operation to be performed (0/Add, 1/Sub)
	
	// Output ports
	wire [32:0] Sum ;	
						// Output ports
	output [32:0] SumS_5 ;					// Mantissa after 16|0 shift
	output [4:0] Shift ;					// Shift amount				// The result of the operation
	output PSgn ;							// The sign for the result
	output Opr ;							// The effective (performed) operation

	output [23:0] fixed_pt_adder34_in_a;
	output [23:0] fixed_pt_adder34_in_b;
	output        fixed_pt_adder34_mode;
	output        fixed_pt_adder34_cin;
	input  [23:0] fixed_pt_adder34_out;
	input         fixed_pt_adder34_cout;

	assign Opr = (OpMode^Sa^Sb); 		// Resolve sign to determine operation

	// Perform effective operation
	//Original code:
  //`ifndef SYNTHESIS_
	//assign Sum = (OpMode^Sa^Sb) ? ({1'b1, Mmax, 8'b00000000} - {Mmin, 8'b00000000}) : ({1'b1, Mmax, 8'b00000000} + {Mmin, 8'b00000000}) ;
	//`else
  //wire [32:0] sum;
  //wire [32:0] sub;
  //DW01_add #(32) u_add(.A({1'b1, Mmax, 8'b00000000}), .B({Mmin, 8'b00000000}), .CI(1'b0), .SUM(sum[31:0]), .CO(sum[32]));
  //DW01_sub #(32) u_sub(.A({1'b1, Mmax, 8'b00000000}), .B({Mmin, 8'b00000000}), .CI(1'b0), .DIFF(sub[31:0]), .CO(sub[32]));
	//assign Sum = (OpMode^Sa^Sb) ? (sub) : (sum) ;
  //`endif 
	//Rewritten:
	//  One side of the mux :  ( {1'b1, Mmax} - Mmin ) << 8'b0
	//  Other side          :  ( {1'b1, Mmax} + Mmin ) << 8'b0
    // Sending addition inputs outside, doing the actual multiplication outside and then getting the sum back in
	
	wire [23:0] Sum_sum;
	wire Sum_cout;
	assign fixed_pt_adder34_in_a = {1'b1, Mmax}; //24 bits
	assign fixed_pt_adder34_in_b = Mmin;  //24 bits
	assign fixed_pt_adder34_mode = Opr;
	assign fixed_pt_adder34_cin  = 1'b0;
	assign Sum_sum  = fixed_pt_adder34_out; // 24 bits
	assign Sum_cout = fixed_pt_adder34_cout;
  assign Sum = {Sum_cout, Sum_sum, 8'b0}; //Shifted left by 8 bits
	
	// Assign result sign
	assign PSgn = (MaxAB ? Sb : Sa) ;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		// Determine normalization shift amount by finding leading nought
	assign Shift =  ( 
		Sum[32] ? 5'b00000 :	 
		Sum[31] ? 5'b00001 : 
		Sum[30] ? 5'b00010 : 
		Sum[29] ? 5'b00011 : 
		Sum[28] ? 5'b00100 : 
		Sum[27] ? 5'b00101 : 
		Sum[26] ? 5'b00110 : 
		Sum[25] ? 5'b00111 :
		Sum[24] ? 5'b01000 :
		Sum[23] ? 5'b01001 :
		Sum[22] ? 5'b01010 :
		Sum[21] ? 5'b01011 :
		Sum[20] ? 5'b01100 :
		Sum[19] ? 5'b01101 :
		Sum[18] ? 5'b01110 :
		Sum[17] ? 5'b01111 :
		Sum[16] ? 5'b10000 :
		Sum[15] ? 5'b10001 :
		Sum[14] ? 5'b10010 :
		Sum[13] ? 5'b10011 :
		Sum[12] ? 5'b10100 :
		Sum[11] ? 5'b10101 :
		Sum[10] ? 5'b10110 :
		Sum[9] ? 5'b10111 :
		Sum[8] ? 5'b11000 :
		Sum[7] ? 5'b11001 : 5'b11010
	);
	
	reg	  [32:0]		Lvl1;
	
	always @(*) begin
		// Rotate by 16?
		Lvl1 <= Shift[4] ? {Sum[16:0], 16'b0000000000000000} : Sum; 
	end
	
	// Assign outputs
	assign SumS_5 = Lvl1;	

endmodule



`timescale 1ns / 1ps

module FPAddSub_c(
		SumS_5,
		Shift,
		CExp,
		NormM,
		NormE,
		ZeroSum,
		NegE,
		R,
		S,
		FG,
	    fixed_pt_adder5_in_a,
	    fixed_pt_adder5_in_b,
	    fixed_pt_adder5_mode,
	    fixed_pt_adder5_cin,
	    fixed_pt_adder5_out,
	    fixed_pt_adder5_cout
	);
	
	// Input ports
	input [32:0] SumS_5 ;						// Smaller mantissa after 16|12|8|4 shift
	
	input [4:0] Shift ;						// Shift amount
	
// Input ports
	
	input [7:0] CExp ;
	

	// Output ports
	output [22:0] NormM ;				// Normalized mantissa
	output [8:0] NormE ;					// Adjusted exponent
	output ZeroSum ;						// Zero flag
	output NegE ;							// Flag indicating negative exponent
	output R ;								// Round bit
	output S ;								// Final sticky bit
	output FG ;

	output [7:0] fixed_pt_adder5_in_a;
	output [7:0] fixed_pt_adder5_in_b;
	output       fixed_pt_adder5_mode;
	output       fixed_pt_adder5_cin;
	input  [7:0] fixed_pt_adder5_out;
	input        fixed_pt_adder5_cout;

	wire [3:0]Shift_1;
	assign Shift_1 = Shift [3:0];
	// Output ports
	wire [32:0] SumS_7 ;						// The smaller mantissa
	
	reg	  [32:0]		Lvl2;
	wire    [65:0]    Stage1;	
	reg	  [32:0]		Lvl3;
	wire    [65:0]    Stage2;	
	integer           i;               	// Loop variable
	
	assign Stage1 = {SumS_5, SumS_5};

	always @(*) begin    					// Rotate {0 | 4 | 8 | 12} bits
	  case (Shift[3:2])
			// Rotate by 0
			2'b00: Lvl2 <= Stage1[32:0];       		
			// Rotate by 4
			2'b01: begin for (i=65; i>=33; i=i-1) begin Lvl2[i-33] <= Stage1[i-4]; end /*Lvl2[3:0] <= 0;*/ end
			// Rotate by 8
			2'b10: begin for (i=65; i>=33; i=i-1) begin Lvl2[i-33] <= Stage1[i-8]; end /*Lvl2[7:0] <= 0;*/ end
			// Rotate by 12
			2'b11: begin for (i=65; i>=33; i=i-1) begin Lvl2[i-33] <= Stage1[i-12]; end /*Lvl2[11:0] <= 0;*/ end
	  endcase
	end
	
	assign Stage2 = {Lvl2, Lvl2};

	always @(*) begin   				 		// Rotate {0 | 1 | 2 | 3} bits
	  case (Shift_1[1:0])
			// Rotate by 0
			2'b00:  Lvl3 <= Stage2[32:0];
			// Rotate by 1
			2'b01: begin for (i=65; i>=33; i=i-1) begin Lvl3[i-33] <= Stage2[i-1]; end /*Lvl3[0] <= 0;*/ end 
			// Rotate by 2
			2'b10: begin for (i=65; i>=33; i=i-1) begin Lvl3[i-33] <= Stage2[i-2]; end /*Lvl3[1:0] <= 0;*/ end
			// Rotate by 3
			2'b11: begin for (i=65; i>=33; i=i-1) begin Lvl3[i-33] <= Stage2[i-3]; end /*Lvl3[2:0] <= 0;*/ end
	  endcase
	end
	
	// Assign outputs
	assign SumS_7 = Lvl3;						// Take out smaller mantissa



	
	// Internal signals
	wire MSBShift ;						// Flag indicating that a second shift is needed
	wire [8:0] ExpOF ;					// MSB set in sum indicates overflow
	wire [8:0] ExpOK ;					// MSB not set, no adjustment
	
	// Calculate normalized exponent and mantissa, check for all-zero sum
	assign MSBShift = SumS_7[32] ;		// Check MSB in unnormalized sum
	assign ZeroSum = ~|SumS_7 ;			// Check for all zero sum
  //`ifndef SYNTHESIS_
	//assign ExpOK = CExp - Shift ;		// Adjust exponent for new normalized mantissa
  //`else
  //DW01_sub #(8) u_sub(.A(CExp), .B({3'b000, Shift}), .CI(1'b0), .DIFF(ExpOK[7:0]), .CO(ExpOK[8]));
  //`endif
    // Sending addition inputs outside, doing the actual multiplication outside and then getting the sum back in
	// This is 8bit + 5bit adder. We'll just use a 8bit + 8bit adder outside.

	wire ExpOK_cout;
	wire [7:0] ExpOK_out;
	assign fixed_pt_adder5_in_a = CExp;
	assign fixed_pt_adder5_in_b = {3'b0, Shift};
	assign fixed_pt_adder5_mode = 1'b1; //subtractor
	assign fixed_pt_adder5_cin  = 1'b0;
	assign ExpOK_out = fixed_pt_adder5_out;
	assign ExpOK_cout = fixed_pt_adder5_cout;
	assign ExpOK = {ExpOK_cout, ExpOK_out};
	
	assign NegE = ExpOK[8] ;			// Check for exponent overflow
  `ifndef SYNTHESIS_
	assign ExpOF = CExp - Shift + 1'b1 ;		// If MSB set, add one to exponent(x2)
  `else
  assign ExpOF = ExpOK + 1'b1;
  `endif
	assign NormE = MSBShift ? ExpOF : ExpOK ;			// Check for exponent overflow
	assign NormM = SumS_7[31:9] ;		// The new, normalized mantissa
	
	// Also need to compute sticky and round bits for the rounding stage
	assign FG = SumS_7[8] ; 
	assign R = SumS_7[7] ;
	assign S = |SumS_7[6:0] ;		
	
endmodule
`timescale 1ns / 1ps

module FPAddSub_d(
		ZeroSum,
		NormE,
		NormM,
		R,
		S,
		G,
		Sa,
		Sb,
		Ctrl,
		MaxAB,
		NegE,
		InputExc,
		P,
		Flags 
    );

	// Input ports
	input ZeroSum ;					// Sum is zero
	input [8:0] NormE ;				// Normalized exponent
	input [22:0] NormM ;				// Normalized mantissa
	input R ;							// Round bit
	input S ;							// Sticky bit
	input G ;
	input Sa ;							// A's sign bit
	input Sb ;							// B's sign bit
	input Ctrl ;						// Control bit (operation)
	input MaxAB ;
	

	input NegE ;						// Negative exponent?
	input [4:0] InputExc ;					// Exceptions in inputs A and B

	// Output ports
	output [31:0] P ;					// Final result
	output [4:0] Flags ;				// Exception flags
	
	// 
	wire [31:0] Z ;					// Final result
	wire EOF ;
	
	// Internal signals
	wire [23:0] RoundUpM ;			// Rounded up sum with room for overflow
	wire [22:0] RoundM ;				// The final rounded sum
	wire [8:0] RoundE ;				// Rounded exponent (note extra bit due to poential overflow	)
	wire RoundUp ;						// Flag indicating that the sum should be rounded up
	wire ExpAdd ;						// May have to add 1 to compensate for overflow 
	wire RoundOF ;						// Rounding overflow
	wire FSgn;
	// The cases where we need to round upwards (= adding one) in Round to nearest, tie to even
	assign RoundUp = (G & ((R | S) | NormM[0])) ;
	
	// Note that in the other cases (rounding down), the sum is already 'rounded'
	assign RoundUpM = (NormM + 1) ;								// The sum, rounded up by 1
	assign RoundM = (RoundUp ? RoundUpM[22:0] : NormM) ; 	// Compute final mantissa	
	assign RoundOF = RoundUp & RoundUpM[23] ; 				// Check for overflow when rounding up

	// Calculate post-rounding exponent
	assign ExpAdd = (RoundOF ? 1'b1 : 1'b0) ; 				// Add 1 to exponent to compensate for overflow
	assign RoundE = ZeroSum ? 8'b00000000 : (NormE + ExpAdd) ; 							// Final exponent

	// If zero, need to determine sign according to rounding
	assign FSgn = (ZeroSum & (Sa ^ Sb)) | (ZeroSum ? (Sa & Sb & ~Ctrl) : ((~MaxAB & Sa) | ((Ctrl ^ Sb) & (MaxAB | Sa)))) ;

	// Assign final result
	assign Z = {FSgn, RoundE[7:0], RoundM[22:0]} ;
	
	// Indicate exponent overflow
	assign EOF = RoundE[8];

/////////////////////////////////////////////////////////////////////////////////////////////////////////



	
	// Internal signals
	wire Overflow ;					// Overflow flag
	wire Underflow ;					// Underflow flag
	wire DivideByZero ;				// Divide-by-Zero flag (always 0 in Add/Sub)
	wire Invalid ;						// Invalid inputs or result
	wire Inexact ;						// Result is inexact because of rounding
	
	// Exception flags
	
	// Result is too big to be represented
	assign Overflow = EOF | InputExc[1] | InputExc[0] ;
	
	// Result is too small to be represented
	assign Underflow = NegE & (R | S);
	
	// Infinite result computed exactly from finite operands
	assign DivideByZero = &(Z[30:23]) & ~|(Z[30:23]) & ~InputExc[1] & ~InputExc[0];
	
	// Invalid inputs or operation
	assign Invalid = |(InputExc[4:2]) ;
	
	// Inexact answer due to rounding, overflow or underflow
	assign Inexact = (R | S) | Overflow | Underflow;
	
	// Put pieces together to form final result
	assign P = Z ;
	
	// Collect exception flags	
	assign Flags = {Overflow, Underflow, DivideByZero, Invalid, Inexact} ; 	
	
endmodule
// algo used : https://fgiesen.wordpress.com/2012/03/28/half-to-float-done-quic/

`timescale 1ns / 1ps

module fp16_to_fp32 (input [15:0] a , output [31:0] b);

reg [31:0]b_temp;
integer j;
reg [3:0]k;
always @ (*) begin

if ( a [14: 0] == 15'b0 ) begin //signed zero
	b_temp [31] = a[15]; //sign bit
end

else begin

	if ( a[14 : 10] == 5'b0 ) begin //denormalized (covert to normalized)
		
		for (j=0; j<=9; j=j+1)
			begin
			if (a[j] == 1'b1) begin 
			k = j;	end
			end
	k = 9 - k;

	b_temp [22:0] = ( (a [9:0] << (k+1'b1)) & 10'h3FF ) << 13;
	b_temp [30:23] =  7'd127 - 4'd15 - k;
	b_temp [31] = a[15];
	end

	else if ( a[14 : 10] == 5'b11111 ) begin //Infinity/ NAN
	b_temp [22:0] = a [9:0] << 13;
	b_temp [30:23] = 8'hFF;
	b_temp [31] = a[15];
	end

	else begin //Normalized Number
	b_temp [22:0] = a [9:0] << 13;
	b_temp [30:23] =  7'd127 - 4'd15 + a[14:10];
	b_temp [31] = a[15];
	end
end
end

assign b = b_temp;


endmodule

module tb_fp16_to_fp32 ();
reg [15:0] a;
wire [31:0] b;

fp16_to_fp32 uut (a, b);

initial begin
a = 0;
#10
#10 a= 16'h00A0;
#10 a= 16'h808A;
#10 a= 16'h1642;
#10 a= 16'hD555;
#10 a= 16'h7E44;
#10 $finish;
end

endmodule
// algo used : https://fgiesen.wordpress.com/2012/03/28/half-to-float-done-quic/

`timescale 1ns / 1ps

module fp32_to_fp16 (input [31:0] a , output [15:0] b);

reg [15:0]b_temp;
//integer j;
//reg [3:0]k;
always @ (*) begin

if ( a [30: 0] == 15'b0 ) begin //signed zero
	b_temp [15] = a[30]; //sign bit
end

else begin

	if ( a[30 : 23] <= 8'd112  &&  a[30 : 23] >= 8'd103 ) begin //denormalized (covert to normalized)
		
	b_temp [9:0] = {1'b1, a[22:13]} >> {8'd112 - a[30 : 23] + 1'b1} ;  
	b_temp [14:10] =  5'b0;
	b_temp [15] = a[31];
	end

	else if ( a[ 30 : 23] == 8'b11111111 ) begin //Infinity/ NAN
	b_temp [9:0] = a [22:13];
	b_temp [14:10] = 5'h1F;
	b_temp [15] = a[31];
	end

	else begin //Normalized Number
	b_temp [9:0] = a [22:13];
	b_temp [14:10] = 4'd15 - 7'd127  + a[30:23]; //number should be in the range which can be depicted by fp16 (exp for fp32: 70h, 8Eh ; normalized exp for fp32: -15 to 15)
	b_temp [15] = a[31];
	end
end
end

assign b = b_temp;


endmodule

module tb_fp32_to_fp16 ();
reg [31:0] a;
wire [15:0] b;

fp32_to_fp16 uut (a, b);

initial begin
a = 0;
#10
#10 a= 32'h37200000;
#10 a= 32'hB70A0000;
#10 a= 32'h3AC84000;
#10 a= 32'hC2AAA000;
#10 a= 32'h7FC88000;
#10 $finish;
end

endmodule
