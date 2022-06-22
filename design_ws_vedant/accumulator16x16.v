
module accumulator (
    clk,
    resetn,
    start_waddr_accum0,
    start_waddr_accum1,
    start_waddr_accum2,
    start_waddr_accum3,
    start_waddr_accum4,
    start_waddr_accum5,
    start_waddr_accum6,
    start_waddr_accum7,
    start_waddr_accum8,
    start_waddr_accum9,
    start_waddr_accum10,
    start_waddr_accum11,
    start_waddr_accum12,
    start_waddr_accum13,
    start_waddr_accum14,
    start_waddr_accum15,
    wdata_accum0,
    wdata_accum1,
    wdata_accum2,
    wdata_accum3,
    wdata_accum4,
    wdata_accum5,
    wdata_accum6,
    wdata_accum7,
    wdata_accum8,
    wdata_accum9,
    wdata_accum10,
    wdata_accum11,
    wdata_accum12,
    wdata_accum13,
    wdata_accum14,
    wdata_accum15,
    raddr_accum0_matmul,
    raddr_accum1_matmul,
    raddr_accum2_matmul,
    raddr_accum3_matmul,
    raddr_accum4_matmul,
    raddr_accum5_matmul,
    raddr_accum6_matmul,
    raddr_accum7_matmul,
    raddr_accum8_matmul,
    raddr_accum9_matmul,
    raddr_accum10_matmul,
    raddr_accum11_matmul,
    raddr_accum12_matmul,
    raddr_accum13_matmul,
    raddr_accum14_matmul,
    raddr_accum15_matmul,
    raddr_accum0_pool,
    raddr_accum1_pool,
    raddr_accum2_pool,
    raddr_accum3_pool,
    raddr_accum4_pool,
    raddr_accum5_pool,
    raddr_accum6_pool,
    raddr_accum7_pool,
    raddr_accum8_pool,
    raddr_accum9_pool,
    raddr_accum10_pool,
    raddr_accum11_pool,
    raddr_accum12_pool,
    raddr_accum13_pool,
    raddr_accum14_pool,
    raddr_accum15_pool,
    rdata_accum0,
    rdata_accum1,
    rdata_accum2,
    rdata_accum3,
    rdata_accum4,
    rdata_accum5,
    rdata_accum6,
    rdata_accum7,
    rdata_accum8,
    rdata_accum9,
    rdata_accum10,
    rdata_accum11,
    rdata_accum12,
    rdata_accum13,
    rdata_accum14,
    rdata_accum15,
    rdata_accum0_pool,
    rdata_accum1_pool,
    rdata_accum2_pool,
    rdata_accum3_pool,
    rdata_accum4_pool,
    rdata_accum5_pool,
    rdata_accum6_pool,
    rdata_accum7_pool,
    rdata_accum8_pool,
    rdata_accum9_pool,
    rdata_accum10_pool,
    rdata_accum11_pool,
    rdata_accum12_pool,
    rdata_accum13_pool,
    rdata_accum14_pool,
    rdata_accum15_pool,
    wdata_available,
    k_dimension,
    buffer_select,
    start_pooling,
    done_pooling
);

