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
wire [`DESIGN_SIZE*`DWIDTH-1:0] matmul_c_data_out;
wire [`DESIGN_SIZE*`DWIDTH-1:0] norm_data_out;
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
  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd`DESIGN_SIZE),
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
      bram_addr_a_for_writing <= address_mat_c + address_stride_c;
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
      bram_addr_a_for_writing <= bram_addr_a_for_writing - address_stride_c;
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
      bram_addr_a_for_writing <= address_mat_c + address_stride_c;
      bram_a_wdata_available <= 0;
    end
  end
end  

endmodule
