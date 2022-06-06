////////////////////////////////////////////////////////////////////////////////
// THIS FILE WAS AUTOMATICALLY GENERATED FROM generate_pool.v.mako
// DO NOT EDIT
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns
`define DWIDTH 8
`define AWIDTH 11
`define MEM_SIZE 2048

`define MAT_MUL_SIZE 16
`define MASK_WIDTH 16
`define LOG2_MAT_MUL_SIZE 4

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


endmodule