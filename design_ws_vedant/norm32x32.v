////////////////////////////////////////////////////////////////////////////////
// THIS FILE WAS AUTOMATICALLY GENERATED FROM generate_norm.v.mako
// DO NOT EDIT
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns
`define DWIDTH 8
`define AWIDTH 11
`define MEM_SIZE 2048

`define MAT_MUL_SIZE 32
`define MASK_WIDTH 32
`define LOG2_MAT_MUL_SIZE 5

`define BB_MAT_MUL_SIZE `MAT_MUL_SIZE
`define NUM_CYCLES_IN_MAC 3
`define MEM_ACCESS_LATENCY 1
`define REG_DATAWIDTH 32
`define REG_ADDRWIDTH 8
`define ADDR_STRIDE_WIDTH 8
`define MAX_BITS_POOL 3
`define VCS

module norm(
    input enable_norm,
    input enable_pool,
    input [`DWIDTH-1:0] mean,
    input [`DWIDTH-1:0] inv_var,
    input in_data_available,
    input [`DWIDTH-1:0] inp_data0,
    input [`DWIDTH-1:0] inp_data1,
    input [`DWIDTH-1:0] inp_data2,
    input [`DWIDTH-1:0] inp_data3,
    input [`DWIDTH-1:0] inp_data4,
    input [`DWIDTH-1:0] inp_data5,
    input [`DWIDTH-1:0] inp_data6,
    input [`DWIDTH-1:0] inp_data7,
    input [`DWIDTH-1:0] inp_data8,
    input [`DWIDTH-1:0] inp_data9,
    input [`DWIDTH-1:0] inp_data10,
    input [`DWIDTH-1:0] inp_data11,
    input [`DWIDTH-1:0] inp_data12,
    input [`DWIDTH-1:0] inp_data13,
    input [`DWIDTH-1:0] inp_data14,
    input [`DWIDTH-1:0] inp_data15,
    input [`DWIDTH-1:0] inp_data16,
    input [`DWIDTH-1:0] inp_data17,
    input [`DWIDTH-1:0] inp_data18,
    input [`DWIDTH-1:0] inp_data19,
    input [`DWIDTH-1:0] inp_data20,
    input [`DWIDTH-1:0] inp_data21,
    input [`DWIDTH-1:0] inp_data22,
    input [`DWIDTH-1:0] inp_data23,
    input [`DWIDTH-1:0] inp_data24,
    input [`DWIDTH-1:0] inp_data25,
    input [`DWIDTH-1:0] inp_data26,
    input [`DWIDTH-1:0] inp_data27,
    input [`DWIDTH-1:0] inp_data28,
    input [`DWIDTH-1:0] inp_data29,
    input [`DWIDTH-1:0] inp_data30,
    input [`DWIDTH-1:0] inp_data31,
    output [`DWIDTH-1:0] out_data0,
    output [`DWIDTH-1:0] out_data1,
    output [`DWIDTH-1:0] out_data2,
    output [`DWIDTH-1:0] out_data3,
    output [`DWIDTH-1:0] out_data4,
    output [`DWIDTH-1:0] out_data5,
    output [`DWIDTH-1:0] out_data6,
    output [`DWIDTH-1:0] out_data7,
    output [`DWIDTH-1:0] out_data8,
    output [`DWIDTH-1:0] out_data9,
    output [`DWIDTH-1:0] out_data10,
    output [`DWIDTH-1:0] out_data11,
    output [`DWIDTH-1:0] out_data12,
    output [`DWIDTH-1:0] out_data13,
    output [`DWIDTH-1:0] out_data14,
    output [`DWIDTH-1:0] out_data15,
    output [`DWIDTH-1:0] out_data16,
    output [`DWIDTH-1:0] out_data17,
    output [`DWIDTH-1:0] out_data18,
    output [`DWIDTH-1:0] out_data19,
    output [`DWIDTH-1:0] out_data20,
    output [`DWIDTH-1:0] out_data21,
    output [`DWIDTH-1:0] out_data22,
    output [`DWIDTH-1:0] out_data23,
    output [`DWIDTH-1:0] out_data24,
    output [`DWIDTH-1:0] out_data25,
    output [`DWIDTH-1:0] out_data26,
    output [`DWIDTH-1:0] out_data27,
    output [`DWIDTH-1:0] out_data28,
    output [`DWIDTH-1:0] out_data29,
    output [`DWIDTH-1:0] out_data30,
    output [`DWIDTH-1:0] out_data31,
    output out_data_available,
    input [`MASK_WIDTH-1:0] validity_mask,
    output done_norm,
    input clk,
    input reset
);

