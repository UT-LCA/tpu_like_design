<%!
    import math
%>\
<% 
    mat_mul_size = int(matmul_size)
    log2_mat_mul_size = int(math.log2(mat_mul_size))
%>\
module accumulator (
    clk,
    resetn,
    start_waddr_accum0,
    % for i in range(mat_mul_size):
    wdata_accum${i},
    % endfor
    % for i in range(mat_mul_size):
    raddr_accum${i}_pool,
    % endfor
    % for i in range(mat_mul_size):
    rdata_accum${i}_pool,
    % endfor
    wdata_available,
    k_dimension,
    buffer_select,
    start_pooling,
    done_pooling
);

input clk;
input resetn;
input [`AWIDTH-1:0] start_waddr_accum0;
% for i in range(mat_mul_size):
input [`DWIDTH-1:0] wdata_accum${i};
% endfor
% for i in range(mat_mul_size):
input [`AWIDTH-1:0] raddr_accum${i}_pool;
% endfor
% for i in range(mat_mul_size):
output [`DWIDTH-1:0] rdata_accum${i}_pool;
% endfor
input wdata_available;
input [7:0] k_dimension; // Number of columns in Matrix A | Number of rows in Matrix B (Assumption: Maximum = 256, can be changed accordingly)
input buffer_select;
output start_pooling;
output done_pooling;
  

parameter MWIDTH = 1;

% for i in range(1,mat_mul_size):
reg wdata_available${i};
% endfor

always @ (posedge clk) begin
    wdata_available1 <= wdata_available;
    % for i in range(1,mat_mul_size-1):
    wdata_available${i+1} <= wdata_available${i};
    % endfor
end

% for i in range(mat_mul_size):
wire wdata_en_ping${i};
% endfor
% for i in range(mat_mul_size):
wire wdata_en_pong${i};
% endfor

assign wdata_en_ping0 = wdata_available & buffer_select;
% for i in range(1,mat_mul_size):
assign wdata_en_ping${i} = wdata_available${i} & buffer_select;
% endfor

assign wdata_en_pong0 = wdata_available & ~buffer_select;
% for i in range(1,mat_mul_size):
assign wdata_en_pong${i} = wdata_available${i} & ~buffer_select;
% endfor

reg [7:0] addr_counter;
% for i in range(mat_mul_size):
reg [`AWIDTH-1:0] waddr_accum${i};
% endfor
% for i in range(mat_mul_size):
reg add_accum_mux${i};
% endfor

always @ (posedge clk) begin
    if (~wdata_available | (addr_counter == (k_dimension-1))) begin
        add_accum_mux0 <= 0;
        addr_counter <= 0;
    end
    else if (addr_counter == (`MAT_MUL_SIZE-1) & k_dimension != `MAT_MUL_SIZE) begin
        add_accum_mux0 <= 1;
        addr_counter <= addr_counter + 1;
    end
    else if (wdata_available)
        addr_counter <= addr_counter + 1;
end

reg start_pooling;
reg done_pooling;
reg [7:0] start_pooling_count;
always @ (posedge clk) begin
    if (~resetn)
        start_pooling <= 0;
    //TODO: Note the hardcodign of value below.
    //This value (8'd14) is supposed to be 2*MATMUL_SIZE-2.
    //For 8x8 matmul, this is 8'd14
    //For 16x16 matmul, this should be 8'd30
    //For 32x32 matmul, this should be 8'd62
    else if (start_pooling_count > 8'd14) begin
    	start_pooling <= 0;
    	done_pooling <= 1;
    end
    else if (waddr_accum2 != 0 & wdata_available2 == 0)
        start_pooling <= 1;
end
  
always @ (posedge clk) begin
    if (~resetn)
        start_pooling_count <= 0;
    else if (start_pooling)
        start_pooling_count <= start_pooling_count + 1;
end

reg buffer_select_accum;
wire buffer_select_pool;
reg start_pooling_d1;

always @ (posedge clk) begin
	if (buffer_select_pool)
		buffer_select_accum <= 0;
	else
		buffer_select_accum <= 1;
end

always @ (posedge clk) begin
	start_pooling_d1 <= start_pooling;
end

assign buffer_select_pool = start_pooling | start_pooling_d1;

always @ (posedge clk) begin
    % for i in range(1,mat_mul_size):
    add_accum_mux${i} <= add_accum_mux${i-1};
    % endfor
end
  
reg [7:0] waddr_kdim;
  
always @ (posedge clk) begin
    if (~resetn) 
        waddr_accum0 <= start_waddr_accum0;
    else if (((addr_counter & (`MAT_MUL_SIZE-1)) == (`MAT_MUL_SIZE-1)) & (waddr_kdim > 1)) begin
        waddr_accum0 <= waddr_accum0 - (`MAT_MUL_SIZE -1);
    end
    else if (wdata_available) 
        waddr_accum0 <= waddr_accum0 + 1;
end
  