input clk;
input resetn;
input [`AWIDTH-1:0] start_waddr_accum0;
input [`AWIDTH-1:0] start_waddr_accum1;
input [`AWIDTH-1:0] start_waddr_accum2;
input [`AWIDTH-1:0] start_waddr_accum3;
input [`AWIDTH-1:0] start_waddr_accum4;
input [`AWIDTH-1:0] start_waddr_accum5;
input [`AWIDTH-1:0] start_waddr_accum6;
input [`AWIDTH-1:0] start_waddr_accum7;
input [`AWIDTH-1:0] start_waddr_accum8;
input [`AWIDTH-1:0] start_waddr_accum9;
input [`AWIDTH-1:0] start_waddr_accum10;
input [`AWIDTH-1:0] start_waddr_accum11;
input [`AWIDTH-1:0] start_waddr_accum12;
input [`AWIDTH-1:0] start_waddr_accum13;
input [`AWIDTH-1:0] start_waddr_accum14;
input [`AWIDTH-1:0] start_waddr_accum15;
input [`DWIDTH-1:0] wdata_accum0;
input [`DWIDTH-1:0] wdata_accum1;
input [`DWIDTH-1:0] wdata_accum2;
input [`DWIDTH-1:0] wdata_accum3;
input [`DWIDTH-1:0] wdata_accum4;
input [`DWIDTH-1:0] wdata_accum5;
input [`DWIDTH-1:0] wdata_accum6;
input [`DWIDTH-1:0] wdata_accum7;
input [`DWIDTH-1:0] wdata_accum8;
input [`DWIDTH-1:0] wdata_accum9;
input [`DWIDTH-1:0] wdata_accum10;
input [`DWIDTH-1:0] wdata_accum11;
input [`DWIDTH-1:0] wdata_accum12;
input [`DWIDTH-1:0] wdata_accum13;
input [`DWIDTH-1:0] wdata_accum14;
input [`DWIDTH-1:0] wdata_accum15;
input [`AWIDTH-1:0] raddr_accum0_matmul;
input [`AWIDTH-1:0] raddr_accum1_matmul;
input [`AWIDTH-1:0] raddr_accum2_matmul;
input [`AWIDTH-1:0] raddr_accum3_matmul;
input [`AWIDTH-1:0] raddr_accum4_matmul;
input [`AWIDTH-1:0] raddr_accum5_matmul;
input [`AWIDTH-1:0] raddr_accum6_matmul;
input [`AWIDTH-1:0] raddr_accum7_matmul;
input [`AWIDTH-1:0] raddr_accum8_matmul;
input [`AWIDTH-1:0] raddr_accum9_matmul;
input [`AWIDTH-1:0] raddr_accum10_matmul;
input [`AWIDTH-1:0] raddr_accum11_matmul;
input [`AWIDTH-1:0] raddr_accum12_matmul;
input [`AWIDTH-1:0] raddr_accum13_matmul;
input [`AWIDTH-1:0] raddr_accum14_matmul;
input [`AWIDTH-1:0] raddr_accum15_matmul;
input [`AWIDTH-1:0] raddr_accum0_pool;
input [`AWIDTH-1:0] raddr_accum1_pool;
input [`AWIDTH-1:0] raddr_accum2_pool;
input [`AWIDTH-1:0] raddr_accum3_pool;
input [`AWIDTH-1:0] raddr_accum4_pool;
input [`AWIDTH-1:0] raddr_accum5_pool;
input [`AWIDTH-1:0] raddr_accum6_pool;
input [`AWIDTH-1:0] raddr_accum7_pool;
input [`AWIDTH-1:0] raddr_accum8_pool;
input [`AWIDTH-1:0] raddr_accum9_pool;
input [`AWIDTH-1:0] raddr_accum10_pool;
input [`AWIDTH-1:0] raddr_accum11_pool;
input [`AWIDTH-1:0] raddr_accum12_pool;
input [`AWIDTH-1:0] raddr_accum13_pool;
input [`AWIDTH-1:0] raddr_accum14_pool;
input [`AWIDTH-1:0] raddr_accum15_pool;
output [`DWIDTH-1:0] rdata_accum0;
output [`DWIDTH-1:0] rdata_accum1;
output [`DWIDTH-1:0] rdata_accum2;
output [`DWIDTH-1:0] rdata_accum3;
output [`DWIDTH-1:0] rdata_accum4;
output [`DWIDTH-1:0] rdata_accum5;
output [`DWIDTH-1:0] rdata_accum6;
output [`DWIDTH-1:0] rdata_accum7;
output [`DWIDTH-1:0] rdata_accum8;
output [`DWIDTH-1:0] rdata_accum9;
output [`DWIDTH-1:0] rdata_accum10;
output [`DWIDTH-1:0] rdata_accum11;
output [`DWIDTH-1:0] rdata_accum12;
output [`DWIDTH-1:0] rdata_accum13;
output [`DWIDTH-1:0] rdata_accum14;
output [`DWIDTH-1:0] rdata_accum15;
output [`DWIDTH-1:0] rdata_accum0_pool;
output [`DWIDTH-1:0] rdata_accum1_pool;
output [`DWIDTH-1:0] rdata_accum2_pool;
output [`DWIDTH-1:0] rdata_accum3_pool;
output [`DWIDTH-1:0] rdata_accum4_pool;
output [`DWIDTH-1:0] rdata_accum5_pool;
output [`DWIDTH-1:0] rdata_accum6_pool;
output [`DWIDTH-1:0] rdata_accum7_pool;
output [`DWIDTH-1:0] rdata_accum8_pool;
output [`DWIDTH-1:0] rdata_accum9_pool;
output [`DWIDTH-1:0] rdata_accum10_pool;
output [`DWIDTH-1:0] rdata_accum11_pool;
output [`DWIDTH-1:0] rdata_accum12_pool;
output [`DWIDTH-1:0] rdata_accum13_pool;
output [`DWIDTH-1:0] rdata_accum14_pool;
output [`DWIDTH-1:0] rdata_accum15_pool;
input wdata_available;
input [7:0] k_dimension; // Number of columns in Matrix A | Number of rows in Matrix B (Assumption: Maximum = 256, can be changed accordingly)
input buffer_select;
output start_pooling;
output done_pooling;
  

parameter MWIDTH = 1;

reg wdata_available1;
reg wdata_available2;
reg wdata_available3;
reg wdata_available4;
reg wdata_available5;
reg wdata_available6;
reg wdata_available7;
reg wdata_available8;
reg wdata_available9;
reg wdata_available10;
reg wdata_available11;
reg wdata_available12;
reg wdata_available13;
reg wdata_available14;
reg wdata_available15;

always @ (posedge clk) begin
    wdata_available1 <= wdata_available;
    wdata_available2 <= wdata_available1;
    wdata_available3 <= wdata_available2;
    wdata_available4 <= wdata_available3;
    wdata_available5 <= wdata_available4;
    wdata_available6 <= wdata_available5;
    wdata_available7 <= wdata_available6;
    wdata_available8 <= wdata_available7;
    wdata_available9 <= wdata_available8;
    wdata_available10 <= wdata_available9;
    wdata_available11 <= wdata_available10;
    wdata_available12 <= wdata_available11;
    wdata_available13 <= wdata_available12;
    wdata_available14 <= wdata_available13;
    wdata_available15 <= wdata_available14;
end

wire wdata_en_ping0;
wire wdata_en_ping1;
wire wdata_en_ping2;
wire wdata_en_ping3;
wire wdata_en_ping4;
wire wdata_en_ping5;
wire wdata_en_ping6;
wire wdata_en_ping7;
wire wdata_en_ping8;
wire wdata_en_ping9;
wire wdata_en_ping10;
wire wdata_en_ping11;
wire wdata_en_ping12;
wire wdata_en_ping13;
wire wdata_en_ping14;
wire wdata_en_ping15;
wire wdata_en_pong0;
wire wdata_en_pong1;
wire wdata_en_pong2;
wire wdata_en_pong3;
wire wdata_en_pong4;
wire wdata_en_pong5;
wire wdata_en_pong6;
wire wdata_en_pong7;
wire wdata_en_pong8;
wire wdata_en_pong9;
wire wdata_en_pong10;
wire wdata_en_pong11;
wire wdata_en_pong12;
wire wdata_en_pong13;
wire wdata_en_pong14;
wire wdata_en_pong15;

assign wdata_en_ping0 = wdata_available & buffer_select;
assign wdata_en_ping1 = wdata_available1 & buffer_select;
assign wdata_en_ping2 = wdata_available2 & buffer_select;
assign wdata_en_ping3 = wdata_available3 & buffer_select;
assign wdata_en_ping4 = wdata_available4 & buffer_select;
assign wdata_en_ping5 = wdata_available5 & buffer_select;
assign wdata_en_ping6 = wdata_available6 & buffer_select;
assign wdata_en_ping7 = wdata_available7 & buffer_select;
assign wdata_en_ping8 = wdata_available8 & buffer_select;
assign wdata_en_ping9 = wdata_available9 & buffer_select;
assign wdata_en_ping10 = wdata_available10 & buffer_select;
assign wdata_en_ping11 = wdata_available11 & buffer_select;
assign wdata_en_ping12 = wdata_available12 & buffer_select;
assign wdata_en_ping13 = wdata_available13 & buffer_select;
assign wdata_en_ping14 = wdata_available14 & buffer_select;
assign wdata_en_ping15 = wdata_available15 & buffer_select;

