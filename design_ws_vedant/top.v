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

wire [`DWIDTH-1:0] rdata_accum0;
wire [`DWIDTH-1:0] rdata_accum1;
wire [`DWIDTH-1:0] rdata_accum2;
wire [`DWIDTH-1:0] rdata_accum3;
wire [`DWIDTH-1:0] rdata_accum4;
wire [`DWIDTH-1:0] rdata_accum5;
wire [`DWIDTH-1:0] rdata_accum6;
wire [`DWIDTH-1:0] rdata_accum7;
wire [`AWIDTH-1:0] raddr_accum0_matmul;
wire [`AWIDTH-1:0] raddr_accum1_matmul;
wire [`AWIDTH-1:0] raddr_accum2_matmul;
wire [`AWIDTH-1:0] raddr_accum3_matmul;
wire [`AWIDTH-1:0] raddr_accum4_matmul;
wire [`AWIDTH-1:0] raddr_accum5_matmul;
wire [`AWIDTH-1:0] raddr_accum6_matmul;
wire [`AWIDTH-1:0] raddr_accum7_matmul;
`endif

`ifdef DESIGN_SIZE_16
wire [`AWIDTH-1:0] start_waddr_accum0;
wire [`AWIDTH-1:0] start_waddr_accum1;
wire [`AWIDTH-1:0] start_waddr_accum2;
wire [`AWIDTH-1:0] start_waddr_accum3;
wire [`AWIDTH-1:0] start_waddr_accum4;
wire [`AWIDTH-1:0] start_waddr_accum5;
wire [`AWIDTH-1:0] start_waddr_accum6;
wire [`AWIDTH-1:0] start_waddr_accum7;
wire [`AWIDTH-1:0] start_waddr_accum8;
wire [`AWIDTH-1:0] start_waddr_accum9;
wire [`AWIDTH-1:0] start_waddr_accum10;
wire [`AWIDTH-1:0] start_waddr_accum11;
wire [`AWIDTH-1:0] start_waddr_accum12;
wire [`AWIDTH-1:0] start_waddr_accum13;
wire [`AWIDTH-1:0] start_waddr_accum14;
wire [`AWIDTH-1:0] start_waddr_accum15;

assign start_waddr_accum0 = 11'b0;
assign start_waddr_accum1 = 11'b0;
assign start_waddr_accum2 = 11'b0;
assign start_waddr_accum3 = 11'b0;
assign start_waddr_accum4 = 11'b0;
assign start_waddr_accum5 = 11'b0;
assign start_waddr_accum6 = 11'b0;
assign start_waddr_accum7 = 11'b0;
assign start_waddr_accum8 = 11'b0;
assign start_waddr_accum9 = 11'b0;
assign start_waddr_accum10 = 11'b0;
assign start_waddr_accum11 = 11'b0;
assign start_waddr_accum12 = 11'b0;
assign start_waddr_accum13 = 11'b0;
assign start_waddr_accum14 = 11'b0;
assign start_waddr_accum15 = 11'b0;

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

