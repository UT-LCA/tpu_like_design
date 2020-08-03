
`timescale 1ns / 1ps

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
`define DTYPE_INT8 0
`define DTYPE_FP16 1

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

module matmul_8x8_systolic(
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
 dtype, // 0 = int8, 1 = fp16
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
 input dtype;

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
.a_addr(a_addr),
.b_addr(b_addr),
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
.dtype(dtype),
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
.start_mat_mul(start_mat_mul),
.a_data(a_data_to_pes),
.b_data(b_data_to_pes),
.dtype(dtype),
.pe_data_out(pe_data_out),
.a_data_out(a_data_out),
.b_data_out(b_data_out)
);

//////////////////////////////////////////////////////////////////////////
// Instantiation of the output logic
//////////////////////////////////////////////////////////////////////////
output_logic u_output_logic(
.start_mat_mul(start_mat_mul),
.done_mat_mul(done_mat_mul),
.address_mat_c(address_mat_c),
.address_stride_c(address_stride_c),
.c_data_out(c_data_out),
.c_data_in(c_data_in),
.c_addr(c_addr),
.c_data_available(c_data_available),
.clk_cnt(clk_cnt),
.row_latch_en(row_latch_en),
.final_mat_mul_size(final_mat_mul_size),
.pe_data_out(pe_data_out),
.dtype(dtype),
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
row_latch_en,
final_mat_mul_size,
pe_data_out,
dtype,
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
output row_latch_en;
input [7:0] final_mat_mul_size;
input [511:0] pe_data_out;
input dtype;
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
    if (dtype == `DTYPE_INT8) begin
    c_data_out <= {pe_data_out[32+7*64+7:32+7*64], pe_data_out[32+6*64+7:32+6*64], pe_data_out[32+5*64+7:32+5*64], pe_data_out[32+4*64+7:32+4*64], pe_data_out[32+3*64+7:32+3*64], pe_data_out[32+2*64+7:32+2*64], pe_data_out[32+64+7:32+64], pe_data_out[32+7:32]};
    c_data_out_1 <= {pe_data_out[40+7*64+7:40+7*64], pe_data_out[40+6*64+7:40+6*64], pe_data_out[40+5*64+7:40+5*64], pe_data_out[40+4*64+7:40+4*64], pe_data_out[40+3*64+7:40+3*64], pe_data_out[40+2*64+7:40+2*64], pe_data_out[40+64+7:40+64], pe_data_out[40+7:40]};
    c_data_out_2 <= {pe_data_out[48+7*64+7:48+7*64], pe_data_out[48+6*64+7:48+6*64], pe_data_out[48+5*64+7:48+5*64], pe_data_out[48+4*64+7:48+4*64], pe_data_out[48+3*64+7:48+3*64], pe_data_out[48+2*64+7:48+2*64], pe_data_out[48+64+7:48+64], pe_data_out[48+7:48]};
    c_data_out_3 <= {pe_data_out[56+7*64+7:56+7*64], pe_data_out[56+6*64+7:56+6*64], pe_data_out[56+5*64+7:56+5*64], pe_data_out[56+4*64+7:56+4*64], pe_data_out[56+3*64+7:56+3*64], pe_data_out[56+2*64+7:56+2*64], pe_data_out[56+64+7:56+64], pe_data_out[56+7:56]};
    c_data_out_4 <= {pe_data_out[0+7*64+7:0+7*64], pe_data_out[0+6*64+7:0+6*64], pe_data_out[0+5*64+7:0+5*64], pe_data_out[0+4*64+7:0+4*64], pe_data_out[0+3*64+7:0+3*64], pe_data_out[0+2*64+7:0+2*64], pe_data_out[0+64+7:0+64], pe_data_out[0+7:0]};
    c_data_out_5 <= {pe_data_out[8+7*64+7:8+7*64], pe_data_out[8+6*64+7:8+6*64], pe_data_out[8+5*64+7:8+5*64], pe_data_out[8+4*64+7:8+4*64], pe_data_out[8+3*64+7:8+3*64], pe_data_out[8+2*64+7:8+2*64], pe_data_out[8+64+7:8+64], pe_data_out[8+7:8]};
    c_data_out_6 <= {pe_data_out[16+7*64+7:16+7*64], pe_data_out[16+6*64+7:16+6*64], pe_data_out[16+5*64+7:16+5*64], pe_data_out[16+4*64+7:16+4*64], pe_data_out[16+3*64+7:16+3*64], pe_data_out[16+2*64+7:16+2*64], pe_data_out[16+64+7:16+64], pe_data_out[16+7:16]};
    c_data_out_7 <= {pe_data_out[24+7*64+7:24+7*64], pe_data_out[24+6*64+7:24+6*64], pe_data_out[24+5*64+7:24+5*64], pe_data_out[24+4*64+7:24+4*64], pe_data_out[24+3*64+7:24+3*64], pe_data_out[24+2*64+7:24+2*64], pe_data_out[24+64+7:24+64], pe_data_out[24+7:24]};
    end 
    else begin
    c_data_out <= {pe_data_out[96+3*128+15:96+3*128], pe_data_out[96+2*128+15:96+2*128], pe_data_out[96+128+15:96+128], pe_data_out[96+15:96]};
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
dtype,
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
input dtype;
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
        (dtype == `DTYPE_FP16) ? a_data_valid_part1 :
        (a_data_valid_part1 || a_data_valid_part2)
      ) ?
       1'b0 : (a_mem_access_counter >= `MEM_ACCESS_LATENCY);