assign wdata_en_pong0 = wdata_available & ~buffer_select;
assign wdata_en_pong1 = wdata_available1 & ~buffer_select;
assign wdata_en_pong2 = wdata_available2 & ~buffer_select;
assign wdata_en_pong3 = wdata_available3 & ~buffer_select;
assign wdata_en_pong4 = wdata_available4 & ~buffer_select;
assign wdata_en_pong5 = wdata_available5 & ~buffer_select;
assign wdata_en_pong6 = wdata_available6 & ~buffer_select;
assign wdata_en_pong7 = wdata_available7 & ~buffer_select;
assign wdata_en_pong8 = wdata_available8 & ~buffer_select;
assign wdata_en_pong9 = wdata_available9 & ~buffer_select;
assign wdata_en_pong10 = wdata_available10 & ~buffer_select;
assign wdata_en_pong11 = wdata_available11 & ~buffer_select;
assign wdata_en_pong12 = wdata_available12 & ~buffer_select;
assign wdata_en_pong13 = wdata_available13 & ~buffer_select;
assign wdata_en_pong14 = wdata_available14 & ~buffer_select;
assign wdata_en_pong15 = wdata_available15 & ~buffer_select;

reg [7:0] addr_counter;
reg [`AWIDTH-1:0] waddr_accum0;
reg [`AWIDTH-1:0] waddr_accum1;
reg [`AWIDTH-1:0] waddr_accum2;
reg [`AWIDTH-1:0] waddr_accum3;
reg [`AWIDTH-1:0] waddr_accum4;
reg [`AWIDTH-1:0] waddr_accum5;
reg [`AWIDTH-1:0] waddr_accum6;
reg [`AWIDTH-1:0] waddr_accum7;
reg [`AWIDTH-1:0] waddr_accum8;
reg [`AWIDTH-1:0] waddr_accum9;
reg [`AWIDTH-1:0] waddr_accum10;
reg [`AWIDTH-1:0] waddr_accum11;
reg [`AWIDTH-1:0] waddr_accum12;
reg [`AWIDTH-1:0] waddr_accum13;
reg [`AWIDTH-1:0] waddr_accum14;
reg [`AWIDTH-1:0] waddr_accum15;
reg add_accum_mux0;
reg add_accum_mux1;
reg add_accum_mux2;
reg add_accum_mux3;
reg add_accum_mux4;
reg add_accum_mux5;
reg add_accum_mux6;
reg add_accum_mux7;
reg add_accum_mux8;
reg add_accum_mux9;
reg add_accum_mux10;
reg add_accum_mux11;
reg add_accum_mux12;
reg add_accum_mux13;
reg add_accum_mux14;
reg add_accum_mux15;

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
    add_accum_mux1 <= add_accum_mux0;
    add_accum_mux2 <= add_accum_mux1;
    add_accum_mux3 <= add_accum_mux2;
    add_accum_mux4 <= add_accum_mux3;
    add_accum_mux5 <= add_accum_mux4;
    add_accum_mux6 <= add_accum_mux5;
    add_accum_mux7 <= add_accum_mux6;
    add_accum_mux8 <= add_accum_mux7;
    add_accum_mux9 <= add_accum_mux8;
    add_accum_mux10 <= add_accum_mux9;
    add_accum_mux11 <= add_accum_mux10;
    add_accum_mux12 <= add_accum_mux11;
    add_accum_mux13 <= add_accum_mux12;
    add_accum_mux14 <= add_accum_mux13;
    add_accum_mux15 <= add_accum_mux14;
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
    waddr_accum1 <= waddr_accum0;
    waddr_accum2 <= waddr_accum1;
    waddr_accum3 <= waddr_accum2;
    waddr_accum4 <= waddr_accum3;
    waddr_accum5 <= waddr_accum4;
    waddr_accum6 <= waddr_accum5;
    waddr_accum7 <= waddr_accum6;
    waddr_accum8 <= waddr_accum7;
    waddr_accum9 <= waddr_accum8;
    waddr_accum10 <= waddr_accum9;
    waddr_accum11 <= waddr_accum10;
    waddr_accum12 <= waddr_accum11;
    waddr_accum13 <= waddr_accum12;
    waddr_accum14 <= waddr_accum13;
    waddr_accum15 <= waddr_accum14;
end
   
// Data going into the Accumulator Adders
wire [`DWIDTH-1:0] wdata_accum0_in;
wire [`DWIDTH-1:0] wdata_accum1_in;
wire [`DWIDTH-1:0] wdata_accum2_in;
wire [`DWIDTH-1:0] wdata_accum3_in;
wire [`DWIDTH-1:0] wdata_accum4_in;
wire [`DWIDTH-1:0] wdata_accum5_in;
wire [`DWIDTH-1:0] wdata_accum6_in;
wire [`DWIDTH-1:0] wdata_accum7_in;
wire [`DWIDTH-1:0] wdata_accum8_in;
wire [`DWIDTH-1:0] wdata_accum9_in;
wire [`DWIDTH-1:0] wdata_accum10_in;
wire [`DWIDTH-1:0] wdata_accum11_in;
wire [`DWIDTH-1:0] wdata_accum12_in;
wire [`DWIDTH-1:0] wdata_accum13_in;
wire [`DWIDTH-1:0] wdata_accum14_in;
wire [`DWIDTH-1:0] wdata_accum15_in;

// Data written into the PING Accumulators
wire [`DWIDTH-1:0] wdata_accum0_ping;
wire [`DWIDTH-1:0] wdata_accum1_ping;
wire [`DWIDTH-1:0] wdata_accum2_ping;
wire [`DWIDTH-1:0] wdata_accum3_ping;
wire [`DWIDTH-1:0] wdata_accum4_ping;
wire [`DWIDTH-1:0] wdata_accum5_ping;
wire [`DWIDTH-1:0] wdata_accum6_ping;
wire [`DWIDTH-1:0] wdata_accum7_ping;
wire [`DWIDTH-1:0] wdata_accum8_ping;
wire [`DWIDTH-1:0] wdata_accum9_ping;
wire [`DWIDTH-1:0] wdata_accum10_ping;
wire [`DWIDTH-1:0] wdata_accum11_ping;
wire [`DWIDTH-1:0] wdata_accum12_ping;
wire [`DWIDTH-1:0] wdata_accum13_ping;
wire [`DWIDTH-1:0] wdata_accum14_ping;
wire [`DWIDTH-1:0] wdata_accum15_ping;
    
