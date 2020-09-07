
`timescale 1ns/1ns
`define DWIDTH 8
`define AWIDTH 10
`define MEM_SIZE 1024
`define DESIGN_SIZE 32
`define MAT_MUL_SIZE 8
`define MASK_WIDTH 8
`define LOG2_MAT_MUL_SIZE 3
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
`define REG_VALID_MASK_A_COLS_B_ROWS_ADDR 32'h54
`define REG_VALID_MASK_B_COLS_ADDR 32'h58
`define REG_MATRIX_A_STRIDE_ADDR 32'h28
`define REG_MATRIX_B_STRIDE_ADDR 32'h32
`define REG_MATRIX_C_STRIDE_ADDR 32'h36
  
/////////////////////////////////////////////////
// The 32x32 matmul definition
/////////////////////////////////////////////////


module matmul_32x32_systolic_composed_from_8x8(
  input clk,
  input reset,
  input pe_reset,
  input start_mat_mul,
  output done_mat_mul,

  input [`AWIDTH-1:0] address_mat_a,
  input [`AWIDTH-1:0] address_mat_b,
  input [`AWIDTH-1:0] address_mat_c,
  input [`ADDR_STRIDE_WIDTH-1:0] address_stride_a,
  input [`ADDR_STRIDE_WIDTH-1:0] address_stride_b,
  input [`ADDR_STRIDE_WIDTH-1:0] address_stride_c,
  
  input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_0_0,
  output [`AWIDTH-1:0] a_addr_0_0,
  input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0_0,
  output [`AWIDTH-1:0] b_addr_0_0,
  
  input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_1_0,
  output [`AWIDTH-1:0] a_addr_1_0,
  input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0_1,
  output [`AWIDTH-1:0] b_addr_0_1,
  
  input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_2_0,
  output [`AWIDTH-1:0] a_addr_2_0,
  input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0_2,
  output [`AWIDTH-1:0] b_addr_0_2,
  
  input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_3_0,
  output [`AWIDTH-1:0] a_addr_3_0,
  input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0_3,
  output [`AWIDTH-1:0] b_addr_0_3,
  
  output [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_0_3,
  output [`AWIDTH-1:0] c_addr_0_3,
  output c_data_0_3_available,
    
  output [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_1_3,
  output [`AWIDTH-1:0] c_addr_1_3,
  output c_data_1_3_available,
    
  output [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_2_3,
  output [`AWIDTH-1:0] c_addr_2_3,
  output c_data_2_3_available,
    
  output [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_3_3,
  output [`AWIDTH-1:0] c_addr_3_3,
  output c_data_3_3_available,
    
  input [`MASK_WIDTH-1:0] validity_mask_a_rows,
  input [`MASK_WIDTH-1:0] validity_mask_a_cols,
  input [`MASK_WIDTH-1:0] validity_mask_b_rows,
  input [`MASK_WIDTH-1:0] validity_mask_b_cols
);

  wire [`MASK_WIDTH-1:0] validity_mask_b_rows_NC;
  assign validity_mask_b_rows_NC = validity_mask_b_rows;
    /////////////////////////////////////////////////
  // ORing all done signals
  /////////////////////////////////////////////////
  wire done_mat_mul_0_0;
  wire done_mat_mul_0_1;
  wire done_mat_mul_0_2;
  wire done_mat_mul_0_3;
  wire done_mat_mul_1_0;
  wire done_mat_mul_1_1;
  wire done_mat_mul_1_2;
  wire done_mat_mul_1_3;
  wire done_mat_mul_2_0;
  wire done_mat_mul_2_1;
  wire done_mat_mul_2_2;
  wire done_mat_mul_2_3;
  wire done_mat_mul_3_0;
  wire done_mat_mul_3_1;
  wire done_mat_mul_3_2;
  wire done_mat_mul_3_3;

  assign done_mat_mul = done_mat_mul_0_0;  /////////////////////////////////////////////////
  // Matmul 0_0
  /////////////////////////////////////////////////

  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_0_0_to_0_1;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0_0_to_1_0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_0_0_NC;
  assign a_data_in_0_0_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in_0_0_NC;
  assign c_data_in_0_0_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_0_0_NC;
  assign b_data_in_0_0_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_0_0_to_0_1;
  wire [`AWIDTH-1:0] c_addr_0_0_NC;
  wire c_data_0_0_available_NC;

matmul_8x8_systolic u_matmul_8x8_systolic_0_0(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul_0_0),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .a_data(a_data_0_0),
  .b_data(b_data_0_0),
  .a_data_in(a_data_in_0_0_NC),
  .b_data_in(b_data_in_0_0_NC),
  .c_data_in(c_data_in_0_0_NC),
  .c_data_out(c_data_0_0_to_0_1),
  .a_data_out(a_data_0_0_to_0_1),
  .b_data_out(b_data_0_0_to_1_0),
  .a_addr(a_addr_0_0),
  .b_addr(b_addr_0_0),
  .c_addr(c_addr_0_0_NC),
  .c_data_available(c_data_0_0_available_NC),

  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd32),
  .a_loc(8'd0),
  .b_loc(8'd0)
);

  /////////////////////////////////////////////////
  // Matmul 0_1
  /////////////////////////////////////////////////

  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_0_1_to_0_2;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0_1_to_1_1;
  wire [`AWIDTH-1:0] a_addr_0_1_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_0_1_NC;
  assign a_data_0_1_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_0_1_NC;
  assign b_data_in_0_1_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_0_1_to_0_2;
  wire [`AWIDTH-1:0] c_addr_0_1_NC;
  wire c_data_0_1_available_NC;

matmul_8x8_systolic u_matmul_8x8_systolic_0_1(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul_0_1),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .a_data(a_data_0_1_NC),
  .b_data(b_data_0_1),
  .a_data_in(a_data_0_0_to_0_1),
  .b_data_in(b_data_in_0_1_NC),
  .c_data_in(c_data_0_0_to_0_1),
  .c_data_out(c_data_0_1_to_0_2),
  .a_data_out(a_data_0_1_to_0_2),
  .b_data_out(b_data_0_1_to_1_1),
  .a_addr(a_addr_0_1_NC),
  .b_addr(b_addr_0_1),
  .c_addr(c_addr_0_1_NC),
  .c_data_available(c_data_0_1_available_NC),

  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd32),
  .a_loc(8'd0),
  .b_loc(8'd1)
);

  /////////////////////////////////////////////////
  // Matmul 0_2
  /////////////////////////////////////////////////

  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_0_2_to_0_3;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0_2_to_1_2;
  wire [`AWIDTH-1:0] a_addr_0_2_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_0_2_NC;
  assign a_data_0_2_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_0_2_NC;
  assign b_data_in_0_2_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_0_2_to_0_3;
  wire [`AWIDTH-1:0] c_addr_0_2_NC;
  wire c_data_0_2_available_NC;

matmul_8x8_systolic u_matmul_8x8_systolic_0_2(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul_0_2),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .a_data(a_data_0_2_NC),
  .b_data(b_data_0_2),
  .a_data_in(a_data_0_1_to_0_2),
  .b_data_in(b_data_in_0_2_NC),
  .c_data_in(c_data_0_1_to_0_2),
  .c_data_out(c_data_0_2_to_0_3),
  .a_data_out(a_data_0_2_to_0_3),
  .b_data_out(b_data_0_2_to_1_2),
  .a_addr(a_addr_0_2_NC),
  .b_addr(b_addr_0_2),
  .c_addr(c_addr_0_2_NC),
  .c_data_available(c_data_0_2_available_NC),

  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd32),
  .a_loc(8'd0),
  .b_loc(8'd2)
);

  /////////////////////////////////////////////////
  // Matmul 0_3
  /////////////////////////////////////////////////

  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_0_3_to_0_4;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0_3_to_1_3;
  wire [`AWIDTH-1:0] a_addr_0_3_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_0_3_NC;
  assign a_data_0_3_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_0_3_NC;
  assign b_data_in_0_3_NC = 0;

matmul_8x8_systolic u_matmul_8x8_systolic_0_3(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul_0_3),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .a_data(a_data_0_3_NC),
  .b_data(b_data_0_3),
  .a_data_in(a_data_0_2_to_0_3),
  .b_data_in(b_data_in_0_3_NC),
  .c_data_in(c_data_0_2_to_0_3),
  .c_data_out(c_data_0_3),
  .a_data_out(a_data_0_3_to_0_4),
  .b_data_out(b_data_0_3_to_1_3),
  .a_addr(a_addr_0_3_NC),
  .b_addr(b_addr_0_3),
  .c_addr(c_addr_0_3),
  .c_data_available(c_data_0_3_available),

  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd32),
  .a_loc(8'd0),
  .b_loc(8'd3)
);

  /////////////////////////////////////////////////
  // Matmul 1_0
  /////////////////////////////////////////////////

  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_1_0_to_1_1;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1_0_to_2_0;
  wire [`AWIDTH-1:0] b_addr_1_0_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1_0_NC;
  assign b_data_1_0_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_1_0_NC;
  assign a_data_in_1_0_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in_1_0_NC;
  assign c_data_in_1_0_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_1_0_to_1_1;
  wire [`AWIDTH-1:0] c_addr_1_0_NC;
  wire c_data_1_0_available_NC;

matmul_8x8_systolic u_matmul_8x8_systolic_1_0(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul_1_0),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .a_data(a_data_1_0),
  .b_data(b_data_1_0_NC),
  .a_data_in(a_data_in_1_0_NC),
  .b_data_in(b_data_0_0_to_1_0),
  .c_data_in(c_data_in_1_0_NC),
  .c_data_out(c_data_1_0_to_1_1),
  .a_data_out(a_data_1_0_to_1_1),
  .b_data_out(b_data_1_0_to_2_0),
  .a_addr(a_addr_1_0),
  .b_addr(b_addr_1_0_NC),
  .c_addr(c_addr_1_0_NC),
  .c_data_available(c_data_1_0_available_NC),

  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd32),
  .a_loc(8'd1),
  .b_loc(8'd0)
);

  /////////////////////////////////////////////////
  // Matmul 1_1
  /////////////////////////////////////////////////

  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_1_1_to_1_2;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1_1_to_2_1;
  wire [`AWIDTH-1:0] a_addr_1_1_NC;
  wire [`AWIDTH-1:0] b_addr_1_1_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_1_1_NC;
  assign a_data_1_1_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1_1_NC;
  assign b_data_1_1_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_1_1_to_1_2;
  wire [`AWIDTH-1:0] c_addr_1_1_NC;
  wire c_data_1_1_available_NC;

matmul_8x8_systolic u_matmul_8x8_systolic_1_1(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul_1_1),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .a_data(a_data_1_1_NC),
  .b_data(b_data_1_1_NC),
  .a_data_in(a_data_1_0_to_1_1),
  .b_data_in(b_data_0_1_to_1_1),
  .c_data_in(c_data_1_0_to_1_1),
  .c_data_out(c_data_1_1_to_1_2),
  .a_data_out(a_data_1_1_to_1_2),
  .b_data_out(b_data_1_1_to_2_1),
  .a_addr(a_addr_1_1_NC),
  .b_addr(b_addr_1_1_NC),
  .c_addr(c_addr_1_1_NC),
  .c_data_available(c_data_1_1_available_NC),

  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd32),
  .a_loc(8'd1),
  .b_loc(8'd1)
);

  /////////////////////////////////////////////////
  // Matmul 1_2
  /////////////////////////////////////////////////

  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_1_2_to_1_3;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1_2_to_2_2;
  wire [`AWIDTH-1:0] a_addr_1_2_NC;
  wire [`AWIDTH-1:0] b_addr_1_2_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_1_2_NC;
  assign a_data_1_2_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1_2_NC;
  assign b_data_1_2_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_1_2_to_1_3;
  wire [`AWIDTH-1:0] c_addr_1_2_NC;
  wire c_data_1_2_available_NC;

matmul_8x8_systolic u_matmul_8x8_systolic_1_2(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul_1_2),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .a_data(a_data_1_2_NC),
  .b_data(b_data_1_2_NC),
  .a_data_in(a_data_1_1_to_1_2),
  .b_data_in(b_data_0_2_to_1_2),
  .c_data_in(c_data_1_1_to_1_2),
  .c_data_out(c_data_1_2_to_1_3),
  .a_data_out(a_data_1_2_to_1_3),
  .b_data_out(b_data_1_2_to_2_2),
  .a_addr(a_addr_1_2_NC),
  .b_addr(b_addr_1_2_NC),
  .c_addr(c_addr_1_2_NC),
  .c_data_available(c_data_1_2_available_NC),

  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd32),
  .a_loc(8'd1),
  .b_loc(8'd2)
);

  /////////////////////////////////////////////////
  // Matmul 1_3
  /////////////////////////////////////////////////

  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_1_3_to_1_4;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1_3_to_2_3;
  wire [`AWIDTH-1:0] a_addr_1_3_NC;
  wire [`AWIDTH-1:0] b_addr_1_3_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_1_3_NC;
  assign a_data_1_3_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1_3_NC;
  assign b_data_1_3_NC = 0;

matmul_8x8_systolic u_matmul_8x8_systolic_1_3(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul_1_3),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .a_data(a_data_1_3_NC),
  .b_data(b_data_1_3_NC),
  .a_data_in(a_data_1_2_to_1_3),
  .b_data_in(b_data_0_3_to_1_3),
  .c_data_in(c_data_1_2_to_1_3),
  .c_data_out(c_data_1_3),
  .a_data_out(a_data_1_3_to_1_4),
  .b_data_out(b_data_1_3_to_2_3),
  .a_addr(a_addr_1_3_NC),
  .b_addr(b_addr_1_3_NC),
  .c_addr(c_addr_1_3),
  .c_data_available(c_data_1_3_available),

  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd32),
  .a_loc(8'd1),
  .b_loc(8'd3)
);

  /////////////////////////////////////////////////
  // Matmul 2_0
  /////////////////////////////////////////////////

  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_2_0_to_2_1;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_2_0_to_3_0;
  wire [`AWIDTH-1:0] b_addr_2_0_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_2_0_NC;
  assign b_data_2_0_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_2_0_NC;
  assign a_data_in_2_0_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in_2_0_NC;
  assign c_data_in_2_0_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_2_0_to_2_1;
  wire [`AWIDTH-1:0] c_addr_2_0_NC;
  wire c_data_2_0_available_NC;

matmul_8x8_systolic u_matmul_8x8_systolic_2_0(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul_2_0),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .a_data(a_data_2_0),
  .b_data(b_data_2_0_NC),
  .a_data_in(a_data_in_2_0_NC),
  .b_data_in(b_data_1_0_to_2_0),
  .c_data_in(c_data_in_2_0_NC),
  .c_data_out(c_data_2_0_to_2_1),
  .a_data_out(a_data_2_0_to_2_1),
  .b_data_out(b_data_2_0_to_3_0),
  .a_addr(a_addr_2_0),
  .b_addr(b_addr_2_0_NC),
  .c_addr(c_addr_2_0_NC),
  .c_data_available(c_data_2_0_available_NC),

  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd32),
  .a_loc(8'd2),
  .b_loc(8'd0)
);

  /////////////////////////////////////////////////
  // Matmul 2_1
  /////////////////////////////////////////////////

  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_2_1_to_2_2;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_2_1_to_3_1;
  wire [`AWIDTH-1:0] a_addr_2_1_NC;
  wire [`AWIDTH-1:0] b_addr_2_1_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_2_1_NC;
  assign a_data_2_1_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_2_1_NC;
  assign b_data_2_1_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_2_1_to_2_2;
  wire [`AWIDTH-1:0] c_addr_2_1_NC;
  wire c_data_2_1_available_NC;

matmul_8x8_systolic u_matmul_8x8_systolic_2_1(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul_2_1),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .a_data(a_data_2_1_NC),
  .b_data(b_data_2_1_NC),
  .a_data_in(a_data_2_0_to_2_1),
  .b_data_in(b_data_1_1_to_2_1),
  .c_data_in(c_data_2_0_to_2_1),
  .c_data_out(c_data_2_1_to_2_2),
  .a_data_out(a_data_2_1_to_2_2),
  .b_data_out(b_data_2_1_to_3_1),
  .a_addr(a_addr_2_1_NC),
  .b_addr(b_addr_2_1_NC),
  .c_addr(c_addr_2_1_NC),
  .c_data_available(c_data_2_1_available_NC),

  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd32),
  .a_loc(8'd2),
  .b_loc(8'd1)
);

  /////////////////////////////////////////////////
  // Matmul 2_2
  /////////////////////////////////////////////////

  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_2_2_to_2_3;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_2_2_to_3_2;
  wire [`AWIDTH-1:0] a_addr_2_2_NC;
  wire [`AWIDTH-1:0] b_addr_2_2_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_2_2_NC;
  assign a_data_2_2_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_2_2_NC;
  assign b_data_2_2_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_2_2_to_2_3;
  wire [`AWIDTH-1:0] c_addr_2_2_NC;
  wire c_data_2_2_available_NC;

matmul_8x8_systolic u_matmul_8x8_systolic_2_2(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul_2_2),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .a_data(a_data_2_2_NC),
  .b_data(b_data_2_2_NC),
  .a_data_in(a_data_2_1_to_2_2),
  .b_data_in(b_data_1_2_to_2_2),
  .c_data_in(c_data_2_1_to_2_2),
  .c_data_out(c_data_2_2_to_2_3),
  .a_data_out(a_data_2_2_to_2_3),
  .b_data_out(b_data_2_2_to_3_2),
  .a_addr(a_addr_2_2_NC),
  .b_addr(b_addr_2_2_NC),
  .c_addr(c_addr_2_2_NC),
  .c_data_available(c_data_2_2_available_NC),

  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd32),
  .a_loc(8'd2),
  .b_loc(8'd2)
);

  /////////////////////////////////////////////////
  // Matmul 2_3
  /////////////////////////////////////////////////

  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_2_3_to_2_4;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_2_3_to_3_3;
  wire [`AWIDTH-1:0] a_addr_2_3_NC;
  wire [`AWIDTH-1:0] b_addr_2_3_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_2_3_NC;
  assign a_data_2_3_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_2_3_NC;
  assign b_data_2_3_NC = 0;

matmul_8x8_systolic u_matmul_8x8_systolic_2_3(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul_2_3),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .a_data(a_data_2_3_NC),
  .b_data(b_data_2_3_NC),
  .a_data_in(a_data_2_2_to_2_3),
  .b_data_in(b_data_1_3_to_2_3),
  .c_data_in(c_data_2_2_to_2_3),
  .c_data_out(c_data_2_3),
  .a_data_out(a_data_2_3_to_2_4),
  .b_data_out(b_data_2_3_to_3_3),
  .a_addr(a_addr_2_3_NC),
  .b_addr(b_addr_2_3_NC),
  .c_addr(c_addr_2_3),
  .c_data_available(c_data_2_3_available),

  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd32),
  .a_loc(8'd2),
  .b_loc(8'd3)
);

  /////////////////////////////////////////////////
  // Matmul 3_0
  /////////////////////////////////////////////////

  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_3_0_to_3_1;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_3_0_to_4_0;
  wire [`AWIDTH-1:0] b_addr_3_0_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_3_0_NC;
  assign b_data_3_0_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_3_0_NC;
  assign a_data_in_3_0_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in_3_0_NC;
  assign c_data_in_3_0_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_3_0_to_3_1;
  wire [`AWIDTH-1:0] c_addr_3_0_NC;
  wire c_data_3_0_available_NC;

matmul_8x8_systolic u_matmul_8x8_systolic_3_0(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul_3_0),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .a_data(a_data_3_0),
  .b_data(b_data_3_0_NC),
  .a_data_in(a_data_in_3_0_NC),
  .b_data_in(b_data_2_0_to_3_0),
  .c_data_in(c_data_in_3_0_NC),
  .c_data_out(c_data_3_0_to_3_1),
  .a_data_out(a_data_3_0_to_3_1),
  .b_data_out(b_data_3_0_to_4_0),
  .a_addr(a_addr_3_0),
  .b_addr(b_addr_3_0_NC),
  .c_addr(c_addr_3_0_NC),
  .c_data_available(c_data_3_0_available_NC),

  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd32),
  .a_loc(8'd3),
  .b_loc(8'd0)
);

  /////////////////////////////////////////////////
  // Matmul 3_1
  /////////////////////////////////////////////////

  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_3_1_to_3_2;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_3_1_to_4_1;
  wire [`AWIDTH-1:0] a_addr_3_1_NC;
  wire [`AWIDTH-1:0] b_addr_3_1_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_3_1_NC;
  assign a_data_3_1_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_3_1_NC;
  assign b_data_3_1_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_3_1_to_3_2;
  wire [`AWIDTH-1:0] c_addr_3_1_NC;
  wire c_data_3_1_available_NC;

matmul_8x8_systolic u_matmul_8x8_systolic_3_1(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul_3_1),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .a_data(a_data_3_1_NC),
  .b_data(b_data_3_1_NC),
  .a_data_in(a_data_3_0_to_3_1),
  .b_data_in(b_data_2_1_to_3_1),
  .c_data_in(c_data_3_0_to_3_1),
  .c_data_out(c_data_3_1_to_3_2),
  .a_data_out(a_data_3_1_to_3_2),
  .b_data_out(b_data_3_1_to_4_1),
  .a_addr(a_addr_3_1_NC),
  .b_addr(b_addr_3_1_NC),
  .c_addr(c_addr_3_1_NC),
  .c_data_available(c_data_3_1_available_NC),

  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd32),
  .a_loc(8'd3),
  .b_loc(8'd1)
);

  /////////////////////////////////////////////////
  // Matmul 3_2
  /////////////////////////////////////////////////

  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_3_2_to_3_3;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_3_2_to_4_2;
  wire [`AWIDTH-1:0] a_addr_3_2_NC;
  wire [`AWIDTH-1:0] b_addr_3_2_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_3_2_NC;
  assign a_data_3_2_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_3_2_NC;
  assign b_data_3_2_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_3_2_to_3_3;
  wire [`AWIDTH-1:0] c_addr_3_2_NC;
  wire c_data_3_2_available_NC;

matmul_8x8_systolic u_matmul_8x8_systolic_3_2(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul_3_2),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .a_data(a_data_3_2_NC),
  .b_data(b_data_3_2_NC),
  .a_data_in(a_data_3_1_to_3_2),
  .b_data_in(b_data_2_2_to_3_2),
  .c_data_in(c_data_3_1_to_3_2),
  .c_data_out(c_data_3_2_to_3_3),
  .a_data_out(a_data_3_2_to_3_3),
  .b_data_out(b_data_3_2_to_4_2),
  .a_addr(a_addr_3_2_NC),
  .b_addr(b_addr_3_2_NC),
  .c_addr(c_addr_3_2_NC),
  .c_data_available(c_data_3_2_available_NC),

  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd32),
  .a_loc(8'd3),
  .b_loc(8'd2)
);

  /////////////////////////////////////////////////
  // Matmul 3_3
  /////////////////////////////////////////////////

  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_3_3_to_3_4;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_3_3_to_4_3;
  wire [`AWIDTH-1:0] a_addr_3_3_NC;
  wire [`AWIDTH-1:0] b_addr_3_3_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_3_3_NC;
  assign a_data_3_3_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_3_3_NC;
  assign b_data_3_3_NC = 0;

matmul_8x8_systolic u_matmul_8x8_systolic_3_3(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul_3_3),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .a_data(a_data_3_3_NC),
  .b_data(b_data_3_3_NC),
  .a_data_in(a_data_3_2_to_3_3),
  .b_data_in(b_data_2_3_to_3_3),
  .c_data_in(c_data_3_2_to_3_3),
  .c_data_out(c_data_3_3),
  .a_data_out(a_data_3_3_to_3_4),
  .b_data_out(b_data_3_3_to_4_3),
  .a_addr(a_addr_3_3_NC),
  .b_addr(b_addr_3_3_NC),
  .c_addr(c_addr_3_3),
  .c_data_available(c_data_3_3_available),

  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd32),
  .a_loc(8'd3),
  .b_loc(8'd3)
);

endmodule

