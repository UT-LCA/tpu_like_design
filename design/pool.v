module pool(
    input enable_pool,
    input in_data_available,
		input [`MAX_BITS_POOL-1:0] kernel_size,
		input [`MAT_MUL_SIZE-1:0] valid_mask,
    input [`MAT_MUL_SIZE*`DWIDTH-1:0] inp_data,
    output [`MAT_MUL_SIZE*`DWIDTH-1:0] out_data,
    output out_data_available,
    input [`MASK_WIDTH-1:0] validity_mask,
    output done_pool,
    input clk,
    input reset
);

reg [`MAT_MUL_SIZE*`DWIDTH-1:0] out_data_temp;
reg out_data_available_temp;
integer i,j;

always @(posedge clk) begin
	if (reset) begin
		out_data_temp = 0;	
	end

	else if (enable_pool) begin

			out_data_available_temp <= 1;
			done_pool <= 1;

			case (kernel_size)
				1: begin
					out_data_temp = in_data_available;
				end
				2: begin
					for (i = 0; i < `MAT_MUL_SIZE/2; i = i + 8) begin
							out_data_temp[ i +: 8] = (inp_data[i*2 +: 8]  + inp_data[i*2 + 8 +: 8]) >> 1; 
					end
				end
				4: begin	
					for (i = 0; i < `MAT_MUL_SIZE/4; i = i + 8) begin
							out_data_temp[ i +: 8] = (inp_data[i*4 +: 8]  + inp_data[i*4 + 8 +: 8] + inp_data[i*4 + 16 +: 8]  + inp_data[i*4 + 24 +: 8]) >> 2; 
					end
				end

			endcase			
	end
end

assign out_data = enable_pool ? out_data_temp : inp_data; 
assign out_data_available = enable_pool ? out_data_available_temp : in_data_available;

endmodule
