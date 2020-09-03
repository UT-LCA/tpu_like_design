
`timescale 1ns/1ns
`define DWIDTH 8
`define AWIDTH 16
`define MEM_SIZE 1024

`define MAT_MUL_SIZE 8
`define MASK_WIDTH 8
`define LOG2_MAT_MUL_SIZE 3

`define BB_MAT_MUL_SIZE `MAT_MUL_SIZE
`define NUM_CYCLES_IN_MAC 3
`define MEM_ACCESS_LATENCY 1
`define REG_DATAWIDTH 32
`define REG_ADDRWIDTH 8
`define ADDR_STRIDE_WIDTH 16
`define MAX_BITS_POOL 3

//Design with memories
module matrix_multiplication(
  clk, 
  clk_mem, 
  resetn, 
  pe_resetn,
  address_mat_a,
  address_mat_b,
  address_mat_c,
  address_stride_a,
  address_stride_b,
  address_stride_c,
  validity_mask_a_rows,
  validity_mask_a_cols_b_rows,
  validity_mask_b_cols,
  bram_addr_a_ext,
  bram_rdata_a_ext,
  bram_wdata_a_ext,
  bram_we_a_ext,
  bram_addr_b_ext,
  bram_rdata_b_ext,
  bram_wdata_b_ext,
  bram_we_b_ext,
  bram_addr_c_ext,
  bram_rdata_c_ext,
  bram_wdata_c_ext,
  bram_we_c_ext,
  start_reg,
  clear_done_reg,
  slice_dtype,
  slice_mode,
  final_mat_mul_size,
  a_loc,
  b_loc,
  a_data_in,
  b_data_in,
  c_data_in
);

  input clk;
  input clk_mem;
  input resetn;
  input pe_resetn;
  input [`AWIDTH-1:0] address_mat_a;
  input [`AWIDTH-1:0] address_mat_b;
  input [`AWIDTH-1:0] address_mat_c;
  input [`ADDR_STRIDE_WIDTH-1:0] address_stride_a;
  input [`ADDR_STRIDE_WIDTH-1:0] address_stride_b;
  input [`ADDR_STRIDE_WIDTH-1:0] address_stride_c;
  input [`MASK_WIDTH-1:0] validity_mask_a_rows;
  input [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows;
  input [`MASK_WIDTH-1:0] validity_mask_b_cols;
  input  [`AWIDTH-1:0] bram_addr_a_ext;
  output [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_ext;
  input  [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_ext;
  input  [`MASK_WIDTH-1:0] bram_we_a_ext;
  input  [`AWIDTH-1:0] bram_addr_b_ext;
  output [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_ext;
  input  [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_ext;
  input  [`MASK_WIDTH-1:0] bram_we_b_ext;
  input  [`AWIDTH-1:0] bram_addr_c_ext;
  output [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_ext;
  input  [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_ext;
  input  [`MASK_WIDTH-1:0] bram_we_c_ext;
  input start_reg;
  input clear_done_reg;
  input slice_dtype;
  input slice_mode;
  input [7:0] final_mat_mul_size;
  input [7:0] a_loc;
  input [7:0] b_loc;
  input [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in;
  input [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in;
  input [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in;

	wire [`AWIDTH-1:0] bram_addr_a;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a;
	wire [`MASK_WIDTH-1:0] bram_we_a;
	wire bram_en_a;

	wire [`AWIDTH-1:0] bram_addr_b;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b;
	wire [`MASK_WIDTH-1:0] bram_we_b;
	wire bram_en_b;
	
	wire [`AWIDTH-1:0] bram_addr_c;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c;
	wire [`MASK_WIDTH-1:0] bram_we_c;
	wire bram_en_c;

  reg [3:0] state;

////////////////////////////////////////////////////////////////
// BRAM matrix A 
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
// BRAM matrix B 
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
// BRAM matrix C 
////////////////////////////////////////////////////////////////
ram matrix_C (
  .addr0(bram_addr_c),
  .d0(bram_wdata_c), 
  .we0(bram_we_c), 
  .q0(bram_rdata_c), 
  .addr1(bram_addr_c_ext),
  .d1(bram_wdata_c_ext), 
  .we1(bram_we_c_ext), 
  .q1(bram_rdata_c_ext), 
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

wire c_data_available;

//Connections for bram c (output matrix)
//bram_addr_c -> connected to u_matmul_4x4 block
//bram_rdata_c -> not used
//bram_wdata_c -> connected to u_matmul_4x4 block
//bram_we_c -> set to 1 when c_data is available
//bram_en_c -> hardcoded to 1 

  assign bram_en_c = 1'b1;
  assign bram_we_c = (c_data_available) ? 8'b11111111 : 8'b00000000;  

//Connections for bram a (first input matrix)
//bram_addr_a -> connected to u_matmul_4x4
//bram_rdata_a -> connected to u_matmul_4x4
//bram_wdata_a -> hardcoded to 0 (this block only reads from bram a)
//bram_we_a -> hardcoded to 0 (this block only reads from bram a)
//bram_en_a -> hardcoded to 1

  assign bram_wdata_a = 32'b0;
  assign bram_en_a = 1'b1;
  assign bram_we_a = 8'b0;
  
//Connections for bram b (second input matrix)
//bram_addr_b -> connected to u_matmul_4x4
//bram_rdata_b -> connected to u_matmul_4x4
//bram_wdata_b -> hardcoded to 0 (this block only reads from bram b)
//bram_we_b -> hardcoded to 0 (this block only reads from bram b)
//bram_en_b -> hardcoded to 1

  assign bram_wdata_b = 32'b0;
  assign bram_en_b = 1'b1;
  assign bram_we_b = 8'b0;
  
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out_NC;
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out_NC;
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_out_dir_int_NC;

wire reset;
assign reset = ~resetn;
wire pe_reset;
assign pe_reset = ~pe_resetn;

matmul_slice u_matmul_8x8(
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
  .a_data_in(a_data_in),
  .b_data_in(b_data_in),
  .c_data_in(c_data_in),
  .c_data_out(bram_wdata_c),
  .c_data_out_dir_int(c_data_out_dir_int_NC),
  .a_data_out(a_data_out_NC),
  .b_data_out(b_data_out_NC),
  .a_addr(bram_addr_a),
  .b_addr(bram_addr_b),
  .c_addr(bram_addr_c),
  .c_data_available(c_data_available),
  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .slice_dtype(slice_dtype),
  .slice_mode(slice_mode),
  .op(2'b01),
  .final_mat_mul_size(final_mat_mul_size),
  .a_loc(a_loc),
  .b_loc(b_loc)
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

