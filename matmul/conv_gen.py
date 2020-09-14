print("""
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
""")

for i in range(7):
    print("""
  reg pe_reset_{iter};	
  reg start_mat_mul_{iter};
  wire done_mat_mul_{iter};
  reg [`AWIDTH-1:0] address_mat_a_{iter};
  reg [`AWIDTH-1:0] address_mat_b_{iter};
  reg [`AWIDTH-1:0] address_mat_c_{iter};
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_a_{iter};
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_b_{iter};
  reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_c_{iter};
  wire [3:0] flags_NC_{iter};
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_{iter};
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_{iter};
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_{iter};
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_{iter}_NC;
  assign a_data_in_{iter}_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_{iter}_NC;
  assign b_data_in_{iter}_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in_{iter}_NC;
  assign c_data_in_{iter}_NC = 0;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out_{iter}_NC;
  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out_{iter}_NC;
  wire [`AWIDTH-1:0] a_addr_{iter};
  wire [`AWIDTH-1:0] b_addr_{iter};
  wire [`AWIDTH-1:0] c_addr_{iter};
  wire c_data_{iter}_available;
  reg [3:0] validity_mask_a_{iter}_rows;
  reg [3:0] validity_mask_a_{iter}_cols;
  reg [3:0] validity_mask_b_{iter}_rows;
  reg [3:0] validity_mask_b_{iter}_cols;
  
  """.format(iter=i))

for horizontal in range(7):
    print("""
    reg [`AWIDTH-1:0] bram_addr_a_{iter}_ext;
    wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_{iter}_ext;
    reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_{iter}_ext;
    reg [`MASK_WIDTH-1:0] bram_we_a_{iter}_ext;
    
	  wire [`AWIDTH-1:0] bram_addr_a_{iter};
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_{iter};
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_{iter};
	  wire [`MASK_WIDTH-1:0] bram_we_a_{iter};
	  wire bram_en_a_{iter};

    reg [`AWIDTH-1:0] bram_addr_b_{iter}_ext;
    wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_{iter}_ext;
    reg [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_{iter}_ext;
    reg [`MASK_WIDTH-1:0] bram_we_b_{iter}_ext;
    
	  wire [`AWIDTH-1:0] bram_addr_b_{iter};
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_{iter};
	  wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_{iter};
	  wire [`MASK_WIDTH-1:0] bram_we_b_{iter};
	  wire bram_en_b_{iter};

    """.format(iter=horizontal))

print("""
  always @* begin
    case (bram_select)
""")

iter_inc = 0
for horizontal in range(7):
    print("""
      {iter_inc}: begin
      bram_addr_a_{iter}_ext = bram_addr_ext;
      bram_wdata_a_{iter}_ext = bram_wdata_ext;
      bram_we_a_{iter}_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_a_{iter}_ext;
      end
    """.format(iter_inc=iter_inc, iter=horizontal))
    iter_inc += 1
    print("""
      {iter_inc}: begin
      bram_addr_b_{iter}_ext = bram_addr_ext;
      bram_wdata_b_{iter}_ext = bram_wdata_ext;
      bram_we_b_{iter}_ext = bram_we_ext;
      bram_rdata_ext = bram_rdata_b_{iter}_ext;
      end
    """.format(iter_inc=iter_inc, iter=horizontal))
    iter_inc += 1

print("""
      default: begin
      bram_rdata_ext = 0;
      end
    endcase 
  end
   """)

for horizontal in range(7):
  print("""
  ram matrix_A_{iter}(
    .addr0(bram_addr_a_{iter}),
    .d0(bram_wdata_a_{iter}), 
    .we0(bram_we_a_{iter}), 
    .q0(a_data_{iter}), 
    .addr1(bram_addr_a_{iter}_ext),
    .d1(bram_wdata_a_{iter}_ext), 
    .we1(bram_we_a_{iter}_ext), 
    .q1(bram_rdata_a_{iter}_ext), 
    .clk(clk_mem));

  ram matrix_B_{iter}(
    .addr0(b_addr_{iter}),
    .d0(bram_wdata_b_{iter}), 
    .we0(bram_we_b_{iter}), 
    .q0(b_data_{iter}), 
    .addr1(bram_addr_b_{iter}_ext),
    .d1(bram_wdata_b_{iter}_ext), 
    .we1(bram_we_b_{iter}_ext), 
    .q1(bram_rdata_b_{iter}_ext), 
    .clk(clk_mem));

    """.format(iter=horizontal))