//////////////////////////////////////////////////////////////////////////
// Logic to delay certain parts of the data received from BRAM A (systolic data setup)
//////////////////////////////////////////////////////////////////////////
wire [`MASK_WIDTH-1:0] validity_mask_a_rows_internal;
assign validity_mask_a_rows_internal = (dtype == `DTYPE_INT8) ? 
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
assign a_data_delayed[2*`DWIDTH-1:1*`DWIDTH] = (dtype == `DTYPE_INT8)? a_one_clk_del_int8 : a_one_clk_del_fp16;
assign a_data_delayed[3*`DWIDTH-1:2*`DWIDTH] = (dtype == `DTYPE_INT8)? a_two_clk_del_int8 : a_two_clk_del_fp16;
assign a_data_delayed[4*`DWIDTH-1:3*`DWIDTH] = (dtype == `DTYPE_INT8)? a_thr_clk_del_int8 : a_thr_clk_del_fp16;
assign a_data_delayed[5*`DWIDTH-1:4*`DWIDTH] = (dtype == `DTYPE_INT8)? a_fou_clk_del_int8 : a_fou_clk_del_fp16;
assign a_data_delayed[6*`DWIDTH-1:5*`DWIDTH] = (dtype == `DTYPE_INT8)? a_fiv_clk_del_int8 : a_fiv_clk_del_fp16;
assign a_data_delayed[7*`DWIDTH-1:6*`DWIDTH] = (dtype == `DTYPE_INT8)? a_six_clk_del_int8 : a_six_clk_del_fp16;
assign a_data_delayed[8*`DWIDTH-1:7*`DWIDTH] = (dtype == `DTYPE_INT8)? a_sev_clk_del_int8 : a_sev_clk_del_fp16;


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
        (dtype == `DTYPE_FP16) ? b_data_valid_part1 :
        (b_data_valid_part1 || b_data_valid_part2)
      ) ?
        1'b0 : (b_mem_access_counter >= `MEM_ACCESS_LATENCY);

