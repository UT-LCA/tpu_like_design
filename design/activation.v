module activation(
    input enable_activation,
    input in_data_available,
    input [`MAT_MUL_SIZE*`DWIDTH-1:0] inp_data,
    output [`MAT_MUL_SIZE*`DWIDTH-1:0] out_data,
    output out_data_available,
    input [`MASK_WIDTH-1:0] validity_mask,
    output done_activation,
    input clk,
    input reset
);

reg  finish_activation;
reg  out_data_valid;
reg  [`MAT_MUL_SIZE*`DWIDTH-1:0] out_activation;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] temp;

// If the activation block is not enabled, just forward the input data
assign out_data             = enable_activation ? out_activation    : inp_data;
assign done_activation      = enable_activation ? finish_activation : 1'b1;
assign out_data_available   = enable_activation ? out_data_valid    : in_data_available;

always @(posedge clk) begin
    if (reset) begin
      out_activation   <= {`MAT_MUL_SIZE*`DWIDTH-1{1'b0}};
      finish_activation<= 1'b0;
      out_data_valid   <= 1'b0;
    end
    else begin
       if(in_data_available) begin
           out_activation   <= temp;
           finish_activation<= 1'b1;
           out_data_valid   <= 1'b1;
       end
       else begin
           out_activation   <= {`MAT_MUL_SIZE*`DWIDTH-1{1'b0}};
           finish_activation<= 1'b0;
           out_data_valid   <= 1'b0;
       end
    end
end

// generate multiple ReLU block based on the MAT_MUL_SIZE
genvar i;
generate 
  for (i = 1; i <= `MAT_MUL_SIZE; i = i + 1) begin : loop_gen_ReLU
        ReLU ReLUinst (.inp_data(inp_data[i*`DWIDTH-1 -:`DWIDTH]), .out_data(temp[i*`DWIDTH-1 -:`DWIDTH]));
  end
endgenerate

endmodule

module ReLU(
    input [`DWIDTH-1:0] inp_data,
    output[`DWIDTH-1:0] out_data
);

assign out_data = inp_data[`DWIDTH-1] ? {`DWIDTH{1'b0}} : inp_data;

endmodule