///////////////////////////////////////////////////////////////////
//Module to reduce multiple values (add, max, min) into one final result.
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Numerics. We use fixed point format:
//  Most significant 8 bits represent integer part and Least significant 8 bits
//  represent fraction part
//  i.e. IIIIIIIIFFFFFFFF = IIIIIIII.FFFFFFFF
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// There are 32 inputs to the reduction unit. We use a tree structure to reduce the 32 values.
// It is assumed that the number of addressses supplied (end_addr - start_addr + 1) is a multiple
// of 32. If the real application needs to reduce a number of values that are not a multiple of
// 32, then the application must pad the values in the input BRAM appropriately
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// A user is expected to use the resetn signal everytime before starting a new reduction operation.
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Accumulation is done in 20 bits (16 + log(16))
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Each entry of the RAM contains `NUM_INPUTS (which is 32) values. So,
// 1 read of the RAM provides all the inputs required for going through
// the reduction unit once. 
//////////////////////////////////////////////////////////////////

`timescale 1ns/1ns
`define DWIDTH 16
`define LOGDWIDTH 4
`define AWIDTH 5
`define MEM_SIZE 2048
`define NUM_INPUTS 32

////////////////////////////////////////////
// Top module
////////////////////////////////////////////
module reduction_layer(
  input clk,
  input resetn, //resets the control logic and the processing elements
  input start, //indicates start of the reduction operation
  input  [`AWIDTH-1:0] start_addr,  //the starting address where the inputs are located (inclusive)
  input  [`AWIDTH-1:0] end_addr,    //the end address where the inputs are located (inclusive)
  input  [1:0] reduction_type, //can have 3 values: 0 (Add), 1 (Max), 2 (Min)
  input  bram_in_we, //flag used to load the RAM with inputs from outside
  input  [`DWIDTH-1:0] bram_in_wdata_ext, //port to load RAM with inputs from outside (ideally we'd have AXI or some similar interface to load the RAM through a DMA module)
  input  [`AWIDTH-1:0] bram_in_addr_ext, //port to load RAM with inputs from outside (ideally we'd have AXI or some similar interface to load the RAM through a DMA module)
  output [`DWIDTH-1:0] reduced_out, //output
  output reg done //output is valid when done is 1
);

