
`timescale 1ns/1ns
`define DWIDTH 8 
`define AWIDTH 7
`define MEM_SIZE 128
`define MAT_MUL_SIZE 4
`define LOG2_MAT_MUL_SIZE 2
`define BB_MAT_MUL_SIZE `MAT_MUL_SIZE
`define NUM_CYCLES_IN_MAC 3

//Design with memories
module matrix_multiplication(
  clk, 
  clk_mem, 
  reset, 
  enable_writing_to_mem, 
  enable_reading_from_mem, 
  data_pi,
  addr_pi, 
  we_a,
  we_b,
  we_c,
  data_from_out_mat,
  start_mat_mul,
  done_mat_mul
);

  input clk;
  input clk_mem;
  input reset;
  input enable_writing_to_mem;
  input enable_reading_from_mem;
  input [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] data_pi;
  input [`AWIDTH-1:0] addr_pi;
  input we_a;
  input we_b;
  input we_c;
  output [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] data_from_out_mat;
  input start_mat_mul;
  output done_mat_mul;

  reg enable_writing_to_mem_reg;
  reg enable_reading_from_mem_reg;
  reg [`AWIDTH-1:0] addr_pi_reg;
  always @(posedge clk_mem) begin
    if (reset) begin
      enable_writing_to_mem_reg<= 0;
      enable_reading_from_mem_reg<= 0;
      addr_pi_reg <= 0;
    end else begin
      enable_writing_to_mem_reg<= enable_writing_to_mem;
      enable_reading_from_mem_reg<= enable_reading_from_mem;
      addr_pi_reg <= addr_pi;
    end
  end

  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data;
  reg [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_reg;
  wire [`AWIDTH-1:0] a_addr;
  wire [`AWIDTH-1:0] a_addr_muxed;

  reg [`AWIDTH-1:0] a_addr_reg;
  always @(posedge clk_mem) begin
    if (reset) begin
      a_addr_reg <= `MEM_SIZE-1; 
    end else begin
      a_addr_reg <= a_addr;
    end
  end

  reg [`AWIDTH-1:0] a_addr_muxed_reg;
  always @(posedge clk_mem) begin
    if (reset) begin
      a_addr_muxed_reg <= `MEM_SIZE-1; 
    end else begin
      a_addr_muxed_reg <= a_addr_muxed;
    end
  end
  assign a_addr_muxed = (enable_writing_to_mem_reg) ? addr_pi_reg : a_addr_reg;

  // BRAM matrix A 
  ram matrix_A (
    .addr0(a_addr_muxed_reg),
    .d0(data_pi), 
    .we0(we_a), 
    .q0(a_data), 
    .clk(clk_mem));

  always @(posedge clk_mem) begin
    if (reset) begin
      a_data_reg <= 0;
    end
    else begin
      a_data_reg <= a_data;
    end
  end

  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data;
  reg [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_reg;
  wire [`AWIDTH-1:0] b_addr;
  wire [`AWIDTH-1:0] b_addr_muxed;

  reg [`AWIDTH-1:0] b_addr_reg;
  always @(posedge clk_mem) begin
    if (reset) begin
      b_addr_reg <= `MEM_SIZE-1;
    end else begin
      b_addr_reg <= b_addr;
    end
  end

  reg [`AWIDTH-1:0] b_addr_muxed_reg;
  always @(posedge clk_mem) begin
    if (reset) begin
      b_addr_muxed_reg <= `MEM_SIZE-1;
    end else begin
      b_addr_muxed_reg <= b_addr_muxed;
    end
  end

  assign b_addr_muxed = (enable_writing_to_mem_reg) ? addr_pi_reg : b_addr_reg;

  // BRAM matrix B
  ram matrix_B (
    .addr0(b_addr_muxed_reg),
    .d0(data_pi), 
    .we0(we_b), 
    .q0(b_data), 
    .clk(clk_mem));

  always @(posedge clk_mem) begin
    if (reset) begin
      b_data_reg <= 0;
    end
    else begin
      b_data_reg <= b_data;
    end
  end

  reg  [`AWIDTH-1:0] c_addr;
  wire [`AWIDTH-1:0] c_addr_muxed;
  assign c_addr_muxed = (enable_reading_from_mem_reg) ? addr_pi_reg : c_addr;

  reg [`AWIDTH-1:0] c_addr_muxed_reg;
  always @(posedge clk_mem) begin
    if (reset) begin
      c_addr_muxed_reg <= 0;
    end else begin
      c_addr_muxed_reg <= c_addr_muxed;
    end
  end

  always @(posedge clk_mem) begin
    if (reset || done_mat_mul) begin
        c_addr <= 0;
    end
    else if (start_mat_mul) begin
        c_addr <= c_addr+1;
    end
  end
  
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_out;
  reg  [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_out_reg;
  
  always @(posedge clk_mem) begin
    if (reset) begin
      c_data_out_reg<= 0;
    end
    else if (start_mat_mul) begin
        c_data_out_reg<= c_data_out;
    end
  end

  reg [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] data_from_out_mat;
  wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] data_from_out_mat_temp;

  always @(posedge clk_mem) begin
    if(reset) begin
      data_from_out_mat <= 0;
    end else begin
      data_from_out_mat <= data_from_out_mat_temp;
    end
  end

  // BRAM matrix C
  ram matrix_C (
    .addr0(c_addr_muxed_reg),
    .d0(c_data_out_reg),
    .we0(we_c),
    .q0(data_from_out_mat_temp),
    .clk(clk_mem));

wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out_NC;
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out_NC;
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_NC;
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_NC;

matmul_4x4_systolic u_matmul_4x4(
  .clk(clk),
  .reset(reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul),
  .a_data(a_data_reg),
  .b_data(b_data_reg),
  .a_data_in(a_data_in_NC),
  .b_data_in(b_data_in_NC),
  .c_data_in({`BB_MAT_MUL_SIZE*`DWIDTH{1'b0}}),
  .c_data_out(c_data_out),
  .a_data_out(a_data_out_NC),
  .b_data_out(b_data_out_NC),
  .a_addr(a_addr),
  .b_addr(b_addr),
  .final_mat_mul_size(8'd4),
  .a_loc(8'd0),
  .b_loc(8'd0)
);

endmodule  


module ram (addr0, d0, we0, q0,  clk);

input [`AWIDTH-1:0] addr0;
input [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] d0;
input we0;
output [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] q0;
input clk;

//reg [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] q0;
//reg [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] ram[`MEM_SIZE-1:0];
//
//always @(posedge clk)  
//begin 
//        if (we0) 
//        begin 
//            ram[addr0] <= d0; 
//        end 
//        q0 <= ram[addr0];
//end

single_port_ram u_single_port_ram(
  .data(d0),
  .we(we0),
  .addr(addr0),
  .clk(clk),
  .out(q0)
);
endmodule