always @ (posedge clk) begin
    if (~resetn | (((addr_counter & (`MAT_MUL_SIZE-1)) == (`MAT_MUL_SIZE-1)) & (waddr_kdim == 1))) begin
        waddr_kdim <= k_dimension >> `LOG2_MAT_MUL_SIZE;
    end
    else if (((addr_counter & (`MAT_MUL_SIZE-1)) == (`MAT_MUL_SIZE-1)) & (waddr_kdim > 1)) begin
        waddr_kdim <= waddr_kdim - 1;
    end
end
  
always @ (posedge clk) begin
    % for i in range(1,mat_mul_size):
    waddr_accum${i} <= waddr_accum${i-1};
    % endfor
end
   
// Data going into the Accumulator Adders
% for i in range(mat_mul_size):
wire [`DWIDTH-1:0] wdata_accum${i}_in;
% endfor

// Data written into the PING Accumulators
% for i in range(mat_mul_size):
wire [`DWIDTH-1:0] wdata_accum${i}_ping;
% endfor

% for i in range(mat_mul_size):
wire [`AWIDTH-1:0] raddr_buffer${i};
% endfor

% for i in range(mat_mul_size):
wire [`DWIDTH-1:0] rdata_buffer${i};
% endfor

% for i in range(mat_mul_size):
wire [`DWIDTH-1:0] rdata_buffer${i}_pong;
% endfor
    
// Based on the Accumulator Adder MUX select signal either 0 or data read from the RAM goes into the Adder
% for i in range(mat_mul_size):
assign wdata_accum${i}_in = (~add_accum_mux${i})?  8'b0 : (buffer_select)? rdata_buffer${i} : rdata_buffer${i}_pong;
% endfor
  
% for i in range(mat_mul_size):
reg [`AWIDTH-1:0] raddr_accum${i};
% endfor
  
// Start reading the address written to after ${mat_mul_size-1} clock cycles to calculate partial sums
always @ (posedge clk) begin
    raddr_accum0 <= waddr_accum${mat_mul_size-2}; // waddr_accum${mat_mul_size-2} = (waddr_accum0 delayed by ${mat_mul_size-2} clock cycles)
    % for i in range(1,mat_mul_size):
    raddr_accum${i} <= raddr_accum${i-1};
    % endfor
end
  
// Port 0 for each RAM is used for writing the data coming from the matmul as of now, not used for reading
% for i in range(mat_mul_size):
wire [`DWIDTH-1:0] accum${i}_ping_q0_NC;
% endfor
% for i in range(mat_mul_size):
wire [`DWIDTH-1:0] accum${i}_pong_q0_NC;
% endfor

% for i in range(1,mat_mul_size):  
reg buffer_select_pool${i};
% endfor
  
always @ (posedge clk) begin
buffer_select_pool1 <= buffer_select_pool;
% for i in range(2,mat_mul_size):
buffer_select_pool${i} <= buffer_select_pool${i-1};
% endfor
end

% for i in range(1,mat_mul_size):  
reg buffer_select_accum${i};
% endfor
  
always @ (posedge clk) begin
buffer_select_accum1 <= buffer_select_accum;
% for i in range(2,mat_mul_size):
buffer_select_accum${i} <= buffer_select_accum${i-1};
% endfor
end

assign raddr_buffer0 = (buffer_select_pool)? raddr_accum0_pool : (buffer_select_accum)? raddr_accum0:11'bx;
% for i in range(1,mat_mul_size):
assign raddr_buffer${i} = (buffer_select_pool${i})? raddr_accum${i}_pool : (buffer_select_accum${i})? raddr_accum${i}:11'bx;
% endfor
  
assign rdata_accum0_pool =  (buffer_select_pool)?  (buffer_select)? rdata_buffer0 : rdata_buffer0_pong : 8'b0;
% for i in range(1,mat_mul_size):
assign rdata_accum${i}_pool =  (buffer_select_pool${i})? (buffer_select)? rdata_buffer${i} : rdata_buffer${i}_pong : 8'b0;
% endfor  
  
////////////////////////////////////////////////
// PING ACCUMULATORS
////////////////////////////////////////////////

% for i in range(mat_mul_size): 
qadd adder_accum_ping${i} (wdata_accum${i}, wdata_accum${i}_in, wdata_accum${i}_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum${i}_ping (
    .addr0(waddr_accum${i}),
    .d0(wdata_accum${i}_ping), 
    .we0(wdata_en_ping${i}), 
    .q0(accum${i}_ping_q0_NC),
    .addr1(raddr_buffer${i}),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer${i}), 
    .clk(clk)
);

% endfor
% for i in range(mat_mul_size): 
wire [`DWIDTH-1:0] wdata_accum${i}_pong;
% endfor

////////////////////////////////////////////////
// PONG ACCUMULATORS
////////////////////////////////////////////////

% for i in range(mat_mul_size): 
qadd adder_accum_pong${i} (wdata_accum${i}, wdata_accum${i}_in, wdata_accum${i}_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum${i}_pong (
    .addr0(waddr_accum${i}),
    .d0(wdata_accum${i}_pong), 
    .we0(wdata_en_pong${i}), 
    .q0(accum${i}_pong_q0_NC),
    .addr1(raddr_buffer${i}),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer${i}_pong), 
    .clk(clk)
);

% endfor
endmodule

