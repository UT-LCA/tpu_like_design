
`timescale 1ns/1ns
///////////////////////////////////////////////////////////
//Eltwise layer
///////////////////////////////////////////////////////////
//Each PE has 1 multiplier, an adder and a subtractor.
//There are 4 PEs in each compute unit. 
//There are 6 such compute units in the whole layer.
//So, total compute throughput is 24 ops per cycle.
//The "per cycle" is because the adder/sub/mul are
//pipelined. Although they may be take more than 1 cycle,
//but in the steady state, one result will come out every cycle.
//
//There are 6 BRAMs for each input operand. Each location in a BRAM
//stores 4 inputs. So, the read bandwidth is 24 elements
//per cycle. This matches the compute throughput. So, we
//utilize each PE every cycle. There are 6 BRAMs for output.
//We can write 4 elements per cycle.
//
//There are two modes of operation: 
// 1. Vector/Matrix mode
//    In this mode, both operands are matrices/vectors.
//    They are read from BRAMs (A and B). The operation 
//    selected (using the op input) is performed. This mode
//    can be used for operations such as residual add, or 
//    dropout.
// 2. Scalar mode
//    In this mode, one operand is a matrix/vector and the
//    other operand is a scalar. It could be the mean or 
//    variance of a normalization layer for example. The 
//    scalar input is provided from the top-level of the design
//    so it can be easily modified at runtime.
//
//Important inputs:
//   mode: 
//      0 -> Both operands (A and B) are matrices/vectors. Result is a matrix/vector.
//      1 -> Operand A is matrix/vector. Operand B is scalar. Result is a matrix/vector.
//   op:
//      00 -> Addition
//      01 -> Subtraction
//      10 -> Multiplication
//
//The whole design can operate on 24xN matrices.  
//Typically, to use this design, we'd break a large input
//matrix into 24 column sections and process the matrix 
//section by section. The number of rows will be programmed
//in the "iterations" register in the design.

`define DWIDTH 16
`define AWIDTH 10
`define MEM_SIZE 1024
`define DESIGN_SIZE 12
`define CU_SIZE 4
`define MASK_WIDTH 4
`define MEM_ACCESS_LATENCY 1

`define REG_DATAWIDTH 32
`define REG_ADDRWIDTH 8
`define ITERATIONS_WIDTH 32

`define REG_STDN_ADDR 32'h4
`define REG_MATRIX_A_ADDR 32'he
`define REG_MATRIX_B_ADDR 32'h12
`define REG_MATRIX_C_ADDR 32'h16
`define REG_VALID_MASK_A_ADDR 32'h20
`define REG_VALID_MASK_B_ADDR 32'h5c

`define REG_ITERATIONS_ADDR 32'h40