wire [`DWIDTH-1:0] rdata_accum0;
wire [`DWIDTH-1:0] rdata_accum1;
wire [`DWIDTH-1:0] rdata_accum2;
wire [`DWIDTH-1:0] rdata_accum3;
wire [`DWIDTH-1:0] rdata_accum4;
wire [`DWIDTH-1:0] rdata_accum5;
wire [`DWIDTH-1:0] rdata_accum6;
wire [`DWIDTH-1:0] rdata_accum7;
wire [`DWIDTH-1:0] rdata_accum8;
wire [`DWIDTH-1:0] rdata_accum9;
wire [`DWIDTH-1:0] rdata_accum10;
wire [`DWIDTH-1:0] rdata_accum11;
wire [`DWIDTH-1:0] rdata_accum12;
wire [`DWIDTH-1:0] rdata_accum13;
wire [`DWIDTH-1:0] rdata_accum14;
wire [`DWIDTH-1:0] rdata_accum15;
wire [`AWIDTH-1:0] raddr_accum0_matmul;
wire [`AWIDTH-1:0] raddr_accum1_matmul;
wire [`AWIDTH-1:0] raddr_accum2_matmul;
wire [`AWIDTH-1:0] raddr_accum3_matmul;
wire [`AWIDTH-1:0] raddr_accum4_matmul;
wire [`AWIDTH-1:0] raddr_accum5_matmul;
wire [`AWIDTH-1:0] raddr_accum6_matmul;
wire [`AWIDTH-1:0] raddr_accum7_matmul;
wire [`AWIDTH-1:0] raddr_accum8_matmul;
wire [`AWIDTH-1:0] raddr_accum9_matmul;
wire [`AWIDTH-1:0] raddr_accum10_matmul;
wire [`AWIDTH-1:0] raddr_accum11_matmul;
wire [`AWIDTH-1:0] raddr_accum12_matmul;
wire [`AWIDTH-1:0] raddr_accum13_matmul;
wire [`AWIDTH-1:0] raddr_accum14_matmul;
wire [`AWIDTH-1:0] raddr_accum15_matmul;
`endif

`ifdef DESIGN_SIZE_32
wire [`AWIDTH-1:0] start_waddr_accum0;
wire [`AWIDTH-1:0] start_waddr_accum1;
wire [`AWIDTH-1:0] start_waddr_accum2;
wire [`AWIDTH-1:0] start_waddr_accum3;
wire [`AWIDTH-1:0] start_waddr_accum4;
wire [`AWIDTH-1:0] start_waddr_accum5;
wire [`AWIDTH-1:0] start_waddr_accum6;
wire [`AWIDTH-1:0] start_waddr_accum7;
wire [`AWIDTH-1:0] start_waddr_accum8;
wire [`AWIDTH-1:0] start_waddr_accum9;
wire [`AWIDTH-1:0] start_waddr_accum10;
wire [`AWIDTH-1:0] start_waddr_accum11;
wire [`AWIDTH-1:0] start_waddr_accum12;
wire [`AWIDTH-1:0] start_waddr_accum13;
wire [`AWIDTH-1:0] start_waddr_accum14;
wire [`AWIDTH-1:0] start_waddr_accum15;
wire [`AWIDTH-1:0] start_waddr_accum16;
wire [`AWIDTH-1:0] start_waddr_accum17;
wire [`AWIDTH-1:0] start_waddr_accum18;
wire [`AWIDTH-1:0] start_waddr_accum19;
wire [`AWIDTH-1:0] start_waddr_accum20;
wire [`AWIDTH-1:0] start_waddr_accum21;
wire [`AWIDTH-1:0] start_waddr_accum22;
wire [`AWIDTH-1:0] start_waddr_accum23;
wire [`AWIDTH-1:0] start_waddr_accum24;
wire [`AWIDTH-1:0] start_waddr_accum25;
wire [`AWIDTH-1:0] start_waddr_accum26;
wire [`AWIDTH-1:0] start_waddr_accum27;
wire [`AWIDTH-1:0] start_waddr_accum28;
wire [`AWIDTH-1:0] start_waddr_accum29;
wire [`AWIDTH-1:0] start_waddr_accum30;
wire [`AWIDTH-1:0] start_waddr_accum31;

assign start_waddr_accum0 = 11'b0;
assign start_waddr_accum1 = 11'b0;
assign start_waddr_accum2 = 11'b0;
assign start_waddr_accum3 = 11'b0;
assign start_waddr_accum4 = 11'b0;
assign start_waddr_accum5 = 11'b0;
assign start_waddr_accum6 = 11'b0;
assign start_waddr_accum7 = 11'b0;
assign start_waddr_accum8 = 11'b0;
assign start_waddr_accum9 = 11'b0;
assign start_waddr_accum10 = 11'b0;
assign start_waddr_accum11 = 11'b0;
assign start_waddr_accum12 = 11'b0;
assign start_waddr_accum13 = 11'b0;
assign start_waddr_accum14 = 11'b0;
assign start_waddr_accum15 = 11'b0;
assign start_waddr_accum16 = 11'b0;
assign start_waddr_accum17 = 11'b0;
assign start_waddr_accum18 = 11'b0;
assign start_waddr_accum19 = 11'b0;
assign start_waddr_accum20 = 11'b0;
assign start_waddr_accum21 = 11'b0;
assign start_waddr_accum22 = 11'b0;
assign start_waddr_accum23 = 11'b0;
assign start_waddr_accum24 = 11'b0;
assign start_waddr_accum25 = 11'b0;
assign start_waddr_accum26 = 11'b0;
assign start_waddr_accum27 = 11'b0;
assign start_waddr_accum28 = 11'b0;
assign start_waddr_accum29 = 11'b0;
assign start_waddr_accum30 = 11'b0;
assign start_waddr_accum31 = 11'b0;

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

