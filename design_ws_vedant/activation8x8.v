module activation(
    input activation_type,
    input enable_activation,
    input enable_pool,
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
    output done_activation,
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

wire out_data_available_internal;
assign out_data_available   = enable_pool? enable_activation ? out_data_available_internal : in_data_available : in_data_available2;


wire out_data_available_NC;
wire out_data_available_final;
reg [`DWIDTH-1:0] act_count;
reg done_activation;

always @(posedge clk) begin
	if (reset) begin
		done_activation <= 0;
		act_count <= 0;
	end
	if (act_count == 4) begin
		done_activation <= 1;
	end
	if (out_data_available_final == 1) begin
		act_count <= act_count + 1;
	end
end

sub_activation activation0(
  .activation_type(activation_type),
  .enable_activation(enable_activation),
  .in_data_available(in_data_available),
  .inp_data(inp_data0),
  .out_data(out_data0),
  .out_data_available(out_data_available_internal),
  .validity_mask(validity_mask[0]),
  .clk(clk),
  .reset(reset)
);

sub_activation activation1(
  .activation_type(activation_type),
  .enable_activation(enable_activation),
  .in_data_available(in_data_available1),
  .inp_data(inp_data1),
  .out_data(out_data1),
  .out_data_available(out_data_available_NC),
  .validity_mask(validity_mask[1]),
  .clk(clk),
  .reset(reset)
);

sub_activation activation2(
  .activation_type(activation_type),
  .enable_activation(enable_activation),
  .in_data_available(in_data_available2),
  .inp_data(inp_data2),
  .out_data(out_data2),
  .out_data_available(out_data_available_NC),
  .validity_mask(validity_mask[2]),
  .clk(clk),
  .reset(reset)
);

sub_activation activation3(
  .activation_type(activation_type),
  .enable_activation(enable_activation),
  .in_data_available(in_data_available3),
  .inp_data(inp_data3),
  .out_data(out_data3),
  .out_data_available(out_data_available_NC),
  .validity_mask(validity_mask[3]),
  .clk(clk),
  .reset(reset)
);

sub_activation activation4(
  .activation_type(activation_type),
  .enable_activation(enable_activation),
  .in_data_available(in_data_available4),
  .inp_data(inp_data4),
  .out_data(out_data4),
  .out_data_available(out_data_available_NC),
  .validity_mask(validity_mask[4]),
  .clk(clk),
  .reset(reset)
);

sub_activation activation5(
  .activation_type(activation_type),
  .enable_activation(enable_activation),
  .in_data_available(in_data_available5),
  .inp_data(inp_data5),
  .out_data(out_data5),
  .out_data_available(out_data_available_NC),
  .validity_mask(validity_mask[5]),
  .clk(clk),
  .reset(reset)
);

sub_activation activation6(
  .activation_type(activation_type),
  .enable_activation(enable_activation),
  .in_data_available(in_data_available6),
  .inp_data(inp_data6),
  .out_data(out_data6),
  .out_data_available(out_data_available_NC),
  .validity_mask(validity_mask[6]),
  .clk(clk),
  .reset(reset)
);

sub_activation activation7(
  .activation_type(activation_type),
  .enable_activation(enable_activation),
  .in_data_available(in_data_available7),
  .inp_data(inp_data7),
  .out_data(out_data7),
  .out_data_available(out_data_available_final),
  .validity_mask(validity_mask[7]),
  .clk(clk),
  .reset(reset)
);

endmodule

module sub_activation(
    input activation_type,
    input enable_activation,
    input in_data_available,
    input [`DWIDTH-1:0] inp_data,
    output [`DWIDTH-1:0] out_data,
    output out_data_available,
    input validity_mask,
    input clk,
    input reset
);

reg  out_data_available_internal;
wire [`DWIDTH-1:0] out_data_internal;
reg [`DWIDTH-1:0] slope_applied_data_internal;
reg [`DWIDTH-1:0] intercept_applied_data_internal;
reg [`DWIDTH-1:0] relu_applied_data_internal;
integer i;
integer cycle_count;
reg activation_in_progress;

reg [3:0] address;
reg [`DWIDTH-1:0] data_slope;
reg [`DWIDTH-1:0] data_intercept;
reg [`DWIDTH-1:0] data_intercept_delayed;

// If the activation block is not enabled, just forward the input data
assign out_data             = enable_activation ? out_data_internal : inp_data;
assign out_data_available   = enable_activation ? out_data_available_internal : in_data_available;

always @(posedge clk) begin
   if (reset || ~enable_activation) begin
      slope_applied_data_internal     <= 0;
      intercept_applied_data_internal <= 0; 
      relu_applied_data_internal      <= 0; 
      data_intercept_delayed      <= 0;
      out_data_available_internal <= 0;
      cycle_count                 <= 0;
      activation_in_progress      <= 0;      
   end 
   else if(in_data_available || activation_in_progress) begin
      cycle_count = cycle_count + 1;
      if(activation_type==1'b1) begin // tanH
        slope_applied_data_internal <= data_slope * inp_data;
        data_intercept_delayed <= data_intercept;
        intercept_applied_data_internal <= slope_applied_data_internal + data_intercept_delayed;
      end else begin // ReLU
        relu_applied_data_internal <= (inp_data)? {`DWIDTH{1'b0}} : inp_data;
      end 
      
      //TANH needs 1 extra cycle
      if (activation_type==1'b1) begin
         if (cycle_count==2) begin
            out_data_available_internal <= 1;
         end
      end else begin
         if (cycle_count==1) begin
           out_data_available_internal <= 1;
         end
      end

      //TANH needs 1 extra cycle
      if (activation_type==1'b1) begin
        if(cycle_count==2) begin
           activation_in_progress <= 0;
        end
        else begin
           activation_in_progress <= 1;
        end
      end else begin
        if(cycle_count==1) begin
           activation_in_progress <= 0;
        end
        else begin
           activation_in_progress <= 1;
        end
      end
   end   
   else begin
      slope_applied_data_internal     <= 0;
      intercept_applied_data_internal <= 0; 
      relu_applied_data_internal      <= 0; 
      data_intercept_delayed      <= 0;
      out_data_available_internal <= 0;
      cycle_count                 <= 0;
      activation_in_progress      <= 0;
   end
end

assign out_data_internal = (activation_type) ? intercept_applied_data_internal : relu_applied_data_internal;

//Our equation of tanh is Y=AX+B
//A is the slope and B is the intercept.
//We store A in one LUT and B in another.
//LUT for the slope
always @(address) begin
    case (address)
      4'b0000: data_slope = 8'd0;
      4'b0001: data_slope = 8'd0;
      4'b0010: data_slope = 8'd2;
      4'b0011: data_slope = 8'd3;
      4'b0100: data_slope = 8'd4;
      4'b0101: data_slope = 8'd0;
      4'b0110: data_slope = 8'd4;
      4'b0111: data_slope = 8'd3;
      4'b1000: data_slope = 8'd2;
      4'b1001: data_slope = 8'd0;
      4'b1010: data_slope = 8'd0;
      default: data_slope = 8'd0;
    endcase  
end

//LUT for the intercept
always @(address) begin
    case (address)
      4'b0000: data_intercept = 8'd127;
      4'b0001: data_intercept = 8'd99;
      4'b0010: data_intercept = 8'd46;
      4'b0011: data_intercept = 8'd18;
      4'b0100: data_intercept = 8'd0;
      4'b0101: data_intercept = 8'd0;
      4'b0110: data_intercept = 8'd0;
      4'b0111: data_intercept = -8'd18;
      4'b1000: data_intercept = -8'd46;
      4'b1001: data_intercept = -8'd99;
      4'b1010: data_intercept = -8'd127;
      default: data_intercept = 8'd0;
    endcase  
end

//Logic to find address
always @(inp_data) begin
        if((inp_data)>=90) begin
           address = 4'b0000;
        end
        else if ((inp_data)>=39 && (inp_data)<90) begin
           address = 4'b0001;
        end
        else if ((inp_data)>=28 && (inp_data)<39) begin
           address = 4'b0010;
        end
        else if ((inp_data)>=16 && (inp_data)<28) begin
           address = 4'b0011;
        end
        else if ((inp_data)>=1 && (inp_data)<16) begin
           address = 4'b0100;
        end
        else if ((inp_data)==0) begin
           address = 4'b0101;
        end
        else if ((inp_data)>-16 && (inp_data)<=-1) begin
           address = 4'b0110;
        end
        else if ((inp_data)>-28 && (inp_data)<=-16) begin
           address = 4'b0111;
        end
        else if ((inp_data)>-39 && (inp_data)<=-28) begin
           address = 4'b1000;
        end
        else if ((inp_data)>-90 && (inp_data)<=-39) begin
           address = 4'b1001;
        end
        else if ((inp_data)<=-90) begin
           address = 4'b1010;
        end
        else begin
           address = 4'b0101;
        end
end

//Adding a dummy signal to use validity_mask input, to make ODIN happy
//TODO: Need to correctly use validity_mask
wire [`MASK_WIDTH-1:0] dummy;
assign dummy = validity_mask;


endmodule

