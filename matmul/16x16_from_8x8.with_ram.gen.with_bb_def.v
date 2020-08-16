
`timescale 1ns/1ns
`define DWIDTH 8
`define AWIDTH 16
`define MEM_SIZE 2048
`define DESIGN_SIZE 16
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
`define REG_MATRIX_C_STRIDE_ADDR 32'h3

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
  input  [`MAT_MUL_SIZE-1:0] bram_we_ext
);


  reg start_reg;
  reg clear_done_reg;
  //Dummy register to sync all other invalid/unimplemented addresses
  reg [`REG_DATAWIDTH-1:0] reg_dummy;
  
  reg [`AWIDTH-1:0] bram_addr_a_0_0_ext;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_0_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_0_0_ext;
  reg [`MASK_WIDTH-1:0] bram_we_a_0_0_ext;
    
  reg [`AWIDTH-1:0] bram_addr_a_1_0_ext;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_1_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_1_0_ext;
  reg [`MASK_WIDTH-1:0] bram_we_a_1_0_ext;
    
  reg [`AWIDTH-1:0] bram_addr_b_0_0_ext;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_0_0_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_0_0_ext;
  reg [`MASK_WIDTH-1:0] bram_we_b_0_0_ext;
    
  reg [`AWIDTH-1:0] bram_addr_b_0_1_ext;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_0_1_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_0_1_ext;
  reg [`MASK_WIDTH-1:0] bram_we_b_0_1_ext;
    
  reg [`AWIDTH-1:0] bram_addr_c_0_1_ext;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_0_1_ext;
  reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_0_1_ext;
  reg [`MASK_WIDTH-1:0] bram_we_c_0_1_ext;
    
  reg [`AWIDTH-1:0] bram_addr_c_1_1_ext;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_1_1_ext;
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
    
	wire [`AWIDTH-1:0] bram_addr_c_0_1;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_0_1;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_0_1;
	wire [`MASK_WIDTH-1:0] bram_we_c_0_1;
	wire bram_en_c_0_1;
    
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
      bram_addr_c_0_1_ext = bram_addr_ext;
      bram_wdata_c_0_1_ext = bram_wdata_ext;
      bram_we_c_0_1_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_c_0_1_ext;
      end
    
      5: begin
      bram_addr_c_1_1_ext = bram_addr_ext;
      bram_wdata_c_1_1_ext = bram_wdata_ext;
      bram_we_c_1_1_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_c_1_1_ext;
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
  	/////////////////////////////////////////////////
// BRAMs to store matrix C
/////////////////////////////////////////////////


  // BRAM matrix C 0_1
ram matrix_C_0_1(
  .addr0(bram_addr_c_0_1),
  .d0(bram_wdata_c_0_1), 
  .we0(bram_we_c_0_1), 
  .q0(bram_rdata_c_0_1), 
  .addr1(bram_addr_c_0_1_ext),
  .d1(bram_wdata_c_0_1_ext), 
  .we1(bram_we_c_0_1_ext), 
  .q1(bram_rdata_c_0_1_ext), 
  .clk(clk_mem));
  	
  // BRAM matrix C 1_1
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
          `REG_STDN_TPU_ADDR   : begin
                                 start_reg <= PWDATA[0];
                                 clear_done_reg <= PWDATA[31];
                                 end
          `REG_MATRIX_A_ADDR   : address_mat_a <= PWDATA[`AWIDTH-1:0];
          `REG_MATRIX_B_ADDR   : address_mat_b <= PWDATA[`AWIDTH-1:0];
          `REG_MATRIX_C_ADDR   : address_mat_c <= PWDATA[`AWIDTH-1:0];
          `REG_VALID_MASK_A_ROWS_ADDR: begin
                                validity_mask_a_rows <= PWDATA[`MASK_WIDTH-1:0];
                                end
          `REG_VALID_MASK_A_COLS_B_ROWS_ADDR: begin
                                validity_mask_a_cols_b_rows <= PWDATA[`MASK_WIDTH-1:0];
                                end
          `REG_VALID_MASK_B_COLS_ADDR: begin
                                validity_mask_b_cols <= PWDATA[`MASK_WIDTH-1:0];
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
          `REG_STDN_TPU_ADDR  : PRDATA <= {done_mat_mul, 30'b0, start_mat_mul};
          `REG_MATRIX_A_ADDR    : PRDATA <= address_mat_a;
          `REG_MATRIX_B_ADDR    : PRDATA <= address_mat_b;
          `REG_MATRIX_C_ADDR    : PRDATA <= address_mat_c;
          `REG_VALID_MASK_A_ROWS_ADDR: PRDATA <= validity_mask_a_rows;
          `REG_VALID_MASK_A_COLS_B_ROWS_ADDR: PRDATA <= validity_mask_a_cols_b_rows;
          `REG_VALID_MASK_B_COLS_ADDR: PRDATA <= validity_mask_b_cols;
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
  
  wire c_data_0_1_available;
  assign bram_en_c_0_1 = 1'b1;
  assign bram_we_c_0_1 = (c_data_0_1_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  
  	
  wire c_data_1_1_available;
  assign bram_en_c_1_1 = 1'b1;
  assign bram_we_c_1_1 = (c_data_1_1_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  
  	
  assign bram_wdata_a_0_0 = {`MAT_MUL_SIZE*`DWIDTH{1'b0}};
  assign bram_en_a_0_0 = 1'b1;
  assign bram_we_a_0_0 = {`MASK_WIDTH{1'b0}};
  	
  assign bram_wdata_a_1_0 = {`MAT_MUL_SIZE*`DWIDTH{1'b0}};
  assign bram_en_a_1_0 = 1'b1;
  assign bram_we_a_1_0 = {`MASK_WIDTH{1'b0}};
  	
  assign bram_wdata_b_0_0 = {`MAT_MUL_SIZE*`DWIDTH{1'b0}};
  assign bram_en_b_0_0 = 1'b1;
  assign bram_we_b_0_0 = {`MASK_WIDTH{1'b0}};

  	
  assign bram_wdata_b_0_1 = {`MAT_MUL_SIZE*`DWIDTH{1'b0}};
  assign bram_en_b_0_1 = 1'b1;
  assign bram_we_b_0_1 = {`MASK_WIDTH{1'b0}};

  	
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
  	
  .c_data_0_1(bram_wdata_c_0_1),
  .c_addr_0_1(bram_addr_c_0_1),
  .c_data_0_1_available(c_data_0_1_available),
   		
  .c_data_1_1(bram_wdata_c_1_1),
  .c_addr_1_1(bram_addr_c_1_1),
  .c_data_1_1_available(c_data_1_1_available),
   		
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
  
  input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_0_0,
  output [`AWIDTH-1:0] a_addr_0_0,
  input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0_0,
  output [`AWIDTH-1:0] b_addr_0_0,
  
  input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_1_0,
  output [`AWIDTH-1:0] a_addr_1_0,
  input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0_1,
  output [`AWIDTH-1:0] b_addr_0_1,
  
  output [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_0_1,
  output [`AWIDTH-1:0] c_addr_0_1,
  output c_data_0_1_available,
    
  output [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_1_1,
  output [`AWIDTH-1:0] c_addr_1_1,
  output c_data_1_1_available,
    
  input [`MASK_WIDTH-1:0] validity_mask_a_rows,
  input [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows,
  input [`MASK_WIDTH-1:0] validity_mask_b_cols
);
    /////////////////////////////////////////////////
  // ORing all done signals
  /////////////////////////////////////////////////
  wire done_mat_mul_0_0;
  wire done_mat_mul_0_1;
  wire done_mat_mul_1_0;
  wire done_mat_mul_1_1;

  assign done_mat_mul = done_mat_mul_0_0;  /////////////////////////////////////////////////
  // Matmul 0_0
  /////////////////////////////////////////////////

  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_0_0_to_0_1;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_0_0_to_1_0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_0_0_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in_0_0_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_0_0_NC;
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
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
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
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_0_1_NC;

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
  .c_data_out(c_data_0_1),
  .a_data_out(a_data_0_1_to_0_2),
  .b_data_out(b_data_0_1_to_1_1),
  .a_addr(a_addr_0_1_NC),
  .b_addr(b_addr_0_1),
  .c_addr(c_addr_0_1),
  .c_data_available(c_data_0_1_available),

  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
  .a_loc(8'd0),
  .b_loc(8'd1)
);

  /////////////////////////////////////////////////
  // Matmul 1_0
  /////////////////////////////////////////////////

  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_1_0_to_1_1;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1_0_to_2_0;
  wire [`AWIDTH-1:0] b_addr_1_0_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1_0_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_1_0_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in_1_0_NC;
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
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
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
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_1_1_NC;

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
  .c_data_out(c_data_1_1),
  .a_data_out(a_data_1_1_to_1_2),
  .b_data_out(b_data_1_1_to_2_1),
  .a_addr(a_addr_1_1_NC),
  .b_addr(b_addr_1_1_NC),
  .c_addr(c_addr_1_1),
  .c_data_available(c_data_1_1_available),

  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .final_mat_mul_size(8'd16),
  .a_loc(8'd1),
  .b_loc(8'd1)
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

`ifdef VCS
reg [`MAT_MUL_SIZE*`DWIDTH-1:0] q0;
reg [`MAT_MUL_SIZE*`DWIDTH-1:0] q1;
reg [7:0] ram[((1<<`AWIDTH)-1):0];
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

  
`timescale 1ns / 1ps
/*
`define DWIDTH 8
`define AWIDTH 16
`define MEM_SIZE 2048

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
*/
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020-07-25 21:27:45.174821
// Design Name: 
// Module Name: matmul_8x8_systolic
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module matmul_8x8_systolic(
 clk,
 reset,
 pe_reset,
 start_mat_mul,
 done_mat_mul,
 address_mat_a,
 address_mat_b,
 address_mat_c,
 address_stride_a,
 address_stride_b,
 address_stride_c,
 a_data,
 b_data,
 a_data_in, //Data values coming in from previous matmul - systolic connections
 b_data_in,
 c_data_in, //Data values coming in from previous matmul - systolic shifting
 c_data_out, //Data values going out to next matmul - systolic shifting
 a_data_out,
 b_data_out,
 a_addr,
 b_addr,
 c_addr,
 c_data_available,

 validity_mask_a_rows,
 validity_mask_a_cols_b_rows,
 validity_mask_b_cols,
  
final_mat_mul_size,
  
 a_loc,
 b_loc
);

 input clk;
 input reset;
 input pe_reset;
 input start_mat_mul;
 output done_mat_mul;
 input [`AWIDTH-1:0] address_mat_a;
 input [`AWIDTH-1:0] address_mat_b;
 input [`AWIDTH-1:0] address_mat_c;
 input [`ADDR_STRIDE_WIDTH-1:0] address_stride_a;
 input [`ADDR_STRIDE_WIDTH-1:0] address_stride_b;
 input [`ADDR_STRIDE_WIDTH-1:0] address_stride_c;
 input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data;
 input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data;
 input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in;
 input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in;
 input [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in;
 output [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_out;
 output [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out;
 output [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out;
 output [`AWIDTH-1:0] a_addr;
 output [`AWIDTH-1:0] b_addr;
 output [`AWIDTH-1:0] c_addr;
 output c_data_available;

 input [`MASK_WIDTH-1:0] validity_mask_a_rows;
 input [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows;
 input [`MASK_WIDTH-1:0] validity_mask_b_cols;

//7:0 is okay here. We aren't going to make a matmul larger than 128x128
//In fact, these will get optimized out by the synthesis tool, because
//we hardcode them at the instantiation level.
 input [7:0] final_mat_mul_size;
  
 input [7:0] a_loc;
 input [7:0] b_loc;

//////////////////////////////////////////////////////////////////////////
// Logic for clock counting and when to assert done
//////////////////////////////////////////////////////////////////////////

reg done_mat_mul;
//This is 7 bits because the expectation is that clock count will be pretty
//small. For large matmuls, this will need to increased to have more bits.
//In general, a systolic multiplier takes 4*N-2+P cycles, where N is the size 
//of the matmul and P is the number of pipleine stages in the MAC block.
reg [7:0] clk_cnt;

//Finding out number of cycles to assert matmul done.
//When we have to save the outputs to accumulators, then we don't need to
//shift out data. So, we can assert done_mat_mul early.
//In the normal case, we have to include the time to shift out the results. 
//Note: the count expression used to contain "4*final_mat_mul_size", but 
//to avoid multiplication, we now use "final_mat_mul_size<<2"
wire [7:0] clk_cnt_for_done;

assign clk_cnt_for_done = 
                          ((final_mat_mul_size<<2) - 2 + `NUM_CYCLES_IN_MAC);  
    
always @(posedge clk) begin
  if (reset || ~start_mat_mul) begin
    clk_cnt <= 0;
    done_mat_mul <= 0;
  end
  else if (clk_cnt == clk_cnt_for_done) begin
    done_mat_mul <= 1;
    clk_cnt <= clk_cnt + 1;

  end
  else if (done_mat_mul == 0) begin
    clk_cnt <= clk_cnt + 1;

  end    
  else begin
    done_mat_mul <= 0;
    clk_cnt <= clk_cnt + 1;
  end
end
wire [`DWIDTH-1:0] a0_data;
wire [`DWIDTH-1:0] a1_data;
wire [`DWIDTH-1:0] a2_data;
wire [`DWIDTH-1:0] a3_data;
wire [`DWIDTH-1:0] a4_data;
wire [`DWIDTH-1:0] a5_data;
wire [`DWIDTH-1:0] a6_data;
wire [`DWIDTH-1:0] a7_data;
wire [`DWIDTH-1:0] b0_data;
wire [`DWIDTH-1:0] b1_data;
wire [`DWIDTH-1:0] b2_data;
wire [`DWIDTH-1:0] b3_data;
wire [`DWIDTH-1:0] b4_data;
wire [`DWIDTH-1:0] b5_data;
wire [`DWIDTH-1:0] b6_data;
wire [`DWIDTH-1:0] b7_data;
wire [`DWIDTH-1:0] a1_data_delayed_1;
wire [`DWIDTH-1:0] a2_data_delayed_1;
wire [`DWIDTH-1:0] a2_data_delayed_2;
wire [`DWIDTH-1:0] a3_data_delayed_1;
wire [`DWIDTH-1:0] a3_data_delayed_2;
wire [`DWIDTH-1:0] a3_data_delayed_3;
wire [`DWIDTH-1:0] a4_data_delayed_1;
wire [`DWIDTH-1:0] a4_data_delayed_2;
wire [`DWIDTH-1:0] a4_data_delayed_3;
wire [`DWIDTH-1:0] a4_data_delayed_4;
wire [`DWIDTH-1:0] a5_data_delayed_1;
wire [`DWIDTH-1:0] a5_data_delayed_2;
wire [`DWIDTH-1:0] a5_data_delayed_3;
wire [`DWIDTH-1:0] a5_data_delayed_4;
wire [`DWIDTH-1:0] a5_data_delayed_5;
wire [`DWIDTH-1:0] a6_data_delayed_1;
wire [`DWIDTH-1:0] a6_data_delayed_2;
wire [`DWIDTH-1:0] a6_data_delayed_3;
wire [`DWIDTH-1:0] a6_data_delayed_4;
wire [`DWIDTH-1:0] a6_data_delayed_5;
wire [`DWIDTH-1:0] a6_data_delayed_6;
wire [`DWIDTH-1:0] a7_data_delayed_1;
wire [`DWIDTH-1:0] a7_data_delayed_2;
wire [`DWIDTH-1:0] a7_data_delayed_3;
wire [`DWIDTH-1:0] a7_data_delayed_4;
wire [`DWIDTH-1:0] a7_data_delayed_5;
wire [`DWIDTH-1:0] a7_data_delayed_6;
wire [`DWIDTH-1:0] a7_data_delayed_7;
wire [`DWIDTH-1:0] b1_data_delayed_1;
wire [`DWIDTH-1:0] b2_data_delayed_1;
wire [`DWIDTH-1:0] b2_data_delayed_2;
wire [`DWIDTH-1:0] b3_data_delayed_1;
wire [`DWIDTH-1:0] b3_data_delayed_2;
wire [`DWIDTH-1:0] b3_data_delayed_3;
wire [`DWIDTH-1:0] b4_data_delayed_1;
wire [`DWIDTH-1:0] b4_data_delayed_2;
wire [`DWIDTH-1:0] b4_data_delayed_3;
wire [`DWIDTH-1:0] b4_data_delayed_4;
wire [`DWIDTH-1:0] b5_data_delayed_1;
wire [`DWIDTH-1:0] b5_data_delayed_2;
wire [`DWIDTH-1:0] b5_data_delayed_3;
wire [`DWIDTH-1:0] b5_data_delayed_4;
wire [`DWIDTH-1:0] b5_data_delayed_5;
wire [`DWIDTH-1:0] b6_data_delayed_1;
wire [`DWIDTH-1:0] b6_data_delayed_2;
wire [`DWIDTH-1:0] b6_data_delayed_3;
wire [`DWIDTH-1:0] b6_data_delayed_4;
wire [`DWIDTH-1:0] b6_data_delayed_5;
wire [`DWIDTH-1:0] b6_data_delayed_6;
wire [`DWIDTH-1:0] b7_data_delayed_1;
wire [`DWIDTH-1:0] b7_data_delayed_2;
wire [`DWIDTH-1:0] b7_data_delayed_3;
wire [`DWIDTH-1:0] b7_data_delayed_4;
wire [`DWIDTH-1:0] b7_data_delayed_5;
wire [`DWIDTH-1:0] b7_data_delayed_6;
wire [`DWIDTH-1:0] b7_data_delayed_7;


//////////////////////////////////////////////////////////////////////////
// Instantiation of systolic data setup
//////////////////////////////////////////////////////////////////////////
systolic_data_setup u_systolic_data_setup(
.clk(clk),
.reset(reset),
.start_mat_mul(start_mat_mul),
.a_addr(a_addr),
.b_addr(b_addr),
.address_mat_a(address_mat_a),
.address_mat_b(address_mat_b),
.address_stride_a(address_stride_a),
.address_stride_b(address_stride_b),
.a_data(a_data),
.b_data(b_data),
.clk_cnt(clk_cnt),
.a0_data(a0_data),
.b0_data(b0_data),
.a1_data_delayed_1(a1_data_delayed_1),
.b1_data_delayed_1(b1_data_delayed_1),
.a2_data_delayed_2(a2_data_delayed_2),
.b2_data_delayed_2(b2_data_delayed_2),
.a3_data_delayed_3(a3_data_delayed_3),
.b3_data_delayed_3(b3_data_delayed_3),
.a4_data_delayed_4(a4_data_delayed_4),
.b4_data_delayed_4(b4_data_delayed_4),
.a5_data_delayed_5(a5_data_delayed_5),
.b5_data_delayed_5(b5_data_delayed_5),
.a6_data_delayed_6(a6_data_delayed_6),
.b6_data_delayed_6(b6_data_delayed_6),
.a7_data_delayed_7(a7_data_delayed_7),
.b7_data_delayed_7(b7_data_delayed_7),

.validity_mask_a_rows(validity_mask_a_rows),
.validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
.validity_mask_b_cols(validity_mask_b_cols),

.final_mat_mul_size(final_mat_mul_size),
  
.a_loc(a_loc),
.b_loc(b_loc)
);

//////////////////////////////////////////////////////////////////////////
// Logic to mux data_in coming from neighboring matmuls
//////////////////////////////////////////////////////////////////////////
wire [`DWIDTH-1:0] a0;
wire [`DWIDTH-1:0] a1;
wire [`DWIDTH-1:0] a2;
wire [`DWIDTH-1:0] a3;
wire [`DWIDTH-1:0] a4;
wire [`DWIDTH-1:0] a5;
wire [`DWIDTH-1:0] a6;
wire [`DWIDTH-1:0] a7;
wire [`DWIDTH-1:0] b0;
wire [`DWIDTH-1:0] b1;
wire [`DWIDTH-1:0] b2;
wire [`DWIDTH-1:0] b3;
wire [`DWIDTH-1:0] b4;
wire [`DWIDTH-1:0] b5;
wire [`DWIDTH-1:0] b6;
wire [`DWIDTH-1:0] b7;

wire [`DWIDTH-1:0] a0_data_in;
wire [`DWIDTH-1:0] a1_data_in;
wire [`DWIDTH-1:0] a2_data_in;
wire [`DWIDTH-1:0] a3_data_in;
wire [`DWIDTH-1:0] a4_data_in;
wire [`DWIDTH-1:0] a5_data_in;
wire [`DWIDTH-1:0] a6_data_in;
wire [`DWIDTH-1:0] a7_data_in;

assign a0_data_in = a_data_in[1*`DWIDTH-1:0*`DWIDTH];
assign a1_data_in = a_data_in[2*`DWIDTH-1:1*`DWIDTH];
assign a2_data_in = a_data_in[3*`DWIDTH-1:2*`DWIDTH];
assign a3_data_in = a_data_in[4*`DWIDTH-1:3*`DWIDTH];
assign a4_data_in = a_data_in[5*`DWIDTH-1:4*`DWIDTH];
assign a5_data_in = a_data_in[6*`DWIDTH-1:5*`DWIDTH];
assign a6_data_in = a_data_in[7*`DWIDTH-1:6*`DWIDTH];
assign a7_data_in = a_data_in[8*`DWIDTH-1:7*`DWIDTH];

wire [`DWIDTH-1:0] b0_data_in;
wire [`DWIDTH-1:0] b1_data_in;
wire [`DWIDTH-1:0] b2_data_in;
wire [`DWIDTH-1:0] b3_data_in;
wire [`DWIDTH-1:0] b4_data_in;
wire [`DWIDTH-1:0] b5_data_in;
wire [`DWIDTH-1:0] b6_data_in;
wire [`DWIDTH-1:0] b7_data_in;

assign b0_data_in = b_data_in[1*`DWIDTH-1:0*`DWIDTH];
assign b1_data_in = b_data_in[2*`DWIDTH-1:1*`DWIDTH];
assign b2_data_in = b_data_in[3*`DWIDTH-1:2*`DWIDTH];
assign b3_data_in = b_data_in[4*`DWIDTH-1:3*`DWIDTH];
assign b4_data_in = b_data_in[5*`DWIDTH-1:4*`DWIDTH];
assign b5_data_in = b_data_in[6*`DWIDTH-1:5*`DWIDTH];
assign b6_data_in = b_data_in[7*`DWIDTH-1:6*`DWIDTH];
assign b7_data_in = b_data_in[8*`DWIDTH-1:7*`DWIDTH];

assign a0 = (b_loc==0) ? a0_data           : a0_data_in;
assign a1 = (b_loc==0) ? a1_data_delayed_1 : a1_data_in;
assign a2 = (b_loc==0) ? a2_data_delayed_2 : a2_data_in;
assign a3 = (b_loc==0) ? a3_data_delayed_3 : a3_data_in;
assign a4 = (b_loc==0) ? a4_data_delayed_4 : a4_data_in;
assign a5 = (b_loc==0) ? a5_data_delayed_5 : a5_data_in;
assign a6 = (b_loc==0) ? a6_data_delayed_6 : a6_data_in;
assign a7 = (b_loc==0) ? a7_data_delayed_7 : a7_data_in;

assign b0 = (a_loc==0) ? b0_data           : b0_data_in;
assign b1 = (a_loc==0) ? b1_data_delayed_1 : b1_data_in;
assign b2 = (a_loc==0) ? b2_data_delayed_2 : b2_data_in;
assign b3 = (a_loc==0) ? b3_data_delayed_3 : b3_data_in;
assign b4 = (a_loc==0) ? b4_data_delayed_4 : b4_data_in;
assign b5 = (a_loc==0) ? b5_data_delayed_5 : b5_data_in;
assign b6 = (a_loc==0) ? b6_data_delayed_6 : b6_data_in;
assign b7 = (a_loc==0) ? b7_data_delayed_7 : b7_data_in;

wire [`DWIDTH-1:0] matrixC0_0;
wire [`DWIDTH-1:0] matrixC0_1;
wire [`DWIDTH-1:0] matrixC0_2;
wire [`DWIDTH-1:0] matrixC0_3;
wire [`DWIDTH-1:0] matrixC0_4;
wire [`DWIDTH-1:0] matrixC0_5;
wire [`DWIDTH-1:0] matrixC0_6;
wire [`DWIDTH-1:0] matrixC0_7;
wire [`DWIDTH-1:0] matrixC1_0;
wire [`DWIDTH-1:0] matrixC1_1;
wire [`DWIDTH-1:0] matrixC1_2;
wire [`DWIDTH-1:0] matrixC1_3;
wire [`DWIDTH-1:0] matrixC1_4;
wire [`DWIDTH-1:0] matrixC1_5;
wire [`DWIDTH-1:0] matrixC1_6;
wire [`DWIDTH-1:0] matrixC1_7;
wire [`DWIDTH-1:0] matrixC2_0;
wire [`DWIDTH-1:0] matrixC2_1;
wire [`DWIDTH-1:0] matrixC2_2;
wire [`DWIDTH-1:0] matrixC2_3;
wire [`DWIDTH-1:0] matrixC2_4;
wire [`DWIDTH-1:0] matrixC2_5;
wire [`DWIDTH-1:0] matrixC2_6;
wire [`DWIDTH-1:0] matrixC2_7;
wire [`DWIDTH-1:0] matrixC3_0;
wire [`DWIDTH-1:0] matrixC3_1;
wire [`DWIDTH-1:0] matrixC3_2;
wire [`DWIDTH-1:0] matrixC3_3;
wire [`DWIDTH-1:0] matrixC3_4;
wire [`DWIDTH-1:0] matrixC3_5;
wire [`DWIDTH-1:0] matrixC3_6;
wire [`DWIDTH-1:0] matrixC3_7;
wire [`DWIDTH-1:0] matrixC4_0;
wire [`DWIDTH-1:0] matrixC4_1;
wire [`DWIDTH-1:0] matrixC4_2;
wire [`DWIDTH-1:0] matrixC4_3;
wire [`DWIDTH-1:0] matrixC4_4;
wire [`DWIDTH-1:0] matrixC4_5;
wire [`DWIDTH-1:0] matrixC4_6;
wire [`DWIDTH-1:0] matrixC4_7;
wire [`DWIDTH-1:0] matrixC5_0;
wire [`DWIDTH-1:0] matrixC5_1;
wire [`DWIDTH-1:0] matrixC5_2;
wire [`DWIDTH-1:0] matrixC5_3;
wire [`DWIDTH-1:0] matrixC5_4;
wire [`DWIDTH-1:0] matrixC5_5;
wire [`DWIDTH-1:0] matrixC5_6;
wire [`DWIDTH-1:0] matrixC5_7;
wire [`DWIDTH-1:0] matrixC6_0;
wire [`DWIDTH-1:0] matrixC6_1;
wire [`DWIDTH-1:0] matrixC6_2;
wire [`DWIDTH-1:0] matrixC6_3;
wire [`DWIDTH-1:0] matrixC6_4;
wire [`DWIDTH-1:0] matrixC6_5;
wire [`DWIDTH-1:0] matrixC6_6;
wire [`DWIDTH-1:0] matrixC6_7;
wire [`DWIDTH-1:0] matrixC7_0;
wire [`DWIDTH-1:0] matrixC7_1;
wire [`DWIDTH-1:0] matrixC7_2;
wire [`DWIDTH-1:0] matrixC7_3;
wire [`DWIDTH-1:0] matrixC7_4;
wire [`DWIDTH-1:0] matrixC7_5;
wire [`DWIDTH-1:0] matrixC7_6;
wire [`DWIDTH-1:0] matrixC7_7;


wire row_latch_en;

//////////////////////////////////////////////////////////////////////////
// Instantiation of the output logic
//////////////////////////////////////////////////////////////////////////
output_logic u_output_logic(
.start_mat_mul(start_mat_mul),
.done_mat_mul(done_mat_mul),
.address_mat_c(address_mat_c),
.address_stride_c(address_stride_c),
.c_data_out(c_data_out),
.c_data_in(c_data_in),
.c_addr(c_addr),
.c_data_available(c_data_available),
.clk_cnt(clk_cnt),
.row_latch_en(row_latch_en),

.final_mat_mul_size(final_mat_mul_size),
  .matrixC0_0(matrixC0_0),
.matrixC0_1(matrixC0_1),
.matrixC0_2(matrixC0_2),
.matrixC0_3(matrixC0_3),
.matrixC0_4(matrixC0_4),
.matrixC0_5(matrixC0_5),
.matrixC0_6(matrixC0_6),
.matrixC0_7(matrixC0_7),
.matrixC1_0(matrixC1_0),
.matrixC1_1(matrixC1_1),
.matrixC1_2(matrixC1_2),
.matrixC1_3(matrixC1_3),
.matrixC1_4(matrixC1_4),
.matrixC1_5(matrixC1_5),
.matrixC1_6(matrixC1_6),
.matrixC1_7(matrixC1_7),
.matrixC2_0(matrixC2_0),
.matrixC2_1(matrixC2_1),
.matrixC2_2(matrixC2_2),
.matrixC2_3(matrixC2_3),
.matrixC2_4(matrixC2_4),
.matrixC2_5(matrixC2_5),
.matrixC2_6(matrixC2_6),
.matrixC2_7(matrixC2_7),
.matrixC3_0(matrixC3_0),
.matrixC3_1(matrixC3_1),
.matrixC3_2(matrixC3_2),
.matrixC3_3(matrixC3_3),
.matrixC3_4(matrixC3_4),
.matrixC3_5(matrixC3_5),
.matrixC3_6(matrixC3_6),
.matrixC3_7(matrixC3_7),
.matrixC4_0(matrixC4_0),
.matrixC4_1(matrixC4_1),
.matrixC4_2(matrixC4_2),
.matrixC4_3(matrixC4_3),
.matrixC4_4(matrixC4_4),
.matrixC4_5(matrixC4_5),
.matrixC4_6(matrixC4_6),
.matrixC4_7(matrixC4_7),
.matrixC5_0(matrixC5_0),
.matrixC5_1(matrixC5_1),
.matrixC5_2(matrixC5_2),
.matrixC5_3(matrixC5_3),
.matrixC5_4(matrixC5_4),
.matrixC5_5(matrixC5_5),
.matrixC5_6(matrixC5_6),
.matrixC5_7(matrixC5_7),
.matrixC6_0(matrixC6_0),
.matrixC6_1(matrixC6_1),
.matrixC6_2(matrixC6_2),
.matrixC6_3(matrixC6_3),
.matrixC6_4(matrixC6_4),
.matrixC6_5(matrixC6_5),
.matrixC6_6(matrixC6_6),
.matrixC6_7(matrixC6_7),
.matrixC7_0(matrixC7_0),
.matrixC7_1(matrixC7_1),
.matrixC7_2(matrixC7_2),
.matrixC7_3(matrixC7_3),
.matrixC7_4(matrixC7_4),
.matrixC7_5(matrixC7_5),
.matrixC7_6(matrixC7_6),
.matrixC7_7(matrixC7_7),

.clk(clk),
.reset(reset)
);

//////////////////////////////////////////////////////////////////////////
// Instantiations of the actual PEs
//////////////////////////////////////////////////////////////////////////
systolic_pe_matrix u_systolic_pe_matrix(
.clk(clk),
.reset(reset),
.pe_reset(pe_reset),
.start_mat_mul(start_mat_mul),
.a0(a0),
.a1(a1),
.a2(a2),
.a3(a3),
.a4(a4),
.a5(a5),
.a6(a6),
.a7(a7),
.b0(b0),
.b1(b1),
.b2(b2),
.b3(b3),
.b4(b4),
.b5(b5),
.b6(b6),
.b7(b7),
.matrixC0_0(matrixC0_0),
.matrixC0_1(matrixC0_1),
.matrixC0_2(matrixC0_2),
.matrixC0_3(matrixC0_3),
.matrixC0_4(matrixC0_4),
.matrixC0_5(matrixC0_5),
.matrixC0_6(matrixC0_6),
.matrixC0_7(matrixC0_7),
.matrixC1_0(matrixC1_0),
.matrixC1_1(matrixC1_1),
.matrixC1_2(matrixC1_2),
.matrixC1_3(matrixC1_3),
.matrixC1_4(matrixC1_4),
.matrixC1_5(matrixC1_5),
.matrixC1_6(matrixC1_6),
.matrixC1_7(matrixC1_7),
.matrixC2_0(matrixC2_0),
.matrixC2_1(matrixC2_1),
.matrixC2_2(matrixC2_2),
.matrixC2_3(matrixC2_3),
.matrixC2_4(matrixC2_4),
.matrixC2_5(matrixC2_5),
.matrixC2_6(matrixC2_6),
.matrixC2_7(matrixC2_7),
.matrixC3_0(matrixC3_0),
.matrixC3_1(matrixC3_1),
.matrixC3_2(matrixC3_2),
.matrixC3_3(matrixC3_3),
.matrixC3_4(matrixC3_4),
.matrixC3_5(matrixC3_5),
.matrixC3_6(matrixC3_6),
.matrixC3_7(matrixC3_7),
.matrixC4_0(matrixC4_0),
.matrixC4_1(matrixC4_1),
.matrixC4_2(matrixC4_2),
.matrixC4_3(matrixC4_3),
.matrixC4_4(matrixC4_4),
.matrixC4_5(matrixC4_5),
.matrixC4_6(matrixC4_6),
.matrixC4_7(matrixC4_7),
.matrixC5_0(matrixC5_0),
.matrixC5_1(matrixC5_1),
.matrixC5_2(matrixC5_2),
.matrixC5_3(matrixC5_3),
.matrixC5_4(matrixC5_4),
.matrixC5_5(matrixC5_5),
.matrixC5_6(matrixC5_6),
.matrixC5_7(matrixC5_7),
.matrixC6_0(matrixC6_0),
.matrixC6_1(matrixC6_1),
.matrixC6_2(matrixC6_2),
.matrixC6_3(matrixC6_3),
.matrixC6_4(matrixC6_4),
.matrixC6_5(matrixC6_5),
.matrixC6_6(matrixC6_6),
.matrixC6_7(matrixC6_7),
.matrixC7_0(matrixC7_0),
.matrixC7_1(matrixC7_1),
.matrixC7_2(matrixC7_2),
.matrixC7_3(matrixC7_3),
.matrixC7_4(matrixC7_4),
.matrixC7_5(matrixC7_5),
.matrixC7_6(matrixC7_6),
.matrixC7_7(matrixC7_7),

.a_data_out(a_data_out),
.b_data_out(b_data_out)
);

endmodule


//////////////////////////////////////////////////////////////////////////
// Output logic
//////////////////////////////////////////////////////////////////////////
module output_logic(
start_mat_mul,
done_mat_mul,
address_mat_c,
address_stride_c,
c_data_in,
c_data_out, //Data values going out to next matmul - systolic shifting
c_addr,
c_data_available,
clk_cnt,
row_latch_en,

final_mat_mul_size,
  matrixC0_0,
matrixC0_1,
matrixC0_2,
matrixC0_3,
matrixC0_4,
matrixC0_5,
matrixC0_6,
matrixC0_7,
matrixC1_0,
matrixC1_1,
matrixC1_2,
matrixC1_3,
matrixC1_4,
matrixC1_5,
matrixC1_6,
matrixC1_7,
matrixC2_0,
matrixC2_1,
matrixC2_2,
matrixC2_3,
matrixC2_4,
matrixC2_5,
matrixC2_6,
matrixC2_7,
matrixC3_0,
matrixC3_1,
matrixC3_2,
matrixC3_3,
matrixC3_4,
matrixC3_5,
matrixC3_6,
matrixC3_7,
matrixC4_0,
matrixC4_1,
matrixC4_2,
matrixC4_3,
matrixC4_4,
matrixC4_5,
matrixC4_6,
matrixC4_7,
matrixC5_0,
matrixC5_1,
matrixC5_2,
matrixC5_3,
matrixC5_4,
matrixC5_5,
matrixC5_6,
matrixC5_7,
matrixC6_0,
matrixC6_1,
matrixC6_2,
matrixC6_3,
matrixC6_4,
matrixC6_5,
matrixC6_6,
matrixC6_7,
matrixC7_0,
matrixC7_1,
matrixC7_2,
matrixC7_3,
matrixC7_4,
matrixC7_5,
matrixC7_6,
matrixC7_7,

clk,
reset
);

input clk;
input reset;
input start_mat_mul;
input done_mat_mul;
input [`AWIDTH-1:0] address_mat_c;
input [`ADDR_STRIDE_WIDTH-1:0] address_stride_c;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_out;
output [`AWIDTH-1:0] c_addr;
output c_data_available;
input [7:0] clk_cnt;
output row_latch_en;

input [7:0] final_mat_mul_size;
  input [`DWIDTH-1:0] matrixC0_0;
input [`DWIDTH-1:0] matrixC0_1;
input [`DWIDTH-1:0] matrixC0_2;
input [`DWIDTH-1:0] matrixC0_3;
input [`DWIDTH-1:0] matrixC0_4;
input [`DWIDTH-1:0] matrixC0_5;
input [`DWIDTH-1:0] matrixC0_6;
input [`DWIDTH-1:0] matrixC0_7;
input [`DWIDTH-1:0] matrixC1_0;
input [`DWIDTH-1:0] matrixC1_1;
input [`DWIDTH-1:0] matrixC1_2;
input [`DWIDTH-1:0] matrixC1_3;
input [`DWIDTH-1:0] matrixC1_4;
input [`DWIDTH-1:0] matrixC1_5;
input [`DWIDTH-1:0] matrixC1_6;
input [`DWIDTH-1:0] matrixC1_7;
input [`DWIDTH-1:0] matrixC2_0;
input [`DWIDTH-1:0] matrixC2_1;
input [`DWIDTH-1:0] matrixC2_2;
input [`DWIDTH-1:0] matrixC2_3;
input [`DWIDTH-1:0] matrixC2_4;
input [`DWIDTH-1:0] matrixC2_5;
input [`DWIDTH-1:0] matrixC2_6;
input [`DWIDTH-1:0] matrixC2_7;
input [`DWIDTH-1:0] matrixC3_0;
input [`DWIDTH-1:0] matrixC3_1;
input [`DWIDTH-1:0] matrixC3_2;
input [`DWIDTH-1:0] matrixC3_3;
input [`DWIDTH-1:0] matrixC3_4;
input [`DWIDTH-1:0] matrixC3_5;
input [`DWIDTH-1:0] matrixC3_6;
input [`DWIDTH-1:0] matrixC3_7;
input [`DWIDTH-1:0] matrixC4_0;
input [`DWIDTH-1:0] matrixC4_1;
input [`DWIDTH-1:0] matrixC4_2;
input [`DWIDTH-1:0] matrixC4_3;
input [`DWIDTH-1:0] matrixC4_4;
input [`DWIDTH-1:0] matrixC4_5;
input [`DWIDTH-1:0] matrixC4_6;
input [`DWIDTH-1:0] matrixC4_7;
input [`DWIDTH-1:0] matrixC5_0;
input [`DWIDTH-1:0] matrixC5_1;
input [`DWIDTH-1:0] matrixC5_2;
input [`DWIDTH-1:0] matrixC5_3;
input [`DWIDTH-1:0] matrixC5_4;
input [`DWIDTH-1:0] matrixC5_5;
input [`DWIDTH-1:0] matrixC5_6;
input [`DWIDTH-1:0] matrixC5_7;
input [`DWIDTH-1:0] matrixC6_0;
input [`DWIDTH-1:0] matrixC6_1;
input [`DWIDTH-1:0] matrixC6_2;
input [`DWIDTH-1:0] matrixC6_3;
input [`DWIDTH-1:0] matrixC6_4;
input [`DWIDTH-1:0] matrixC6_5;
input [`DWIDTH-1:0] matrixC6_6;
input [`DWIDTH-1:0] matrixC6_7;
input [`DWIDTH-1:0] matrixC7_0;
input [`DWIDTH-1:0] matrixC7_1;
input [`DWIDTH-1:0] matrixC7_2;
input [`DWIDTH-1:0] matrixC7_3;
input [`DWIDTH-1:0] matrixC7_4;
input [`DWIDTH-1:0] matrixC7_5;
input [`DWIDTH-1:0] matrixC7_6;
input [`DWIDTH-1:0] matrixC7_7;
wire row_latch_en;


//////////////////////////////////////////////////////////////////////////
// Logic to capture matrix C data from the PEs and shift it out
//////////////////////////////////////////////////////////////////////////
//assign row_latch_en = (clk_cnt==(`MAT_MUL_SIZE + (a_loc+b_loc) * `BB_MAT_MUL_SIZE + 10 +  `NUM_CYCLES_IN_MAC - 1));
//Writing the line above to avoid multiplication:
//assign row_latch_en = (clk_cnt==(`MAT_MUL_SIZE + ((a_loc+b_loc) << `LOG2_MAT_MUL_SIZE) + 10 +  `NUM_CYCLES_IN_MAC - 1));

assign row_latch_en =  
                       ((clk_cnt == ((final_mat_mul_size<<2) - final_mat_mul_size - 1 +`NUM_CYCLES_IN_MAC)));
    
reg c_data_available;
reg [`AWIDTH-1:0] c_addr;
reg start_capturing_c_data;
integer counter;
reg [8*`DWIDTH-1:0] c_data_out;
reg [8*`DWIDTH-1:0] c_data_out_1;
reg [8*`DWIDTH-1:0] c_data_out_2;
reg [8*`DWIDTH-1:0] c_data_out_3;
reg [8*`DWIDTH-1:0] c_data_out_4;
reg [8*`DWIDTH-1:0] c_data_out_5;
reg [8*`DWIDTH-1:0] c_data_out_6;
reg [8*`DWIDTH-1:0] c_data_out_7;
wire condition_to_start_shifting_output;
assign condition_to_start_shifting_output = 
                          row_latch_en ;  

  
//For larger matmuls, this logic will have more entries in the case statement
always @(posedge clk) begin
  if (reset | ~start_mat_mul) begin
    start_capturing_c_data <= 1'b0;
    c_data_available <= 1'b0;
    c_addr <= address_mat_c + address_stride_c;
    c_data_out <= 0;
    counter <= 0;

    c_data_out_1 <= 0;
    c_data_out_2 <= 0;
    c_data_out_3 <= 0;
    c_data_out_4 <= 0;
    c_data_out_5 <= 0;
    c_data_out_6 <= 0;
    c_data_out_7 <= 0;
  end else if (condition_to_start_shifting_output) begin
    start_capturing_c_data <= 1'b1;
    c_data_available <= 1'b1;
    c_addr <= c_addr - address_stride_c;
    c_data_out <= {matrixC7_7, matrixC6_7, matrixC5_7, matrixC4_7, matrixC3_7, matrixC2_7, matrixC1_7, matrixC0_7};
      c_data_out_1 <= {matrixC7_6, matrixC6_6, matrixC5_6, matrixC4_6, matrixC3_6, matrixC2_6, matrixC1_6, matrixC0_6};
      c_data_out_2 <= {matrixC7_5, matrixC6_5, matrixC5_5, matrixC4_5, matrixC3_5, matrixC2_5, matrixC1_5, matrixC0_5};
      c_data_out_3 <= {matrixC7_4, matrixC6_4, matrixC5_4, matrixC4_4, matrixC3_4, matrixC2_4, matrixC1_4, matrixC0_4};
      c_data_out_4 <= {matrixC7_3, matrixC6_3, matrixC5_3, matrixC4_3, matrixC3_3, matrixC2_3, matrixC1_3, matrixC0_3};
      c_data_out_5 <= {matrixC7_2, matrixC6_2, matrixC5_2, matrixC4_2, matrixC3_2, matrixC2_2, matrixC1_2, matrixC0_2};
      c_data_out_6 <= {matrixC7_1, matrixC6_1, matrixC5_1, matrixC4_1, matrixC3_1, matrixC2_1, matrixC1_1, matrixC0_1};
      c_data_out_7 <= {matrixC7_0, matrixC6_0, matrixC5_0, matrixC4_0, matrixC3_0, matrixC2_0, matrixC1_0, matrixC0_0};

    counter <= counter + 1;
  end else if (done_mat_mul) begin
    start_capturing_c_data <= 1'b0;
    c_data_available <= 1'b0;
    c_addr <= address_mat_c + address_stride_c;
    c_data_out <= 0;

    c_data_out_1 <= 0;
    c_data_out_2 <= 0;
    c_data_out_3 <= 0;
    c_data_out_4 <= 0;
    c_data_out_5 <= 0;
    c_data_out_6 <= 0;
    c_data_out_7 <= 0;
  end 
  else if (counter >= `MAT_MUL_SIZE) begin
    c_data_out <= c_data_out_1;
    c_addr <= c_addr - address_stride_c; 

    c_data_out_1 <= c_data_out_2;
    c_data_out_2 <= c_data_out_3;
    c_data_out_3 <= c_data_out_4;
    c_data_out_4 <= c_data_out_5;
    c_data_out_5 <= c_data_out_6;
    c_data_out_6 <= c_data_out_7;
    c_data_out_7 <= c_data_in;
  end
  else if (start_capturing_c_data) begin
    c_data_available <= 1'b1;
    c_addr <= c_addr - address_stride_c; 
    counter <= counter + 1;
    c_data_out <= c_data_out_1;

    c_data_out_1 <= c_data_out_2;
    c_data_out_2 <= c_data_out_3;
    c_data_out_3 <= c_data_out_4;
    c_data_out_4 <= c_data_out_5;
    c_data_out_5 <= c_data_out_6;
    c_data_out_6 <= c_data_out_7;
    c_data_out_7 <= c_data_in;
  end
end

endmodule


//////////////////////////////////////////////////////////////////////////
// Systolic data setup
//////////////////////////////////////////////////////////////////////////
module systolic_data_setup(
clk,
reset,
start_mat_mul,
a_addr,
b_addr,
address_mat_a,
address_mat_b,
address_stride_a,
address_stride_b,
a_data,
b_data,
clk_cnt,
a0_data,
b0_data,
a1_data_delayed_1,
b1_data_delayed_1,
a2_data_delayed_2,
b2_data_delayed_2,
a3_data_delayed_3,
b3_data_delayed_3,
a4_data_delayed_4,
b4_data_delayed_4,
a5_data_delayed_5,
b5_data_delayed_5,
a6_data_delayed_6,
b6_data_delayed_6,
a7_data_delayed_7,
b7_data_delayed_7,

validity_mask_a_rows,
validity_mask_a_cols_b_rows,
validity_mask_b_cols,

final_mat_mul_size,
  
a_loc,
b_loc
);

input clk;
input reset;
input start_mat_mul;
output [`AWIDTH-1:0] a_addr;
output [`AWIDTH-1:0] b_addr;
input [`AWIDTH-1:0] address_mat_a;
input [`AWIDTH-1:0] address_mat_b;
input [`ADDR_STRIDE_WIDTH-1:0] address_stride_a;
input [`ADDR_STRIDE_WIDTH-1:0] address_stride_b;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data;
input [7:0] clk_cnt;
output [`DWIDTH-1:0] a0_data;
output [`DWIDTH-1:0] b0_data;
output [`DWIDTH-1:0] a1_data_delayed_1;
output [`DWIDTH-1:0] b1_data_delayed_1;
output [`DWIDTH-1:0] a2_data_delayed_2;
output [`DWIDTH-1:0] b2_data_delayed_2;
output [`DWIDTH-1:0] a3_data_delayed_3;
output [`DWIDTH-1:0] b3_data_delayed_3;
output [`DWIDTH-1:0] a4_data_delayed_4;
output [`DWIDTH-1:0] b4_data_delayed_4;
output [`DWIDTH-1:0] a5_data_delayed_5;
output [`DWIDTH-1:0] b5_data_delayed_5;
output [`DWIDTH-1:0] a6_data_delayed_6;
output [`DWIDTH-1:0] b6_data_delayed_6;
output [`DWIDTH-1:0] a7_data_delayed_7;
output [`DWIDTH-1:0] b7_data_delayed_7;

input [`MASK_WIDTH-1:0] validity_mask_a_rows;
input [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows;
input [`MASK_WIDTH-1:0] validity_mask_b_cols;

input [7:0] final_mat_mul_size;
  
input [7:0] a_loc;
input [7:0] b_loc;
wire [`DWIDTH-1:0] a0_data;
wire [`DWIDTH-1:0] a1_data;
wire [`DWIDTH-1:0] a2_data;
wire [`DWIDTH-1:0] a3_data;
wire [`DWIDTH-1:0] a4_data;
wire [`DWIDTH-1:0] a5_data;
wire [`DWIDTH-1:0] a6_data;
wire [`DWIDTH-1:0] a7_data;
wire [`DWIDTH-1:0] b0_data;
wire [`DWIDTH-1:0] b1_data;
wire [`DWIDTH-1:0] b2_data;
wire [`DWIDTH-1:0] b3_data;
wire [`DWIDTH-1:0] b4_data;
wire [`DWIDTH-1:0] b5_data;
wire [`DWIDTH-1:0] b6_data;
wire [`DWIDTH-1:0] b7_data;

//////////////////////////////////////////////////////////////////////////
// Logic to generate addresses to BRAM A
//////////////////////////////////////////////////////////////////////////
reg [`AWIDTH-1:0] a_addr;
reg a_mem_access; //flag that tells whether the matmul is trying to access memory or not

always @(posedge clk) begin
  //(clk_cnt >= a_loc*`MAT_MUL_SIZE+final_mat_mul_size) begin
  //Writing the line above to avoid multiplication:

  if (reset || ~start_mat_mul || (clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin
  
      a_addr <= address_mat_a-address_stride_a;
  
    a_mem_access <= 0;
  end
  //else if ((clk_cnt >= a_loc*`MAT_MUL_SIZE) && (clk_cnt < a_loc*`MAT_MUL_SIZE+final_mat_mul_size)) begin
  //Writing the line above to avoid multiplication:

  else if ((clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)) && (clk_cnt < (a_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin
  
      a_addr <= a_addr + address_stride_a;
  
    a_mem_access <= 1;
  end
end

//////////////////////////////////////////////////////////////////////////
// Logic to generate valid signals for data coming from BRAM A
//////////////////////////////////////////////////////////////////////////
reg [7:0] a_mem_access_counter;
always @(posedge clk) begin
  if (reset || ~start_mat_mul) begin
    a_mem_access_counter <= 0;
  end
  else if (a_mem_access == 1) begin
    a_mem_access_counter <= a_mem_access_counter + 1;  
  end
  else begin
    a_mem_access_counter <= 0;
  end
end

wire a_data_valid; //flag that tells whether the data from memory is valid
assign a_data_valid = 
     ((validity_mask_a_cols_b_rows[0]==1'b0 && a_mem_access_counter==1) ||
      (validity_mask_a_cols_b_rows[1]==1'b0 && a_mem_access_counter==2) ||
      (validity_mask_a_cols_b_rows[2]==1'b0 && a_mem_access_counter==3) ||
      (validity_mask_a_cols_b_rows[3]==1'b0 && a_mem_access_counter==4) ||
      (validity_mask_a_cols_b_rows[4]==1'b0 && a_mem_access_counter==5) ||
      (validity_mask_a_cols_b_rows[5]==1'b0 && a_mem_access_counter==6) ||
      (validity_mask_a_cols_b_rows[6]==1'b0 && a_mem_access_counter==7) ||
      (validity_mask_a_cols_b_rows[7]==1'b0 && a_mem_access_counter==8)) ?
    
    1'b0 : (a_mem_access_counter >= `MEM_ACCESS_LATENCY);

//////////////////////////////////////////////////////////////////////////
// Logic to delay certain parts of the data received from BRAM A (systolic data setup)
//////////////////////////////////////////////////////////////////////////
assign a0_data = a_data[1*`DWIDTH-1:0*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[0]}};
assign a1_data = a_data[2*`DWIDTH-1:1*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[1]}};
assign a2_data = a_data[3*`DWIDTH-1:2*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[2]}};
assign a3_data = a_data[4*`DWIDTH-1:3*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[3]}};
assign a4_data = a_data[5*`DWIDTH-1:4*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[4]}};
assign a5_data = a_data[6*`DWIDTH-1:5*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[5]}};
assign a6_data = a_data[7*`DWIDTH-1:6*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[6]}};
assign a7_data = a_data[8*`DWIDTH-1:7*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[7]}};

reg [`DWIDTH-1:0] a1_data_delayed_1;
reg [`DWIDTH-1:0] a2_data_delayed_1;
reg [`DWIDTH-1:0] a2_data_delayed_2;
reg [`DWIDTH-1:0] a3_data_delayed_1;
reg [`DWIDTH-1:0] a3_data_delayed_2;
reg [`DWIDTH-1:0] a3_data_delayed_3;
reg [`DWIDTH-1:0] a4_data_delayed_1;
reg [`DWIDTH-1:0] a4_data_delayed_2;
reg [`DWIDTH-1:0] a4_data_delayed_3;
reg [`DWIDTH-1:0] a4_data_delayed_4;
reg [`DWIDTH-1:0] a5_data_delayed_1;
reg [`DWIDTH-1:0] a5_data_delayed_2;
reg [`DWIDTH-1:0] a5_data_delayed_3;
reg [`DWIDTH-1:0] a5_data_delayed_4;
reg [`DWIDTH-1:0] a5_data_delayed_5;
reg [`DWIDTH-1:0] a6_data_delayed_1;
reg [`DWIDTH-1:0] a6_data_delayed_2;
reg [`DWIDTH-1:0] a6_data_delayed_3;
reg [`DWIDTH-1:0] a6_data_delayed_4;
reg [`DWIDTH-1:0] a6_data_delayed_5;
reg [`DWIDTH-1:0] a6_data_delayed_6;
reg [`DWIDTH-1:0] a7_data_delayed_1;
reg [`DWIDTH-1:0] a7_data_delayed_2;
reg [`DWIDTH-1:0] a7_data_delayed_3;
reg [`DWIDTH-1:0] a7_data_delayed_4;
reg [`DWIDTH-1:0] a7_data_delayed_5;
reg [`DWIDTH-1:0] a7_data_delayed_6;
reg [`DWIDTH-1:0] a7_data_delayed_7;


always @(posedge clk) begin
  if (reset || ~start_mat_mul || clk_cnt==0) begin
    a1_data_delayed_1 <= 0;
    a2_data_delayed_1 <= 0;
    a2_data_delayed_2 <= 0;
    a3_data_delayed_1 <= 0;
    a3_data_delayed_2 <= 0;
    a3_data_delayed_3 <= 0;
    a4_data_delayed_1 <= 0;
    a4_data_delayed_2 <= 0;
    a4_data_delayed_3 <= 0;
    a4_data_delayed_4 <= 0;
    a5_data_delayed_1 <= 0;
    a5_data_delayed_2 <= 0;
    a5_data_delayed_3 <= 0;
    a5_data_delayed_4 <= 0;
    a5_data_delayed_5 <= 0;
    a6_data_delayed_1 <= 0;
    a6_data_delayed_2 <= 0;
    a6_data_delayed_3 <= 0;
    a6_data_delayed_4 <= 0;
    a6_data_delayed_5 <= 0;
    a6_data_delayed_6 <= 0;
    a7_data_delayed_1 <= 0;
    a7_data_delayed_2 <= 0;
    a7_data_delayed_3 <= 0;
    a7_data_delayed_4 <= 0;
    a7_data_delayed_5 <= 0;
    a7_data_delayed_6 <= 0;
    a7_data_delayed_7 <= 0;

  end
  else begin
  a1_data_delayed_1 <= a1_data;
  a2_data_delayed_1 <= a2_data;
  a3_data_delayed_1 <= a3_data;
  a4_data_delayed_1 <= a4_data;
  a5_data_delayed_1 <= a5_data;
  a6_data_delayed_1 <= a6_data;
  a7_data_delayed_1 <= a7_data;
  a2_data_delayed_2 <= a2_data_delayed_1;
  a3_data_delayed_2 <= a3_data_delayed_1;
  a3_data_delayed_3 <= a3_data_delayed_2;
  a4_data_delayed_2 <= a4_data_delayed_1;
  a4_data_delayed_3 <= a4_data_delayed_2;
  a4_data_delayed_4 <= a4_data_delayed_3;
  a5_data_delayed_2 <= a5_data_delayed_1;
  a5_data_delayed_3 <= a5_data_delayed_2;
  a5_data_delayed_4 <= a5_data_delayed_3;
  a5_data_delayed_5 <= a5_data_delayed_4;
  a6_data_delayed_2 <= a6_data_delayed_1;
  a6_data_delayed_3 <= a6_data_delayed_2;
  a6_data_delayed_4 <= a6_data_delayed_3;
  a6_data_delayed_5 <= a6_data_delayed_4;
  a6_data_delayed_6 <= a6_data_delayed_5;
  a7_data_delayed_2 <= a7_data_delayed_1;
  a7_data_delayed_3 <= a7_data_delayed_2;
  a7_data_delayed_4 <= a7_data_delayed_3;
  a7_data_delayed_5 <= a7_data_delayed_4;
  a7_data_delayed_6 <= a7_data_delayed_5;
  a7_data_delayed_7 <= a7_data_delayed_6;
 
  end
end

//////////////////////////////////////////////////////////////////////////
// Logic to generate addresses to BRAM B
//////////////////////////////////////////////////////////////////////////
reg [`AWIDTH-1:0] b_addr;
reg b_mem_access; //flag that tells whether the matmul is trying to access memory or not
always @(posedge clk) begin
  //else if (clk_cnt >= b_loc*`MAT_MUL_SIZE+final_mat_mul_size) begin
  //Writing the line above to avoid multiplication:

  if ((reset || ~start_mat_mul) || (clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin

      b_addr <= address_mat_b - address_stride_b;
  
    b_mem_access <= 0;
  end
  //else if ((clk_cnt >= b_loc*`MAT_MUL_SIZE) && (clk_cnt < b_loc*`MAT_MUL_SIZE+final_mat_mul_size)) begin
  //Writing the line above to avoid multiplication:

  else if ((clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)) && (clk_cnt < (b_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin

      b_addr <= b_addr + address_stride_b;
  
    b_mem_access <= 1;
  end
end 

//////////////////////////////////////////////////////////////////////////
// Logic to generate valid signals for data coming from BRAM B
//////////////////////////////////////////////////////////////////////////
reg [7:0] b_mem_access_counter;
always @(posedge clk) begin
  if (reset || ~start_mat_mul) begin
    b_mem_access_counter <= 0;
  end
  else if (b_mem_access == 1) begin
    b_mem_access_counter <= b_mem_access_counter + 1;  
  end
  else begin
    b_mem_access_counter <= 0;
  end
end

wire b_data_valid; //flag that tells whether the data from memory is valid
assign b_data_valid = 
     ((validity_mask_a_cols_b_rows[0]==1'b0 && b_mem_access_counter==1) ||
      (validity_mask_a_cols_b_rows[1]==1'b0 && b_mem_access_counter==2) ||
      (validity_mask_a_cols_b_rows[2]==1'b0 && b_mem_access_counter==3) ||
      (validity_mask_a_cols_b_rows[3]==1'b0 && b_mem_access_counter==4) ||
      (validity_mask_a_cols_b_rows[4]==1'b0 && b_mem_access_counter==5) ||
      (validity_mask_a_cols_b_rows[5]==1'b0 && b_mem_access_counter==6) ||
      (validity_mask_a_cols_b_rows[6]==1'b0 && b_mem_access_counter==7) ||
      (validity_mask_a_cols_b_rows[7]==1'b0 && b_mem_access_counter==8)) ?
    
        1'b0 : (b_mem_access_counter >= `MEM_ACCESS_LATENCY);

//////////////////////////////////////////////////////////////////////////
// Logic to delay certain parts of the data received from BRAM B (systolic data setup)
//////////////////////////////////////////////////////////////////////////
assign b0_data = b_data[1*`DWIDTH-1:0*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[0]}};
assign b1_data = b_data[2*`DWIDTH-1:1*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[1]}};
assign b2_data = b_data[3*`DWIDTH-1:2*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[2]}};
assign b3_data = b_data[4*`DWIDTH-1:3*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[3]}};
assign b4_data = b_data[5*`DWIDTH-1:4*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[4]}};
assign b5_data = b_data[6*`DWIDTH-1:5*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[5]}};
assign b6_data = b_data[7*`DWIDTH-1:6*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[6]}};
assign b7_data = b_data[8*`DWIDTH-1:7*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[7]}};

reg [`DWIDTH-1:0] b1_data_delayed_1;
reg [`DWIDTH-1:0] b2_data_delayed_1;
reg [`DWIDTH-1:0] b2_data_delayed_2;
reg [`DWIDTH-1:0] b3_data_delayed_1;
reg [`DWIDTH-1:0] b3_data_delayed_2;
reg [`DWIDTH-1:0] b3_data_delayed_3;
reg [`DWIDTH-1:0] b4_data_delayed_1;
reg [`DWIDTH-1:0] b4_data_delayed_2;
reg [`DWIDTH-1:0] b4_data_delayed_3;
reg [`DWIDTH-1:0] b4_data_delayed_4;
reg [`DWIDTH-1:0] b5_data_delayed_1;
reg [`DWIDTH-1:0] b5_data_delayed_2;
reg [`DWIDTH-1:0] b5_data_delayed_3;
reg [`DWIDTH-1:0] b5_data_delayed_4;
reg [`DWIDTH-1:0] b5_data_delayed_5;
reg [`DWIDTH-1:0] b6_data_delayed_1;
reg [`DWIDTH-1:0] b6_data_delayed_2;
reg [`DWIDTH-1:0] b6_data_delayed_3;
reg [`DWIDTH-1:0] b6_data_delayed_4;
reg [`DWIDTH-1:0] b6_data_delayed_5;
reg [`DWIDTH-1:0] b6_data_delayed_6;
reg [`DWIDTH-1:0] b7_data_delayed_1;
reg [`DWIDTH-1:0] b7_data_delayed_2;
reg [`DWIDTH-1:0] b7_data_delayed_3;
reg [`DWIDTH-1:0] b7_data_delayed_4;
reg [`DWIDTH-1:0] b7_data_delayed_5;
reg [`DWIDTH-1:0] b7_data_delayed_6;
reg [`DWIDTH-1:0] b7_data_delayed_7;


always @(posedge clk) begin
  if (reset || ~start_mat_mul || clk_cnt==0) begin
    b1_data_delayed_1 <= 0;
    b2_data_delayed_1 <= 0;
    b2_data_delayed_2 <= 0;
    b3_data_delayed_1 <= 0;
    b3_data_delayed_2 <= 0;
    b3_data_delayed_3 <= 0;
    b4_data_delayed_1 <= 0;
    b4_data_delayed_2 <= 0;
    b4_data_delayed_3 <= 0;
    b4_data_delayed_4 <= 0;
    b5_data_delayed_1 <= 0;
    b5_data_delayed_2 <= 0;
    b5_data_delayed_3 <= 0;
    b5_data_delayed_4 <= 0;
    b5_data_delayed_5 <= 0;
    b6_data_delayed_1 <= 0;
    b6_data_delayed_2 <= 0;
    b6_data_delayed_3 <= 0;
    b6_data_delayed_4 <= 0;
    b6_data_delayed_5 <= 0;
    b6_data_delayed_6 <= 0;
    b7_data_delayed_1 <= 0;
    b7_data_delayed_2 <= 0;
    b7_data_delayed_3 <= 0;
    b7_data_delayed_4 <= 0;
    b7_data_delayed_5 <= 0;
    b7_data_delayed_6 <= 0;
    b7_data_delayed_7 <= 0;

  end
  else begin
  b1_data_delayed_1 <= b1_data;
  b2_data_delayed_1 <= b2_data;
  b3_data_delayed_1 <= b3_data;
  b4_data_delayed_1 <= b4_data;
  b5_data_delayed_1 <= b5_data;
  b6_data_delayed_1 <= b6_data;
  b7_data_delayed_1 <= b7_data;
  b2_data_delayed_2 <= b2_data_delayed_1;
  b3_data_delayed_2 <= b3_data_delayed_1;
  b3_data_delayed_3 <= b3_data_delayed_2;
  b4_data_delayed_2 <= b4_data_delayed_1;
  b4_data_delayed_3 <= b4_data_delayed_2;
  b4_data_delayed_4 <= b4_data_delayed_3;
  b5_data_delayed_2 <= b5_data_delayed_1;
  b5_data_delayed_3 <= b5_data_delayed_2;
  b5_data_delayed_4 <= b5_data_delayed_3;
  b5_data_delayed_5 <= b5_data_delayed_4;
  b6_data_delayed_2 <= b6_data_delayed_1;
  b6_data_delayed_3 <= b6_data_delayed_2;
  b6_data_delayed_4 <= b6_data_delayed_3;
  b6_data_delayed_5 <= b6_data_delayed_4;
  b6_data_delayed_6 <= b6_data_delayed_5;
  b7_data_delayed_2 <= b7_data_delayed_1;
  b7_data_delayed_3 <= b7_data_delayed_2;
  b7_data_delayed_4 <= b7_data_delayed_3;
  b7_data_delayed_5 <= b7_data_delayed_4;
  b7_data_delayed_6 <= b7_data_delayed_5;
  b7_data_delayed_7 <= b7_data_delayed_6;
 
  end
end
endmodule


//////////////////////////////////////////////////////////////////////////
// Systolically connected PEs
//////////////////////////////////////////////////////////////////////////
module systolic_pe_matrix(
clk,
reset,
pe_reset,
start_mat_mul,
a0,
a1,
a2,
a3,
a4,
a5,
a6,
a7,
b0,
b1,
b2,
b3,
b4,
b5,
b6,
b7,
matrixC0_0,
matrixC0_1,
matrixC0_2,
matrixC0_3,
matrixC0_4,
matrixC0_5,
matrixC0_6,
matrixC0_7,
matrixC1_0,
matrixC1_1,
matrixC1_2,
matrixC1_3,
matrixC1_4,
matrixC1_5,
matrixC1_6,
matrixC1_7,
matrixC2_0,
matrixC2_1,
matrixC2_2,
matrixC2_3,
matrixC2_4,
matrixC2_5,
matrixC2_6,
matrixC2_7,
matrixC3_0,
matrixC3_1,
matrixC3_2,
matrixC3_3,
matrixC3_4,
matrixC3_5,
matrixC3_6,
matrixC3_7,
matrixC4_0,
matrixC4_1,
matrixC4_2,
matrixC4_3,
matrixC4_4,
matrixC4_5,
matrixC4_6,
matrixC4_7,
matrixC5_0,
matrixC5_1,
matrixC5_2,
matrixC5_3,
matrixC5_4,
matrixC5_5,
matrixC5_6,
matrixC5_7,
matrixC6_0,
matrixC6_1,
matrixC6_2,
matrixC6_3,
matrixC6_4,
matrixC6_5,
matrixC6_6,
matrixC6_7,
matrixC7_0,
matrixC7_1,
matrixC7_2,
matrixC7_3,
matrixC7_4,
matrixC7_5,
matrixC7_6,
matrixC7_7,

a_data_out,
b_data_out
);

input clk;
input reset;
input pe_reset;
input start_mat_mul;
input [`DWIDTH-1:0] a0;
input [`DWIDTH-1:0] a1;
input [`DWIDTH-1:0] a2;
input [`DWIDTH-1:0] a3;
input [`DWIDTH-1:0] a4;
input [`DWIDTH-1:0] a5;
input [`DWIDTH-1:0] a6;
input [`DWIDTH-1:0] a7;
input [`DWIDTH-1:0] b0;
input [`DWIDTH-1:0] b1;
input [`DWIDTH-1:0] b2;
input [`DWIDTH-1:0] b3;
input [`DWIDTH-1:0] b4;
input [`DWIDTH-1:0] b5;
input [`DWIDTH-1:0] b6;
input [`DWIDTH-1:0] b7;
output [`DWIDTH-1:0] matrixC0_0;
output [`DWIDTH-1:0] matrixC0_1;
output [`DWIDTH-1:0] matrixC0_2;
output [`DWIDTH-1:0] matrixC0_3;
output [`DWIDTH-1:0] matrixC0_4;
output [`DWIDTH-1:0] matrixC0_5;
output [`DWIDTH-1:0] matrixC0_6;
output [`DWIDTH-1:0] matrixC0_7;
output [`DWIDTH-1:0] matrixC1_0;
output [`DWIDTH-1:0] matrixC1_1;
output [`DWIDTH-1:0] matrixC1_2;
output [`DWIDTH-1:0] matrixC1_3;
output [`DWIDTH-1:0] matrixC1_4;
output [`DWIDTH-1:0] matrixC1_5;
output [`DWIDTH-1:0] matrixC1_6;
output [`DWIDTH-1:0] matrixC1_7;
output [`DWIDTH-1:0] matrixC2_0;
output [`DWIDTH-1:0] matrixC2_1;
output [`DWIDTH-1:0] matrixC2_2;
output [`DWIDTH-1:0] matrixC2_3;
output [`DWIDTH-1:0] matrixC2_4;
output [`DWIDTH-1:0] matrixC2_5;
output [`DWIDTH-1:0] matrixC2_6;
output [`DWIDTH-1:0] matrixC2_7;
output [`DWIDTH-1:0] matrixC3_0;
output [`DWIDTH-1:0] matrixC3_1;
output [`DWIDTH-1:0] matrixC3_2;
output [`DWIDTH-1:0] matrixC3_3;
output [`DWIDTH-1:0] matrixC3_4;
output [`DWIDTH-1:0] matrixC3_5;
output [`DWIDTH-1:0] matrixC3_6;
output [`DWIDTH-1:0] matrixC3_7;
output [`DWIDTH-1:0] matrixC4_0;
output [`DWIDTH-1:0] matrixC4_1;
output [`DWIDTH-1:0] matrixC4_2;
output [`DWIDTH-1:0] matrixC4_3;
output [`DWIDTH-1:0] matrixC4_4;
output [`DWIDTH-1:0] matrixC4_5;
output [`DWIDTH-1:0] matrixC4_6;
output [`DWIDTH-1:0] matrixC4_7;
output [`DWIDTH-1:0] matrixC5_0;
output [`DWIDTH-1:0] matrixC5_1;
output [`DWIDTH-1:0] matrixC5_2;
output [`DWIDTH-1:0] matrixC5_3;
output [`DWIDTH-1:0] matrixC5_4;
output [`DWIDTH-1:0] matrixC5_5;
output [`DWIDTH-1:0] matrixC5_6;
output [`DWIDTH-1:0] matrixC5_7;
output [`DWIDTH-1:0] matrixC6_0;
output [`DWIDTH-1:0] matrixC6_1;
output [`DWIDTH-1:0] matrixC6_2;
output [`DWIDTH-1:0] matrixC6_3;
output [`DWIDTH-1:0] matrixC6_4;
output [`DWIDTH-1:0] matrixC6_5;
output [`DWIDTH-1:0] matrixC6_6;
output [`DWIDTH-1:0] matrixC6_7;
output [`DWIDTH-1:0] matrixC7_0;
output [`DWIDTH-1:0] matrixC7_1;
output [`DWIDTH-1:0] matrixC7_2;
output [`DWIDTH-1:0] matrixC7_3;
output [`DWIDTH-1:0] matrixC7_4;
output [`DWIDTH-1:0] matrixC7_5;
output [`DWIDTH-1:0] matrixC7_6;
output [`DWIDTH-1:0] matrixC7_7;

output [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out;

wire [`DWIDTH-1:0] a0_0to0_1, a0_1to0_2, a0_2to0_3, a0_3to0_4, a0_4to0_5, a0_5to0_6, a0_6to0_7, a0_7to0_8;
wire [`DWIDTH-1:0] a1_0to1_1, a1_1to1_2, a1_2to1_3, a1_3to1_4, a1_4to1_5, a1_5to1_6, a1_6to1_7, a1_7to1_8;
wire [`DWIDTH-1:0] a2_0to2_1, a2_1to2_2, a2_2to2_3, a2_3to2_4, a2_4to2_5, a2_5to2_6, a2_6to2_7, a2_7to2_8;
wire [`DWIDTH-1:0] a3_0to3_1, a3_1to3_2, a3_2to3_3, a3_3to3_4, a3_4to3_5, a3_5to3_6, a3_6to3_7, a3_7to3_8;
wire [`DWIDTH-1:0] a4_0to4_1, a4_1to4_2, a4_2to4_3, a4_3to4_4, a4_4to4_5, a4_5to4_6, a4_6to4_7, a4_7to4_8;
wire [`DWIDTH-1:0] a5_0to5_1, a5_1to5_2, a5_2to5_3, a5_3to5_4, a5_4to5_5, a5_5to5_6, a5_6to5_7, a5_7to5_8;
wire [`DWIDTH-1:0] a6_0to6_1, a6_1to6_2, a6_2to6_3, a6_3to6_4, a6_4to6_5, a6_5to6_6, a6_6to6_7, a6_7to6_8;
wire [`DWIDTH-1:0] a7_0to7_1, a7_1to7_2, a7_2to7_3, a7_3to7_4, a7_4to7_5, a7_5to7_6, a7_6to7_7, a7_7to7_8;

wire [`DWIDTH-1:0] b0_0to1_0, b1_0to2_0, b2_0to3_0, b3_0to4_0, b4_0to5_0, b5_0to6_0, b6_0to7_0, b7_0to8_0;
wire [`DWIDTH-1:0] b0_1to1_1, b1_1to2_1, b2_1to3_1, b3_1to4_1, b4_1to5_1, b5_1to6_1, b6_1to7_1, b7_1to8_1;
wire [`DWIDTH-1:0] b0_2to1_2, b1_2to2_2, b2_2to3_2, b3_2to4_2, b4_2to5_2, b5_2to6_2, b6_2to7_2, b7_2to8_2;
wire [`DWIDTH-1:0] b0_3to1_3, b1_3to2_3, b2_3to3_3, b3_3to4_3, b4_3to5_3, b5_3to6_3, b6_3to7_3, b7_3to8_3;
wire [`DWIDTH-1:0] b0_4to1_4, b1_4to2_4, b2_4to3_4, b3_4to4_4, b4_4to5_4, b5_4to6_4, b6_4to7_4, b7_4to8_4;
wire [`DWIDTH-1:0] b0_5to1_5, b1_5to2_5, b2_5to3_5, b3_5to4_5, b4_5to5_5, b5_5to6_5, b6_5to7_5, b7_5to8_5;
wire [`DWIDTH-1:0] b0_6to1_6, b1_6to2_6, b2_6to3_6, b3_6to4_6, b4_6to5_6, b5_6to6_6, b6_6to7_6, b7_6to8_6;
wire [`DWIDTH-1:0] b0_7to1_7, b1_7to2_7, b2_7to3_7, b3_7to4_7, b4_7to5_7, b5_7to6_7, b6_7to7_7, b7_7to8_7;

//////////////////////////////////////////////////////////////////////////
// Instantiations of the actual PEs
//////////////////////////////////////////////////////////////////////////
//For larger matmul, more PEs will be needed
wire effective_rst;
assign effective_rst = reset | pe_reset;

processing_element pe0_0(.reset(effective_rst), .clk(clk),  .in_a(a0),      .in_b(b0),  .out_a(a0_0to0_1), .out_b(b0_0to1_0), .out_c(matrixC0_0));
processing_element pe0_1(.reset(effective_rst), .clk(clk),  .in_a(a0_0to0_1), .in_b(b1),  .out_a(a0_1to0_2), .out_b(b0_1to1_1), .out_c(matrixC0_1));
processing_element pe0_2(.reset(effective_rst), .clk(clk),  .in_a(a0_1to0_2), .in_b(b2),  .out_a(a0_2to0_3), .out_b(b0_2to1_2), .out_c(matrixC0_2));
processing_element pe0_3(.reset(effective_rst), .clk(clk),  .in_a(a0_2to0_3), .in_b(b3),  .out_a(a0_3to0_4), .out_b(b0_3to1_3), .out_c(matrixC0_3));
processing_element pe0_4(.reset(effective_rst), .clk(clk),  .in_a(a0_3to0_4), .in_b(b4),  .out_a(a0_4to0_5), .out_b(b0_4to1_4), .out_c(matrixC0_4));
processing_element pe0_5(.reset(effective_rst), .clk(clk),  .in_a(a0_4to0_5), .in_b(b5),  .out_a(a0_5to0_6), .out_b(b0_5to1_5), .out_c(matrixC0_5));
processing_element pe0_6(.reset(effective_rst), .clk(clk),  .in_a(a0_5to0_6), .in_b(b6),  .out_a(a0_6to0_7), .out_b(b0_6to1_6), .out_c(matrixC0_6));
processing_element pe0_7(.reset(effective_rst), .clk(clk),  .in_a(a0_6to0_7), .in_b(b7),  .out_a(a0_7to0_8), .out_b(b0_7to1_7), .out_c(matrixC0_7));

processing_element pe1_0(.reset(effective_rst), .clk(clk),  .in_a(a1), .in_b(b0_0to1_0),  .out_a(a1_0to1_1), .out_b(b1_0to2_0), .out_c(matrixC1_0));
processing_element pe2_0(.reset(effective_rst), .clk(clk),  .in_a(a2), .in_b(b1_0to2_0),  .out_a(a2_0to2_1), .out_b(b2_0to3_0), .out_c(matrixC2_0));
processing_element pe3_0(.reset(effective_rst), .clk(clk),  .in_a(a3), .in_b(b2_0to3_0),  .out_a(a3_0to3_1), .out_b(b3_0to4_0), .out_c(matrixC3_0));
processing_element pe4_0(.reset(effective_rst), .clk(clk),  .in_a(a4), .in_b(b3_0to4_0),  .out_a(a4_0to4_1), .out_b(b4_0to5_0), .out_c(matrixC4_0));
processing_element pe5_0(.reset(effective_rst), .clk(clk),  .in_a(a5), .in_b(b4_0to5_0),  .out_a(a5_0to5_1), .out_b(b5_0to6_0), .out_c(matrixC5_0));
processing_element pe6_0(.reset(effective_rst), .clk(clk),  .in_a(a6), .in_b(b5_0to6_0),  .out_a(a6_0to6_1), .out_b(b6_0to7_0), .out_c(matrixC6_0));
processing_element pe7_0(.reset(effective_rst), .clk(clk),  .in_a(a7), .in_b(b6_0to7_0),  .out_a(a7_0to7_1), .out_b(b7_0to8_0), .out_c(matrixC7_0));

processing_element pe1_1(.reset(effective_rst), .clk(clk),  .in_a(a1_0to1_1), .in_b(b0_1to1_1),  .out_a(a1_1to1_2), .out_b(b1_1to2_1), .out_c(matrixC1_1));
processing_element pe1_2(.reset(effective_rst), .clk(clk),  .in_a(a1_1to1_2), .in_b(b0_2to1_2),  .out_a(a1_2to1_3), .out_b(b1_2to2_2), .out_c(matrixC1_2));
processing_element pe1_3(.reset(effective_rst), .clk(clk),  .in_a(a1_2to1_3), .in_b(b0_3to1_3),  .out_a(a1_3to1_4), .out_b(b1_3to2_3), .out_c(matrixC1_3));
processing_element pe1_4(.reset(effective_rst), .clk(clk),  .in_a(a1_3to1_4), .in_b(b0_4to1_4),  .out_a(a1_4to1_5), .out_b(b1_4to2_4), .out_c(matrixC1_4));
processing_element pe1_5(.reset(effective_rst), .clk(clk),  .in_a(a1_4to1_5), .in_b(b0_5to1_5),  .out_a(a1_5to1_6), .out_b(b1_5to2_5), .out_c(matrixC1_5));
processing_element pe1_6(.reset(effective_rst), .clk(clk),  .in_a(a1_5to1_6), .in_b(b0_6to1_6),  .out_a(a1_6to1_7), .out_b(b1_6to2_6), .out_c(matrixC1_6));
processing_element pe1_7(.reset(effective_rst), .clk(clk),  .in_a(a1_6to1_7), .in_b(b0_7to1_7),  .out_a(a1_7to1_8), .out_b(b1_7to2_7), .out_c(matrixC1_7));
processing_element pe2_1(.reset(effective_rst), .clk(clk),  .in_a(a2_0to2_1), .in_b(b1_1to2_1),  .out_a(a2_1to2_2), .out_b(b2_1to3_1), .out_c(matrixC2_1));
processing_element pe2_2(.reset(effective_rst), .clk(clk),  .in_a(a2_1to2_2), .in_b(b1_2to2_2),  .out_a(a2_2to2_3), .out_b(b2_2to3_2), .out_c(matrixC2_2));
processing_element pe2_3(.reset(effective_rst), .clk(clk),  .in_a(a2_2to2_3), .in_b(b1_3to2_3),  .out_a(a2_3to2_4), .out_b(b2_3to3_3), .out_c(matrixC2_3));
processing_element pe2_4(.reset(effective_rst), .clk(clk),  .in_a(a2_3to2_4), .in_b(b1_4to2_4),  .out_a(a2_4to2_5), .out_b(b2_4to3_4), .out_c(matrixC2_4));
processing_element pe2_5(.reset(effective_rst), .clk(clk),  .in_a(a2_4to2_5), .in_b(b1_5to2_5),  .out_a(a2_5to2_6), .out_b(b2_5to3_5), .out_c(matrixC2_5));
processing_element pe2_6(.reset(effective_rst), .clk(clk),  .in_a(a2_5to2_6), .in_b(b1_6to2_6),  .out_a(a2_6to2_7), .out_b(b2_6to3_6), .out_c(matrixC2_6));
processing_element pe2_7(.reset(effective_rst), .clk(clk),  .in_a(a2_6to2_7), .in_b(b1_7to2_7),  .out_a(a2_7to2_8), .out_b(b2_7to3_7), .out_c(matrixC2_7));
processing_element pe3_1(.reset(effective_rst), .clk(clk),  .in_a(a3_0to3_1), .in_b(b2_1to3_1),  .out_a(a3_1to3_2), .out_b(b3_1to4_1), .out_c(matrixC3_1));
processing_element pe3_2(.reset(effective_rst), .clk(clk),  .in_a(a3_1to3_2), .in_b(b2_2to3_2),  .out_a(a3_2to3_3), .out_b(b3_2to4_2), .out_c(matrixC3_2));
processing_element pe3_3(.reset(effective_rst), .clk(clk),  .in_a(a3_2to3_3), .in_b(b2_3to3_3),  .out_a(a3_3to3_4), .out_b(b3_3to4_3), .out_c(matrixC3_3));
processing_element pe3_4(.reset(effective_rst), .clk(clk),  .in_a(a3_3to3_4), .in_b(b2_4to3_4),  .out_a(a3_4to3_5), .out_b(b3_4to4_4), .out_c(matrixC3_4));
processing_element pe3_5(.reset(effective_rst), .clk(clk),  .in_a(a3_4to3_5), .in_b(b2_5to3_5),  .out_a(a3_5to3_6), .out_b(b3_5to4_5), .out_c(matrixC3_5));
processing_element pe3_6(.reset(effective_rst), .clk(clk),  .in_a(a3_5to3_6), .in_b(b2_6to3_6),  .out_a(a3_6to3_7), .out_b(b3_6to4_6), .out_c(matrixC3_6));
processing_element pe3_7(.reset(effective_rst), .clk(clk),  .in_a(a3_6to3_7), .in_b(b2_7to3_7),  .out_a(a3_7to3_8), .out_b(b3_7to4_7), .out_c(matrixC3_7));
processing_element pe4_1(.reset(effective_rst), .clk(clk),  .in_a(a4_0to4_1), .in_b(b3_1to4_1),  .out_a(a4_1to4_2), .out_b(b4_1to5_1), .out_c(matrixC4_1));
processing_element pe4_2(.reset(effective_rst), .clk(clk),  .in_a(a4_1to4_2), .in_b(b3_2to4_2),  .out_a(a4_2to4_3), .out_b(b4_2to5_2), .out_c(matrixC4_2));
processing_element pe4_3(.reset(effective_rst), .clk(clk),  .in_a(a4_2to4_3), .in_b(b3_3to4_3),  .out_a(a4_3to4_4), .out_b(b4_3to5_3), .out_c(matrixC4_3));
processing_element pe4_4(.reset(effective_rst), .clk(clk),  .in_a(a4_3to4_4), .in_b(b3_4to4_4),  .out_a(a4_4to4_5), .out_b(b4_4to5_4), .out_c(matrixC4_4));
processing_element pe4_5(.reset(effective_rst), .clk(clk),  .in_a(a4_4to4_5), .in_b(b3_5to4_5),  .out_a(a4_5to4_6), .out_b(b4_5to5_5), .out_c(matrixC4_5));
processing_element pe4_6(.reset(effective_rst), .clk(clk),  .in_a(a4_5to4_6), .in_b(b3_6to4_6),  .out_a(a4_6to4_7), .out_b(b4_6to5_6), .out_c(matrixC4_6));
processing_element pe4_7(.reset(effective_rst), .clk(clk),  .in_a(a4_6to4_7), .in_b(b3_7to4_7),  .out_a(a4_7to4_8), .out_b(b4_7to5_7), .out_c(matrixC4_7));
processing_element pe5_1(.reset(effective_rst), .clk(clk),  .in_a(a5_0to5_1), .in_b(b4_1to5_1),  .out_a(a5_1to5_2), .out_b(b5_1to6_1), .out_c(matrixC5_1));
processing_element pe5_2(.reset(effective_rst), .clk(clk),  .in_a(a5_1to5_2), .in_b(b4_2to5_2),  .out_a(a5_2to5_3), .out_b(b5_2to6_2), .out_c(matrixC5_2));
processing_element pe5_3(.reset(effective_rst), .clk(clk),  .in_a(a5_2to5_3), .in_b(b4_3to5_3),  .out_a(a5_3to5_4), .out_b(b5_3to6_3), .out_c(matrixC5_3));
processing_element pe5_4(.reset(effective_rst), .clk(clk),  .in_a(a5_3to5_4), .in_b(b4_4to5_4),  .out_a(a5_4to5_5), .out_b(b5_4to6_4), .out_c(matrixC5_4));
processing_element pe5_5(.reset(effective_rst), .clk(clk),  .in_a(a5_4to5_5), .in_b(b4_5to5_5),  .out_a(a5_5to5_6), .out_b(b5_5to6_5), .out_c(matrixC5_5));
processing_element pe5_6(.reset(effective_rst), .clk(clk),  .in_a(a5_5to5_6), .in_b(b4_6to5_6),  .out_a(a5_6to5_7), .out_b(b5_6to6_6), .out_c(matrixC5_6));
processing_element pe5_7(.reset(effective_rst), .clk(clk),  .in_a(a5_6to5_7), .in_b(b4_7to5_7),  .out_a(a5_7to5_8), .out_b(b5_7to6_7), .out_c(matrixC5_7));
processing_element pe6_1(.reset(effective_rst), .clk(clk),  .in_a(a6_0to6_1), .in_b(b5_1to6_1),  .out_a(a6_1to6_2), .out_b(b6_1to7_1), .out_c(matrixC6_1));
processing_element pe6_2(.reset(effective_rst), .clk(clk),  .in_a(a6_1to6_2), .in_b(b5_2to6_2),  .out_a(a6_2to6_3), .out_b(b6_2to7_2), .out_c(matrixC6_2));
processing_element pe6_3(.reset(effective_rst), .clk(clk),  .in_a(a6_2to6_3), .in_b(b5_3to6_3),  .out_a(a6_3to6_4), .out_b(b6_3to7_3), .out_c(matrixC6_3));
processing_element pe6_4(.reset(effective_rst), .clk(clk),  .in_a(a6_3to6_4), .in_b(b5_4to6_4),  .out_a(a6_4to6_5), .out_b(b6_4to7_4), .out_c(matrixC6_4));
processing_element pe6_5(.reset(effective_rst), .clk(clk),  .in_a(a6_4to6_5), .in_b(b5_5to6_5),  .out_a(a6_5to6_6), .out_b(b6_5to7_5), .out_c(matrixC6_5));
processing_element pe6_6(.reset(effective_rst), .clk(clk),  .in_a(a6_5to6_6), .in_b(b5_6to6_6),  .out_a(a6_6to6_7), .out_b(b6_6to7_6), .out_c(matrixC6_6));
processing_element pe6_7(.reset(effective_rst), .clk(clk),  .in_a(a6_6to6_7), .in_b(b5_7to6_7),  .out_a(a6_7to6_8), .out_b(b6_7to7_7), .out_c(matrixC6_7));
processing_element pe7_1(.reset(effective_rst), .clk(clk),  .in_a(a7_0to7_1), .in_b(b6_1to7_1),  .out_a(a7_1to7_2), .out_b(b7_1to8_1), .out_c(matrixC7_1));
processing_element pe7_2(.reset(effective_rst), .clk(clk),  .in_a(a7_1to7_2), .in_b(b6_2to7_2),  .out_a(a7_2to7_3), .out_b(b7_2to8_2), .out_c(matrixC7_2));
processing_element pe7_3(.reset(effective_rst), .clk(clk),  .in_a(a7_2to7_3), .in_b(b6_3to7_3),  .out_a(a7_3to7_4), .out_b(b7_3to8_3), .out_c(matrixC7_3));
processing_element pe7_4(.reset(effective_rst), .clk(clk),  .in_a(a7_3to7_4), .in_b(b6_4to7_4),  .out_a(a7_4to7_5), .out_b(b7_4to8_4), .out_c(matrixC7_4));
processing_element pe7_5(.reset(effective_rst), .clk(clk),  .in_a(a7_4to7_5), .in_b(b6_5to7_5),  .out_a(a7_5to7_6), .out_b(b7_5to8_5), .out_c(matrixC7_5));
processing_element pe7_6(.reset(effective_rst), .clk(clk),  .in_a(a7_5to7_6), .in_b(b6_6to7_6),  .out_a(a7_6to7_7), .out_b(b7_6to8_6), .out_c(matrixC7_6));
processing_element pe7_7(.reset(effective_rst), .clk(clk),  .in_a(a7_6to7_7), .in_b(b6_7to7_7),  .out_a(a7_7to7_8), .out_b(b7_7to8_7), .out_c(matrixC7_7));
assign a_data_out = {a7_7to7_8,a6_7to6_8,a5_7to5_8,a4_7to4_8,a3_7to3_8,a2_7to2_8,a1_7to1_8,a0_7to0_8};
assign b_data_out = {b7_7to8_7,b7_6to8_6,b7_5to8_5,b7_4to8_4,b7_3to8_3,b7_2to8_2,b7_1to8_1,b7_0to8_0};

endmodule

module processing_element(
 reset, 
 clk, 
 in_a,
 in_b, 
 out_a, 
 out_b, 
 out_c
 );

 input reset;
 input clk;
 input  [`DWIDTH-1:0] in_a;
 input  [`DWIDTH-1:0] in_b;
 output [`DWIDTH-1:0] out_a;
 output [`DWIDTH-1:0] out_b;
 output [`DWIDTH-1:0] out_c;  //reduced precision

 reg [`DWIDTH-1:0] out_a;
 reg [`DWIDTH-1:0] out_b;
 wire [`DWIDTH-1:0] out_c;

 //wire [`DWIDTH-1:0] out_mac;
 wire [37:0] out_mac;

 assign out_c = out_mac[`DWIDTH-1:0];

 //seq_mac u_mac(.a(in_a), .b(in_b), .out(out_mac), .reset(reset), .clk(clk));
 mac_int u_mac(.a({10'b0,in_a}), .b({11'b0,in_b}), .out(out_mac), .reset(reset), .clk(clk));

 always @(posedge clk)begin
    if(reset) begin
      out_a<=0;
      out_b<=0;
    end
    else begin  
      out_a<=in_a;
      out_b<=in_b;
    end
 end
 
endmodule
/*
module seq_mac(a, b, out, reset, clk);
input [`DWIDTH-1:0] a;
input [`DWIDTH-1:0] b;
input reset;
input clk;
output [`DWIDTH-1:0] out;


reg [2*`DWIDTH-1:0] out_temp;
wire [`DWIDTH-1:0] mul_out;
wire [2*`DWIDTH-1:0] add_out;

reg [`DWIDTH-1:0] a_flopped;
reg [`DWIDTH-1:0] b_flopped;

wire [2*`DWIDTH-1:0] mul_out_temp;
reg [2*`DWIDTH-1:0] mul_out_temp_reg;

always @(posedge clk) begin
  if (reset) begin
    a_flopped <= 0;
    b_flopped <= 0;
  end else begin
    a_flopped <= a;
    b_flopped <= b;
  end
end

//assign mul_out = a * b;
qmult mult_u1(.i_multiplicand(a_flopped), .i_multiplier(b_flopped), .o_result(mul_out_temp));

always @(posedge clk) begin
  if (reset) begin
    mul_out_temp_reg <= 0;
  end else begin
    mul_out_temp_reg <= mul_out_temp;
  end
end

//we just truncate the higher bits of the product
//assign add_out = mul_out + out;
qadd add_u1(.a(out), .b(mul_out_temp_reg), .c(add_out));

always @(posedge clk) begin
  if (reset) begin
    out_temp <= 0;
  end else begin
    out_temp <= add_out;
  end
end

//down cast the result
assign out = 
    (out_temp[2*`DWIDTH-1] == 0) ?  //positive number
        (
           (|(out_temp[2*`DWIDTH-2 : `DWIDTH-1])) ?  //is any bit from 14:7 is 1, that means overlfow
             {out_temp[2*`DWIDTH-1] , {(`DWIDTH-1){1'b1}}} : //sign bit and then all 1s
             {out_temp[2*`DWIDTH-1] , out_temp[`DWIDTH-2:0]} 
        )
        : //negative number
        (
           (|(out_temp[2*`DWIDTH-2 : `DWIDTH-1])) ?  //is any bit from 14:7 is 0, that means overlfow
             {out_temp[2*`DWIDTH-1] , out_temp[`DWIDTH-2:0]} :
             {out_temp[2*`DWIDTH-1] , {(`DWIDTH-1){1'b0}}} //sign bit and then all 0s
        );


endmodule

module qmult(i_multiplicand,i_multiplier,o_result);
input [`DWIDTH-1:0] i_multiplicand;
input [`DWIDTH-1:0] i_multiplier;
output [2*`DWIDTH-1:0] o_result;

assign o_result = i_multiplicand * i_multiplier;
//DW02_mult #(`DWIDTH,`DWIDTH) u_mult(.A(i_multiplicand), .B(i_multiplier), .TC(1'b1), .PRODUCT(o_result));

endmodule

module qadd(a,b,c);
input [2*`DWIDTH-1:0] a;
input [2*`DWIDTH-1:0] b;
output [2*`DWIDTH-1:0] c;

assign c = a + b;
//DW01_add #(`DWIDTH) u_add(.A(a), .B(b), .CI(1'b0), .SUM(c), .CO());
endmodule
*/
