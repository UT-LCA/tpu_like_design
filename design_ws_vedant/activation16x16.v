////////////////////////////////////////////////////////////////////////////////
// THIS FILE WAS AUTOMATICALLY GENERATED FROM generate_activation.v.mako
// DO NOT EDIT
////////////////////////////////////////////////////////////////////////////////
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
assign out_data_available   = enable_pool? enable_activation ? out_data_available_internal : in_data_available : in_data_available2;


wire out_data_available_final;
reg [`DWIDTH-1:0] act_count;
reg done_activation;
reg [`DWIDTH-1:0] done_activation_count;

always @(posedge clk) begin
	if (reset) begin
		done_activation <= 0;
      done_activation_count <= 0;
		act_count <= 0;
	end
   else if (done_activation_count == `MAT_MUL_SIZE)
      done_activation <= 0;
	else if (act_count == 4) begin
		done_activation <= 1;
      done_activation_count <= done_activation_count + 1;
	end
	else if (out_data_available_final == 1) begin
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

wire out_data_available_NC1;
sub_activation activation1(
    .activation_type(activation_type),
    .enable_activation(enable_activation),
    .in_data_available(in_data_available1),
    .inp_data(inp_data1),
    .out_data(out_data1),
    .out_data_available(out_data_available_NC1),
    .validity_mask(validity_mask[1]),
    .clk(clk),
    .reset(reset)
);    

wire out_data_available_NC2;
sub_activation activation2(
    .activation_type(activation_type),
    .enable_activation(enable_activation),
    .in_data_available(in_data_available2),
    .inp_data(inp_data2),
    .out_data(out_data2),
    .out_data_available(out_data_available_NC2),
    .validity_mask(validity_mask[2]),
    .clk(clk),
    .reset(reset)
);    

wire out_data_available_NC3;
sub_activation activation3(
    .activation_type(activation_type),
    .enable_activation(enable_activation),
    .in_data_available(in_data_available3),
    .inp_data(inp_data3),
    .out_data(out_data3),
    .out_data_available(out_data_available_NC3),
    .validity_mask(validity_mask[3]),
    .clk(clk),
    .reset(reset)
);    

wire out_data_available_NC4;
sub_activation activation4(
    .activation_type(activation_type),
    .enable_activation(enable_activation),
    .in_data_available(in_data_available4),
    .inp_data(inp_data4),
    .out_data(out_data4),
    .out_data_available(out_data_available_NC4),
    .validity_mask(validity_mask[4]),
    .clk(clk),
    .reset(reset)
);    

wire out_data_available_NC5;
sub_activation activation5(
    .activation_type(activation_type),
    .enable_activation(enable_activation),
    .in_data_available(in_data_available5),
    .inp_data(inp_data5),
    .out_data(out_data5),
    .out_data_available(out_data_available_NC5),
    .validity_mask(validity_mask[5]),
    .clk(clk),
    .reset(reset)
);    

wire out_data_available_NC6;
sub_activation activation6(
    .activation_type(activation_type),
    .enable_activation(enable_activation),
    .in_data_available(in_data_available6),
    .inp_data(inp_data6),
    .out_data(out_data6),
    .out_data_available(out_data_available_NC6),
    .validity_mask(validity_mask[6]),
    .clk(clk),
    .reset(reset)
);    

wire out_data_available_NC7;
sub_activation activation7(
    .activation_type(activation_type),
    .enable_activation(enable_activation),
    .in_data_available(in_data_available7),
    .inp_data(inp_data7),
    .out_data(out_data7),
    .out_data_available(out_data_available_NC7),
    .validity_mask(validity_mask[7]),
    .clk(clk),
    .reset(reset)
);    

wire out_data_available_NC8;
sub_activation activation8(
    .activation_type(activation_type),
    .enable_activation(enable_activation),
    .in_data_available(in_data_available8),
    .inp_data(inp_data8),
    .out_data(out_data8),
    .out_data_available(out_data_available_NC8),
    .validity_mask(validity_mask[8]),
    .clk(clk),
    .reset(reset)
);    

wire out_data_available_NC9;
sub_activation activation9(
    .activation_type(activation_type),
    .enable_activation(enable_activation),
    .in_data_available(in_data_available9),
    .inp_data(inp_data9),
    .out_data(out_data9),
    .out_data_available(out_data_available_NC9),
    .validity_mask(validity_mask[9]),
    .clk(clk),
    .reset(reset)
);    

wire out_data_available_NC10;
sub_activation activation10(
    .activation_type(activation_type),
    .enable_activation(enable_activation),
    .in_data_available(in_data_available10),
    .inp_data(inp_data10),
    .out_data(out_data10),
    .out_data_available(out_data_available_NC10),
    .validity_mask(validity_mask[10]),
    .clk(clk),
    .reset(reset)
);    

wire out_data_available_NC11;
sub_activation activation11(
    .activation_type(activation_type),
    .enable_activation(enable_activation),
    .in_data_available(in_data_available11),
    .inp_data(inp_data11),
    .out_data(out_data11),
    .out_data_available(out_data_available_NC11),
    .validity_mask(validity_mask[11]),
    .clk(clk),
    .reset(reset)
);    

wire out_data_available_NC12;
sub_activation activation12(
    .activation_type(activation_type),
    .enable_activation(enable_activation),
    .in_data_available(in_data_available12),
    .inp_data(inp_data12),
    .out_data(out_data12),
    .out_data_available(out_data_available_NC12),
    .validity_mask(validity_mask[12]),
    .clk(clk),
    .reset(reset)
);    

wire out_data_available_NC13;
sub_activation activation13(
    .activation_type(activation_type),
    .enable_activation(enable_activation),
    .in_data_available(in_data_available13),
    .inp_data(inp_data13),
    .out_data(out_data13),
    .out_data_available(out_data_available_NC13),
    .validity_mask(validity_mask[13]),
    .clk(clk),
    .reset(reset)
);    

wire out_data_available_NC14;
sub_activation activation14(
    .activation_type(activation_type),
    .enable_activation(enable_activation),
    .in_data_available(in_data_available14),
    .inp_data(inp_data14),
    .out_data(out_data14),
    .out_data_available(out_data_available_NC14),
    .validity_mask(validity_mask[14]),
    .clk(clk),
    .reset(reset)
);    

sub_activation activation15(
  .activation_type(activation_type),
  .enable_activation(enable_activation),
  .in_data_available(in_data_available15),
  .inp_data(inp_data15),
  .out_data(out_data15),
  .out_data_available(out_data_available_final),
  .validity_mask(validity_mask[15]),
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
reg [`DWIDTH-1:0] out_data_internal;
reg [`DWIDTH-1:0] slope_applied_data_internal;
reg [`DWIDTH-1:0] intercept_applied_data_internal;
reg [`DWIDTH-1:0] relu_applied_data_internal;

reg [31:0] cycle_count;
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
      cycle_count <= cycle_count + 1;
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

always @ (posedge clk) begin
   if (activation_type == 1'b1)
      out_data_internal <= intercept_applied_data_internal;
   else
      out_data_internal <= relu_applied_data_internal;
end

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

