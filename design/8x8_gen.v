
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020-05-31 11:16:03.445001
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
    a_mem_access_counter = a_mem_access_counter + 1;  
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
    b_mem_access_counter = b_mem_access_counter + 1;  
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
