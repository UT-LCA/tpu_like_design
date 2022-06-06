////////////////////////////////////////////////////////////////////////////////
// THIS FILE WAS AUTOMATICALLY GENERATED FROM generate_pool.v.mako
// DO NOT EDIT
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns
`define DWIDTH 8
`define AWIDTH 11
`define MEM_SIZE 2048

`define MAT_MUL_SIZE 32
`define MASK_WIDTH 32
`define LOG2_MAT_MUL_SIZE 5

`define BB_MAT_MUL_SIZE `MAT_MUL_SIZE
`define NUM_CYCLES_IN_MAC 3
`define MEM_ACCESS_LATENCY 1
`define REG_DATAWIDTH 32
`define REG_ADDRWIDTH 8
`define ADDR_STRIDE_WIDTH 8
`define MAX_BITS_POOL 3
`define VCS

module pooling(
    clk,
    resetn,
    start_pooling,
    pool_select,
    pool_norm_valid,
    enable_pool,
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
    pool0,
    pool1,
    pool2,
    pool3,
    pool4,
    pool5,
    pool6,
    pool7,
    pool8,
    pool9,
    pool10,
    pool11,
    pool12,
    pool13,
    pool14,
    pool15,
    pool16,
    pool17,
    pool18,
    pool19,
    pool20,
    pool21,
    pool22,
    pool23,
    pool24,
    pool25,
    pool26,
    pool27,
    pool28,
    pool29,
    pool30,
    pool31,
    matrix_size,
    filter_size
);

input clk;
input resetn;
input start_pooling;
input pool_select;
input enable_pool;
output pool_norm_valid;
output [`DWIDTH-1:0] pool0;
output [`DWIDTH-1:0] pool1;
output [`DWIDTH-1:0] pool2;
output [`DWIDTH-1:0] pool3;
output [`DWIDTH-1:0] pool4;
output [`DWIDTH-1:0] pool5;
output [`DWIDTH-1:0] pool6;
output [`DWIDTH-1:0] pool7;
output [`DWIDTH-1:0] pool8;
output [`DWIDTH-1:0] pool9;
output [`DWIDTH-1:0] pool10;
output [`DWIDTH-1:0] pool11;
output [`DWIDTH-1:0] pool12;
output [`DWIDTH-1:0] pool13;
output [`DWIDTH-1:0] pool14;
output [`DWIDTH-1:0] pool15;
output [`DWIDTH-1:0] pool16;
output [`DWIDTH-1:0] pool17;
output [`DWIDTH-1:0] pool18;
output [`DWIDTH-1:0] pool19;
output [`DWIDTH-1:0] pool20;
output [`DWIDTH-1:0] pool21;
output [`DWIDTH-1:0] pool22;
output [`DWIDTH-1:0] pool23;
output [`DWIDTH-1:0] pool24;
output [`DWIDTH-1:0] pool25;
output [`DWIDTH-1:0] pool26;
output [`DWIDTH-1:0] pool27;
output [`DWIDTH-1:0] pool28;
output [`DWIDTH-1:0] pool29;
output [`DWIDTH-1:0] pool30;
output [`DWIDTH-1:0] pool31;
input [`DWIDTH-1:0] rdata_accum0_pool;
input [`DWIDTH-1:0] rdata_accum1_pool;
input [`DWIDTH-1:0] rdata_accum2_pool;
input [`DWIDTH-1:0] rdata_accum3_pool;
input [`DWIDTH-1:0] rdata_accum4_pool;
input [`DWIDTH-1:0] rdata_accum5_pool;
input [`DWIDTH-1:0] rdata_accum6_pool;
input [`DWIDTH-1:0] rdata_accum7_pool;
input [`DWIDTH-1:0] rdata_accum8_pool;
input [`DWIDTH-1:0] rdata_accum9_pool;
input [`DWIDTH-1:0] rdata_accum10_pool;
input [`DWIDTH-1:0] rdata_accum11_pool;
input [`DWIDTH-1:0] rdata_accum12_pool;
input [`DWIDTH-1:0] rdata_accum13_pool;
input [`DWIDTH-1:0] rdata_accum14_pool;
input [`DWIDTH-1:0] rdata_accum15_pool;
input [`DWIDTH-1:0] rdata_accum16_pool;
input [`DWIDTH-1:0] rdata_accum17_pool;
input [`DWIDTH-1:0] rdata_accum18_pool;
input [`DWIDTH-1:0] rdata_accum19_pool;
input [`DWIDTH-1:0] rdata_accum20_pool;
input [`DWIDTH-1:0] rdata_accum21_pool;
input [`DWIDTH-1:0] rdata_accum22_pool;
input [`DWIDTH-1:0] rdata_accum23_pool;
input [`DWIDTH-1:0] rdata_accum24_pool;
input [`DWIDTH-1:0] rdata_accum25_pool;
input [`DWIDTH-1:0] rdata_accum26_pool;
input [`DWIDTH-1:0] rdata_accum27_pool;
input [`DWIDTH-1:0] rdata_accum28_pool;
input [`DWIDTH-1:0] rdata_accum29_pool;
input [`DWIDTH-1:0] rdata_accum30_pool;
input [`DWIDTH-1:0] rdata_accum31_pool;
output [`AWIDTH-1:0] raddr_accum0_pool;
output [`AWIDTH-1:0] raddr_accum1_pool;
output [`AWIDTH-1:0] raddr_accum2_pool;
output [`AWIDTH-1:0] raddr_accum3_pool;
output [`AWIDTH-1:0] raddr_accum4_pool;
output [`AWIDTH-1:0] raddr_accum5_pool;
output [`AWIDTH-1:0] raddr_accum6_pool;
output [`AWIDTH-1:0] raddr_accum7_pool;
output [`AWIDTH-1:0] raddr_accum8_pool;
output [`AWIDTH-1:0] raddr_accum9_pool;
output [`AWIDTH-1:0] raddr_accum10_pool;
output [`AWIDTH-1:0] raddr_accum11_pool;
output [`AWIDTH-1:0] raddr_accum12_pool;
output [`AWIDTH-1:0] raddr_accum13_pool;
output [`AWIDTH-1:0] raddr_accum14_pool;
output [`AWIDTH-1:0] raddr_accum15_pool;
output [`AWIDTH-1:0] raddr_accum16_pool;
output [`AWIDTH-1:0] raddr_accum17_pool;
output [`AWIDTH-1:0] raddr_accum18_pool;
output [`AWIDTH-1:0] raddr_accum19_pool;
output [`AWIDTH-1:0] raddr_accum20_pool;
output [`AWIDTH-1:0] raddr_accum21_pool;
output [`AWIDTH-1:0] raddr_accum22_pool;
output [`AWIDTH-1:0] raddr_accum23_pool;
output [`AWIDTH-1:0] raddr_accum24_pool;
output [`AWIDTH-1:0] raddr_accum25_pool;
output [`AWIDTH-1:0] raddr_accum26_pool;
output [`AWIDTH-1:0] raddr_accum27_pool;
output [`AWIDTH-1:0] raddr_accum28_pool;
output [`AWIDTH-1:0] raddr_accum29_pool;
output [`AWIDTH-1:0] raddr_accum30_pool;
output [`AWIDTH-1:0] raddr_accum31_pool;
input [`DWIDTH-1:0] matrix_size;
input [`DWIDTH-1:0] filter_size;

reg [`AWIDTH-1:0] raddr_accum1_pool;
reg [`AWIDTH-1:0] raddr_accum2_pool;
reg [`AWIDTH-1:0] raddr_accum3_pool;
reg [`AWIDTH-1:0] raddr_accum4_pool;
reg [`AWIDTH-1:0] raddr_accum5_pool;
reg [`AWIDTH-1:0] raddr_accum6_pool;
reg [`AWIDTH-1:0] raddr_accum7_pool;
reg [`AWIDTH-1:0] raddr_accum8_pool;
reg [`AWIDTH-1:0] raddr_accum9_pool;
reg [`AWIDTH-1:0] raddr_accum10_pool;
reg [`AWIDTH-1:0] raddr_accum11_pool;
reg [`AWIDTH-1:0] raddr_accum12_pool;
reg [`AWIDTH-1:0] raddr_accum13_pool;
reg [`AWIDTH-1:0] raddr_accum14_pool;
reg [`AWIDTH-1:0] raddr_accum15_pool;
reg [`AWIDTH-1:0] raddr_accum16_pool;
reg [`AWIDTH-1:0] raddr_accum17_pool;
reg [`AWIDTH-1:0] raddr_accum18_pool;
reg [`AWIDTH-1:0] raddr_accum19_pool;
reg [`AWIDTH-1:0] raddr_accum20_pool;
reg [`AWIDTH-1:0] raddr_accum21_pool;
reg [`AWIDTH-1:0] raddr_accum22_pool;
reg [`AWIDTH-1:0] raddr_accum23_pool;
reg [`AWIDTH-1:0] raddr_accum24_pool;
reg [`AWIDTH-1:0] raddr_accum25_pool;
reg [`AWIDTH-1:0] raddr_accum26_pool;
reg [`AWIDTH-1:0] raddr_accum27_pool;
reg [`AWIDTH-1:0] raddr_accum28_pool;
reg [`AWIDTH-1:0] raddr_accum29_pool;
reg [`AWIDTH-1:0] raddr_accum30_pool;
reg [`AWIDTH-1:0] raddr_accum31_pool;