//////////////////////////////////////////////////////////////////////////
// Logic to delay certain parts of the data received from BRAM B (systolic data setup)
//////////////////////////////////////////////////////////////////////////
wire [`MASK_WIDTH-1:0] validity_mask_b_cols_internal;
assign validity_mask_b_cols_internal = (dtype == `DTYPE_INT8) ? validity_mask_b_cols : {validity_mask_b_cols[3],validity_mask_b_cols[3], validity_mask_b_cols[2],validity_mask_b_cols[2], validity_mask_b_cols[1],validity_mask_b_cols[1], validity_mask_b_cols[0],validity_mask_b_cols[0]};

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
assign b_data_delayed[2*`DWIDTH-1:1*`DWIDTH] = (dtype == `DTYPE_INT8)? b_one_clk_del_int8 : b_one_clk_del_fp16;
assign b_data_delayed[3*`DWIDTH-1:2*`DWIDTH] = (dtype == `DTYPE_INT8)? b_two_clk_del_int8 : b_two_clk_del_fp16;
assign b_data_delayed[4*`DWIDTH-1:3*`DWIDTH] = (dtype == `DTYPE_INT8)? b_thr_clk_del_int8 : b_thr_clk_del_fp16;
assign b_data_delayed[5*`DWIDTH-1:4*`DWIDTH] = (dtype == `DTYPE_INT8)? b_fou_clk_del_int8 : b_fou_clk_del_fp16;
assign b_data_delayed[6*`DWIDTH-1:5*`DWIDTH] = (dtype == `DTYPE_INT8)? b_fiv_clk_del_int8 : b_fiv_clk_del_fp16;
assign b_data_delayed[7*`DWIDTH-1:6*`DWIDTH] = (dtype == `DTYPE_INT8)? b_six_clk_del_int8 : b_six_clk_del_fp16;
assign b_data_delayed[8*`DWIDTH-1:7*`DWIDTH] = (dtype == `DTYPE_INT8)? b_sev_clk_del_int8 : b_sev_clk_del_fp16;

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
reg [`DWIDTH-1:0] out_int8;
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
start_mat_mul,
a_data,
b_data,
dtype,
pe_data_out,
a_data_out,
b_data_out
);

input clk;
input reset;
input pe_reset;
input start_mat_mul;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data;
input dtype;
output [511:0] pe_data_out;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out;


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
assign in_a_pe00 = (dtype == `DTYPE_FP16) ? a_data[15:0] : {8'b0, a_data[7:0]};
assign in_b_pe00 = (dtype == `DTYPE_FP16) ? b_data[15:0] : {b_data[7:0], b_data[15:8], b_data[23:16], b_data[31:24]};

wire [2*`DWIDTH-1:0] a0_0to0_1_fp16;
wire [1*`DWIDTH-1:0] a0_3to0_4_int8;
assign a0_0to0_1_fp16 = out_a_pe00;
assign a0_3to0_4_int8 = out_a_pe00[7:0];
assign in_a_pe01 = (dtype == `DTYPE_FP16) ? a0_0to0_1_fp16 : {8'b0, a0_3to0_4_int8};
assign in_b_pe01 = (dtype == `DTYPE_FP16) ? b_data[15:0] : {b_data[39:32], b_data[47:40], b_data[55:48], b_data[63:56]};

