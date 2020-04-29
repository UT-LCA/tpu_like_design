module norm(
    input enable_norm;
    input [`DWIDTH-1:0] mean;
    input [`DWIDTH-1:0] inv_var;
    input in_data_available;
    input [`MAT_MUL_SIZE*`DWIDTH-1:0] inp_data;
    output [`MAT_MUL_SIZE*`DWIDTH-1:0] out_data;
    output out_data_available;
    input clk;
    input reset;
);

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


always @(posedge clk) begin
    if (reset || ~enable_norm || ~in_data_available) begin
        out_data <= 0;
        out_data_available <= 0;
    end else if (in_data_available) begin
        for (integer i = 0; i < `MAT_MUL_SIZE; i++) begin
            out_data[i*`DWIDTH +: `DWIDTH] <= (in_data[i*`DWIDTH +: `DWIDTH] - mean) * inv_var;
        end
        out_data_available <= 1;
    end

endmodule