wire [`DWIDTH-1:0] rdata_accum0;
wire [`DWIDTH-1:0] rdata_accum1;
wire [`DWIDTH-1:0] rdata_accum2;
wire [`DWIDTH-1:0] rdata_accum3;
wire [`DWIDTH-1:0] rdata_accum4;
wire [`DWIDTH-1:0] rdata_accum5;
wire [`DWIDTH-1:0] rdata_accum6;
wire [`DWIDTH-1:0] rdata_accum7;
wire [`DWIDTH-1:0] rdata_accum8;
wire [`DWIDTH-1:0] rdata_accum9;
wire [`DWIDTH-1:0] rdata_accum10;
wire [`DWIDTH-1:0] rdata_accum11;
wire [`DWIDTH-1:0] rdata_accum12;
wire [`DWIDTH-1:0] rdata_accum13;
wire [`DWIDTH-1:0] rdata_accum14;
wire [`DWIDTH-1:0] rdata_accum15;
wire [`DWIDTH-1:0] rdata_accum16;
wire [`DWIDTH-1:0] rdata_accum17;
wire [`DWIDTH-1:0] rdata_accum18;
wire [`DWIDTH-1:0] rdata_accum19;
wire [`DWIDTH-1:0] rdata_accum20;
wire [`DWIDTH-1:0] rdata_accum21;
wire [`DWIDTH-1:0] rdata_accum22;
wire [`DWIDTH-1:0] rdata_accum23;
wire [`DWIDTH-1:0] rdata_accum24;
wire [`DWIDTH-1:0] rdata_accum25;
wire [`DWIDTH-1:0] rdata_accum26;
wire [`DWIDTH-1:0] rdata_accum27;
wire [`DWIDTH-1:0] rdata_accum28;
wire [`DWIDTH-1:0] rdata_accum29;
wire [`DWIDTH-1:0] rdata_accum30;
wire [`DWIDTH-1:0] rdata_accum31;
wire [`AWIDTH-1:0] raddr_accum0_matmul;
wire [`AWIDTH-1:0] raddr_accum1_matmul;
wire [`AWIDTH-1:0] raddr_accum2_matmul;
wire [`AWIDTH-1:0] raddr_accum3_matmul;
wire [`AWIDTH-1:0] raddr_accum4_matmul;
wire [`AWIDTH-1:0] raddr_accum5_matmul;
wire [`AWIDTH-1:0] raddr_accum6_matmul;
wire [`AWIDTH-1:0] raddr_accum7_matmul;
wire [`AWIDTH-1:0] raddr_accum8_matmul;
wire [`AWIDTH-1:0] raddr_accum9_matmul;
wire [`AWIDTH-1:0] raddr_accum10_matmul;
wire [`AWIDTH-1:0] raddr_accum11_matmul;
wire [`AWIDTH-1:0] raddr_accum12_matmul;
wire [`AWIDTH-1:0] raddr_accum13_matmul;
wire [`AWIDTH-1:0] raddr_accum14_matmul;
wire [`AWIDTH-1:0] raddr_accum15_matmul;
wire [`AWIDTH-1:0] raddr_accum16_matmul;
wire [`AWIDTH-1:0] raddr_accum17_matmul;
wire [`AWIDTH-1:0] raddr_accum18_matmul;
wire [`AWIDTH-1:0] raddr_accum19_matmul;
wire [`AWIDTH-1:0] raddr_accum20_matmul;
wire [`AWIDTH-1:0] raddr_accum21_matmul;
wire [`AWIDTH-1:0] raddr_accum22_matmul;
wire [`AWIDTH-1:0] raddr_accum23_matmul;
wire [`AWIDTH-1:0] raddr_accum24_matmul;
wire [`AWIDTH-1:0] raddr_accum25_matmul;
wire [`AWIDTH-1:0] raddr_accum26_matmul;
wire [`AWIDTH-1:0] raddr_accum27_matmul;
wire [`AWIDTH-1:0] raddr_accum28_matmul;
wire [`AWIDTH-1:0] raddr_accum29_matmul;
wire [`AWIDTH-1:0] raddr_accum30_matmul;
wire [`AWIDTH-1:0] raddr_accum31_matmul;
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
  .done_pooling(done_pool),
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
  .raddr_accum0_matmul(raddr_accum0_matmul),
  .raddr_accum1_matmul(raddr_accum1_matmul),
  .raddr_accum2_matmul(raddr_accum2_matmul),
  .raddr_accum3_matmul(raddr_accum3_matmul),
  .raddr_accum4_matmul(raddr_accum4_matmul),
  .raddr_accum5_matmul(raddr_accum5_matmul),
  .raddr_accum6_matmul(raddr_accum6_matmul),
  .raddr_accum7_matmul(raddr_accum7_matmul),
  .raddr_accum0_pool(raddr_accum0_pool),
  .raddr_accum1_pool(raddr_accum1_pool),
  .raddr_accum2_pool(raddr_accum2_pool),
  .raddr_accum3_pool(raddr_accum3_pool),
  .raddr_accum4_pool(raddr_accum4_pool),
  .raddr_accum5_pool(raddr_accum5_pool),
  .raddr_accum6_pool(raddr_accum6_pool),
  .raddr_accum7_pool(raddr_accum7_pool),
  .rdata_accum0(rdata_accum0),
  .rdata_accum1(rdata_accum1),
  .rdata_accum2(rdata_accum2),
  .rdata_accum3(rdata_accum3),
  .rdata_accum4(rdata_accum4),
  .rdata_accum5(rdata_accum5),
  .rdata_accum6(rdata_accum6),
  .rdata_accum7(rdata_accum7),
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
  .start_waddr_accum0(start_waddr_accum0),
  .start_waddr_accum1(start_waddr_accum1),
  .start_waddr_accum2(start_waddr_accum2),
  .start_waddr_accum3(start_waddr_accum3),
  .start_waddr_accum4(start_waddr_accum4),
  .start_waddr_accum5(start_waddr_accum5),
  .start_waddr_accum6(start_waddr_accum6),
  .start_waddr_accum7(start_waddr_accum7),
  .start_waddr_accum8(start_waddr_accum8),
  .start_waddr_accum9(start_waddr_accum9),
  .start_waddr_accum10(start_waddr_accum10),
  .start_waddr_accum11(start_waddr_accum11),
  .start_waddr_accum12(start_waddr_accum12),
  .start_waddr_accum13(start_waddr_accum13),
  .start_waddr_accum14(start_waddr_accum14),
  .start_waddr_accum15(start_waddr_accum15),
  .wdata_accum0(matrixC150),
  .wdata_accum1(matrixC151),
  .wdata_accum2(matrixC152),
  .wdata_accum3(matrixC153),
  .wdata_accum4(matrixC154),
  .wdata_accum5(matrixC155),
  .wdata_accum6(matrixC156),
  .wdata_accum7(matrixC157),
  .wdata_accum8(matrixC158),
  .wdata_accum9(matrixC159),
  .wdata_accum10(matrixC1510),
  .wdata_accum11(matrixC1511),
  .wdata_accum12(matrixC1512),
  .wdata_accum13(matrixC1513),
  .wdata_accum14(matrixC1514),
  .wdata_accum15(matrixC1515),
  .raddr_accum0_matmul(raddr_accum0_matmul),
  .raddr_accum1_matmul(raddr_accum1_matmul),
  .raddr_accum2_matmul(raddr_accum2_matmul),
  .raddr_accum3_matmul(raddr_accum3_matmul),
  .raddr_accum4_matmul(raddr_accum4_matmul),
  .raddr_accum5_matmul(raddr_accum5_matmul),
  .raddr_accum6_matmul(raddr_accum6_matmul),
  .raddr_accum7_matmul(raddr_accum7_matmul),
  .raddr_accum9_matmul(raddr_accum9_matmul),
  .raddr_accum10_matmul(raddr_accum10_matmul),
  .raddr_accum11_matmul(raddr_accum11_matmul),
  .raddr_accum12_matmul(raddr_accum12_matmul),
  .raddr_accum13_matmul(raddr_accum13_matmul),
  .raddr_accum14_matmul(raddr_accum14_matmul),
  .raddr_accum15_matmul(raddr_accum15_matmul),
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
  .rdata_accum0(rdata_accum0),
  .rdata_accum1(rdata_accum1),
  .rdata_accum2(rdata_accum2),
  .rdata_accum3(rdata_accum3),
  .rdata_accum4(rdata_accum4),
  .rdata_accum5(rdata_accum5),
  .rdata_accum6(rdata_accum6),
  .rdata_accum7(rdata_accum7),
  .rdata_accum8(rdata_accum8),
  .rdata_accum9(rdata_accum9),
  .rdata_accum10(rdata_accum10),
  .rdata_accum11(rdata_accum11),
  .rdata_accum12(rdata_accum12),
  .rdata_accum13(rdata_accum13),
  .rdata_accum14(rdata_accum14),
  .rdata_accum15(rdata_accum15),
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
  .start_waddr_accum0(start_waddr_accum0),
  .start_waddr_accum1(start_waddr_accum1),
  .start_waddr_accum2(start_waddr_accum2),
  .start_waddr_accum3(start_waddr_accum3),
  .start_waddr_accum4(start_waddr_accum4),
  .start_waddr_accum5(start_waddr_accum5),
  .start_waddr_accum6(start_waddr_accum6),
  .start_waddr_accum7(start_waddr_accum7),
  .start_waddr_accum8(start_waddr_accum8),
  .start_waddr_accum9(start_waddr_accum9),
  .start_waddr_accum10(start_waddr_accum10),
  .start_waddr_accum11(start_waddr_accum11),
  .start_waddr_accum12(start_waddr_accum12),
  .start_waddr_accum13(start_waddr_accum13),
  .start_waddr_accum14(start_waddr_accum14),
  .start_waddr_accum15(start_waddr_accum15),
  .start_waddr_accum16(start_waddr_accum16),
  .start_waddr_accum17(start_waddr_accum17),
  .start_waddr_accum18(start_waddr_accum18),
  .start_waddr_accum19(start_waddr_accum19),
  .start_waddr_accum20(start_waddr_accum20),
  .start_waddr_accum21(start_waddr_accum21),
  .start_waddr_accum22(start_waddr_accum22),
  .start_waddr_accum23(start_waddr_accum23),
  .start_waddr_accum24(start_waddr_accum24),
  .start_waddr_accum25(start_waddr_accum25),
  .start_waddr_accum26(start_waddr_accum26),
  .start_waddr_accum27(start_waddr_accum27),
  .start_waddr_accum28(start_waddr_accum28),
  .start_waddr_accum29(start_waddr_accum29),
  .start_waddr_accum30(start_waddr_accum30),
  .start_waddr_accum31(start_waddr_accum31),
  .wdata_accum0(matrixC310),
  .wdata_accum1(matrixC311),
  .wdata_accum2(matrixC312),
  .wdata_accum3(matrixC313),
  .wdata_accum4(matrixC314),
  .wdata_accum5(matrixC315),
  .wdata_accum6(matrixC316),
  .wdata_accum7(matrixC317),
  .wdata_accum8(matrixC318),
  .wdata_accum9(matrixC319),
  .wdata_accum10(matrixC3110),
  .wdata_accum11(matrixC3111),
  .wdata_accum12(matrixC3112),
  .wdata_accum13(matrixC3113),
  .wdata_accum14(matrixC3114),
  .wdata_accum15(matrixC3115),
  .wdata_accum16(matrixC3116),
  .wdata_accum17(matrixC3117),
  .wdata_accum18(matrixC3118),
  .wdata_accum19(matrixC3119),
  .wdata_accum20(matrixC3120),
  .wdata_accum21(matrixC3121),
  .wdata_accum22(matrixC3122),
  .wdata_accum23(matrixC3123),
  .wdata_accum24(matrixC3124),
  .wdata_accum25(matrixC3125),
  .wdata_accum26(matrixC3126),
  .wdata_accum27(matrixC3127),
  .wdata_accum28(matrixC3128),
  .wdata_accum29(matrixC3129),
  .wdata_accum30(matrixC3130),
  .wdata_accum31(matrixC3131),
  .raddr_accum0_matmul(raddr_accum0_matmul),
  .raddr_accum1_matmul(raddr_accum1_matmul),
  .raddr_accum2_matmul(raddr_accum2_matmul),
  .raddr_accum3_matmul(raddr_accum3_matmul),
  .raddr_accum4_matmul(raddr_accum4_matmul),
  .raddr_accum5_matmul(raddr_accum5_matmul),
  .raddr_accum6_matmul(raddr_accum6_matmul),
  .raddr_accum7_matmul(raddr_accum7_matmul),
  .rdata_accum0_matmul(rdata_accum0_matmul),
  .raddr_accum9_matmul(raddr_accum9_matmul),
  .raddr_accum10_matmul(raddr_accum10_matmul),
  .raddr_accum11_matmul(raddr_accum11_matmul),
  .raddr_accum12_matmul(raddr_accum12_matmul),
  .raddr_accum13_matmul(raddr_accum13_matmul),
  .raddr_accum14_matmul(raddr_accum14_matmul),
  .raddr_accum15_matmul(raddr_accum15_matmul),
  .raddr_accum16_matmul(raddr_accum16_matmul),
  .raddr_accum17_matmul(raddr_accum17_matmul),
  .raddr_accum18_matmul(raddr_accum18_matmul),
  .raddr_accum19_matmul(raddr_accum19_matmul),
  .raddr_accum20_matmul(raddr_accum20_matmul),
  .raddr_accum21_matmul(raddr_accum21_matmul),
  .raddr_accum22_matmul(raddr_accum22_matmul),
  .raddr_accum23_matmul(raddr_accum23_matmul),
  .raddr_accum24_matmul(raddr_accum24_matmul),
  .raddr_accum25_matmul(raddr_accum25_matmul),
  .raddr_accum26_matmul(raddr_accum26_matmul),
  .raddr_accum27_matmul(raddr_accum27_matmul),
  .raddr_accum28_matmul(raddr_accum28_matmul),
  .raddr_accum29_matmul(raddr_accum29_matmul),
  .raddr_accum30_matmul(raddr_accum30_matmul),
  .raddr_accum31_matmul(raddr_accum31_matmul),
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
  .rdata_accum0(rdata_accum0),
  .rdata_accum1(rdata_accum1),
  .rdata_accum2(rdata_accum2),
  .rdata_accum3(rdata_accum3),
  .rdata_accum4(rdata_accum4),
  .rdata_accum5(rdata_accum5),
  .rdata_accum6(rdata_accum6),
  .rdata_accum7(rdata_accum7),
  .rdata_accum8(rdata_accum8),
  .rdata_accum9(rdata_accum9),
  .rdata_accum10(rdata_accum10),
  .rdata_accum11(rdata_accum11),
  .rdata_accum12(rdata_accum12),
  .rdata_accum13(rdata_accum13),
  .rdata_accum14(rdata_accum14),
  .rdata_accum15(rdata_accum15),
  .rdata_accum16(rdata_accum16),
  .rdata_accum17(rdata_accum17),
  .rdata_accum18(rdata_accum18),
  .rdata_accum19(rdata_accum19),
  .rdata_accum20(rdata_accum20),
  .rdata_accum21(rdata_accum21),
  .rdata_accum22(rdata_accum22),
  .rdata_accum23(rdata_accum23),
  .rdata_accum24(rdata_accum24),
  .rdata_accum25(rdata_accum25),
  .rdata_accum26(rdata_accum26),
  .rdata_accum27(rdata_accum27),
  .rdata_accum28(rdata_accum28),
  .rdata_accum29(rdata_accum29),
  .rdata_accum30(rdata_accum30),
  .rdata_accum31(rdata_accum31),
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
  .pool31(pool31),
  `endif
);


////////////////////////////////////////////////////////////////
// Normalization module
////////////////////////////////////////////////////////////////
norm u_norm(
  .enable_norm(enable_norm),
  .enable_pool(enable_pool),
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
