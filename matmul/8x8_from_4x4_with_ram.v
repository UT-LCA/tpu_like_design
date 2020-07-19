
`timescale 1ns/1ns
//`define DWIDTH 8
//`define AWIDTH 11
//`define MEM_SIZE 2048
//
//`define MAT_MUL_SIZE 8
//`define MASK_WIDTH 8
//`define LOG2_MAT_MUL_SIZE 3
//
//`define BB_MAT_MUL_SIZE `MAT_MUL_SIZE
//`define NUM_CYCLES_IN_MAC 3
//`define MEM_ACCESS_LATENCY 1
//`define REG_DATAWIDTH 32
//`define REG_ADDRWIDTH 8
//`define ADDR_STRIDE_WIDTH 8
//`define MAX_BITS_POOL 3

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
  validity_mask_a_rows,
  validity_mask_a_cols_b_rows,
  validity_mask_b_cols,

  bram_select,
  bram_addr_ext,
  bram_rdata_ext,
  bram_wdata_ext,
  bram_we_ext,

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
  input [`MASK_WIDTH-1:0] validity_mask_a_rows;
  input [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows;
  input [`MASK_WIDTH-1:0] validity_mask_b_cols;

  input [7:0] bram_select;

  input  [`AWIDTH-1:0] bram_addr_ext;
  output reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_ext;
  input  [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_ext;
  input  [`MASK_WIDTH-1:0] bram_we_ext;

  input start_reg;
  input clear_done_reg;

  reg [`AWIDTH-1:0] bram_addr_a_0_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_0_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_0_0_ext;
  reg [`MASK_WIDTH-1:0] bram_we_a_0_0_ext;

  reg [`AWIDTH-1:0] bram_addr_a_1_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_1_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_1_0_ext;
  reg [`MASK_WIDTH-1:0] bram_we_a_1_0_ext;

  reg [`AWIDTH-1:0] bram_addr_b_0_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_0_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_0_0_ext;
  reg [`MASK_WIDTH-1:0] bram_we_b_0_0_ext;

  reg [`AWIDTH-1:0] bram_addr_b_0_1_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_0_1_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_0_1_ext;
  reg [`MASK_WIDTH-1:0] bram_we_b_0_1_ext;

  reg [`AWIDTH-1:0] bram_addr_c_1_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_1_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_1_0_ext;
  reg [`MASK_WIDTH-1:0] bram_we_c_1_0_ext;

  reg [`AWIDTH-1:0] bram_addr_c_1_1_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_1_1_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_1_1_ext;
  reg [`MASK_WIDTH-1:0] bram_we_c_1_1_ext;

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
	
	wire [`AWIDTH-1:0] bram_addr_c_1_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_1_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_1_0;
	wire [`MASK_WIDTH-1:0] bram_we_c_1_0;
	wire bram_en_c_1_0;

	wire [`AWIDTH-1:0] bram_addr_c_1_1;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_1_1;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_1_1;
	wire [`MASK_WIDTH-1:0] bram_we_c_1_1;
	wire bram_en_c_1_1;

  always @* begin
    case (bram_select)
      0: begin
      bram_addr_a_0_0_ext = bram_addr_ext;
      bram_wdata_a_0_0_ext = bram_wdata_ext;
      bram_we_a_0_0_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_0_0_ext;
      end
      1: begin
      bram_addr_a_1_0_ext = bram_addr_ext;
      bram_wdata_a_1_0_ext = bram_wdata_ext;
      bram_we_a_1_0_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_1_0_ext;
      end
      2: begin
      bram_addr_b_0_0_ext = bram_addr_ext;
      bram_wdata_b_0_0_ext = bram_wdata_ext;
      bram_we_b_0_0_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_0_0_ext;
      end 
      3: begin
      bram_addr_b_0_1_ext = bram_addr_ext;
      bram_wdata_b_0_1_ext = bram_wdata_ext;
      bram_we_b_0_1_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_0_1_ext;
      end
      4: begin
      bram_addr_c_1_0_ext = bram_addr_ext;
      bram_wdata_c_1_0_ext = bram_wdata_ext;
      bram_we_c_1_0_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_c_1_0_ext;
      end
      5: begin
      bram_addr_c_1_1_ext = bram_addr_ext;
      bram_wdata_c_1_1_ext = bram_wdata_ext;
      bram_we_c_1_1_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_c_1_1_ext;
      end
      default: begin
      bram_addr_a_0_0_ext = bram_addr_ext;
      bram_wdata_a_0_0_ext = bram_wdata_ext;
      bram_we_a_0_0_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_0_0_ext;
      end
    endcase 
  end

  reg [3:0] state;

////////////////////////////////////////////////////////////////
// BRAM matrix A 
////////////////////////////////////////////////////////////////
ram matrix_A_0_0 (
  .addr0(bram_addr_a_0_0),
  .d0(bram_wdata_a_0_0), 
  .we0(bram_we_a_0_0), 
  .q0(bram_rdata_a_0_0), 
  .addr1(bram_addr_a_0_0_ext),
  .d1(bram_wdata_a_0_0_ext), 
  .we1(bram_we_a_0_0_ext), 
  .q1(bram_rdata_a_0_0_ext), 
  .clk(clk_mem));

ram matrix_A_1_0 (
  .addr0(bram_addr_a_1_0),
  .d0(bram_wdata_a_1_0), 
  .we0(bram_we_a_1_0), 
  .q0(bram_rdata_a_1_0), 
  .addr1(bram_addr_a_1_0_ext),
  .d1(bram_wdata_a_1_0_ext), 
  .we1(bram_we_a_1_0_ext), 
  .q1(bram_rdata_a_1_0_ext), 
  .clk(clk_mem));