for horizontal in range(7):
  print("""

  assign bram_wdata_a_{iter} = c_data_{iter};
  assign bram_en_a_{iter} = 1'b1;
  assign bram_we_a_{iter} = (c_data_{iter}_available) ? {{`MASK_WIDTH{{1'b1}}}} : {{`MASK_WIDTH{{1'b0}}}};  
  assign bram_addr_a_{iter} = (c_data_{iter}_available) ? c_addr_{iter} : a_addr_{iter};

  assign bram_wdata_b_{iter} = {{`MAT_MUL_SIZE*`DWIDTH{{1'b0}}}};
  assign bram_en_b_{iter} = 1'b1;
  assign bram_we_b_{iter} = {{`MASK_WIDTH{{1'b0}}}};
  """.format(iter=horizontal))

print("""
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

""")

for iter in range(7):
    print("""
reg [1:0] slice_{iter}_op;
    """.format(iter=iter))


addr_width = 10
addr_stride_width = 16
state_width = 5
state = 1
print("""
reg [3:0] count;
reg [4:0] state;
reg [4:0] vertical_count;

	always @( posedge clk) begin
      if (resetn == 1'b0) begin
        state <= {state_width}'d0;
        done <= 0;
        """.format(state_width=state_width))

for horizontal in range(7):
    print("""
      slice_{horiz}_op <= 0;
      start_mat_mul_{horiz} <= 0;
      address_mat_a_{horiz} <= 0;
      address_mat_b_{horiz} <= 0;
      address_mat_c_{horiz} <= 0;
      address_stride_a_{horiz} <= 0;
      address_stride_b_{horiz} <= 0;
      address_stride_c_{horiz} <= 0;
      validity_mask_a_{horiz}_rows <= 0;
      validity_mask_a_{horiz}_cols <= 0;
      validity_mask_b_{horiz}_rows <= 0;
      validity_mask_b_{horiz}_cols <= 0;
    """.format(horiz=horizontal, \
      state_width=state_width, \
      state=state, \
      awidth=addr_width, \
      stride_width=addr_stride_width))

print("""
        count <= 0;
        vertical_count <= 0;
      end 
      else begin
        case (state)
        {state_width}'d0: begin
        """.format(state_width=state_width))

for iter in range(7):
  print("""start_mat_mul_{iter} <= 1'b0;""".format(iter=iter))

print("""
          if (start== 1'b1) begin
            count <= 4'd1;
            vertical_count <= 5'd1;
            state <= {state_width}'d1;
            done <= 0;
          end 
        end
""".format(state_width=state_width))

print("""
    {state_width}'d{state}: begin
""".format(state_width=state_width, state=state))
for horizontal in range(7):
    print("""
      slice_{horiz}_op <= 2'b00;
      start_mat_mul_{horiz} <= 1'b1;
      address_mat_a_{horiz} <=  vertical_count + `ADDRESS_BASE_A +{awidth}'d{horiz_addr_a}; //will change horizontally
      address_mat_b_{horiz} <=  vertical_count + `ADDRESS_BASE_B +{awidth}'d{horiz_addr_b}; //will change horizontally
      address_mat_c_{horiz} <=  vertical_count + `ADDRESS_BASE_A +{awidth}'d192; //will stay constant horizontally
      //if (count==4'd4) begin
      // address_stride_a_{horiz} <= {stride_width}'d8;
      //end else begin
        address_stride_a_{horiz} <= {stride_width}'d1; 
      //end
      address_stride_b_{horiz} <= {stride_width}'d3; //constant horiz
      address_stride_c_{horiz} <= {stride_width}'d64; //constant horiz
      validity_mask_a_{horiz}_rows <= 4'b1111; //constant
      validity_mask_a_{horiz}_cols <= 4'b1111; //constant
      validity_mask_b_{horiz}_rows <= 4'b1111; //constant
      validity_mask_b_{horiz}_cols <= 4'b0111; //constant
      """.format(horiz=horizontal, \
          awidth=addr_width, \
          stride_width=addr_stride_width,\
          horiz_addr_a=horizontal*11,\
          horiz_addr_b=horizontal*12,\
          state=state,\
          state_width=state_width))
