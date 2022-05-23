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
wire start_pool;

`ifdef DESIGN_SIZE_32
wire [`DWIDTH-1:0] matrixC310;
wire [`DWIDTH-1:0] matrixC311;
wire [`DWIDTH-1:0] matrixC312;
wire [`DWIDTH-1:0] matrixC313;
wire [`DWIDTH-1:0] matrixC314;
wire [`DWIDTH-1:0] matrixC315;
wire [`DWIDTH-1:0] matrixC316;
wire [`DWIDTH-1:0] matrixC317;
wire [`DWIDTH-1:0] matrixC318;
wire [`DWIDTH-1:0] matrixC319;
wire [`DWIDTH-1:0] matrixC3110;
wire [`DWIDTH-1:0] matrixC3111;
wire [`DWIDTH-1:0] matrixC3112;
wire [`DWIDTH-1:0] matrixC3113;
wire [`DWIDTH-1:0] matrixC3114;
wire [`DWIDTH-1:0] matrixC3115;
wire [`DWIDTH-1:0] matrixC3116;
wire [`DWIDTH-1:0] matrixC3117;
wire [`DWIDTH-1:0] matrixC3118;
wire [`DWIDTH-1:0] matrixC3119;
wire [`DWIDTH-1:0] matrixC3120;
wire [`DWIDTH-1:0] matrixC3121;
wire [`DWIDTH-1:0] matrixC3122;
wire [`DWIDTH-1:0] matrixC3123;
wire [`DWIDTH-1:0] matrixC3124;
wire [`DWIDTH-1:0] matrixC3125;
wire [`DWIDTH-1:0] matrixC3126;
wire [`DWIDTH-1:0] matrixC3127;
wire [`DWIDTH-1:0] matrixC3128;
wire [`DWIDTH-1:0] matrixC3129;
wire [`DWIDTH-1:0] matrixC3130;
wire [`DWIDTH-1:0] matrixC3131;
`endif
`ifdef DESIGN_SIZE_16
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
`endif
`ifdef DESIGN_SIZE_8
wire [`DWIDTH-1:0] matrixC70;
wire [`DWIDTH-1:0] matrixC71;
wire [`DWIDTH-1:0] matrixC72;
wire [`DWIDTH-1:0] matrixC73;
wire [`DWIDTH-1:0] matrixC74;
wire [`DWIDTH-1:0] matrixC75;
wire [`DWIDTH-1:0] matrixC76;
wire [`DWIDTH-1:0] matrixC77;
`endif
`ifdef DESIGN_SIZE_4
wire [`DWIDTH-1:0] matrixC30;
wire [`DWIDTH-1:0] matrixC31;
wire [`DWIDTH-1:0] matrixC32;
wire [`DWIDTH-1:0] matrixC33;
`endif

`ifdef DESIGN_SIZE_8
wire [`AWIDTH-1:0] start_waddr_accum0;
wire [`AWIDTH-1:0] start_waddr_accum1;
wire [`AWIDTH-1:0] start_waddr_accum2;
wire [`AWIDTH-1:0] start_waddr_accum3;
wire [`AWIDTH-1:0] start_waddr_accum4;
wire [`AWIDTH-1:0] start_waddr_accum5;
wire [`AWIDTH-1:0] start_waddr_accum6;
wire [`AWIDTH-1:0] start_waddr_accum7;

assign start_waddr_accum0 = 11'b0;
assign start_waddr_accum1 = 11'b0;
assign start_waddr_accum2 = 11'b0;
assign start_waddr_accum3 = 11'b0;
assign start_waddr_accum4 = 11'b0;
assign start_waddr_accum5 = 11'b0;
assign start_waddr_accum6 = 11'b0;
assign start_waddr_accum7 = 11'b0;

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
  `ifdef DESIGN_SIZE_32
  .matrixC310(matrixC310),
  .matrixC311(matrixC311),
  .matrixC312(matrixC312),
  .matrixC313(matrixC313),
  .matrixC314(matrixC314),
  .matrixC315(matrixC315),
  .matrixC316(matrixC316),
  .matrixC317(matrixC317),
  .matrixC318(matrixC318),
  .matrixC319(matrixC319),
  .matrixC3110(matrixC3110),
  .matrixC3111(matrixC3111),
  .matrixC3112(matrixC3112),
  .matrixC3113(matrixC3113),
  .matrixC3114(matrixC3114),
  .matrixC3115(matrixC3115),
  .matrixC3116(matrixC3116),
  .matrixC3117(matrixC3117),
  .matrixC3118(matrixC3118),
  .matrixC3119(matrixC3119),
  .matrixC3120(matrixC3120),
  .matrixC3121(matrixC3121),
  .matrixC3122(matrixC3122),
  .matrixC3123(matrixC3123),
  .matrixC3124(matrixC3124),
  .matrixC3125(matrixC3125),
  .matrixC3126(matrixC3126),
  .matrixC3127(matrixC3127),
  .matrixC3128(matrixC3128),
  .matrixC3129(matrixC3129),
  .matrixC3130(matrixC3130),
  .matrixC3131(matrixC3131),
  `endif
  `ifdef DESIGN_SIZE_16
  .matrixC150(matrixC150),
  .matrixC151(matrixC151),
  .matrixC152(matrixC152),
  .matrixC153(matrixC153),
  .matrixC154(matrixC154),
  .matrixC155(matrixC155),
  .matrixC156(matrixC156),
  .matrixC157(matrixC157),
  .matrixC158(matrixC158),
  .matrixC159(matrixC159),
  .matrixC1510(matrixC1510),
  .matrixC1511(matrixC1511),
  .matrixC1512(matrixC1512),
  .matrixC1513(matrixC1513),
  .matrixC1514(matrixC1514),
  .matrixC1515(matrixC1515),
  `endif
  `ifdef DESIGN_SIZE_8
  .matrixC70(matrixC70),
  .matrixC71(matrixC71),
  .matrixC72(matrixC72),
  .matrixC73(matrixC73),
  .matrixC74(matrixC74),
  .matrixC75(matrixC75),
  .matrixC76(matrixC76),
  .matrixC77(matrixC77),
  `endif
  `ifdef DESIGN_SIZE_4
  .matrixC30(matrixC30),
  .matrixC31(matrixC31),
  .matrixC32(matrixC32),
  .matrixC33(matrixC33),
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
  .wdata_available(matmul_c_data_available),
  `ifdef DESIGN_SIZE_8
  .start_waddr_accum0(start_waddr_accum0),
  .start_waddr_accum1(start_waddr_accum1),
  .start_waddr_accum2(start_waddr_accum2),
  .start_waddr_accum3(start_waddr_accum3),
  .start_waddr_accum4(start_waddr_accum4),
  .start_waddr_accum5(start_waddr_accum5),
  .start_waddr_accum6(start_waddr_accum6),
  .start_waddr_accum7(start_waddr_accum7),
  .wdata_accum0(matrixC70),
  .wdata_accum1(matrixC71),
  .wdata_accum2(matrixC72),
  .wdata_accum3(matrixC73),
  .wdata_accum4(matrixC74),
  .wdata_accum5(matrixC75),
  .wdata_accum6(matrixC76),
  .wdata_accum7(matrixC77),
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
);

////////////////////////////////////////////////////////////////
// Pooling module
////////////////////////////////////////////////////////////////
pooling u_pooling (
  .clk(clk),
  .resetn(resetn),
  .matrix_size(matrix_size),
  .filter_size(filter_size),
  .pool_select(pool_select),
  .start_pooling(start_pool),
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
  .rdata_accum7_pool(rdata_accum7_pool)
  `endif
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
  // else if (activation_out_data_available) begin
  else if (0) begin
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
