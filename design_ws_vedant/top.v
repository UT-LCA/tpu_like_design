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
wire pool_norm_valid;

`ifdef DESIGN_SIZE_32
wire [`DWIDTH-1:0] matrixC31_0;
wire [`DWIDTH-1:0] matrixC31_1;
wire [`DWIDTH-1:0] matrixC31_2;
wire [`DWIDTH-1:0] matrixC31_3;
wire [`DWIDTH-1:0] matrixC31_4;
wire [`DWIDTH-1:0] matrixC31_5;
wire [`DWIDTH-1:0] matrixC31_6;
wire [`DWIDTH-1:0] matrixC31_7;
wire [`DWIDTH-1:0] matrixC31_8;
wire [`DWIDTH-1:0] matrixC31_9;
wire [`DWIDTH-1:0] matrixC31_10;
wire [`DWIDTH-1:0] matrixC31_11;
wire [`DWIDTH-1:0] matrixC31_12;
wire [`DWIDTH-1:0] matrixC31_13;
wire [`DWIDTH-1:0] matrixC31_14;
wire [`DWIDTH-1:0] matrixC31_15;
wire [`DWIDTH-1:0] matrixC31_16;
wire [`DWIDTH-1:0] matrixC31_17;
wire [`DWIDTH-1:0] matrixC31_18;
wire [`DWIDTH-1:0] matrixC31_19;
wire [`DWIDTH-1:0] matrixC31_20;
wire [`DWIDTH-1:0] matrixC31_21;
wire [`DWIDTH-1:0] matrixC31_22;
wire [`DWIDTH-1:0] matrixC31_23;
wire [`DWIDTH-1:0] matrixC31_24;
wire [`DWIDTH-1:0] matrixC31_25;
wire [`DWIDTH-1:0] matrixC31_26;
wire [`DWIDTH-1:0] matrixC31_27;
wire [`DWIDTH-1:0] matrixC31_28;
wire [`DWIDTH-1:0] matrixC31_29;
wire [`DWIDTH-1:0] matrixC31_30;
wire [`DWIDTH-1:0] matrixC31_31;
`endif
`ifdef DESIGN_SIZE_16
wire [`DWIDTH-1:0] matrixC15_0;
wire [`DWIDTH-1:0] matrixC15_1;
wire [`DWIDTH-1:0] matrixC15_2;
wire [`DWIDTH-1:0] matrixC15_3;
wire [`DWIDTH-1:0] matrixC15_4;
wire [`DWIDTH-1:0] matrixC15_5;
wire [`DWIDTH-1:0] matrixC15_6;
wire [`DWIDTH-1:0] matrixC15_7;
wire [`DWIDTH-1:0] matrixC15_8;
wire [`DWIDTH-1:0] matrixC15_9;
wire [`DWIDTH-1:0] matrixC15_10;
wire [`DWIDTH-1:0] matrixC15_11;
wire [`DWIDTH-1:0] matrixC15_12;
wire [`DWIDTH-1:0] matrixC15_13;
wire [`DWIDTH-1:0] matrixC15_14;
wire [`DWIDTH-1:0] matrixC15_15;
`endif
`ifdef DESIGN_SIZE_8
wire [`DWIDTH-1:0] matrixC7_0;
wire [`DWIDTH-1:0] matrixC7_1;
wire [`DWIDTH-1:0] matrixC7_2;
wire [`DWIDTH-1:0] matrixC7_3;
wire [`DWIDTH-1:0] matrixC7_4;
wire [`DWIDTH-1:0] matrixC7_5;
wire [`DWIDTH-1:0] matrixC7_6;
wire [`DWIDTH-1:0] matrixC7_7;
`endif
`ifdef DESIGN_SIZE_4
wire [`DWIDTH-1:0] matrixC3_0;
wire [`DWIDTH-1:0] matrixC3_1;
wire [`DWIDTH-1:0] matrixC3_2;
wire [`DWIDTH-1:0] matrixC3_3;
`endif

wire [`AWIDTH-1:0] start_waddr_accum0;

assign start_waddr_accum0 = 11'b0;

`ifdef DESIGN_SIZE_8
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

`ifdef DESIGN_SIZE_16
wire [`DWIDTH-1:0] rdata_accum0_pool;
wire [`DWIDTH-1:0] rdata_accum1_pool;
wire [`DWIDTH-1:0] rdata_accum2_pool;
wire [`DWIDTH-1:0] rdata_accum3_pool;
wire [`DWIDTH-1:0] rdata_accum4_pool;
wire [`DWIDTH-1:0] rdata_accum5_pool;
wire [`DWIDTH-1:0] rdata_accum6_pool;
wire [`DWIDTH-1:0] rdata_accum7_pool;
wire [`DWIDTH-1:0] rdata_accum8_pool;
wire [`DWIDTH-1:0] rdata_accum9_pool;
wire [`DWIDTH-1:0] rdata_accum10_pool;
wire [`DWIDTH-1:0] rdata_accum11_pool;
wire [`DWIDTH-1:0] rdata_accum12_pool;
wire [`DWIDTH-1:0] rdata_accum13_pool;
wire [`DWIDTH-1:0] rdata_accum14_pool;
wire [`DWIDTH-1:0] rdata_accum15_pool;
wire [`AWIDTH-1:0] raddr_accum0_pool;
wire [`AWIDTH-1:0] raddr_accum1_pool;
wire [`AWIDTH-1:0] raddr_accum2_pool;
wire [`AWIDTH-1:0] raddr_accum3_pool;
wire [`AWIDTH-1:0] raddr_accum4_pool;
wire [`AWIDTH-1:0] raddr_accum5_pool;
wire [`AWIDTH-1:0] raddr_accum6_pool;
wire [`AWIDTH-1:0] raddr_accum7_pool;
wire [`AWIDTH-1:0] raddr_accum8_pool;
wire [`AWIDTH-1:0] raddr_accum9_pool;
wire [`AWIDTH-1:0] raddr_accum10_pool;
wire [`AWIDTH-1:0] raddr_accum11_pool;
wire [`AWIDTH-1:0] raddr_accum12_pool;
wire [`AWIDTH-1:0] raddr_accum13_pool;
wire [`AWIDTH-1:0] raddr_accum14_pool;
wire [`AWIDTH-1:0] raddr_accum15_pool;
`endif

`ifdef DESIGN_SIZE_32
wire [`DWIDTH-1:0] rdata_accum0_pool;
wire [`DWIDTH-1:0] rdata_accum1_pool;
wire [`DWIDTH-1:0] rdata_accum2_pool;
wire [`DWIDTH-1:0] rdata_accum3_pool;
wire [`DWIDTH-1:0] rdata_accum4_pool;
wire [`DWIDTH-1:0] rdata_accum5_pool;
wire [`DWIDTH-1:0] rdata_accum6_pool;
wire [`DWIDTH-1:0] rdata_accum7_pool;
wire [`DWIDTH-1:0] rdata_accum8_pool;
wire [`DWIDTH-1:0] rdata_accum9_pool;
wire [`DWIDTH-1:0] rdata_accum10_pool;
wire [`DWIDTH-1:0] rdata_accum11_pool;
wire [`DWIDTH-1:0] rdata_accum12_pool;
wire [`DWIDTH-1:0] rdata_accum13_pool;
wire [`DWIDTH-1:0] rdata_accum14_pool;
wire [`DWIDTH-1:0] rdata_accum15_pool;
wire [`DWIDTH-1:0] rdata_accum16_pool;
wire [`DWIDTH-1:0] rdata_accum17_pool;
wire [`DWIDTH-1:0] rdata_accum18_pool;
wire [`DWIDTH-1:0] rdata_accum19_pool;
wire [`DWIDTH-1:0] rdata_accum20_pool;
wire [`DWIDTH-1:0] rdata_accum21_pool;
wire [`DWIDTH-1:0] rdata_accum22_pool;
wire [`DWIDTH-1:0] rdata_accum23_pool;
wire [`DWIDTH-1:0] rdata_accum24_pool;
wire [`DWIDTH-1:0] rdata_accum25_pool;
wire [`DWIDTH-1:0] rdata_accum26_pool;
wire [`DWIDTH-1:0] rdata_accum27_pool;
wire [`DWIDTH-1:0] rdata_accum28_pool;
wire [`DWIDTH-1:0] rdata_accum29_pool;
wire [`DWIDTH-1:0] rdata_accum30_pool;
wire [`DWIDTH-1:0] rdata_accum31_pool;
wire [`AWIDTH-1:0] raddr_accum0_pool;
wire [`AWIDTH-1:0] raddr_accum1_pool;
wire [`AWIDTH-1:0] raddr_accum2_pool;
wire [`AWIDTH-1:0] raddr_accum3_pool;
wire [`AWIDTH-1:0] raddr_accum4_pool;
wire [`AWIDTH-1:0] raddr_accum5_pool;
wire [`AWIDTH-1:0] raddr_accum6_pool;
wire [`AWIDTH-1:0] raddr_accum7_pool;
wire [`AWIDTH-1:0] raddr_accum8_pool;
wire [`AWIDTH-1:0] raddr_accum9_pool;
wire [`AWIDTH-1:0] raddr_accum10_pool;
wire [`AWIDTH-1:0] raddr_accum11_pool;
wire [`AWIDTH-1:0] raddr_accum12_pool;
wire [`AWIDTH-1:0] raddr_accum13_pool;
wire [`AWIDTH-1:0] raddr_accum14_pool;
wire [`AWIDTH-1:0] raddr_accum15_pool;
wire [`AWIDTH-1:0] raddr_accum16_pool;
wire [`AWIDTH-1:0] raddr_accum17_pool;
wire [`AWIDTH-1:0] raddr_accum18_pool;
wire [`AWIDTH-1:0] raddr_accum19_pool;
wire [`AWIDTH-1:0] raddr_accum20_pool;
wire [`AWIDTH-1:0] raddr_accum21_pool;
wire [`AWIDTH-1:0] raddr_accum22_pool;
wire [`AWIDTH-1:0] raddr_accum23_pool;
wire [`AWIDTH-1:0] raddr_accum24_pool;
wire [`AWIDTH-1:0] raddr_accum25_pool;
wire [`AWIDTH-1:0] raddr_accum26_pool;
wire [`AWIDTH-1:0] raddr_accum27_pool;
wire [`AWIDTH-1:0] raddr_accum28_pool;
wire [`AWIDTH-1:0] raddr_accum29_pool;
wire [`AWIDTH-1:0] raddr_accum30_pool;
wire [`AWIDTH-1:0] raddr_accum31_pool;
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
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
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
  .matrixC31_0(matrixC31_0),
  .matrixC31_1(matrixC31_1),
  .matrixC31_2(matrixC31_2),
  .matrixC31_3(matrixC31_3),
  .matrixC31_4(matrixC31_4),
  .matrixC31_5(matrixC31_5),
  .matrixC31_6(matrixC31_6),
  .matrixC31_7(matrixC31_7),
  .matrixC31_8(matrixC31_8),
  .matrixC31_9(matrixC31_9),
  .matrixC31_10(matrixC31_10),
  .matrixC31_11(matrixC31_11),
  .matrixC31_12(matrixC31_12),
  .matrixC31_13(matrixC31_13),
  .matrixC31_14(matrixC31_14),
  .matrixC31_15(matrixC31_15),
  .matrixC31_16(matrixC31_16),
  .matrixC31_17(matrixC31_17),
  .matrixC31_18(matrixC31_18),
  .matrixC31_19(matrixC31_19),
  .matrixC31_20(matrixC31_20),
  .matrixC31_21(matrixC31_21),
  .matrixC31_22(matrixC31_22),
  .matrixC31_23(matrixC31_23),
  .matrixC31_24(matrixC31_24),
  .matrixC31_25(matrixC31_25),
  .matrixC31_26(matrixC31_26),
  .matrixC31_27(matrixC31_27),
  .matrixC31_28(matrixC31_28),
  .matrixC31_29(matrixC31_29),
  .matrixC31_30(matrixC31_30),
  .matrixC31_31(matrixC31_31),
  `endif
  `ifdef DESIGN_SIZE_16
  .matrixC15_0(matrixC15_0),
  .matrixC15_1(matrixC15_1),
  .matrixC15_2(matrixC15_2),
  .matrixC15_3(matrixC15_3),
  .matrixC15_4(matrixC15_4),
  .matrixC15_5(matrixC15_5),
  .matrixC15_6(matrixC15_6),
  .matrixC15_7(matrixC15_7),
  .matrixC15_8(matrixC15_8),
  .matrixC15_9(matrixC15_9),
  .matrixC15_10(matrixC15_10),
  .matrixC15_11(matrixC15_11),
  .matrixC15_12(matrixC15_12),
  .matrixC15_13(matrixC15_13),
  .matrixC15_14(matrixC15_14),
  .matrixC15_15(matrixC15_15),
  `endif
  `ifdef DESIGN_SIZE_8
  .matrixC7_0(matrixC7_0),
  .matrixC7_1(matrixC7_1),
  .matrixC7_2(matrixC7_2),
  .matrixC7_3(matrixC7_3),
  .matrixC7_4(matrixC7_4),
  .matrixC7_5(matrixC7_5),
  .matrixC7_6(matrixC7_6),
  .matrixC7_7(matrixC7_7),
  `endif
  `ifdef DESIGN_SIZE_4
  .matrixC3_0(matrixC3_0),
  .matrixC3_1(matrixC3_1),
  .matrixC3_2(matrixC3_2),
  .matrixC3_3(matrixC3_3),
  `endif
  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
//TODO: Need to change the width of this. 
//For 8x8 matmul, this is 16 bits
//For 16x16 matmul, this is 32 bits
//For 32x32 matmul, this is 64 bits
  .a_loc(16'd0),
  .b_loc(16'd0)
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
  .done_pooling(done_pool),
  .wdata_available(matmul_c_data_available),
  .start_waddr_accum0(start_waddr_accum0),
  `ifdef DESIGN_SIZE_8
  .wdata_accum0(matrixC7_0),
  .wdata_accum1(matrixC7_1),
  .wdata_accum2(matrixC7_2),
  .wdata_accum3(matrixC7_3),
  .wdata_accum4(matrixC7_4),
  .wdata_accum5(matrixC7_5),
  .wdata_accum6(matrixC7_6),
  .wdata_accum7(matrixC7_7),
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
  `ifdef DESIGN_SIZE_16
  .wdata_accum0(matrixC15_0),
  .wdata_accum1(matrixC15_1),
  .wdata_accum2(matrixC15_2),
  .wdata_accum3(matrixC15_3),
  .wdata_accum4(matrixC15_4),
  .wdata_accum5(matrixC15_5),
  .wdata_accum6(matrixC15_6),
  .wdata_accum7(matrixC15_7),
  .wdata_accum8(matrixC15_8),
  .wdata_accum9(matrixC15_9),
  .wdata_accum10(matrixC15_10),
  .wdata_accum11(matrixC15_11),
  .wdata_accum12(matrixC15_12),
  .wdata_accum13(matrixC15_13),
  .wdata_accum14(matrixC15_14),
  .wdata_accum15(matrixC15_15),
  .raddr_accum0_pool(raddr_accum0_pool),
  .raddr_accum1_pool(raddr_accum1_pool),
  .raddr_accum2_pool(raddr_accum2_pool),
  .raddr_accum3_pool(raddr_accum3_pool),
  .raddr_accum4_pool(raddr_accum4_pool),
  .raddr_accum5_pool(raddr_accum5_pool),
  .raddr_accum6_pool(raddr_accum6_pool),
  .raddr_accum7_pool(raddr_accum7_pool),
  .raddr_accum8_pool(raddr_accum8_pool),
  .raddr_accum9_pool(raddr_accum9_pool),
  .raddr_accum10_pool(raddr_accum10_pool),
  .raddr_accum11_pool(raddr_accum11_pool),
  .raddr_accum12_pool(raddr_accum12_pool),
  .raddr_accum13_pool(raddr_accum13_pool),
  .raddr_accum14_pool(raddr_accum14_pool),
  .raddr_accum15_pool(raddr_accum15_pool),
  .rdata_accum0_pool(rdata_accum0_pool),
  .rdata_accum1_pool(rdata_accum1_pool),
  .rdata_accum2_pool(rdata_accum2_pool),
  .rdata_accum3_pool(rdata_accum3_pool),
  .rdata_accum4_pool(rdata_accum4_pool),
  .rdata_accum5_pool(rdata_accum5_pool),
  .rdata_accum6_pool(rdata_accum6_pool),
  .rdata_accum7_pool(rdata_accum7_pool),
  .rdata_accum8_pool(rdata_accum8_pool),
  .rdata_accum9_pool(rdata_accum9_pool),
  .rdata_accum10_pool(rdata_accum10_pool),
  .rdata_accum11_pool(rdata_accum11_pool),
  .rdata_accum12_pool(rdata_accum12_pool),
  .rdata_accum13_pool(rdata_accum13_pool),
  .rdata_accum14_pool(rdata_accum14_pool),
  .rdata_accum15_pool(rdata_accum15_pool)
  `endif
  `ifdef DESIGN_SIZE_32
  .wdata_accum0(matrixC31_0),
  .wdata_accum1(matrixC31_1),
  .wdata_accum2(matrixC31_2),
  .wdata_accum3(matrixC31_3),
  .wdata_accum4(matrixC31_4),
  .wdata_accum5(matrixC31_5),
  .wdata_accum6(matrixC31_6),
  .wdata_accum7(matrixC31_7),
  .wdata_accum8(matrixC31_8),
  .wdata_accum9(matrixC31_9),
  .wdata_accum10(matrixC31_10),
  .wdata_accum11(matrixC31_11),
  .wdata_accum12(matrixC31_12),
  .wdata_accum13(matrixC31_13),
  .wdata_accum14(matrixC31_14),
  .wdata_accum15(matrixC31_15),
  .wdata_accum16(matrixC31_16),
  .wdata_accum17(matrixC31_17),
  .wdata_accum18(matrixC31_18),
  .wdata_accum19(matrixC31_19),
  .wdata_accum20(matrixC31_20),
  .wdata_accum21(matrixC31_21),
  .wdata_accum22(matrixC31_22),
  .wdata_accum23(matrixC31_23),
  .wdata_accum24(matrixC31_24),
  .wdata_accum25(matrixC31_25),
  .wdata_accum26(matrixC31_26),
  .wdata_accum27(matrixC31_27),
  .wdata_accum28(matrixC31_28),
  .wdata_accum29(matrixC31_29),
  .wdata_accum30(matrixC31_30),
  .wdata_accum31(matrixC31_31),
  .raddr_accum0_pool(raddr_accum0_pool),
  .raddr_accum1_pool(raddr_accum1_pool),
  .raddr_accum2_pool(raddr_accum2_pool),
  .raddr_accum3_pool(raddr_accum3_pool),
  .raddr_accum4_pool(raddr_accum4_pool),
  .raddr_accum5_pool(raddr_accum5_pool),
  .raddr_accum6_pool(raddr_accum6_pool),
  .raddr_accum7_pool(raddr_accum7_pool),
  .raddr_accum8_pool(raddr_accum8_pool),
  .raddr_accum9_pool(raddr_accum9_pool),
  .raddr_accum10_pool(raddr_accum10_pool),
  .raddr_accum11_pool(raddr_accum11_pool),
  .raddr_accum12_pool(raddr_accum12_pool),
  .raddr_accum13_pool(raddr_accum13_pool),
  .raddr_accum14_pool(raddr_accum14_pool),
  .raddr_accum15_pool(raddr_accum15_pool),
  .raddr_accum16_pool(raddr_accum16_pool),
  .raddr_accum17_pool(raddr_accum17_pool),
  .raddr_accum18_pool(raddr_accum18_pool),
  .raddr_accum19_pool(raddr_accum19_pool),
  .raddr_accum20_pool(raddr_accum20_pool),
  .raddr_accum21_pool(raddr_accum21_pool),
  .raddr_accum22_pool(raddr_accum22_pool),
  .raddr_accum23_pool(raddr_accum23_pool),
  .raddr_accum24_pool(raddr_accum24_pool),
  .raddr_accum25_pool(raddr_accum25_pool),
  .raddr_accum26_pool(raddr_accum26_pool),
  .raddr_accum27_pool(raddr_accum27_pool),
  .raddr_accum28_pool(raddr_accum28_pool),
  .raddr_accum29_pool(raddr_accum29_pool),
  .raddr_accum30_pool(raddr_accum30_pool),
  .raddr_accum31_pool(raddr_accum31_pool),
  .rdata_accum0_pool(rdata_accum0_pool),
  .rdata_accum1_pool(rdata_accum1_pool),
  .rdata_accum2_pool(rdata_accum2_pool),
  .rdata_accum3_pool(rdata_accum3_pool),
  .rdata_accum4_pool(rdata_accum4_pool),
  .rdata_accum5_pool(rdata_accum5_pool),
  .rdata_accum6_pool(rdata_accum6_pool),
  .rdata_accum7_pool(rdata_accum7_pool),
  .rdata_accum8_pool(rdata_accum8_pool),
  .rdata_accum9_pool(rdata_accum9_pool),
  .rdata_accum10_pool(rdata_accum10_pool),
  .rdata_accum11_pool(rdata_accum11_pool),
  .rdata_accum12_pool(rdata_accum12_pool),
  .rdata_accum13_pool(rdata_accum13_pool),
  .rdata_accum14_pool(rdata_accum14_pool),
  .rdata_accum15_pool(rdata_accum15_pool),
  .rdata_accum16_pool(rdata_accum16_pool),
  .rdata_accum17_pool(rdata_accum17_pool),
  .rdata_accum18_pool(rdata_accum18_pool),
  .rdata_accum19_pool(rdata_accum19_pool),
  .rdata_accum20_pool(rdata_accum20_pool),
  .rdata_accum21_pool(rdata_accum21_pool),
  .rdata_accum22_pool(rdata_accum22_pool),
  .rdata_accum23_pool(rdata_accum23_pool),
  .rdata_accum24_pool(rdata_accum24_pool),
  .rdata_accum25_pool(rdata_accum25_pool),
  .rdata_accum26_pool(rdata_accum26_pool),
  .rdata_accum27_pool(rdata_accum27_pool),
  .rdata_accum28_pool(rdata_accum28_pool),
  .rdata_accum29_pool(rdata_accum29_pool),
  .rdata_accum30_pool(rdata_accum30_pool),
  .rdata_accum31_pool(rdata_accum31_pool)
  `endif
);

wire [`DWIDTH-1:0] pool0;
wire [`DWIDTH-1:0] pool1;
wire [`DWIDTH-1:0] pool2;
wire [`DWIDTH-1:0] pool3;
wire [`DWIDTH-1:0] pool4;
wire [`DWIDTH-1:0] pool5;
wire [`DWIDTH-1:0] pool6;
wire [`DWIDTH-1:0] pool7;
wire [`DWIDTH-1:0] pool8;
wire [`DWIDTH-1:0] pool9;
wire [`DWIDTH-1:0] pool10;
wire [`DWIDTH-1:0] pool11;
wire [`DWIDTH-1:0] pool12;
wire [`DWIDTH-1:0] pool13;
wire [`DWIDTH-1:0] pool14;
wire [`DWIDTH-1:0] pool15;
wire [`DWIDTH-1:0] pool16;
wire [`DWIDTH-1:0] pool17;
wire [`DWIDTH-1:0] pool18;
wire [`DWIDTH-1:0] pool19;
wire [`DWIDTH-1:0] pool20;
wire [`DWIDTH-1:0] pool21;
wire [`DWIDTH-1:0] pool22;
wire [`DWIDTH-1:0] pool23;
wire [`DWIDTH-1:0] pool24;
wire [`DWIDTH-1:0] pool25;
wire [`DWIDTH-1:0] pool26;
wire [`DWIDTH-1:0] pool27;
wire [`DWIDTH-1:0] pool28;
wire [`DWIDTH-1:0] pool29;
wire [`DWIDTH-1:0] pool30;
wire [`DWIDTH-1:0] pool31;

wire [`DWIDTH-1:0] norm_data_out0;
wire [`DWIDTH-1:0] norm_data_out1;
wire [`DWIDTH-1:0] norm_data_out2;
wire [`DWIDTH-1:0] norm_data_out3;
wire [`DWIDTH-1:0] norm_data_out4;
wire [`DWIDTH-1:0] norm_data_out5;
wire [`DWIDTH-1:0] norm_data_out6;
wire [`DWIDTH-1:0] norm_data_out7;
wire [`DWIDTH-1:0] norm_data_out8;
wire [`DWIDTH-1:0] norm_data_out9;
wire [`DWIDTH-1:0] norm_data_out10;
wire [`DWIDTH-1:0] norm_data_out11;
wire [`DWIDTH-1:0] norm_data_out12;
wire [`DWIDTH-1:0] norm_data_out13;
wire [`DWIDTH-1:0] norm_data_out14;
wire [`DWIDTH-1:0] norm_data_out15;
wire [`DWIDTH-1:0] norm_data_out16;
wire [`DWIDTH-1:0] norm_data_out17;
wire [`DWIDTH-1:0] norm_data_out18;
wire [`DWIDTH-1:0] norm_data_out19;
wire [`DWIDTH-1:0] norm_data_out20;
wire [`DWIDTH-1:0] norm_data_out21;
wire [`DWIDTH-1:0] norm_data_out22;
wire [`DWIDTH-1:0] norm_data_out23;
wire [`DWIDTH-1:0] norm_data_out24;
wire [`DWIDTH-1:0] norm_data_out25;
wire [`DWIDTH-1:0] norm_data_out26;
wire [`DWIDTH-1:0] norm_data_out27;
wire [`DWIDTH-1:0] norm_data_out28;
wire [`DWIDTH-1:0] norm_data_out29;
wire [`DWIDTH-1:0] norm_data_out30;
wire [`DWIDTH-1:0] norm_data_out31;

wire [`DWIDTH-1:0] act_data_out0;
wire [`DWIDTH-1:0] act_data_out1;
wire [`DWIDTH-1:0] act_data_out2;
wire [`DWIDTH-1:0] act_data_out3;
wire [`DWIDTH-1:0] act_data_out4;
wire [`DWIDTH-1:0] act_data_out5;
wire [`DWIDTH-1:0] act_data_out6;
wire [`DWIDTH-1:0] act_data_out7;
wire [`DWIDTH-1:0] act_data_out8;
wire [`DWIDTH-1:0] act_data_out9;
wire [`DWIDTH-1:0] act_data_out10;
wire [`DWIDTH-1:0] act_data_out11;
wire [`DWIDTH-1:0] act_data_out12;
wire [`DWIDTH-1:0] act_data_out13;
wire [`DWIDTH-1:0] act_data_out14;
wire [`DWIDTH-1:0] act_data_out15;
wire [`DWIDTH-1:0] act_data_out16;
wire [`DWIDTH-1:0] act_data_out17;
wire [`DWIDTH-1:0] act_data_out18;
wire [`DWIDTH-1:0] act_data_out19;
wire [`DWIDTH-1:0] act_data_out20;
wire [`DWIDTH-1:0] act_data_out21;
wire [`DWIDTH-1:0] act_data_out22;
wire [`DWIDTH-1:0] act_data_out23;
wire [`DWIDTH-1:0] act_data_out24;
wire [`DWIDTH-1:0] act_data_out25;
wire [`DWIDTH-1:0] act_data_out26;
wire [`DWIDTH-1:0] act_data_out27;
wire [`DWIDTH-1:0] act_data_out28;
wire [`DWIDTH-1:0] act_data_out29;
wire [`DWIDTH-1:0] act_data_out30;
wire [`DWIDTH-1:0] act_data_out31;

////////////////////////////////////////////////////////////////
// Pooling module
////////////////////////////////////////////////////////////////
pooling u_pooling (
  .clk(clk),
  .resetn(resetn),
  .matrix_size(matrix_size),
  .filter_size(filter_size),
  .enable_pool(enable_pool),
  .pool_select(pool_select),
  .start_pooling(start_pool),
  .pool_norm_valid(pool_norm_valid),
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
  .rdata_accum7_pool(rdata_accum7_pool),
  .pool0(pool0),
  .pool1(pool1),
  .pool2(pool2),
  .pool3(pool3),
  .pool4(pool4),
  .pool5(pool5),
  .pool6(pool6),
  .pool7(pool7)  
  `endif
  `ifdef DESIGN_SIZE_16
  .raddr_accum0_pool(raddr_accum0_pool),
  .raddr_accum1_pool(raddr_accum1_pool),
  .raddr_accum2_pool(raddr_accum2_pool),
  .raddr_accum3_pool(raddr_accum3_pool),
  .raddr_accum4_pool(raddr_accum4_pool),
  .raddr_accum5_pool(raddr_accum5_pool),
  .raddr_accum6_pool(raddr_accum6_pool),
  .raddr_accum7_pool(raddr_accum7_pool),
  .raddr_accum8_pool(raddr_accum8_pool),
  .raddr_accum9_pool(raddr_accum9_pool),
  .raddr_accum10_pool(raddr_accum10_pool),
  .raddr_accum11_pool(raddr_accum11_pool),
  .raddr_accum12_pool(raddr_accum12_pool),
  .raddr_accum13_pool(raddr_accum13_pool),
  .raddr_accum14_pool(raddr_accum14_pool),
  .raddr_accum15_pool(raddr_accum15_pool),
  .rdata_accum0_pool(rdata_accum0_pool),
  .rdata_accum1_pool(rdata_accum1_pool),
  .rdata_accum2_pool(rdata_accum2_pool),
  .rdata_accum3_pool(rdata_accum3_pool),
  .rdata_accum4_pool(rdata_accum4_pool),
  .rdata_accum5_pool(rdata_accum5_pool),
  .rdata_accum6_pool(rdata_accum6_pool),
  .rdata_accum7_pool(rdata_accum7_pool),
  .rdata_accum8_pool(rdata_accum8_pool),
  .rdata_accum9_pool(rdata_accum9_pool),
  .rdata_accum10_pool(rdata_accum10_pool),
  .rdata_accum11_pool(rdata_accum11_pool),
  .rdata_accum12_pool(rdata_accum12_pool),
  .rdata_accum13_pool(rdata_accum13_pool),
  .rdata_accum14_pool(rdata_accum14_pool),
  .rdata_accum15_pool(rdata_accum15_pool),
  .pool0(pool0),
  .pool1(pool1),
  .pool2(pool2),
  .pool3(pool3),
  .pool4(pool4),
  .pool5(pool5),
  .pool6(pool6),
  .pool7(pool7),
  .pool8(pool8),
  .pool9(pool9),
  .pool10(pool10),
  .pool11(pool11),
  .pool12(pool12),
  .pool13(pool13),
  .pool14(pool14),
  .pool15(pool15)
  `endif
  `ifdef DESIGN_SIZE_32
  .raddr_accum0_pool(raddr_accum0_pool),
  .raddr_accum1_pool(raddr_accum1_pool),
  .raddr_accum2_pool(raddr_accum2_pool),
  .raddr_accum3_pool(raddr_accum3_pool),
  .raddr_accum4_pool(raddr_accum4_pool),
  .raddr_accum5_pool(raddr_accum5_pool),
  .raddr_accum6_pool(raddr_accum6_pool),
  .raddr_accum7_pool(raddr_accum7_pool),
  .raddr_accum8_pool(raddr_accum8_pool),
  .raddr_accum9_pool(raddr_accum9_pool),
  .raddr_accum10_pool(raddr_accum10_pool),
  .raddr_accum11_pool(raddr_accum11_pool),
  .raddr_accum12_pool(raddr_accum12_pool),
  .raddr_accum13_pool(raddr_accum13_pool),
  .raddr_accum14_pool(raddr_accum14_pool),
  .raddr_accum15_pool(raddr_accum15_pool),
  .raddr_accum16_pool(raddr_accum16_pool),
  .raddr_accum17_pool(raddr_accum17_pool),
  .raddr_accum18_pool(raddr_accum18_pool),
  .raddr_accum19_pool(raddr_accum19_pool),
  .raddr_accum20_pool(raddr_accum20_pool),
  .raddr_accum21_pool(raddr_accum21_pool),
  .raddr_accum22_pool(raddr_accum22_pool),
  .raddr_accum23_pool(raddr_accum23_pool),
  .raddr_accum24_pool(raddr_accum24_pool),
  .raddr_accum25_pool(raddr_accum25_pool),
  .raddr_accum26_pool(raddr_accum26_pool),
  .raddr_accum27_pool(raddr_accum27_pool),
  .raddr_accum28_pool(raddr_accum28_pool),
  .raddr_accum29_pool(raddr_accum29_pool),
  .raddr_accum30_pool(raddr_accum30_pool),
  .raddr_accum31_pool(raddr_accum31_pool),
  .rdata_accum0_pool(rdata_accum0_pool),
  .rdata_accum1_pool(rdata_accum1_pool),
  .rdata_accum2_pool(rdata_accum2_pool),
  .rdata_accum3_pool(rdata_accum3_pool),
  .rdata_accum4_pool(rdata_accum4_pool),
  .rdata_accum5_pool(rdata_accum5_pool),
  .rdata_accum6_pool(rdata_accum6_pool),
  .rdata_accum7_pool(rdata_accum7_pool),
  .rdata_accum8_pool(rdata_accum8_pool),
  .rdata_accum9_pool(rdata_accum9_pool),
  .rdata_accum10_pool(rdata_accum10_pool),
  .rdata_accum11_pool(rdata_accum11_pool),
  .rdata_accum12_pool(rdata_accum12_pool),
  .rdata_accum13_pool(rdata_accum13_pool),
  .rdata_accum14_pool(rdata_accum14_pool),
  .rdata_accum15_pool(rdata_accum15_pool),
  .rdata_accum16_pool(rdata_accum16_pool),
  .rdata_accum17_pool(rdata_accum17_pool),
  .rdata_accum18_pool(rdata_accum18_pool),
  .rdata_accum19_pool(rdata_accum19_pool),
  .rdata_accum20_pool(rdata_accum20_pool),
  .rdata_accum21_pool(rdata_accum21_pool),
  .rdata_accum22_pool(rdata_accum22_pool),
  .rdata_accum23_pool(rdata_accum23_pool),
  .rdata_accum24_pool(rdata_accum24_pool),
  .rdata_accum25_pool(rdata_accum25_pool),
  .rdata_accum26_pool(rdata_accum26_pool),
  .rdata_accum27_pool(rdata_accum27_pool),
  .rdata_accum28_pool(rdata_accum28_pool),
  .rdata_accum29_pool(rdata_accum29_pool),
  .rdata_accum30_pool(rdata_accum30_pool),
  .rdata_accum31_pool(rdata_accum31_pool),
  .pool0(pool0),
  .pool1(pool1),
  .pool2(pool2),
  .pool3(pool3),
  .pool4(pool4),
  .pool5(pool5),
  .pool6(pool6),
  .pool7(pool7),
  .pool8(pool8),
  .pool9(pool9),
  .pool10(pool10),
  .pool11(pool11),
  .pool12(pool12),
  .pool13(pool13),
  .pool14(pool14),
  .pool15(pool15),
  .pool16(pool16),
  .pool17(pool17),
  .pool18(pool18),
  .pool19(pool19),
  .pool20(pool20),
  .pool21(pool21),
  .pool22(pool22),
  .pool23(pool23),
  .pool24(pool24),
  .pool25(pool25),
  .pool26(pool26),
  .pool27(pool27),
  .pool28(pool28),
  .pool29(pool29),
  .pool30(pool30),
  .pool31(pool31)
  `endif
);


////////////////////////////////////////////////////////////////
// Normalization module
////////////////////////////////////////////////////////////////
norm u_norm(
  .enable_norm(enable_norm),
  .mean(mean),
  .inv_var(inv_var),
  .in_data_available(pool_norm_valid),
  `ifdef DESIGN_SIZE_8
  .inp_data0(pool0),
  .inp_data1(pool1),
  .inp_data2(pool2),
  .inp_data3(pool3),
  .inp_data4(pool4),
  .inp_data5(pool5),
  .inp_data6(pool6),
  .inp_data7(pool7),
  .out_data0(norm_data_out0),
  .out_data1(norm_data_out1),
  .out_data2(norm_data_out2),
  .out_data3(norm_data_out3),
  .out_data4(norm_data_out4),
  .out_data5(norm_data_out5),
  .out_data6(norm_data_out6),
  .out_data7(norm_data_out7),
  `endif
  `ifdef DESIGN_SIZE_16
  .inp_data0(pool0),
  .inp_data1(pool1),
  .inp_data2(pool2),
  .inp_data3(pool3),
  .inp_data4(pool4),
  .inp_data5(pool5),
  .inp_data6(pool6),
  .inp_data7(pool7),
  .inp_data8(pool8),
  .inp_data9(pool9),
  .inp_data10(pool10),
  .inp_data11(pool11),
  .inp_data12(pool12),
  .inp_data13(pool13),
  .inp_data14(pool14),
  .inp_data15(pool15),
  .out_data0(norm_data_out0),
  .out_data1(norm_data_out1),
  .out_data2(norm_data_out2),
  .out_data3(norm_data_out3),
  .out_data4(norm_data_out4),
  .out_data5(norm_data_out5),
  .out_data6(norm_data_out6),
  .out_data7(norm_data_out7),
  .out_data8(norm_data_out8),
  .out_data9(norm_data_out9),
  .out_data10(norm_data_out10),
  .out_data11(norm_data_out11),
  .out_data12(norm_data_out12),
  .out_data13(norm_data_out13),
  .out_data14(norm_data_out14),
  .out_data15(norm_data_out15),
  `endif
  `ifdef DESIGN_SIZE_32
  .inp_data0(pool0),
  .inp_data1(pool1),
  .inp_data2(pool2),
  .inp_data3(pool3),
  .inp_data4(pool4),
  .inp_data5(pool5),
  .inp_data6(pool6),
  .inp_data7(pool7),
  .inp_data8(pool8),
  .inp_data9(pool9),
  .inp_data10(pool10),
  .inp_data11(pool11),
  .inp_data12(pool12),
  .inp_data13(pool13),
  .inp_data14(pool14),
  .inp_data15(pool15),
  .inp_data16(pool16),
  .inp_data17(pool17),
  .inp_data18(pool18),
  .inp_data19(pool19),
  .inp_data20(pool20),
  .inp_data21(pool21),
  .inp_data22(pool22),
  .inp_data23(pool23),
  .inp_data24(pool24),
  .inp_data25(pool25),
  .inp_data26(pool26),
  .inp_data27(pool27),
  .inp_data28(pool28),
  .inp_data29(pool29),
  .inp_data30(pool30),
  .inp_data31(pool31),
  .out_data0(norm_data_out0),
  .out_data1(norm_data_out1),
  .out_data2(norm_data_out2),
  .out_data3(norm_data_out3),
  .out_data4(norm_data_out4),
  .out_data5(norm_data_out5),
  .out_data6(norm_data_out6),
  .out_data7(norm_data_out7),
  .out_data8(norm_data_out8),
  .out_data9(norm_data_out9),
  .out_data10(norm_data_out10),
  .out_data11(norm_data_out11),
  .out_data12(norm_data_out12),
  .out_data13(norm_data_out13),
  .out_data14(norm_data_out14),
  .out_data15(norm_data_out15),
  .out_data16(norm_data_out16),
  .out_data17(norm_data_out17),
  .out_data18(norm_data_out18),
  .out_data19(norm_data_out19),
  .out_data20(norm_data_out20),
  .out_data21(norm_data_out21),
  .out_data22(norm_data_out22),
  .out_data23(norm_data_out23),
  .out_data24(norm_data_out24),
  .out_data25(norm_data_out25),
  .out_data26(norm_data_out26),
  .out_data27(norm_data_out27),
  .out_data28(norm_data_out28),
  .out_data29(norm_data_out29),
  .out_data30(norm_data_out30),
  .out_data31(norm_data_out31),
  `endif
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
  .enable_pool(enable_pool),
  .in_data_available(norm_out_data_available),
  `ifdef DESIGN_SIZE_8
  .inp_data0(norm_data_out0),
  .inp_data1(norm_data_out1),
  .inp_data2(norm_data_out2),
  .inp_data3(norm_data_out3),
  .inp_data4(norm_data_out4),
  .inp_data5(norm_data_out5),
  .inp_data6(norm_data_out6),
  .inp_data7(norm_data_out7),
  .out_data0(act_data_out0),
  .out_data1(act_data_out1),
  .out_data2(act_data_out2),
  .out_data3(act_data_out3),
  .out_data4(act_data_out4),
  .out_data5(act_data_out5),
  .out_data6(act_data_out6),
  .out_data7(act_data_out7),
  `endif
  `ifdef DESIGN_SIZE_16
  .inp_data0(norm_data_out0),
  .inp_data1(norm_data_out1),
  .inp_data2(norm_data_out2),
  .inp_data3(norm_data_out3),
  .inp_data4(norm_data_out4),
  .inp_data5(norm_data_out5),
  .inp_data6(norm_data_out6),
  .inp_data7(norm_data_out7),
  .inp_data8(norm_data_out8),
  .inp_data9(norm_data_out9),
  .inp_data10(norm_data_out10),
  .inp_data11(norm_data_out11),
  .inp_data12(norm_data_out12),
  .inp_data13(norm_data_out13),
  .inp_data14(norm_data_out14),
  .inp_data15(norm_data_out15),
  .out_data0(act_data_out0),
  .out_data1(act_data_out1),
  .out_data2(act_data_out2),
  .out_data3(act_data_out3),
  .out_data4(act_data_out4),
  .out_data5(act_data_out5),
  .out_data6(act_data_out6),
  .out_data7(act_data_out7),
  .out_data8(act_data_out8),
  .out_data9(act_data_out9),
  .out_data10(act_data_out10),
  .out_data11(act_data_out11),
  .out_data12(act_data_out12),
  .out_data13(act_data_out13),
  .out_data14(act_data_out14),
  .out_data15(act_data_out15),
  `endif
  `ifdef DESIGN_SIZE_32
  .inp_data0(norm_data_out0),
  .inp_data1(norm_data_out1),
  .inp_data2(norm_data_out2),
  .inp_data3(norm_data_out3),
  .inp_data4(norm_data_out4),
  .inp_data5(norm_data_out5),
  .inp_data6(norm_data_out6),
  .inp_data7(norm_data_out7),
  .inp_data8(norm_data_out8),
  .inp_data9(norm_data_out9),
  .inp_data10(norm_data_out10),
  .inp_data11(norm_data_out11),
  .inp_data12(norm_data_out12),
  .inp_data13(norm_data_out13),
  .inp_data14(norm_data_out14),
  .inp_data15(norm_data_out15),
  .inp_data16(norm_data_out16),
  .inp_data17(norm_data_out17),
  .inp_data18(norm_data_out18),
  .inp_data19(norm_data_out19),
  .inp_data20(norm_data_out20),
  .inp_data21(norm_data_out21),
  .inp_data22(norm_data_out22),
  .inp_data23(norm_data_out23),
  .inp_data24(norm_data_out24),
  .inp_data25(norm_data_out25),
  .inp_data26(norm_data_out26),
  .inp_data27(norm_data_out27),
  .inp_data28(norm_data_out28),
  .inp_data29(norm_data_out29),
  .inp_data30(norm_data_out30),
  .inp_data31(norm_data_out31),
  .out_data0(act_data_out0),
  .out_data1(act_data_out1),
  .out_data2(act_data_out2),
  .out_data3(act_data_out3),
  .out_data4(act_data_out4),
  .out_data5(act_data_out5),
  .out_data6(act_data_out6),
  .out_data7(act_data_out7),
  .out_data8(act_data_out8),
  .out_data9(act_data_out9),
  .out_data10(act_data_out10),
  .out_data11(act_data_out11),
  .out_data12(act_data_out12),
  .out_data13(act_data_out13),
  .out_data14(act_data_out14),
  .out_data15(act_data_out15),
  .out_data16(act_data_out16),
  .out_data17(act_data_out17),
  .out_data18(act_data_out18),
  .out_data19(act_data_out19),
  .out_data20(act_data_out20),
  .out_data21(act_data_out21),
  .out_data22(act_data_out22),
  .out_data23(act_data_out23),
  .out_data24(act_data_out24),
  .out_data25(act_data_out25),
  .out_data26(act_data_out26),
  .out_data27(act_data_out27),
  .out_data28(act_data_out28),
  .out_data29(act_data_out29),
  .out_data30(act_data_out30),
  .out_data31(act_data_out31),
  `endif
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

reg activation_out_data_available1;
reg activation_out_data_available2;
reg activation_out_data_available3;
reg activation_out_data_available4;
reg activation_out_data_available5;
reg activation_out_data_available6;
reg activation_out_data_available7;

`ifdef DESIGN_SIZE_16
reg activation_out_data_available8;
reg activation_out_data_available9;
reg activation_out_data_available10;
reg activation_out_data_available11;
reg activation_out_data_available12;
reg activation_out_data_available13;
reg activation_out_data_available14;
reg activation_out_data_available15;
`endif

`ifdef DESIGN_SIZE_32
reg activation_out_data_available8;
reg activation_out_data_available9;
reg activation_out_data_available10;
reg activation_out_data_available11;
reg activation_out_data_available12;
reg activation_out_data_available13;
reg activation_out_data_available14;
reg activation_out_data_available15;
reg activation_out_data_available16;
reg activation_out_data_available17;
reg activation_out_data_available18;
reg activation_out_data_available19;
reg activation_out_data_available20;
reg activation_out_data_available21;
reg activation_out_data_available22;
reg activation_out_data_available23;
reg activation_out_data_available24;
reg activation_out_data_available25;
reg activation_out_data_available26;
reg activation_out_data_available27;
reg activation_out_data_available28;
reg activation_out_data_available29;
reg activation_out_data_available30;
reg activation_out_data_available31;
`endif

always @(posedge clk) begin
    activation_out_data_available1 <= activation_out_data_available;
    activation_out_data_available2 <= activation_out_data_available1;
    activation_out_data_available3 <= activation_out_data_available2;
    activation_out_data_available4 <= activation_out_data_available3;
    activation_out_data_available5 <= activation_out_data_available4;
    activation_out_data_available6 <= activation_out_data_available5;
    activation_out_data_available7 <= activation_out_data_available6;
end

`ifdef DESIGN_SIZE_16
always @(posedge clk) begin
    activation_out_data_available8 <= activation_out_data_available7;
    activation_out_data_available9 <= activation_out_data_available8;
    activation_out_data_available10 <= activation_out_data_available9;
    activation_out_data_available11 <= activation_out_data_available10;
    activation_out_data_available12 <= activation_out_data_available11;
    activation_out_data_available13 <= activation_out_data_available12;
    activation_out_data_available14 <= activation_out_data_available13;
    activation_out_data_available15 <= activation_out_data_available14;
end
`endif

`ifdef DESIGN_SIZE_32
always @(posedge clk) begin
    activation_out_data_available8 <= activation_out_data_available7;
    activation_out_data_available9 <= activation_out_data_available8;
    activation_out_data_available10 <= activation_out_data_available9;
    activation_out_data_available11 <= activation_out_data_available10;
    activation_out_data_available12 <= activation_out_data_available11;
    activation_out_data_available13 <= activation_out_data_available12;
    activation_out_data_available14 <= activation_out_data_available13;
    activation_out_data_available15 <= activation_out_data_available14;
    activation_out_data_available16 <= activation_out_data_available15;
    activation_out_data_available17 <= activation_out_data_available16;
    activation_out_data_available18 <= activation_out_data_available17;
    activation_out_data_available19 <= activation_out_data_available18;
    activation_out_data_available20 <= activation_out_data_available19;
    activation_out_data_available21 <= activation_out_data_available20;
    activation_out_data_available22 <= activation_out_data_available21;
    activation_out_data_available23 <= activation_out_data_available22;
    activation_out_data_available24 <= activation_out_data_available23;
    activation_out_data_available25 <= activation_out_data_available24;
    activation_out_data_available26 <= activation_out_data_available25;
    activation_out_data_available27 <= activation_out_data_available26;
    activation_out_data_available28 <= activation_out_data_available27;
    activation_out_data_available29 <= activation_out_data_available28;
    activation_out_data_available30 <= activation_out_data_available29;
    activation_out_data_available31 <= activation_out_data_available30;
end
`endif

reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data0;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data1;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data2;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data3;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data4;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data5;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data6;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data7;

`ifdef DESIGN_SIZE_16
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data8;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data9;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data10;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data11;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data12;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data13;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data14;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data15;
`endif

`ifdef DESIGN_SIZE_32
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data8;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data9;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data10;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data11;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data12;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data13;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data14;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data15;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data16;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data17;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data18;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data19;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data20;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data21;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data22;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data23;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data24;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data25;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data26;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data27;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data28;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data29;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data30;
reg [(`MAT_MUL_SIZE*`DWIDTH)-1:0] final_data31;
`endif

always @(posedge clk) begin
    if (reset) begin
        final_data0 <= 0;
    end
    else if (activation_out_data_available) begin
        final_data0 <= {act_data_out0[7:0],final_data0[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data1 <= 0;
    end
    else if (activation_out_data_available1) begin
        final_data1 <= {act_data_out1[7:0],final_data1[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data2 <= 0;
    end
    else if (activation_out_data_available2) begin
        final_data2 <= {act_data_out2[7:0],final_data2[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data3 <= 0;
    end
    else if (activation_out_data_available3) begin
        final_data3 <= {act_data_out3[7:0],final_data3[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data4 <= 0;
    end
    else if (activation_out_data_available4) begin
        final_data4 <= {act_data_out4[7:0],final_data4[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data5 <= 0;
    end
    else if (activation_out_data_available5) begin
        final_data5 <= {act_data_out5[7:0],final_data5[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data6 <= 0;
    end
    else if (activation_out_data_available6) begin
        final_data6 <= {act_data_out6[7:0],final_data6[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data7 <= 0;
    end
    else if (activation_out_data_available7) begin
        final_data7 <= {act_data_out7[7:0],final_data7[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

`ifdef DESIGN_SIZE_16
always @(posedge clk) begin
    if (reset) begin
        final_data8 <= 0;
    end
    else if (activation_out_data_available8) begin
        final_data8 <= {act_data_out8[7:0],final_data8[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data9 <= 0;
    end
    else if (activation_out_data_available9) begin
        final_data9 <= {act_data_out9[7:0],final_data9[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data10 <= 0;
    end
    else if (activation_out_data_available10) begin
        final_data10 <= {act_data_out10[7:0],final_data10[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data11 <= 0;
    end
    else if (activation_out_data_available11) begin
        final_data11 <= {act_data_out11[7:0],final_data11[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data12 <= 0;
    end
    else if (activation_out_data_available12) begin
        final_data12 <= {act_data_out12[7:0],final_data12[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data13 <= 0;
    end
    else if (activation_out_data_available13) begin
        final_data13 <= {act_data_out13[7:0],final_data13[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data14 <= 0;
    end
    else if (activation_out_data_available14) begin
        final_data14 <= {act_data_out14[7:0],final_data14[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data15 <= 0;
    end
    else if (activation_out_data_available15) begin
        final_data15 <= {act_data_out15[7:0],final_data15[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end
`endif

`ifdef DESIGN_SIZE_32
always @(posedge clk) begin
    if (reset) begin
        final_data8 <= 0;
    end
    else if (activation_out_data_available8) begin
        final_data8 <= {act_data_out8[7:0],final_data8[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data9 <= 0;
    end
    else if (activation_out_data_available9) begin
        final_data9 <= {act_data_out9[7:0],final_data9[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data10 <= 0;
    end
    else if (activation_out_data_available10) begin
        final_data10 <= {act_data_out10[7:0],final_data10[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data11 <= 0;
    end
    else if (activation_out_data_available11) begin
        final_data11 <= {act_data_out11[7:0],final_data11[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data12 <= 0;
    end
    else if (activation_out_data_available12) begin
        final_data12 <= {act_data_out12[7:0],final_data12[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data13 <= 0;
    end
    else if (activation_out_data_available13) begin
        final_data13 <= {act_data_out13[7:0],final_data13[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data14 <= 0;
    end
    else if (activation_out_data_available14) begin
        final_data14 <= {act_data_out14[7:0],final_data14[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data15 <= 0;
    end
    else if (activation_out_data_available15) begin
        final_data15 <= {act_data_out15[7:0],final_data15[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data16 <= 0;
    end
    else if (activation_out_data_available16) begin
        final_data16 <= {act_data_out16[7:0],final_data16[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data17 <= 0;
    end
    else if (activation_out_data_available17) begin
        final_data17 <= {act_data_out17[7:0],final_data17[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data18 <= 0;
    end
    else if (activation_out_data_available18) begin
        final_data18 <= {act_data_out18[7:0],final_data18[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data19 <= 0;
    end
    else if (activation_out_data_available19) begin
        final_data19 <= {act_data_out19[7:0],final_data19[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data20 <= 0;
    end
    else if (activation_out_data_available20) begin
        final_data20 <= {act_data_out20[7:0],final_data20[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data21 <= 0;
    end
    else if (activation_out_data_available21) begin
        final_data21 <= {act_data_out21[7:0],final_data21[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data22 <= 0;
    end
    else if (activation_out_data_available22) begin
        final_data22 <= {act_data_out22[7:0],final_data22[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data23 <= 0;
    end
    else if (activation_out_data_available23) begin
        final_data23 <= {act_data_out23[7:0],final_data23[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data24 <= 0;
    end
    else if (activation_out_data_available24) begin
        final_data24 <= {act_data_out24[7:0],final_data24[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data25 <= 0;
    end
    else if (activation_out_data_available25) begin
        final_data25 <= {act_data_out25[7:0],final_data25[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data26 <= 0;
    end
    else if (activation_out_data_available26) begin
        final_data26 <= {act_data_out26[7:0],final_data26[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data27 <= 0;
    end
    else if (activation_out_data_available27) begin
        final_data27 <= {act_data_out27[7:0],final_data27[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data28 <= 0;
    end
    else if (activation_out_data_available28) begin
        final_data28 <= {act_data_out28[7:0],final_data28[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data29 <= 0;
    end
    else if (activation_out_data_available29) begin
        final_data29 <= {act_data_out29[7:0],final_data29[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data30 <= 0;
    end
    else if (activation_out_data_available30) begin
        final_data30 <= {act_data_out30[7:0],final_data30[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end

always @(posedge clk) begin
    if (reset) begin
        final_data31 <= 0;
    end
    else if (activation_out_data_available31) begin
        final_data31 <= {act_data_out31[7:0],final_data31[(`MAT_MUL_SIZE*`DWIDTH)-1:8]};
    end
end
`endif

reg [31:0] i;
  always @(posedge clk) begin
    if (reset) begin
        i <= 0;
        bram_wdata_a <= 0;
        bram_addr_a_for_writing <= address_mat_c + address_stride_c;
        bram_a_wdata_available <= 0;
      end
    else if (done_activation) begin
        i <= i + 1;
        case(i)
        `ifdef DESIGN_SIZE_8
        0: begin bram_wdata_a <= final_data0; end
        1: begin bram_wdata_a <= final_data1; end
        2: begin bram_wdata_a <= final_data2; end
        3: begin bram_wdata_a <= final_data3; end
        4: begin bram_wdata_a <= final_data4; end
        5: begin bram_wdata_a <= final_data5; end
        6: begin bram_wdata_a <= final_data6; end
        7: begin bram_wdata_a <= final_data7; end
        default : begin bram_wdata_a <= final_data7; end
        `endif
        `ifdef DESIGN_SIZE_16
        0: begin bram_wdata_a <= final_data0; end
        1: begin bram_wdata_a <= final_data1; end
        2: begin bram_wdata_a <= final_data2; end
        3: begin bram_wdata_a <= final_data3; end
        4: begin bram_wdata_a <= final_data4; end
        5: begin bram_wdata_a <= final_data5; end
        6: begin bram_wdata_a <= final_data6; end
        7: begin bram_wdata_a <= final_data7; end
        8: begin bram_wdata_a <= final_data8; end
        9: begin bram_wdata_a <= final_data9; end
        10: begin bram_wdata_a <= final_data10; end
        11: begin bram_wdata_a <= final_data11; end
        12: begin bram_wdata_a <= final_data12; end
        13: begin bram_wdata_a <= final_data13; end
        14: begin bram_wdata_a <= final_data14; end
        15: begin bram_wdata_a <= final_data15; end
        default : begin bram_wdata_a <= final_data15; end
        `endif 
        `ifdef DESIGN_SIZE_32
        0: begin bram_wdata_a <= final_data0; end
        1: begin bram_wdata_a <= final_data1; end
        2: begin bram_wdata_a <= final_data2; end
        3: begin bram_wdata_a <= final_data3; end
        4: begin bram_wdata_a <= final_data4; end
        5: begin bram_wdata_a <= final_data5; end
        6: begin bram_wdata_a <= final_data6; end
        7: begin bram_wdata_a <= final_data7; end
        8: begin bram_wdata_a <= final_data8; end
        9: begin bram_wdata_a <= final_data9; end
        10: begin bram_wdata_a <= final_data10; end
        11: begin bram_wdata_a <= final_data11; end
        12: begin bram_wdata_a <= final_data12; end
        13: begin bram_wdata_a <= final_data13; end
        14: begin bram_wdata_a <= final_data14; end
        15: begin bram_wdata_a <= final_data15; end
        16: begin bram_wdata_a <= final_data16; end
        17: begin bram_wdata_a <= final_data17; end
        18: begin bram_wdata_a <= final_data18; end
        19: begin bram_wdata_a <= final_data19; end
        20: begin bram_wdata_a <= final_data20; end
        21: begin bram_wdata_a <= final_data21; end
        22: begin bram_wdata_a <= final_data22; end
        23: begin bram_wdata_a <= final_data23; end
        24: begin bram_wdata_a <= final_data24; end
        25: begin bram_wdata_a <= final_data25; end
        26: begin bram_wdata_a <= final_data26; end
        27: begin bram_wdata_a <= final_data27; end
        28: begin bram_wdata_a <= final_data28; end
        29: begin bram_wdata_a <= final_data29; end
        30: begin bram_wdata_a <= final_data30; end
        31: begin bram_wdata_a <= final_data31; end
        default : begin bram_wdata_a <= final_data31; end
        `endif
        endcase
        bram_addr_a_for_writing <= bram_addr_a_for_writing - address_stride_c;
        bram_a_wdata_available <= done_activation;
    end
    else begin
        bram_wdata_a <= 0;
        bram_addr_a_for_writing <= address_mat_c + address_stride_c;
        bram_a_wdata_available <= 0;
    end
  end
 

endmodule