wire [2*`DWIDTH-1:0] a0_1to0_2_fp16;
assign a0_1to0_2_fp16 = out_a_pe01;
assign in_a_pe02 = (dtype == `DTYPE_FP16) ? a0_1to0_2_fp16 : {8'b0, a_data[15:8]};
assign in_b_pe02 = (dtype == `DTYPE_FP16) ? b_data[31:16] : out_b_pe00;

wire [2*`DWIDTH-1:0] a0_2to0_3_fp16;
wire [1*`DWIDTH-1:0] a1_3to1_4_int8;
assign a0_2to0_3_fp16 = out_a_pe02;
assign a1_3to1_4_int8 = out_a_pe02[7:0];
assign in_a_pe03 = (dtype == `DTYPE_FP16) ? a0_2to0_3_fp16 : a1_3to1_4_int8;
assign in_b_pe03 = (dtype == `DTYPE_FP16) ? b_data[47:32] : out_b_pe01;


///////////////////////////////////////////
// Second row of PEs 
///////////////////////////////////////////
wire [2*`DWIDTH-1:0] b0_0to1_0_fp16;
assign b0_0to1_0_fp16 = out_b_pe00[15:0];
assign in_a_pe10 = (dtype == `DTYPE_FP16) ? a_data[31:16] : {8'b0, a_data[23:16]};
assign in_b_pe10 = (dtype == `DTYPE_FP16) ? b0_0to1_0_fp16 : out_b_pe02;

wire [2*`DWIDTH-1:0] a1_0to1_1_fp16;
wire [1*`DWIDTH-1:0] a2_3to2_4_int8;
wire [2*`DWIDTH-1:0] b0_1to1_1_fp16;
assign a1_0to1_1_fp16 = out_a_pe10;
assign a2_3to2_4_int8 = out_a_pe10[7:0];
assign b0_1to1_1_fp16 = out_b_pe01[15:0];
assign in_a_pe11 = (dtype == `DTYPE_FP16) ? a1_0to1_1_fp16 : a2_3to2_4_int8;
assign in_b_pe11 = (dtype == `DTYPE_FP16) ? b0_1to1_1_fp16 : out_b_pe03;

wire [2*`DWIDTH-1:0] a1_1to1_2_fp16;
wire [2*`DWIDTH-1:0] b0_2to1_2_fp16;
assign a1_1to1_2_fp16 = out_a_pe11;
assign b0_2to1_2_fp16 = out_b_pe02[15:0];
assign in_a_pe12 = (dtype == `DTYPE_FP16) ? a1_1to1_2_fp16 : {8'b0, a_data[31:24]};
assign in_b_pe12 = (dtype == `DTYPE_FP16) ? b0_2to1_2_fp16 : out_b_pe10;

wire [2*`DWIDTH-1:0] a1_2to1_3_fp16;
wire [1*`DWIDTH-1:0] a3_3to3_4_int8;
wire [2*`DWIDTH-1:0] b0_3to1_3_fp16;
assign a1_2to1_3_fp16 = out_a_pe12;
assign a3_3to3_4_int8 = out_a_pe12[7:0];
assign b0_3to1_3_fp16 = out_b_pe03[15:0];
assign in_a_pe13 = (dtype == `DTYPE_FP16) ? a1_2to1_3_fp16 : {8'b0, a3_3to3_4_int8};
assign in_b_pe13 = (dtype == `DTYPE_FP16) ? b0_3to1_3_fp16 : out_b_pe11;


///////////////////////////////////////////
// Third row of PEs 
///////////////////////////////////////////
wire [2*`DWIDTH-1:0] b1_0to2_0_fp16;
assign b1_0to2_0_fp16 = out_b_pe10[15:0];
assign in_a_pe20 = (dtype == `DTYPE_FP16) ? a_data[47:32] : {8'b0, a_data[39:32]};
assign in_b_pe20 = (dtype == `DTYPE_FP16) ? b1_0to2_0_fp16 : out_b_pe12;

wire [2*`DWIDTH-1:0] a2_0to2_1_fp16;
wire [1*`DWIDTH-1:0] a4_3to4_4_int8;
wire [2*`DWIDTH-1:0] b1_1to2_1_fp16;
assign a2_0to2_1_fp16 = out_a_pe20; 
assign a4_3to4_4_int8 = out_a_pe20[7:0];
assign b1_1to2_1_fp16 = out_b_pe11[15:0];
assign in_a_pe21 = (dtype == `DTYPE_FP16) ? a2_0to2_1_fp16 : a4_3to4_4_int8;
assign in_b_pe21 = (dtype == `DTYPE_FP16) ? b1_1to2_1_fp16 : out_b_pe13;

wire [2*`DWIDTH-1:0] a2_1to2_2_fp16;
wire [2*`DWIDTH-1:0] b1_2to2_2_fp16;
assign a2_1to2_2_fp16 = out_a_pe21;
assign b1_2to2_2_fp16 = out_b_pe12[15:0];
assign in_a_pe22 = (dtype == `DTYPE_FP16) ? a2_1to2_2_fp16 : {8'b0, a_data[47:40]};
assign in_b_pe22 = (dtype == `DTYPE_FP16) ? b1_2to2_2_fp16 : out_b_pe20;

wire [2*`DWIDTH-1:0] a2_2to2_3_fp16;
wire [1*`DWIDTH-1:0] a5_3to5_4_int8;
wire [2*`DWIDTH-1:0] b1_3to2_3_fp16;
assign a2_2to2_3_fp16 = out_a_pe22;
assign a5_3to5_4_int8 = out_a_pe22[7:0];
assign b1_3to2_3_fp16 = out_b_pe13[15:0];
assign in_a_pe23 = (dtype == `DTYPE_FP16) ? a2_2to2_3_fp16 : {8'b0, a5_3to5_4_int8};
assign in_b_pe23 = (dtype == `DTYPE_FP16) ? b1_3to2_3_fp16 : out_b_pe21;


///////////////////////////////////////////
// Fourth row of PEs 
///////////////////////////////////////////
wire [2*`DWIDTH-1:0] b2_0to3_0_fp16;
assign b2_0to3_0_fp16 = out_b_pe20[15:0];
assign in_a_pe30 = (dtype == `DTYPE_FP16) ? a_data[63:48] : {8'b0, a_data[55:48]};
assign in_b_pe30 = (dtype == `DTYPE_FP16) ? b2_0to3_0_fp16 : out_b_pe22;

wire [2*`DWIDTH-1:0] a3_0to3_1_fp16;
wire [1*`DWIDTH-1:0] a6_3to6_4_int8;
wire [2*`DWIDTH-1:0] b2_1to3_1_fp16;
assign a3_0to3_1_fp16 = out_a_pe30;
assign a6_3to6_4_int8 = out_a_pe30[7:0];
assign b2_1to3_1_fp16 = out_b_pe21[15:0];
assign in_a_pe31 = (dtype == `DTYPE_FP16) ? a3_0to3_1_fp16 : a6_3to6_4_int8;
assign in_b_pe31 = (dtype == `DTYPE_FP16) ? b2_1to3_1_fp16 : out_b_pe23;

wire [2*`DWIDTH-1:0] a3_1to3_2_fp16;
wire [2*`DWIDTH-1:0] b2_2to3_2_fp16;
assign a3_1to3_2_fp16 = out_a_pe31;
assign b2_2to3_2_fp16 = out_b_pe22[15:0];
assign in_a_pe32 = (dtype == `DTYPE_FP16) ? a3_1to3_2_fp16 : {8'b0, a_data[63:56]};
assign in_b_pe32 = (dtype == `DTYPE_FP16) ? b2_2to3_2_fp16 : out_b_pe30;

wire [2*`DWIDTH-1:0] a3_2to3_3_fp16;
wire [1*`DWIDTH-1:0] a7_3to7_4_int8;
wire [2*`DWIDTH-1:0] b2_3to3_3_fp16;
assign a3_2to3_3_fp16 = out_a_pe32;
assign a7_3to7_4_int8 = out_a_pe32[7:0];
assign b2_3to3_3_fp16 = out_b_pe23[15:0];
assign in_a_pe33 = (dtype == `DTYPE_FP16) ? a3_2to3_3_fp16 : {8'b0, a7_3to7_4_int8};
assign in_b_pe33 = (dtype == `DTYPE_FP16) ? b2_3to3_3_fp16 : out_b_pe31;

//                                                                          16 bits                 32 bits           16 bits             32 bits          32 bits
processing_element pe00(.reset(effective_rst), .clk(clk),  .dtype(dtype), .in_a(in_a_pe00), .in_b(in_b_pe00), .out_a(out_a_pe00), .out_b(out_b_pe00), .out_c(out_c_pe00));
processing_element pe01(.reset(effective_rst), .clk(clk),  .dtype(dtype), .in_a(in_a_pe01), .in_b(in_b_pe01), .out_a(out_a_pe01), .out_b(out_b_pe01), .out_c(out_c_pe01));
processing_element pe02(.reset(effective_rst), .clk(clk),  .dtype(dtype), .in_a(in_a_pe02), .in_b(in_b_pe02), .out_a(out_a_pe02), .out_b(out_b_pe02), .out_c(out_c_pe02));
processing_element pe03(.reset(effective_rst), .clk(clk),  .dtype(dtype), .in_a(in_a_pe03), .in_b(in_b_pe03), .out_a(out_a_pe03), .out_b(out_b_pe03), .out_c(out_c_pe03));

processing_element pe10(.reset(effective_rst), .clk(clk),  .dtype(dtype), .in_a(in_a_pe10), .in_b(in_b_pe10), .out_a(out_a_pe10), .out_b(out_b_pe10), .out_c(out_c_pe10));
processing_element pe11(.reset(effective_rst), .clk(clk),  .dtype(dtype), .in_a(in_a_pe11), .in_b(in_b_pe11), .out_a(out_a_pe11), .out_b(out_b_pe11), .out_c(out_c_pe11));
processing_element pe12(.reset(effective_rst), .clk(clk),  .dtype(dtype), .in_a(in_a_pe12), .in_b(in_b_pe12), .out_a(out_a_pe12), .out_b(out_b_pe12), .out_c(out_c_pe12));
processing_element pe13(.reset(effective_rst), .clk(clk),  .dtype(dtype), .in_a(in_a_pe13), .in_b(in_b_pe13), .out_a(out_a_pe13), .out_b(out_b_pe13), .out_c(out_c_pe13));

processing_element pe20(.reset(effective_rst), .clk(clk),  .dtype(dtype), .in_a(in_a_pe20), .in_b(in_b_pe20), .out_a(out_a_pe20), .out_b(out_b_pe20), .out_c(out_c_pe20));
processing_element pe21(.reset(effective_rst), .clk(clk),  .dtype(dtype), .in_a(in_a_pe21), .in_b(in_b_pe21), .out_a(out_a_pe21), .out_b(out_b_pe21), .out_c(out_c_pe21));
processing_element pe22(.reset(effective_rst), .clk(clk),  .dtype(dtype), .in_a(in_a_pe22), .in_b(in_b_pe22), .out_a(out_a_pe22), .out_b(out_b_pe22), .out_c(out_c_pe22));
processing_element pe23(.reset(effective_rst), .clk(clk),  .dtype(dtype), .in_a(in_a_pe23), .in_b(in_b_pe23), .out_a(out_a_pe23), .out_b(out_b_pe23), .out_c(out_c_pe23));

processing_element pe30(.reset(effective_rst), .clk(clk),  .dtype(dtype), .in_a(in_a_pe30), .in_b(in_b_pe30), .out_a(out_a_pe30), .out_b(out_b_pe30), .out_c(out_c_pe30));
processing_element pe31(.reset(effective_rst), .clk(clk),  .dtype(dtype), .in_a(in_a_pe31), .in_b(in_b_pe31), .out_a(out_a_pe31), .out_b(out_b_pe31), .out_c(out_c_pe31));
processing_element pe32(.reset(effective_rst), .clk(clk),  .dtype(dtype), .in_a(in_a_pe32), .in_b(in_b_pe32), .out_a(out_a_pe32), .out_b(out_b_pe32), .out_c(out_c_pe32));
processing_element pe33(.reset(effective_rst), .clk(clk),  .dtype(dtype), .in_a(in_a_pe33), .in_b(in_b_pe33), .out_a(out_a_pe33), .out_b(out_b_pe33), .out_c(out_c_pe33));
endmodule

// This PE acts as one fp16 PE and 4 int8 PEs (connected horizontally)
module processing_element(
 reset, 
 clk, 
 dtype,
 in_a,
 in_b,
 out_a,
 out_b,
 out_c
 );

 input reset;
 input clk;
 input dtype;
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

 reg [2*`DWIDTH-1:0] out_a;
 reg [4*`DWIDTH-1:0] out_b;

 wire [4*`DWIDTH-1:0] out_mac;
 wire [4*`DWIDTH-1:0] a_seq_mac;
 wire [4*`DWIDTH-1:0] b_seq_mac;

 reg [`DWIDTH-1: 0] out_a_0to1;
 reg [`DWIDTH-1: 0] out_a_1to2;
 reg [`DWIDTH-1: 0] out_a_2to3;

 assign a_seq_mac = (dtype == `DTYPE_FP16) ? {16'b0, in_a[15:0]} : {in_a[7:0], out_a_0to1, out_a_1to2, out_a_2to3 };
 assign b_seq_mac = (dtype == `DTYPE_FP16) ? {16'b0, in_b[15:0]} : {in_b[31:24], in_b[23:16], in_b[15:8], in_b[7:0]};

 seq_mac u_mac( .clk(clk), 
                .reset(reset), 
                .dtype(dtype), 
                .a(a_seq_mac), 
                .b(b_seq_mac), 
                .out(out_mac));

 assign out_c[15:0]  = (dtype == `DTYPE_FP16) ? out_mac[15:0] : {out_mac[15:8],  out_mac[7:0]};
 assign out_c[31:16] = (dtype == `DTYPE_FP16) ? {16{1'b0}}    : {out_mac[31:24], out_mac[23:16]} ;

 always @(posedge clk)begin
    if(reset) begin
      out_a <= 0;
      out_b <= 0;
      out_a_0to1 <= 0;
      out_a_1to2 <= 0;
      out_a_2to3 <= 0;
    end
    else begin  
      out_a[7:0]   <= (dtype == `DTYPE_FP16) ? in_a[7:0]  : out_a_2to3;
      out_a[15:8]  <= (dtype == `DTYPE_FP16) ? in_a[15:8] : 8'b0;
      out_b[7:0]   <= in_b[7:0];
      out_b[15:8]  <= in_b[15:8];
      out_b[23:16] <= (dtype == `DTYPE_FP16) ? 8'b0 : in_b[23:16];
      out_b[31:24] <= (dtype == `DTYPE_FP16) ? 8'b0 : in_b[31:24];
      
      out_a_0to1 <= in_a;
      out_a_1to2 <= out_a_0to1;
      out_a_2to3 <= out_a_1to2;
    end
 end
 
endmodule

module seq_mac(clk, reset, dtype, a, b, out);
input clk;
input reset;
input dtype;
input [4*`DWIDTH-1:0] a;
input [4*`DWIDTH-1:0] b;
output [4*`DWIDTH-1:0] out;

wire [8*`DWIDTH-1:0] add_out;

reg [4*`DWIDTH-1:0] a_flopped; //32 bits
reg [4*`DWIDTH-1:0] b_flopped; //32 bits

always @(posedge clk) begin
  if (reset) begin
    a_flopped <= 0;
    b_flopped <= 0;
  end else begin
    a_flopped <= a;
    b_flopped <= b;
  end
end

wire [8*`DWIDTH-1:0] mul_out; //64 bits
//                            32 bits                   32 bits              64 bits
qmult mult_u1(.i_multiplicand(a_flopped), .i_multiplier(b_flopped), .o_result(mul_out), .dtype(dtype));

reg [8*`DWIDTH-1:0] mul_out_reg;
always @(posedge clk) begin
  if (reset) begin
    mul_out_reg <= 0;
  end else begin
    mul_out_reg <= mul_out;
  end
end

reg [8*`DWIDTH-1:0] out_temp;
//             64 bits       64 bits         64 bits
qadd add_u1(.a(out_temp), .b(mul_out_reg), .c(add_out), .dtype(dtype));

always @(posedge clk) begin
  if (reset) begin
    out_temp <= 0;
  end else begin
    out_temp <= add_out;
  end
end

//Reduce precision
//TODO: For now, this is just faking it
assign out[4*`DWIDTH-1:0] = {out_temp[55:48], out_temp[39:32], out_temp[23:16], out_temp[7:0]};

endmodule

/////////////////////////////////////////
// For int8:
// Multiplication: 8 bits * 8 bits -> 16 bits
// Addition:       16 bits + 16 bits -> 16 bits
// We can provide an option to do accumulation/addition 
// in 8 bits, but that can come later.
//
// For fp16:
// Multiplication: 16 bits * 16 bits -> 16 bits (then cast this to 32 bits)
// Addition:       32 bits + 32 bits -> 32 bits
// We can provide an option to do accumulation/addition 
// in 16 bits, but that can come later.

//4 int8 multipliers, one fp16 multiplier
module qmult(i_multiplicand, i_multiplier, o_result, dtype);
input [4*`DWIDTH-1:0] i_multiplicand;
input [4*`DWIDTH-1:0] i_multiplier;
output [8*`DWIDTH-1:0] o_result;
input dtype;

reg [8*`DWIDTH-1:0] o_result;

always @(*) begin
  if (dtype == `DTYPE_INT8) begin
    o_result[15:0]  = i_multiplicand[7:0]   * i_multiplier[7:0];
    o_result[31:16] = i_multiplicand[15:8]  * i_multiplier[15:8];
    o_result[47:32] = i_multiplicand[23:16] * i_multiplier[23:16];
    o_result[63:48] = i_multiplicand[31:24] * i_multiplier[31:24];
  end
  else begin
    o_result[31:0]  = i_multiplicand[15:0] * i_multiplier[15:0];
  end
end
endmodule

//4 int8 adders (actually int16 adders because we support accumulation in higher precision), one fp16 adder (actually fp32 adder)
module qadd(a, b, c, dtype);
input [8*`DWIDTH-1:0] a;
input [8*`DWIDTH-1:0] b;
output [8*`DWIDTH-1:0] c;
input dtype;

reg [8*`DWIDTH-1:0] c;

always @(*) begin
  if (dtype == `DTYPE_INT8) begin
    c[15:0]  = a[15:0]  + b[15:0];
    c[31:16] = a[31:16] + b[31:16];
    c[47:32] = a[47:32] + b[47:32];
    c[63:48] = a[63:48] + b[63:48];
  end
  else begin
    c[31:0] = a[31:0] + b[31:0];
  end
end

endmodule
