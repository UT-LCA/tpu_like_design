
`timescale 1ns/1ns
`define DWIDTH 8
`define AWIDTH 11
`define MEM_SIZE 2048

`define MAT_MUL_SIZE 4
`define MASK_WIDTH 4
`define LOG2_MAT_MUL_SIZE 2

`define BB_MAT_MUL_SIZE `MAT_MUL_SIZE
`define NUM_CYCLES_IN_MAC 3
`define MEM_ACCESS_LATENCY 1
`define REG_DATAWIDTH 32
`define REG_ADDRWIDTH 8
`define ADDR_STRIDE_WIDTH 8
`define MAX_BITS_POOL 3

//Design with memories
module matrix_multiplication(
  clk, 
  clk_mem, 
  resetn, 
  address_mat_a,
  address_mat_b,
  address_mat_c,
  address_stride_a,
  address_stride_b,
  address_stride_c,
  save_output_to_accum,
  add_accum_to_output,
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
  clear_done_reg
);

  input clk;
  input clk_mem;
  input resetn;
  input [`AWIDTH-1:0] address_mat_a;
  input [`AWIDTH-1:0] address_mat_b;
  input [`AWIDTH-1:0] address_mat_c;
  input [`ADDR_STRIDE_WIDTH-1:0] address_stride_a;
  input [`ADDR_STRIDE_WIDTH-1:0] address_stride_b;
  input [`ADDR_STRIDE_WIDTH-1:0] address_stride_c;
  input save_output_to_accum;
  input add_accum_to_output;
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

	wire [`AWIDTH-1:0] bram_addr_a;
	wire [4*`DWIDTH-1:0] bram_rdata_a;
	wire [4*`DWIDTH-1:0] bram_wdata_a;
	wire [`MASK_WIDTH-1:0] bram_we_a;
	wire bram_en_a;

	wire [`AWIDTH-1:0] bram_addr_b;
	wire [4*`DWIDTH-1:0] bram_rdata_b;
	wire [4*`DWIDTH-1:0] bram_wdata_b;
	wire [`MASK_WIDTH-1:0] bram_we_b;
	wire bram_en_b;
	
	wire [`AWIDTH-1:0] bram_addr_c;
	wire [4*`DWIDTH-1:0] bram_rdata_c;
	wire [4*`DWIDTH-1:0] bram_wdata_c;
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
  assign bram_we_c = (c_data_available) ? 4'b1111 : 4'b0000;  

//Connections for bram a (first input matrix)
//bram_addr_a -> connected to u_matmul_4x4
//bram_rdata_a -> connected to u_matmul_4x4
//bram_wdata_a -> hardcoded to 0 (this block only reads from bram a)
//bram_we_a -> hardcoded to 0 (this block only reads from bram a)
//bram_en_a -> hardcoded to 1

  assign bram_wdata_a = 32'b0;
  assign bram_en_a = 1'b1;
  assign bram_we_a = 4'b0;
  
//Connections for bram b (second input matrix)
//bram_addr_b -> connected to u_matmul_4x4
//bram_rdata_b -> connected to u_matmul_4x4
//bram_wdata_b -> hardcoded to 0 (this block only reads from bram b)
//bram_we_b -> hardcoded to 0 (this block only reads from bram b)
//bram_en_b -> hardcoded to 1

  assign bram_wdata_b = 32'b0;
  assign bram_en_b = 1'b1;
  assign bram_we_b = 4'b0;
  
//NC wires 
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out_NC;
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out_NC;
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_NC;
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_NC;

wire reset;
assign reset = ~resetn;

