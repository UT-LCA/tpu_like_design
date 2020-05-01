module norm(
    input enable_norm,
    input [`DWIDTH-1:0] mean,
    input [`DWIDTH-1:0] inv_var,
    input in_data_available,
    input [`MAT_MUL_SIZE*`DWIDTH-1:0] inp_data,
    output [`MAT_MUL_SIZE*`DWIDTH-1:0] out_data,
    output out_data_available,
    output done_norm,
    input clk,
    input reset
);

reg out_data_available_internal;
reg [`MAT_MUL_SIZE*`DWIDTH-1:0] out_data_internal;
reg done_norm_internal;

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
always @(posedge clk) begin
    if (reset || ~in_data_available || ~enable_norm) begin
        out_data_internal <= 0;
        out_data_available_internal <= 0;
        cycle_count <= 0;
        done_norm_internal <= 0;
    end else if (in_data_available) begin
        cycle_count++;
        //TODO: This may not compile on ODIN. So, might have to change
        //to a non-loop implementation
        //Note: the following loop is not a loop across multiple cycles.
        //This loop will run in 1 cycle.
        for (integer i = 0; i < `MAT_MUL_SIZE; i++) begin
            out_data_internal[i*`DWIDTH +: `DWIDTH] <= (inp_data[i*`DWIDTH +: `DWIDTH] - mean) * inv_var;
        end

        //In each cycle while we're doing normalization, keep
        //data available asserted.
        out_data_available_internal <= 1;

        //When we've normalized values N times, where N is the matmul
        //size, that means we're done. Eg 4 cycles for 4x4 matmul.
        if(cycle_count==`MAT_MUL_SIZE) begin
            done_norm_internal <= 1'b1;
        end
    end
end

//TODO: Will need to create a pipelined design here.
//We want to do the subtraction in one cycle
//and multiplication in the next cycle
/*
reg [3:0] state;
`define STATE_INIT 4'b0000
`define STATE_ADD 4'b0001
`define STATE_MUL 4'b0010
`define 
always @( posedge clk) begin
  if (reset || ~in_data_available) begin
    state <= 4'b0000;
    out_data <= 0;
    out_data_available <= 0;
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
  endcase  
end 
end
*/

endmodule