// Based on the Accumulator Adder MUX select signal either 0 or data read from the RAM goes into the Adder
assign wdata_accum0_in = (~add_accum_mux0)?  8'b0 : rdata_accum0;
assign wdata_accum1_in = (~add_accum_mux1)?  8'b0 : rdata_accum1;
assign wdata_accum2_in = (~add_accum_mux2)?  8'b0 : rdata_accum2;
assign wdata_accum3_in = (~add_accum_mux3)?  8'b0 : rdata_accum3;
assign wdata_accum4_in = (~add_accum_mux4)?  8'b0 : rdata_accum4;
assign wdata_accum5_in = (~add_accum_mux5)?  8'b0 : rdata_accum5;
assign wdata_accum6_in = (~add_accum_mux6)?  8'b0 : rdata_accum6;
assign wdata_accum7_in = (~add_accum_mux7)?  8'b0 : rdata_accum7;
assign wdata_accum8_in = (~add_accum_mux8)?  8'b0 : rdata_accum8;
assign wdata_accum9_in = (~add_accum_mux9)?  8'b0 : rdata_accum9;
assign wdata_accum10_in = (~add_accum_mux10)?  8'b0 : rdata_accum10;
assign wdata_accum11_in = (~add_accum_mux11)?  8'b0 : rdata_accum11;
assign wdata_accum12_in = (~add_accum_mux12)?  8'b0 : rdata_accum12;
assign wdata_accum13_in = (~add_accum_mux13)?  8'b0 : rdata_accum13;
assign wdata_accum14_in = (~add_accum_mux14)?  8'b0 : rdata_accum14;
assign wdata_accum15_in = (~add_accum_mux15)?  8'b0 : rdata_accum15;
  
reg [`AWIDTH-1:0] raddr_accum0;
reg [`AWIDTH-1:0] raddr_accum1;
reg [`AWIDTH-1:0] raddr_accum2;
reg [`AWIDTH-1:0] raddr_accum3;
reg [`AWIDTH-1:0] raddr_accum4;
reg [`AWIDTH-1:0] raddr_accum5;
reg [`AWIDTH-1:0] raddr_accum6;
reg [`AWIDTH-1:0] raddr_accum7;
reg [`AWIDTH-1:0] raddr_accum8;
reg [`AWIDTH-1:0] raddr_accum9;
reg [`AWIDTH-1:0] raddr_accum10;
reg [`AWIDTH-1:0] raddr_accum11;
reg [`AWIDTH-1:0] raddr_accum12;
reg [`AWIDTH-1:0] raddr_accum13;
reg [`AWIDTH-1:0] raddr_accum14;
reg [`AWIDTH-1:0] raddr_accum15;
  
// Start reading the address written to after 15 clock cycles to calculate partial sums
always @ (posedge clk) begin
    raddr_accum0 <= waddr_accum14; // waddr_accum14 = (waddr_accum0 delayed by 14 clock cycles)
    raddr_accum1 <= raddr_accum0;
    raddr_accum2 <= raddr_accum1;
    raddr_accum3 <= raddr_accum2;
    raddr_accum4 <= raddr_accum3;
    raddr_accum5 <= raddr_accum4;
    raddr_accum6 <= raddr_accum5;
    raddr_accum7 <= raddr_accum6;
    raddr_accum8 <= raddr_accum7;
    raddr_accum9 <= raddr_accum8;
    raddr_accum10 <= raddr_accum9;
    raddr_accum11 <= raddr_accum10;
    raddr_accum12 <= raddr_accum11;
    raddr_accum13 <= raddr_accum12;
    raddr_accum14 <= raddr_accum13;
    raddr_accum15 <= raddr_accum14;
end
  
// Port 0 for each RAM is used for writing the data coming from the matmul as of now, not used for reading
wire [`DWIDTH-1:0] accum0_ping_q0_NC;
wire [`DWIDTH-1:0] accum1_ping_q0_NC;
wire [`DWIDTH-1:0] accum2_ping_q0_NC;
wire [`DWIDTH-1:0] accum3_ping_q0_NC;
wire [`DWIDTH-1:0] accum4_ping_q0_NC;
wire [`DWIDTH-1:0] accum5_ping_q0_NC;
wire [`DWIDTH-1:0] accum6_ping_q0_NC;
wire [`DWIDTH-1:0] accum7_ping_q0_NC;
wire [`DWIDTH-1:0] accum8_ping_q0_NC;
wire [`DWIDTH-1:0] accum9_ping_q0_NC;
wire [`DWIDTH-1:0] accum10_ping_q0_NC;
wire [`DWIDTH-1:0] accum11_ping_q0_NC;
wire [`DWIDTH-1:0] accum12_ping_q0_NC;
wire [`DWIDTH-1:0] accum13_ping_q0_NC;
wire [`DWIDTH-1:0] accum14_ping_q0_NC;
wire [`DWIDTH-1:0] accum15_ping_q0_NC;
wire [`DWIDTH-1:0] accum0_pong_q0_NC;
wire [`DWIDTH-1:0] accum1_pong_q0_NC;
wire [`DWIDTH-1:0] accum2_pong_q0_NC;
wire [`DWIDTH-1:0] accum3_pong_q0_NC;
wire [`DWIDTH-1:0] accum4_pong_q0_NC;
wire [`DWIDTH-1:0] accum5_pong_q0_NC;
wire [`DWIDTH-1:0] accum6_pong_q0_NC;
wire [`DWIDTH-1:0] accum7_pong_q0_NC;
wire [`DWIDTH-1:0] accum8_pong_q0_NC;
wire [`DWIDTH-1:0] accum9_pong_q0_NC;
wire [`DWIDTH-1:0] accum10_pong_q0_NC;
wire [`DWIDTH-1:0] accum11_pong_q0_NC;
wire [`DWIDTH-1:0] accum12_pong_q0_NC;
wire [`DWIDTH-1:0] accum13_pong_q0_NC;
wire [`DWIDTH-1:0] accum14_pong_q0_NC;
wire [`DWIDTH-1:0] accum15_pong_q0_NC;

