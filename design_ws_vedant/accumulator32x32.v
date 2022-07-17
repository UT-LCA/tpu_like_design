////////////////////////////////////////////////////////////////////////////////
// THIS FILE WAS AUTOMATICALLY GENERATED FROM generate_accum.v.mako
// DO NOT EDIT
////////////////////////////////////////////////////////////////////////////////
module accumulator (
    clk,
    resetn,
    start_waddr_accum0,
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
    wdata_accum16,
    wdata_accum17,
    wdata_accum18,
    wdata_accum19,
    wdata_accum20,
    wdata_accum21,
    wdata_accum22,
    wdata_accum23,
    wdata_accum24,
    wdata_accum25,
    wdata_accum26,
    wdata_accum27,
    wdata_accum28,
    wdata_accum29,
    wdata_accum30,
    wdata_accum31,
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
    raddr_accum16_pool,
    raddr_accum17_pool,
    raddr_accum18_pool,
    raddr_accum19_pool,
    raddr_accum20_pool,
    raddr_accum21_pool,
    raddr_accum22_pool,
    raddr_accum23_pool,
    raddr_accum24_pool,
    raddr_accum25_pool,
    raddr_accum26_pool,
    raddr_accum27_pool,
    raddr_accum28_pool,
    raddr_accum29_pool,
    raddr_accum30_pool,
    raddr_accum31_pool,
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
    rdata_accum16_pool,
    rdata_accum17_pool,
    rdata_accum18_pool,
    rdata_accum19_pool,
    rdata_accum20_pool,
    rdata_accum21_pool,
    rdata_accum22_pool,
    rdata_accum23_pool,
    rdata_accum24_pool,
    rdata_accum25_pool,
    rdata_accum26_pool,
    rdata_accum27_pool,
    rdata_accum28_pool,
    rdata_accum29_pool,
    rdata_accum30_pool,
    rdata_accum31_pool,
    wdata_available,
    k_dimension,
    buffer_select,
    start_pooling,
    done_pooling
);