reg [`AWIDTH-1:0] bram_in_addr;
wire [`AWIDTH-1:0] bram_in_addr_muxed;
wire [`NUM_INPUTS*`DWIDTH-1:0] bram_in_wdata;
wire [`NUM_INPUTS*`DWIDTH-1:0] bram_in_rdata;
wire [`DWIDTH+`LOGDWIDTH-1:0] reduced_out_unrounded;
wire [`DWIDTH-1:0] reduced_out_add;

////////////////////////////////////////////////////////////////
//Ideally the RAM would be loaded using an AXI interface or something similar through a DMA engine. 
//Here we've just exposed the write data and address bus to the top-level.
//Each data entry in the RAM is very wide (`NUM_INPUTS*`DWIDTH). That leads to lot of
//ports on the top-level, causing very long wires from RAM to/from IOs. To avoid this,
//we are just going to reduce the width of the port (to `DWIDTH) and just replicate
//that over tha actual data port of the BRAM `NUM_INPUTS times. This doesn't impact
//hardware/functionality of the core design.
assign bram_in_addr_muxed = bram_in_we ? bram_in_addr_ext : bram_in_addr;
assign bram_in_wdata = {`NUM_INPUTS{bram_in_wdata_ext}}; 

////////////////////////////////////////////////////////////////
//Input matrix data is stored in this RAM
//The design reads 16 elements in one clock
////////////////////////////////////////////////////////////////
spram in_data(
  .addr(bram_in_addr_muxed),
  .d(bram_in_wdata), 
  .we(bram_in_we), 
  .q(bram_in_rdata), 
  .clk(clk));

reg [3:0] state;
reg [3:0] count;
reg reset_reduction_unit;
	
////////////////////////////////////////////////////////////////
// Control logic
////////////////////////////////////////////////////////////////
	always @( posedge clk) begin
      if (resetn == 1'b0) begin
        state <= 4'b0000;
        count <= 0;
        done <= 0;
        reset_reduction_unit <= 1;
      end 
      else begin
        case (state)
        4'b0000: begin
          //Stay here until start becomes 1. Keep the processing
          //elements in reset because we don't need them yet.
          if (start == 1'b1) begin
            state <= 4'b0001;
          end 
          done <= 0;
          reset_reduction_unit <= 1;
        end
        
        4'b0001: begin
          state <= 4'b0010;                    
          //Set correct read address for the BRAM containing input values
          //so that the values are available in the next cycle 
          bram_in_addr <= start_addr;
          reset_reduction_unit <= 1;
        end      

        4'b0010: begin
          //During this state, the values for the address set in previous state
          //are available at the read-output of the BRAM.
          //Now let's lift the reset from the processing elements.
          reset_reduction_unit <= 0;
          //If we have reached the end condition (that is, we have 
          //read all the entries from start_addr to end_addr), let's
          //move to the next state (that state doesn't read the RAM any more)
          if (bram_in_addr == end_addr) begin
            //end the loop
            state <= 4'b1110;
          end
			    else begin
            //Increment BRAM addr, so we can fetch the next data in the next cycle
            bram_in_addr <= bram_in_addr + 1;
          end
        end

        4'b1110: begin     
          //The full operation ends after all the locations have been read
          //(and data fed to the reduction unit) and initiation interval
          //(latency) has passed. So, let's count for the initiation interval
          //and then assert done and go back to the initial state.
          count <= count + 1;
          if (count==5) begin
            state <= 4'b0000;
            count <= 0;
            done <= 1;
            reset_reduction_unit <= 1;
          end
        end
      endcase  
	end 
  end


////////////////////////////////////////////////////////////////
// Let's instantiate the unit that actually performs the reduction
////////////////////////////////////////////////////////////////
reduction_unit ucu(
  .clk(clk),
  .reset(reset_reduction_unit),
  .inp0(bram_in_rdata[1*`DWIDTH-1:0*`DWIDTH]), 
  .inp1(bram_in_rdata[2*`DWIDTH-1:1*`DWIDTH]), 
  .inp2(bram_in_rdata[3*`DWIDTH-1:2*`DWIDTH]), 
  .inp3(bram_in_rdata[4*`DWIDTH-1:3*`DWIDTH]), 
  .inp4(bram_in_rdata[5*`DWIDTH-1:4*`DWIDTH]), 
  .inp5(bram_in_rdata[6*`DWIDTH-1:5*`DWIDTH]), 
  .inp6(bram_in_rdata[7*`DWIDTH-1:6*`DWIDTH]), 
  .inp7(bram_in_rdata[8*`DWIDTH-1:7*`DWIDTH]), 
  .inp8(bram_in_rdata[9*`DWIDTH-1:8*`DWIDTH]), 
  .inp9(bram_in_rdata[10*`DWIDTH-1:9*`DWIDTH]), 
  .inp10(bram_in_rdata[11*`DWIDTH-1:10*`DWIDTH]), 
  .inp11(bram_in_rdata[12*`DWIDTH-1:11*`DWIDTH]), 
  .inp12(bram_in_rdata[13*`DWIDTH-1:12*`DWIDTH]), 
  .inp13(bram_in_rdata[14*`DWIDTH-1:13*`DWIDTH]), 
  .inp14(bram_in_rdata[15*`DWIDTH-1:14*`DWIDTH]), 
  .inp15(bram_in_rdata[16*`DWIDTH-1:15*`DWIDTH]), 
  .inp16(bram_in_rdata[17*`DWIDTH-1:16*`DWIDTH]), 
  .inp17(bram_in_rdata[18*`DWIDTH-1:17*`DWIDTH]), 
  .inp18(bram_in_rdata[19*`DWIDTH-1:18*`DWIDTH]), 
  .inp19(bram_in_rdata[20*`DWIDTH-1:19*`DWIDTH]), 
  .inp20(bram_in_rdata[21*`DWIDTH-1:20*`DWIDTH]), 
  .inp21(bram_in_rdata[22*`DWIDTH-1:21*`DWIDTH]), 
  .inp22(bram_in_rdata[23*`DWIDTH-1:22*`DWIDTH]), 
  .inp23(bram_in_rdata[24*`DWIDTH-1:23*`DWIDTH]), 
  .inp24(bram_in_rdata[25*`DWIDTH-1:24*`DWIDTH]), 
  .inp25(bram_in_rdata[26*`DWIDTH-1:25*`DWIDTH]), 
  .inp26(bram_in_rdata[27*`DWIDTH-1:26*`DWIDTH]), 
  .inp27(bram_in_rdata[28*`DWIDTH-1:27*`DWIDTH]), 
  .inp28(bram_in_rdata[29*`DWIDTH-1:28*`DWIDTH]), 
  .inp29(bram_in_rdata[30*`DWIDTH-1:29*`DWIDTH]), 
  .inp30(bram_in_rdata[31*`DWIDTH-1:30*`DWIDTH]), 
  .inp31(bram_in_rdata[32*`DWIDTH-1:31*`DWIDTH]), 
  .mode(reduction_type),
  .outp(reduced_out_unrounded)
);

////////////////////////////////////////////////////////////////
// Rounding of the output of reduction unit (from 20 bits to 16 bits).
// This is required only when reduction type is "sum"
////////////////////////////////////////////////////////////////
rounding #(`DWIDTH+`LOGDWIDTH, `DWIDTH) u_round(.i_data(reduced_out_unrounded), .o_data(reduced_out_add));