reg [7:0] pool_count0;
reg [7:0] pool_count1;
reg [7:0] pool_count2;
reg [7:0] pool_count3;
reg [7:0] pool_count4;
reg [7:0] pool_count5;
reg [7:0] pool_count6;
reg [7:0] pool_count7;
reg [7:0] pool_count8;
reg [7:0] pool_count9;
reg [7:0] pool_count10;
reg [7:0] pool_count11;
reg [7:0] pool_count12;
reg [7:0] pool_count13;
reg [7:0] pool_count14;
reg [7:0] pool_count15;
reg [7:0] pool_count16;
reg [7:0] pool_count17;
reg [7:0] pool_count18;
reg [7:0] pool_count19;
reg [7:0] pool_count20;
reg [7:0] pool_count21;
reg [7:0] pool_count22;
reg [7:0] pool_count23;
reg [7:0] pool_count24;
reg [7:0] pool_count25;
reg [7:0] pool_count26;
reg [7:0] pool_count27;
reg [7:0] pool_count28;
reg [7:0] pool_count29;
reg [7:0] pool_count30;
reg [7:0] pool_count31;
reg [7:0] pool_count32;

wire [`DWIDTH-1:0] filter_size_int;
assign filter_size_int = (enable_pool)? filter_size : 8'b1;
wire [`DWIDTH-1:0] matrix_size_int;
assign matrix_size_int = (enable_pool)? matrix_size : 8'b1;

