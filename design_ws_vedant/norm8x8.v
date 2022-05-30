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
    output [`DWIDTH-1:0] out_data0,
    output [`DWIDTH-1:0] out_data1,
    output [`DWIDTH-1:0] out_data2,
    output [`DWIDTH-1:0] out_data3,
    output [`DWIDTH-1:0] out_data4,
    output [`DWIDTH-1:0] out_data5,
    output [`DWIDTH-1:0] out_data6,
    output [`DWIDTH-1:0] out_data7,
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

always @(posedge clk) begin
	in_data_available1 <= in_data_available;
	in_data_available2 <= in_data_available1;
	in_data_available3 <= in_data_available2;
	in_data_available4 <= in_data_available3;
	in_data_available5 <= in_data_available4;
	in_data_available6 <= in_data_available5;
	in_data_available7 <= in_data_available6;	
end

assign out_data_available = enable_pool? (enable_norm) ? out_data_available_internal : in_data_available : in_data_available2;

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
    .out_data_available(out_data_available_final),
    .validity_mask(validity_mask[7]),
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

integer cycle_count;
integer i;
always @(posedge clk) begin
    if ((reset || ~enable_norm)) begin
        mean_applied_data <= 0;
        variance_applied_data <= 0;
        out_data_available_internal <= 0;
        cycle_count <= 0;
        norm_in_progress <= 0;
    end else if (in_data_available||norm_in_progress) begin
        cycle_count = cycle_count + 1;
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
        //Out data is available starting with the second clock cycle because 
        //in the first cycle, we only apply the mean.
        if(cycle_count==2) begin
            out_data_available_internal <= 1;
        end

        //When we've normalized values N times, where N is the matmul
        //size, that means we're done. But there is one additional cycle
        //that is taken in the beginning (when we are applying the mean to the first
        //column of data). We can call this the Initiation Interval of the pipeline.
        //So, for a 4x4 matmul, this block takes 5 cycles.
        if(cycle_count==2) begin
            norm_in_progress <= 0;
        end
        else begin
            norm_in_progress <= 1;
        end
    end
    else begin
        mean_applied_data <= 0;
        variance_applied_data <= 0;
        out_data_available_internal <= 0;
        cycle_count <= 0;
        norm_in_progress <= 0;
    end
end

assign out_data_internal = variance_applied_data;

endmodule