wire [`AWIDTH-1:0] raddr_buffer0;
wire [`AWIDTH-1:0] raddr_buffer1;
wire [`AWIDTH-1:0] raddr_buffer2;
wire [`AWIDTH-1:0] raddr_buffer3;
wire [`AWIDTH-1:0] raddr_buffer4;
wire [`AWIDTH-1:0] raddr_buffer5;
wire [`AWIDTH-1:0] raddr_buffer6;
wire [`AWIDTH-1:0] raddr_buffer7;
wire [`AWIDTH-1:0] raddr_buffer8;
wire [`AWIDTH-1:0] raddr_buffer9;
wire [`AWIDTH-1:0] raddr_buffer10;
wire [`AWIDTH-1:0] raddr_buffer11;
wire [`AWIDTH-1:0] raddr_buffer12;
wire [`AWIDTH-1:0] raddr_buffer13;
wire [`AWIDTH-1:0] raddr_buffer14;
wire [`AWIDTH-1:0] raddr_buffer15;

wire [`DWIDTH-1:0] rdata_buffer0;
wire [`DWIDTH-1:0] rdata_buffer1;
wire [`DWIDTH-1:0] rdata_buffer2;
wire [`DWIDTH-1:0] rdata_buffer3;
wire [`DWIDTH-1:0] rdata_buffer4;
wire [`DWIDTH-1:0] rdata_buffer5;
wire [`DWIDTH-1:0] rdata_buffer6;
wire [`DWIDTH-1:0] rdata_buffer7;
wire [`DWIDTH-1:0] rdata_buffer8;
wire [`DWIDTH-1:0] rdata_buffer9;
wire [`DWIDTH-1:0] rdata_buffer10;
wire [`DWIDTH-1:0] rdata_buffer11;
wire [`DWIDTH-1:0] rdata_buffer12;
wire [`DWIDTH-1:0] rdata_buffer13;
wire [`DWIDTH-1:0] rdata_buffer14;
wire [`DWIDTH-1:0] rdata_buffer15;

reg buffer_select_pool1;
reg buffer_select_pool2;
reg buffer_select_pool3;
reg buffer_select_pool4;
reg buffer_select_pool5;
reg buffer_select_pool6;
reg buffer_select_pool7;
reg buffer_select_pool8;
reg buffer_select_pool9;
reg buffer_select_pool10;
reg buffer_select_pool11;
reg buffer_select_pool12;
reg buffer_select_pool13;
reg buffer_select_pool14;
reg buffer_select_pool15;
  
always @ (posedge clk) begin
buffer_select_pool1 <= buffer_select_pool;
buffer_select_pool2 <= buffer_select_pool1;
buffer_select_pool3 <= buffer_select_pool2;
buffer_select_pool4 <= buffer_select_pool3;
buffer_select_pool5 <= buffer_select_pool4;
buffer_select_pool6 <= buffer_select_pool5;
buffer_select_pool7 <= buffer_select_pool6;
buffer_select_pool8 <= buffer_select_pool7;
buffer_select_pool9 <= buffer_select_pool8;
buffer_select_pool10 <= buffer_select_pool9;
buffer_select_pool11 <= buffer_select_pool10;
buffer_select_pool12 <= buffer_select_pool11;
buffer_select_pool13 <= buffer_select_pool12;
buffer_select_pool14 <= buffer_select_pool13;
buffer_select_pool15 <= buffer_select_pool14;
end

reg buffer_select_accum1;
reg buffer_select_accum2;
reg buffer_select_accum3;
reg buffer_select_accum4;
reg buffer_select_accum5;
reg buffer_select_accum6;
reg buffer_select_accum7;
reg buffer_select_accum8;
reg buffer_select_accum9;
reg buffer_select_accum10;
reg buffer_select_accum11;
reg buffer_select_accum12;
reg buffer_select_accum13;
reg buffer_select_accum14;
reg buffer_select_accum15;
  
always @ (posedge clk) begin
buffer_select_accum1 <= buffer_select_accum;
buffer_select_accum2 <= buffer_select_accum1;
buffer_select_accum3 <= buffer_select_accum2;
buffer_select_accum4 <= buffer_select_accum3;
buffer_select_accum5 <= buffer_select_accum4;
buffer_select_accum6 <= buffer_select_accum5;
buffer_select_accum7 <= buffer_select_accum6;
buffer_select_accum8 <= buffer_select_accum7;
buffer_select_accum9 <= buffer_select_accum8;
buffer_select_accum10 <= buffer_select_accum9;
buffer_select_accum11 <= buffer_select_accum10;
buffer_select_accum12 <= buffer_select_accum11;
buffer_select_accum13 <= buffer_select_accum12;
buffer_select_accum14 <= buffer_select_accum13;
buffer_select_accum15 <= buffer_select_accum14;
end