always @ (posedge clk) begin
    if (~resetn|~start_pooling) begin
        pool_count0 <= 0;
    end
    else if (pool_count0 == (filter_size_int*filter_size_int)) begin
        pool_count0 <= 1;
    end
    else if (start_pooling) begin
        pool_count0 <= pool_count0 + 1;
    end      
end

always @ (posedge clk) begin
    pool_count1 <= pool_count0;
    pool_count2 <= pool_count1;
    pool_count3 <= pool_count2;
    pool_count4 <= pool_count3;
    pool_count5 <= pool_count4;
    pool_count6 <= pool_count5;
    pool_count7 <= pool_count6;
    pool_count8 <= pool_count7;
    pool_count9 <= pool_count8;
    pool_count10 <= pool_count9;
    pool_count11 <= pool_count10;
    pool_count12 <= pool_count11;
    pool_count13 <= pool_count12;
    pool_count14 <= pool_count13;
    pool_count15 <= pool_count14;
    pool_count16 <= pool_count15;
    pool_count17 <= pool_count16;
    pool_count18 <= pool_count17;
    pool_count19 <= pool_count18;
    pool_count20 <= pool_count19;
    pool_count21 <= pool_count20;
    pool_count22 <= pool_count21;
    pool_count23 <= pool_count22;
    pool_count24 <= pool_count23;
    pool_count25 <= pool_count24;
    pool_count26 <= pool_count25;
    pool_count27 <= pool_count26;
    pool_count28 <= pool_count27;
    pool_count29 <= pool_count28;
    pool_count30 <= pool_count29;
    pool_count31 <= pool_count30;
    pool_count32 <= pool_count31;
end

wire [`DWIDTH-1:0] cmp0;
wire [`DWIDTH-1:0] cmp1;
wire [`DWIDTH-1:0] cmp2;
wire [`DWIDTH-1:0] cmp3;
wire [`DWIDTH-1:0] cmp4;
wire [`DWIDTH-1:0] cmp5;
wire [`DWIDTH-1:0] cmp6;
wire [`DWIDTH-1:0] cmp7;
wire [`DWIDTH-1:0] cmp8;
wire [`DWIDTH-1:0] cmp9;
wire [`DWIDTH-1:0] cmp10;
wire [`DWIDTH-1:0] cmp11;
wire [`DWIDTH-1:0] cmp12;
wire [`DWIDTH-1:0] cmp13;
wire [`DWIDTH-1:0] cmp14;
wire [`DWIDTH-1:0] cmp15;
wire [`DWIDTH-1:0] cmp16;
wire [`DWIDTH-1:0] cmp17;
wire [`DWIDTH-1:0] cmp18;
wire [`DWIDTH-1:0] cmp19;
wire [`DWIDTH-1:0] cmp20;
wire [`DWIDTH-1:0] cmp21;
wire [`DWIDTH-1:0] cmp22;
wire [`DWIDTH-1:0] cmp23;
wire [`DWIDTH-1:0] cmp24;
wire [`DWIDTH-1:0] cmp25;
wire [`DWIDTH-1:0] cmp26;
wire [`DWIDTH-1:0] cmp27;
wire [`DWIDTH-1:0] cmp28;
wire [`DWIDTH-1:0] cmp29;
wire [`DWIDTH-1:0] cmp30;
wire [`DWIDTH-1:0] cmp31;

