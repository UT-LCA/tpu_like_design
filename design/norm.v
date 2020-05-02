module norm(
    input enable_norm,
    input [`DWIDTH-1:0] mean,
    input [`DWIDTH-1:0] inv_var,
    input in_data_available,
    input [`MAT_MUL_SIZE*`DWIDTH-1:0] inp_data,
    output [`MAT_MUL_SIZE*`DWIDTH-1:0] out_data,
    output out_data_available,
    input [`MASK_WIDTH-1:0] validity_mask,
    output done_norm,
    input clk,
    input reset
);

reg out_data_available_internal;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] out_data_internal;
reg [`MAT_MUL_SIZE*`DWIDTH-1:0] mean_applied_data;
reg [`MAT_MUL_SIZE*`DWIDTH-1:0] variance_applied_data;
reg done_norm_internal;
reg norm_in_progress;

//Muxing logic to handle the case when this block is disabled
assign out_data_available = (enable_norm) ? out_data_available_internal : in_data_available;
assign out_data = (enable_norm) ? out_data_internal : inp_data;
assign done_norm = (enable_norm) ? done_norm_internal : 1'b1;

//inp_data will have multiple elements in it. the number of elements is the same as size of the matmul.
//on each clock edge, if in_data_available is 1, then we will normalize the inputs.

//the code uses the funky part-select syntax. example:
//wire [7:0] byteN = word[byte_num*8 +: 8];
//byte_num*8 is the starting point. 8 is the width is the part-select (has to be constant).in_data_available
//+: indicates the part-select increases from the starting point
//-: indicates the part-select decreases from the starting point
//another example:
//loc = 3;
//PA[loc -:4] = PA[loc+1 +:4];  // equivalent to PA[3:0] = PA[7:4];

integer cycle_count;
integer i;
always @(posedge clk) begin
    if ((reset || ~enable_norm)) begin
        mean_applied_data <= 0;
        variance_applied_data <= 0;
        out_data_available_internal <= 0;
        cycle_count <= 0;
        done_norm_internal <= 0;
        norm_in_progress <= 0;
    end else if (in_data_available || norm_in_progress) begin
        cycle_count = cycle_count + 1;
        //Let's apply mean and variance as the input data comes in.
        //We have a pipeline here. First stage does the add (to apply the mean)
        //and second stage does the multiplication (to apply the variance).
        //Note: the following loop is not a loop across multiple columns of data.
        //This loop will run in 2 cycle on the same column of data that comes into 
        //this module in 1 clock.
        for (i = 0; i < `MAT_MUL_SIZE; i=i+1) begin
            if (validity_mask[i] == 1'b1) begin
                mean_applied_data[i*`DWIDTH +: `DWIDTH] <= (inp_data[i*`DWIDTH +: `DWIDTH] - mean);
                variance_applied_data[i*`DWIDTH +: `DWIDTH] <= (mean_applied_data[i*`DWIDTH +: `DWIDTH] * inv_var);
            end 
            else begin
                mean_applied_data[i*`DWIDTH +: `DWIDTH] <= (inp_data[i*`DWIDTH +: `DWIDTH]);
                variance_applied_data[i*`DWIDTH +: `DWIDTH] <= (mean_applied_data[i*`DWIDTH +: `DWIDTH]);
            end
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
        if(cycle_count==(`MAT_MUL_SIZE+1)) begin
            done_norm_internal <= 1'b1;
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
        done_norm_internal <= 0;
        norm_in_progress <= 0;
    end
end

assign out_data_internal = variance_applied_data;

endmodule