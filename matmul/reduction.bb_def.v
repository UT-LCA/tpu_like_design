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
// There are 32 inputs to the comute unit. We use a tree structure to reduce the 32 values.
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

`timescale 1ns/1ns
`define DWIDTH 16
`define LOGDWIDTH 4
`define AWIDTH 11
`define MEM_SIZE 2048
`define NUM_INPUTS 32

////////////////////////////////////////////
// Top module
////////////////////////////////////////////
module reduction_layer(
  input clk,
  input resetn,
  input start,
  input  [`AWIDTH-1:0] start_addr,  //inclusive
  input  [`AWIDTH-1:0] end_addr,    //inclusive
  input  [1:0] reduction_type, //can have 3 values: 0 (Add), 1 (Max), 2 (Min)
  output [`DWIDTH-1:0] reduced_out,
  output reg done
);

reg [`AWIDTH-1:0] bram_in_addr;
wire [`NUM_INPUTS*`DWIDTH-1:0] bram_in_wdata_NC;
reg bram_in_we;
wire [`NUM_INPUTS*`DWIDTH-1:0] bram_in_rdata;
wire [`DWIDTH+`LOGDWIDTH-1:0] reduced_out_unrounded;
wire [`DWIDTH-1:0] reduced_out_add;

////////////////////////////////////////////////////////////////
//Input matrix data is stored in this RAM
//The design reads 16 elements in one clock
////////////////////////////////////////////////////////////////
spram in_data(
  .addr(bram_in_addr),
  .d(bram_in_wdata_NC), 
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
          bram_in_we <= 1'b0;
          reset_reduction_unit <= 1;
        end      

        4'b0010: begin
          //During this state, the values for the address set in previous state
          //are available at the read-output of the BRAM

          reset_reduction_unit <= 0;
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
          //count for the initiation interval
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


wire [`DWIDTH*32-1:0] reduction_unit_in;

genvar i;
generate
  for (i=0; i<`NUM_INPUTS; i=i+1) begin: cu_in
    assign reduction_unit_in[(i+1)*`DWIDTH-1:i*`DWIDTH] = bram_in_rdata[(i+1)*`DWIDTH-1:i*`DWIDTH];
  end
endgenerate

////////////////////////////////////////////////////////////////
// Let's instantiate the unit that actually performs the reduction
////////////////////////////////////////////////////////////////
reduction_unit ucu(
  .clk(clk),
  .reset(reset_reduction_unit),
  .inp0(reduction_unit_in[1*`DWIDTH-1:0*`DWIDTH]), 
  .inp1(reduction_unit_in[2*`DWIDTH-1:1*`DWIDTH]), 
  .inp2(reduction_unit_in[3*`DWIDTH-1:2*`DWIDTH]), 
  .inp3(reduction_unit_in[4*`DWIDTH-1:3*`DWIDTH]), 
  .inp4(reduction_unit_in[5*`DWIDTH-1:4*`DWIDTH]), 
  .inp5(reduction_unit_in[6*`DWIDTH-1:5*`DWIDTH]), 
  .inp6(reduction_unit_in[7*`DWIDTH-1:6*`DWIDTH]), 
  .inp7(reduction_unit_in[8*`DWIDTH-1:7*`DWIDTH]), 
  .inp8(reduction_unit_in[9*`DWIDTH-1:8*`DWIDTH]), 
  .inp9(reduction_unit_in[10*`DWIDTH-1:9*`DWIDTH]), 
  .inp10(reduction_unit_in[11*`DWIDTH-1:10*`DWIDTH]), 
  .inp11(reduction_unit_in[12*`DWIDTH-1:11*`DWIDTH]), 
  .inp12(reduction_unit_in[13*`DWIDTH-1:12*`DWIDTH]), 
  .inp13(reduction_unit_in[14*`DWIDTH-1:13*`DWIDTH]), 
  .inp14(reduction_unit_in[15*`DWIDTH-1:14*`DWIDTH]), 
  .inp15(reduction_unit_in[16*`DWIDTH-1:15*`DWIDTH]), 
  .inp16(reduction_unit_in[17*`DWIDTH-1:16*`DWIDTH]), 
  .inp17(reduction_unit_in[18*`DWIDTH-1:17*`DWIDTH]), 
  .inp18(reduction_unit_in[19*`DWIDTH-1:18*`DWIDTH]), 
  .inp19(reduction_unit_in[20*`DWIDTH-1:19*`DWIDTH]), 
  .inp20(reduction_unit_in[21*`DWIDTH-1:20*`DWIDTH]), 
  .inp21(reduction_unit_in[22*`DWIDTH-1:21*`DWIDTH]), 
  .inp22(reduction_unit_in[23*`DWIDTH-1:22*`DWIDTH]), 
  .inp23(reduction_unit_in[24*`DWIDTH-1:23*`DWIDTH]), 
  .inp24(reduction_unit_in[25*`DWIDTH-1:24*`DWIDTH]), 
  .inp25(reduction_unit_in[26*`DWIDTH-1:25*`DWIDTH]), 
  .inp26(reduction_unit_in[27*`DWIDTH-1:26*`DWIDTH]), 
  .inp27(reduction_unit_in[28*`DWIDTH-1:27*`DWIDTH]), 
  .inp28(reduction_unit_in[29*`DWIDTH-1:28*`DWIDTH]), 
  .inp29(reduction_unit_in[30*`DWIDTH-1:29*`DWIDTH]), 
  .inp30(reduction_unit_in[31*`DWIDTH-1:30*`DWIDTH]), 
  .inp31(reduction_unit_in[32*`DWIDTH-1:31*`DWIDTH]), 
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