reg [`DWIDTH-1:0] compare0;
reg [`DWIDTH-1:0] compare1;
reg [`DWIDTH-1:0] compare2;
reg [`DWIDTH-1:0] compare3;
reg [`DWIDTH-1:0] compare4;
reg [`DWIDTH-1:0] compare5;
reg [`DWIDTH-1:0] compare6;
reg [`DWIDTH-1:0] compare7;
reg [`DWIDTH-1:0] compare8;
reg [`DWIDTH-1:0] compare9;
reg [`DWIDTH-1:0] compare10;
reg [`DWIDTH-1:0] compare11;
reg [`DWIDTH-1:0] compare12;
reg [`DWIDTH-1:0] compare13;
reg [`DWIDTH-1:0] compare14;
reg [`DWIDTH-1:0] compare15;
reg [`DWIDTH-1:0] compare16;
reg [`DWIDTH-1:0] compare17;
reg [`DWIDTH-1:0] compare18;
reg [`DWIDTH-1:0] compare19;
reg [`DWIDTH-1:0] compare20;
reg [`DWIDTH-1:0] compare21;
reg [`DWIDTH-1:0] compare22;
reg [`DWIDTH-1:0] compare23;
reg [`DWIDTH-1:0] compare24;
reg [`DWIDTH-1:0] compare25;
reg [`DWIDTH-1:0] compare26;
reg [`DWIDTH-1:0] compare27;
reg [`DWIDTH-1:0] compare28;
reg [`DWIDTH-1:0] compare29;
reg [`DWIDTH-1:0] compare30;
reg [`DWIDTH-1:0] compare31;

wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg0;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg1;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg2;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg3;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg4;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg5;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg6;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg7;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg8;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg9;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg10;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg11;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg12;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg13;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg14;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg15;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg16;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg17;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg18;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg19;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg20;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg21;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg22;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg23;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg24;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg25;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg26;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg27;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg28;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg29;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg30;
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg31;

reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average0;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average1;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average2;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average3;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average4;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average5;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average6;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average7;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average8;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average9;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average10;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average11;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average12;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average13;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average14;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average15;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average16;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average17;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average18;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average19;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average20;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average21;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average22;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average23;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average24;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average25;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average26;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average27;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average28;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average29;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average30;
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] average31;

assign pool_norm_valid = (pool_count1 == (filter_size_int*filter_size_int))?1'b1:1'b0;