state += 1
print("""
  count <= count + 1;

  if (done_mat_mul == 1'b1) begin
    state <= {state_width}'d{state};
""".format(state=state, state_width=state_width))
print("""
  end
end
""".format(state=state, state_width=state_width))
    
print("""
    {state_width}'d{state}: begin
    count <= 4'b0;
""".format(state_width=state_width, state=state))
next_state = state+1
for horizontal in range(7):
    print("""
    start_mat_mul_{horiz} <= 1'b0;""".format(horiz=horizontal))
print("""
    state <= {state_width}'d{next_state};
  end
""".format(next_state=next_state, state_width=state_width))
state += 1
print("""
    {state_width}'d{state}: begin
""".format(state_width=state_width, state=state))
for horizontal in [4,5,6]:
    print("""
      slice_{horiz}_op <= 2'b10;
      start_mat_mul_{horiz} <= 1'b1;
      address_mat_a_{horiz} <= vertical_count + `ADDRESS_BASE_A + {awidth}'d192; //will stay constant horizontally
      address_mat_b_{horiz} <= vertical_count + `ADDRESS_BASE_A +  {awidth}'d192; //will stay constant horizontally
      address_mat_c_{horiz} <= vertical_count + `ADDRESS_BASE_A + {awidth}'d512; //will stay constant horizontally
      address_stride_a_{horiz} <= {stride_width}'d64;
      address_stride_b_{horiz} <= {stride_width}'d64;
      address_stride_c_{horiz} <= {stride_width}'d64; 
      validity_mask_a_{horiz}_rows <= 4'b1111; //constant
      validity_mask_a_{horiz}_cols <= 4'b1111; //constant
      validity_mask_b_{horiz}_rows <= 4'b1111; //constant
      validity_mask_b_{horiz}_cols <= 4'b0111; //constant
    """.format(horiz=horizontal, \
      state_width=state_width, \
      state=state, \
      awidth=addr_width, \
      stride_width=addr_stride_width))
next_state = state+1
print("""
      if (done_eltwise_add_phase_1 == 1'b1) begin
        state <= {state_width}'d{next_state};
      end
""".format(state_width=state_width, state=state, next_state=next_state))

state += 1
next_state = state+1
print("""
end
    {state_width}'d{state}: begin
        start_mat_mul_4 <= 1'b0;
        start_mat_mul_5 <= 1'b0;
        start_mat_mul_6 <= 1'b0;
        state <= {state_width}'d{next_state};
""".format(state_width=state_width, state=state, next_state=next_state))
state += 1
print("""
end
    {state_width}'d{state}: begin
""".format(state_width=state_width, state=state))
for horizontal in [5,6]:
    print("""
      slice_{horiz}_op <= 2'b10;
      start_mat_mul_{horiz} <= 1'b1;
      address_mat_a_{horiz} <= vertical_count + `ADDRESS_BASE_A + {awidth}'d512; //will stay constant horizontally
      address_mat_b_{horiz} <= vertical_count + `ADDRESS_BASE_A +  {awidth}'d512; //will stay constant horizontally
      address_mat_c_{horiz} <= vertical_count + `ADDRESS_BASE_A + {awidth}'d768; //will stay constant horizontally
      address_stride_a_{horiz} <= {stride_width}'d64;
      address_stride_b_{horiz} <= {stride_width}'d64;
      address_stride_c_{horiz} <= {stride_width}'d64; 
      validity_mask_a_{horiz}_rows <= 4'b1111; //constant
      validity_mask_a_{horiz}_cols <= 4'b1111; //constant
      validity_mask_b_{horiz}_rows <= 4'b1111; //constant
      validity_mask_b_{horiz}_cols <= 4'b0111; //constant
    """.format(horiz=horizontal, \
      state_width=state_width, \
      state=state, \
      awidth=addr_width, \
      stride_width=addr_stride_width))
next_state = state+1
print("""
      if (done_eltwise_add_phase_2 == 1'b1) begin
        state <= {state_width}'d{next_state};
      end
""".format(state_width=state_width, state=state, next_state=next_state))