//This is the pipeline depth of the PEs (adder/mult)
`define PE_PIPELINE_DEPTH 2

  module eltwise_layer(
  input clk,
  input clk_mem,
  input resetn,
  input pe_resetn,
  input        [`REG_ADDRWIDTH-1:0] PADDR,
  input                             PWRITE,
  input                             PSEL,
  input                             PENABLE,
  input        [`REG_DATAWIDTH-1:0] PWDATA,
  output reg   [`REG_DATAWIDTH-1:0] PRDATA,
  output reg                        PREADY,
  input [`DWIDTH-1:0] scalar_inp,
  input mode, // mode==0 -> vector/matrix, mode==1 -> scalar
  input  [1:0] op, //op==11 -> Mul, op==01 -> Sub, op==00 -> Add
  input  [7:0] bram_select,
  input  [`AWIDTH-1:0] bram_addr_ext,
  output reg [`CU_SIZE*`DWIDTH-1:0] bram_rdata_ext,
  input  [`CU_SIZE*`DWIDTH-1:0] bram_wdata_ext,
  input  [`CU_SIZE-1:0] bram_we_ext
);


  wire PCLK;
  assign PCLK = clk;
  wire PRESETn;
  assign PRESETn = resetn;
  reg start_reg;
  reg clear_done_reg;

  //Dummy register to sync all other invalid/unimplemented addresses
  reg [`REG_DATAWIDTH-1:0] reg_dummy;
  
  reg [`AWIDTH-1:0] bram_addr_a_0_ext;
  wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_a_0_ext;
  reg [`CU_SIZE*`DWIDTH-1:0] bram_wdata_a_0_ext;
  reg [`MASK_WIDTH-1:0] bram_we_a_0_ext;
    
  reg [`AWIDTH-1:0] bram_addr_a_2_ext;
  wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_a_2_ext;
  reg [`CU_SIZE*`DWIDTH-1:0] bram_wdata_a_2_ext;
  reg [`MASK_WIDTH-1:0] bram_we_a_2_ext;
    
  reg [`AWIDTH-1:0] bram_addr_a_4_ext;
  wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_a_4_ext;
  reg [`CU_SIZE*`DWIDTH-1:0] bram_wdata_a_4_ext;
  reg [`MASK_WIDTH-1:0] bram_we_a_4_ext;

  reg [`AWIDTH-1:0] bram_addr_a_1_ext;
  wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_a_1_ext;
  reg [`CU_SIZE*`DWIDTH-1:0] bram_wdata_a_1_ext;
  reg [`MASK_WIDTH-1:0] bram_we_a_1_ext;
    
  reg [`AWIDTH-1:0] bram_addr_a_3_ext;
  wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_a_3_ext;
  reg [`CU_SIZE*`DWIDTH-1:0] bram_wdata_a_3_ext;
  reg [`MASK_WIDTH-1:0] bram_we_a_3_ext;
    
  reg [`AWIDTH-1:0] bram_addr_a_5_ext;
  wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_a_5_ext;
  reg [`CU_SIZE*`DWIDTH-1:0] bram_wdata_a_5_ext;
  reg [`MASK_WIDTH-1:0] bram_we_a_5_ext;

    
  reg [`AWIDTH-1:0] bram_addr_b_0_ext;
  wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_b_0_ext;
  reg [`CU_SIZE*`DWIDTH-1:0] bram_wdata_b_0_ext;
  reg [`MASK_WIDTH-1:0] bram_we_b_0_ext;
    
  reg [`AWIDTH-1:0] bram_addr_b_1_ext;
  wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_b_1_ext;
  reg [`CU_SIZE*`DWIDTH-1:0] bram_wdata_b_1_ext;
  reg [`MASK_WIDTH-1:0] bram_we_b_1_ext;
    
  reg [`AWIDTH-1:0] bram_addr_b_2_ext;
  wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_b_2_ext;
  reg [`CU_SIZE*`DWIDTH-1:0] bram_wdata_b_2_ext;
  reg [`MASK_WIDTH-1:0] bram_we_b_2_ext;
    
  reg [`AWIDTH-1:0] bram_addr_b_3_ext;
  wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_b_3_ext;
  reg [`CU_SIZE*`DWIDTH-1:0] bram_wdata_b_3_ext;
  reg [`MASK_WIDTH-1:0] bram_we_b_3_ext;
    
  reg [`AWIDTH-1:0] bram_addr_b_4_ext;
  wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_b_4_ext;
  reg [`CU_SIZE*`DWIDTH-1:0] bram_wdata_b_4_ext;
  reg [`MASK_WIDTH-1:0] bram_we_b_4_ext;
    
  reg [`AWIDTH-1:0] bram_addr_b_5_ext;
  wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_b_5_ext;
  reg [`CU_SIZE*`DWIDTH-1:0] bram_wdata_b_5_ext;
  reg [`MASK_WIDTH-1:0] bram_we_b_5_ext;

  reg [`AWIDTH-1:0] bram_addr_c_0_ext;
  wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_c_0_ext;
  reg [`CU_SIZE*`DWIDTH-1:0] bram_wdata_c_0_ext;
  reg [`MASK_WIDTH-1:0] bram_we_c_0_ext;
    
  reg [`AWIDTH-1:0] bram_addr_c_1_ext;
  wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_c_1_ext;
  reg [`CU_SIZE*`DWIDTH-1:0] bram_wdata_c_1_ext;
  reg [`MASK_WIDTH-1:0] bram_we_c_1_ext;
    
  reg [`AWIDTH-1:0] bram_addr_c_2_ext;
  wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_c_2_ext;
  reg [`CU_SIZE*`DWIDTH-1:0] bram_wdata_c_2_ext;
  reg [`MASK_WIDTH-1:0] bram_we_c_2_ext;
    
  reg [`AWIDTH-1:0] bram_addr_c_3_ext;
  wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_c_3_ext;
  reg [`CU_SIZE*`DWIDTH-1:0] bram_wdata_c_3_ext;
  reg [`MASK_WIDTH-1:0] bram_we_c_3_ext;
    
  reg [`AWIDTH-1:0] bram_addr_c_4_ext;
  wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_c_4_ext;
  reg [`CU_SIZE*`DWIDTH-1:0] bram_wdata_c_4_ext;
  reg [`MASK_WIDTH-1:0] bram_we_c_4_ext;
    
  reg [`AWIDTH-1:0] bram_addr_c_5_ext;
  wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_c_5_ext;
  reg [`CU_SIZE*`DWIDTH-1:0] bram_wdata_c_5_ext;
  reg [`MASK_WIDTH-1:0] bram_we_c_5_ext;
    
	wire [`AWIDTH-1:0] bram_addr_a_0;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_a_0;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_wdata_a_0;
	wire [`MASK_WIDTH-1:0] bram_we_a_0;
	wire bram_en_a_0;
    
	wire [`AWIDTH-1:0] bram_addr_a_2;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_a_2;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_wdata_a_2;
	wire [`MASK_WIDTH-1:0] bram_we_a_2;
	wire bram_en_a_2;
    
	wire [`AWIDTH-1:0] bram_addr_a_4;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_a_4;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_wdata_a_4;
	wire [`MASK_WIDTH-1:0] bram_we_a_4;
	wire bram_en_a_4;

	wire [`AWIDTH-1:0] bram_addr_a_1;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_a_1;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_wdata_a_1;
	wire [`MASK_WIDTH-1:0] bram_we_a_1;
	wire bram_en_a_1;
    
	wire [`AWIDTH-1:0] bram_addr_a_3;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_a_3;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_wdata_a_3;
	wire [`MASK_WIDTH-1:0] bram_we_a_3;
	wire bram_en_a_3;
    
	wire [`AWIDTH-1:0] bram_addr_a_5;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_a_5;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_wdata_a_5;
	wire [`MASK_WIDTH-1:0] bram_we_a_5;
	wire bram_en_a_5;
    
	wire [`AWIDTH-1:0] bram_addr_b_0;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_b_0;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_wdata_b_0;
	wire [`MASK_WIDTH-1:0] bram_we_b_0;
	wire bram_en_b_0;
    
	wire [`AWIDTH-1:0] bram_addr_b_1;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_b_1;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_wdata_b_1;
	wire [`MASK_WIDTH-1:0] bram_we_b_1;
	wire bram_en_b_1;
    
	wire [`AWIDTH-1:0] bram_addr_b_2;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_b_2;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_wdata_b_2;
	wire [`MASK_WIDTH-1:0] bram_we_b_2;
	wire bram_en_b_2;
    
	wire [`AWIDTH-1:0] bram_addr_b_3;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_b_3;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_wdata_b_3;
	wire [`MASK_WIDTH-1:0] bram_we_b_3;
	wire bram_en_b_3;

  wire [`AWIDTH-1:0] bram_addr_b_4;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_b_4;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_wdata_b_4;
	wire [`MASK_WIDTH-1:0] bram_we_b_4;
	wire bram_en_b_4;
    
	wire [`AWIDTH-1:0] bram_addr_b_5;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_b_5;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_wdata_b_5;
	wire [`MASK_WIDTH-1:0] bram_we_b_5;
	wire bram_en_b_5;

	wire [`AWIDTH-1:0] bram_addr_c_0;
	wire [`AWIDTH-1:0] bram_addr_c_1;
	wire [`AWIDTH-1:0] bram_addr_c_2;
	wire [`AWIDTH-1:0] bram_addr_c_3;
	wire [`AWIDTH-1:0] bram_addr_c_4;
	wire [`AWIDTH-1:0] bram_addr_c_5;

	wire [`CU_SIZE*`DWIDTH-1:0] bram_wdata_c_0;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_wdata_c_1;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_wdata_c_2;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_wdata_c_3;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_wdata_c_4;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_wdata_c_5;

	wire [`MASK_WIDTH-1:0] bram_we_c_0;
	wire [`MASK_WIDTH-1:0] bram_we_c_1;
	wire [`MASK_WIDTH-1:0] bram_we_c_2;
	wire [`MASK_WIDTH-1:0] bram_we_c_3;
	wire [`MASK_WIDTH-1:0] bram_we_c_4;
	wire [`MASK_WIDTH-1:0] bram_we_c_5;
    
	wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_c_0;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_c_1;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_c_2;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_c_3;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_c_4;
	wire [`CU_SIZE*`DWIDTH-1:0] bram_rdata_c_5;

  always @* begin
    case (bram_select)
  
      0: begin
      bram_addr_a_0_ext = bram_addr_ext;
      bram_wdata_a_0_ext = bram_wdata_ext;
      bram_we_a_0_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_0_ext;
      end
    
      1: begin
      bram_addr_a_2_ext = bram_addr_ext;
      bram_wdata_a_2_ext = bram_wdata_ext;
      bram_we_a_2_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_2_ext;
      end
    
      2: begin
      bram_addr_a_4_ext = bram_addr_ext;
      bram_wdata_a_4_ext = bram_wdata_ext;
      bram_we_a_4_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_4_ext;
      end

      3: begin
      bram_addr_a_1_ext = bram_addr_ext;
      bram_wdata_a_1_ext = bram_wdata_ext;
      bram_we_a_1_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_1_ext;
      end
    
      4: begin
      bram_addr_a_3_ext = bram_addr_ext;
      bram_wdata_a_3_ext = bram_wdata_ext;
      bram_we_a_3_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_3_ext;
      end
    
      5: begin
      bram_addr_a_5_ext = bram_addr_ext;
      bram_wdata_a_5_ext = bram_wdata_ext;
      bram_we_a_5_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_5_ext;
      end
    
      6: begin
      bram_addr_b_0_ext = bram_addr_ext;
      bram_wdata_b_0_ext = bram_wdata_ext;
      bram_we_b_0_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_0_ext;
      end
    
      7: begin
      bram_addr_b_1_ext = bram_addr_ext;
      bram_wdata_b_1_ext = bram_wdata_ext;
      bram_we_b_1_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_1_ext;
      end
    
      8: begin
      bram_addr_b_2_ext = bram_addr_ext;
      bram_wdata_b_2_ext = bram_wdata_ext;
      bram_we_b_2_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_2_ext;
      end
    
      9: begin
      bram_addr_b_3_ext = bram_addr_ext;
      bram_wdata_b_3_ext = bram_wdata_ext;
      bram_we_b_3_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_3_ext;
      end
    
      10: begin
      bram_addr_b_4_ext = bram_addr_ext;
      bram_wdata_b_4_ext = bram_wdata_ext;
      bram_we_b_4_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_4_ext;
      end
    
      11: begin
      bram_addr_b_5_ext = bram_addr_ext;
      bram_wdata_b_5_ext = bram_wdata_ext;
      bram_we_b_5_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_5_ext;
      end

      12: begin
      bram_addr_c_0_ext = bram_addr_ext;
      bram_wdata_c_0_ext = bram_wdata_ext;
      bram_we_c_0_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_c_0_ext;
      end
    
      13: begin
      bram_addr_c_1_ext = bram_addr_ext;
      bram_wdata_c_1_ext = bram_wdata_ext;
      bram_we_c_1_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_c_1_ext;
      end
    
      14: begin
      bram_addr_c_2_ext = bram_addr_ext;
      bram_wdata_c_2_ext = bram_wdata_ext;
      bram_we_c_2_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_c_2_ext;
      end
    
      15: begin
      bram_addr_c_3_ext = bram_addr_ext;
      bram_wdata_c_3_ext = bram_wdata_ext;
      bram_we_c_3_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_c_3_ext;
      end
    
      16: begin
      bram_addr_c_4_ext = bram_addr_ext;
      bram_wdata_c_4_ext = bram_wdata_ext;
      bram_we_c_4_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_c_4_ext;
      end
    
      17: begin
      bram_addr_c_5_ext = bram_addr_ext;
      bram_wdata_c_5_ext = bram_wdata_ext;
      bram_we_c_5_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_c_5_ext;
      end
    
      default: begin
      bram_rdata_ext = 0;
      end
    endcase 
  end
  
