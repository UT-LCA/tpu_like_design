////////////////////////////////////////////////////////////////////////////////
// THIS FILE WAS AUTOMATICALLY GENERATED FROM generate_norm.v.mako
// DO NOT EDIT
////////////////////////////////////////////////////////////////////////////////
module norm(
    input enable_norm,
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
end

wire out_data_available_internal;
wire out_data_available_final;

reg [`DWIDTH-1:0] done_count;
reg done_norm;

assign out_data_available = (enable_norm) ? out_data_available_internal : in_data_available;

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

wire out_data_available_NC1;
norm_sub norm1(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available1),
    .inp_data(inp_data1),
    .out_data(out_data1),
    .out_data_available(out_data_available_NC1),
    .validity_mask(validity_mask[1]),
    .clk(clk),
    .reset(reset)
);

wire out_data_available_NC2;
norm_sub norm2(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available2),
    .inp_data(inp_data2),
    .out_data(out_data2),
    .out_data_available(out_data_available_NC2),
    .validity_mask(validity_mask[2]),
    .clk(clk),
    .reset(reset)
);

wire out_data_available_NC3;
norm_sub norm3(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available3),
    .inp_data(inp_data3),
    .out_data(out_data3),
    .out_data_available(out_data_available_NC3),
    .validity_mask(validity_mask[3]),
    .clk(clk),
    .reset(reset)
);

wire out_data_available_NC4;
norm_sub norm4(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available4),
    .inp_data(inp_data4),
    .out_data(out_data4),
    .out_data_available(out_data_available_NC4),
    .validity_mask(validity_mask[4]),
    .clk(clk),
    .reset(reset)
);

wire out_data_available_NC5;
norm_sub norm5(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available5),
    .inp_data(inp_data5),
    .out_data(out_data5),
    .out_data_available(out_data_available_NC5),
    .validity_mask(validity_mask[5]),
    .clk(clk),
    .reset(reset)
);

wire out_data_available_NC6;
norm_sub norm6(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available6),
    .inp_data(inp_data6),
    .out_data(out_data6),
    .out_data_available(out_data_available_NC6),
    .validity_mask(validity_mask[6]),
    .clk(clk),
    .reset(reset)
);

wire out_data_available_NC7;
norm_sub norm7(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available7),
    .inp_data(inp_data7),
    .out_data(out_data7),
    .out_data_available(out_data_available_NC7),
    .validity_mask(validity_mask[7]),
    .clk(clk),
    .reset(reset)
);

wire out_data_available_NC8;
norm_sub norm8(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available8),
    .inp_data(inp_data8),
    .out_data(out_data8),
    .out_data_available(out_data_available_NC8),
    .validity_mask(validity_mask[8]),
    .clk(clk),
    .reset(reset)
);

wire out_data_available_NC9;
norm_sub norm9(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available9),
    .inp_data(inp_data9),
    .out_data(out_data9),
    .out_data_available(out_data_available_NC9),
    .validity_mask(validity_mask[9]),
    .clk(clk),
    .reset(reset)
);

wire out_data_available_NC10;
norm_sub norm10(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available10),
    .inp_data(inp_data10),
    .out_data(out_data10),
    .out_data_available(out_data_available_NC10),
    .validity_mask(validity_mask[10]),
    .clk(clk),
    .reset(reset)
);

wire out_data_available_NC11;
norm_sub norm11(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available11),
    .inp_data(inp_data11),
    .out_data(out_data11),
    .out_data_available(out_data_available_NC11),
    .validity_mask(validity_mask[11]),
    .clk(clk),
    .reset(reset)
);

wire out_data_available_NC12;
norm_sub norm12(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available12),
    .inp_data(inp_data12),
    .out_data(out_data12),
    .out_data_available(out_data_available_NC12),
    .validity_mask(validity_mask[12]),
    .clk(clk),
    .reset(reset)
);

wire out_data_available_NC13;
norm_sub norm13(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available13),
    .inp_data(inp_data13),
    .out_data(out_data13),
    .out_data_available(out_data_available_NC13),
    .validity_mask(validity_mask[13]),
    .clk(clk),
    .reset(reset)
);

wire out_data_available_NC14;
norm_sub norm14(
	.enable_norm(enable_norm),
    .mean(mean),
    .inv_var(inv_var),
    .in_data_available(in_data_available14),
    .inp_data(inp_data14),
    .out_data(out_data14),
    .out_data_available(out_data_available_NC14),
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
    .out_data_available(out_data_available_final),
    .validity_mask(validity_mask[15]),
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