////////////////////////////////////////////////////////////////
// BRAM matrix B 
////////////////////////////////////////////////////////////////
ram matrix_B_0_0 (
  .addr0(bram_addr_b_0_0),
  .d0(bram_wdata_b_0_0), 
  .we0(bram_we_b_0_0), 
  .q0(bram_rdata_b_0_0), 
  .addr1(bram_addr_b_0_0_ext),
  .d1(bram_wdata_b_0_0_ext), 
  .we1(bram_we_b_0_0_ext), 
  .q1(bram_rdata_b_0_0_ext), 
  .clk(clk_mem));

ram matrix_B_0_1 (
  .addr0(bram_addr_b_0_1),
  .d0(bram_wdata_b_0_1), 
  .we0(bram_we_b_0_1), 
  .q0(bram_rdata_b_0_1), 
  .addr1(bram_addr_b_0_1_ext),
  .d1(bram_wdata_b_0_1_ext), 
  .we1(bram_we_b_0_1_ext), 
  .q1(bram_rdata_b_0_1_ext), 
  .clk(clk_mem));

////////////////////////////////////////////////////////////////
// BRAM matrix C 
////////////////////////////////////////////////////////////////
ram matrix_C_1_0(
  .addr0(bram_addr_c_1_0),
  .d0(bram_wdata_c_1_0), 
  .we0(bram_we_c_1_0), 
  .q0(bram_rdata_c_1_0), 
  .addr1(bram_addr_c_1_0_ext),
  .d1(bram_wdata_c_1_0_ext), 
  .we1(bram_we_c_1_0_ext), 
  .q1(bram_rdata_c_1_0_ext), 
  .clk(clk_mem));

ram matrix_C_1_1(
  .addr0(bram_addr_c_1_1),
  .d0(bram_wdata_c_1_1), 
  .we0(bram_we_c_1_1), 
  .q0(bram_rdata_c_1_1), 
  .addr1(bram_addr_c_1_1_ext),
  .d1(bram_wdata_c_1_1_ext), 
  .we1(bram_we_c_1_1_ext), 
  .q1(bram_rdata_c_1_1_ext), 
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

  wire c_data_1_0_available;
  wire c_data_1_1_available;

//Connections for bram c (output matrix)
//bram_addr_c_1_0 -> connected to u_matmul_4x4 block
//bram_rdata_c_1_0 -> not used
//bram_wdata_c_1_0 -> connected to u_matmul_4x4 block
//bram_we_c_1_0 -> set to 1 when c_data is available
//bram_en_c -> hardcoded to 1 

  assign bram_en_c_1_0 = 1'b1;
  assign bram_we_c_1_0 = (c_data_1_0_available) ? 8'b11111111 : 8'b00000000;  

  assign bram_en_c_1_1 = 1'b1;
  assign bram_we_c_1_1 = (c_data_1_1_available) ? 8'b11111111 : 8'b00000000;  

//Connections for bram a (first input matrix)
//bram_addr_a_0_0 -> connected to u_matmul_4x4
//bram_rdata_a_0_0 -> connected to u_matmul_4x4
//bram_wdata_a_0_0 -> hardcoded to 0 (this block only reads from bram a)
//bram_we_a_0_0 -> hardcoded to 0 (this block only reads from bram a)
//bram_en_a -> hardcoded to 1

  assign bram_wdata_a_0_0 = 32'b0;
  assign bram_en_a_0_0 = 1'b1;
  assign bram_we_a_0_0 = 8'b0;
  
  assign bram_wdata_a_1_0 = 32'b0;
  assign bram_en_a_1_0 = 1'b1;
  assign bram_we_a_1_0 = 8'b0;
  
//Connections for bram b (second input matrix)
//bram_addr_b_0_0 -> connected to u_matmul_4x4
//bram_rdata_b_0_0 -> connected to u_matmul_4x4
//bram_wdata_b_0_0 -> hardcoded to 0 (this block only reads from bram b)
//bram_we_b_0_0 -> hardcoded to 0 (this block only reads from bram b)
//bram_en_b -> hardcoded to 1

  assign bram_wdata_b_0_0 = 32'b0;
  assign bram_en_b_0_0 = 1'b1;
  assign bram_we_b_0_0 = 8'b0;
  
  assign bram_wdata_b_0_1 = 32'b0;
  assign bram_en_b_0_1 = 1'b1;
  assign bram_we_b_0_1 = 8'b0;
  
wire reset;
assign reset = ~resetn;

matmul_8x8_systolic u_matmul_8x8(
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

  .a_data_0_0(bram_rdata_a_0_0),
  .b_data_0_0(bram_rdata_b_0_0),
  .a_data_1_0(bram_rdata_a_1_0),
  .b_data_0_1(bram_rdata_b_0_1),

  .a_addr_0_0(bram_addr_a_0_0),
  .b_addr_0_0(bram_addr_b_0_0),
  .a_addr_1_0(bram_addr_a_1_0),
  .b_addr_0_1(bram_addr_b_0_1),

  .c_data_1_0(bram_wdata_c_1_0),
  .c_data_1_1(bram_wdata_c_1_1),
  .c_addr_1_0(bram_addr_c_1_0),
  .c_addr_1_1(bram_addr_c_1_1),
  .c_data_1_0_available(c_data_1_0_available),
  .c_data_1_1_available(c_data_1_1_available),

  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols)
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