matmul u_matmul_4x4(
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
  .c_data_out(bram_wdata_c),
  .a_data_out(a_data_out_NC),
  .b_data_out(b_data_out_NC),
  .a_addr(bram_addr_a),
  .b_addr(bram_addr_b),
  .c_addr(bram_addr_c),
  .c_data_available(c_data_available),
  .save_output_to_accum(save_output_to_accum),
  .add_accum_to_output(add_accum_to_output),
  .enable_conv_mode(1'b0),
  .conv_filter_height(4'd1),
  .conv_filter_width(4'd1),
  .conv_stride_horiz(4'd1),
  .conv_stride_verti(4'd1),
  .conv_padding_left(4'd0),
  .conv_padding_right(4'd0),
  .conv_padding_top(4'd0),
  .conv_padding_bottom(4'd0),
  .num_channels_inp(16'd4),
  .num_channels_out(16'd4),
  .inp_img_height(16'd8),
  .inp_img_width(16'd8),
  .out_img_height(16'd8),
  .out_img_width(16'd8),
  .batch_size(32'd64),
  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd4),
  .a_loc(8'd0),
  .b_loc(8'd0)
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
reg [7:0] clk_cnt;

//Finding out number of cycles to assert matmul done.
//When we have to save the outputs to accumulators, then we don't need to
//shift out data. So, we can assert done_mat_mul early.
//In the normal case, we have to include the time to shift out the results. 
//Note: the count expression used to contain "4*final_mat_mul_size", but 
//to avoid multiplication, we now use "final_mat_mul_size<<2"
wire [7:0] clk_cnt_for_done;
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
reg dummy;

always @(posedge clk) begin
  //We want to reset c,r,s when reset is asserted. And also when we have finished
  //the last accumulation of a pass. For the next pass, we need to start fresh
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

wire [`DWIDTH-1:0] a0_data;
wire [`DWIDTH-1:0] a1_data;
wire [`DWIDTH-1:0] a2_data;
wire [`DWIDTH-1:0] a3_data;
wire [`DWIDTH-1:0] b0_data;
wire [`DWIDTH-1:0] b1_data;
wire [`DWIDTH-1:0] b2_data;
wire [`DWIDTH-1:0] b3_data;
wire [`DWIDTH-1:0] a1_data_delayed_1;
wire [`DWIDTH-1:0] a2_data_delayed_1;
wire [`DWIDTH-1:0] a2_data_delayed_2;
wire [`DWIDTH-1:0] a3_data_delayed_1;
wire [`DWIDTH-1:0] a3_data_delayed_2;
wire [`DWIDTH-1:0] a3_data_delayed_3;
wire [`DWIDTH-1:0] b1_data_delayed_1;
wire [`DWIDTH-1:0] b2_data_delayed_1;
wire [`DWIDTH-1:0] b2_data_delayed_2;
wire [`DWIDTH-1:0] b3_data_delayed_1;
wire [`DWIDTH-1:0] b3_data_delayed_2;
wire [`DWIDTH-1:0] b3_data_delayed_3;

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
.b0_data(b0_data),
.b1_data_delayed_1(b1_data_delayed_1),
.b2_data_delayed_2(b2_data_delayed_2),
.b3_data_delayed_3(b3_data_delayed_3),
.validity_mask_a_rows(validity_mask_a_rows),
.validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
.validity_mask_b_cols(validity_mask_b_cols),
.enable_conv_mode(enable_conv_mode),
.r(r),
.s(s),
.c(c),
.num_channels_out(num_channels_out),
.conv_padding_left(conv_padding_left),
.conv_padding_right(conv_padding_right),
.conv_padding_top(conv_padding_top),
.conv_padding_bottom(conv_padding_bottom),
.inp_img_height(inp_img_height),
.inp_img_width(inp_img_width),
.final_mat_mul_size(final_mat_mul_size),
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
wire [`DWIDTH-1:0] b0;
wire [`DWIDTH-1:0] b1;
wire [`DWIDTH-1:0] b2;
wire [`DWIDTH-1:0] b3;

wire [`DWIDTH-1:0] a0_data_in;
wire [`DWIDTH-1:0] a1_data_in;
wire [`DWIDTH-1:0] a2_data_in;
wire [`DWIDTH-1:0] a3_data_in;
assign a0_data_in = a_data_in[`DWIDTH-1:0];
assign a1_data_in = a_data_in[2*`DWIDTH-1:`DWIDTH];
assign a2_data_in = a_data_in[3*`DWIDTH-1:2*`DWIDTH];
assign a3_data_in = a_data_in[4*`DWIDTH-1:3*`DWIDTH];

wire [`DWIDTH-1:0] b0_data_in;
wire [`DWIDTH-1:0] b1_data_in;
wire [`DWIDTH-1:0] b2_data_in;
wire [`DWIDTH-1:0] b3_data_in;
assign b0_data_in = b_data_in[`DWIDTH-1:0];
assign b1_data_in = b_data_in[2*`DWIDTH-1:`DWIDTH];
assign b2_data_in = b_data_in[3*`DWIDTH-1:2*`DWIDTH];
assign b3_data_in = b_data_in[4*`DWIDTH-1:3*`DWIDTH];

//If b_loc is 0, that means this matmul block is on the top-row of the
//final large matmul. In that case, b will take inputs from mem.
//If b_loc != 0, that means this matmul block is not on the top-row of the
//final large matmul. In that case, b will take inputs from the matmul on top
//of this one.
assign a0 = (b_loc==0) ? a0_data           : a0_data_in;
assign a1 = (b_loc==0) ? a1_data_delayed_1 : a1_data_in;
assign a2 = (b_loc==0) ? a2_data_delayed_2 : a2_data_in;
assign a3 = (b_loc==0) ? a3_data_delayed_3 : a3_data_in;

//If a_loc is 0, that means this matmul block is on the left-col of the
//final large matmul. In that case, a will take inputs from mem.
//If a_loc != 0, that means this matmul block is not on the left-col of the
//final large matmul. In that case, a will take inputs from the matmul on left
//of this one.
assign b0 = (a_loc==0) ? b0_data           : b0_data_in;
assign b1 = (a_loc==0) ? b1_data_delayed_1 : b1_data_in;
assign b2 = (a_loc==0) ? b2_data_delayed_2 : b2_data_in;
assign b3 = (a_loc==0) ? b3_data_delayed_3 : b3_data_in;


wire [`DWIDTH-1:0] matrixC00;
wire [`DWIDTH-1:0] matrixC01;
wire [`DWIDTH-1:0] matrixC02;
wire [`DWIDTH-1:0] matrixC03;
wire [`DWIDTH-1:0] matrixC10;
wire [`DWIDTH-1:0] matrixC11;
wire [`DWIDTH-1:0] matrixC12;
wire [`DWIDTH-1:0] matrixC13;
wire [`DWIDTH-1:0] matrixC20;
wire [`DWIDTH-1:0] matrixC21;
wire [`DWIDTH-1:0] matrixC22;
wire [`DWIDTH-1:0] matrixC23;
wire [`DWIDTH-1:0] matrixC30;
wire [`DWIDTH-1:0] matrixC31;
wire [`DWIDTH-1:0] matrixC32;
wire [`DWIDTH-1:0] matrixC33;

wire [`DWIDTH-1:0] matrixC00_added;
wire [`DWIDTH-1:0] matrixC01_added;
wire [`DWIDTH-1:0] matrixC02_added;
wire [`DWIDTH-1:0] matrixC03_added;
wire [`DWIDTH-1:0] matrixC10_added;
wire [`DWIDTH-1:0] matrixC11_added;
wire [`DWIDTH-1:0] matrixC12_added;
wire [`DWIDTH-1:0] matrixC13_added;
wire [`DWIDTH-1:0] matrixC20_added;
wire [`DWIDTH-1:0] matrixC21_added;
wire [`DWIDTH-1:0] matrixC22_added;
wire [`DWIDTH-1:0] matrixC23_added;
wire [`DWIDTH-1:0] matrixC30_added;
wire [`DWIDTH-1:0] matrixC31_added;
wire [`DWIDTH-1:0] matrixC32_added;
wire [`DWIDTH-1:0] matrixC33_added;

//////////////////////////////////////////////////////////////////////////
// Instantiation of accumulators
//////////////////////////////////////////////////////////////////////////
accumulators u_accumulators(
.reset(reset),
.clk(clk),
.save_output_to_accum(save_output_to_accum),
.add_accum_to_output(add_accum_to_output),
.reset_accum(reset_accum),
.row_latch_en(row_latch_en),
.r(r),
.s(s),
.c(c),
.matrixC00(matrixC00),
.matrixC01(matrixC01),
.matrixC02(matrixC02),
.matrixC03(matrixC03),
.matrixC10(matrixC10),
.matrixC11(matrixC11),
.matrixC12(matrixC12),
.matrixC13(matrixC13),
.matrixC20(matrixC20),
.matrixC21(matrixC21),
.matrixC22(matrixC22),
.matrixC23(matrixC23),
.matrixC30(matrixC30),
.matrixC31(matrixC31),
.matrixC32(matrixC32),
.matrixC33(matrixC33),
.matrixC00_added(matrixC00_added),
.matrixC01_added(matrixC01_added),
.matrixC02_added(matrixC02_added),
.matrixC03_added(matrixC03_added),
.matrixC10_added(matrixC10_added),
.matrixC11_added(matrixC11_added),
.matrixC12_added(matrixC12_added),
.matrixC13_added(matrixC13_added),
.matrixC20_added(matrixC20_added),
.matrixC21_added(matrixC21_added),
.matrixC22_added(matrixC22_added),
.matrixC23_added(matrixC23_added),
.matrixC30_added(matrixC30_added),
.matrixC31_added(matrixC31_added),
.matrixC32_added(matrixC32_added),
.matrixC33_added(matrixC33_added)
);

//////////////////////////////////////////////////////////////////////////
// Instantiation of the output logic
//////////////////////////////////////////////////////////////////////////
output_logic u_output_logic(
.clk(clk),
.reset(reset),
.start_mat_mul(start_mat_mul),
.done_mat_mul(done_mat_mul),
.address_mat_c(address_mat_c),
.address_stride_c(address_stride_c),
.c_data_out(c_data_out),
.c_addr(c_addr),
.c_data_available(c_data_available),
.clk_cnt(clk_cnt),
.save_output_to_accum(save_output_to_accum),
.add_accum_to_output(add_accum_to_output),
.reset_accum(reset_accum),
.row_latch_en(row_latch_en),
.matrixC00_added(matrixC00_added),
.matrixC01_added(matrixC01_added),
.matrixC02_added(matrixC02_added),
.matrixC03_added(matrixC03_added),
.matrixC10_added(matrixC10_added),
.matrixC11_added(matrixC11_added),
.matrixC12_added(matrixC12_added),
.matrixC13_added(matrixC13_added),
.matrixC20_added(matrixC20_added),
.matrixC21_added(matrixC21_added),
.matrixC22_added(matrixC22_added),
.matrixC23_added(matrixC23_added),
.matrixC30_added(matrixC30_added),
.matrixC31_added(matrixC31_added),
.matrixC32_added(matrixC32_added),
.matrixC33_added(matrixC33_added)
);


wire [`DWIDTH-1:0] cin_col0;
wire [`DWIDTH-1:0] cin_col1;
wire [`DWIDTH-1:0] cin_col2;
wire [`DWIDTH-1:0] cin_col3;
assign cin_col0 = c_data_in[`DWIDTH-1:0];
assign cin_col1 = c_data_in[2*`DWIDTH-1:`DWIDTH];
assign cin_col2 = c_data_in[3*`DWIDTH-1:2*`DWIDTH];
assign cin_col3 = c_data_in[4*`DWIDTH-1:3*`DWIDTH];

//////////////////////////////////////////////////////////////////////////
// Instantiations of the actual PEs
//////////////////////////////////////////////////////////////////////////
systolic_pe_matrix u_systolic_pe_matrix(
.reset(reset),
.clk(clk),
.start_mat_mul(start_mat_mul),
.a0(a0), 
.a1(a1), 
.a2(a2), 
.a3(a3),
.b0(b0), 
.b1(b1), 
.b2(b2), 
.b3(b3),
.matrixC00(matrixC00),
.matrixC01(matrixC01),
.matrixC02(matrixC02),
.matrixC03(matrixC03),
.matrixC10(matrixC10),
.matrixC11(matrixC11),
.matrixC12(matrixC12),
.matrixC13(matrixC13),
.matrixC20(matrixC20),
.matrixC21(matrixC21),
.matrixC22(matrixC22),
.matrixC23(matrixC23),
.matrixC30(matrixC30),
.matrixC31(matrixC31),
.matrixC32(matrixC32),
.matrixC33(matrixC33),
.a_data_out(a_data_out),
.b_data_out(b_data_out)
);

endmodule

//////////////////////////////////////////////////////////////////////////
// Output logic
//////////////////////////////////////////////////////////////////////////
module output_logic(
clk,
reset,
start_mat_mul,
done_mat_mul,
address_mat_c,
address_stride_c,
c_data_out, //Data values going out to next matmul - systolic shifting
c_addr,
c_data_available,
clk_cnt,
save_output_to_accum,
add_accum_to_output,
reset_accum,
row_latch_en,
matrixC00_added,
matrixC01_added,
matrixC02_added,
matrixC03_added,
matrixC10_added,
matrixC11_added,
matrixC12_added,
matrixC13_added,
matrixC20_added,
matrixC21_added,
matrixC22_added,
matrixC23_added,
matrixC30_added,
matrixC31_added,
matrixC32_added,
matrixC33_added
);

input clk;
input reset;
input start_mat_mul;
input done_mat_mul;
input [`AWIDTH-1:0] address_mat_c;
input [`ADDR_STRIDE_WIDTH-1:0] address_stride_c;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_out;
output [`AWIDTH-1:0] c_addr;
output c_data_available;
input [7:0] clk_cnt;
input save_output_to_accum;
input add_accum_to_output;
output reset_accum;
output row_latch_en;
input [`DWIDTH-1:0] matrixC00_added;
input [`DWIDTH-1:0] matrixC01_added;
input [`DWIDTH-1:0] matrixC02_added;
input [`DWIDTH-1:0] matrixC03_added;
input [`DWIDTH-1:0] matrixC10_added;
input [`DWIDTH-1:0] matrixC11_added;
input [`DWIDTH-1:0] matrixC12_added;
input [`DWIDTH-1:0] matrixC13_added;
input [`DWIDTH-1:0] matrixC20_added;
input [`DWIDTH-1:0] matrixC21_added;
input [`DWIDTH-1:0] matrixC22_added;
input [`DWIDTH-1:0] matrixC23_added;
input [`DWIDTH-1:0] matrixC30_added;
input [`DWIDTH-1:0] matrixC31_added;
input [`DWIDTH-1:0] matrixC32_added;
input [`DWIDTH-1:0] matrixC33_added;

wire row_latch_en;

//////////////////////////////////////////////////////////////////////////
// Logic to capture matrix C data from the PEs and shift it out
//////////////////////////////////////////////////////////////////////////

//assign row_latch_en = (clk_cnt==(`MAT_MUL_SIZE + (a_loc+b_loc) * `BB_MAT_MUL_SIZE + 10 +  `NUM_CYCLES_IN_MAC - 1));
//Writing the line above to avoid multiplication:
//assign row_latch_en = (clk_cnt==(`MAT_MUL_SIZE + ((a_loc+b_loc) << `LOG2_MAT_MUL_SIZE) + 10 +  `NUM_CYCLES_IN_MAC - 1));
//Fixing bug. The line above is inaccurate. Using the line below. 
//TODO: This line needs to be fixed to include a_loc and b_loc ie. when final_mat_mul_size is different from `MAT_MUL_SIZE
assign row_latch_en =  (save_output_to_accum) ?
                       ((clk_cnt == ((`MAT_MUL_SIZE<<2) - `MAT_MUL_SIZE -1 +`NUM_CYCLES_IN_MAC))) :
                       ((clk_cnt == ((`MAT_MUL_SIZE<<2) - `MAT_MUL_SIZE -2 +`NUM_CYCLES_IN_MAC)));

reg c_data_available;
reg [`AWIDTH-1:0] c_addr;
reg start_capturing_c_data;
integer counter;
reg [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_out;
wire reset_accum;

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
    c_addr <= c_addr + address_stride_c;
    c_data_out <= {matrixC30_added, matrixC20_added, matrixC10_added, matrixC00_added};  //first set of elements is captured here
    counter <= counter + 1;
  end else if (done_mat_mul) begin
    start_capturing_c_data <= 1'b0;
    c_data_available <= 1'b0;
    c_addr <= address_mat_c-address_stride_c;
    c_data_out <= 0;
  end 
  else if (start_capturing_c_data) begin
    c_data_available <= 1'b1;
    c_addr <= c_addr + address_stride_c;
    counter <= counter + 1;
    case (counter)  //rest of the elements are captured here
        1: c_data_out <= {matrixC31_added, matrixC21_added, matrixC11_added, matrixC01_added};
        2: c_data_out <= {matrixC32_added, matrixC22_added, matrixC12_added, matrixC02_added};
        3: c_data_out <= {matrixC33_added, matrixC23_added, matrixC13_added, matrixC03_added};
        default: c_data_out <= 0;
    endcase
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
a0_data,
a1_data_delayed_1,
a2_data_delayed_2,
a3_data_delayed_3,
b0_data,
b1_data_delayed_1,
b2_data_delayed_2,
b3_data_delayed_3,
validity_mask_a_rows,
validity_mask_a_cols_b_rows,
validity_mask_b_cols,
enable_conv_mode,
r,
s,
c,
num_channels_out,
conv_padding_left,
conv_padding_right,
conv_padding_top,
conv_padding_bottom,
inp_img_height,
inp_img_width,
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
output [`DWIDTH-1:0] a0_data;
output [`DWIDTH-1:0] a1_data_delayed_1;
output [`DWIDTH-1:0] a2_data_delayed_2;
output [`DWIDTH-1:0] a3_data_delayed_3;
output [`DWIDTH-1:0] b0_data;
output [`DWIDTH-1:0] b1_data_delayed_1;
output [`DWIDTH-1:0] b2_data_delayed_2;
output [`DWIDTH-1:0] b3_data_delayed_3;
input enable_conv_mode;
input [3:0] r; //iterator for filter height
input [3:0] s; //iterator for filter width
input [15:0] c; //iterator for input channels
input [15:0] num_channels_out;
input [3:0] conv_padding_left;
input [3:0] conv_padding_right;
input [3:0] conv_padding_top;
input [3:0] conv_padding_bottom;
input [15:0] inp_img_height;
input [15:0] inp_img_width;
input [`MASK_WIDTH-1:0] validity_mask_a_rows;
input [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows;
input [`MASK_WIDTH-1:0] validity_mask_b_cols;
input [7:0] final_mat_mul_size;
input [7:0] a_loc;
input [7:0] b_loc;

wire [`DWIDTH-1:0] a0_data;
wire [`DWIDTH-1:0] a1_data;
wire [`DWIDTH-1:0] a2_data;
wire [`DWIDTH-1:0] a3_data;
wire [`DWIDTH-1:0] b0_data;
wire [`DWIDTH-1:0] b1_data;
wire [`DWIDTH-1:0] b2_data;
wire [`DWIDTH-1:0] b3_data;

//////////////////////////////////////////////////////////////////////////
// Logic to generate addresses to BRAM A
//////////////////////////////////////////////////////////////////////////
reg [`AWIDTH-1:0] a_addr;
reg a_mem_access; //flag that tells whether the matmul is trying to access memory or not

always @(posedge clk) begin
  //else if (clk_cnt >= a_loc*`MAT_MUL_SIZE+final_mat_mul_size) begin
  //Writing the line above to avoid multiplication:
  if ((reset || ~start_mat_mul) || (clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin
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

wire a_data_valid; //flag that tells whether the data from memory is valid
assign a_data_valid = 
       ((validity_mask_a_cols_b_rows[0]==1'b0 && a_mem_access_counter==0) ||
        (validity_mask_a_cols_b_rows[1]==1'b0 && a_mem_access_counter==1) ||
        (validity_mask_a_cols_b_rows[2]==1'b0 && a_mem_access_counter==2) ||
        (validity_mask_a_cols_b_rows[3]==1'b0 && a_mem_access_counter==3)) ?
        1'b0 : (a_mem_access_counter >= `MEM_ACCESS_LATENCY);

//////////////////////////////////////////////////////////////////////////
// Logic to delay certain parts of the data received from BRAM A (systolic data setup)
//////////////////////////////////////////////////////////////////////////
//Slice data into chunks and qualify it with whether it is valid or not
assign a0_data = a_data[`DWIDTH-1:0] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[0]}};
assign a1_data = a_data[2*`DWIDTH-1:`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[1]}};
assign a2_data = a_data[3*`DWIDTH-1:2*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[2]}};
assign a3_data = a_data[4*`DWIDTH-1:3*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[3]}};

//For larger matmuls, more such delaying flops will be needed
reg [`DWIDTH-1:0] a1_data_delayed_1;
reg [`DWIDTH-1:0] a2_data_delayed_1;
reg [`DWIDTH-1:0] a2_data_delayed_2;
reg [`DWIDTH-1:0] a3_data_delayed_1;
reg [`DWIDTH-1:0] a3_data_delayed_2;
reg [`DWIDTH-1:0] a3_data_delayed_3;
always @(posedge clk) begin
  if (reset || ~start_mat_mul || clk_cnt==0) begin
    a1_data_delayed_1 <= 0;
    a2_data_delayed_1 <= 0;
    a2_data_delayed_2 <= 0;
    a3_data_delayed_1 <= 0;
    a3_data_delayed_2 <= 0;
    a3_data_delayed_3 <= 0;
  end
  else begin
    a1_data_delayed_1 <= a1_data;
    a2_data_delayed_1 <= a2_data;
    a2_data_delayed_2 <= a2_data_delayed_1;
    a3_data_delayed_1 <= a3_data;
    a3_data_delayed_2 <= a3_data_delayed_1;
    a3_data_delayed_3 <= a3_data_delayed_2;
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

wire b_data_valid; //flag that tells whether the data from memory is valid
assign b_data_valid = 
       ((validity_mask_a_cols_b_rows[0]==1'b0 && b_mem_access_counter==0) ||
        (validity_mask_a_cols_b_rows[1]==1'b0 && b_mem_access_counter==1) ||
        (validity_mask_a_cols_b_rows[2]==1'b0 && b_mem_access_counter==2) ||
        (validity_mask_a_cols_b_rows[3]==1'b0 && b_mem_access_counter==3)) ?
        1'b0 : (b_mem_access_counter >= `MEM_ACCESS_LATENCY);

//////////////////////////////////////////////////////////////////////////
// Logic to delay certain parts of the data received from BRAM B (systolic data setup)
//////////////////////////////////////////////////////////////////////////
//Slice data into chunks and qualify it with whether it is valid or not
assign b0_data = b_data[`DWIDTH-1:0] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[0]}};
assign b1_data = b_data[2*`DWIDTH-1:`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[1]}};
assign b2_data = b_data[3*`DWIDTH-1:2*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[2]}};
assign b3_data = b_data[4*`DWIDTH-1:3*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[3]}};

//For larger matmuls, more such delaying flops will be needed
reg [`DWIDTH-1:0] b1_data_delayed_1;
reg [`DWIDTH-1:0] b2_data_delayed_1;
reg [`DWIDTH-1:0] b2_data_delayed_2;
reg [`DWIDTH-1:0] b3_data_delayed_1;
reg [`DWIDTH-1:0] b3_data_delayed_2;
reg [`DWIDTH-1:0] b3_data_delayed_3;
always @(posedge clk) begin
  if (reset || ~start_mat_mul || clk_cnt==0) begin
    b1_data_delayed_1 <= 0;
    b2_data_delayed_1 <= 0;
    b2_data_delayed_2 <= 0;
    b3_data_delayed_1 <= 0;
    b3_data_delayed_2 <= 0;
    b3_data_delayed_3 <= 0;
  end
  else begin
    b1_data_delayed_1 <= b1_data;
    b2_data_delayed_1 <= b2_data;
    b2_data_delayed_2 <= b2_data_delayed_1;
    b3_data_delayed_1 <= b3_data;
    b3_data_delayed_2 <= b3_data_delayed_1;
    b3_data_delayed_3 <= b3_data_delayed_2;
  end
end


endmodule

//////////////////////////////////////////////////////////////////////////
// Accumulators
//////////////////////////////////////////////////////////////////////////
module accumulators(
reset,
clk,
save_output_to_accum,
add_accum_to_output,
reset_accum,
row_latch_en,
r,
s,
c,
matrixC00,
matrixC01,
matrixC02,
matrixC03,
matrixC10,
matrixC11,
matrixC12,
matrixC13,
matrixC20,
matrixC21,
matrixC22,
matrixC23,
matrixC30,
matrixC31,
matrixC32,
matrixC33,
matrixC00_added,
matrixC01_added,
matrixC02_added,
matrixC03_added,
matrixC10_added,
matrixC11_added,
matrixC12_added,
matrixC13_added,
matrixC20_added,
matrixC21_added,
matrixC22_added,
matrixC23_added,
matrixC30_added,
matrixC31_added,
matrixC32_added,
matrixC33_added
);

input clk;
input reset;
input save_output_to_accum;
input add_accum_to_output;
input reset_accum;
input row_latch_en;

input [3:0] r; //iterator for filter height
input [3:0] s; //iterator for filter width
input [15:0] c; //iterator for input channels

input [`DWIDTH-1:0] matrixC00;
input [`DWIDTH-1:0] matrixC01;
input [`DWIDTH-1:0] matrixC02;
input [`DWIDTH-1:0] matrixC03;
input [`DWIDTH-1:0] matrixC10;
input [`DWIDTH-1:0] matrixC11;
input [`DWIDTH-1:0] matrixC12;
input [`DWIDTH-1:0] matrixC13;
input [`DWIDTH-1:0] matrixC20;
input [`DWIDTH-1:0] matrixC21;
input [`DWIDTH-1:0] matrixC22;
input [`DWIDTH-1:0] matrixC23;
input [`DWIDTH-1:0] matrixC30;
input [`DWIDTH-1:0] matrixC31;
input [`DWIDTH-1:0] matrixC32;
input [`DWIDTH-1:0] matrixC33;

output [`DWIDTH-1:0] matrixC00_added;
output [`DWIDTH-1:0] matrixC01_added;
output [`DWIDTH-1:0] matrixC02_added;
output [`DWIDTH-1:0] matrixC03_added;
output [`DWIDTH-1:0] matrixC10_added;
output [`DWIDTH-1:0] matrixC11_added;
output [`DWIDTH-1:0] matrixC12_added;
output [`DWIDTH-1:0] matrixC13_added;
output [`DWIDTH-1:0] matrixC20_added;
output [`DWIDTH-1:0] matrixC21_added;
output [`DWIDTH-1:0] matrixC22_added;
output [`DWIDTH-1:0] matrixC23_added;
output [`DWIDTH-1:0] matrixC30_added;
output [`DWIDTH-1:0] matrixC31_added;
output [`DWIDTH-1:0] matrixC32_added;
output [`DWIDTH-1:0] matrixC33_added;

reg [`DWIDTH-1:0] matrixC00_accum;
reg [`DWIDTH-1:0] matrixC01_accum;
reg [`DWIDTH-1:0] matrixC02_accum;
reg [`DWIDTH-1:0] matrixC03_accum;
reg [`DWIDTH-1:0] matrixC10_accum;
reg [`DWIDTH-1:0] matrixC11_accum;
reg [`DWIDTH-1:0] matrixC12_accum;
reg [`DWIDTH-1:0] matrixC13_accum;
reg [`DWIDTH-1:0] matrixC20_accum;
reg [`DWIDTH-1:0] matrixC21_accum;
reg [`DWIDTH-1:0] matrixC22_accum;
reg [`DWIDTH-1:0] matrixC23_accum;
reg [`DWIDTH-1:0] matrixC30_accum;
reg [`DWIDTH-1:0] matrixC31_accum;
reg [`DWIDTH-1:0] matrixC32_accum;
reg [`DWIDTH-1:0] matrixC33_accum;

reg outputs_saved_to_accum;
reg outputs_added_to_accum;
wire reset_accum;
reg [15:0] cur_c_saved;
reg [3:0] cur_r_saved;
reg [3:0] cur_s_saved;

always @(posedge clk) begin
  if (reset || ~(save_output_to_accum || add_accum_to_output) || (reset_accum)) begin
    matrixC00_accum <= 0;
    matrixC01_accum <= 0;
    matrixC02_accum <= 0;
    matrixC03_accum <= 0;
    matrixC10_accum <= 0;
    matrixC11_accum <= 0;
    matrixC12_accum <= 0;
    matrixC13_accum <= 0;
    matrixC20_accum <= 0;
    matrixC21_accum <= 0;
    matrixC22_accum <= 0;
    matrixC23_accum <= 0;
    matrixC30_accum <= 0;
    matrixC31_accum <= 0;
    matrixC32_accum <= 0;
    matrixC33_accum <= 0;
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
    matrixC10_accum <= matrixC10_added;
    matrixC11_accum <= matrixC11_added;
    matrixC12_accum <= matrixC12_added;
    matrixC13_accum <= matrixC13_added;
    matrixC20_accum <= matrixC20_added;
    matrixC21_accum <= matrixC21_added;
    matrixC22_accum <= matrixC22_added;
    matrixC23_accum <= matrixC23_added;
    matrixC30_accum <= matrixC30_added;
    matrixC31_accum <= matrixC31_added;
    matrixC32_accum <= matrixC32_added;
    matrixC33_accum <= matrixC33_added;
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
    matrixC10_accum <= matrixC10;
    matrixC11_accum <= matrixC11;
    matrixC12_accum <= matrixC12;
    matrixC13_accum <= matrixC13;
    matrixC20_accum <= matrixC20;
    matrixC21_accum <= matrixC21;
    matrixC22_accum <= matrixC22;
    matrixC23_accum <= matrixC23;
    matrixC30_accum <= matrixC30;
    matrixC31_accum <= matrixC31;
    matrixC32_accum <= matrixC32;
    matrixC33_accum <= matrixC33;
    outputs_saved_to_accum <= 1;
    cur_c_saved <= c;
    cur_r_saved <= r;
    cur_s_saved <= s;
  end
  else if (row_latch_en && add_accum_to_output) begin
    outputs_added_to_accum <= 1;
  end
end

assign matrixC00_added = (add_accum_to_output) ? (matrixC00 + matrixC00_accum) : matrixC00 ; 
assign matrixC01_added = (add_accum_to_output) ? (matrixC01 + matrixC01_accum) : matrixC01 ; 
assign matrixC02_added = (add_accum_to_output) ? (matrixC02 + matrixC02_accum) : matrixC02 ; 
assign matrixC03_added = (add_accum_to_output) ? (matrixC03 + matrixC03_accum) : matrixC03 ; 
assign matrixC10_added = (add_accum_to_output) ? (matrixC10 + matrixC10_accum) : matrixC10 ; 
assign matrixC11_added = (add_accum_to_output) ? (matrixC11 + matrixC11_accum) : matrixC11 ; 
assign matrixC12_added = (add_accum_to_output) ? (matrixC12 + matrixC12_accum) : matrixC12 ; 
assign matrixC13_added = (add_accum_to_output) ? (matrixC13 + matrixC13_accum) : matrixC13 ; 
assign matrixC20_added = (add_accum_to_output) ? (matrixC20 + matrixC20_accum) : matrixC20 ; 
assign matrixC21_added = (add_accum_to_output) ? (matrixC21 + matrixC21_accum) : matrixC21 ; 
assign matrixC22_added = (add_accum_to_output) ? (matrixC22 + matrixC22_accum) : matrixC22 ; 
assign matrixC23_added = (add_accum_to_output) ? (matrixC23 + matrixC23_accum) : matrixC23 ; 
assign matrixC30_added = (add_accum_to_output) ? (matrixC30 + matrixC30_accum) : matrixC30 ; 
assign matrixC31_added = (add_accum_to_output) ? (matrixC31 + matrixC31_accum) : matrixC31 ; 
assign matrixC32_added = (add_accum_to_output) ? (matrixC32 + matrixC32_accum) : matrixC32 ; 
assign matrixC33_added = (add_accum_to_output) ? (matrixC33 + matrixC33_accum) : matrixC33 ; 

endmodule


//////////////////////////////////////////////////////////////////////////
// Systolically connected PEs
//////////////////////////////////////////////////////////////////////////
module systolic_pe_matrix(
reset,
clk,
start_mat_mul,
a0, a1, a2, a3,
b0, b1, b2, b3,
matrixC00,
matrixC01,
matrixC02,
matrixC03,
matrixC10,
matrixC11,
matrixC12,
matrixC13,
matrixC20,
matrixC21,
matrixC22,
matrixC23,
matrixC30,
matrixC31,
matrixC32,
matrixC33,
a_data_out,
b_data_out
);

input clk;
input reset;
input start_mat_mul;
input [`DWIDTH-1:0] a0;
input [`DWIDTH-1:0] a1;
input [`DWIDTH-1:0] a2;
input [`DWIDTH-1:0] a3;
input [`DWIDTH-1:0] b0;
input [`DWIDTH-1:0] b1;
input [`DWIDTH-1:0] b2;
input [`DWIDTH-1:0] b3;
output [`DWIDTH-1:0] matrixC00;
output [`DWIDTH-1:0] matrixC01;
output [`DWIDTH-1:0] matrixC02;
output [`DWIDTH-1:0] matrixC03;
output [`DWIDTH-1:0] matrixC10;
output [`DWIDTH-1:0] matrixC11;
output [`DWIDTH-1:0] matrixC12;
output [`DWIDTH-1:0] matrixC13;
output [`DWIDTH-1:0] matrixC20;
output [`DWIDTH-1:0] matrixC21;
output [`DWIDTH-1:0] matrixC22;
output [`DWIDTH-1:0] matrixC23;
output [`DWIDTH-1:0] matrixC30;
output [`DWIDTH-1:0] matrixC31;
output [`DWIDTH-1:0] matrixC32;
output [`DWIDTH-1:0] matrixC33;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out;

wire [`DWIDTH-1:0] a00to01, a01to02, a02to03, a03to04;
wire [`DWIDTH-1:0] a10to11, a11to12, a12to13, a13to14;
wire [`DWIDTH-1:0] a20to21, a21to22, a22to23, a23to24;
wire [`DWIDTH-1:0] a30to31, a31to32, a32to33, a33to34;

wire [`DWIDTH-1:0] b00to10, b10to20, b20to30, b30to40; 
wire [`DWIDTH-1:0] b01to11, b11to21, b21to31, b31to41;
wire [`DWIDTH-1:0] b02to12, b12to22, b22to32, b32to42;
wire [`DWIDTH-1:0] b03to13, b13to23, b23to33, b33to43;

//For larger matmul, more PEs will be needed
wire effective_rst;
assign effective_rst = reset | ~start_mat_mul;

processing_element pe00(.reset(effective_rst), .clk(clk),  .in_a(a0),      .in_b(b0),  .out_a(a00to01), .out_b(b00to10), .out_c(matrixC00));
processing_element pe01(.reset(effective_rst), .clk(clk),  .in_a(a00to01), .in_b(b1),  .out_a(a01to02), .out_b(b01to11), .out_c(matrixC01));
processing_element pe02(.reset(effective_rst), .clk(clk),  .in_a(a01to02), .in_b(b2),  .out_a(a02to03), .out_b(b02to12), .out_c(matrixC02));
processing_element pe03(.reset(effective_rst), .clk(clk),  .in_a(a02to03), .in_b(b3),  .out_a(a03to04), .out_b(b03to13), .out_c(matrixC03));

processing_element pe10(.reset(effective_rst), .clk(clk),  .in_a(a1),      .in_b(b00to10), .out_a(a10to11), .out_b(b10to20), .out_c(matrixC10));
processing_element pe11(.reset(effective_rst), .clk(clk),  .in_a(a10to11), .in_b(b01to11), .out_a(a11to12), .out_b(b11to21), .out_c(matrixC11));
processing_element pe12(.reset(effective_rst), .clk(clk),  .in_a(a11to12), .in_b(b02to12), .out_a(a12to13), .out_b(b12to22), .out_c(matrixC12));
processing_element pe13(.reset(effective_rst), .clk(clk),  .in_a(a12to13), .in_b(b03to13), .out_a(a13to14), .out_b(b13to23), .out_c(matrixC13));

processing_element pe20(.reset(effective_rst), .clk(clk),  .in_a(a2),      .in_b(b10to20), .out_a(a20to21), .out_b(b20to30), .out_c(matrixC20));
processing_element pe21(.reset(effective_rst), .clk(clk),  .in_a(a20to21), .in_b(b11to21), .out_a(a21to22), .out_b(b21to31), .out_c(matrixC21));
processing_element pe22(.reset(effective_rst), .clk(clk),  .in_a(a21to22), .in_b(b12to22), .out_a(a22to23), .out_b(b22to32), .out_c(matrixC22));
processing_element pe23(.reset(effective_rst), .clk(clk),  .in_a(a22to23), .in_b(b13to23), .out_a(a23to24), .out_b(b23to33), .out_c(matrixC23));

processing_element pe30(.reset(effective_rst), .clk(clk),  .in_a(a3),      .in_b(b20to30), .out_a(a30to31), .out_b(b30to40), .out_c(matrixC30));
processing_element pe31(.reset(effective_rst), .clk(clk),  .in_a(a30to31), .in_b(b21to31), .out_a(a31to32), .out_b(b31to41), .out_c(matrixC31));
processing_element pe32(.reset(effective_rst), .clk(clk),  .in_a(a31to32), .in_b(b22to32), .out_a(a32to33), .out_b(b32to42), .out_c(matrixC32));
processing_element pe33(.reset(effective_rst), .clk(clk),  .in_a(a32to33), .in_b(b23to33), .out_a(a33to34), .out_b(b33to43), .out_c(matrixC33));

assign a_data_out = {a33to34,a23to24,a13to14,a03to04};
assign b_data_out = {b33to43,b32to42,b31to41,b30to40};

endmodule


//////////////////////////////////////////////////////////////////////////
// Processing element (PE)
//////////////////////////////////////////////////////////////////////////
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

//////////////////////////////////////////////////////////////////////////
// Multiply-and-accumulate (MAC) block
//////////////////////////////////////////////////////////////////////////
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
module qadd(a,b,c);
input [`DWIDTH-1:0] a;
input [`DWIDTH-1:0] b;
output [`DWIDTH-1:0] c;

assign c = a + b;
//DW01_add #(`DWIDTH) u_add(.A(a), .B(b), .CI(1'b0), .SUM(c), .CO());
endmodule