reg [`AWIDTH-1:0] x;
reg [`AWIDTH-1:0] y;
reg [`AWIDTH-1:0] k;
assign raddr_accum0_pool = (~resetn|~start_pooling)? 11'h7ff: ((matrix_size_int)*y + x + k);

always @(posedge clk) begin
    if(~resetn|~start_pooling) begin
        x<=0;
        y<=0;
        k<=0;
    end
    else if (y == (matrix_size_int-1) & x==(filter_size_int-1)) begin
        k<=k+filter_size_int;
        y<=0;
        x<=0;
    end
    else if (x==(filter_size_int-1)) begin
        y<=y+1;
        x<=0;
    end
    else if (start_pooling) begin
        x<=x+1;
    end
end

always @ (posedge clk) begin
    raddr_accum1_pool <= raddr_accum0_pool;
    raddr_accum2_pool <= raddr_accum1_pool;
    raddr_accum3_pool <= raddr_accum2_pool;
    raddr_accum4_pool <= raddr_accum3_pool;
    raddr_accum5_pool <= raddr_accum4_pool;
    raddr_accum6_pool <= raddr_accum5_pool;
    raddr_accum7_pool <= raddr_accum6_pool;
    raddr_accum8_pool <= raddr_accum7_pool;
    raddr_accum9_pool <= raddr_accum8_pool;
    raddr_accum10_pool <= raddr_accum9_pool;
    raddr_accum11_pool <= raddr_accum10_pool;
    raddr_accum12_pool <= raddr_accum11_pool;
    raddr_accum13_pool <= raddr_accum12_pool;
    raddr_accum14_pool <= raddr_accum13_pool;
    raddr_accum15_pool <= raddr_accum14_pool;
    raddr_accum16_pool <= raddr_accum15_pool;
    raddr_accum17_pool <= raddr_accum16_pool;
    raddr_accum18_pool <= raddr_accum17_pool;
    raddr_accum19_pool <= raddr_accum18_pool;
    raddr_accum20_pool <= raddr_accum19_pool;
    raddr_accum21_pool <= raddr_accum20_pool;
    raddr_accum22_pool <= raddr_accum21_pool;
    raddr_accum23_pool <= raddr_accum22_pool;
    raddr_accum24_pool <= raddr_accum23_pool;
    raddr_accum25_pool <= raddr_accum24_pool;
    raddr_accum26_pool <= raddr_accum25_pool;
    raddr_accum27_pool <= raddr_accum26_pool;
    raddr_accum28_pool <= raddr_accum27_pool;
    raddr_accum29_pool <= raddr_accum28_pool;
    raddr_accum30_pool <= raddr_accum29_pool;
    raddr_accum31_pool <= raddr_accum30_pool;
end

always @ (posedge clk) begin
    if (~resetn) begin
        compare0 <= 0;
    end
    else if (rdata_accum0_pool > cmp0) begin
        compare0 <= rdata_accum0_pool;
    end
    else if (rdata_accum0_pool < cmp0) begin
        compare0 <= cmp0;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average0 <= 0;
    end
    else begin
        average0 <= avg0 + rdata_accum0_pool;
    end
end

assign cmp0 = (pool_count0 == 1)? 0 : compare0;
assign avg0 = (pool_count0 == 1)? 0 : average0;
assign pool0 = (pool_count1 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare0 : average0/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare1 <= 0;
    end
    else if (rdata_accum1_pool > cmp1) begin
        compare1 <= rdata_accum1_pool;
    end
    else if (rdata_accum1_pool < cmp1) begin
        compare1 <= cmp1;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average1 <= 0;
    end
    else begin
        average1 <= avg1 + rdata_accum1_pool;
    end
end

assign cmp1 = (pool_count1 == 1)? 0 : compare1;
assign avg1 = (pool_count1 == 1)? 0 : average1;
assign pool1 = (pool_count2 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare1 : average1/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare2 <= 0;
    end
    else if (rdata_accum2_pool > cmp2) begin
        compare2 <= rdata_accum2_pool;
    end
    else if (rdata_accum2_pool < cmp2) begin
        compare2 <= cmp2;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average2 <= 0;
    end
    else begin
        average2 <= avg2 + rdata_accum2_pool;
    end
end

assign cmp2 = (pool_count2 == 1)? 0 : compare2;
assign avg2 = (pool_count2 == 1)? 0 : average2;
assign pool2 = (pool_count3 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare2 : average2/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare3 <= 0;
    end
    else if (rdata_accum3_pool > cmp3) begin
        compare3 <= rdata_accum3_pool;
    end
    else if (rdata_accum3_pool < cmp3) begin
        compare3 <= cmp3;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average3 <= 0;
    end
    else begin
        average3 <= avg3 + rdata_accum3_pool;
    end
end

assign cmp3 = (pool_count3 == 1)? 0 : compare3;
assign avg3 = (pool_count3 == 1)? 0 : average3;
assign pool3 = (pool_count4 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare3 : average3/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare4 <= 0;
    end
    else if (rdata_accum4_pool > cmp4) begin
        compare4 <= rdata_accum4_pool;
    end
    else if (rdata_accum4_pool < cmp4) begin
        compare4 <= cmp4;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average4 <= 0;
    end
    else begin
        average4 <= avg4 + rdata_accum4_pool;
    end
end

assign cmp4 = (pool_count4 == 1)? 0 : compare4;
assign avg4 = (pool_count4 == 1)? 0 : average4;
assign pool4 = (pool_count5 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare4 : average4/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare5 <= 0;
    end
    else if (rdata_accum5_pool > cmp5) begin
        compare5 <= rdata_accum5_pool;
    end
    else if (rdata_accum5_pool < cmp5) begin
        compare5 <= cmp5;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average5 <= 0;
    end
    else begin
        average5 <= avg5 + rdata_accum5_pool;
    end
end

assign cmp5 = (pool_count5 == 1)? 0 : compare5;
assign avg5 = (pool_count5 == 1)? 0 : average5;
assign pool5 = (pool_count6 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare5 : average5/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare6 <= 0;
    end
    else if (rdata_accum6_pool > cmp6) begin
        compare6 <= rdata_accum6_pool;
    end
    else if (rdata_accum6_pool < cmp6) begin
        compare6 <= cmp6;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average6 <= 0;
    end
    else begin
        average6 <= avg6 + rdata_accum6_pool;
    end
end

assign cmp6 = (pool_count6 == 1)? 0 : compare6;
assign avg6 = (pool_count6 == 1)? 0 : average6;
assign pool6 = (pool_count7 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare6 : average6/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare7 <= 0;
    end
    else if (rdata_accum7_pool > cmp7) begin
        compare7 <= rdata_accum7_pool;
    end
    else if (rdata_accum7_pool < cmp7) begin
        compare7 <= cmp7;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average7 <= 0;
    end
    else begin
        average7 <= avg7 + rdata_accum7_pool;
    end
end

assign cmp7 = (pool_count7 == 1)? 0 : compare7;
assign avg7 = (pool_count7 == 1)? 0 : average7;
assign pool7 = (pool_count8 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare7 : average7/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare8 <= 0;
    end
    else if (rdata_accum8_pool > cmp8) begin
        compare8 <= rdata_accum8_pool;
    end
    else if (rdata_accum8_pool < cmp8) begin
        compare8 <= cmp8;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average8 <= 0;
    end
    else begin
        average8 <= avg8 + rdata_accum8_pool;
    end
end

assign cmp8 = (pool_count8 == 1)? 0 : compare8;
assign avg8 = (pool_count8 == 1)? 0 : average8;
assign pool8 = (pool_count9 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare8 : average8/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare9 <= 0;
    end
    else if (rdata_accum9_pool > cmp9) begin
        compare9 <= rdata_accum9_pool;
    end
    else if (rdata_accum9_pool < cmp9) begin
        compare9 <= cmp9;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average9 <= 0;
    end
    else begin
        average9 <= avg9 + rdata_accum9_pool;
    end
end

assign cmp9 = (pool_count9 == 1)? 0 : compare9;
assign avg9 = (pool_count9 == 1)? 0 : average9;
assign pool9 = (pool_count10 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare9 : average9/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare10 <= 0;
    end
    else if (rdata_accum10_pool > cmp10) begin
        compare10 <= rdata_accum10_pool;
    end
    else if (rdata_accum10_pool < cmp10) begin
        compare10 <= cmp10;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average10 <= 0;
    end
    else begin
        average10 <= avg10 + rdata_accum10_pool;
    end
end

assign cmp10 = (pool_count10 == 1)? 0 : compare10;
assign avg10 = (pool_count10 == 1)? 0 : average10;
assign pool10 = (pool_count11 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare10 : average10/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare11 <= 0;
    end
    else if (rdata_accum11_pool > cmp11) begin
        compare11 <= rdata_accum11_pool;
    end
    else if (rdata_accum11_pool < cmp11) begin
        compare11 <= cmp11;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average11 <= 0;
    end
    else begin
        average11 <= avg11 + rdata_accum11_pool;
    end
end

assign cmp11 = (pool_count11 == 1)? 0 : compare11;
assign avg11 = (pool_count11 == 1)? 0 : average11;
assign pool11 = (pool_count12 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare11 : average11/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare12 <= 0;
    end
    else if (rdata_accum12_pool > cmp12) begin
        compare12 <= rdata_accum12_pool;
    end
    else if (rdata_accum12_pool < cmp12) begin
        compare12 <= cmp12;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average12 <= 0;
    end
    else begin
        average12 <= avg12 + rdata_accum12_pool;
    end
end

assign cmp12 = (pool_count12 == 1)? 0 : compare12;
assign avg12 = (pool_count12 == 1)? 0 : average12;
assign pool12 = (pool_count13 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare12 : average12/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare13 <= 0;
    end
    else if (rdata_accum13_pool > cmp13) begin
        compare13 <= rdata_accum13_pool;
    end
    else if (rdata_accum13_pool < cmp13) begin
        compare13 <= cmp13;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average13 <= 0;
    end
    else begin
        average13 <= avg13 + rdata_accum13_pool;
    end
end

assign cmp13 = (pool_count13 == 1)? 0 : compare13;
assign avg13 = (pool_count13 == 1)? 0 : average13;
assign pool13 = (pool_count14 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare13 : average13/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare14 <= 0;
    end
    else if (rdata_accum14_pool > cmp14) begin
        compare14 <= rdata_accum14_pool;
    end
    else if (rdata_accum14_pool < cmp14) begin
        compare14 <= cmp14;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average14 <= 0;
    end
    else begin
        average14 <= avg14 + rdata_accum14_pool;
    end
end

assign cmp14 = (pool_count14 == 1)? 0 : compare14;
assign avg14 = (pool_count14 == 1)? 0 : average14;
assign pool14 = (pool_count15 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare14 : average14/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare15 <= 0;
    end
    else if (rdata_accum15_pool > cmp15) begin
        compare15 <= rdata_accum15_pool;
    end
    else if (rdata_accum15_pool < cmp15) begin
        compare15 <= cmp15;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average15 <= 0;
    end
    else begin
        average15 <= avg15 + rdata_accum15_pool;
    end
end

assign cmp15 = (pool_count15 == 1)? 0 : compare15;
assign avg15 = (pool_count15 == 1)? 0 : average15;
assign pool15 = (pool_count16 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare15 : average15/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare16 <= 0;
    end
    else if (rdata_accum16_pool > cmp16) begin
        compare16 <= rdata_accum16_pool;
    end
    else if (rdata_accum16_pool < cmp16) begin
        compare16 <= cmp16;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average16 <= 0;
    end
    else begin
        average16 <= avg16 + rdata_accum16_pool;
    end
end

assign cmp16 = (pool_count16 == 1)? 0 : compare16;
assign avg16 = (pool_count16 == 1)? 0 : average16;
assign pool16 = (pool_count17 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare16 : average16/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare17 <= 0;
    end
    else if (rdata_accum17_pool > cmp17) begin
        compare17 <= rdata_accum17_pool;
    end
    else if (rdata_accum17_pool < cmp17) begin
        compare17 <= cmp17;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average17 <= 0;
    end
    else begin
        average17 <= avg17 + rdata_accum17_pool;
    end
end

assign cmp17 = (pool_count17 == 1)? 0 : compare17;
assign avg17 = (pool_count17 == 1)? 0 : average17;
assign pool17 = (pool_count18 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare17 : average17/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare18 <= 0;
    end
    else if (rdata_accum18_pool > cmp18) begin
        compare18 <= rdata_accum18_pool;
    end
    else if (rdata_accum18_pool < cmp18) begin
        compare18 <= cmp18;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average18 <= 0;
    end
    else begin
        average18 <= avg18 + rdata_accum18_pool;
    end
end

assign cmp18 = (pool_count18 == 1)? 0 : compare18;
assign avg18 = (pool_count18 == 1)? 0 : average18;
assign pool18 = (pool_count19 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare18 : average18/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare19 <= 0;
    end
    else if (rdata_accum19_pool > cmp19) begin
        compare19 <= rdata_accum19_pool;
    end
    else if (rdata_accum19_pool < cmp19) begin
        compare19 <= cmp19;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average19 <= 0;
    end
    else begin
        average19 <= avg19 + rdata_accum19_pool;
    end
end

assign cmp19 = (pool_count19 == 1)? 0 : compare19;
assign avg19 = (pool_count19 == 1)? 0 : average19;
assign pool19 = (pool_count20 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare19 : average19/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare20 <= 0;
    end
    else if (rdata_accum20_pool > cmp20) begin
        compare20 <= rdata_accum20_pool;
    end
    else if (rdata_accum20_pool < cmp20) begin
        compare20 <= cmp20;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average20 <= 0;
    end
    else begin
        average20 <= avg20 + rdata_accum20_pool;
    end
end

assign cmp20 = (pool_count20 == 1)? 0 : compare20;
assign avg20 = (pool_count20 == 1)? 0 : average20;
assign pool20 = (pool_count21 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare20 : average20/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare21 <= 0;
    end
    else if (rdata_accum21_pool > cmp21) begin
        compare21 <= rdata_accum21_pool;
    end
    else if (rdata_accum21_pool < cmp21) begin
        compare21 <= cmp21;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average21 <= 0;
    end
    else begin
        average21 <= avg21 + rdata_accum21_pool;
    end
end

assign cmp21 = (pool_count21 == 1)? 0 : compare21;
assign avg21 = (pool_count21 == 1)? 0 : average21;
assign pool21 = (pool_count22 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare21 : average21/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare22 <= 0;
    end
    else if (rdata_accum22_pool > cmp22) begin
        compare22 <= rdata_accum22_pool;
    end
    else if (rdata_accum22_pool < cmp22) begin
        compare22 <= cmp22;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average22 <= 0;
    end
    else begin
        average22 <= avg22 + rdata_accum22_pool;
    end
end

assign cmp22 = (pool_count22 == 1)? 0 : compare22;
assign avg22 = (pool_count22 == 1)? 0 : average22;
assign pool22 = (pool_count23 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare22 : average22/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare23 <= 0;
    end
    else if (rdata_accum23_pool > cmp23) begin
        compare23 <= rdata_accum23_pool;
    end
    else if (rdata_accum23_pool < cmp23) begin
        compare23 <= cmp23;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average23 <= 0;
    end
    else begin
        average23 <= avg23 + rdata_accum23_pool;
    end
end

assign cmp23 = (pool_count23 == 1)? 0 : compare23;
assign avg23 = (pool_count23 == 1)? 0 : average23;
assign pool23 = (pool_count24 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare23 : average23/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare24 <= 0;
    end
    else if (rdata_accum24_pool > cmp24) begin
        compare24 <= rdata_accum24_pool;
    end
    else if (rdata_accum24_pool < cmp24) begin
        compare24 <= cmp24;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average24 <= 0;
    end
    else begin
        average24 <= avg24 + rdata_accum24_pool;
    end
end

assign cmp24 = (pool_count24 == 1)? 0 : compare24;
assign avg24 = (pool_count24 == 1)? 0 : average24;
assign pool24 = (pool_count25 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare24 : average24/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare25 <= 0;
    end
    else if (rdata_accum25_pool > cmp25) begin
        compare25 <= rdata_accum25_pool;
    end
    else if (rdata_accum25_pool < cmp25) begin
        compare25 <= cmp25;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average25 <= 0;
    end
    else begin
        average25 <= avg25 + rdata_accum25_pool;
    end
end

assign cmp25 = (pool_count25 == 1)? 0 : compare25;
assign avg25 = (pool_count25 == 1)? 0 : average25;
assign pool25 = (pool_count26 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare25 : average25/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare26 <= 0;
    end
    else if (rdata_accum26_pool > cmp26) begin
        compare26 <= rdata_accum26_pool;
    end
    else if (rdata_accum26_pool < cmp26) begin
        compare26 <= cmp26;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average26 <= 0;
    end
    else begin
        average26 <= avg26 + rdata_accum26_pool;
    end
end

assign cmp26 = (pool_count26 == 1)? 0 : compare26;
assign avg26 = (pool_count26 == 1)? 0 : average26;
assign pool26 = (pool_count27 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare26 : average26/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare27 <= 0;
    end
    else if (rdata_accum27_pool > cmp27) begin
        compare27 <= rdata_accum27_pool;
    end
    else if (rdata_accum27_pool < cmp27) begin
        compare27 <= cmp27;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average27 <= 0;
    end
    else begin
        average27 <= avg27 + rdata_accum27_pool;
    end
end

assign cmp27 = (pool_count27 == 1)? 0 : compare27;
assign avg27 = (pool_count27 == 1)? 0 : average27;
assign pool27 = (pool_count28 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare27 : average27/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare28 <= 0;
    end
    else if (rdata_accum28_pool > cmp28) begin
        compare28 <= rdata_accum28_pool;
    end
    else if (rdata_accum28_pool < cmp28) begin
        compare28 <= cmp28;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average28 <= 0;
    end
    else begin
        average28 <= avg28 + rdata_accum28_pool;
    end
end

assign cmp28 = (pool_count28 == 1)? 0 : compare28;
assign avg28 = (pool_count28 == 1)? 0 : average28;
assign pool28 = (pool_count29 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare28 : average28/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare29 <= 0;
    end
    else if (rdata_accum29_pool > cmp29) begin
        compare29 <= rdata_accum29_pool;
    end
    else if (rdata_accum29_pool < cmp29) begin
        compare29 <= cmp29;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average29 <= 0;
    end
    else begin
        average29 <= avg29 + rdata_accum29_pool;
    end
end

assign cmp29 = (pool_count29 == 1)? 0 : compare29;
assign avg29 = (pool_count29 == 1)? 0 : average29;
assign pool29 = (pool_count30 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare29 : average29/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare30 <= 0;
    end
    else if (rdata_accum30_pool > cmp30) begin
        compare30 <= rdata_accum30_pool;
    end
    else if (rdata_accum30_pool < cmp30) begin
        compare30 <= cmp30;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average30 <= 0;
    end
    else begin
        average30 <= avg30 + rdata_accum30_pool;
    end
end

assign cmp30 = (pool_count30 == 1)? 0 : compare30;
assign avg30 = (pool_count30 == 1)? 0 : average30;
assign pool30 = (pool_count31 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare30 : average30/(filter_size_int*filter_size_int)) : 8'b0;

always @ (posedge clk) begin
    if (~resetn) begin
        compare31 <= 0;
    end
    else if (rdata_accum31_pool > cmp31) begin
        compare31 <= rdata_accum31_pool;
    end
    else if (rdata_accum31_pool < cmp31) begin
        compare31 <= cmp31;
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        average31 <= 0;
    end
    else begin
        average31 <= avg31 + rdata_accum31_pool;
    end
end

assign cmp31 = (pool_count31 == 1)? 0 : compare31;
assign avg31 = (pool_count31 == 1)? 0 : average31;
assign pool31 = (pool_count32 == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare31 : average31/(filter_size_int*filter_size_int)) : 8'b0;


endmodule