reg in_data_available1;
reg in_data_available2;
reg in_data_available3;
reg in_data_available4;
reg in_data_available5;
reg in_data_available6;
reg in_data_available7;
reg in_data_available8;
reg in_data_available9;
reg in_data_available10;
reg in_data_available11;
reg in_data_available12;
reg in_data_available13;
reg in_data_available14;
reg in_data_available15;
reg in_data_available16;
reg in_data_available17;
reg in_data_available18;
reg in_data_available19;
reg in_data_available20;
reg in_data_available21;
reg in_data_available22;
reg in_data_available23;
reg in_data_available24;
reg in_data_available25;
reg in_data_available26;
reg in_data_available27;
reg in_data_available28;
reg in_data_available29;
reg in_data_available30;
reg in_data_available31;

always @(posedge clk) begin
    in_data_available1 <= in_data_available;
	in_data_available2 <= in_data_available1;
	in_data_available3 <= in_data_available2;
	in_data_available4 <= in_data_available3;
	in_data_available5 <= in_data_available4;
	in_data_available6 <= in_data_available5;
	in_data_available7 <= in_data_available6;
	in_data_available8 <= in_data_available7;
	in_data_available9 <= in_data_available8;
	in_data_available10 <= in_data_available9;
	in_data_available11 <= in_data_available10;
	in_data_available12 <= in_data_available11;
	in_data_available13 <= in_data_available12;
	in_data_available14 <= in_data_available13;
	in_data_available15 <= in_data_available14;
	in_data_available16 <= in_data_available15;
	in_data_available17 <= in_data_available16;
	in_data_available18 <= in_data_available17;
	in_data_available19 <= in_data_available18;
	in_data_available20 <= in_data_available19;
	in_data_available21 <= in_data_available20;
	in_data_available22 <= in_data_available21;
	in_data_available23 <= in_data_available22;
	in_data_available24 <= in_data_available23;
	in_data_available25 <= in_data_available24;
	in_data_available26 <= in_data_available25;
	in_data_available27 <= in_data_available26;
	in_data_available28 <= in_data_available27;
	in_data_available29 <= in_data_available28;
	in_data_available30 <= in_data_available29;
	in_data_available31 <= in_data_available30;
end

assign out_data_available = (enable_norm) ? out_data_available_internal : in_data_available;

wire out_data_available_internal;
wire out_data_available_NC;
wire out_data_available_final;

