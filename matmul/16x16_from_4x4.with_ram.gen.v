
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

`define REG_START_DONE_ADDR 32'h0
`define REG_MATRIX_A_ADDR 32'he
`define REG_MATRIX_B_ADDR 32'h12
`define REG_MATRIX_C_ADDR 32'h16
`define REG_VALID_MASK_ADDR 32'h20
`define REG_MATRIX_A_STRIDE_ADDR 32'h28
`define REG_MATRIX_B_STRIDE_ADDR 32'h32
`define REG_MATRIX_C_STRIDE_ADDR 32'h36
  module matrix_multiplication(
  input clk,
  input clk_mem,
  input resetn,
  input pe_resetn,
  input                             PCLK,
  input                             PRESETn,
  input        [`REG_ADDRWIDTH-1:0] PADDR,
  input                             PWRITE,
  input                             PSEL,
  input                             PENABLE,
  input        [`REG_DATAWIDTH-1:0] PWDATA,
  output reg   [`REG_DATAWIDTH-1:0] PRDATA,
  output reg                        PREADY,
  input  [7:0] bram_select,
  input  [`AWIDTH-1:0] bram_addr_ext,
  output reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_ext,
  input  [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_ext,
  input  [`MASK_WIDTH-1:0] bram_we_ext
);


  reg start_reg;
  reg clear_done_reg;
  //Dummy register to sync all other invalid/unimplemented addresses
  reg [`REG_DATAWIDTH-1:0] reg_dummy;
  
  reg [`AWIDTH-1:0] bram_addr_a_0_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_0_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_0_0_ext;
  reg [`MASK_WIDTH-1:0] bram_we_a_0_0_ext;
    
  reg [`AWIDTH-1:0] bram_addr_a_1_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_1_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_1_0_ext;
  reg [`MASK_WIDTH-1:0] bram_we_a_1_0_ext;
    
  reg [`AWIDTH-1:0] bram_addr_a_2_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_2_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_2_0_ext;
  reg [`MASK_WIDTH-1:0] bram_we_a_2_0_ext;
    
  reg [`AWIDTH-1:0] bram_addr_a_3_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_3_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_3_0_ext;
  reg [`MASK_WIDTH-1:0] bram_we_a_3_0_ext;
    
  reg [`AWIDTH-1:0] bram_addr_b_0_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_0_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_0_0_ext;
  reg [`MASK_WIDTH-1:0] bram_we_b_0_0_ext;
    
  reg [`AWIDTH-1:0] bram_addr_b_0_1_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_0_1_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_0_1_ext;
  reg [`MASK_WIDTH-1:0] bram_we_b_0_1_ext;
    
  reg [`AWIDTH-1:0] bram_addr_b_0_2_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_0_2_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_0_2_ext;
  reg [`MASK_WIDTH-1:0] bram_we_b_0_2_ext;
    
  reg [`AWIDTH-1:0] bram_addr_b_0_3_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_0_3_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_0_3_ext;
  reg [`MASK_WIDTH-1:0] bram_we_b_0_3_ext;
    
  reg [`AWIDTH-1:0] bram_addr_c_0_3_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_0_3_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_0_3_ext;
  reg [`MASK_WIDTH-1:0] bram_we_c_0_3_ext;
    
  reg [`AWIDTH-1:0] bram_addr_c_1_3_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_1_3_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_1_3_ext;
  reg [`MASK_WIDTH-1:0] bram_we_c_1_3_ext;
    
  reg [`AWIDTH-1:0] bram_addr_c_2_3_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_2_3_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_2_3_ext;
  reg [`MASK_WIDTH-1:0] bram_we_c_2_3_ext;
    
  reg [`AWIDTH-1:0] bram_addr_c_3_3_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_3_3_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_3_3_ext;
  reg [`MASK_WIDTH-1:0] bram_we_c_3_3_ext;
    
	wire [`AWIDTH-1:0] bram_addr_a_0_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_0_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_0_0;
	wire [`MASK_WIDTH-1:0] bram_we_a_0_0;
	wire bram_en_a_0_0;
    
	wire [`AWIDTH-1:0] bram_addr_a_1_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_1_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_1_0;
	wire [`MASK_WIDTH-1:0] bram_we_a_1_0;
	wire bram_en_a_1_0;
    
	wire [`AWIDTH-1:0] bram_addr_a_2_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_2_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_2_0;
	wire [`MASK_WIDTH-1:0] bram_we_a_2_0;
	wire bram_en_a_2_0;
    
	wire [`AWIDTH-1:0] bram_addr_a_3_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_3_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_3_0;
	wire [`MASK_WIDTH-1:0] bram_we_a_3_0;
	wire bram_en_a_3_0;
    
	wire [`AWIDTH-1:0] bram_addr_b_0_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_0_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_0_0;
	wire [`MASK_WIDTH-1:0] bram_we_b_0_0;
	wire bram_en_b_0_0;
    
	wire [`AWIDTH-1:0] bram_addr_b_0_1;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_0_1;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_0_1;
	wire [`MASK_WIDTH-1:0] bram_we_b_0_1;
	wire bram_en_b_0_1;
    
	wire [`AWIDTH-1:0] bram_addr_b_0_2;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_0_2;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_0_2;
	wire [`MASK_WIDTH-1:0] bram_we_b_0_2;
	wire bram_en_b_0_2;
    
	wire [`AWIDTH-1:0] bram_addr_b_0_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_0_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_0_3;
	wire [`MASK_WIDTH-1:0] bram_we_b_0_3;
	wire bram_en_b_0_3;
    
	wire [`AWIDTH-1:0] bram_addr_c_0_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_0_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_0_3;
	wire [`MASK_WIDTH-1:0] bram_we_c_0_3;
	wire bram_en_c_0_3;
    
	wire [`AWIDTH-1:0] bram_addr_c_1_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_1_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_1_3;
	wire [`MASK_WIDTH-1:0] bram_we_c_1_3;
	wire bram_en_c_1_3;
    
	wire [`AWIDTH-1:0] bram_addr_c_2_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_2_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_2_3;
	wire [`MASK_WIDTH-1:0] bram_we_c_2_3;
	wire bram_en_c_2_3;
    
	wire [`AWIDTH-1:0] bram_addr_c_3_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_3_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_3_3;
	wire [`MASK_WIDTH-1:0] bram_we_c_3_3;
	wire bram_en_c_3_3;
    
  always @* begin
    case (bram_select)
  
      0: begin
      bram_addr_a_0_0_ext = bram_addr_ext;
      bram_wdata_a_0_0_ext = bram_wdata_ext;
      bram_we_a_0_0_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_0_0_ext;
      end
    
      0: begin
      bram_addr_a_1_0_ext = bram_addr_ext;
      bram_wdata_a_1_0_ext = bram_wdata_ext;
      bram_we_a_1_0_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_1_0_ext;
      end
    
      0: begin
      bram_addr_a_2_0_ext = bram_addr_ext;
      bram_wdata_a_2_0_ext = bram_wdata_ext;
      bram_we_a_2_0_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_2_0_ext;
      end
    
      0: begin
      bram_addr_a_3_0_ext = bram_addr_ext;
      bram_wdata_a_3_0_ext = bram_wdata_ext;
      bram_we_a_3_0_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_3_0_ext;
      end
    
      1: begin
      bram_addr_b_0_0_ext = bram_addr_ext;
      bram_wdata_b_0_0_ext = bram_wdata_ext;
      bram_we_b_0_0_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_0_0_ext;
      end
    
      1: begin
      bram_addr_b_0_1_ext = bram_addr_ext;
      bram_wdata_b_0_1_ext = bram_wdata_ext;
      bram_we_b_0_1_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_0_1_ext;
      end
    
      1: begin
      bram_addr_b_0_2_ext = bram_addr_ext;
      bram_wdata_b_0_2_ext = bram_wdata_ext;
      bram_we_b_0_2_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_0_2_ext;
      end
    
      1: begin
      bram_addr_b_0_3_ext = bram_addr_ext;
      bram_wdata_b_0_3_ext = bram_wdata_ext;
      bram_we_b_0_3_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_0_3_ext;
      end
    
      2: begin
      bram_addr_c_0_3_ext = bram_addr_ext;
      bram_wdata_c_0_3_ext = bram_wdata_ext;
      bram_we_c_0_3_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_c_0_3_ext;
      end
    
      2: begin
      bram_addr_c_1_3_ext = bram_addr_ext;
      bram_wdata_c_1_3_ext = bram_wdata_ext;
      bram_we_c_1_3_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_c_1_3_ext;
      end
    
      2: begin
      bram_addr_c_2_3_ext = bram_addr_ext;
      bram_wdata_c_2_3_ext = bram_wdata_ext;
      bram_we_c_2_3_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_c_2_3_ext;
      end
    
      2: begin
      bram_addr_c_3_3_ext = bram_addr_ext;
      bram_wdata_c_3_3_ext = bram_wdata_ext;
      bram_we_c_3_3_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_c_3_3_ext;
      end
    
      default: begin
      bram_rdata_ext = 0;
      end
    endcase 
  end
  
/////////////////////////////////////////////////
// BRAMs to store matrix A
/////////////////////////////////////////////////


  // BRAM matrix A 0_0
ram matrix_A_0_0(
  .addr0(bram_addr_a_0_0),
  .d0(bram_wdata_a_0_0), 
  .we0(bram_we_a_0_0), 
  .q0(bram_rdata_a_0_0), 
  .addr1(bram_addr_a_0_0_ext),
  .d1(bram_wdata_a_0_0_ext), 
  .we1(bram_we_a_0_0_ext), 
  .q1(bram_rdata_a_0_0_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix A 1_0
ram matrix_A_1_0(
  .addr0(bram_addr_a_1_0),
  .d0(bram_wdata_a_1_0), 
  .we0(bram_we_a_1_0), 
  .q0(bram_rdata_a_1_0), 
  .addr1(bram_addr_a_1_0_ext),
  .d1(bram_wdata_a_1_0_ext), 
  .we1(bram_we_a_1_0_ext), 
  .q1(bram_rdata_a_1_0_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix A 2_0
ram matrix_A_2_0(
  .addr0(bram_addr_a_2_0),
  .d0(bram_wdata_a_2_0), 
  .we0(bram_we_a_2_0), 
  .q0(bram_rdata_a_2_0), 
  .addr1(bram_addr_a_2_0_ext),
  .d1(bram_wdata_a_2_0_ext), 
  .we1(bram_we_a_2_0_ext), 
  .q1(bram_rdata_a_2_0_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix A 3_0
ram matrix_A_3_0(
  .addr0(bram_addr_a_3_0),
  .d0(bram_wdata_a_3_0), 
  .we0(bram_we_a_3_0), 
  .q0(bram_rdata_a_3_0), 
  .addr1(bram_addr_a_3_0_ext),
  .d1(bram_wdata_a_3_0_ext), 
  .we1(bram_we_a_3_0_ext), 
  .q1(bram_rdata_a_3_0_ext), 
  .clk(clk_mem));
  	/////////////////////////////////////////////////
// BRAMs to store matrix B
/////////////////////////////////////////////////


  // BRAM matrix B 0_0
ram matrix_B_0_0(
  .addr0(bram_addr_b_0_0),
  .d0(bram_wdata_b_0_0), 
  .we0(bram_we_b_0_0), 
  .q0(bram_rdata_b_0_0), 
  .addr1(bram_addr_b_0_0_ext),
  .d1(bram_wdata_b_0_0_ext), 
  .we1(bram_we_b_0_0_ext), 
  .q1(bram_rdata_b_0_0_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix B 0_1
ram matrix_B_0_1(
  .addr0(bram_addr_b_0_1),
  .d0(bram_wdata_b_0_1), 
  .we0(bram_we_b_0_1), 
  .q0(bram_rdata_b_0_1), 
  .addr1(bram_addr_b_0_1_ext),
  .d1(bram_wdata_b_0_1_ext), 
  .we1(bram_we_b_0_1_ext), 
  .q1(bram_rdata_b_0_1_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix B 0_2
ram matrix_B_0_2(
  .addr0(bram_addr_b_0_2),
  .d0(bram_wdata_b_0_2), 
  .we0(bram_we_b_0_2), 
  .q0(bram_rdata_b_0_2), 
  .addr1(bram_addr_b_0_2_ext),
  .d1(bram_wdata_b_0_2_ext), 
  .we1(bram_we_b_0_2_ext), 
  .q1(bram_rdata_b_0_2_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix B 0_3
ram matrix_B_0_3(
  .addr0(bram_addr_b_0_3),
  .d0(bram_wdata_b_0_3), 
  .we0(bram_we_b_0_3), 
  .q0(bram_rdata_b_0_3), 
  .addr1(bram_addr_b_0_3_ext),
  .d1(bram_wdata_b_0_3_ext), 
  .we1(bram_we_b_0_3_ext), 
  .q1(bram_rdata_b_0_3_ext), 
  .clk(clk_mem));
  	/////////////////////////////////////////////////
// BRAMs to store matrix C
/////////////////////////////////////////////////


  // BRAM matrix C 0_3
ram matrix_C_0_3(
  .addr0(bram_addr_c_0_3),
  .d0(bram_wdata_c_0_3), 
  .we0(bram_we_c_0_3), 
  .q0(bram_rdata_c_0_3), 
  .addr1(bram_addr_c_0_3_ext),
  .d1(bram_wdata_c_0_3_ext), 
  .we1(bram_we_c_0_3_ext), 
  .q1(bram_rdata_c_0_3_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix C 1_3
ram matrix_C_1_3(
  .addr0(bram_addr_c_1_3),
  .d0(bram_wdata_c_1_3), 
  .we0(bram_we_c_1_3), 
  .q0(bram_rdata_c_1_3), 
  .addr1(bram_addr_c_1_3_ext),
  .d1(bram_wdata_c_1_3_ext), 
  .we1(bram_we_c_1_3_ext), 
  .q1(bram_rdata_c_1_3_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix C 2_3
ram matrix_C_2_3(
  .addr0(bram_addr_c_2_3),
  .d0(bram_wdata_c_2_3), 
  .we0(bram_we_c_2_3), 
  .q0(bram_rdata_c_2_3), 
  .addr1(bram_addr_c_2_3_ext),
  .d1(bram_wdata_c_2_3_ext), 
  .we1(bram_we_c_2_3_ext), 
  .q1(bram_rdata_c_2_3_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix C 3_3
ram matrix_C_3_3(
  .addr0(bram_addr_c_3_3),
  .d0(bram_wdata_c_3_3), 
  .we0(bram_we_c_3_3), 
  .q0(bram_rdata_c_3_3), 
  .addr1(bram_addr_c_3_3_ext),
  .d1(bram_wdata_c_3_3_ext), 
  .we1(bram_we_c_3_3_ext), 
  .q1(bram_rdata_c_3_3_ext), 
  .clk(clk_mem));
  	
reg start_mat_mul;
wire done_mat_mul;

reg [3:0] state;
	
////////////////////////////////////////////////////////////////
// Control logic
////////////////////////////////////////////////////////////////
	always @( posedge clk) begin
      if (resetn == 1'b0) begin
        state <= 4'b0000;
        start_mat_mul <= 1'b0;
      end 
      else begin
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

reg [1:0] state_apb;
`define IDLE     2'b00
`define W_ENABLE  2'b01
`define R_ENABLE  2'b10

reg [`AWIDTH-1:0] address_mat_a;
reg [`AWIDTH-1:0] address_mat_b;
reg [`AWIDTH-1:0] address_mat_c;
reg [`MASK_WIDTH-1:0] validity_mask_a_rows;
reg [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows;
reg [`MASK_WIDTH-1:0] validity_mask_b_cols;
reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_a;
reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_b;
reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_c;

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
    validity_mask_a_rows <= {`MASK_WIDTH{1'b1}};
    validity_mask_a_cols_b_rows <= {`MASK_WIDTH{1'b1}};
    validity_mask_b_cols <= {`MASK_WIDTH{1'b1}};
    address_stride_a <= `MAT_MUL_SIZE;
    address_stride_b <= `MAT_MUL_SIZE;
    address_stride_c <= `MAT_MUL_SIZE;
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
          `REG_START_DONE_ADDR : begin
                                 start_reg <= PWDATA[0];
                                 clear_done_reg <= PWDATA[31];
                                 end
          `REG_MATRIX_A_ADDR   : address_mat_a <= PWDATA[`AWIDTH-1:0];
          `REG_MATRIX_B_ADDR   : address_mat_b <= PWDATA[`AWIDTH-1:0];
          `REG_MATRIX_C_ADDR   : address_mat_c <= PWDATA[`AWIDTH-1:0];
          `REG_VALID_MASK_ADDR : begin
                                 validity_mask_a_rows <= PWDATA[`MASK_WIDTH-1:0];
                                 validity_mask_a_cols_b_rows <= PWDATA[2*`MASK_WIDTH-1:`MASK_WIDTH];
                                 validity_mask_b_cols <= PWDATA[3*`MASK_WIDTH-1:2*`MASK_WIDTH];
                                 end
          `REG_MATRIX_A_STRIDE_ADDR : address_stride_a <= PWDATA[`ADDR_STRIDE_WIDTH-1:0];
          `REG_MATRIX_B_STRIDE_ADDR : address_stride_b <= PWDATA[`ADDR_STRIDE_WIDTH-1:0];
          `REG_MATRIX_C_STRIDE_ADDR : address_stride_c <= PWDATA[`ADDR_STRIDE_WIDTH-1:0];
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
          `REG_START_DONE_ADDR  : PRDATA <= {done_mat_mul, 30'b0, start_mat_mul};
          `REG_MATRIX_A_ADDR    : PRDATA <= address_mat_a;
          `REG_MATRIX_B_ADDR    : PRDATA <= address_mat_b;
          `REG_MATRIX_C_ADDR    : PRDATA <= address_mat_c;
          `REG_VALID_MASK_ADDR  : PRDATA <= {validity_mask_b_cols, validity_mask_a_cols_b_rows, validity_mask_a_rows};
          `REG_MATRIX_A_STRIDE_ADDR : PRDATA <= address_stride_a;
          `REG_MATRIX_B_STRIDE_ADDR : PRDATA <= address_stride_b;
          `REG_MATRIX_C_STRIDE_ADDR : PRDATA <= address_stride_c;
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
  
  wire c_data_0_3_available;
  assign bram_en_c_0_3 = 1'b1;
  assign bram_we_c_0_3 = (c_data_0_3_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  
  	
  wire c_data_1_3_available;
  assign bram_en_c_1_3 = 1'b1;
  assign bram_we_c_1_3 = (c_data_1_3_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  
  	
  wire c_data_2_3_available;
  assign bram_en_c_2_3 = 1'b1;
  assign bram_we_c_2_3 = (c_data_2_3_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  
  	
  wire c_data_3_3_available;
  assign bram_en_c_3_3 = 1'b1;
  assign bram_we_c_3_3 = (c_data_3_3_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  
  	
  assign bram_wdata_a_0_0 = {`MAT_MUL_SIZE*`DWIDTH{1'b0}};
  assign bram_en_a_0_0 = 1'b1;
  assign bram_we_a_0_0 = {`MASK_WIDTH{1'b0}};
  	
  assign bram_wdata_a_1_0 = {`MAT_MUL_SIZE*`DWIDTH{1'b0}};
  assign bram_en_a_1_0 = 1'b1;
  assign bram_we_a_1_0 = {`MASK_WIDTH{1'b0}};
  	
  assign bram_wdata_a_2_0 = {`MAT_MUL_SIZE*`DWIDTH{1'b0}};
  assign bram_en_a_2_0 = 1'b1;
  assign bram_we_a_2_0 = {`MASK_WIDTH{1'b0}};
  	
  assign bram_wdata_a_3_0 = {`MAT_MUL_SIZE*`DWIDTH{1'b0}};
  assign bram_en_a_3_0 = 1'b1;
  assign bram_we_a_3_0 = {`MASK_WIDTH{1'b0}};
  	
  assign bram_wdata_b_0_0 = {`MAT_MUL_SIZE*`DWIDTH{1'b0}};
  assign bram_en_b_0_0 = 1'b1;
  assign bram_we_b_0_0 = {`MASK_WIDTH{1'b0}};

  	
  assign bram_wdata_b_0_1 = {`MAT_MUL_SIZE*`DWIDTH{1'b0}};
  assign bram_en_b_0_1 = 1'b1;
  assign bram_we_b_0_1 = {`MASK_WIDTH{1'b0}};

  	
  assign bram_wdata_b_0_2 = {`MAT_MUL_SIZE*`DWIDTH{1'b0}};
  assign bram_en_b_0_2 = 1'b1;
  assign bram_we_b_0_2 = {`MASK_WIDTH{1'b0}};

  	
  assign bram_wdata_b_0_3 = {`MAT_MUL_SIZE*`DWIDTH{1'b0}};
  assign bram_en_b_0_3 = 1'b1;
  assign bram_we_b_0_3 = {`MASK_WIDTH{1'b0}};

  	
/////////////////////////////////////////////////
// The 16x16 matmul instantiation
/////////////////////////////////////////////////


  matmul_16x16_systolic u_matmul_16x16_systolic (
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
  
  .a_data_0_0(bram_rdata_a_0_0),
  .b_data_0_0(bram_rdata_b_0_0),
  .a_addr_0_0(bram_addr_a_0_0),
  .b_addr_0_0(bram_addr_b_0_0),
  	
  .a_data_1_0(bram_rdata_a_1_0),
  .b_data_0_1(bram_rdata_b_0_1),
  .a_addr_1_0(bram_addr_a_1_0),
  .b_addr_0_1(bram_addr_b_0_1),
  	
  .a_data_2_0(bram_rdata_a_2_0),
  .b_data_0_2(bram_rdata_b_0_2),
  .a_addr_2_0(bram_addr_a_2_0),
  .b_addr_0_2(bram_addr_b_0_2),
  	
  .a_data_3_0(bram_rdata_a_3_0),
  .b_data_0_3(bram_rdata_b_0_3),
  .a_addr_3_0(bram_addr_a_3_0),
  .b_addr_0_3(bram_addr_b_0_3),
  	
  .c_data_0_3(bram_wdata_c_0_3),
  .c_addr_0_3(bram_addr_c_0_3),
  .c_data_0_3_available(c_data_0_3_available),
   		
  .c_data_1_3(bram_wdata_c_1_3),
  .c_addr_1_3(bram_addr_c_1_3),
  .c_data_1_3_available(c_data_1_3_available),
   		
  .c_data_2_3(bram_wdata_c_2_3),
  .c_addr_2_3(bram_addr_c_2_3),
  .c_data_2_3_available(c_data_2_3_available),
   		
  .c_data_3_3(bram_wdata_c_3_3),
  .c_addr_3_3(bram_addr_c_3_3),
  .c_data_3_3_available(c_data_3_3_available),
   		
  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols)
);
endmodule
  
/////////////////////////////////////////////////
// The 16x16 matmul definition
/////////////////////////////////////////////////


module matmul_16x16_systolic(
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
  
  input [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_0_0,
  output [`AWIDTH-1:0] a_addr_0_0,
  input [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0_0,
  output [`AWIDTH-1:0] b_addr_0_0,
  
  input [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_1_0,
  output [`AWIDTH-1:0] a_addr_1_0,
  input [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0_1,
  output [`AWIDTH-1:0] b_addr_0_1,
  
  input [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_2_0,
  output [`AWIDTH-1:0] a_addr_2_0,
  input [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0_2,
  output [`AWIDTH-1:0] b_addr_0_2,
  
  input [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_3_0,
  output [`AWIDTH-1:0] a_addr_3_0,
  input [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0_3,
  output [`AWIDTH-1:0] b_addr_0_3,
  
  output [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_0_3,
  output [`AWIDTH-1:0] c_addr_0_3,
  output c_data_0_3_available,
    
  output [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_1_3,
  output [`AWIDTH-1:0] c_addr_1_3,
  output c_data_1_3_available,
    
  output [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_2_3,
  output [`AWIDTH-1:0] c_addr_2_3,
  output c_data_2_3_available,
    
  output [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_3_3,
  output [`AWIDTH-1:0] c_addr_3_3,
  output c_data_3_3_available,
    
  input [`MASK_WIDTH-1:0] validity_mask_a_rows,
  input [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows,
  input [`MASK_WIDTH-1:0] validity_mask_b_cols
);
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

  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_0_0_to_0_1;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0_0_to_1_0;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_0_0_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in_0_0_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_0_0_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_0_0_to_0_1;
  wire [`AWIDTH-1:0] c_addr_0_0_NC;
  wire c_data_0_0_available_NC;

matmul_4x4_systolic u_matmul_4x4_systolic_0_0(
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
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
  .a_loc(8'd0),
  .b_loc(8'd0)
);

  /////////////////////////////////////////////////
  // Matmul 0_1
  /////////////////////////////////////////////////

  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_0_1_to_0_2;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0_1_to_1_1;
  wire [`AWIDTH-1:0] a_addr_0_1_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_0_1_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_0_1_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_0_1_to_0_2;
  wire [`AWIDTH-1:0] c_addr_0_1_NC;
  wire c_data_0_1_available_NC;

matmul_4x4_systolic u_matmul_4x4_systolic_0_1(
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
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
  .a_loc(8'd0),
  .b_loc(8'd1)
);

  /////////////////////////////////////////////////
  // Matmul 0_2
  /////////////////////////////////////////////////

  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_0_2_to_0_3;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0_2_to_1_2;
  wire [`AWIDTH-1:0] a_addr_0_2_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_0_2_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_0_2_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_0_2_to_0_3;
  wire [`AWIDTH-1:0] c_addr_0_2_NC;
  wire c_data_0_2_available_NC;

matmul_4x4_systolic u_matmul_4x4_systolic_0_2(
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
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
  .a_loc(8'd0),
  .b_loc(8'd2)
);

  /////////////////////////////////////////////////
  // Matmul 0_3
  /////////////////////////////////////////////////

  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_0_3_to_0_4;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0_3_to_1_3;
  wire [`AWIDTH-1:0] a_addr_0_3_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_0_3_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_0_3_NC;

matmul_4x4_systolic u_matmul_4x4_systolic_0_3(
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
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
  .a_loc(8'd0),
  .b_loc(8'd3)
);

  /////////////////////////////////////////////////
  // Matmul 1_0
  /////////////////////////////////////////////////

  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_1_0_to_1_1;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1_0_to_2_0;
  wire [`AWIDTH-1:0] b_addr_1_0_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1_0_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_1_0_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in_1_0_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_1_0_to_1_1;
  wire [`AWIDTH-1:0] c_addr_1_0_NC;
  wire c_data_1_0_available_NC;

matmul_4x4_systolic u_matmul_4x4_systolic_1_0(
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
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
  .a_loc(8'd1),
  .b_loc(8'd0)
);

  /////////////////////////////////////////////////
  // Matmul 1_1
  /////////////////////////////////////////////////

  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_1_1_to_1_2;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1_1_to_2_1;
  wire [`AWIDTH-1:0] a_addr_1_1_NC;
  wire [`AWIDTH-1:0] b_addr_1_1_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_1_1_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1_1_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_1_1_to_1_2;
  wire [`AWIDTH-1:0] c_addr_1_1_NC;
  wire c_data_1_1_available_NC;

matmul_4x4_systolic u_matmul_4x4_systolic_1_1(
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
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
  .a_loc(8'd1),
  .b_loc(8'd1)
);

  /////////////////////////////////////////////////
  // Matmul 1_2
  /////////////////////////////////////////////////

  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_1_2_to_1_3;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1_2_to_2_2;
  wire [`AWIDTH-1:0] a_addr_1_2_NC;
  wire [`AWIDTH-1:0] b_addr_1_2_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_1_2_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1_2_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_1_2_to_1_3;
  wire [`AWIDTH-1:0] c_addr_1_2_NC;
  wire c_data_1_2_available_NC;

matmul_4x4_systolic u_matmul_4x4_systolic_1_2(
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
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
  .a_loc(8'd1),
  .b_loc(8'd2)
);

  /////////////////////////////////////////////////
  // Matmul 1_3
  /////////////////////////////////////////////////

  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_1_3_to_1_4;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1_3_to_2_3;
  wire [`AWIDTH-1:0] a_addr_1_3_NC;
  wire [`AWIDTH-1:0] b_addr_1_3_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_1_3_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1_3_NC;

matmul_4x4_systolic u_matmul_4x4_systolic_1_3(
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
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
  .a_loc(8'd1),
  .b_loc(8'd3)
);

  /////////////////////////////////////////////////
  // Matmul 2_0
  /////////////////////////////////////////////////

  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_2_0_to_2_1;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_2_0_to_3_0;
  wire [`AWIDTH-1:0] b_addr_2_0_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_2_0_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_2_0_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in_2_0_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_2_0_to_2_1;
  wire [`AWIDTH-1:0] c_addr_2_0_NC;
  wire c_data_2_0_available_NC;

matmul_4x4_systolic u_matmul_4x4_systolic_2_0(
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
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
  .a_loc(8'd2),
  .b_loc(8'd0)
);

  /////////////////////////////////////////////////
  // Matmul 2_1
  /////////////////////////////////////////////////

  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_2_1_to_2_2;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_2_1_to_3_1;
  wire [`AWIDTH-1:0] a_addr_2_1_NC;
  wire [`AWIDTH-1:0] b_addr_2_1_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_2_1_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_2_1_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_2_1_to_2_2;
  wire [`AWIDTH-1:0] c_addr_2_1_NC;
  wire c_data_2_1_available_NC;

matmul_4x4_systolic u_matmul_4x4_systolic_2_1(
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
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
  .a_loc(8'd2),
  .b_loc(8'd1)
);

  /////////////////////////////////////////////////
  // Matmul 2_2
  /////////////////////////////////////////////////

  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_2_2_to_2_3;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_2_2_to_3_2;
  wire [`AWIDTH-1:0] a_addr_2_2_NC;
  wire [`AWIDTH-1:0] b_addr_2_2_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_2_2_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_2_2_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_2_2_to_2_3;
  wire [`AWIDTH-1:0] c_addr_2_2_NC;
  wire c_data_2_2_available_NC;

matmul_4x4_systolic u_matmul_4x4_systolic_2_2(
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
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
  .a_loc(8'd2),
  .b_loc(8'd2)
);

  /////////////////////////////////////////////////
  // Matmul 2_3
  /////////////////////////////////////////////////

  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_2_3_to_2_4;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_2_3_to_3_3;
  wire [`AWIDTH-1:0] a_addr_2_3_NC;
  wire [`AWIDTH-1:0] b_addr_2_3_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_2_3_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_2_3_NC;

matmul_4x4_systolic u_matmul_4x4_systolic_2_3(
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
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
  .a_loc(8'd2),
  .b_loc(8'd3)
);

  /////////////////////////////////////////////////
  // Matmul 3_0
  /////////////////////////////////////////////////

  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_3_0_to_3_1;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_3_0_to_4_0;
  wire [`AWIDTH-1:0] b_addr_3_0_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_3_0_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_3_0_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in_3_0_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_3_0_to_3_1;
  wire [`AWIDTH-1:0] c_addr_3_0_NC;
  wire c_data_3_0_available_NC;

matmul_4x4_systolic u_matmul_4x4_systolic_3_0(
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
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
  .a_loc(8'd3),
  .b_loc(8'd0)
);

  /////////////////////////////////////////////////
  // Matmul 3_1
  /////////////////////////////////////////////////

  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_3_1_to_3_2;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_3_1_to_4_1;
  wire [`AWIDTH-1:0] a_addr_3_1_NC;
  wire [`AWIDTH-1:0] b_addr_3_1_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_3_1_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_3_1_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_3_1_to_3_2;
  wire [`AWIDTH-1:0] c_addr_3_1_NC;
  wire c_data_3_1_available_NC;

matmul_4x4_systolic u_matmul_4x4_systolic_3_1(
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
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
  .a_loc(8'd3),
  .b_loc(8'd1)
);

  /////////////////////////////////////////////////
  // Matmul 3_2
  /////////////////////////////////////////////////

  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_3_2_to_3_3;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_3_2_to_4_2;
  wire [`AWIDTH-1:0] a_addr_3_2_NC;
  wire [`AWIDTH-1:0] b_addr_3_2_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_3_2_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_3_2_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_3_2_to_3_3;
  wire [`AWIDTH-1:0] c_addr_3_2_NC;
  wire c_data_3_2_available_NC;

matmul_4x4_systolic u_matmul_4x4_systolic_3_2(
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
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
  .a_loc(8'd3),
  .b_loc(8'd2)
);

  /////////////////////////////////////////////////
  // Matmul 3_3
  /////////////////////////////////////////////////

  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_3_3_to_3_4;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_3_3_to_4_3;
  wire [`AWIDTH-1:0] a_addr_3_3_NC;
  wire [`AWIDTH-1:0] b_addr_3_3_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_3_3_NC;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_3_3_NC;

matmul_4x4_systolic u_matmul_4x4_systolic_3_3(
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
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
  .a_loc(8'd3),
  .b_loc(8'd3)
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

  