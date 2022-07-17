############################################################
## Generator file for pooling.v
############################################################

<%!
    import math
%>\
`timescale 1ns/1ns
`define DWIDTH 8
`define AWIDTH 11
`define MEM_SIZE 2048
<% 
    mat_mul_size = int(matmul_size)
    log2_mat_mul_size = int(math.log2(mat_mul_size))
%>\

`define MAT_MUL_SIZE ${mat_mul_size}
`define MASK_WIDTH ${mat_mul_size}
`define LOG2_MAT_MUL_SIZE ${log2_mat_mul_size}

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
    % for i in range(mat_mul_size):
    rdata_accum${i}_pool,
    % endfor
    % for i in range(mat_mul_size):
    raddr_accum${i}_pool,
    % endfor
    % for i in range(mat_mul_size):
    pool${i},
    % endfor
    matrix_size,
    filter_size
);

input clk;
input resetn;
input start_pooling;
input pool_select;
input enable_pool;
output pool_norm_valid;
% for i in range(mat_mul_size):
output [`DWIDTH-1:0] pool${i};
% endfor
% for i in range(mat_mul_size):
input [`DWIDTH-1:0] rdata_accum${i}_pool;
% endfor
% for i in range(mat_mul_size):
output [`AWIDTH-1:0] raddr_accum${i}_pool;
% endfor
input [`DWIDTH-1:0] matrix_size;
input [`DWIDTH-1:0] filter_size;

% for i in range(1,mat_mul_size):
reg [`AWIDTH-1:0] raddr_accum${i}_pool;
% endfor

% for i in range(mat_mul_size+1):
reg [7:0] pool_count${i};
% endfor

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
    % for i in range(mat_mul_size):
    pool_count${i+1} <= pool_count${i};
    % endfor
end

% for i in range(mat_mul_size):
wire [`DWIDTH-1:0] cmp${i};
% endfor

% for i in range(mat_mul_size):
reg [`DWIDTH-1:0] compare${i};
% endfor

% for i in range(mat_mul_size):
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] avg${i};
% endfor

% for i in range(mat_mul_size):
reg [`DWIDTH+`MAT_MUL_SIZE-1:0] avg${i}_int;
% endfor

% for i in range(mat_mul_size):
wire [`DWIDTH+`MAT_MUL_SIZE-1:0] average${i};
% endfor

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
    % for i in range(1,mat_mul_size):
    raddr_accum${i}_pool <= raddr_accum${i-1}_pool;
    % endfor
end

% for i in range(mat_mul_size):
always @ (posedge clk) begin
    if (~resetn) begin
        compare${i} <= 0;
    end
    else if (rdata_accum${i}_pool > cmp${i}) begin
        compare${i} <= rdata_accum${i}_pool;
    end
    else if (rdata_accum${i}_pool < cmp${i}) begin
        compare${i} <= cmp${i};
    end
end 

always @ (posedge clk) begin
    if (~resetn) begin
        avg${i}_int <= 0;
    end
    else begin
        avg${i}_int <= avg${i} + rdata_accum${i}_pool;
    end
end

assign cmp${i} = (pool_count${i} == 1)? 0 : compare${i};
assign avg${i} = (pool_count${i} == 1)? 0 : avg${i}_int;
assign average${i} = (filter_size_int == 8'b1)? avg${i}_int : (filter_size_int == 8'b10)? avg${i}_int >> 2 : (filter_size_int == 8'b11)? avg${i}_int >> 3 : (filter_size_int == 8'b100)? avg${i}_int >> 4 : avg${i}_int;

wire [`DWIDTH-1:0] pool${i}_wire;
assign pool${i}_wire = (pool_count${i+1} == (filter_size_int*filter_size_int))? ((pool_select == 0)? compare${i} : average${i}) : 8'b0;
always @(posedge clk) begin
 pool${i} <= pool${i}_wire;
end

% endfor

endmodule

