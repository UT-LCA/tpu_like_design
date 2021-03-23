
`timescale 1ns/1ns
`define DWIDTH 16
`define AWIDTH 10
`define MEM_SIZE 1024
`define DESIGN_SIZE 8
`define MAT_MUL_SIZE 4
`define MASK_WIDTH 4
`define LOG2_MAT_MUL_SIZE 2
`define NUM_CYCLES_IN_MAC 3
`define MEM_ACCESS_LATENCY 1
`define REG_DATAWIDTH 32
`define REG_ADDRWIDTH 8
`define ADDR_STRIDE_WIDTH 16
`define REG_STDN_TPU_ADDR 32'h4
`define REG_MATRIX_A_ADDR 32'he
`define REG_MATRIX_B_ADDR 32'h12
`define REG_MATRIX_C_ADDR 32'h16
`define REG_VALID_MASK_A_ROWS_ADDR 32'h20
`define REG_VALID_MASK_A_COLS_ADDR 32'h54
`define REG_VALID_MASK_B_ROWS_ADDR 32'h5c
`define REG_VALID_MASK_B_COLS_ADDR 32'h58
`define REG_MATRIX_A_STRIDE_ADDR 32'h28
`define REG_MATRIX_B_STRIDE_ADDR 32'h32
`define REG_MATRIX_C_STRIDE_ADDR 32'h36
`define ADDRESS_BASE_A 10'd0
`define ADDRESS_BASE_B 10'd0
`define ADDRESS_BASE_C 10'd0
  module conv(
  input clk,
  input clk_mem,
  input resetn,
  input pe_resetn,
  input start,
  output reg done,
  input  [7:0] bram_select,
  input  [`AWIDTH-1:0] bram_addr_ext,
  output reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_ext,
  input  [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_ext,
  input  [`MAT_MUL_SIZE-1:0] bram_we_ext
);


  wire PCLK;
  assign PCLK = clk;
  //Dummy register to sync all other invalid/unimplemented addresses
  reg [`REG_DATAWIDTH-1:0] reg_dummy;

wire reset;
assign reset = ~resetn;
wire pe_reset;
assign pe_reset = ~pe_resetn;


  reg pe_reset_0;	
  reg start_mat_mul_0;
  wire done_mat_mul_0;
  reg [`AWIDTH-1:0] address_mat_a_0;
  reg [`AWIDTH-1:0] address_mat_b_0;
  reg [`AWIDTH-1:0] address_mat_c_0;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_a_0;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_b_0;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_c_0;
  wire [3:0] flags_NC_0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_0_NC;
  assign a_data_in_0_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_0_NC;
  assign b_data_in_0_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in_0_NC;
  assign c_data_in_0_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out_0_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out_0_NC;
  wire [`AWIDTH-1:0] a_addr_0;
  wire [`AWIDTH-1:0] b_addr_0;
  wire [`AWIDTH-1:0] c_addr_0;
  wire c_data_0_available;
  reg [3:0] validity_mask_a_0_rows;
  reg [3:0] validity_mask_a_0_cols;
  reg [3:0] validity_mask_b_0_rows;
  reg [3:0] validity_mask_b_0_cols;
  
  

  reg pe_reset_1;	
  reg start_mat_mul_1;
  wire done_mat_mul_1;
  reg [`AWIDTH-1:0] address_mat_a_1;
  reg [`AWIDTH-1:0] address_mat_b_1;
  reg [`AWIDTH-1:0] address_mat_c_1;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_a_1;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_b_1;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_c_1;
  wire [3:0] flags_NC_1;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_1;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_1;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_1_NC;
  assign a_data_in_1_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_1_NC;
  assign b_data_in_1_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in_1_NC;
  assign c_data_in_1_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out_1_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out_1_NC;
  wire [`AWIDTH-1:0] a_addr_1;
  wire [`AWIDTH-1:0] b_addr_1;
  wire [`AWIDTH-1:0] c_addr_1;
  wire c_data_1_available;
  reg [3:0] validity_mask_a_1_rows;
  reg [3:0] validity_mask_a_1_cols;
  reg [3:0] validity_mask_b_1_rows;
  reg [3:0] validity_mask_b_1_cols;
  
  

  reg pe_reset_2;	
  reg start_mat_mul_2;
  wire done_mat_mul_2;
  reg [`AWIDTH-1:0] address_mat_a_2;
  reg [`AWIDTH-1:0] address_mat_b_2;
  reg [`AWIDTH-1:0] address_mat_c_2;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_a_2;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_b_2;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_c_2;
  wire [3:0] flags_NC_2;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_2;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_2;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_2;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_2_NC;
  assign a_data_in_2_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_2_NC;
  assign b_data_in_2_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in_2_NC;
  assign c_data_in_2_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out_2_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out_2_NC;
  wire [`AWIDTH-1:0] a_addr_2;
  wire [`AWIDTH-1:0] b_addr_2;
  wire [`AWIDTH-1:0] c_addr_2;
  wire c_data_2_available;
  reg [3:0] validity_mask_a_2_rows;
  reg [3:0] validity_mask_a_2_cols;
  reg [3:0] validity_mask_b_2_rows;
  reg [3:0] validity_mask_b_2_cols;
  
  

  reg pe_reset_3;	
  reg start_mat_mul_3;
  wire done_mat_mul_3;
  reg [`AWIDTH-1:0] address_mat_a_3;
  reg [`AWIDTH-1:0] address_mat_b_3;
  reg [`AWIDTH-1:0] address_mat_c_3;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_a_3;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_b_3;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_c_3;
  wire [3:0] flags_NC_3;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_3;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_3;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_3;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_3_NC;
  assign a_data_in_3_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_3_NC;
  assign b_data_in_3_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in_3_NC;
  assign c_data_in_3_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out_3_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out_3_NC;
  wire [`AWIDTH-1:0] a_addr_3;
  wire [`AWIDTH-1:0] b_addr_3;
  wire [`AWIDTH-1:0] c_addr_3;
  wire c_data_3_available;
  reg [3:0] validity_mask_a_3_rows;
  reg [3:0] validity_mask_a_3_cols;
  reg [3:0] validity_mask_b_3_rows;
  reg [3:0] validity_mask_b_3_cols;
  
  

  reg pe_reset_4;	
  reg start_mat_mul_4;
  wire done_mat_mul_4;
  reg [`AWIDTH-1:0] address_mat_a_4;
  reg [`AWIDTH-1:0] address_mat_b_4;
  reg [`AWIDTH-1:0] address_mat_c_4;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_a_4;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_b_4;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_c_4;
  wire [3:0] flags_NC_4;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_4;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_4;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_4;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_4_NC;
  assign a_data_in_4_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_4_NC;
  assign b_data_in_4_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in_4_NC;
  assign c_data_in_4_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out_4_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out_4_NC;
  wire [`AWIDTH-1:0] a_addr_4;
  wire [`AWIDTH-1:0] b_addr_4;
  wire [`AWIDTH-1:0] c_addr_4;
  wire c_data_4_available;
  reg [3:0] validity_mask_a_4_rows;
  reg [3:0] validity_mask_a_4_cols;
  reg [3:0] validity_mask_b_4_rows;
  reg [3:0] validity_mask_b_4_cols;
  
  

  reg pe_reset_5;	
  reg start_mat_mul_5;
  wire done_mat_mul_5;
  reg [`AWIDTH-1:0] address_mat_a_5;
  reg [`AWIDTH-1:0] address_mat_b_5;
  reg [`AWIDTH-1:0] address_mat_c_5;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_a_5;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_b_5;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_c_5;
  wire [3:0] flags_NC_5;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_5;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_5;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_5;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_5_NC;
  assign a_data_in_5_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_5_NC;
  assign b_data_in_5_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in_5_NC;
  assign c_data_in_5_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out_5_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out_5_NC;
  wire [`AWIDTH-1:0] a_addr_5;
  wire [`AWIDTH-1:0] b_addr_5;
  wire [`AWIDTH-1:0] c_addr_5;
  wire c_data_5_available;
  reg [3:0] validity_mask_a_5_rows;
  reg [3:0] validity_mask_a_5_cols;
  reg [3:0] validity_mask_b_5_rows;
  reg [3:0] validity_mask_b_5_cols;
  
  

  reg pe_reset_6;	
  reg start_mat_mul_6;
  wire done_mat_mul_6;
  reg [`AWIDTH-1:0] address_mat_a_6;
  reg [`AWIDTH-1:0] address_mat_b_6;
  reg [`AWIDTH-1:0] address_mat_c_6;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_a_6;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_b_6;
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_c_6;
  wire [3:0] flags_NC_6;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_6;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_6;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_6;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_6_NC;
  assign a_data_in_6_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_6_NC;
  assign b_data_in_6_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in_6_NC;
  assign c_data_in_6_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out_6_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out_6_NC;
  wire [`AWIDTH-1:0] a_addr_6;
  wire [`AWIDTH-1:0] b_addr_6;
  wire [`AWIDTH-1:0] c_addr_6;
  wire c_data_6_available;
  reg [3:0] validity_mask_a_6_rows;
  reg [3:0] validity_mask_a_6_cols;
  reg [3:0] validity_mask_b_6_rows;
  reg [3:0] validity_mask_b_6_cols;
  
  

    reg [`AWIDTH-1:0] bram_addr_a_0_ext;
    wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_0_ext;
    reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_0_ext;
    reg [`MASK_WIDTH-1:0] bram_we_a_0_ext;
    
	  wire [`AWIDTH-1:0] bram_addr_a_0;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_0;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_0;
	  wire [`MASK_WIDTH-1:0] bram_we_a_0;
	  wire bram_en_a_0;

    reg [`AWIDTH-1:0] bram_addr_b_0_ext;
    wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_0_ext;
    reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_0_ext;
    reg [`MASK_WIDTH-1:0] bram_we_b_0_ext;
    
	  wire [`AWIDTH-1:0] bram_addr_b_0;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_0;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_0;
	  wire [`MASK_WIDTH-1:0] bram_we_b_0;
	  wire bram_en_b_0;

    

    reg [`AWIDTH-1:0] bram_addr_a_1_ext;
    wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_1_ext;
    reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_1_ext;
    reg [`MASK_WIDTH-1:0] bram_we_a_1_ext;
    
	  wire [`AWIDTH-1:0] bram_addr_a_1;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_1;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_1;
	  wire [`MASK_WIDTH-1:0] bram_we_a_1;
	  wire bram_en_a_1;

    reg [`AWIDTH-1:0] bram_addr_b_1_ext;
    wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_1_ext;
    reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_1_ext;
    reg [`MASK_WIDTH-1:0] bram_we_b_1_ext;
    
	  wire [`AWIDTH-1:0] bram_addr_b_1;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_1;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_1;
	  wire [`MASK_WIDTH-1:0] bram_we_b_1;
	  wire bram_en_b_1;

    

    reg [`AWIDTH-1:0] bram_addr_a_2_ext;
    wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_2_ext;
    reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_2_ext;
    reg [`MASK_WIDTH-1:0] bram_we_a_2_ext;
    
	  wire [`AWIDTH-1:0] bram_addr_a_2;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_2;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_2;
	  wire [`MASK_WIDTH-1:0] bram_we_a_2;
	  wire bram_en_a_2;

    reg [`AWIDTH-1:0] bram_addr_b_2_ext;
    wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_2_ext;
    reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_2_ext;
    reg [`MASK_WIDTH-1:0] bram_we_b_2_ext;
    
	  wire [`AWIDTH-1:0] bram_addr_b_2;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_2;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_2;
	  wire [`MASK_WIDTH-1:0] bram_we_b_2;
	  wire bram_en_b_2;

    

    reg [`AWIDTH-1:0] bram_addr_a_3_ext;
    wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_3_ext;
    reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_3_ext;
    reg [`MASK_WIDTH-1:0] bram_we_a_3_ext;
    
	  wire [`AWIDTH-1:0] bram_addr_a_3;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_3;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_3;
	  wire [`MASK_WIDTH-1:0] bram_we_a_3;
	  wire bram_en_a_3;

    reg [`AWIDTH-1:0] bram_addr_b_3_ext;
    wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_3_ext;
    reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_3_ext;
    reg [`MASK_WIDTH-1:0] bram_we_b_3_ext;
    
	  wire [`AWIDTH-1:0] bram_addr_b_3;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_3;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_3;
	  wire [`MASK_WIDTH-1:0] bram_we_b_3;
	  wire bram_en_b_3;

    

    reg [`AWIDTH-1:0] bram_addr_a_4_ext;
    wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_4_ext;
    reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_4_ext;
    reg [`MASK_WIDTH-1:0] bram_we_a_4_ext;
    
	  wire [`AWIDTH-1:0] bram_addr_a_4;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_4;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_4;
	  wire [`MASK_WIDTH-1:0] bram_we_a_4;
	  wire bram_en_a_4;

    reg [`AWIDTH-1:0] bram_addr_b_4_ext;
    wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_4_ext;
    reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_4_ext;
    reg [`MASK_WIDTH-1:0] bram_we_b_4_ext;
    
	  wire [`AWIDTH-1:0] bram_addr_b_4;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_4;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_4;
	  wire [`MASK_WIDTH-1:0] bram_we_b_4;
	  wire bram_en_b_4;

    

    reg [`AWIDTH-1:0] bram_addr_a_5_ext;
    wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_5_ext;
    reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_5_ext;
    reg [`MASK_WIDTH-1:0] bram_we_a_5_ext;
    
	  wire [`AWIDTH-1:0] bram_addr_a_5;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_5;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_5;
	  wire [`MASK_WIDTH-1:0] bram_we_a_5;
	  wire bram_en_a_5;

    reg [`AWIDTH-1:0] bram_addr_b_5_ext;
    wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_5_ext;
    reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_5_ext;
    reg [`MASK_WIDTH-1:0] bram_we_b_5_ext;
    
	  wire [`AWIDTH-1:0] bram_addr_b_5;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_5;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_5;
	  wire [`MASK_WIDTH-1:0] bram_we_b_5;
	  wire bram_en_b_5;

    

    reg [`AWIDTH-1:0] bram_addr_a_6_ext;
    wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_6_ext;
    reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_6_ext;
    reg [`MASK_WIDTH-1:0] bram_we_a_6_ext;
    
	  wire [`AWIDTH-1:0] bram_addr_a_6;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_6;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_6;
	  wire [`MASK_WIDTH-1:0] bram_we_a_6;
	  wire bram_en_a_6;

    reg [`AWIDTH-1:0] bram_addr_b_6_ext;
    wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_6_ext;
    reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_6_ext;
    reg [`MASK_WIDTH-1:0] bram_we_b_6_ext;
    
	  wire [`AWIDTH-1:0] bram_addr_b_6;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_6;
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_6;
	  wire [`MASK_WIDTH-1:0] bram_we_b_6;
	  wire bram_en_b_6;

    

  always @* begin
    case (bram_select)


      0: begin
      bram_addr_a_0_ext = bram_addr_ext;
      bram_wdata_a_0_ext = bram_wdata_ext;
      bram_we_a_0_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_0_ext;
      end
    

      1: begin
      bram_addr_b_0_ext = bram_addr_ext;
      bram_wdata_b_0_ext = bram_wdata_ext;
      bram_we_b_0_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_0_ext;
      end
    

      2: begin
      bram_addr_a_1_ext = bram_addr_ext;
      bram_wdata_a_1_ext = bram_wdata_ext;
      bram_we_a_1_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_1_ext;
      end
    

      3: begin
      bram_addr_b_1_ext = bram_addr_ext;
      bram_wdata_b_1_ext = bram_wdata_ext;
      bram_we_b_1_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_1_ext;
      end
    

      4: begin
      bram_addr_a_2_ext = bram_addr_ext;
      bram_wdata_a_2_ext = bram_wdata_ext;
      bram_we_a_2_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_2_ext;
      end
    

      5: begin
      bram_addr_b_2_ext = bram_addr_ext;
      bram_wdata_b_2_ext = bram_wdata_ext;
      bram_we_b_2_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_2_ext;
      end
    

      6: begin
      bram_addr_a_3_ext = bram_addr_ext;
      bram_wdata_a_3_ext = bram_wdata_ext;
      bram_we_a_3_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_3_ext;
      end
    

      7: begin
      bram_addr_b_3_ext = bram_addr_ext;
      bram_wdata_b_3_ext = bram_wdata_ext;
      bram_we_b_3_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_3_ext;
      end
    

      8: begin
      bram_addr_a_4_ext = bram_addr_ext;
      bram_wdata_a_4_ext = bram_wdata_ext;
      bram_we_a_4_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_4_ext;
      end
    

      9: begin
      bram_addr_b_4_ext = bram_addr_ext;
      bram_wdata_b_4_ext = bram_wdata_ext;
      bram_we_b_4_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_4_ext;
      end
    

      10: begin
      bram_addr_a_5_ext = bram_addr_ext;
      bram_wdata_a_5_ext = bram_wdata_ext;
      bram_we_a_5_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_5_ext;
      end
    

      11: begin
      bram_addr_b_5_ext = bram_addr_ext;
      bram_wdata_b_5_ext = bram_wdata_ext;
      bram_we_b_5_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_5_ext;
      end
    

      12: begin
      bram_addr_a_6_ext = bram_addr_ext;
      bram_wdata_a_6_ext = bram_wdata_ext;
      bram_we_a_6_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_6_ext;
      end
    

      13: begin
      bram_addr_b_6_ext = bram_addr_ext;
      bram_wdata_b_6_ext = bram_wdata_ext;
      bram_we_b_6_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_6_ext;
      end
    

      default: begin
      bram_rdata_ext = 0;
      end
    endcase 
  end
   

  ram matrix_A_0(
    .addr0(bram_addr_a_0),
    .d0(bram_wdata_a_0), 
    .we0(bram_we_a_0), 
    .q0(a_data_0), 
    .addr1(bram_addr_a_0_ext),
    .d1(bram_wdata_a_0_ext), 
    .we1(bram_we_a_0_ext), 
    .q1(bram_rdata_a_0_ext), 
    .clk(clk_mem));

  ram matrix_B_0(
    .addr0(b_addr_0),
    .d0(bram_wdata_b_0), 
    .we0(bram_we_b_0), 
    .q0(b_data_0), 
    .addr1(bram_addr_b_0_ext),
    .d1(bram_wdata_b_0_ext), 
    .we1(bram_we_b_0_ext), 
    .q1(bram_rdata_b_0_ext), 
    .clk(clk_mem));

    

  ram matrix_A_1(
    .addr0(bram_addr_a_1),
    .d0(bram_wdata_a_1), 
    .we0(bram_we_a_1), 
    .q0(a_data_1), 
    .addr1(bram_addr_a_1_ext),
    .d1(bram_wdata_a_1_ext), 
    .we1(bram_we_a_1_ext), 
    .q1(bram_rdata_a_1_ext), 
    .clk(clk_mem));

  ram matrix_B_1(
    .addr0(b_addr_1),
    .d0(bram_wdata_b_1), 
    .we0(bram_we_b_1), 
    .q0(b_data_1), 
    .addr1(bram_addr_b_1_ext),
    .d1(bram_wdata_b_1_ext), 
    .we1(bram_we_b_1_ext), 
    .q1(bram_rdata_b_1_ext), 
    .clk(clk_mem));

    

  ram matrix_A_2(
    .addr0(bram_addr_a_2),
    .d0(bram_wdata_a_2), 
    .we0(bram_we_a_2), 
    .q0(a_data_2), 
    .addr1(bram_addr_a_2_ext),
    .d1(bram_wdata_a_2_ext), 
    .we1(bram_we_a_2_ext), 
    .q1(bram_rdata_a_2_ext), 
    .clk(clk_mem));

  ram matrix_B_2(
    .addr0(b_addr_2),
    .d0(bram_wdata_b_2), 
    .we0(bram_we_b_2), 
    .q0(b_data_2), 
    .addr1(bram_addr_b_2_ext),
    .d1(bram_wdata_b_2_ext), 
    .we1(bram_we_b_2_ext), 
    .q1(bram_rdata_b_2_ext), 
    .clk(clk_mem));

    

  ram matrix_A_3(
    .addr0(bram_addr_a_3),
    .d0(bram_wdata_a_3), 
    .we0(bram_we_a_3), 
    .q0(a_data_3), 
    .addr1(bram_addr_a_3_ext),
    .d1(bram_wdata_a_3_ext), 
    .we1(bram_we_a_3_ext), 
    .q1(bram_rdata_a_3_ext), 
    .clk(clk_mem));

  ram matrix_B_3(
    .addr0(b_addr_3),
    .d0(bram_wdata_b_3), 
    .we0(bram_we_b_3), 
    .q0(b_data_3), 
    .addr1(bram_addr_b_3_ext),
    .d1(bram_wdata_b_3_ext), 
    .we1(bram_we_b_3_ext), 
    .q1(bram_rdata_b_3_ext), 
    .clk(clk_mem));

    

  ram matrix_A_4(
    .addr0(bram_addr_a_4),
    .d0(bram_wdata_a_4), 
    .we0(bram_we_a_4), 
    .q0(a_data_4), 
    .addr1(bram_addr_a_4_ext),
    .d1(bram_wdata_a_4_ext), 
    .we1(bram_we_a_4_ext), 
    .q1(bram_rdata_a_4_ext), 
    .clk(clk_mem));

  ram matrix_B_4(
    .addr0(b_addr_4),
    .d0(bram_wdata_b_4), 
    .we0(bram_we_b_4), 
    .q0(b_data_4), 
    .addr1(bram_addr_b_4_ext),
    .d1(bram_wdata_b_4_ext), 
    .we1(bram_we_b_4_ext), 
    .q1(bram_rdata_b_4_ext), 
    .clk(clk_mem));

    

  ram matrix_A_5(
    .addr0(bram_addr_a_5),
    .d0(bram_wdata_a_5), 
    .we0(bram_we_a_5), 
    .q0(a_data_5), 
    .addr1(bram_addr_a_5_ext),
    .d1(bram_wdata_a_5_ext), 
    .we1(bram_we_a_5_ext), 
    .q1(bram_rdata_a_5_ext), 
    .clk(clk_mem));

  ram matrix_B_5(
    .addr0(b_addr_5),
    .d0(bram_wdata_b_5), 
    .we0(bram_we_b_5), 
    .q0(b_data_5), 
    .addr1(bram_addr_b_5_ext),
    .d1(bram_wdata_b_5_ext), 
    .we1(bram_we_b_5_ext), 
    .q1(bram_rdata_b_5_ext), 
    .clk(clk_mem));

    

  ram matrix_A_6(
    .addr0(bram_addr_a_6),
    .d0(bram_wdata_a_6), 
    .we0(bram_we_a_6), 
    .q0(a_data_6), 
    .addr1(bram_addr_a_6_ext),
    .d1(bram_wdata_a_6_ext), 
    .we1(bram_we_a_6_ext), 
    .q1(bram_rdata_a_6_ext), 
    .clk(clk_mem));

  ram matrix_B_6(
    .addr0(b_addr_6),
    .d0(bram_wdata_b_6), 
    .we0(bram_we_b_6), 
    .q0(b_data_6), 
    .addr1(bram_addr_b_6_ext),
    .d1(bram_wdata_b_6_ext), 
    .we1(bram_we_b_6_ext), 
    .q1(bram_rdata_b_6_ext), 
    .clk(clk_mem));

    


  assign bram_wdata_a_0 = c_data_0;
  assign bram_en_a_0 = 1'b1;
  assign bram_we_a_0 = (c_data_0_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  
  assign bram_addr_a_0 = (c_data_0_available) ? c_addr_0 : a_addr_0;

  assign bram_wdata_b_0 = {`MAT_MUL_SIZE*`DWIDTH{1'b0}};
  assign bram_en_b_0 = 1'b1;
  assign bram_we_b_0 = {`MASK_WIDTH{1'b0}};
  


  assign bram_wdata_a_1 = c_data_1;
  assign bram_en_a_1 = 1'b1;
  assign bram_we_a_1 = (c_data_1_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  
  assign bram_addr_a_1 = (c_data_1_available) ? c_addr_1 : a_addr_1;

  assign bram_wdata_b_1 = {`MAT_MUL_SIZE*`DWIDTH{1'b0}};
  assign bram_en_b_1 = 1'b1;
  assign bram_we_b_1 = {`MASK_WIDTH{1'b0}};
  


  assign bram_wdata_a_2 = c_data_2;
  assign bram_en_a_2 = 1'b1;
  assign bram_we_a_2 = (c_data_2_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  
  assign bram_addr_a_2 = (c_data_2_available) ? c_addr_2 : a_addr_2;

  assign bram_wdata_b_2 = {`MAT_MUL_SIZE*`DWIDTH{1'b0}};
  assign bram_en_b_2 = 1'b1;
  assign bram_we_b_2 = {`MASK_WIDTH{1'b0}};
  


  assign bram_wdata_a_3 = c_data_3;
  assign bram_en_a_3 = 1'b1;
  assign bram_we_a_3 = (c_data_3_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  
  assign bram_addr_a_3 = (c_data_3_available) ? c_addr_3 : a_addr_3;

  assign bram_wdata_b_3 = {`MAT_MUL_SIZE*`DWIDTH{1'b0}};
  assign bram_en_b_3 = 1'b1;
  assign bram_we_b_3 = {`MASK_WIDTH{1'b0}};
  


  assign bram_wdata_a_4 = c_data_4;
  assign bram_en_a_4 = 1'b1;
  assign bram_we_a_4 = (c_data_4_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  
  assign bram_addr_a_4 = (c_data_4_available) ? c_addr_4 : a_addr_4;

  assign bram_wdata_b_4 = {`MAT_MUL_SIZE*`DWIDTH{1'b0}};
  assign bram_en_b_4 = 1'b1;
  assign bram_we_b_4 = {`MASK_WIDTH{1'b0}};
  


  assign bram_wdata_a_5 = c_data_5;
  assign bram_en_a_5 = 1'b1;
  assign bram_we_a_5 = (c_data_5_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  
  assign bram_addr_a_5 = (c_data_5_available) ? c_addr_5 : a_addr_5;

  assign bram_wdata_b_5 = {`MAT_MUL_SIZE*`DWIDTH{1'b0}};
  assign bram_en_b_5 = 1'b1;
  assign bram_we_b_5 = {`MASK_WIDTH{1'b0}};
  


  assign bram_wdata_a_6 = c_data_6;
  assign bram_en_a_6 = 1'b1;
  assign bram_we_a_6 = (c_data_6_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  
  assign bram_addr_a_6 = (c_data_6_available) ? c_addr_6 : a_addr_6;

  assign bram_wdata_b_6 = {`MAT_MUL_SIZE*`DWIDTH{1'b0}};
  assign bram_en_b_6 = 1'b1;
  assign bram_we_b_6 = {`MASK_WIDTH{1'b0}};
  

wire done_mat_mul;
assign done_mat_mul = 
done_mat_mul_0 &
done_mat_mul_1 &
done_mat_mul_2 &
done_mat_mul_3 &
done_mat_mul_4 &
done_mat_mul_5 &
done_mat_mul_6;

wire done_eltwise_add_phase_1;
wire done_eltwise_add_phase_2;
wire done_eltwise_add_phase_3;
assign done_eltwise_add_phase_1 = done_mat_mul_4 & done_mat_mul_5 & done_mat_mul_6;
assign done_eltwise_add_phase_2 = done_mat_mul_5 & done_mat_mul_6;
assign done_eltwise_add_phase_3 = done_mat_mul_6;



reg [1:0] slice_0_op;
    

reg [1:0] slice_1_op;
    

reg [1:0] slice_2_op;
    

reg [1:0] slice_3_op;
    

reg [1:0] slice_4_op;
    

reg [1:0] slice_5_op;
    

reg [1:0] slice_6_op;
    

reg [3:0] count;
reg [4:0] state;
reg [4:0] vertical_count;

	always @( posedge clk) begin
      if (resetn == 1'b0) begin
        state <= 5'd0;
        done <= 0;
        

      slice_0_op <= 0;
      start_mat_mul_0 <= 0;
      address_mat_a_0 <= 0;
      address_mat_b_0 <= 0;
      address_mat_c_0 <= 0;
      address_stride_a_0 <= 0;
      address_stride_b_0 <= 0;
      address_stride_c_0 <= 0;
      validity_mask_a_0_rows <= 0;
      validity_mask_a_0_cols <= 0;
      validity_mask_b_0_rows <= 0;
      validity_mask_b_0_cols <= 0;
    

      slice_1_op <= 0;
      start_mat_mul_1 <= 0;
      address_mat_a_1 <= 0;
      address_mat_b_1 <= 0;
      address_mat_c_1 <= 0;
      address_stride_a_1 <= 0;
      address_stride_b_1 <= 0;
      address_stride_c_1 <= 0;
      validity_mask_a_1_rows <= 0;
      validity_mask_a_1_cols <= 0;
      validity_mask_b_1_rows <= 0;
      validity_mask_b_1_cols <= 0;
    

      slice_2_op <= 0;
      start_mat_mul_2 <= 0;
      address_mat_a_2 <= 0;
      address_mat_b_2 <= 0;
      address_mat_c_2 <= 0;
      address_stride_a_2 <= 0;
      address_stride_b_2 <= 0;
      address_stride_c_2 <= 0;
      validity_mask_a_2_rows <= 0;
      validity_mask_a_2_cols <= 0;
      validity_mask_b_2_rows <= 0;
      validity_mask_b_2_cols <= 0;
    

      slice_3_op <= 0;
      start_mat_mul_3 <= 0;
      address_mat_a_3 <= 0;
      address_mat_b_3 <= 0;
      address_mat_c_3 <= 0;
      address_stride_a_3 <= 0;
      address_stride_b_3 <= 0;
      address_stride_c_3 <= 0;
      validity_mask_a_3_rows <= 0;
      validity_mask_a_3_cols <= 0;
      validity_mask_b_3_rows <= 0;
      validity_mask_b_3_cols <= 0;
    

      slice_4_op <= 0;
      start_mat_mul_4 <= 0;
      address_mat_a_4 <= 0;
      address_mat_b_4 <= 0;
      address_mat_c_4 <= 0;
      address_stride_a_4 <= 0;
      address_stride_b_4 <= 0;
      address_stride_c_4 <= 0;
      validity_mask_a_4_rows <= 0;
      validity_mask_a_4_cols <= 0;
      validity_mask_b_4_rows <= 0;
      validity_mask_b_4_cols <= 0;
    

      slice_5_op <= 0;
      start_mat_mul_5 <= 0;
      address_mat_a_5 <= 0;
      address_mat_b_5 <= 0;
      address_mat_c_5 <= 0;
      address_stride_a_5 <= 0;
      address_stride_b_5 <= 0;
      address_stride_c_5 <= 0;
      validity_mask_a_5_rows <= 0;
      validity_mask_a_5_cols <= 0;
      validity_mask_b_5_rows <= 0;
      validity_mask_b_5_cols <= 0;
    

      slice_6_op <= 0;
      start_mat_mul_6 <= 0;
      address_mat_a_6 <= 0;
      address_mat_b_6 <= 0;
      address_mat_c_6 <= 0;
      address_stride_a_6 <= 0;
      address_stride_b_6 <= 0;
      address_stride_c_6 <= 0;
      validity_mask_a_6_rows <= 0;
      validity_mask_a_6_cols <= 0;
      validity_mask_b_6_rows <= 0;
      validity_mask_b_6_cols <= 0;
    

        count <= 0;
        vertical_count <= 0;
      end 
      else begin
        case (state)
        5'd0: begin
        
start_mat_mul_0 <= 1'b0;
start_mat_mul_1 <= 1'b0;
start_mat_mul_2 <= 1'b0;
start_mat_mul_3 <= 1'b0;
start_mat_mul_4 <= 1'b0;
start_mat_mul_5 <= 1'b0;
start_mat_mul_6 <= 1'b0;

          if (start== 1'b1) begin
            count <= 4'd1;
            vertical_count <= 5'd1;
            state <= 5'd1;
            done <= 0;
          end 
        end


    5'd1: begin


      slice_0_op <= 2'b00;
      start_mat_mul_0 <= 1'b1;
      address_mat_a_0 <=  vertical_count + `ADDRESS_BASE_A +10'd0; //will change horizontally
      address_mat_b_0 <=  vertical_count + `ADDRESS_BASE_B +10'd0; //will change horizontally
      address_mat_c_0 <=  vertical_count + `ADDRESS_BASE_A +10'd192; //will stay constant horizontally
      //if (count==4'd4) begin
      // address_stride_a_0 <= 16'd8;
      //end else begin
        address_stride_a_0 <= 16'd1; 
      //end
      address_stride_b_0 <= 16'd3; //constant horiz
      address_stride_c_0 <= 16'd64; //constant horiz
      validity_mask_a_0_rows <= 4'b1111; //constant
      validity_mask_a_0_cols <= 4'b1111; //constant
      validity_mask_b_0_rows <= 4'b1111; //constant
      validity_mask_b_0_cols <= 4'b0111; //constant
      

      slice_1_op <= 2'b00;
      start_mat_mul_1 <= 1'b1;
      address_mat_a_1 <=  vertical_count + `ADDRESS_BASE_A +10'd11; //will change horizontally
      address_mat_b_1 <=  vertical_count + `ADDRESS_BASE_B +10'd12; //will change horizontally
      address_mat_c_1 <=  vertical_count + `ADDRESS_BASE_A +10'd192; //will stay constant horizontally
      //if (count==4'd4) begin
      // address_stride_a_1 <= 16'd8;
      //end else begin
        address_stride_a_1 <= 16'd1; 
      //end
      address_stride_b_1 <= 16'd3; //constant horiz
      address_stride_c_1 <= 16'd64; //constant horiz
      validity_mask_a_1_rows <= 4'b1111; //constant
      validity_mask_a_1_cols <= 4'b1111; //constant
      validity_mask_b_1_rows <= 4'b1111; //constant
      validity_mask_b_1_cols <= 4'b0111; //constant
      

      slice_2_op <= 2'b00;
      start_mat_mul_2 <= 1'b1;
      address_mat_a_2 <=  vertical_count + `ADDRESS_BASE_A +10'd22; //will change horizontally
      address_mat_b_2 <=  vertical_count + `ADDRESS_BASE_B +10'd24; //will change horizontally
      address_mat_c_2 <=  vertical_count + `ADDRESS_BASE_A +10'd192; //will stay constant horizontally
      //if (count==4'd4) begin
      // address_stride_a_2 <= 16'd8;
      //end else begin
        address_stride_a_2 <= 16'd1; 
      //end
      address_stride_b_2 <= 16'd3; //constant horiz
      address_stride_c_2 <= 16'd64; //constant horiz
      validity_mask_a_2_rows <= 4'b1111; //constant
      validity_mask_a_2_cols <= 4'b1111; //constant
      validity_mask_b_2_rows <= 4'b1111; //constant
      validity_mask_b_2_cols <= 4'b0111; //constant
      

      slice_3_op <= 2'b00;
      start_mat_mul_3 <= 1'b1;
      address_mat_a_3 <=  vertical_count + `ADDRESS_BASE_A +10'd33; //will change horizontally
      address_mat_b_3 <=  vertical_count + `ADDRESS_BASE_B +10'd36; //will change horizontally
      address_mat_c_3 <=  vertical_count + `ADDRESS_BASE_A +10'd192; //will stay constant horizontally
      //if (count==4'd4) begin
      // address_stride_a_3 <= 16'd8;
      //end else begin
        address_stride_a_3 <= 16'd1; 
      //end
      address_stride_b_3 <= 16'd3; //constant horiz
      address_stride_c_3 <= 16'd64; //constant horiz
      validity_mask_a_3_rows <= 4'b1111; //constant
      validity_mask_a_3_cols <= 4'b1111; //constant
      validity_mask_b_3_rows <= 4'b1111; //constant
      validity_mask_b_3_cols <= 4'b0111; //constant
      

      slice_4_op <= 2'b00;
      start_mat_mul_4 <= 1'b1;
      address_mat_a_4 <=  vertical_count + `ADDRESS_BASE_A +10'd44; //will change horizontally
      address_mat_b_4 <=  vertical_count + `ADDRESS_BASE_B +10'd48; //will change horizontally
      address_mat_c_4 <=  vertical_count + `ADDRESS_BASE_A +10'd192; //will stay constant horizontally
      //if (count==4'd4) begin
      // address_stride_a_4 <= 16'd8;
      //end else begin
        address_stride_a_4 <= 16'd1; 
      //end
      address_stride_b_4 <= 16'd3; //constant horiz
      address_stride_c_4 <= 16'd64; //constant horiz
      validity_mask_a_4_rows <= 4'b1111; //constant
      validity_mask_a_4_cols <= 4'b1111; //constant
      validity_mask_b_4_rows <= 4'b1111; //constant
      validity_mask_b_4_cols <= 4'b0111; //constant
      

      slice_5_op <= 2'b00;
      start_mat_mul_5 <= 1'b1;
      address_mat_a_5 <=  vertical_count + `ADDRESS_BASE_A +10'd55; //will change horizontally
      address_mat_b_5 <=  vertical_count + `ADDRESS_BASE_B +10'd60; //will change horizontally
      address_mat_c_5 <=  vertical_count + `ADDRESS_BASE_A +10'd192; //will stay constant horizontally
      //if (count==4'd4) begin
      // address_stride_a_5 <= 16'd8;
      //end else begin
        address_stride_a_5 <= 16'd1; 
      //end
      address_stride_b_5 <= 16'd3; //constant horiz
      address_stride_c_5 <= 16'd64; //constant horiz
      validity_mask_a_5_rows <= 4'b1111; //constant
      validity_mask_a_5_cols <= 4'b1111; //constant
      validity_mask_b_5_rows <= 4'b1111; //constant
      validity_mask_b_5_cols <= 4'b0111; //constant
      

      slice_6_op <= 2'b00;
      start_mat_mul_6 <= 1'b1;
      address_mat_a_6 <=  vertical_count + `ADDRESS_BASE_A +10'd66; //will change horizontally
      address_mat_b_6 <=  vertical_count + `ADDRESS_BASE_B +10'd72; //will change horizontally
      address_mat_c_6 <=  vertical_count + `ADDRESS_BASE_A +10'd192; //will stay constant horizontally
      //if (count==4'd4) begin
      // address_stride_a_6 <= 16'd8;
      //end else begin
        address_stride_a_6 <= 16'd1; 
      //end
      address_stride_b_6 <= 16'd3; //constant horiz
      address_stride_c_6 <= 16'd64; //constant horiz
      validity_mask_a_6_rows <= 4'b1111; //constant
      validity_mask_a_6_cols <= 4'b1111; //constant
      validity_mask_b_6_rows <= 4'b1111; //constant
      validity_mask_b_6_cols <= 4'b0111; //constant
      

  count <= count + 1;

  if (done_mat_mul == 1'b1) begin
    state <= 5'd2;


  end
end


    5'd2: begin
    count <= 4'b0;


    start_mat_mul_0 <= 1'b0;

    start_mat_mul_1 <= 1'b0;

    start_mat_mul_2 <= 1'b0;

    start_mat_mul_3 <= 1'b0;

    start_mat_mul_4 <= 1'b0;

    start_mat_mul_5 <= 1'b0;

    start_mat_mul_6 <= 1'b0;

    state <= 5'd3;
  end


    5'd3: begin


      slice_4_op <= 2'b10;
      start_mat_mul_4 <= 1'b1;
      address_mat_a_4 <= vertical_count + `ADDRESS_BASE_A + 10'd192; //will stay constant horizontally
      address_mat_b_4 <= vertical_count + `ADDRESS_BASE_A +  10'd192; //will stay constant horizontally
      address_mat_c_4 <= vertical_count + `ADDRESS_BASE_A + 10'd512; //will stay constant horizontally
      address_stride_a_4 <= 16'd64;
      address_stride_b_4 <= 16'd64;
      address_stride_c_4 <= 16'd64; 
      validity_mask_a_4_rows <= 4'b1111; //constant
      validity_mask_a_4_cols <= 4'b1111; //constant
      validity_mask_b_4_rows <= 4'b1111; //constant
      validity_mask_b_4_cols <= 4'b0111; //constant
    

      slice_5_op <= 2'b10;
      start_mat_mul_5 <= 1'b1;
      address_mat_a_5 <= vertical_count + `ADDRESS_BASE_A + 10'd192; //will stay constant horizontally
      address_mat_b_5 <= vertical_count + `ADDRESS_BASE_A +  10'd192; //will stay constant horizontally
      address_mat_c_5 <= vertical_count + `ADDRESS_BASE_A + 10'd512; //will stay constant horizontally
      address_stride_a_5 <= 16'd64;
      address_stride_b_5 <= 16'd64;
      address_stride_c_5 <= 16'd64; 
      validity_mask_a_5_rows <= 4'b1111; //constant
      validity_mask_a_5_cols <= 4'b1111; //constant
      validity_mask_b_5_rows <= 4'b1111; //constant
      validity_mask_b_5_cols <= 4'b0111; //constant
    

      slice_6_op <= 2'b10;
      start_mat_mul_6 <= 1'b1;
      address_mat_a_6 <= vertical_count + `ADDRESS_BASE_A + 10'd192; //will stay constant horizontally
      address_mat_b_6 <= vertical_count + `ADDRESS_BASE_A +  10'd192; //will stay constant horizontally
      address_mat_c_6 <= vertical_count + `ADDRESS_BASE_A + 10'd512; //will stay constant horizontally
      address_stride_a_6 <= 16'd64;
      address_stride_b_6 <= 16'd64;
      address_stride_c_6 <= 16'd64; 
      validity_mask_a_6_rows <= 4'b1111; //constant
      validity_mask_a_6_cols <= 4'b1111; //constant
      validity_mask_b_6_rows <= 4'b1111; //constant
      validity_mask_b_6_cols <= 4'b0111; //constant
    

      if (done_eltwise_add_phase_1 == 1'b1) begin
        state <= 5'd4;
      end


end
    5'd4: begin
        start_mat_mul_4 <= 1'b0;
        start_mat_mul_5 <= 1'b0;
        start_mat_mul_6 <= 1'b0;
        state <= 5'd5;


end
    5'd5: begin


      slice_5_op <= 2'b10;
      start_mat_mul_5 <= 1'b1;
      address_mat_a_5 <= vertical_count + `ADDRESS_BASE_A + 10'd512; //will stay constant horizontally
      address_mat_b_5 <= vertical_count + `ADDRESS_BASE_A +  10'd512; //will stay constant horizontally
      address_mat_c_5 <= vertical_count + `ADDRESS_BASE_A + 10'd768; //will stay constant horizontally
      address_stride_a_5 <= 16'd64;
      address_stride_b_5 <= 16'd64;
      address_stride_c_5 <= 16'd64; 
      validity_mask_a_5_rows <= 4'b1111; //constant
      validity_mask_a_5_cols <= 4'b1111; //constant
      validity_mask_b_5_rows <= 4'b1111; //constant
      validity_mask_b_5_cols <= 4'b0111; //constant
    

      slice_6_op <= 2'b10;
      start_mat_mul_6 <= 1'b1;
      address_mat_a_6 <= vertical_count + `ADDRESS_BASE_A + 10'd512; //will stay constant horizontally
      address_mat_b_6 <= vertical_count + `ADDRESS_BASE_A +  10'd512; //will stay constant horizontally
      address_mat_c_6 <= vertical_count + `ADDRESS_BASE_A + 10'd768; //will stay constant horizontally
      address_stride_a_6 <= 16'd64;
      address_stride_b_6 <= 16'd64;
      address_stride_c_6 <= 16'd64; 
      validity_mask_a_6_rows <= 4'b1111; //constant
      validity_mask_a_6_cols <= 4'b1111; //constant
      validity_mask_b_6_rows <= 4'b1111; //constant
      validity_mask_b_6_cols <= 4'b0111; //constant
    

      if (done_eltwise_add_phase_2 == 1'b1) begin
        state <= 5'd6;
      end


end
    5'd6: begin
        state <= 5'd7;
        start_mat_mul_5 <= 1'b0;
        start_mat_mul_6 <= 1'b0;


end
    5'd7: begin


      slice_6_op <= 2'b10;
      start_mat_mul_6 <= 1'b1;
      address_mat_a_6 <= vertical_count + `ADDRESS_BASE_A + 10'd768; //will stay constant horizontally
      address_mat_b_6 <= vertical_count + `ADDRESS_BASE_A +  10'd768; //will stay constant horizontally
      address_mat_c_6 <= vertical_count + `ADDRESS_BASE_A + 10'd900; //will stay constant horizontally
      address_stride_a_6 <= 16'd64;
      address_stride_b_6 <= 16'd64;
      address_stride_c_6 <= 16'd64; 
      validity_mask_a_6_rows <= 4'b1111; //constant
      validity_mask_a_6_cols <= 4'b1111; //constant
      validity_mask_b_6_rows <= 4'b1111; //constant
      validity_mask_b_6_cols <= 4'b0111; //constant
    

      if (done_eltwise_add_phase_3 == 1'b1) begin
        state <= 5'd8;
      end
end


    5'd8: begin
        state <= 5'd9;
        start_mat_mul_6 <= 1'b0;
end


    5'd9: begin
    if (vertical_count == 5'd16) begin
      done <= 1'b1;
      state <= 5'd0;
    end 
    else begin
      vertical_count <= vertical_count + 1;
      state <= 5'd1;
    end
    end
  
endcase
end
end


    matmul_slice u_matmul_4x4_systolic_0(
      .clk(clk),
      .reset(reset),
      .pe_reset(pe_reset),
      .start_mat_mul(start_mat_mul_0),
      .done_mat_mul(done_mat_mul_0),
      .address_mat_a(address_mat_a_0),
      .address_mat_b(address_mat_b_0),
      .address_mat_c(address_mat_c_0),
      .address_stride_a(address_stride_a_0),
      .address_stride_b(address_stride_b_0),
      .address_stride_c(address_stride_c_0),
      .a_data(a_data_0),
      .b_data(b_data_0),
      .a_data_in(a_data_in_0_NC),
      .b_data_in(b_data_in_0_NC),
      .c_data_in(c_data_in_0_NC),
      .c_data_out(c_data_0),
      .a_data_out(a_data_out_0_NC),
      .b_data_out(b_data_out_0_NC),
      .a_addr(a_addr_0),
      .b_addr(b_addr_0),
      .c_addr(c_addr_0),
      .c_data_available(c_data_0_available),
      .flags(flags_NC_0),
      .validity_mask_a_rows({4'b0,validity_mask_a_0_rows}),
      .validity_mask_a_cols({4'b0,validity_mask_a_0_cols}),
      .validity_mask_b_rows({4'b0,validity_mask_b_0_rows}),
      .validity_mask_b_cols({4'b0,validity_mask_b_0_cols}),
      .slice_mode(1'b0), //0 is SLICE_MODE_MATMUL
      .slice_dtype(1'b1), //1 is FP16
      .op(slice_0_op), 
      .preload(1'b0),
      .final_mat_mul_size(8'd4),
      .a_loc(8'd0),
      .b_loc(8'd0)
    );
    
    

    matmul_slice u_matmul_4x4_systolic_1(
      .clk(clk),
      .reset(reset),
      .pe_reset(pe_reset),
      .start_mat_mul(start_mat_mul_1),
      .done_mat_mul(done_mat_mul_1),
      .address_mat_a(address_mat_a_1),
      .address_mat_b(address_mat_b_1),
      .address_mat_c(address_mat_c_1),
      .address_stride_a(address_stride_a_1),
      .address_stride_b(address_stride_b_1),
      .address_stride_c(address_stride_c_1),
      .a_data(a_data_1),
      .b_data(b_data_1),
      .a_data_in(a_data_in_1_NC),
      .b_data_in(b_data_in_1_NC),
      .c_data_in(c_data_in_1_NC),
      .c_data_out(c_data_1),
      .a_data_out(a_data_out_1_NC),
      .b_data_out(b_data_out_1_NC),
      .a_addr(a_addr_1),
      .b_addr(b_addr_1),
      .c_addr(c_addr_1),
      .c_data_available(c_data_1_available),
      .flags(flags_NC_1),
      .validity_mask_a_rows({4'b0,validity_mask_a_1_rows}),
      .validity_mask_a_cols({4'b0,validity_mask_a_1_cols}),
      .validity_mask_b_rows({4'b0,validity_mask_b_1_rows}),
      .validity_mask_b_cols({4'b0,validity_mask_b_1_cols}),
      .slice_mode(1'b0), //0 is SLICE_MODE_MATMUL
      .slice_dtype(1'b1), //1 is FP16
      .op(slice_1_op), 
      .preload(1'b0),
      .final_mat_mul_size(8'd4),
      .a_loc(8'd0),
      .b_loc(8'd0)
    );
    
    

    matmul_slice u_matmul_4x4_systolic_2(
      .clk(clk),
      .reset(reset),
      .pe_reset(pe_reset),
      .start_mat_mul(start_mat_mul_2),
      .done_mat_mul(done_mat_mul_2),
      .address_mat_a(address_mat_a_2),
      .address_mat_b(address_mat_b_2),
      .address_mat_c(address_mat_c_2),
      .address_stride_a(address_stride_a_2),
      .address_stride_b(address_stride_b_2),
      .address_stride_c(address_stride_c_2),
      .a_data(a_data_2),
      .b_data(b_data_2),
      .a_data_in(a_data_in_2_NC),
      .b_data_in(b_data_in_2_NC),
      .c_data_in(c_data_in_2_NC),
      .c_data_out(c_data_2),
      .a_data_out(a_data_out_2_NC),
      .b_data_out(b_data_out_2_NC),
      .a_addr(a_addr_2),
      .b_addr(b_addr_2),
      .c_addr(c_addr_2),
      .c_data_available(c_data_2_available),
      .flags(flags_NC_2),
      .validity_mask_a_rows({4'b0,validity_mask_a_2_rows}),
      .validity_mask_a_cols({4'b0,validity_mask_a_2_cols}),
      .validity_mask_b_rows({4'b0,validity_mask_b_2_rows}),
      .validity_mask_b_cols({4'b0,validity_mask_b_2_cols}),
      .slice_mode(1'b0), //0 is SLICE_MODE_MATMUL
      .slice_dtype(1'b1), //1 is FP16
      .op(slice_2_op), 
      .preload(1'b0),
      .final_mat_mul_size(8'd4),
      .a_loc(8'd0),
      .b_loc(8'd0)
    );
    
    

    matmul_slice u_matmul_4x4_systolic_3(
      .clk(clk),
      .reset(reset),
      .pe_reset(pe_reset),
      .start_mat_mul(start_mat_mul_3),
      .done_mat_mul(done_mat_mul_3),
      .address_mat_a(address_mat_a_3),
      .address_mat_b(address_mat_b_3),
      .address_mat_c(address_mat_c_3),
      .address_stride_a(address_stride_a_3),
      .address_stride_b(address_stride_b_3),
      .address_stride_c(address_stride_c_3),
      .a_data(a_data_3),
      .b_data(b_data_3),
      .a_data_in(a_data_in_3_NC),
      .b_data_in(b_data_in_3_NC),
      .c_data_in(c_data_in_3_NC),
      .c_data_out(c_data_3),
      .a_data_out(a_data_out_3_NC),
      .b_data_out(b_data_out_3_NC),
      .a_addr(a_addr_3),
      .b_addr(b_addr_3),
      .c_addr(c_addr_3),
      .c_data_available(c_data_3_available),
      .flags(flags_NC_3),
      .validity_mask_a_rows({4'b0,validity_mask_a_3_rows}),
      .validity_mask_a_cols({4'b0,validity_mask_a_3_cols}),
      .validity_mask_b_rows({4'b0,validity_mask_b_3_rows}),
      .validity_mask_b_cols({4'b0,validity_mask_b_3_cols}),
      .slice_mode(1'b0), //0 is SLICE_MODE_MATMUL
      .slice_dtype(1'b1), //1 is FP16
      .op(slice_3_op), 
      .preload(1'b0),
      .final_mat_mul_size(8'd4),
      .a_loc(8'd0),
      .b_loc(8'd0)
    );
    
    

    matmul_slice u_matmul_4x4_systolic_4(
      .clk(clk),
      .reset(reset),
      .pe_reset(pe_reset),
      .start_mat_mul(start_mat_mul_4),
      .done_mat_mul(done_mat_mul_4),
      .address_mat_a(address_mat_a_4),
      .address_mat_b(address_mat_b_4),
      .address_mat_c(address_mat_c_4),
      .address_stride_a(address_stride_a_4),
      .address_stride_b(address_stride_b_4),
      .address_stride_c(address_stride_c_4),
      .a_data(a_data_4),
      .b_data(b_data_4),
      .a_data_in(a_data_in_4_NC),
      .b_data_in(b_data_in_4_NC),
      .c_data_in(c_data_in_4_NC),
      .c_data_out(c_data_4),
      .a_data_out(a_data_out_4_NC),
      .b_data_out(b_data_out_4_NC),
      .a_addr(a_addr_4),
      .b_addr(b_addr_4),
      .c_addr(c_addr_4),
      .c_data_available(c_data_4_available),
      .flags(flags_NC_4),
      .validity_mask_a_rows({4'b0,validity_mask_a_4_rows}),
      .validity_mask_a_cols({4'b0,validity_mask_a_4_cols}),
      .validity_mask_b_rows({4'b0,validity_mask_b_4_rows}),
      .validity_mask_b_cols({4'b0,validity_mask_b_4_cols}),
      .slice_mode(1'b0), //0 is SLICE_MODE_MATMUL
      .slice_dtype(1'b1), //1 is FP16
      .op(slice_4_op), 
      .preload(1'b0),
      .final_mat_mul_size(8'd4),
      .a_loc(8'd0),
      .b_loc(8'd0)
    );
    
    

    matmul_slice u_matmul_4x4_systolic_5(
      .clk(clk),
      .reset(reset),
      .pe_reset(pe_reset),
      .start_mat_mul(start_mat_mul_5),
      .done_mat_mul(done_mat_mul_5),
      .address_mat_a(address_mat_a_5),
      .address_mat_b(address_mat_b_5),
      .address_mat_c(address_mat_c_5),
      .address_stride_a(address_stride_a_5),
      .address_stride_b(address_stride_b_5),
      .address_stride_c(address_stride_c_5),
      .a_data(a_data_5),
      .b_data(b_data_5),
      .a_data_in(a_data_in_5_NC),
      .b_data_in(b_data_in_5_NC),
      .c_data_in(c_data_in_5_NC),
      .c_data_out(c_data_5),
      .a_data_out(a_data_out_5_NC),
      .b_data_out(b_data_out_5_NC),
      .a_addr(a_addr_5),
      .b_addr(b_addr_5),
      .c_addr(c_addr_5),
      .c_data_available(c_data_5_available),
      .flags(flags_NC_5),
      .validity_mask_a_rows({4'b0,validity_mask_a_5_rows}),
      .validity_mask_a_cols({4'b0,validity_mask_a_5_cols}),
      .validity_mask_b_rows({4'b0,validity_mask_b_5_rows}),
      .validity_mask_b_cols({4'b0,validity_mask_b_5_cols}),
      .slice_mode(1'b0), //0 is SLICE_MODE_MATMUL
      .slice_dtype(1'b1), //1 is FP16
      .op(slice_5_op), 
      .preload(1'b0),
      .final_mat_mul_size(8'd4),
      .a_loc(8'd0),
      .b_loc(8'd0)
    );
    
    

    matmul_slice u_matmul_4x4_systolic_6(
      .clk(clk),
      .reset(reset),
      .pe_reset(pe_reset),
      .start_mat_mul(start_mat_mul_6),
      .done_mat_mul(done_mat_mul_6),
      .address_mat_a(address_mat_a_6),
      .address_mat_b(address_mat_b_6),
      .address_mat_c(address_mat_c_6),
      .address_stride_a(address_stride_a_6),
      .address_stride_b(address_stride_b_6),
      .address_stride_c(address_stride_c_6),
      .a_data(a_data_6),
      .b_data(b_data_6),
      .a_data_in(a_data_in_6_NC),
      .b_data_in(b_data_in_6_NC),
      .c_data_in(c_data_in_6_NC),
      .c_data_out(c_data_6),
      .a_data_out(a_data_out_6_NC),
      .b_data_out(b_data_out_6_NC),
      .a_addr(a_addr_6),
      .b_addr(b_addr_6),
      .c_addr(c_addr_6),
      .c_data_available(c_data_6_available),
      .flags(flags_NC_6),
      .validity_mask_a_rows({4'b0,validity_mask_a_6_rows}),
      .validity_mask_a_cols({4'b0,validity_mask_a_6_cols}),
      .validity_mask_b_rows({4'b0,validity_mask_b_6_rows}),
      .validity_mask_b_cols({4'b0,validity_mask_b_6_cols}),
      .slice_mode(1'b0), //0 is SLICE_MODE_MATMUL
      .slice_dtype(1'b1), //1 is FP16
      .op(slice_6_op), 
      .preload(1'b0),
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
input [`MAT_MUL_SIZE*`DWIDTH-1:0] d0;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] d1;
input [`MAT_MUL_SIZE-1:0] we0;
input [`MAT_MUL_SIZE-1:0] we1;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] q0;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] q1;
input clk;

`ifdef SYNTHESIS
reg [`MAT_MUL_SIZE*`DWIDTH-1:0] q0;
reg [`MAT_MUL_SIZE*`DWIDTH-1:0] q1;
reg [`DWIDTH-1:0] ram[((1<<`AWIDTH)-1):0];
integer i;

always @(posedge clk)  
begin 
    for (i = 0; i < `MAT_MUL_SIZE; i=i+1) begin
        if (we0[i]) ram[addr0+i] <= d0[i*`DWIDTH +: `DWIDTH]; 
    end    
    for (i = 0; i < `MAT_MUL_SIZE; i=i+1) begin
        q0[i*`DWIDTH +: `DWIDTH] <= ram[addr0+i];
    end    
end

always @(posedge clk)  
begin 
    for (i = 0; i < `MAT_MUL_SIZE; i=i+1) begin
        if (we1[i]) ram[addr0+i] <= d1[i*`DWIDTH +: `DWIDTH]; 
    end    
    for (i = 0; i < `MAT_MUL_SIZE; i=i+1) begin
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

  
    
    