assign raddr_buffer0 = (buffer_select_pool)? raddr_accum0_pool : (buffer_select_accum)? raddr_accum0 : 11'bx;
assign raddr_buffer1 = (buffer_select_pool1)? raddr_accum1_pool : (buffer_select_accum1)? raddr_accum1 : 11'bx;
assign raddr_buffer2 = (buffer_select_pool2)? raddr_accum2_pool : (buffer_select_accum2)? raddr_accum2 : 11'bx;
assign raddr_buffer3 = (buffer_select_pool3)? raddr_accum3_pool : (buffer_select_accum3)? raddr_accum3 : 11'bx;
assign raddr_buffer4 = (buffer_select_pool4)? raddr_accum4_pool : (buffer_select_accum4)? raddr_accum4 : 11'bx;
assign raddr_buffer5 = (buffer_select_pool5)? raddr_accum5_pool : (buffer_select_accum5)? raddr_accum5 : 11'bx;
assign raddr_buffer6 = (buffer_select_pool6)? raddr_accum6_pool : (buffer_select_accum6)? raddr_accum6 : 11'bx;
assign raddr_buffer7 = (buffer_select_pool7)? raddr_accum7_pool : (buffer_select_accum7)? raddr_accum7 : 11'bx;
assign raddr_buffer8 = (buffer_select_pool8)? raddr_accum8_pool : (buffer_select_accum8)? raddr_accum8 : 11'bx;
assign raddr_buffer9 = (buffer_select_pool9)? raddr_accum9_pool : (buffer_select_accum9)? raddr_accum9 : 11'bx;
assign raddr_buffer10 = (buffer_select_pool10)? raddr_accum10_pool : (buffer_select_accum10)? raddr_accum10 : 11'bx;
assign raddr_buffer11 = (buffer_select_pool11)? raddr_accum11_pool : (buffer_select_accum11)? raddr_accum11 : 11'bx;
assign raddr_buffer12 = (buffer_select_pool12)? raddr_accum12_pool : (buffer_select_accum12)? raddr_accum12 : 11'bx;
assign raddr_buffer13 = (buffer_select_pool13)? raddr_accum13_pool : (buffer_select_accum13)? raddr_accum13 : 11'bx;
assign raddr_buffer14 = (buffer_select_pool14)? raddr_accum14_pool : (buffer_select_accum14)? raddr_accum14 : 11'bx;
assign raddr_buffer15 = (buffer_select_pool15)? raddr_accum15_pool : (buffer_select_accum15)? raddr_accum15 : 11'bx;
  
assign rdata_accum0_pool =  (buffer_select_pool)? rdata_buffer0 : 8'b0;
assign rdata_accum1_pool =  (buffer_select_pool1)? rdata_buffer1 : 8'b0;
assign rdata_accum2_pool =  (buffer_select_pool2)? rdata_buffer2 : 8'b0;
assign rdata_accum3_pool =  (buffer_select_pool3)? rdata_buffer3 : 8'b0;
assign rdata_accum4_pool =  (buffer_select_pool4)? rdata_buffer4 : 8'b0;
assign rdata_accum5_pool =  (buffer_select_pool5)? rdata_buffer5 : 8'b0;
assign rdata_accum6_pool =  (buffer_select_pool6)? rdata_buffer6 : 8'b0;
assign rdata_accum7_pool =  (buffer_select_pool7)? rdata_buffer7 : 8'b0;
assign rdata_accum8_pool =  (buffer_select_pool8)? rdata_buffer8 : 8'b0;
assign rdata_accum9_pool =  (buffer_select_pool9)? rdata_buffer9 : 8'b0;
assign rdata_accum10_pool =  (buffer_select_pool10)? rdata_buffer10 : 8'b0;
assign rdata_accum11_pool =  (buffer_select_pool11)? rdata_buffer11 : 8'b0;
assign rdata_accum12_pool =  (buffer_select_pool12)? rdata_buffer12 : 8'b0;
assign rdata_accum13_pool =  (buffer_select_pool13)? rdata_buffer13 : 8'b0;
assign rdata_accum14_pool =  (buffer_select_pool14)? rdata_buffer14 : 8'b0;
assign rdata_accum15_pool =  (buffer_select_pool15)? rdata_buffer15 : 8'b0;
  
////////////////////////////////////////////////
// PING ACCUMULATORS
////////////////////////////////////////////////

qadd adder_accum_ping0 (wdata_accum0, wdata_accum0_in, wdata_accum0_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum0_ping (
    .addr0(waddr_accum0),
    .d0(wdata_accum0_ping), 
    .we0(wdata_en_ping0), 
    .q0(accum0_ping_q0_NC),
    .addr1(raddr_buffer0),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer0), 
    .clk(clk)
);

qadd adder_accum_ping1 (wdata_accum1, wdata_accum1_in, wdata_accum1_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum1_ping (
    .addr0(waddr_accum1),
    .d0(wdata_accum1_ping), 
    .we0(wdata_en_ping1), 
    .q0(accum1_ping_q0_NC),
    .addr1(raddr_buffer1),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer1), 
    .clk(clk)
);

qadd adder_accum_ping2 (wdata_accum2, wdata_accum2_in, wdata_accum2_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum2_ping (
    .addr0(waddr_accum2),
    .d0(wdata_accum2_ping), 
    .we0(wdata_en_ping2), 
    .q0(accum2_ping_q0_NC),
    .addr1(raddr_buffer2),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer2), 
    .clk(clk)
);

qadd adder_accum_ping3 (wdata_accum3, wdata_accum3_in, wdata_accum3_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum3_ping (
    .addr0(waddr_accum3),
    .d0(wdata_accum3_ping), 
    .we0(wdata_en_ping3), 
    .q0(accum3_ping_q0_NC),
    .addr1(raddr_buffer3),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer3), 
    .clk(clk)
);

qadd adder_accum_ping4 (wdata_accum4, wdata_accum4_in, wdata_accum4_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum4_ping (
    .addr0(waddr_accum4),
    .d0(wdata_accum4_ping), 
    .we0(wdata_en_ping4), 
    .q0(accum4_ping_q0_NC),
    .addr1(raddr_buffer4),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer4), 
    .clk(clk)
);

qadd adder_accum_ping5 (wdata_accum5, wdata_accum5_in, wdata_accum5_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum5_ping (
    .addr0(waddr_accum5),
    .d0(wdata_accum5_ping), 
    .we0(wdata_en_ping5), 
    .q0(accum5_ping_q0_NC),
    .addr1(raddr_buffer5),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer5), 
    .clk(clk)
);

qadd adder_accum_ping6 (wdata_accum6, wdata_accum6_in, wdata_accum6_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum6_ping (
    .addr0(waddr_accum6),
    .d0(wdata_accum6_ping), 
    .we0(wdata_en_ping6), 
    .q0(accum6_ping_q0_NC),
    .addr1(raddr_buffer6),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer6), 
    .clk(clk)
);

qadd adder_accum_ping7 (wdata_accum7, wdata_accum7_in, wdata_accum7_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum7_ping (
    .addr0(waddr_accum7),
    .d0(wdata_accum7_ping), 
    .we0(wdata_en_ping7), 
    .q0(accum7_ping_q0_NC),
    .addr1(raddr_buffer7),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer7), 
    .clk(clk)
);