/////////////////////////////////////////////////
// BRAMs to store matrix A
/////////////////////////////////////////////////


  // BRAM matrix A 0
ram matrix_A_0(
  .addr0(bram_addr_a_0),
  .d0(bram_wdata_a_0), 
  .we0(bram_we_a_0), 
  .q0(bram_rdata_a_0), 
  .addr1(bram_addr_a_0_ext),
  .d1(bram_wdata_a_0_ext), 
  .we1(bram_we_a_0_ext), 
  .q1(bram_rdata_a_0_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix A 2
ram matrix_A_2(
  .addr0(bram_addr_a_2),
  .d0(bram_wdata_a_2), 
  .we0(bram_we_a_2), 
  .q0(bram_rdata_a_2), 
  .addr1(bram_addr_a_2_ext),
  .d1(bram_wdata_a_2_ext), 
  .we1(bram_we_a_2_ext), 
  .q1(bram_rdata_a_2_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix A 4
ram matrix_A_4(
  .addr0(bram_addr_a_4),
  .d0(bram_wdata_a_4), 
  .we0(bram_we_a_4), 
  .q0(bram_rdata_a_4), 
  .addr1(bram_addr_a_4_ext),
  .d1(bram_wdata_a_4_ext), 
  .we1(bram_we_a_4_ext), 
  .q1(bram_rdata_a_4_ext), 
  .clk(clk_mem));


    // BRAM matrix A 1
ram matrix_A_1(
  .addr0(bram_addr_a_1),
  .d0(bram_wdata_a_1), 
  .we0(bram_we_a_1), 
  .q0(bram_rdata_a_1), 
  .addr1(bram_addr_a_1_ext),
  .d1(bram_wdata_a_1_ext), 
  .we1(bram_we_a_1_ext), 
  .q1(bram_rdata_a_1_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix A 3
ram matrix_A_3(
  .addr0(bram_addr_a_3),
  .d0(bram_wdata_a_3), 
  .we0(bram_we_a_3), 
  .q0(bram_rdata_a_3), 
  .addr1(bram_addr_a_3_ext),
  .d1(bram_wdata_a_3_ext), 
  .we1(bram_we_a_3_ext), 
  .q1(bram_rdata_a_3_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix A 5
ram matrix_A_5(
  .addr0(bram_addr_a_5),
  .d0(bram_wdata_a_5), 
  .we0(bram_we_a_5), 
  .q0(bram_rdata_a_5), 
  .addr1(bram_addr_a_5_ext),
  .d1(bram_wdata_a_5_ext), 
  .we1(bram_we_a_5_ext), 
  .q1(bram_rdata_a_5_ext), 
  .clk(clk_mem));

////////////////////////////////////////////////
// BRAMs to store matrix B
/////////////////////////////////////////////////


  // BRAM matrix B 0
ram matrix_B_0(
  .addr0(bram_addr_b_0),
  .d0(bram_wdata_b_0), 
  .we0(bram_we_b_0), 
  .q0(bram_rdata_b_0), 
  .addr1(bram_addr_b_0_ext),
  .d1(bram_wdata_b_0_ext), 
  .we1(bram_we_b_0_ext), 
  .q1(bram_rdata_b_0_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix B 1
ram matrix_B_1(
  .addr0(bram_addr_b_1),
  .d0(bram_wdata_b_1), 
  .we0(bram_we_b_1), 
  .q0(bram_rdata_b_1), 
  .addr1(bram_addr_b_1_ext),
  .d1(bram_wdata_b_1_ext), 
  .we1(bram_we_b_1_ext), 
  .q1(bram_rdata_b_1_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix B 2
ram matrix_B_2(
  .addr0(bram_addr_b_2),
  .d0(bram_wdata_b_2), 
  .we0(bram_we_b_2), 
  .q0(bram_rdata_b_2), 
  .addr1(bram_addr_b_2_ext),
  .d1(bram_wdata_b_2_ext), 
  .we1(bram_we_b_2_ext), 
  .q1(bram_rdata_b_2_ext), 
  .clk(clk_mem));

  	
  // BRAM matrix B 3
ram matrix_B_3(
  .addr0(bram_addr_b_3),
  .d0(bram_wdata_b_3), 
  .we0(bram_we_b_3), 
  .q0(bram_rdata_b_3), 
  .addr1(bram_addr_b_3_ext),
  .d1(bram_wdata_b_3_ext), 
  .we1(bram_we_b_3_ext), 
  .q1(bram_rdata_b_3_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix B 4
ram matrix_B_4(
  .addr0(bram_addr_b_4),
  .d0(bram_wdata_b_4), 
  .we0(bram_we_b_4), 
  .q0(bram_rdata_b_4), 
  .addr1(bram_addr_b_4_ext),
  .d1(bram_wdata_b_4_ext), 
  .we1(bram_we_b_4_ext), 
  .q1(bram_rdata_b_4_ext), 
  .clk(clk_mem));


  // BRAM matrix B 5
ram matrix_B_5(
  .addr0(bram_addr_b_5),
  .d0(bram_wdata_b_5), 
  .we0(bram_we_b_5), 
  .q0(bram_rdata_b_5), 
  .addr1(bram_addr_b_5_ext),
  .d1(bram_wdata_b_5_ext), 
  .we1(bram_we_b_5_ext), 
  .q1(bram_rdata_b_5_ext), 
  .clk(clk_mem));

////////////////////////////////////////////////
// BRAMs to store matrix C
/////////////////////////////////////////////////


  // BRAM matrix C 0
ram matrix_C_0(
  .addr0(bram_addr_c_0),
  .d0(bram_wdata_c_0), 
  .we0(bram_we_c_0), 
  .q0(bram_rdata_c_0), 
  .addr1(bram_addr_c_0_ext),
  .d1(bram_wdata_c_0_ext), 
  .we1(bram_we_c_0_ext), 
  .q1(bram_rdata_c_0_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix C 1
ram matrix_C_1(
  .addr0(bram_addr_c_1),
  .d0(bram_wdata_c_1), 
  .we0(bram_we_c_1), 
  .q0(bram_rdata_c_1), 
  .addr1(bram_addr_c_1_ext),
  .d1(bram_wdata_c_1_ext), 
  .we1(bram_we_c_1_ext), 
  .q1(bram_rdata_c_1_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix C 2
ram matrix_C_2(
  .addr0(bram_addr_c_2),
  .d0(bram_wdata_c_2), 
  .we0(bram_we_c_2), 
  .q0(bram_rdata_c_2), 
  .addr1(bram_addr_c_2_ext),
  .d1(bram_wdata_c_2_ext), 
  .we1(bram_we_c_2_ext), 
  .q1(bram_rdata_c_2_ext), 
  .clk(clk_mem));

  	
  // BRAM matrix C 3
ram matrix_C_3(
  .addr0(bram_addr_c_3),
  .d0(bram_wdata_c_3), 
  .we0(bram_we_c_3), 
  .q0(bram_rdata_c_3), 
  .addr1(bram_addr_c_3_ext),
  .d1(bram_wdata_c_3_ext), 
  .we1(bram_we_c_3_ext), 
  .q1(bram_rdata_c_3_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix C 4
ram matrix_C_4(
  .addr0(bram_addr_c_4),
  .d0(bram_wdata_c_4), 
  .we0(bram_we_c_4), 
  .q0(bram_rdata_c_4), 
  .addr1(bram_addr_c_4_ext),
  .d1(bram_wdata_c_4_ext), 
  .we1(bram_we_c_4_ext), 
  .q1(bram_rdata_c_4_ext), 
  .clk(clk_mem));


  // BRAM matrix C 5
ram matrix_C_5(
  .addr0(bram_addr_c_5),
  .d0(bram_wdata_c_5), 
  .we0(bram_we_c_5), 
  .q0(bram_rdata_c_5), 
  .addr1(bram_addr_c_5_ext),
  .d1(bram_wdata_c_5_ext), 
  .we1(bram_we_c_5_ext), 
  .q1(bram_rdata_c_5_ext), 
  .clk(clk_mem));
  	
reg start_eltwise_op;
wire done_eltwise_op;

reg [3:0] state;
	
////////////////////////////////////////////////////////////////
// Control logic
////////////////////////////////////////////////////////////////
	always @( posedge clk) begin
      if (resetn == 1'b0) begin
        state <= 4'b0000;
        start_eltwise_op <= 1'b0;
      end 
      else begin
        case (state)

        4'b0000: begin
          start_eltwise_op <= 1'b0;
          if (start_reg == 1'b1) begin
            state <= 4'b0001;
          end else begin
            state <= 4'b0000;
          end
        end
        
        4'b0001: begin
          start_eltwise_op <= 1'b1;	      
          state <= 4'b1010;                    
        end      
        
        4'b1010: begin                 
          if (done_eltwise_op == 1'b1) begin
            start_eltwise_op <= 1'b0;
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

reg [1:0] state_apb;
`define IDLE     2'b00
`define W_ENABLE  2'b01
`define R_ENABLE  2'b10

reg [`AWIDTH-1:0] address_mat_a;
reg [`AWIDTH-1:0] address_mat_b;
reg [`AWIDTH-1:0] address_mat_c;
reg [`MASK_WIDTH-1:0] validity_mask_a;
reg [`MASK_WIDTH-1:0] validity_mask_b;
reg [`ITERATIONS_WIDTH-1:0] iterations;

////////////////////////////////////////////////////////////////
// Configuration logic
////////////////////////////////////////////////////////////////
always @(posedge PCLK) begin
  if (PRESETn == 0) begin
    state_apb <= `IDLE;
    PRDATA <= 0;
    PREADY <= 0;
    address_mat_a <= 0;
    address_mat_b <= 0;
    address_mat_c <= 0;
    validity_mask_a <= {`MASK_WIDTH{1'b1}};
    validity_mask_b <= {`MASK_WIDTH{1'b1}};
  end

  else begin
    case (state_apb)
      `IDLE : begin
        PRDATA <= 0;
        if (PSEL) begin
          if (PWRITE) begin
            state_apb <= `W_ENABLE;
          end
          else begin
            state_apb <= `R_ENABLE;
          end
        end
        PREADY <= 0;
      end

      `W_ENABLE : begin
        if (PSEL && PWRITE && PENABLE) begin
          case (PADDR)
          `REG_STDN_ADDR       : begin
                                 start_reg <= PWDATA[0];
                                 clear_done_reg <= PWDATA[31];
                                 end
          `REG_MATRIX_A_ADDR   : address_mat_a <= PWDATA[`AWIDTH-1:0];
          `REG_MATRIX_B_ADDR   : address_mat_b <= PWDATA[`AWIDTH-1:0];
          `REG_MATRIX_C_ADDR   : address_mat_c <= PWDATA[`AWIDTH-1:0];
          `REG_VALID_MASK_A_ADDR: begin
                                validity_mask_a <= PWDATA[`MASK_WIDTH-1:0];
                                end
          `REG_VALID_MASK_B_ADDR: begin
                                validity_mask_b <= PWDATA[`MASK_WIDTH-1:0];
                                end
          `REG_ITERATIONS_ADDR: iterations <= PWDATA[`ITERATIONS_WIDTH-1:0];
          default : reg_dummy <= PWDATA; //sink writes to a dummy register
          endcase
          PREADY <=1;          
        end
        state_apb <= `IDLE;
      end

      `R_ENABLE : begin
        if (PSEL && !PWRITE && PENABLE) begin
          PREADY <= 1;
          case (PADDR)
          `REG_STDN_ADDR        : PRDATA <= {done_eltwise_op, 30'b0, start_eltwise_op};
          `REG_MATRIX_A_ADDR    : PRDATA <= address_mat_a;
          `REG_MATRIX_B_ADDR    : PRDATA <= address_mat_b;
          `REG_MATRIX_C_ADDR    : PRDATA <= address_mat_c;
          `REG_VALID_MASK_A_ADDR: PRDATA <= validity_mask_a;
          `REG_VALID_MASK_B_ADDR: PRDATA <= validity_mask_b;
          `REG_ITERATIONS_ADDR: PRDATA <= iterations;
          default : PRDATA <= reg_dummy; //read the dummy register for undefined addresses
          endcase
        end
        state_apb <= `IDLE;
      end
      default: begin
        state_apb <= `IDLE;
      end
    endcase
  end
end  
  
wire reset;
assign reset = ~resetn;
wire pe_reset;
assign pe_reset = ~pe_resetn;

  wire c_data_0_available;
  wire c_data_1_available;
  wire c_data_2_available;
  wire c_data_3_available;
  wire c_data_4_available;
  wire c_data_5_available;

  assign bram_wdata_a_0 = {`CU_SIZE*`DWIDTH{1'b0}};
  assign bram_en_a_0 = 1'b1;
  assign bram_we_a_0 = {`MASK_WIDTH{1'b0}};

  assign bram_wdata_a_1 = {`CU_SIZE*`DWIDTH{1'b0}};
  assign bram_en_a_1 = 1'b1;
  assign bram_we_a_1 = {`MASK_WIDTH{1'b0}};

  assign bram_wdata_a_2 = {`CU_SIZE*`DWIDTH{1'b0}};
  assign bram_en_a_2 = 1'b1;
  assign bram_we_a_2 = {`MASK_WIDTH{1'b0}};

  assign bram_wdata_a_3 = {`CU_SIZE*`DWIDTH{1'b0}};
  assign bram_en_a_3 = 1'b1;
  assign bram_we_a_3 = {`MASK_WIDTH{1'b0}};

  assign bram_wdata_a_4 = {`CU_SIZE*`DWIDTH{1'b0}};
  assign bram_en_a_4 = 1'b1;
  assign bram_we_a_4 = {`MASK_WIDTH{1'b0}};

  assign bram_wdata_a_5 = {`CU_SIZE*`DWIDTH{1'b0}};
  assign bram_en_a_5 = 1'b1;
  assign bram_we_a_5 = {`MASK_WIDTH{1'b0}};
  	
  assign bram_wdata_b_0 = {`CU_SIZE*`DWIDTH{1'b0}};
  assign bram_en_b_0 = 1'b1;
  assign bram_we_b_0 = {`MASK_WIDTH{1'b0}};

  assign bram_wdata_b_1 = {`CU_SIZE*`DWIDTH{1'b0}};
  assign bram_en_b_1 = 1'b1;
  assign bram_we_b_1 = {`MASK_WIDTH{1'b0}};

  assign bram_wdata_b_2 = {`CU_SIZE*`DWIDTH{1'b0}};
  assign bram_en_b_2 = 1'b1;
  assign bram_we_b_2 = {`MASK_WIDTH{1'b0}};

  assign bram_wdata_b_3 = {`CU_SIZE*`DWIDTH{1'b0}};
  assign bram_en_b_3 = 1'b1;
  assign bram_we_b_3 = {`MASK_WIDTH{1'b0}};

  assign bram_wdata_b_4 = {`CU_SIZE*`DWIDTH{1'b0}};
  assign bram_en_b_4 = 1'b1;
  assign bram_we_b_4 = {`MASK_WIDTH{1'b0}};

  assign bram_wdata_b_5 = {`CU_SIZE*`DWIDTH{1'b0}};
  assign bram_en_b_5 = 1'b1;
  assign bram_we_b_5 = {`MASK_WIDTH{1'b0}};

  assign bram_en_c_0 = 1'b1;
  assign bram_we_c_0 = (c_data_0_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  
  	
  assign bram_en_c_2 = 1'b1;
  assign bram_we_c_2 = (c_data_2_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  
  	
  assign bram_en_c_4 = 1'b1;
  assign bram_we_c_4 = (c_data_4_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  

  assign bram_en_c_1 = 1'b1;
  assign bram_we_c_1 = (c_data_1_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  
  	
  assign bram_en_c_3 = 1'b1;
  assign bram_we_c_3 = (c_data_3_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  
  	
  assign bram_en_c_5 = 1'b1;
  assign bram_we_c_5 = (c_data_5_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  

  /////////////////////////////////////////////////
  // ORing all done signals
  /////////////////////////////////////////////////
  wire done_eltwise_op_0;
  wire done_eltwise_op_1;
  wire done_eltwise_op_2;
  wire done_eltwise_op_3;
  wire done_eltwise_op_4;
  wire done_eltwise_op_5;

  assign done_eltwise_op = 
  done_eltwise_op_0 | 
  done_eltwise_op_1 | 
  done_eltwise_op_2 | 
  done_eltwise_op_3 | 
  done_eltwise_op_4 | 
  done_eltwise_op_5 ;

  /////////////////////////////////////////////////
  // Code to allow for scalar mode
  /////////////////////////////////////////////////
  
	wire [`CU_SIZE*`DWIDTH-1:0] b_data_0;
	wire [`CU_SIZE*`DWIDTH-1:0] b_data_1;
	wire [`CU_SIZE*`DWIDTH-1:0] b_data_2;
	wire [`CU_SIZE*`DWIDTH-1:0] b_data_3;
	wire [`CU_SIZE*`DWIDTH-1:0] b_data_4;
	wire [`CU_SIZE*`DWIDTH-1:0] b_data_5;

  assign b_data_0 = mode ? bram_rdata_b_0 : {`CU_SIZE{scalar_inp}};
  assign b_data_1 = mode ? bram_rdata_b_1 : {`CU_SIZE{scalar_inp}};
  assign b_data_2 = mode ? bram_rdata_b_2 : {`CU_SIZE{scalar_inp}};
  assign b_data_3 = mode ? bram_rdata_b_3 : {`CU_SIZE{scalar_inp}};
  assign b_data_4 = mode ? bram_rdata_b_4 : {`CU_SIZE{scalar_inp}};
  assign b_data_5 = mode ? bram_rdata_b_5 : {`CU_SIZE{scalar_inp}};

  /////////////////////////////////////////////////
  // Compute Unit 0
  /////////////////////////////////////////////////

eltwise_cu u_eltwise_cu_0(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_eltwise_op(start_eltwise_op),
  .done_eltwise_op(done_eltwise_op_0),
  .count(iterations),
  .op(op),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .a_data(bram_rdata_a_0),
  .b_data(b_data_0),
  .c_data_out(bram_wdata_c_0),
  .a_addr(bram_addr_a_0),
  .b_addr(bram_addr_b_0),
  .c_addr(bram_addr_c_0),
  .c_data_available(c_data_0_available),
  .validity_mask_a(4'b1111),
  .validity_mask_b(4'b1111)
);

  /////////////////////////////////////////////////
  // Matmul 1
  /////////////////////////////////////////////////

eltwise_cu u_eltwise_cu_1(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_eltwise_op(start_eltwise_op),
  .done_eltwise_op(done_eltwise_op_1),
  .count(iterations),
  .op(op),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .a_data(bram_rdata_a_1),
  .b_data(b_data_1),
  .c_data_out(bram_wdata_c_1),
  .a_addr(bram_addr_a_1),
  .b_addr(bram_addr_b_1),
  .c_addr(bram_addr_c_1),
  .c_data_available(c_data_1_available),
  .validity_mask_a(4'b1111),
  .validity_mask_b(4'b1111)
);

  /////////////////////////////////////////////////
  // Matmul 2
  /////////////////////////////////////////////////

eltwise_cu u_eltwise_cu_2(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_eltwise_op(start_eltwise_op),
  .done_eltwise_op(done_eltwise_op_2),
  .count(iterations),
  .op(op),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .a_data(bram_rdata_a_2),
  .b_data(b_data_2),
  .c_data_out(bram_wdata_c_2),
  .a_addr(bram_addr_a_2),
  .b_addr(bram_addr_b_2),
  .c_addr(bram_addr_c_2),
  .c_data_available(c_data_2_available),
  .validity_mask_a(4'b1111),
  .validity_mask_b(4'b1111)
);

  /////////////////////////////////////////////////
  // Matmul 3
  /////////////////////////////////////////////////

eltwise_cu u_eltwise_cu_3(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_eltwise_op(start_eltwise_op),
  .done_eltwise_op(done_eltwise_op_3),
  .count(iterations),
  .op(op),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .a_data(bram_rdata_a_3),
  .b_data(b_data_3),
  .c_data_out(bram_wdata_c_3),
  .a_addr(bram_addr_a_3),
  .b_addr(bram_addr_b_3),
  .c_addr(bram_addr_c_3),
  .c_data_available(c_data_3_available),
  .validity_mask_a(4'b1111),
  .validity_mask_b(4'b1111)
);

  /////////////////////////////////////////////////
  // Matmul 4
  /////////////////////////////////////////////////

eltwise_cu u_eltwise_cu_4(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_eltwise_op(start_eltwise_op),
  .done_eltwise_op(done_eltwise_op_4),
  .count(iterations),
  .op(op),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .a_data(bram_rdata_a_4),
  .b_data(b_data_4),
  .c_data_out(bram_wdata_c_4),
  .a_addr(bram_addr_a_4),
  .b_addr(bram_addr_b_4),
  .c_addr(bram_addr_c_4),
  .c_data_available(c_data_4_available),
  .validity_mask_a(4'b1111),
  .validity_mask_b(4'b1111)
);

  /////////////////////////////////////////////////
  // Matmul 5
  /////////////////////////////////////////////////

eltwise_cu u_eltwise_cu_5(
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_eltwise_op(start_eltwise_op),
  .done_eltwise_op(done_eltwise_op_5),
  .count(iterations),
  .op(op),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .a_data(bram_rdata_a_5),
  .b_data(b_data_5),
  .c_data_out(bram_wdata_c_5),
  .a_addr(bram_addr_a_5),
  .b_addr(bram_addr_b_5),
  .c_addr(bram_addr_c_5),
  .c_data_available(c_data_5_available),
  .validity_mask_a(4'b0011),
  .validity_mask_b(4'b0011)
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
input [`CU_SIZE*`DWIDTH-1:0] d0;
input [`CU_SIZE*`DWIDTH-1:0] d1;
input [`CU_SIZE-1:0] we0;
input [`CU_SIZE-1:0] we1;
output [`CU_SIZE*`DWIDTH-1:0] q0;
output [`CU_SIZE*`DWIDTH-1:0] q1;
input clk;

`ifdef VCS
reg [`CU_SIZE*`DWIDTH-1:0] q0;
reg [`CU_SIZE*`DWIDTH-1:0] q1;
reg [7:0] ram[((1<<`AWIDTH)-1):0];
integer i;

always @(posedge clk)  
begin 
    for (i = 0; i < `CU_SIZE; i=i+1) begin
        if (we0[i]) ram[addr0+i] <= d0[i*`DWIDTH +: `DWIDTH]; 
    end    
    for (i = 0; i < `CU_SIZE; i=i+1) begin
        q0[i*`DWIDTH +: `DWIDTH] <= ram[addr0+i];
    end    
end

always @(posedge clk)  
begin 
    for (i = 0; i < `CU_SIZE; i=i+1) begin
        if (we1[i]) ram[addr0+i] <= d1[i*`DWIDTH +: `DWIDTH]; 
    end    
    for (i = 0; i < `CU_SIZE; i=i+1) begin
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

  
module eltwise_cu(
 clk,
 reset,
 pe_reset,
 start_eltwise_op,
 done_eltwise_op,
 count,
 op,
 address_mat_a,
 address_mat_b,
 address_mat_c,
 a_data,
 b_data,
 c_data_out, 
 a_addr,
 b_addr,
 c_addr,
 c_data_available,
 validity_mask_a,
 validity_mask_b
);

 input clk;
 input reset;
 input pe_reset;
 input start_eltwise_op;
 output done_eltwise_op;
 input [`ITERATIONS_WIDTH-1:0] count;
 input [1:0] op;
 input [`AWIDTH-1:0] address_mat_a;
 input [`AWIDTH-1:0] address_mat_b;
 input [`AWIDTH-1:0] address_mat_c;
 input [`CU_SIZE*`DWIDTH-1:0] a_data;
 input [`CU_SIZE*`DWIDTH-1:0] b_data;
 output [`CU_SIZE*`DWIDTH-1:0] c_data_out;
 output [`AWIDTH-1:0] a_addr;
 output [`AWIDTH-1:0] b_addr;
 output [`AWIDTH-1:0] c_addr;
 output c_data_available;
 input [`MASK_WIDTH-1:0] validity_mask_a;
 input [`MASK_WIDTH-1:0] validity_mask_b;

wire [`DWIDTH-1:0] out0;
wire [`DWIDTH-1:0] out1;
wire [`DWIDTH-1:0] out2;
wire [`DWIDTH-1:0] out3;

wire [`DWIDTH-1:0] a0_data;
wire [`DWIDTH-1:0] a1_data;
wire [`DWIDTH-1:0] a2_data;
wire [`DWIDTH-1:0] a3_data;
wire [`DWIDTH-1:0] b0_data;
wire [`DWIDTH-1:0] b1_data;
wire [`DWIDTH-1:0] b2_data;
wire [`DWIDTH-1:0] b3_data;

//////////////////////////////////////////////////////////////////////////
// Logic for done
//////////////////////////////////////////////////////////////////////////
wire [7:0] clk_cnt_for_done;
reg [31:0] clk_cnt;
reg done_eltwise_op;

assign clk_cnt_for_done = 
                  `PE_PIPELINE_DEPTH + //This is dependent on the pipeline depth of the PEs
                  count //The number of iterations asked for this compute unit
                  ;
                          
always @(posedge clk) begin
  if (reset || ~start_eltwise_op) begin
    clk_cnt <= 0;
    done_eltwise_op <= 0;
  end
  else if (clk_cnt == clk_cnt_for_done) begin
    done_eltwise_op <= 1;
    clk_cnt <= clk_cnt + 1;
  end
  else if (done_eltwise_op == 0) begin
    clk_cnt <= clk_cnt + 1;
  end    
  else begin
    done_eltwise_op <= 0;
    clk_cnt <= clk_cnt + 1;
  end
end

//////////////////////////////////////////////////////////////////////////
// Instantiation of input logic
//////////////////////////////////////////////////////////////////////////
input_logic u_input_logic(
.clk(clk),
.reset(reset),
.start_eltwise_op(start_eltwise_op),
.count(count),
.a_addr(a_addr),
.b_addr(b_addr),
.address_mat_a(address_mat_a),
.address_mat_b(address_mat_b),
.a_data(a_data),
.b_data(b_data),
.a0_data(a0_data),
.a1_data(a1_data),
.a2_data(a2_data),
.a3_data(a3_data),
.b0_data(b0_data),
.b1_data(b1_data),
.b2_data(b2_data),
.b3_data(b3_data),
.validity_mask_a(validity_mask_a),
.validity_mask_b(validity_mask_b)
);

//////////////////////////////////////////////////////////////////////////
// Instantiation of the output logic
//////////////////////////////////////////////////////////////////////////
output_logic u_output_logic(
.clk(clk),
.reset(reset),
.start_eltwise_op(start_eltwise_op),
.done_eltwise_op(done_eltwise_op),
.address_mat_c(address_mat_c),
.c_data_out(c_data_out),
.c_addr(c_addr),
.c_data_available(c_data_available),
.out0(out0),
.out1(out1),
.out2(out2),
.out3(out3)
);

//////////////////////////////////////////////////////////////////////////
// Instantiations of the actual PEs
//////////////////////////////////////////////////////////////////////////
pe_array u_pe_array(
.reset(reset),
.clk(clk),
.pe_reset(pe_reset),
.op(op),
.a0(a0_data), 
.a1(a1_data), 
.a2(a2_data), 
.a3(a3_data),
.b0(b0_data), 
.b1(b1_data), 
.b2(b2_data), 
.b3(b3_data),
.out0(out0),
.out1(out1),
.out2(out2),
.out3(out3)
);

endmodule

//////////////////////////////////////////////////////////////////////////
// Output logic
//////////////////////////////////////////////////////////////////////////
module output_logic(
clk,
reset,
start_eltwise_op,
done_eltwise_op,
address_mat_c,
c_data_out, 
c_addr,
c_data_available,
out0,
out1,
out2,
out3
);

input clk;
input reset;
input start_eltwise_op;
input done_eltwise_op;
input [`AWIDTH-1:0] address_mat_c;
output [`CU_SIZE*`DWIDTH-1:0] c_data_out;
output [`AWIDTH-1:0] c_addr;
output c_data_available;
input [`DWIDTH-1:0] out0;
input [`DWIDTH-1:0] out1;
input [`DWIDTH-1:0] out2;
input [`DWIDTH-1:0] out3;

reg c_data_available;
reg [`CU_SIZE*`DWIDTH-1:0] c_data_out;

//////////////////////////////////////////////////////////////////////////
// Logic to capture matrix C data from the PEs and send to RAM
//////////////////////////////////////////////////////////////////////////

reg [`AWIDTH-1:0] c_addr;
reg [7:0] cnt;

always @(posedge clk) begin
  if (reset | ~start_eltwise_op) begin
    c_data_available <= 1'b0;
    c_addr <= address_mat_c;
    c_data_out <= 0;
    cnt <= 0;
  end
  else if (cnt>`PE_PIPELINE_DEPTH) begin
    c_data_available <= 1'b1;
    c_addr <= c_addr+1;
    c_data_out <= {out3, out2, out1, out0};
    cnt <= cnt + 1;
  end else begin
    cnt <= cnt + 1;
  end 
end

endmodule

//////////////////////////////////////////////////////////////////////////
// Data setup
//////////////////////////////////////////////////////////////////////////
module input_logic(
clk,
reset,
start_eltwise_op,
count,
a_addr,
b_addr,
address_mat_a,
address_mat_b,
a_data,
b_data,
a0_data,
a1_data,
a2_data,
a3_data,
b0_data,
b1_data,
b2_data,
b3_data,
validity_mask_a,
validity_mask_b
);

input clk;
input reset;
input start_eltwise_op;
input [`ITERATIONS_WIDTH-1:0] count;
output [`AWIDTH-1:0] a_addr;
output [`AWIDTH-1:0] b_addr;
input [`AWIDTH-1:0] address_mat_a;
input [`AWIDTH-1:0] address_mat_b;
input [`CU_SIZE*`DWIDTH-1:0] a_data;
input [`CU_SIZE*`DWIDTH-1:0] b_data;
output [`DWIDTH-1:0] a0_data;
output [`DWIDTH-1:0] a1_data;
output [`DWIDTH-1:0] a2_data;
output [`DWIDTH-1:0] a3_data;
output [`DWIDTH-1:0] b0_data;
output [`DWIDTH-1:0] b1_data;
output [`DWIDTH-1:0] b2_data;
output [`DWIDTH-1:0] b3_data;
input [`MASK_WIDTH-1:0] validity_mask_a;
input [`MASK_WIDTH-1:0] validity_mask_b;

reg [7:0] iterations;

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
  //else if (clk_cnt >= a_loc*`CU_SIZE+final_mat_mul_size) begin
  //Writing the line above to avoid multiplication:
  if (reset || ~start_eltwise_op) begin
    a_addr <= address_mat_a;
    a_mem_access <= 0;
    iterations <= 0;
  end

  //else if ((clk_cnt >= a_loc*`CU_SIZE) && (clk_cnt < a_loc*`CU_SIZE+final_mat_mul_size)) begin
  //Writing the line above to avoid multiplication:
  else if (iterations <= count) begin
    a_addr <= a_addr + 1;
    a_mem_access <= 1;
    iterations <= iterations + 1;
  end
end  

//////////////////////////////////////////////////////////////////////////
// Logic to generate valid signals for data coming from BRAM A
//////////////////////////////////////////////////////////////////////////
reg [7:0] a_mem_access_counter;
always @(posedge clk) begin
  if (reset || ~start_eltwise_op) begin
    a_mem_access_counter <= 0;
  end
  else if (a_mem_access == 1) begin
    a_mem_access_counter <= a_mem_access_counter + 1;  

  end
  else begin
    a_mem_access_counter <= 0;
  end
end

wire bram_rdata_a_valid; //flag that tells whether the data from memory is valid
assign bram_rdata_a_valid = 
       ((validity_mask_a[0]==1'b0 && a_mem_access_counter==1) ||
        (validity_mask_a[1]==1'b0 && a_mem_access_counter==2) ||
        (validity_mask_a[2]==1'b0 && a_mem_access_counter==3) ||
        (validity_mask_a[3]==1'b0 && a_mem_access_counter==4)) ?
        1'b0 : (a_mem_access_counter >= `MEM_ACCESS_LATENCY);

//////////////////////////////////////////////////////////////////////////
// Logic to delay certain parts of the data received from BRAM A (systolic data setup)
//////////////////////////////////////////////////////////////////////////
//Slice data into chunks and qualify it with whether it is valid or not
assign a0_data = a_data[1*`DWIDTH-1:0*`DWIDTH] & {`DWIDTH{bram_rdata_a_valid}} & {`DWIDTH{validity_mask_a[0]}};
assign a1_data = a_data[2*`DWIDTH-1:1*`DWIDTH] & {`DWIDTH{bram_rdata_a_valid}} & {`DWIDTH{validity_mask_a[1]}};
assign a2_data = a_data[3*`DWIDTH-1:2*`DWIDTH] & {`DWIDTH{bram_rdata_a_valid}} & {`DWIDTH{validity_mask_a[2]}};
assign a3_data = a_data[4*`DWIDTH-1:3*`DWIDTH] & {`DWIDTH{bram_rdata_a_valid}} & {`DWIDTH{validity_mask_a[3]}};


//////////////////////////////////////////////////////////////////////////
// Logic to generate addresses to BRAM B
//////////////////////////////////////////////////////////////////////////
reg [`AWIDTH-1:0] b_addr;
reg b_mem_access; //flag that tells whether the matmul is trying to access memory or not

always @(posedge clk) begin
  //else if (clk_cnt >= b_loc*`CU_SIZE+final_mat_mul_size) begin
  //Writing the line above to avoid multiplication:
  if (reset || ~start_eltwise_op) begin
    b_addr <= address_mat_b ;
    b_mem_access <= 0;
  end
  //else if ((clk_cnt >= b_loc*`CU_SIZE) && (clk_cnt < b_loc*`CU_SIZE+final_mat_mul_size)) begin
  //Writing the line above to avoid multiplication:
  else if (iterations <= count) begin
    b_addr <= b_addr + 1;
    b_mem_access <= 1;
  end
end  

//////////////////////////////////////////////////////////////////////////
// Logic to generate valid signals for data coming from BRAM B
//////////////////////////////////////////////////////////////////////////
reg [7:0] b_mem_access_counter;
always @(posedge clk) begin
  if (reset || ~start_eltwise_op) begin
    b_mem_access_counter <= 0;
  end
  else if (b_mem_access == 1) begin
    b_mem_access_counter <= b_mem_access_counter + 1;  
  end
  else begin
    b_mem_access_counter <= 0;
  end
end

wire bram_rdata_b_valid; //flag that tells whether the data from memory is valid
assign bram_rdata_b_valid = 
       ((validity_mask_b[0]==1'b0 && b_mem_access_counter==1) ||
        (validity_mask_b[1]==1'b0 && b_mem_access_counter==2) ||
        (validity_mask_b[2]==1'b0 && b_mem_access_counter==3) ||
        (validity_mask_b[3]==1'b0 && b_mem_access_counter==4)) ?
        1'b0 : (b_mem_access_counter >= `MEM_ACCESS_LATENCY);

//Slice data into chunks and qualify it with whether it is valid or not
assign b0_data = b_data[1*`DWIDTH-1:0*`DWIDTH] & {`DWIDTH{bram_rdata_b_valid}} & {`DWIDTH{validity_mask_b[0]}};
assign b1_data = b_data[2*`DWIDTH-1:1*`DWIDTH] & {`DWIDTH{bram_rdata_b_valid}} & {`DWIDTH{validity_mask_b[1]}};
assign b2_data = b_data[3*`DWIDTH-1:2*`DWIDTH] & {`DWIDTH{bram_rdata_b_valid}} & {`DWIDTH{validity_mask_b[2]}};
assign b3_data = b_data[4*`DWIDTH-1:3*`DWIDTH] & {`DWIDTH{bram_rdata_b_valid}} & {`DWIDTH{validity_mask_b[3]}};


endmodule



//////////////////////////////////////////////////////////////////////////
// Array of processing elements
//////////////////////////////////////////////////////////////////////////
module pe_array(
reset,
clk,
pe_reset,
op,
a0, a1, a2, a3,
b0, b1, b2, b3,
out0, out1, out2, out3
);

input clk;
input reset;
input pe_reset;
input [1:0] op;
input [`DWIDTH-1:0] a0;
input [`DWIDTH-1:0] a1;
input [`DWIDTH-1:0] a2;
input [`DWIDTH-1:0] a3;
input [`DWIDTH-1:0] b0;
input [`DWIDTH-1:0] b1;
input [`DWIDTH-1:0] b2;
input [`DWIDTH-1:0] b3;
output [`DWIDTH-1:0] out0;
output [`DWIDTH-1:0] out1;
output [`DWIDTH-1:0] out2;
output [`DWIDTH-1:0] out3;

wire [`DWIDTH-1:0] out0, out1, out2, out3;

wire effective_rst;
assign effective_rst = reset | pe_reset;

processing_element pe0(.reset(effective_rst), .clk(clk), .in_a(a0), .in_b(b0), .op(op), .out(out0));
processing_element pe1(.reset(effective_rst), .clk(clk), .in_a(a1), .in_b(b1), .op(op), .out(out1));
processing_element pe2(.reset(effective_rst), .clk(clk), .in_a(a2), .in_b(b2), .op(op), .out(out2));
processing_element pe3(.reset(effective_rst), .clk(clk), .in_a(a3), .in_b(b3), .op(op), .out(out3));

endmodule


//////////////////////////////////////////////////////////////////////////
// Processing element (PE)
//////////////////////////////////////////////////////////////////////////
module processing_element(
 reset, 
 clk, 
 in_a,
 in_b, 
 op,
 out
 );

 input reset;
 input clk;
 input  [`DWIDTH-1:0] in_a;
 input  [`DWIDTH-1:0] in_b;
 input  [1:0] op;
 output [`DWIDTH-1:0] out;

 wire [`DWIDTH-1:0] out_mul;
 wire [`DWIDTH-1:0] out_sum;
 wire [`DWIDTH-1:0] out_sub;

 assign out = (op == 2'b00) ? out_sum : 
              (op == 2'b01) ? out_sub :
              out_mul;

 seq_mul u_mul(.a(in_a), .b(in_b), .out(out_mul), .reset(reset), .clk(clk));
 seq_add u_add(.a(in_a), .b(in_b), .out(out_sum), .reset(reset), .clk(clk));
 seq_sub u_sub(.a(in_a), .b(in_b), .out(out_sum), .reset(reset), .clk(clk));

endmodule

//////////////////////////////////////////////////////////////////////////
// Multiply block
//////////////////////////////////////////////////////////////////////////
module seq_mul(a, b, out, reset, clk);
input [`DWIDTH-1:0] a;
input [`DWIDTH-1:0] b;
input reset;
input clk;
output [`DWIDTH-1:0] out;

reg [`DWIDTH-1:0] a_flopped;
reg [`DWIDTH-1:0] b_flopped;

wire [`DWIDTH-1:0] mul_out_temp;
reg [`DWIDTH-1:0] mul_out_temp_reg;

always @(posedge clk) begin
  if (reset) begin
    a_flopped <= 0;
    b_flopped <= 0;
  end else begin
    a_flopped <= a;
    b_flopped <= b;
  end
end

assign mul_out_temp = a * b;
//muliply_fp mul_u1(.a(a_flopped), .b(b_flopped), .out(mul_out_temp));

always @(posedge clk) begin
  if (reset) begin
    mul_out_temp_reg <= 0;
  end else begin
    mul_out_temp_reg <= mul_out_temp;
  end
end

assign out = mul_out_temp_reg;

endmodule

//////////////////////////////////////////////////////////////////////////
// Addition block
//////////////////////////////////////////////////////////////////////////
module seq_add(a, b, out, reset, clk);
input [`DWIDTH-1:0] a;
input [`DWIDTH-1:0] b;
input reset;
input clk;
output [`DWIDTH-1:0] out;

reg [`DWIDTH-1:0] a_flopped;
reg [`DWIDTH-1:0] b_flopped;

wire [`DWIDTH-1:0] sum_out_temp;
reg [`DWIDTH-1:0] sum_out_temp_reg;

always @(posedge clk) begin
  if (reset) begin
    a_flopped <= 0;
    b_flopped <= 0;
  end else begin
    a_flopped <= a;
    b_flopped <= b;
  end
end

assign sum_out_temp = a + b;
//add_fp add_u1(.a(a_flopped), .b(b_flopped), .out(sum_out_temp));

always @(posedge clk) begin
  if (reset) begin
    sum_out_temp_reg <= 0;
  end else begin
    sum_out_temp_reg <= sum_out_temp;
  end
end

assign out = sum_out_temp_reg;

endmodule


//////////////////////////////////////////////////////////////////////////
// Subtraction block
//////////////////////////////////////////////////////////////////////////
module seq_sub(a, b, out, reset, clk);
input [`DWIDTH-1:0] a;
input [`DWIDTH-1:0] b;
input reset;
input clk;
output [`DWIDTH-1:0] out;

reg [`DWIDTH-1:0] a_flopped;
reg [`DWIDTH-1:0] b_flopped;

wire [`DWIDTH-1:0] sub_out_temp;
reg [`DWIDTH-1:0] sub_out_temp_reg;

always @(posedge clk) begin
  if (reset) begin
    a_flopped <= 0;
    b_flopped <= 0;
  end else begin
    a_flopped <= a;
    b_flopped <= b;
  end
end

assign sub_out_temp = a - b;
//Floating point adder has both modes - add and sub.
//We don't provide the name of the mode here though.
//add_fp sub_u1(.a(a_flopped), .b(b_flopped), .out(sub_out_temp));

always @(posedge clk) begin
  if (reset) begin
    sub_out_temp_reg <= 0;
  end else begin
    sub_out_temp_reg <= sub_out_temp;
  end
end

assign out = sub_out_temp_reg;

endmodule


