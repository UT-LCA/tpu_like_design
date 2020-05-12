module activation(
    input activation_type,
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
integer i;

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
           for (i = 1; i <= `MAT_MUL_SIZE; i=i+1) begin
               if(activation_type==1'b1) begin // tanH
                   if($signed(inp_data[i*`DWIDTH-1 -:`DWIDTH])>=90) begin
                       out_activation[i*`DWIDTH-1 -:`DWIDTH] = 0 * inp_data[i*`DWIDTH-1 -:`DWIDTH] + 127;
                   end
                   else if ($signed(inp_data[i*`DWIDTH-1 -:`DWIDTH])>=39 && $signed(inp_data[i*`DWIDTH-1 -:`DWIDTH])<90) begin
                       out_activation[i*`DWIDTH-1 -:`DWIDTH] = 0 * inp_data[i*`DWIDTH-1 -:`DWIDTH] + 99;
                   end
                   else if ($signed(inp_data[i*`DWIDTH-1 -:`DWIDTH])>=28 && $signed(inp_data[i*`DWIDTH-1 -:`DWIDTH])<39) begin
                       out_activation[i*`DWIDTH-1 -:`DWIDTH] = 2 * inp_data[i*`DWIDTH-1 -:`DWIDTH] + 46;
                   end
                   else if ($signed(inp_data[i*`DWIDTH-1 -:`DWIDTH])>=16 && $signed(inp_data[i*`DWIDTH-1 -:`DWIDTH])<28) begin
                       out_activation[i*`DWIDTH-1 -:`DWIDTH] = 3 * inp_data[i*`DWIDTH-1 -:`DWIDTH] + 18;
                   end
                   else if ($signed(inp_data[i*`DWIDTH-1 -:`DWIDTH])>=1 && $signed(inp_data[i*`DWIDTH-1 -:`DWIDTH])<16) begin
                       out_activation[i*`DWIDTH-1 -:`DWIDTH] = 4 * inp_data[i*`DWIDTH-1 -:`DWIDTH] + 0;
                   end
                   else if ($signed(inp_data[i*`DWIDTH-1 -:`DWIDTH])==0) begin
                       out_activation[i*`DWIDTH-1 -:`DWIDTH] = 0 * inp_data[i*`DWIDTH-1 -:`DWIDTH] + 0;
                   end
                   else if ($signed(inp_data[i*`DWIDTH-1 -:`DWIDTH])>-16 && $signed(inp_data[i*`DWIDTH-1 -:`DWIDTH])<=-1) begin
                       out_activation[i*`DWIDTH-1 -:`DWIDTH] = 4 * inp_data[i*`DWIDTH-1 -:`DWIDTH] - 0;
                   end
                   else if ($signed(inp_data[i*`DWIDTH-1 -:`DWIDTH])>-28 && $signed(inp_data[i*`DWIDTH-1 -:`DWIDTH])<=-16) begin
                       out_activation[i*`DWIDTH-1 -:`DWIDTH] = 3 * inp_data[i*`DWIDTH-1 -:`DWIDTH] - 18;
                   end
                   else if ($signed(inp_data[i*`DWIDTH-1 -:`DWIDTH])>-39 && $signed(inp_data[i*`DWIDTH-1 -:`DWIDTH])<=-28) begin
                       out_activation[i*`DWIDTH-1 -:`DWIDTH] = 2 * inp_data[i*`DWIDTH-1 -:`DWIDTH] - 46;
                   end
                   else if ($signed(inp_data[i*`DWIDTH-1 -:`DWIDTH])>-90 && $signed(inp_data[i*`DWIDTH-1 -:`DWIDTH])<=-39) begin
                       out_activation[i*`DWIDTH-1 -:`DWIDTH] = 0 * inp_data[i*`DWIDTH-1 -:`DWIDTH] - 99;
                   end
                   else if ($signed(inp_data[i*`DWIDTH-1 -:`DWIDTH])<=-90) begin
                       out_activation[i*`DWIDTH-1 -:`DWIDTH] = 0 * inp_data[i*`DWIDTH-1 -:`DWIDTH] - 127;
                   end
               end
               else begin // ReLU
                    out_activation[i*`DWIDTH-1 -:`DWIDTH] <= inp_data[i*`DWIDTH-1] ? {`DWIDTH{1'b0}} : inp_data[i*`DWIDTH-1 -:`DWIDTH];
               end
           end 
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
//genvar i;
//generate 
//  for (i = 1; i <= `MAT_MUL_SIZE; i = i + 1) begin : loop_gen_ReLU
//        ReLU ReLUinst (.inp_data(inp_data[i*`DWIDTH-1 -:`DWIDTH]), .out_data(temp[i*`DWIDTH-1 -:`DWIDTH]));
//  end
//endgenerate

endmodule

//module ReLU(
//    input [`DWIDTH-1:0] inp_data,
//    output[`DWIDTH-1:0] out_data
//);
//
//assign out_data = inp_data[`DWIDTH-1] ? {`DWIDTH{1'b0}} : inp_data;
//
//endmodule