input clk;
input resetn;
input [`AWIDTH-1:0] start_waddr_accum0;
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
input [`DWIDTH-1:0] wdata_accum16;
input [`DWIDTH-1:0] wdata_accum17;
input [`DWIDTH-1:0] wdata_accum18;
input [`DWIDTH-1:0] wdata_accum19;
input [`DWIDTH-1:0] wdata_accum20;
input [`DWIDTH-1:0] wdata_accum21;
input [`DWIDTH-1:0] wdata_accum22;
input [`DWIDTH-1:0] wdata_accum23;
input [`DWIDTH-1:0] wdata_accum24;
input [`DWIDTH-1:0] wdata_accum25;
input [`DWIDTH-1:0] wdata_accum26;
input [`DWIDTH-1:0] wdata_accum27;
input [`DWIDTH-1:0] wdata_accum28;
input [`DWIDTH-1:0] wdata_accum29;
input [`DWIDTH-1:0] wdata_accum30;
input [`DWIDTH-1:0] wdata_accum31;
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
input [`AWIDTH-1:0] raddr_accum16_pool;
input [`AWIDTH-1:0] raddr_accum17_pool;
input [`AWIDTH-1:0] raddr_accum18_pool;
input [`AWIDTH-1:0] raddr_accum19_pool;
input [`AWIDTH-1:0] raddr_accum20_pool;
input [`AWIDTH-1:0] raddr_accum21_pool;
input [`AWIDTH-1:0] raddr_accum22_pool;
input [`AWIDTH-1:0] raddr_accum23_pool;
input [`AWIDTH-1:0] raddr_accum24_pool;
input [`AWIDTH-1:0] raddr_accum25_pool;
input [`AWIDTH-1:0] raddr_accum26_pool;
input [`AWIDTH-1:0] raddr_accum27_pool;
input [`AWIDTH-1:0] raddr_accum28_pool;
input [`AWIDTH-1:0] raddr_accum29_pool;
input [`AWIDTH-1:0] raddr_accum30_pool;
input [`AWIDTH-1:0] raddr_accum31_pool;
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
output [`DWIDTH-1:0] rdata_accum16_pool;
output [`DWIDTH-1:0] rdata_accum17_pool;
output [`DWIDTH-1:0] rdata_accum18_pool;
output [`DWIDTH-1:0] rdata_accum19_pool;
output [`DWIDTH-1:0] rdata_accum20_pool;
output [`DWIDTH-1:0] rdata_accum21_pool;
output [`DWIDTH-1:0] rdata_accum22_pool;
output [`DWIDTH-1:0] rdata_accum23_pool;
output [`DWIDTH-1:0] rdata_accum24_pool;
output [`DWIDTH-1:0] rdata_accum25_pool;
output [`DWIDTH-1:0] rdata_accum26_pool;
output [`DWIDTH-1:0] rdata_accum27_pool;
output [`DWIDTH-1:0] rdata_accum28_pool;
output [`DWIDTH-1:0] rdata_accum29_pool;
output [`DWIDTH-1:0] rdata_accum30_pool;
output [`DWIDTH-1:0] rdata_accum31_pool;
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
reg wdata_available16;
reg wdata_available17;
reg wdata_available18;
reg wdata_available19;
reg wdata_available20;
reg wdata_available21;
reg wdata_available22;
reg wdata_available23;
reg wdata_available24;
reg wdata_available25;
reg wdata_available26;
reg wdata_available27;
reg wdata_available28;
reg wdata_available29;
reg wdata_available30;
reg wdata_available31;

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
    wdata_available16 <= wdata_available15;
    wdata_available17 <= wdata_available16;
    wdata_available18 <= wdata_available17;
    wdata_available19 <= wdata_available18;
    wdata_available20 <= wdata_available19;
    wdata_available21 <= wdata_available20;
    wdata_available22 <= wdata_available21;
    wdata_available23 <= wdata_available22;
    wdata_available24 <= wdata_available23;
    wdata_available25 <= wdata_available24;
    wdata_available26 <= wdata_available25;
    wdata_available27 <= wdata_available26;
    wdata_available28 <= wdata_available27;
    wdata_available29 <= wdata_available28;
    wdata_available30 <= wdata_available29;
    wdata_available31 <= wdata_available30;
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
wire wdata_en_ping16;
wire wdata_en_ping17;
wire wdata_en_ping18;
wire wdata_en_ping19;
wire wdata_en_ping20;
wire wdata_en_ping21;
wire wdata_en_ping22;
wire wdata_en_ping23;
wire wdata_en_ping24;
wire wdata_en_ping25;
wire wdata_en_ping26;
wire wdata_en_ping27;
wire wdata_en_ping28;
wire wdata_en_ping29;
wire wdata_en_ping30;
wire wdata_en_ping31;
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
wire wdata_en_pong16;
wire wdata_en_pong17;
wire wdata_en_pong18;
wire wdata_en_pong19;
wire wdata_en_pong20;
wire wdata_en_pong21;
wire wdata_en_pong22;
wire wdata_en_pong23;
wire wdata_en_pong24;
wire wdata_en_pong25;
wire wdata_en_pong26;
wire wdata_en_pong27;
wire wdata_en_pong28;
wire wdata_en_pong29;
wire wdata_en_pong30;
wire wdata_en_pong31;

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
assign wdata_en_ping16 = wdata_available16 & buffer_select;
assign wdata_en_ping17 = wdata_available17 & buffer_select;
assign wdata_en_ping18 = wdata_available18 & buffer_select;
assign wdata_en_ping19 = wdata_available19 & buffer_select;
assign wdata_en_ping20 = wdata_available20 & buffer_select;
assign wdata_en_ping21 = wdata_available21 & buffer_select;
assign wdata_en_ping22 = wdata_available22 & buffer_select;
assign wdata_en_ping23 = wdata_available23 & buffer_select;
assign wdata_en_ping24 = wdata_available24 & buffer_select;
assign wdata_en_ping25 = wdata_available25 & buffer_select;
assign wdata_en_ping26 = wdata_available26 & buffer_select;
assign wdata_en_ping27 = wdata_available27 & buffer_select;
assign wdata_en_ping28 = wdata_available28 & buffer_select;
assign wdata_en_ping29 = wdata_available29 & buffer_select;
assign wdata_en_ping30 = wdata_available30 & buffer_select;
assign wdata_en_ping31 = wdata_available31 & buffer_select;

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
assign wdata_en_pong16 = wdata_available16 & ~buffer_select;
assign wdata_en_pong17 = wdata_available17 & ~buffer_select;
assign wdata_en_pong18 = wdata_available18 & ~buffer_select;
assign wdata_en_pong19 = wdata_available19 & ~buffer_select;
assign wdata_en_pong20 = wdata_available20 & ~buffer_select;
assign wdata_en_pong21 = wdata_available21 & ~buffer_select;
assign wdata_en_pong22 = wdata_available22 & ~buffer_select;
assign wdata_en_pong23 = wdata_available23 & ~buffer_select;
assign wdata_en_pong24 = wdata_available24 & ~buffer_select;
assign wdata_en_pong25 = wdata_available25 & ~buffer_select;
assign wdata_en_pong26 = wdata_available26 & ~buffer_select;
assign wdata_en_pong27 = wdata_available27 & ~buffer_select;
assign wdata_en_pong28 = wdata_available28 & ~buffer_select;
assign wdata_en_pong29 = wdata_available29 & ~buffer_select;
assign wdata_en_pong30 = wdata_available30 & ~buffer_select;
assign wdata_en_pong31 = wdata_available31 & ~buffer_select;

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
reg [`AWIDTH-1:0] waddr_accum16;
reg [`AWIDTH-1:0] waddr_accum17;
reg [`AWIDTH-1:0] waddr_accum18;
reg [`AWIDTH-1:0] waddr_accum19;
reg [`AWIDTH-1:0] waddr_accum20;
reg [`AWIDTH-1:0] waddr_accum21;
reg [`AWIDTH-1:0] waddr_accum22;
reg [`AWIDTH-1:0] waddr_accum23;
reg [`AWIDTH-1:0] waddr_accum24;
reg [`AWIDTH-1:0] waddr_accum25;
reg [`AWIDTH-1:0] waddr_accum26;
reg [`AWIDTH-1:0] waddr_accum27;
reg [`AWIDTH-1:0] waddr_accum28;
reg [`AWIDTH-1:0] waddr_accum29;
reg [`AWIDTH-1:0] waddr_accum30;
reg [`AWIDTH-1:0] waddr_accum31;
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
reg add_accum_mux16;
reg add_accum_mux17;
reg add_accum_mux18;
reg add_accum_mux19;
reg add_accum_mux20;
reg add_accum_mux21;
reg add_accum_mux22;
reg add_accum_mux23;
reg add_accum_mux24;
reg add_accum_mux25;
reg add_accum_mux26;
reg add_accum_mux27;
reg add_accum_mux28;
reg add_accum_mux29;
reg add_accum_mux30;
reg add_accum_mux31;

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
    add_accum_mux16 <= add_accum_mux15;
    add_accum_mux17 <= add_accum_mux16;
    add_accum_mux18 <= add_accum_mux17;
    add_accum_mux19 <= add_accum_mux18;
    add_accum_mux20 <= add_accum_mux19;
    add_accum_mux21 <= add_accum_mux20;
    add_accum_mux22 <= add_accum_mux21;
    add_accum_mux23 <= add_accum_mux22;
    add_accum_mux24 <= add_accum_mux23;
    add_accum_mux25 <= add_accum_mux24;
    add_accum_mux26 <= add_accum_mux25;
    add_accum_mux27 <= add_accum_mux26;
    add_accum_mux28 <= add_accum_mux27;
    add_accum_mux29 <= add_accum_mux28;
    add_accum_mux30 <= add_accum_mux29;
    add_accum_mux31 <= add_accum_mux30;
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
    waddr_accum16 <= waddr_accum15;
    waddr_accum17 <= waddr_accum16;
    waddr_accum18 <= waddr_accum17;
    waddr_accum19 <= waddr_accum18;
    waddr_accum20 <= waddr_accum19;
    waddr_accum21 <= waddr_accum20;
    waddr_accum22 <= waddr_accum21;
    waddr_accum23 <= waddr_accum22;
    waddr_accum24 <= waddr_accum23;
    waddr_accum25 <= waddr_accum24;
    waddr_accum26 <= waddr_accum25;
    waddr_accum27 <= waddr_accum26;
    waddr_accum28 <= waddr_accum27;
    waddr_accum29 <= waddr_accum28;
    waddr_accum30 <= waddr_accum29;
    waddr_accum31 <= waddr_accum30;
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
wire [`DWIDTH-1:0] wdata_accum16_in;
wire [`DWIDTH-1:0] wdata_accum17_in;
wire [`DWIDTH-1:0] wdata_accum18_in;
wire [`DWIDTH-1:0] wdata_accum19_in;
wire [`DWIDTH-1:0] wdata_accum20_in;
wire [`DWIDTH-1:0] wdata_accum21_in;
wire [`DWIDTH-1:0] wdata_accum22_in;
wire [`DWIDTH-1:0] wdata_accum23_in;
wire [`DWIDTH-1:0] wdata_accum24_in;
wire [`DWIDTH-1:0] wdata_accum25_in;
wire [`DWIDTH-1:0] wdata_accum26_in;
wire [`DWIDTH-1:0] wdata_accum27_in;
wire [`DWIDTH-1:0] wdata_accum28_in;
wire [`DWIDTH-1:0] wdata_accum29_in;
wire [`DWIDTH-1:0] wdata_accum30_in;
wire [`DWIDTH-1:0] wdata_accum31_in;

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
wire [`DWIDTH-1:0] wdata_accum16_ping;
wire [`DWIDTH-1:0] wdata_accum17_ping;
wire [`DWIDTH-1:0] wdata_accum18_ping;
wire [`DWIDTH-1:0] wdata_accum19_ping;
wire [`DWIDTH-1:0] wdata_accum20_ping;
wire [`DWIDTH-1:0] wdata_accum21_ping;
wire [`DWIDTH-1:0] wdata_accum22_ping;
wire [`DWIDTH-1:0] wdata_accum23_ping;
wire [`DWIDTH-1:0] wdata_accum24_ping;
wire [`DWIDTH-1:0] wdata_accum25_ping;
wire [`DWIDTH-1:0] wdata_accum26_ping;
wire [`DWIDTH-1:0] wdata_accum27_ping;
wire [`DWIDTH-1:0] wdata_accum28_ping;
wire [`DWIDTH-1:0] wdata_accum29_ping;
wire [`DWIDTH-1:0] wdata_accum30_ping;
wire [`DWIDTH-1:0] wdata_accum31_ping;

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
wire [`AWIDTH-1:0] raddr_buffer16;
wire [`AWIDTH-1:0] raddr_buffer17;
wire [`AWIDTH-1:0] raddr_buffer18;
wire [`AWIDTH-1:0] raddr_buffer19;
wire [`AWIDTH-1:0] raddr_buffer20;
wire [`AWIDTH-1:0] raddr_buffer21;
wire [`AWIDTH-1:0] raddr_buffer22;
wire [`AWIDTH-1:0] raddr_buffer23;
wire [`AWIDTH-1:0] raddr_buffer24;
wire [`AWIDTH-1:0] raddr_buffer25;
wire [`AWIDTH-1:0] raddr_buffer26;
wire [`AWIDTH-1:0] raddr_buffer27;
wire [`AWIDTH-1:0] raddr_buffer28;
wire [`AWIDTH-1:0] raddr_buffer29;
wire [`AWIDTH-1:0] raddr_buffer30;
wire [`AWIDTH-1:0] raddr_buffer31;

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
wire [`DWIDTH-1:0] rdata_buffer16;
wire [`DWIDTH-1:0] rdata_buffer17;
wire [`DWIDTH-1:0] rdata_buffer18;
wire [`DWIDTH-1:0] rdata_buffer19;
wire [`DWIDTH-1:0] rdata_buffer20;
wire [`DWIDTH-1:0] rdata_buffer21;
wire [`DWIDTH-1:0] rdata_buffer22;
wire [`DWIDTH-1:0] rdata_buffer23;
wire [`DWIDTH-1:0] rdata_buffer24;
wire [`DWIDTH-1:0] rdata_buffer25;
wire [`DWIDTH-1:0] rdata_buffer26;
wire [`DWIDTH-1:0] rdata_buffer27;
wire [`DWIDTH-1:0] rdata_buffer28;
wire [`DWIDTH-1:0] rdata_buffer29;
wire [`DWIDTH-1:0] rdata_buffer30;
wire [`DWIDTH-1:0] rdata_buffer31;

wire [`DWIDTH-1:0] rdata_buffer0_pong;
wire [`DWIDTH-1:0] rdata_buffer1_pong;
wire [`DWIDTH-1:0] rdata_buffer2_pong;
wire [`DWIDTH-1:0] rdata_buffer3_pong;
wire [`DWIDTH-1:0] rdata_buffer4_pong;
wire [`DWIDTH-1:0] rdata_buffer5_pong;
wire [`DWIDTH-1:0] rdata_buffer6_pong;
wire [`DWIDTH-1:0] rdata_buffer7_pong;
wire [`DWIDTH-1:0] rdata_buffer8_pong;
wire [`DWIDTH-1:0] rdata_buffer9_pong;
wire [`DWIDTH-1:0] rdata_buffer10_pong;
wire [`DWIDTH-1:0] rdata_buffer11_pong;
wire [`DWIDTH-1:0] rdata_buffer12_pong;
wire [`DWIDTH-1:0] rdata_buffer13_pong;
wire [`DWIDTH-1:0] rdata_buffer14_pong;
wire [`DWIDTH-1:0] rdata_buffer15_pong;
wire [`DWIDTH-1:0] rdata_buffer16_pong;
wire [`DWIDTH-1:0] rdata_buffer17_pong;
wire [`DWIDTH-1:0] rdata_buffer18_pong;
wire [`DWIDTH-1:0] rdata_buffer19_pong;
wire [`DWIDTH-1:0] rdata_buffer20_pong;
wire [`DWIDTH-1:0] rdata_buffer21_pong;
wire [`DWIDTH-1:0] rdata_buffer22_pong;
wire [`DWIDTH-1:0] rdata_buffer23_pong;
wire [`DWIDTH-1:0] rdata_buffer24_pong;
wire [`DWIDTH-1:0] rdata_buffer25_pong;
wire [`DWIDTH-1:0] rdata_buffer26_pong;
wire [`DWIDTH-1:0] rdata_buffer27_pong;
wire [`DWIDTH-1:0] rdata_buffer28_pong;
wire [`DWIDTH-1:0] rdata_buffer29_pong;
wire [`DWIDTH-1:0] rdata_buffer30_pong;
wire [`DWIDTH-1:0] rdata_buffer31_pong;
    
// Based on the Accumulator Adder MUX select signal either 0 or data read from the RAM goes into the Adder
assign wdata_accum0_in = (~add_accum_mux0)?  8'b0 : (buffer_select)? rdata_buffer0 : rdata_buffer0_pong;
assign wdata_accum1_in = (~add_accum_mux1)?  8'b0 : (buffer_select)? rdata_buffer1 : rdata_buffer1_pong;
assign wdata_accum2_in = (~add_accum_mux2)?  8'b0 : (buffer_select)? rdata_buffer2 : rdata_buffer2_pong;
assign wdata_accum3_in = (~add_accum_mux3)?  8'b0 : (buffer_select)? rdata_buffer3 : rdata_buffer3_pong;
assign wdata_accum4_in = (~add_accum_mux4)?  8'b0 : (buffer_select)? rdata_buffer4 : rdata_buffer4_pong;
assign wdata_accum5_in = (~add_accum_mux5)?  8'b0 : (buffer_select)? rdata_buffer5 : rdata_buffer5_pong;
assign wdata_accum6_in = (~add_accum_mux6)?  8'b0 : (buffer_select)? rdata_buffer6 : rdata_buffer6_pong;
assign wdata_accum7_in = (~add_accum_mux7)?  8'b0 : (buffer_select)? rdata_buffer7 : rdata_buffer7_pong;
assign wdata_accum8_in = (~add_accum_mux8)?  8'b0 : (buffer_select)? rdata_buffer8 : rdata_buffer8_pong;
assign wdata_accum9_in = (~add_accum_mux9)?  8'b0 : (buffer_select)? rdata_buffer9 : rdata_buffer9_pong;
assign wdata_accum10_in = (~add_accum_mux10)?  8'b0 : (buffer_select)? rdata_buffer10 : rdata_buffer10_pong;
assign wdata_accum11_in = (~add_accum_mux11)?  8'b0 : (buffer_select)? rdata_buffer11 : rdata_buffer11_pong;
assign wdata_accum12_in = (~add_accum_mux12)?  8'b0 : (buffer_select)? rdata_buffer12 : rdata_buffer12_pong;
assign wdata_accum13_in = (~add_accum_mux13)?  8'b0 : (buffer_select)? rdata_buffer13 : rdata_buffer13_pong;
assign wdata_accum14_in = (~add_accum_mux14)?  8'b0 : (buffer_select)? rdata_buffer14 : rdata_buffer14_pong;
assign wdata_accum15_in = (~add_accum_mux15)?  8'b0 : (buffer_select)? rdata_buffer15 : rdata_buffer15_pong;
assign wdata_accum16_in = (~add_accum_mux16)?  8'b0 : (buffer_select)? rdata_buffer16 : rdata_buffer16_pong;
assign wdata_accum17_in = (~add_accum_mux17)?  8'b0 : (buffer_select)? rdata_buffer17 : rdata_buffer17_pong;
assign wdata_accum18_in = (~add_accum_mux18)?  8'b0 : (buffer_select)? rdata_buffer18 : rdata_buffer18_pong;
assign wdata_accum19_in = (~add_accum_mux19)?  8'b0 : (buffer_select)? rdata_buffer19 : rdata_buffer19_pong;
assign wdata_accum20_in = (~add_accum_mux20)?  8'b0 : (buffer_select)? rdata_buffer20 : rdata_buffer20_pong;
assign wdata_accum21_in = (~add_accum_mux21)?  8'b0 : (buffer_select)? rdata_buffer21 : rdata_buffer21_pong;
assign wdata_accum22_in = (~add_accum_mux22)?  8'b0 : (buffer_select)? rdata_buffer22 : rdata_buffer22_pong;
assign wdata_accum23_in = (~add_accum_mux23)?  8'b0 : (buffer_select)? rdata_buffer23 : rdata_buffer23_pong;
assign wdata_accum24_in = (~add_accum_mux24)?  8'b0 : (buffer_select)? rdata_buffer24 : rdata_buffer24_pong;
assign wdata_accum25_in = (~add_accum_mux25)?  8'b0 : (buffer_select)? rdata_buffer25 : rdata_buffer25_pong;
assign wdata_accum26_in = (~add_accum_mux26)?  8'b0 : (buffer_select)? rdata_buffer26 : rdata_buffer26_pong;
assign wdata_accum27_in = (~add_accum_mux27)?  8'b0 : (buffer_select)? rdata_buffer27 : rdata_buffer27_pong;
assign wdata_accum28_in = (~add_accum_mux28)?  8'b0 : (buffer_select)? rdata_buffer28 : rdata_buffer28_pong;
assign wdata_accum29_in = (~add_accum_mux29)?  8'b0 : (buffer_select)? rdata_buffer29 : rdata_buffer29_pong;
assign wdata_accum30_in = (~add_accum_mux30)?  8'b0 : (buffer_select)? rdata_buffer30 : rdata_buffer30_pong;
assign wdata_accum31_in = (~add_accum_mux31)?  8'b0 : (buffer_select)? rdata_buffer31 : rdata_buffer31_pong;
  
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
reg [`AWIDTH-1:0] raddr_accum16;
reg [`AWIDTH-1:0] raddr_accum17;
reg [`AWIDTH-1:0] raddr_accum18;
reg [`AWIDTH-1:0] raddr_accum19;
reg [`AWIDTH-1:0] raddr_accum20;
reg [`AWIDTH-1:0] raddr_accum21;
reg [`AWIDTH-1:0] raddr_accum22;
reg [`AWIDTH-1:0] raddr_accum23;
reg [`AWIDTH-1:0] raddr_accum24;
reg [`AWIDTH-1:0] raddr_accum25;
reg [`AWIDTH-1:0] raddr_accum26;
reg [`AWIDTH-1:0] raddr_accum27;
reg [`AWIDTH-1:0] raddr_accum28;
reg [`AWIDTH-1:0] raddr_accum29;
reg [`AWIDTH-1:0] raddr_accum30;
reg [`AWIDTH-1:0] raddr_accum31;
  
// Start reading the address written to after 31 clock cycles to calculate partial sums
always @ (posedge clk) begin
    raddr_accum0 <= waddr_accum30; // waddr_accum30 = (waddr_accum0 delayed by 30 clock cycles)
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
    raddr_accum16 <= raddr_accum15;
    raddr_accum17 <= raddr_accum16;
    raddr_accum18 <= raddr_accum17;
    raddr_accum19 <= raddr_accum18;
    raddr_accum20 <= raddr_accum19;
    raddr_accum21 <= raddr_accum20;
    raddr_accum22 <= raddr_accum21;
    raddr_accum23 <= raddr_accum22;
    raddr_accum24 <= raddr_accum23;
    raddr_accum25 <= raddr_accum24;
    raddr_accum26 <= raddr_accum25;
    raddr_accum27 <= raddr_accum26;
    raddr_accum28 <= raddr_accum27;
    raddr_accum29 <= raddr_accum28;
    raddr_accum30 <= raddr_accum29;
    raddr_accum31 <= raddr_accum30;
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
wire [`DWIDTH-1:0] accum16_ping_q0_NC;
wire [`DWIDTH-1:0] accum17_ping_q0_NC;
wire [`DWIDTH-1:0] accum18_ping_q0_NC;
wire [`DWIDTH-1:0] accum19_ping_q0_NC;
wire [`DWIDTH-1:0] accum20_ping_q0_NC;
wire [`DWIDTH-1:0] accum21_ping_q0_NC;
wire [`DWIDTH-1:0] accum22_ping_q0_NC;
wire [`DWIDTH-1:0] accum23_ping_q0_NC;
wire [`DWIDTH-1:0] accum24_ping_q0_NC;
wire [`DWIDTH-1:0] accum25_ping_q0_NC;
wire [`DWIDTH-1:0] accum26_ping_q0_NC;
wire [`DWIDTH-1:0] accum27_ping_q0_NC;
wire [`DWIDTH-1:0] accum28_ping_q0_NC;
wire [`DWIDTH-1:0] accum29_ping_q0_NC;
wire [`DWIDTH-1:0] accum30_ping_q0_NC;
wire [`DWIDTH-1:0] accum31_ping_q0_NC;
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
wire [`DWIDTH-1:0] accum16_pong_q0_NC;
wire [`DWIDTH-1:0] accum17_pong_q0_NC;
wire [`DWIDTH-1:0] accum18_pong_q0_NC;
wire [`DWIDTH-1:0] accum19_pong_q0_NC;
wire [`DWIDTH-1:0] accum20_pong_q0_NC;
wire [`DWIDTH-1:0] accum21_pong_q0_NC;
wire [`DWIDTH-1:0] accum22_pong_q0_NC;
wire [`DWIDTH-1:0] accum23_pong_q0_NC;
wire [`DWIDTH-1:0] accum24_pong_q0_NC;
wire [`DWIDTH-1:0] accum25_pong_q0_NC;
wire [`DWIDTH-1:0] accum26_pong_q0_NC;
wire [`DWIDTH-1:0] accum27_pong_q0_NC;
wire [`DWIDTH-1:0] accum28_pong_q0_NC;
wire [`DWIDTH-1:0] accum29_pong_q0_NC;
wire [`DWIDTH-1:0] accum30_pong_q0_NC;
wire [`DWIDTH-1:0] accum31_pong_q0_NC;

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
reg buffer_select_pool16;
reg buffer_select_pool17;
reg buffer_select_pool18;
reg buffer_select_pool19;
reg buffer_select_pool20;
reg buffer_select_pool21;
reg buffer_select_pool22;
reg buffer_select_pool23;
reg buffer_select_pool24;
reg buffer_select_pool25;
reg buffer_select_pool26;
reg buffer_select_pool27;
reg buffer_select_pool28;
reg buffer_select_pool29;
reg buffer_select_pool30;
reg buffer_select_pool31;
  
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
buffer_select_pool16 <= buffer_select_pool15;
buffer_select_pool17 <= buffer_select_pool16;
buffer_select_pool18 <= buffer_select_pool17;
buffer_select_pool19 <= buffer_select_pool18;
buffer_select_pool20 <= buffer_select_pool19;
buffer_select_pool21 <= buffer_select_pool20;
buffer_select_pool22 <= buffer_select_pool21;
buffer_select_pool23 <= buffer_select_pool22;
buffer_select_pool24 <= buffer_select_pool23;
buffer_select_pool25 <= buffer_select_pool24;
buffer_select_pool26 <= buffer_select_pool25;
buffer_select_pool27 <= buffer_select_pool26;
buffer_select_pool28 <= buffer_select_pool27;
buffer_select_pool29 <= buffer_select_pool28;
buffer_select_pool30 <= buffer_select_pool29;
buffer_select_pool31 <= buffer_select_pool30;
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
reg buffer_select_accum16;
reg buffer_select_accum17;
reg buffer_select_accum18;
reg buffer_select_accum19;
reg buffer_select_accum20;
reg buffer_select_accum21;
reg buffer_select_accum22;
reg buffer_select_accum23;
reg buffer_select_accum24;
reg buffer_select_accum25;
reg buffer_select_accum26;
reg buffer_select_accum27;
reg buffer_select_accum28;
reg buffer_select_accum29;
reg buffer_select_accum30;
reg buffer_select_accum31;
  
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
buffer_select_accum16 <= buffer_select_accum15;
buffer_select_accum17 <= buffer_select_accum16;
buffer_select_accum18 <= buffer_select_accum17;
buffer_select_accum19 <= buffer_select_accum18;
buffer_select_accum20 <= buffer_select_accum19;
buffer_select_accum21 <= buffer_select_accum20;
buffer_select_accum22 <= buffer_select_accum21;
buffer_select_accum23 <= buffer_select_accum22;
buffer_select_accum24 <= buffer_select_accum23;
buffer_select_accum25 <= buffer_select_accum24;
buffer_select_accum26 <= buffer_select_accum25;
buffer_select_accum27 <= buffer_select_accum26;
buffer_select_accum28 <= buffer_select_accum27;
buffer_select_accum29 <= buffer_select_accum28;
buffer_select_accum30 <= buffer_select_accum29;
buffer_select_accum31 <= buffer_select_accum30;
end

assign raddr_buffer0 = (buffer_select_pool)? raddr_accum0_pool : (buffer_select_accum)? raddr_accum0:11'bx;
assign raddr_buffer1 = (buffer_select_pool1)? raddr_accum1_pool : (buffer_select_accum1)? raddr_accum1:11'bx;
assign raddr_buffer2 = (buffer_select_pool2)? raddr_accum2_pool : (buffer_select_accum2)? raddr_accum2:11'bx;
assign raddr_buffer3 = (buffer_select_pool3)? raddr_accum3_pool : (buffer_select_accum3)? raddr_accum3:11'bx;
assign raddr_buffer4 = (buffer_select_pool4)? raddr_accum4_pool : (buffer_select_accum4)? raddr_accum4:11'bx;
assign raddr_buffer5 = (buffer_select_pool5)? raddr_accum5_pool : (buffer_select_accum5)? raddr_accum5:11'bx;
assign raddr_buffer6 = (buffer_select_pool6)? raddr_accum6_pool : (buffer_select_accum6)? raddr_accum6:11'bx;
assign raddr_buffer7 = (buffer_select_pool7)? raddr_accum7_pool : (buffer_select_accum7)? raddr_accum7:11'bx;
assign raddr_buffer8 = (buffer_select_pool8)? raddr_accum8_pool : (buffer_select_accum8)? raddr_accum8:11'bx;
assign raddr_buffer9 = (buffer_select_pool9)? raddr_accum9_pool : (buffer_select_accum9)? raddr_accum9:11'bx;
assign raddr_buffer10 = (buffer_select_pool10)? raddr_accum10_pool : (buffer_select_accum10)? raddr_accum10:11'bx;
assign raddr_buffer11 = (buffer_select_pool11)? raddr_accum11_pool : (buffer_select_accum11)? raddr_accum11:11'bx;
assign raddr_buffer12 = (buffer_select_pool12)? raddr_accum12_pool : (buffer_select_accum12)? raddr_accum12:11'bx;
assign raddr_buffer13 = (buffer_select_pool13)? raddr_accum13_pool : (buffer_select_accum13)? raddr_accum13:11'bx;
assign raddr_buffer14 = (buffer_select_pool14)? raddr_accum14_pool : (buffer_select_accum14)? raddr_accum14:11'bx;
assign raddr_buffer15 = (buffer_select_pool15)? raddr_accum15_pool : (buffer_select_accum15)? raddr_accum15:11'bx;
assign raddr_buffer16 = (buffer_select_pool16)? raddr_accum16_pool : (buffer_select_accum16)? raddr_accum16:11'bx;
assign raddr_buffer17 = (buffer_select_pool17)? raddr_accum17_pool : (buffer_select_accum17)? raddr_accum17:11'bx;
assign raddr_buffer18 = (buffer_select_pool18)? raddr_accum18_pool : (buffer_select_accum18)? raddr_accum18:11'bx;
assign raddr_buffer19 = (buffer_select_pool19)? raddr_accum19_pool : (buffer_select_accum19)? raddr_accum19:11'bx;
assign raddr_buffer20 = (buffer_select_pool20)? raddr_accum20_pool : (buffer_select_accum20)? raddr_accum20:11'bx;
assign raddr_buffer21 = (buffer_select_pool21)? raddr_accum21_pool : (buffer_select_accum21)? raddr_accum21:11'bx;
assign raddr_buffer22 = (buffer_select_pool22)? raddr_accum22_pool : (buffer_select_accum22)? raddr_accum22:11'bx;
assign raddr_buffer23 = (buffer_select_pool23)? raddr_accum23_pool : (buffer_select_accum23)? raddr_accum23:11'bx;
assign raddr_buffer24 = (buffer_select_pool24)? raddr_accum24_pool : (buffer_select_accum24)? raddr_accum24:11'bx;
assign raddr_buffer25 = (buffer_select_pool25)? raddr_accum25_pool : (buffer_select_accum25)? raddr_accum25:11'bx;
assign raddr_buffer26 = (buffer_select_pool26)? raddr_accum26_pool : (buffer_select_accum26)? raddr_accum26:11'bx;
assign raddr_buffer27 = (buffer_select_pool27)? raddr_accum27_pool : (buffer_select_accum27)? raddr_accum27:11'bx;
assign raddr_buffer28 = (buffer_select_pool28)? raddr_accum28_pool : (buffer_select_accum28)? raddr_accum28:11'bx;
assign raddr_buffer29 = (buffer_select_pool29)? raddr_accum29_pool : (buffer_select_accum29)? raddr_accum29:11'bx;
assign raddr_buffer30 = (buffer_select_pool30)? raddr_accum30_pool : (buffer_select_accum30)? raddr_accum30:11'bx;
assign raddr_buffer31 = (buffer_select_pool31)? raddr_accum31_pool : (buffer_select_accum31)? raddr_accum31:11'bx;
  
assign rdata_accum0_pool =  (buffer_select_pool)?  (buffer_select)? rdata_buffer0 : rdata_buffer0_pong : 8'b0;
assign rdata_accum1_pool =  (buffer_select_pool1)? (buffer_select)? rdata_buffer1 : rdata_buffer1_pong : 8'b0;
assign rdata_accum2_pool =  (buffer_select_pool2)? (buffer_select)? rdata_buffer2 : rdata_buffer2_pong : 8'b0;
assign rdata_accum3_pool =  (buffer_select_pool3)? (buffer_select)? rdata_buffer3 : rdata_buffer3_pong : 8'b0;
assign rdata_accum4_pool =  (buffer_select_pool4)? (buffer_select)? rdata_buffer4 : rdata_buffer4_pong : 8'b0;
assign rdata_accum5_pool =  (buffer_select_pool5)? (buffer_select)? rdata_buffer5 : rdata_buffer5_pong : 8'b0;
assign rdata_accum6_pool =  (buffer_select_pool6)? (buffer_select)? rdata_buffer6 : rdata_buffer6_pong : 8'b0;
assign rdata_accum7_pool =  (buffer_select_pool7)? (buffer_select)? rdata_buffer7 : rdata_buffer7_pong : 8'b0;
assign rdata_accum8_pool =  (buffer_select_pool8)? (buffer_select)? rdata_buffer8 : rdata_buffer8_pong : 8'b0;
assign rdata_accum9_pool =  (buffer_select_pool9)? (buffer_select)? rdata_buffer9 : rdata_buffer9_pong : 8'b0;
assign rdata_accum10_pool =  (buffer_select_pool10)? (buffer_select)? rdata_buffer10 : rdata_buffer10_pong : 8'b0;
assign rdata_accum11_pool =  (buffer_select_pool11)? (buffer_select)? rdata_buffer11 : rdata_buffer11_pong : 8'b0;
assign rdata_accum12_pool =  (buffer_select_pool12)? (buffer_select)? rdata_buffer12 : rdata_buffer12_pong : 8'b0;
assign rdata_accum13_pool =  (buffer_select_pool13)? (buffer_select)? rdata_buffer13 : rdata_buffer13_pong : 8'b0;
assign rdata_accum14_pool =  (buffer_select_pool14)? (buffer_select)? rdata_buffer14 : rdata_buffer14_pong : 8'b0;
assign rdata_accum15_pool =  (buffer_select_pool15)? (buffer_select)? rdata_buffer15 : rdata_buffer15_pong : 8'b0;
assign rdata_accum16_pool =  (buffer_select_pool16)? (buffer_select)? rdata_buffer16 : rdata_buffer16_pong : 8'b0;
assign rdata_accum17_pool =  (buffer_select_pool17)? (buffer_select)? rdata_buffer17 : rdata_buffer17_pong : 8'b0;
assign rdata_accum18_pool =  (buffer_select_pool18)? (buffer_select)? rdata_buffer18 : rdata_buffer18_pong : 8'b0;
assign rdata_accum19_pool =  (buffer_select_pool19)? (buffer_select)? rdata_buffer19 : rdata_buffer19_pong : 8'b0;
assign rdata_accum20_pool =  (buffer_select_pool20)? (buffer_select)? rdata_buffer20 : rdata_buffer20_pong : 8'b0;
assign rdata_accum21_pool =  (buffer_select_pool21)? (buffer_select)? rdata_buffer21 : rdata_buffer21_pong : 8'b0;
assign rdata_accum22_pool =  (buffer_select_pool22)? (buffer_select)? rdata_buffer22 : rdata_buffer22_pong : 8'b0;
assign rdata_accum23_pool =  (buffer_select_pool23)? (buffer_select)? rdata_buffer23 : rdata_buffer23_pong : 8'b0;
assign rdata_accum24_pool =  (buffer_select_pool24)? (buffer_select)? rdata_buffer24 : rdata_buffer24_pong : 8'b0;
assign rdata_accum25_pool =  (buffer_select_pool25)? (buffer_select)? rdata_buffer25 : rdata_buffer25_pong : 8'b0;
assign rdata_accum26_pool =  (buffer_select_pool26)? (buffer_select)? rdata_buffer26 : rdata_buffer26_pong : 8'b0;
assign rdata_accum27_pool =  (buffer_select_pool27)? (buffer_select)? rdata_buffer27 : rdata_buffer27_pong : 8'b0;
assign rdata_accum28_pool =  (buffer_select_pool28)? (buffer_select)? rdata_buffer28 : rdata_buffer28_pong : 8'b0;
assign rdata_accum29_pool =  (buffer_select_pool29)? (buffer_select)? rdata_buffer29 : rdata_buffer29_pong : 8'b0;
assign rdata_accum30_pool =  (buffer_select_pool30)? (buffer_select)? rdata_buffer30 : rdata_buffer30_pong : 8'b0;
assign rdata_accum31_pool =  (buffer_select_pool31)? (buffer_select)? rdata_buffer31 : rdata_buffer31_pong : 8'b0;
  
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

qadd adder_accum_ping16 (wdata_accum16, wdata_accum16_in, wdata_accum16_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum16_ping (
    .addr0(waddr_accum16),
    .d0(wdata_accum16_ping), 
    .we0(wdata_en_ping16), 
    .q0(accum16_ping_q0_NC),
    .addr1(raddr_buffer16),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer16), 
    .clk(clk)
);

qadd adder_accum_ping17 (wdata_accum17, wdata_accum17_in, wdata_accum17_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum17_ping (
    .addr0(waddr_accum17),
    .d0(wdata_accum17_ping), 
    .we0(wdata_en_ping17), 
    .q0(accum17_ping_q0_NC),
    .addr1(raddr_buffer17),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer17), 
    .clk(clk)
);

qadd adder_accum_ping18 (wdata_accum18, wdata_accum18_in, wdata_accum18_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum18_ping (
    .addr0(waddr_accum18),
    .d0(wdata_accum18_ping), 
    .we0(wdata_en_ping18), 
    .q0(accum18_ping_q0_NC),
    .addr1(raddr_buffer18),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer18), 
    .clk(clk)
);

qadd adder_accum_ping19 (wdata_accum19, wdata_accum19_in, wdata_accum19_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum19_ping (
    .addr0(waddr_accum19),
    .d0(wdata_accum19_ping), 
    .we0(wdata_en_ping19), 
    .q0(accum19_ping_q0_NC),
    .addr1(raddr_buffer19),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer19), 
    .clk(clk)
);

qadd adder_accum_ping20 (wdata_accum20, wdata_accum20_in, wdata_accum20_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum20_ping (
    .addr0(waddr_accum20),
    .d0(wdata_accum20_ping), 
    .we0(wdata_en_ping20), 
    .q0(accum20_ping_q0_NC),
    .addr1(raddr_buffer20),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer20), 
    .clk(clk)
);

qadd adder_accum_ping21 (wdata_accum21, wdata_accum21_in, wdata_accum21_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum21_ping (
    .addr0(waddr_accum21),
    .d0(wdata_accum21_ping), 
    .we0(wdata_en_ping21), 
    .q0(accum21_ping_q0_NC),
    .addr1(raddr_buffer21),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer21), 
    .clk(clk)
);

qadd adder_accum_ping22 (wdata_accum22, wdata_accum22_in, wdata_accum22_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum22_ping (
    .addr0(waddr_accum22),
    .d0(wdata_accum22_ping), 
    .we0(wdata_en_ping22), 
    .q0(accum22_ping_q0_NC),
    .addr1(raddr_buffer22),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer22), 
    .clk(clk)
);

qadd adder_accum_ping23 (wdata_accum23, wdata_accum23_in, wdata_accum23_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum23_ping (
    .addr0(waddr_accum23),
    .d0(wdata_accum23_ping), 
    .we0(wdata_en_ping23), 
    .q0(accum23_ping_q0_NC),
    .addr1(raddr_buffer23),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer23), 
    .clk(clk)
);

qadd adder_accum_ping24 (wdata_accum24, wdata_accum24_in, wdata_accum24_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum24_ping (
    .addr0(waddr_accum24),
    .d0(wdata_accum24_ping), 
    .we0(wdata_en_ping24), 
    .q0(accum24_ping_q0_NC),
    .addr1(raddr_buffer24),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer24), 
    .clk(clk)
);

qadd adder_accum_ping25 (wdata_accum25, wdata_accum25_in, wdata_accum25_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum25_ping (
    .addr0(waddr_accum25),
    .d0(wdata_accum25_ping), 
    .we0(wdata_en_ping25), 
    .q0(accum25_ping_q0_NC),
    .addr1(raddr_buffer25),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer25), 
    .clk(clk)
);

qadd adder_accum_ping26 (wdata_accum26, wdata_accum26_in, wdata_accum26_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum26_ping (
    .addr0(waddr_accum26),
    .d0(wdata_accum26_ping), 
    .we0(wdata_en_ping26), 
    .q0(accum26_ping_q0_NC),
    .addr1(raddr_buffer26),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer26), 
    .clk(clk)
);

qadd adder_accum_ping27 (wdata_accum27, wdata_accum27_in, wdata_accum27_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum27_ping (
    .addr0(waddr_accum27),
    .d0(wdata_accum27_ping), 
    .we0(wdata_en_ping27), 
    .q0(accum27_ping_q0_NC),
    .addr1(raddr_buffer27),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer27), 
    .clk(clk)
);

qadd adder_accum_ping28 (wdata_accum28, wdata_accum28_in, wdata_accum28_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum28_ping (
    .addr0(waddr_accum28),
    .d0(wdata_accum28_ping), 
    .we0(wdata_en_ping28), 
    .q0(accum28_ping_q0_NC),
    .addr1(raddr_buffer28),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer28), 
    .clk(clk)
);

qadd adder_accum_ping29 (wdata_accum29, wdata_accum29_in, wdata_accum29_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum29_ping (
    .addr0(waddr_accum29),
    .d0(wdata_accum29_ping), 
    .we0(wdata_en_ping29), 
    .q0(accum29_ping_q0_NC),
    .addr1(raddr_buffer29),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer29), 
    .clk(clk)
);

qadd adder_accum_ping30 (wdata_accum30, wdata_accum30_in, wdata_accum30_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum30_ping (
    .addr0(waddr_accum30),
    .d0(wdata_accum30_ping), 
    .we0(wdata_en_ping30), 
    .q0(accum30_ping_q0_NC),
    .addr1(raddr_buffer30),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer30), 
    .clk(clk)
);

qadd adder_accum_ping31 (wdata_accum31, wdata_accum31_in, wdata_accum31_ping);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum31_ping (
    .addr0(waddr_accum31),
    .d0(wdata_accum31_ping), 
    .we0(wdata_en_ping31), 
    .q0(accum31_ping_q0_NC),
    .addr1(raddr_buffer31),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer31), 
    .clk(clk)
);

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
wire [`DWIDTH-1:0] wdata_accum16_pong;
wire [`DWIDTH-1:0] wdata_accum17_pong;
wire [`DWIDTH-1:0] wdata_accum18_pong;
wire [`DWIDTH-1:0] wdata_accum19_pong;
wire [`DWIDTH-1:0] wdata_accum20_pong;
wire [`DWIDTH-1:0] wdata_accum21_pong;
wire [`DWIDTH-1:0] wdata_accum22_pong;
wire [`DWIDTH-1:0] wdata_accum23_pong;
wire [`DWIDTH-1:0] wdata_accum24_pong;
wire [`DWIDTH-1:0] wdata_accum25_pong;
wire [`DWIDTH-1:0] wdata_accum26_pong;
wire [`DWIDTH-1:0] wdata_accum27_pong;
wire [`DWIDTH-1:0] wdata_accum28_pong;
wire [`DWIDTH-1:0] wdata_accum29_pong;
wire [`DWIDTH-1:0] wdata_accum30_pong;
wire [`DWIDTH-1:0] wdata_accum31_pong;

////////////////////////////////////////////////
// PONG ACCUMULATORS
////////////////////////////////////////////////

qadd adder_accum_pong0 (wdata_accum0, wdata_accum0_in, wdata_accum0_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum0_pong (
    .addr0(waddr_accum0),
    .d0(wdata_accum0_pong), 
    .we0(wdata_en_pong0), 
    .q0(accum0_pong_q0_NC),
    .addr1(raddr_buffer0),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer0_pong), 
    .clk(clk)
);

qadd adder_accum_pong1 (wdata_accum1, wdata_accum1_in, wdata_accum1_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum1_pong (
    .addr0(waddr_accum1),
    .d0(wdata_accum1_pong), 
    .we0(wdata_en_pong1), 
    .q0(accum1_pong_q0_NC),
    .addr1(raddr_buffer1),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer1_pong), 
    .clk(clk)
);

qadd adder_accum_pong2 (wdata_accum2, wdata_accum2_in, wdata_accum2_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum2_pong (
    .addr0(waddr_accum2),
    .d0(wdata_accum2_pong), 
    .we0(wdata_en_pong2), 
    .q0(accum2_pong_q0_NC),
    .addr1(raddr_buffer2),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer2_pong), 
    .clk(clk)
);

qadd adder_accum_pong3 (wdata_accum3, wdata_accum3_in, wdata_accum3_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum3_pong (
    .addr0(waddr_accum3),
    .d0(wdata_accum3_pong), 
    .we0(wdata_en_pong3), 
    .q0(accum3_pong_q0_NC),
    .addr1(raddr_buffer3),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer3_pong), 
    .clk(clk)
);

qadd adder_accum_pong4 (wdata_accum4, wdata_accum4_in, wdata_accum4_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum4_pong (
    .addr0(waddr_accum4),
    .d0(wdata_accum4_pong), 
    .we0(wdata_en_pong4), 
    .q0(accum4_pong_q0_NC),
    .addr1(raddr_buffer4),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer4_pong), 
    .clk(clk)
);

qadd adder_accum_pong5 (wdata_accum5, wdata_accum5_in, wdata_accum5_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum5_pong (
    .addr0(waddr_accum5),
    .d0(wdata_accum5_pong), 
    .we0(wdata_en_pong5), 
    .q0(accum5_pong_q0_NC),
    .addr1(raddr_buffer5),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer5_pong), 
    .clk(clk)
);

qadd adder_accum_pong6 (wdata_accum6, wdata_accum6_in, wdata_accum6_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum6_pong (
    .addr0(waddr_accum6),
    .d0(wdata_accum6_pong), 
    .we0(wdata_en_pong6), 
    .q0(accum6_pong_q0_NC),
    .addr1(raddr_buffer6),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer6_pong), 
    .clk(clk)
);

qadd adder_accum_pong7 (wdata_accum7, wdata_accum7_in, wdata_accum7_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum7_pong (
    .addr0(waddr_accum7),
    .d0(wdata_accum7_pong), 
    .we0(wdata_en_pong7), 
    .q0(accum7_pong_q0_NC),
    .addr1(raddr_buffer7),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer7_pong), 
    .clk(clk)
);

qadd adder_accum_pong8 (wdata_accum8, wdata_accum8_in, wdata_accum8_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum8_pong (
    .addr0(waddr_accum8),
    .d0(wdata_accum8_pong), 
    .we0(wdata_en_pong8), 
    .q0(accum8_pong_q0_NC),
    .addr1(raddr_buffer8),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer8_pong), 
    .clk(clk)
);

qadd adder_accum_pong9 (wdata_accum9, wdata_accum9_in, wdata_accum9_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum9_pong (
    .addr0(waddr_accum9),
    .d0(wdata_accum9_pong), 
    .we0(wdata_en_pong9), 
    .q0(accum9_pong_q0_NC),
    .addr1(raddr_buffer9),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer9_pong), 
    .clk(clk)
);

qadd adder_accum_pong10 (wdata_accum10, wdata_accum10_in, wdata_accum10_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum10_pong (
    .addr0(waddr_accum10),
    .d0(wdata_accum10_pong), 
    .we0(wdata_en_pong10), 
    .q0(accum10_pong_q0_NC),
    .addr1(raddr_buffer10),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer10_pong), 
    .clk(clk)
);

qadd adder_accum_pong11 (wdata_accum11, wdata_accum11_in, wdata_accum11_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum11_pong (
    .addr0(waddr_accum11),
    .d0(wdata_accum11_pong), 
    .we0(wdata_en_pong11), 
    .q0(accum11_pong_q0_NC),
    .addr1(raddr_buffer11),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer11_pong), 
    .clk(clk)
);

qadd adder_accum_pong12 (wdata_accum12, wdata_accum12_in, wdata_accum12_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum12_pong (
    .addr0(waddr_accum12),
    .d0(wdata_accum12_pong), 
    .we0(wdata_en_pong12), 
    .q0(accum12_pong_q0_NC),
    .addr1(raddr_buffer12),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer12_pong), 
    .clk(clk)
);

qadd adder_accum_pong13 (wdata_accum13, wdata_accum13_in, wdata_accum13_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum13_pong (
    .addr0(waddr_accum13),
    .d0(wdata_accum13_pong), 
    .we0(wdata_en_pong13), 
    .q0(accum13_pong_q0_NC),
    .addr1(raddr_buffer13),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer13_pong), 
    .clk(clk)
);

qadd adder_accum_pong14 (wdata_accum14, wdata_accum14_in, wdata_accum14_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum14_pong (
    .addr0(waddr_accum14),
    .d0(wdata_accum14_pong), 
    .we0(wdata_en_pong14), 
    .q0(accum14_pong_q0_NC),
    .addr1(raddr_buffer14),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer14_pong), 
    .clk(clk)
);

qadd adder_accum_pong15 (wdata_accum15, wdata_accum15_in, wdata_accum15_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum15_pong (
    .addr0(waddr_accum15),
    .d0(wdata_accum15_pong), 
    .we0(wdata_en_pong15), 
    .q0(accum15_pong_q0_NC),
    .addr1(raddr_buffer15),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer15_pong), 
    .clk(clk)
);

qadd adder_accum_pong16 (wdata_accum16, wdata_accum16_in, wdata_accum16_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum16_pong (
    .addr0(waddr_accum16),
    .d0(wdata_accum16_pong), 
    .we0(wdata_en_pong16), 
    .q0(accum16_pong_q0_NC),
    .addr1(raddr_buffer16),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer16_pong), 
    .clk(clk)
);

qadd adder_accum_pong17 (wdata_accum17, wdata_accum17_in, wdata_accum17_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum17_pong (
    .addr0(waddr_accum17),
    .d0(wdata_accum17_pong), 
    .we0(wdata_en_pong17), 
    .q0(accum17_pong_q0_NC),
    .addr1(raddr_buffer17),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer17_pong), 
    .clk(clk)
);

qadd adder_accum_pong18 (wdata_accum18, wdata_accum18_in, wdata_accum18_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum18_pong (
    .addr0(waddr_accum18),
    .d0(wdata_accum18_pong), 
    .we0(wdata_en_pong18), 
    .q0(accum18_pong_q0_NC),
    .addr1(raddr_buffer18),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer18_pong), 
    .clk(clk)
);

qadd adder_accum_pong19 (wdata_accum19, wdata_accum19_in, wdata_accum19_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum19_pong (
    .addr0(waddr_accum19),
    .d0(wdata_accum19_pong), 
    .we0(wdata_en_pong19), 
    .q0(accum19_pong_q0_NC),
    .addr1(raddr_buffer19),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer19_pong), 
    .clk(clk)
);

qadd adder_accum_pong20 (wdata_accum20, wdata_accum20_in, wdata_accum20_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum20_pong (
    .addr0(waddr_accum20),
    .d0(wdata_accum20_pong), 
    .we0(wdata_en_pong20), 
    .q0(accum20_pong_q0_NC),
    .addr1(raddr_buffer20),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer20_pong), 
    .clk(clk)
);

qadd adder_accum_pong21 (wdata_accum21, wdata_accum21_in, wdata_accum21_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum21_pong (
    .addr0(waddr_accum21),
    .d0(wdata_accum21_pong), 
    .we0(wdata_en_pong21), 
    .q0(accum21_pong_q0_NC),
    .addr1(raddr_buffer21),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer21_pong), 
    .clk(clk)
);

qadd adder_accum_pong22 (wdata_accum22, wdata_accum22_in, wdata_accum22_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum22_pong (
    .addr0(waddr_accum22),
    .d0(wdata_accum22_pong), 
    .we0(wdata_en_pong22), 
    .q0(accum22_pong_q0_NC),
    .addr1(raddr_buffer22),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer22_pong), 
    .clk(clk)
);

qadd adder_accum_pong23 (wdata_accum23, wdata_accum23_in, wdata_accum23_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum23_pong (
    .addr0(waddr_accum23),
    .d0(wdata_accum23_pong), 
    .we0(wdata_en_pong23), 
    .q0(accum23_pong_q0_NC),
    .addr1(raddr_buffer23),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer23_pong), 
    .clk(clk)
);

qadd adder_accum_pong24 (wdata_accum24, wdata_accum24_in, wdata_accum24_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum24_pong (
    .addr0(waddr_accum24),
    .d0(wdata_accum24_pong), 
    .we0(wdata_en_pong24), 
    .q0(accum24_pong_q0_NC),
    .addr1(raddr_buffer24),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer24_pong), 
    .clk(clk)
);

qadd adder_accum_pong25 (wdata_accum25, wdata_accum25_in, wdata_accum25_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum25_pong (
    .addr0(waddr_accum25),
    .d0(wdata_accum25_pong), 
    .we0(wdata_en_pong25), 
    .q0(accum25_pong_q0_NC),
    .addr1(raddr_buffer25),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer25_pong), 
    .clk(clk)
);

qadd adder_accum_pong26 (wdata_accum26, wdata_accum26_in, wdata_accum26_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum26_pong (
    .addr0(waddr_accum26),
    .d0(wdata_accum26_pong), 
    .we0(wdata_en_pong26), 
    .q0(accum26_pong_q0_NC),
    .addr1(raddr_buffer26),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer26_pong), 
    .clk(clk)
);

qadd adder_accum_pong27 (wdata_accum27, wdata_accum27_in, wdata_accum27_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum27_pong (
    .addr0(waddr_accum27),
    .d0(wdata_accum27_pong), 
    .we0(wdata_en_pong27), 
    .q0(accum27_pong_q0_NC),
    .addr1(raddr_buffer27),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer27_pong), 
    .clk(clk)
);

qadd adder_accum_pong28 (wdata_accum28, wdata_accum28_in, wdata_accum28_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum28_pong (
    .addr0(waddr_accum28),
    .d0(wdata_accum28_pong), 
    .we0(wdata_en_pong28), 
    .q0(accum28_pong_q0_NC),
    .addr1(raddr_buffer28),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer28_pong), 
    .clk(clk)
);

qadd adder_accum_pong29 (wdata_accum29, wdata_accum29_in, wdata_accum29_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum29_pong (
    .addr0(waddr_accum29),
    .d0(wdata_accum29_pong), 
    .we0(wdata_en_pong29), 
    .q0(accum29_pong_q0_NC),
    .addr1(raddr_buffer29),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer29_pong), 
    .clk(clk)
);

qadd adder_accum_pong30 (wdata_accum30, wdata_accum30_in, wdata_accum30_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum30_pong (
    .addr0(waddr_accum30),
    .d0(wdata_accum30_pong), 
    .we0(wdata_en_pong30), 
    .q0(accum30_pong_q0_NC),
    .addr1(raddr_buffer30),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer30_pong), 
    .clk(clk)
);

qadd adder_accum_pong31 (wdata_accum31, wdata_accum31_in, wdata_accum31_pong);  
ram #(.AW(`AWIDTH), .MW(MWIDTH), .DW(`DWIDTH)) accum31_pong (
    .addr0(waddr_accum31),
    .d0(wdata_accum31_pong), 
    .we0(wdata_en_pong31), 
    .q0(accum31_pong_q0_NC),
    .addr1(raddr_buffer31),
    .d1(8'b0), 
    .we1(1'b0), 
    .q1(rdata_buffer31_pong), 
    .clk(clk)
);

endmodule