reg [`DWIDTH-1:0] done_count;
reg done_norm;

always @(posedge clk) begin
	if (reset) begin
		done_norm <= 0;
		done_count <= 0;
	end
	if (done_count == 4) begin
		done_norm <= 1;
	end
	if (out_data_available_final == 1) begin
		done_count <= done_count + 1;
	end
end

norm_sub norm0(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available),
    .inp_data(inp_data0),
    .out_data(out_data0),
    .out_data_available(out_data_available_internal),
    .validity_mask(validity_mask[0]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm1(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available1),
    .inp_data(inp_data1),
    .out_data(out_data1),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[1]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm2(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available2),
    .inp_data(inp_data2),
    .out_data(out_data2),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[2]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm3(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available3),
    .inp_data(inp_data3),
    .out_data(out_data3),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[3]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm4(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available4),
    .inp_data(inp_data4),
    .out_data(out_data4),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[4]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm5(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available5),
    .inp_data(inp_data5),
    .out_data(out_data5),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[5]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm6(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available6),
    .inp_data(inp_data6),
    .out_data(out_data6),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[6]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm7(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available7),
    .inp_data(inp_data7),
    .out_data(out_data7),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[7]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm8(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available8),
    .inp_data(inp_data8),
    .out_data(out_data8),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[8]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm9(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available9),
    .inp_data(inp_data9),
    .out_data(out_data9),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[9]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm10(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available10),
    .inp_data(inp_data10),
    .out_data(out_data10),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[10]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm11(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available11),
    .inp_data(inp_data11),
    .out_data(out_data11),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[11]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm12(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available12),
    .inp_data(inp_data12),
    .out_data(out_data12),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[12]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm13(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available13),
    .inp_data(inp_data13),
    .out_data(out_data13),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[13]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm14(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available14),
    .inp_data(inp_data14),
    .out_data(out_data14),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[14]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm15(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available15),
    .inp_data(inp_data15),
    .out_data(out_data15),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[15]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm16(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available16),
    .inp_data(inp_data16),
    .out_data(out_data16),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[16]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm17(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available17),
    .inp_data(inp_data17),
    .out_data(out_data17),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[17]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm18(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available18),
    .inp_data(inp_data18),
    .out_data(out_data18),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[18]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm19(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available19),
    .inp_data(inp_data19),
    .out_data(out_data19),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[19]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm20(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available20),
    .inp_data(inp_data20),
    .out_data(out_data20),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[20]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm21(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available21),
    .inp_data(inp_data21),
    .out_data(out_data21),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[21]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm22(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available22),
    .inp_data(inp_data22),
    .out_data(out_data22),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[22]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm23(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available23),
    .inp_data(inp_data23),
    .out_data(out_data23),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[23]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm24(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available24),
    .inp_data(inp_data24),
    .out_data(out_data24),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[24]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm25(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available25),
    .inp_data(inp_data25),
    .out_data(out_data25),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[25]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm26(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available26),
    .inp_data(inp_data26),
    .out_data(out_data26),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[26]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm27(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available27),
    .inp_data(inp_data27),
    .out_data(out_data27),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[27]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm28(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available28),
    .inp_data(inp_data28),
    .out_data(out_data28),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[28]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm29(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available29),
    .inp_data(inp_data29),
    .out_data(out_data29),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[29]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm30(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available30),
    .inp_data(inp_data30),
    .out_data(out_data30),
    .out_data_available(out_data_available_NC),
    .validity_mask(validity_mask[30]),
    .clk(clk),
    .reset(reset)
);

norm_sub norm31(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available31),
    .inp_data(inp_data31),
    .out_data(out_data31),
    .out_data_available(out_data_available_final),
    .validity_mask(validity_mask[31]),
    .clk(clk),
    .reset(reset)
);

endmodule

module norm_sub(
	input enable_norm,
    input [`DWIDTH-1:0] mean,
    input [`DWIDTH-1:0] inv_var,
    input in_data_available,
    input [`DWIDTH-1:0] inp_data,
    output [`DWIDTH-1:0] out_data,
    output out_data_available,
    input  validity_mask,
    input clk,
    input reset
);

reg out_data_available_internal;
wire [`DWIDTH-1:0] out_data_internal;
reg [`DWIDTH-1:0] mean_applied_data;
reg [`DWIDTH-1:0] variance_applied_data;
reg norm_in_progress;

//Muxing logic to handle the case when this block is disabled
assign out_data_available = (enable_norm) ? out_data_available_internal : in_data_available;
assign out_data = (enable_norm) ? out_data_internal : inp_data;

integer i;
always @(posedge clk) begin
    if ((reset || ~enable_norm)) begin
        mean_applied_data <= 0;
        variance_applied_data <= 0;
    end else if (in_data_available||norm_in_progress) begin
        //Let's apply mean and variance as the input data comes in.
        //We have a pipeline here. First stage does the add (to apply the mean)
        //and second stage does the multiplication (to apply the variance).
        //Note: the following loop is not a loop across multiple columns of data.
        //This loop will run in 2 cycle on the same column of data that comes into 
        //this module in 1 clock.
        if (validity_mask == 1'b1) begin
            mean_applied_data <= (inp_data - mean);
            variance_applied_data <= (mean_applied_data * inv_var);
        end 
        else begin
            mean_applied_data <= (inp_data);
            variance_applied_data <= (mean_applied_data);
        end
    end
    else begin
        mean_applied_data <= 0;
        variance_applied_data <= 0;
    end
end

//The data is normalized in two cycles so we are shifting in_data_available by 2 to generate out_data_available
always @(posedge clk) begin
	norm_in_progress <= in_data_available;
	out_data_available_internal <= norm_in_progress;
end

assign out_data_internal = variance_applied_data;

endmodule