state += 1
next_state = state +1
print("""
end
    {state_width}'d{state}: begin
        state <= {state_width}'d{next_state};
        start_mat_mul_5 <= 1'b0;
        start_mat_mul_6 <= 1'b0;
""".format(state_width=state_width, state=state, next_state=next_state))

state += 1
print("""
end
    {state_width}'d{state}: begin
""".format(state_width=state_width, state=state))
for horizontal in [6]:
    print("""
      slice_{horiz}_op <= 2'b10;
      start_mat_mul_{horiz} <= 1'b1;
      address_mat_a_{horiz} <= vertical_count + `ADDRESS_BASE_A + {awidth}'d768; //will stay constant horizontally
      address_mat_b_{horiz} <= vertical_count + `ADDRESS_BASE_A +  {awidth}'d768; //will stay constant horizontally
      address_mat_c_{horiz} <= vertical_count + `ADDRESS_BASE_A + {awidth}'d900; //will stay constant horizontally
      address_stride_a_{horiz} <= {stride_width}'d64;
      address_stride_b_{horiz} <= {stride_width}'d64;
      address_stride_c_{horiz} <= {stride_width}'d64; 
      validity_mask_a_{horiz}_rows <= 4'b1111; //constant
      validity_mask_a_{horiz}_cols <= 4'b1111; //constant
      validity_mask_b_{horiz}_rows <= 4'b1111; //constant
      validity_mask_b_{horiz}_cols <= 4'b0111; //constant
    """.format(horiz=horizontal, \
      state_width=state_width, \
      state=state, \
      awidth=addr_width, \
      stride_width=addr_stride_width))
next_state = state+1
print("""
      if (done_eltwise_add_phase_3 == 1'b1) begin
        state <= {state_width}'d{next_state};
      end
end
""".format(state_width=state_width, state=state, next_state=next_state))
state+=1
next_state = state +1
print("""
    {state_width}'d{state}: begin
        state <= {state_width}'d{next_state};
        start_mat_mul_6 <= 1'b0;
end
""".format(state_width=state_width, state=state, next_state=next_state))
state += 1
print("""
    {state_width}'d{state}: begin
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
""".format(state_width=state_width, state=state, next_state=next_state))


#//Add logic that counts vertical iterations and if reached, goes to end state,
#//otherwise it goes back to state 1

for horiz in range(7):
    print("""
    matmul_slice u_matmul_4x4_systolic_{iter}(
      .clk(clk),
      .reset(reset),
      .pe_reset(pe_reset),
      .start_mat_mul(start_mat_mul_{iter}),
      .done_mat_mul(done_mat_mul_{iter}),
      .address_mat_a(address_mat_a_{iter}),
      .address_mat_b(address_mat_b_{iter}),
      .address_mat_c(address_mat_c_{iter}),
      .address_stride_a(address_stride_a_{iter}),
      .address_stride_b(address_stride_b_{iter}),
      .address_stride_c(address_stride_c_{iter}),
      .a_data(a_data_{iter}),
      .b_data(b_data_{iter}),
      .a_data_in(a_data_in_{iter}_NC),
      .b_data_in(b_data_in_{iter}_NC),
      .c_data_in(c_data_in_{iter}_NC),
      .c_data_out(c_data_{iter}),
      .a_data_out(a_data_out_{iter}_NC),
      .b_data_out(b_data_out_{iter}_NC),
      .a_addr(a_addr_{iter}),
      .b_addr(b_addr_{iter}),
      .c_addr(c_addr_{iter}),
      .c_data_available(c_data_{iter}_available),
      .flags(flags_NC_{iter}),
      .validity_mask_a_rows({{4'b0,validity_mask_a_{iter}_rows}}),
      .validity_mask_a_cols({{4'b0,validity_mask_a_{iter}_cols}}),
      .validity_mask_b_rows({{4'b0,validity_mask_b_{iter}_rows}}),
      .validity_mask_b_cols({{4'b0,validity_mask_b_{iter}_cols}}),
      .slice_mode(1'b0), //0 is SLICE_MODE_MATMUL
      .slice_dtype(1'b1), //1 is FP16
      .op(slice_{iter}_op), 
      .preload(1'b0),
      .final_mat_mul_size(8'd4),
      .a_loc(8'd0),
      .b_loc(8'd0)
    );
    
    """.format(iter=horiz))

print("""

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

  
    
    """)