assign reduced_out = (reduction_type==2'b0) ? reduced_out_add : reduced_out_unrounded[`DWIDTH-1:0];

endmodule

/*
//////////////////////////////////
//Dual port RAM
//////////////////////////////////
module dpram (
        addr1, 
        d1, 
        we1, 
        q1,  
        addr2,
        d2,
        we2,
        q2,
        clk);

input [`AWIDTH-1:0] addr1;
input [`AWIDTH-1:0] addr2;
input [`DWIDTH-1:0] d1;
input [`DWIDTH-1:0] d2;
input we1;
input we2;
output reg [`DWIDTH-1:0] q1;
output reg [`DWIDTH-1:0] q2;
input clk;

`ifdef VCS
reg [7:0] ram[((1<<`AWIDTH)-1):0];

always @(posedge clk)  
begin 
    if (we1) 
      ram[addr1] <= d1;
    else 
      q1 <= ram[addr1];
end

always @(posedge clk)  
begin 
    if (we2)
      ram[addr2] <= d2;
    else
      q2 <= ram[addr2];
end

`else

dual_port_ram u_dual_port_ram(
.addr1(addr1),
.we1(we1_coalesced),
.data1(d1),
.out1(q1),
.addr2(addr2),
.we2(we2_coalesced),
.data2(d2),
.out2(q2),
.clk(clk)
);

`endif

endmodule
*/

//////////////////////////////////
//Single port RAM. Stores the inputs.
//////////////////////////////////
module spram (
        addr, 
        d, 
        we, 
        q,  
        clk);

input [`AWIDTH-1:0] addr;
input [`NUM_INPUTS*`DWIDTH-1:0] d;
input we;
output reg [`NUM_INPUTS*`DWIDTH-1:0] q;
input clk;

`ifdef VCS

reg [`NUM_INPUTS*`DWIDTH-1:0] ram[((1<<`AWIDTH)-1):0];

always @(posedge clk)  
begin 
    if (we) 
      ram[addr] <= d;
    else 
      q <= ram[addr];
end

`else

single_port_ram u_single_port_ram(
.addr(addr),
.we(we),
.data(d),
.out(q),
.clk(clk)
);

`endif

endmodule

///////////////////////////////////////////////////////
// Reduction unit. It's a tree of processing elements.
// There are 32 inputs and one output and 6 stages. 
//
// The output is
// wider (more bits) than the inputs. It has logN more
// bits (if N is the number of bits in the inputs). This
// is based on https://zipcpu.com/dsp/2017/07/22/rounding.html.
// 
// The last stage is special. It adds the previous 
// result. This is useful when we have more than 32 inputs
// to reduce. We send the next set of 32 inputs in the next
// clock after the first set. 
// 
// Each stage of the tree is pipelined.
///////////////////////////////////////////////////////
module reduction_unit(
  clk,
  reset,
  inp0, 
  inp1, 
  inp2, 
  inp3, 
  inp4, 
  inp5, 
  inp6, 
  inp7, 
  inp8, 
  inp9, 
  inp10, 
  inp11, 
  inp12, 
  inp13, 
  inp14, 
  inp15, 
  inp16, 
  inp17, 
  inp18, 
  inp19, 
  inp20, 
  inp21, 
  inp22, 
  inp23, 
  inp24, 
  inp25, 
  inp26, 
  inp27, 
  inp28, 
  inp29, 
  inp30, 
  inp31, 

  mode,
  outp
);

  input clk;
  input reset;
  input  [`DWIDTH-1 : 0] inp0; 
  input  [`DWIDTH-1 : 0] inp1; 
  input  [`DWIDTH-1 : 0] inp2; 
  input  [`DWIDTH-1 : 0] inp3; 
  input  [`DWIDTH-1 : 0] inp4; 
  input  [`DWIDTH-1 : 0] inp5; 
  input  [`DWIDTH-1 : 0] inp6; 
  input  [`DWIDTH-1 : 0] inp7; 
  input  [`DWIDTH-1 : 0] inp8; 
  input  [`DWIDTH-1 : 0] inp9; 
  input  [`DWIDTH-1 : 0] inp10; 
  input  [`DWIDTH-1 : 0] inp11; 
  input  [`DWIDTH-1 : 0] inp12; 
  input  [`DWIDTH-1 : 0] inp13; 
  input  [`DWIDTH-1 : 0] inp14; 
  input  [`DWIDTH-1 : 0] inp15; 
  input  [`DWIDTH-1 : 0] inp16; 
  input  [`DWIDTH-1 : 0] inp17; 
  input  [`DWIDTH-1 : 0] inp18; 
  input  [`DWIDTH-1 : 0] inp19; 
  input  [`DWIDTH-1 : 0] inp20; 
  input  [`DWIDTH-1 : 0] inp21; 
  input  [`DWIDTH-1 : 0] inp22; 
  input  [`DWIDTH-1 : 0] inp23; 
  input  [`DWIDTH-1 : 0] inp24; 
  input  [`DWIDTH-1 : 0] inp25; 
  input  [`DWIDTH-1 : 0] inp26; 
  input  [`DWIDTH-1 : 0] inp27; 
  input  [`DWIDTH-1 : 0] inp28; 
  input  [`DWIDTH-1 : 0] inp29; 
  input  [`DWIDTH-1 : 0] inp30; 
  input  [`DWIDTH-1 : 0] inp31; 
  input [1:0] mode;
  output [`DWIDTH+`LOGDWIDTH-1 : 0] outp;

  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute0_out_stage5;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute0_out_stage5_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute1_out_stage5;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute1_out_stage5_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute2_out_stage5;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute2_out_stage5_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute3_out_stage5;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute3_out_stage5_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute4_out_stage5;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute4_out_stage5_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute5_out_stage5;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute5_out_stage5_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute6_out_stage5;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute6_out_stage5_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute7_out_stage5;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute7_out_stage5_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute8_out_stage5;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute8_out_stage5_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute9_out_stage5;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute9_out_stage5_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute10_out_stage5;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute10_out_stage5_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute11_out_stage5;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute11_out_stage5_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute12_out_stage5;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute12_out_stage5_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute13_out_stage5;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute13_out_stage5_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute14_out_stage5;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute14_out_stage5_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute15_out_stage5;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute15_out_stage5_reg;

  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute0_out_stage4;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute0_out_stage4_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute1_out_stage4;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute1_out_stage4_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute2_out_stage4;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute2_out_stage4_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute3_out_stage4;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute3_out_stage4_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute4_out_stage4;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute4_out_stage4_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute5_out_stage4;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute5_out_stage4_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute6_out_stage4;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute6_out_stage4_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute7_out_stage4;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute7_out_stage4_reg;

  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute0_out_stage3;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute0_out_stage3_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute1_out_stage3;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute1_out_stage3_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute2_out_stage3;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute2_out_stage3_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute3_out_stage3;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute3_out_stage3_reg;

  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute0_out_stage2;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute0_out_stage2_reg;
  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute1_out_stage2;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute1_out_stage2_reg;

  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute0_out_stage1;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute0_out_stage1_reg;

  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute0_out_stage0;
  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] outp;

  always @(posedge clk) begin
    if (reset) begin
      outp <= 0;
      compute0_out_stage5_reg <= 0;
      compute1_out_stage5_reg <= 0;
      compute2_out_stage5_reg <= 0;
      compute3_out_stage5_reg <= 0;
      compute4_out_stage5_reg <= 0;
      compute5_out_stage5_reg <= 0;
      compute6_out_stage5_reg <= 0;
      compute7_out_stage5_reg <= 0;
      compute8_out_stage5_reg <= 0;
      compute9_out_stage5_reg <= 0;
      compute10_out_stage5_reg <= 0;
      compute11_out_stage5_reg <= 0;
      compute12_out_stage5_reg <= 0;
      compute13_out_stage5_reg <= 0;
      compute14_out_stage5_reg <= 0;
      compute15_out_stage5_reg <= 0;
      compute0_out_stage4_reg <= 0;
      compute1_out_stage4_reg <= 0;
      compute2_out_stage4_reg <= 0;
      compute3_out_stage4_reg <= 0;
      compute4_out_stage4_reg <= 0;
      compute5_out_stage4_reg <= 0;
      compute6_out_stage4_reg <= 0;
      compute7_out_stage4_reg <= 0;
      compute0_out_stage3_reg <= 0;
      compute1_out_stage3_reg <= 0;
      compute2_out_stage3_reg <= 0;
      compute3_out_stage3_reg <= 0;
      compute0_out_stage2_reg <= 0;
      compute1_out_stage2_reg <= 0;
      compute0_out_stage1_reg <= 0;
    end

    else begin
      compute0_out_stage5_reg <= compute0_out_stage5;
      compute1_out_stage5_reg <= compute1_out_stage5;
      compute2_out_stage5_reg <= compute2_out_stage5;
      compute3_out_stage5_reg <= compute3_out_stage5;
      compute4_out_stage5_reg <= compute4_out_stage5;
      compute5_out_stage5_reg <= compute5_out_stage5;
      compute6_out_stage5_reg <= compute6_out_stage5;
      compute7_out_stage5_reg <= compute7_out_stage5;
      compute8_out_stage5_reg <= compute8_out_stage5;
      compute9_out_stage5_reg <= compute9_out_stage5;
      compute10_out_stage5_reg <= compute10_out_stage5;
      compute11_out_stage5_reg <= compute11_out_stage5;
      compute12_out_stage5_reg <= compute12_out_stage5;
      compute13_out_stage5_reg <= compute13_out_stage5;
      compute14_out_stage5_reg <= compute14_out_stage5;
      compute15_out_stage5_reg <= compute15_out_stage5;

      compute0_out_stage4_reg <= compute0_out_stage4;
      compute1_out_stage4_reg <= compute1_out_stage4;
      compute2_out_stage4_reg <= compute2_out_stage4;
      compute3_out_stage4_reg <= compute3_out_stage4;
      compute4_out_stage4_reg <= compute4_out_stage4;
      compute5_out_stage4_reg <= compute5_out_stage4;
      compute6_out_stage4_reg <= compute6_out_stage4;
      compute7_out_stage4_reg <= compute7_out_stage4;

      compute0_out_stage3_reg <= compute0_out_stage3;
      compute1_out_stage3_reg <= compute1_out_stage3;
      compute2_out_stage3_reg <= compute2_out_stage3;
      compute3_out_stage3_reg <= compute3_out_stage3;

      compute0_out_stage2_reg <= compute0_out_stage2;
      compute1_out_stage2_reg <= compute1_out_stage2;

      compute0_out_stage1_reg <= compute0_out_stage1;

      outp <= compute0_out_stage0;

    end
  end

  processing_element #(`DWIDTH,`DWIDTH+`LOGDWIDTH) compute0_stage5(.A(inp0),       .B(inp1),    .OUT(compute0_out_stage5), .MODE(mode));
  processing_element #(`DWIDTH,`DWIDTH+`LOGDWIDTH) compute1_stage5(.A(inp2),       .B(inp3),    .OUT(compute1_out_stage5), .MODE(mode));
  processing_element #(`DWIDTH,`DWIDTH+`LOGDWIDTH) compute2_stage5(.A(inp4),       .B(inp5),    .OUT(compute2_out_stage5), .MODE(mode));
  processing_element #(`DWIDTH,`DWIDTH+`LOGDWIDTH) compute3_stage5(.A(inp6),       .B(inp7),    .OUT(compute3_out_stage5), .MODE(mode));
  processing_element #(`DWIDTH,`DWIDTH+`LOGDWIDTH) compute4_stage5(.A(inp8),       .B(inp9),    .OUT(compute4_out_stage5), .MODE(mode));
  processing_element #(`DWIDTH,`DWIDTH+`LOGDWIDTH) compute5_stage5(.A(inp10),       .B(inp11),    .OUT(compute5_out_stage5), .MODE(mode));
  processing_element #(`DWIDTH,`DWIDTH+`LOGDWIDTH) compute6_stage5(.A(inp12),       .B(inp13),    .OUT(compute6_out_stage5), .MODE(mode));
  processing_element #(`DWIDTH,`DWIDTH+`LOGDWIDTH) compute7_stage5(.A(inp14),       .B(inp15),    .OUT(compute7_out_stage5), .MODE(mode));
  processing_element #(`DWIDTH,`DWIDTH+`LOGDWIDTH) compute8_stage5(.A(inp16),       .B(inp17),    .OUT(compute8_out_stage5), .MODE(mode));
  processing_element #(`DWIDTH,`DWIDTH+`LOGDWIDTH) compute9_stage5(.A(inp18),       .B(inp19),    .OUT(compute9_out_stage5), .MODE(mode));
  processing_element #(`DWIDTH,`DWIDTH+`LOGDWIDTH) compute10_stage5(.A(inp20),       .B(inp21),    .OUT(compute10_out_stage5), .MODE(mode));
  processing_element #(`DWIDTH,`DWIDTH+`LOGDWIDTH) compute11_stage5(.A(inp22),       .B(inp23),    .OUT(compute11_out_stage5), .MODE(mode));
  processing_element #(`DWIDTH,`DWIDTH+`LOGDWIDTH) compute12_stage5(.A(inp24),       .B(inp25),    .OUT(compute12_out_stage5), .MODE(mode));
  processing_element #(`DWIDTH,`DWIDTH+`LOGDWIDTH) compute13_stage5(.A(inp26),       .B(inp27),    .OUT(compute13_out_stage5), .MODE(mode));
  processing_element #(`DWIDTH,`DWIDTH+`LOGDWIDTH) compute14_stage5(.A(inp28),       .B(inp29),    .OUT(compute14_out_stage5), .MODE(mode));
  processing_element #(`DWIDTH,`DWIDTH+`LOGDWIDTH) compute15_stage5(.A(inp30),       .B(inp31),    .OUT(compute15_out_stage5), .MODE(mode));

  processing_element #(`DWIDTH+`LOGDWIDTH,`DWIDTH+`LOGDWIDTH) compute0_stage4(.A(compute0_out_stage5_reg),       .B(compute1_out_stage5_reg),    .OUT(compute0_out_stage4), .MODE(mode));
  processing_element #(`DWIDTH+`LOGDWIDTH,`DWIDTH+`LOGDWIDTH) compute1_stage4(.A(compute2_out_stage5_reg),       .B(compute3_out_stage5_reg),    .OUT(compute1_out_stage4), .MODE(mode));
  processing_element #(`DWIDTH+`LOGDWIDTH,`DWIDTH+`LOGDWIDTH) compute2_stage4(.A(compute4_out_stage5_reg),       .B(compute5_out_stage5_reg),    .OUT(compute2_out_stage4), .MODE(mode));
  processing_element #(`DWIDTH+`LOGDWIDTH,`DWIDTH+`LOGDWIDTH) compute3_stage4(.A(compute6_out_stage5_reg),       .B(compute7_out_stage5_reg),    .OUT(compute3_out_stage4), .MODE(mode));
  processing_element #(`DWIDTH+`LOGDWIDTH,`DWIDTH+`LOGDWIDTH) compute4_stage4(.A(compute8_out_stage5_reg),       .B(compute9_out_stage5_reg),    .OUT(compute4_out_stage4), .MODE(mode));
  processing_element #(`DWIDTH+`LOGDWIDTH,`DWIDTH+`LOGDWIDTH) compute5_stage4(.A(compute10_out_stage5_reg),       .B(compute11_out_stage5_reg),    .OUT(compute5_out_stage4), .MODE(mode));
  processing_element #(`DWIDTH+`LOGDWIDTH,`DWIDTH+`LOGDWIDTH) compute6_stage4(.A(compute12_out_stage5_reg),       .B(compute13_out_stage5_reg),    .OUT(compute6_out_stage4), .MODE(mode));
  processing_element #(`DWIDTH+`LOGDWIDTH,`DWIDTH+`LOGDWIDTH) compute7_stage4(.A(compute14_out_stage5_reg),       .B(compute15_out_stage5_reg),    .OUT(compute7_out_stage4), .MODE(mode));

  processing_element #(`DWIDTH+`LOGDWIDTH,`DWIDTH+`LOGDWIDTH) compute0_stage3(.A(compute0_out_stage4_reg),       .B(compute1_out_stage4_reg),    .OUT(compute0_out_stage3), .MODE(mode));
  processing_element #(`DWIDTH+`LOGDWIDTH,`DWIDTH+`LOGDWIDTH) compute1_stage3(.A(compute2_out_stage4_reg),       .B(compute3_out_stage4_reg),    .OUT(compute1_out_stage3), .MODE(mode));
  processing_element #(`DWIDTH+`LOGDWIDTH,`DWIDTH+`LOGDWIDTH) compute2_stage3(.A(compute4_out_stage4_reg),       .B(compute5_out_stage4_reg),    .OUT(compute2_out_stage3), .MODE(mode));
  processing_element #(`DWIDTH+`LOGDWIDTH,`DWIDTH+`LOGDWIDTH) compute3_stage3(.A(compute6_out_stage4_reg),       .B(compute7_out_stage4_reg),    .OUT(compute3_out_stage3), .MODE(mode));

  processing_element #(`DWIDTH+`LOGDWIDTH,`DWIDTH+`LOGDWIDTH) compute0_stage2(.A(compute0_out_stage3_reg),       .B(compute1_out_stage3_reg),    .OUT(compute0_out_stage2), .MODE(mode));
  processing_element #(`DWIDTH+`LOGDWIDTH,`DWIDTH+`LOGDWIDTH) compute1_stage2(.A(compute2_out_stage3_reg),       .B(compute3_out_stage3_reg),    .OUT(compute1_out_stage2), .MODE(mode));

  processing_element #(`DWIDTH+`LOGDWIDTH,`DWIDTH+`LOGDWIDTH) compute0_stage1(.A(compute0_out_stage2_reg),       .B(compute1_out_stage2_reg),    .OUT(compute0_out_stage1), .MODE(mode));

  processing_element #(`DWIDTH+`LOGDWIDTH,`DWIDTH+`LOGDWIDTH) compute0_stage0(.A(outp),       .B(compute0_out_stage1_reg),     .OUT(compute0_out_stage0), .MODE(mode));

endmodule

///////////////////////////////////////////////////////
// Processing element. Finds sum, min or max depending on mode
///////////////////////////////////////////////////////
module processing_element(
  A, B, OUT, MODE
);
parameter IN_DWIDTH = 16;
parameter OUT_DWIDTH = 4;
input [IN_DWIDTH-1:0] A;
input [IN_DWIDTH-1:0] B;
output [OUT_DWIDTH-1:0] OUT;
input [1:0] MODE;

wire [OUT_DWIDTH-1:0] greater;
wire [OUT_DWIDTH-1:0] smaller;
wire [OUT_DWIDTH-1:0] sum;

assign greater = (A>B) ? A : B;
assign smaller = (A<B) ? A : B;
assign sum = A + B;

assign OUT = (MODE==0) ? sum : 
             (MODE==1) ? greater :
             smaller;

endmodule

///////////////////////////////////////////////////////
//Rounding logic based on convergent rounding described 
//here: https://zipcpu.com/dsp/2017/07/22/rounding.html
///////////////////////////////////////////////////////
module rounding( i_data, o_data );
parameter IWID = 32;
parameter OWID = 16;
input  [IWID-1:0] i_data;
output [OWID-1:0] o_data;

wire [IWID-1:0] w_convergent;

assign	w_convergent = i_data[(IWID-1):0]
			+ { {(OWID){1'b0}},
				i_data[(IWID-OWID)],
				{(IWID-OWID-1){!i_data[(IWID-OWID)]}}};

assign o_data = w_convergent[(IWID-1):(IWID-OWID)];

endmodule