qadd adder_accum_ping8 (wdata_accum8, wdata_accum8_in, wdata_accum8_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum8_ping (
    .addr0(waddr_accum8),
    .d0(wdata_accum8_ping), 
    .we0(wdata_en_ping8), 
    .q0(accum8_ping_q0_NC),
    .addr1(raddr_buffer8),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer8), 
    .clk(clk)
);

qadd adder_accum_ping9 (wdata_accum9, wdata_accum9_in, wdata_accum9_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum9_ping (
    .addr0(waddr_accum9),
    .d0(wdata_accum9_ping), 
    .we0(wdata_en_ping9), 
    .q0(accum9_ping_q0_NC),
    .addr1(raddr_buffer9),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer9), 
    .clk(clk)
);

qadd adder_accum_ping10 (wdata_accum10, wdata_accum10_in, wdata_accum10_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum10_ping (
    .addr0(waddr_accum10),
    .d0(wdata_accum10_ping), 
    .we0(wdata_en_ping10), 
    .q0(accum10_ping_q0_NC),
    .addr1(raddr_buffer10),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer10), 
    .clk(clk)
);

qadd adder_accum_ping11 (wdata_accum11, wdata_accum11_in, wdata_accum11_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum11_ping (
    .addr0(waddr_accum11),
    .d0(wdata_accum11_ping), 
    .we0(wdata_en_ping11), 
    .q0(accum11_ping_q0_NC),
    .addr1(raddr_buffer11),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer11), 
    .clk(clk)
);

qadd adder_accum_ping12 (wdata_accum12, wdata_accum12_in, wdata_accum12_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum12_ping (
    .addr0(waddr_accum12),
    .d0(wdata_accum12_ping), 
    .we0(wdata_en_ping12), 
    .q0(accum12_ping_q0_NC),
    .addr1(raddr_buffer12),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer12), 
    .clk(clk)
);

qadd adder_accum_ping13 (wdata_accum13, wdata_accum13_in, wdata_accum13_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum13_ping (
    .addr0(waddr_accum13),
    .d0(wdata_accum13_ping), 
    .we0(wdata_en_ping13), 
    .q0(accum13_ping_q0_NC),
    .addr1(raddr_buffer13),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer13), 
    .clk(clk)
);

qadd adder_accum_ping14 (wdata_accum14, wdata_accum14_in, wdata_accum14_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum14_ping (
    .addr0(waddr_accum14),
    .d0(wdata_accum14_ping), 
    .we0(wdata_en_ping14), 
    .q0(accum14_ping_q0_NC),
    .addr1(raddr_buffer14),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer14), 
    .clk(clk)
);

qadd adder_accum_ping15 (wdata_accum15, wdata_accum15_in, wdata_accum15_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum15_ping (
    .addr0(waddr_accum15),
    .d0(wdata_accum15_ping), 
    .we0(wdata_en_ping15), 
    .q0(accum15_ping_q0_NC),
    .addr1(raddr_buffer15),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer15), 
    .clk(clk)
);

wire [`AWIDTH-1:0] raddr_accum0_pong;
wire [`AWIDTH-1:0] raddr_accum1_pong;
wire [`AWIDTH-1:0] raddr_accum2_pong;
wire [`AWIDTH-1:0] raddr_accum3_pong;
wire [`AWIDTH-1:0] raddr_accum4_pong;
wire [`AWIDTH-1:0] raddr_accum5_pong;
wire [`AWIDTH-1:0] raddr_accum6_pong;
wire [`AWIDTH-1:0] raddr_accum7_pong;
wire [`AWIDTH-1:0] raddr_accum8_pong;
wire [`AWIDTH-1:0] raddr_accum9_pong;
wire [`AWIDTH-1:0] raddr_accum10_pong;
wire [`AWIDTH-1:0] raddr_accum11_pong;
wire [`AWIDTH-1:0] raddr_accum12_pong;
wire [`AWIDTH-1:0] raddr_accum13_pong;
wire [`AWIDTH-1:0] raddr_accum14_pong;
wire [`AWIDTH-1:0] raddr_accum15_pong;

wire [`DWIDTH-1:0] rdata_accum0_pong;
wire [`DWIDTH-1:0] rdata_accum1_pong;
wire [`DWIDTH-1:0] rdata_accum2_pong;
wire [`DWIDTH-1:0] rdata_accum3_pong;
wire [`DWIDTH-1:0] rdata_accum4_pong;
wire [`DWIDTH-1:0] rdata_accum5_pong;
wire [`DWIDTH-1:0] rdata_accum6_pong;
wire [`DWIDTH-1:0] rdata_accum7_pong;
wire [`DWIDTH-1:0] rdata_accum8_pong;
wire [`DWIDTH-1:0] rdata_accum9_pong;
wire [`DWIDTH-1:0] rdata_accum10_pong;
wire [`DWIDTH-1:0] rdata_accum11_pong;
wire [`DWIDTH-1:0] rdata_accum12_pong;
wire [`DWIDTH-1:0] rdata_accum13_pong;
wire [`DWIDTH-1:0] rdata_accum14_pong;
wire [`DWIDTH-1:0] rdata_accum15_pong;

wire [`DWIDTH-1:0] wdata_accum0_pong;
wire [`DWIDTH-1:0] wdata_accum1_pong;
wire [`DWIDTH-1:0] wdata_accum2_pong;
wire [`DWIDTH-1:0] wdata_accum3_pong;
wire [`DWIDTH-1:0] wdata_accum4_pong;
wire [`DWIDTH-1:0] wdata_accum5_pong;
wire [`DWIDTH-1:0] wdata_accum6_pong;
wire [`DWIDTH-1:0] wdata_accum7_pong;
wire [`DWIDTH-1:0] wdata_accum8_pong;
wire [`DWIDTH-1:0] wdata_accum9_pong;
wire [`DWIDTH-1:0] wdata_accum10_pong;
wire [`DWIDTH-1:0] wdata_accum11_pong;
wire [`DWIDTH-1:0] wdata_accum12_pong;
wire [`DWIDTH-1:0] wdata_accum13_pong;
wire [`DWIDTH-1:0] wdata_accum14_pong;
wire [`DWIDTH-1:0] wdata_accum15_pong;

////////////////////////////////////////////////
// PONG ACCUMULATORS
////////////////////////////////////////////////

qadd adder_accum_pong0 (wdata_accum0, wdata_accum0_in, wdata_accum0_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum0_pong (
    .addr0(waddr_accum0),
    .d0(wdata_accum0_pong), 
    .we0(wdata_en_pong0), 
    .q0(accum0_pong_q0_NC),
    .addr1(raddr_accum0_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum0_pong), 
    .clk(clk)
);

qadd adder_accum_pong1 (wdata_accum1, wdata_accum1_in, wdata_accum1_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum1_pong (
    .addr0(waddr_accum1),
    .d0(wdata_accum1_pong), 
    .we0(wdata_en_pong1), 
    .q0(accum1_pong_q0_NC),
    .addr1(raddr_accum1_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum1_pong), 
    .clk(clk)
);

qadd adder_accum_pong2 (wdata_accum2, wdata_accum2_in, wdata_accum2_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum2_pong (
    .addr0(waddr_accum2),
    .d0(wdata_accum2_pong), 
    .we0(wdata_en_pong2), 
    .q0(accum2_pong_q0_NC),
    .addr1(raddr_accum2_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum2_pong), 
    .clk(clk)
);

qadd adder_accum_pong3 (wdata_accum3, wdata_accum3_in, wdata_accum3_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum3_pong (
    .addr0(waddr_accum3),
    .d0(wdata_accum3_pong), 
    .we0(wdata_en_pong3), 
    .q0(accum3_pong_q0_NC),
    .addr1(raddr_accum3_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum3_pong), 
    .clk(clk)
);

qadd adder_accum_pong4 (wdata_accum4, wdata_accum4_in, wdata_accum4_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum4_pong (
    .addr0(waddr_accum4),
    .d0(wdata_accum4_pong), 
    .we0(wdata_en_pong4), 
    .q0(accum4_pong_q0_NC),
    .addr1(raddr_accum4_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum4_pong), 
    .clk(clk)
);

qadd adder_accum_pong5 (wdata_accum5, wdata_accum5_in, wdata_accum5_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum5_pong (
    .addr0(waddr_accum5),
    .d0(wdata_accum5_pong), 
    .we0(wdata_en_pong5), 
    .q0(accum5_pong_q0_NC),
    .addr1(raddr_accum5_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum5_pong), 
    .clk(clk)
);

qadd adder_accum_pong6 (wdata_accum6, wdata_accum6_in, wdata_accum6_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum6_pong (
    .addr0(waddr_accum6),
    .d0(wdata_accum6_pong), 
    .we0(wdata_en_pong6), 
    .q0(accum6_pong_q0_NC),
    .addr1(raddr_accum6_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum6_pong), 
    .clk(clk)
);

qadd adder_accum_pong7 (wdata_accum7, wdata_accum7_in, wdata_accum7_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum7_pong (
    .addr0(waddr_accum7),
    .d0(wdata_accum7_pong), 
    .we0(wdata_en_pong7), 
    .q0(accum7_pong_q0_NC),
    .addr1(raddr_accum7_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum7_pong), 
    .clk(clk)
);

qadd adder_accum_pong8 (wdata_accum8, wdata_accum8_in, wdata_accum8_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum8_pong (
    .addr0(waddr_accum8),
    .d0(wdata_accum8_pong), 
    .we0(wdata_en_pong8), 
    .q0(accum8_pong_q0_NC),
    .addr1(raddr_accum8_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum8_pong), 
    .clk(clk)
);

qadd adder_accum_pong9 (wdata_accum9, wdata_accum9_in, wdata_accum9_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum9_pong (
    .addr0(waddr_accum9),
    .d0(wdata_accum9_pong), 
    .we0(wdata_en_pong9), 
    .q0(accum9_pong_q0_NC),
    .addr1(raddr_accum9_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum9_pong), 
    .clk(clk)
);

qadd adder_accum_pong10 (wdata_accum10, wdata_accum10_in, wdata_accum10_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum10_pong (
    .addr0(waddr_accum10),
    .d0(wdata_accum10_pong), 
    .we0(wdata_en_pong10), 
    .q0(accum10_pong_q0_NC),
    .addr1(raddr_accum10_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum10_pong), 
    .clk(clk)
);

qadd adder_accum_pong11 (wdata_accum11, wdata_accum11_in, wdata_accum11_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum11_pong (
    .addr0(waddr_accum11),
    .d0(wdata_accum11_pong), 
    .we0(wdata_en_pong11), 
    .q0(accum11_pong_q0_NC),
    .addr1(raddr_accum11_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum11_pong), 
    .clk(clk)
);

qadd adder_accum_pong12 (wdata_accum12, wdata_accum12_in, wdata_accum12_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum12_pong (
    .addr0(waddr_accum12),
    .d0(wdata_accum12_pong), 
    .we0(wdata_en_pong12), 
    .q0(accum12_pong_q0_NC),
    .addr1(raddr_accum12_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum12_pong), 
    .clk(clk)
);

qadd adder_accum_pong13 (wdata_accum13, wdata_accum13_in, wdata_accum13_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum13_pong (
    .addr0(waddr_accum13),
    .d0(wdata_accum13_pong), 
    .we0(wdata_en_pong13), 
    .q0(accum13_pong_q0_NC),
    .addr1(raddr_accum13_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum13_pong), 
    .clk(clk)
);

qadd adder_accum_pong14 (wdata_accum14, wdata_accum14_in, wdata_accum14_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum14_pong (
    .addr0(waddr_accum14),
    .d0(wdata_accum14_pong), 
    .we0(wdata_en_pong14), 
    .q0(accum14_pong_q0_NC),
    .addr1(raddr_accum14_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum14_pong), 
    .clk(clk)
);

qadd adder_accum_pong15 (wdata_accum15, wdata_accum15_in, wdata_accum15_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum15_pong (
    .addr0(waddr_accum15),
    .d0(wdata_accum15_pong), 
    .we0(wdata_en_pong15), 
    .q0(accum15_pong_q0_NC),
    .addr1(raddr_accum15_pong),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_accum15_pong), 
    .clk(clk)
);


endmodule