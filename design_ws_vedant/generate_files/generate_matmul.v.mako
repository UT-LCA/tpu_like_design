############################################################
## Generator file for ws_matmul.v
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

module matmul_${mat_mul_size}x${mat_mul_size}_systolic(
    clk,
    reset,
    pe_reset,
    start_mat_mul,
    done_mat_mul,
    num_matrices_A,
    num_matrices_B,
    address_mat_a,
    address_mat_b,
    address_stride_a,
    address_stride_b,
    a_data,
    b_data,
    a_data_in,  // Data values coming in from previous matmul - systolic connections
    b_data_in,  // Data values coming in from previous matmul - weight matrix 
    c_data_in,  // Data values coming in from previous matmul - systolic shifting
    c_data_out, // Data values going out to next matmul - systolic shifting
    a_data_out,
    b_data_out,
    a_addr,
    b_addr,
    c_addr,
    c_data_available,
    % for i in range(mat_mul_size):
    matrixC${mat_mul_size-1}_${i},
    % endfor
    validity_mask_a_rows,
    validity_mask_a_cols_b_rows,
    validity_mask_b_cols,
    a_loc,
    b_loc
);

input clk;
input reset;
input pe_reset;
input start_mat_mul;
output done_mat_mul;
input [31:0] num_matrices_A; // Number of ${mat_mul_size}x${mat_mul_size} matrices the input matrix can be divided into
input [31:0] num_matrices_B; // Number of ${mat_mul_size}x${mat_mul_size} matrices the weight matrix can be divided into
input [`AWIDTH-1:0] address_mat_a;
input [`AWIDTH-1:0] address_mat_b;
input [`ADDR_STRIDE_WIDTH-1:0] address_stride_a;
input [`ADDR_STRIDE_WIDTH-1:0] address_stride_b;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_out;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out;
output [`AWIDTH-1:0] a_addr;
output [`AWIDTH-1:0] b_addr;
output [`AWIDTH-1:0] c_addr;
output c_data_available;
% for i in range(mat_mul_size):
output [`DWIDTH-1:0] matrixC${mat_mul_size-1}_${i};
% endfor
input [`MASK_WIDTH-1:0] validity_mask_a_rows;
input [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows;
input [`MASK_WIDTH-1:0] validity_mask_b_cols;
input [${2*mat_mul_size-1}:0] a_loc;
input [${2*mat_mul_size-1}:0] b_loc;

//////////////////////////////////////////////////////////////////////////
// Logic for clock counting and when to assert done
//////////////////////////////////////////////////////////////////////////

reg done_mat_mul;
// This is set to ${2*mat_mul_size-1} bits in accordance with the previous simulations.
// In general, a systolic multiplier takes 4*N-2+P cycles, where N is the size 
// of the matmul and P is the number of pipeline stages in the MAC block.
reg [${2*mat_mul_size-1}:0] clk_cnt;

// Finding out number of cycles to assert matmul done.
// When we have to save the outputs to accumulators, then we don't need to
// shift out data. So, we can assert done_mat_mul early.
// Note: the count expression used to contain "num_matrices_${mat_mul_size}x${mat_mul_size}*8", but 
// to avoid multiplication, we now use "num_matrices_${mat_mul_size}x${mat_mul_size} << 3"
wire [${2*mat_mul_size-1}:0] clk_cnt_for_done;
assign clk_cnt_for_done = 
((num_matrices_A << (2*`LOG2_MAT_MUL_SIZE -1)) + 1  + `NUM_CYCLES_IN_MAC) ;  

always @(posedge clk) begin
if (reset || ~start_mat_mul) begin
    clk_cnt <= 0;
    done_mat_mul <= 0;
end
else if (clk_cnt == clk_cnt_for_done) begin
    done_mat_mul <= 1;
    clk_cnt <= clk_cnt + 1;
end
else if (done_mat_mul == 0) begin
    clk_cnt <= clk_cnt + 1;
end    
else begin
    done_mat_mul <= 0;
    clk_cnt <= clk_cnt + 1;
end
end

% for i in range(mat_mul_size):
wire [`DWIDTH-1:0] a${i}_data;
% endfor
% for i in range(mat_mul_size):
wire [`DWIDTH-1:0] b${i}_data;
% endfor
% for i in range(1,mat_mul_size):
%   for j in range(1,i+1):
wire [`DWIDTH-1:0] a${i}_data_delayed_${j};
%   endfor
% endfor
% for i in range(1,mat_mul_size):
%   for j in range(1,i+1):
wire [`DWIDTH-1:0] b${i}_data_delayed_${j};
%   endfor
% endfor

reg b_data_sel; // MUX select for Ping-Pong buffers containing the weights in the matmul
reg b_data_valid_ping;
reg b_data_valid_pong;

always @ (posedge clk) begin
	if ((clk_cnt >= 16'd1 && clk_cnt <= 16'd8)||(clk_cnt >= 16'd17 && clk_cnt <= 16'd24))
		b_data_valid_pong <= 1'b1;
	else 
		b_data_valid_pong <= 1'b0;
end

always @ (posedge clk) begin
	if ((clk_cnt >= 16'd9 && clk_cnt <= 16'd16))
		b_data_valid_ping <= 1'b1;
	else 
		b_data_valid_ping <= 1'b0;
end

always @ (posedge clk) begin
	if ((clk_cnt >= 16'd10 && clk_cnt <= 16'd17)||(clk_cnt >= 16'd26 && clk_cnt <= 16'd33))
		b_data_sel <= 1'b1;
	else 
		b_data_sel <= 1'b0;
end

//////////////////////////////////////////////////////////////////////////
// Instantiation of systolic data setup
//////////////////////////////////////////////////////////////////////////
systolic_data_setup u_systolic_data_setup(
    .clk(clk),
    .reset(reset),
    .start_mat_mul(start_mat_mul),
    .a_addr(a_addr),
    .b_addr(b_addr),
    .address_mat_a(address_mat_a),
    .address_mat_b(address_mat_b),
    .address_stride_a(address_stride_a),
    .address_stride_b(address_stride_b),
    .a_data(a_data),
    .b_data(b_data),
    .clk_cnt(clk_cnt),
    .a0_data(a0_data),
    % for i in range(1,mat_mul_size):
    .a${i}_data_delayed_${i}(a${i}_data_delayed_${i}),
    % endfor
    .b0_data(b0_data),
    % for i in range(1,mat_mul_size):
    .b${i}_data_delayed_${i}(b${i}_data_delayed_${i}),
    % endfor
    .validity_mask_a_rows(validity_mask_a_rows),
    .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
    .validity_mask_b_cols(validity_mask_b_cols),
    .num_matrices_A(num_matrices_A),
    .num_matrices_B(num_matrices_B),
    .a_loc(a_loc),
    .b_loc(b_loc)
);

//////////////////////////////////////////////////////////////////////////
// Logic to mux data_in coming from neighboring matmuls
//////////////////////////////////////////////////////////////////////////
% for i in range(mat_mul_size):
wire [`DWIDTH-1:0] a${i};
% endfor
% for i in range(mat_mul_size):
wire [`DWIDTH-1:0] b${i};
% endfor
% for i in range(mat_mul_size):
wire [`DWIDTH-1:0] c${i};
% endfor

% for i in range(mat_mul_size):
wire [`DWIDTH-1:0] a${i}_data_in;
% endfor
assign a0_data_in = a_data_in[`DWIDTH-1:0];
% for i in range(1,mat_mul_size):
assign a${i}_data_in = a_data_in[${i+1}*`DWIDTH-1:${i}*`DWIDTH];
% endfor

% for i in range(mat_mul_size):
wire [`DWIDTH-1:0] b${i}_data_in;
% endfor
assign b0_data_in = b_data_in[`DWIDTH-1:0];
% for i in range(1,mat_mul_size):
assign b${i}_data_in = b_data_in[${i+1}*`DWIDTH-1:${i}*`DWIDTH];
% endfor

// If b_loc is 0, that means this matmul block is on the top-row of the
// final large matmul. In that case, b will take inputs from mem.
// If b_loc != 0, that means this matmul block is not on the top-row of the
// final large matmul. In that case, b will take inputs from the matmul on top
// of this one.
assign a0 = (b_loc==0) ? a0_data           : a0_data_in;
% for i in range(1,mat_mul_size):
assign a${i} = (b_loc==0) ? a${i}_data_delayed_${i} : a${i}_data_in;
% endfor

/// If a_loc is 0, that means this matmul block is on the left-col of the
// final large matmul. In that case, a will take inputs from mem.
// If a_loc != 0, that means this matmul block is not on the left-col of the
// final large matmul. In that case, a will take inputs from the matmul on left
// of this one.
assign b0 = (a_loc==0) ? b0_data           : b0_data_in;
% for i in range(1,mat_mul_size):
assign b${i} = (a_loc==0) ? b${i}_data_delayed_${i} : b${i}_data_in;
% endfor

assign c0 = c_data_in[`DWIDTH-1:0];
% for i in range(1,mat_mul_size):
assign c${i} = c_data_in[${i+1}*`DWIDTH-1:${i}*`DWIDTH];
% endfor

% for i in range(mat_mul_size):
%   for j in range(mat_mul_size):
wire [`DWIDTH-1:0] matrixC${i}_${j};
%   endfor
% endfor

//////////////////////////////////////////////////////////////////////////
// Instantiations of the actual PEs
//////////////////////////////////////////////////////////////////////////
systolic_pe_matrix u_systolic_pe_matrix(
    .reset(reset),
    .clk(clk),
    .pe_reset(pe_reset),
    .b_data_sel(b_data_sel),
    .b_data_valid_ping(b_data_valid_ping), 
    .b_data_valid_pong(b_data_valid_pong),
    % for i in range(mat_mul_size):
    .a${i}(a${i}),
    % endfor
    % for i in range(mat_mul_size):
    .b${i}(b${i}),
    % endfor
    % for i in range(mat_mul_size):
    .c${i}(c${i}),
    % endfor
    % for i in range(mat_mul_size):
    %   for j in range(mat_mul_size):
    .matrixC${i}_${j}(matrixC${i}_${j}),
    %   endfor
    % endfor
    .a_data_out(a_data_out),
    .b_data_out(b_data_out)
);
  
wire c_data_available;
  
assign c_data_available = (clk_cnt > (`LOG2_MAT_MUL_SIZE-1+(`MAT_MUL_SIZE << 1)) & clk_cnt <= ((`LOG2_MAT_MUL_SIZE+(`MAT_MUL_SIZE << 1)) + (num_matrices_A << `LOG2_MAT_MUL_SIZE)-1));

endmodule

//////////////////////////////////////////////////////////////////////////
// Systolic data setup
//////////////////////////////////////////////////////////////////////////
module systolic_data_setup(
    clk,
    reset,
    start_mat_mul,
    a_addr,
    b_addr,
    address_mat_a,
    address_mat_b,
    address_stride_a,
    address_stride_b,
    a_data,
    b_data,
    clk_cnt,
    a0_data,
    % for i in range(1,mat_mul_size):
    a${i}_data_delayed_${i},
    % endfor
    b0_data,
    % for i in range(1,mat_mul_size):
    b${i}_data_delayed_${i},
    % endfor
    validity_mask_a_rows,
    validity_mask_a_cols_b_rows,
    validity_mask_b_cols,
    num_matrices_A,
    num_matrices_B,
    a_loc,
    b_loc 
);

input clk;
input reset;
input start_mat_mul;
output [`AWIDTH-1:0] a_addr;
output [`AWIDTH-1:0] b_addr;
input [`AWIDTH-1:0] address_mat_a;
input [`AWIDTH-1:0] address_mat_b;
input [`ADDR_STRIDE_WIDTH-1:0] address_stride_a;
input [`ADDR_STRIDE_WIDTH-1:0] address_stride_b;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data;
input [${2*mat_mul_size-1}:0] clk_cnt;
output [`DWIDTH-1:0] a0_data;
% for i in range(1,mat_mul_size):
output [`DWIDTH-1:0] a${i}_data_delayed_${i};
% endfor
output [`DWIDTH-1:0] b0_data;
% for i in range(1,mat_mul_size):
output [`DWIDTH-1:0] b${i}_data_delayed_${i};
% endfor
input [`MASK_WIDTH-1:0] validity_mask_a_rows;
input [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows;
input [`MASK_WIDTH-1:0] validity_mask_b_cols;
input [31:0] num_matrices_A;
input [31:0] num_matrices_B;
input [${2*mat_mul_size-1}:0] a_loc;
input [${2*mat_mul_size-1}:0] b_loc;

% for i in range(mat_mul_size):
wire [`DWIDTH-1:0] a${i}_data;
% endfor
% for i in range(mat_mul_size):
wire [`DWIDTH-1:0] b${i}_data;
% endfor

wire a_data_valid; // flag that tells whether the data from memory is valid
wire b_data_valid; // flag that tells whether the data from memory is valid

//////////////////////////////////////////////////////////////////////////
// Logic to generate addresses to BRAM A
//////////////////////////////////////////////////////////////////////////

reg [`AWIDTH-1:0] a_addr;
reg a_mem_access; // flag that tells whether the matmul is trying to access memory or not
  
always @(posedge clk) begin     
if ((reset || ~start_mat_mul) || (clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)+`MAT_MUL_SIZE+(num_matrices_A << `LOG2_MAT_MUL_SIZE))) begin
        a_addr <= address_mat_a-address_stride_a;
        a_mem_access <= 0; 
end
else if ((clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)+`MAT_MUL_SIZE) && (clk_cnt < (a_loc<<`LOG2_MAT_MUL_SIZE)+`MAT_MUL_SIZE+(num_matrices_A << `LOG2_MAT_MUL_SIZE))) begin
        a_addr <= a_addr + address_stride_a;
        a_mem_access <= 1;
end
end


//////////////////////////////////////////////////////////////////////////
// Logic to generate valid signals for data coming from BRAM A
//////////////////////////////////////////////////////////////////////////

reg [${2*mat_mul_size-1}:0] a_mem_access_counter;

always @(posedge clk) begin
    if (reset || ~start_mat_mul) begin
        a_mem_access_counter <= 0;
    end
    else if (a_mem_access == 1) begin
        a_mem_access_counter <= a_mem_access_counter + 1;  
    end
    else begin
        a_mem_access_counter <= 0;
    end
end
  
assign a_data_valid = 
       ((validity_mask_a_cols_b_rows[0]==1'b0 && a_mem_access_counter==1) ||
        % for i in range(1,mat_mul_size-1):
        (validity_mask_a_cols_b_rows[${i}]==1'b0 && a_mem_access_counter==${i+1}) ||
        % endfor
        (validity_mask_a_cols_b_rows[${mat_mul_size-1}]==1'b0 && a_mem_access_counter==${mat_mul_size})) ?
        1'b0 : (a_mem_access_counter >= `MEM_ACCESS_LATENCY);

//////////////////////////////////////////////////////////////////////////
// Logic to delay certain parts of the data received from BRAM A (systolic data setup)
//////////////////////////////////////////////////////////////////////////

// Slice data into chunks and qualify it with whether it is valid or not
assign a0_data = a_data[`DWIDTH-1:0] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[0]}};
% for i in range(1,mat_mul_size):
assign a${i}_data = a_data[${i+1}*`DWIDTH-1:${i}*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[${i}]}};
% endfor

// For larger matmuls, more such delaying flops will be needed
% for i in range(1,mat_mul_size):
%   for j in range(1,i+1):
reg [`DWIDTH-1:0] a${i}_data_delayed_${j};
%   endfor
% endfor

always @(posedge clk) begin
  if (reset || ~start_mat_mul || clk_cnt==0) begin
  % for i in range(1,mat_mul_size):
  %     for j in range(1,i+1):
    a${i}_data_delayed_${j} <= 0;
  %     endfor
  % endfor
  end
  else begin
  % for i in range(mat_mul_size):
  %     for j in range (1,i+1):
  %         if (j == 1):
    a${i}_data_delayed_${j} <= a${i}_data;
  %         else:
    a${i}_data_delayed_${j} <= a${i}_data_delayed_${j-1};
  %         endif
  %     endfor
  % endfor
  end
end

//////////////////////////////////////////////////////////////////////////
// Logic to generate addresses to BRAM B
//////////////////////////////////////////////////////////////////////////

reg [`AWIDTH-1:0] b_addr;
reg b_mem_access; // flag that tells whether the matmul is trying to access memory or not
 
always @(posedge clk) begin  
    if ((reset || ~start_mat_mul) || (clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)+num_matrices_B << `LOG2_MAT_MUL_SIZE)) begin
        b_addr <= address_mat_b - address_stride_b;
        b_mem_access <= 0;
    end 
    else if ((clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)) && (clk_cnt < (b_loc<<`LOG2_MAT_MUL_SIZE)+num_matrices_B << `LOG2_MAT_MUL_SIZE)) begin
        b_addr <= b_addr + address_stride_b;
        b_mem_access <= 1;
    end
end  

//////////////////////////////////////////////////////////////////////////
// Logic to generate valid signals for data coming from BRAM B
//////////////////////////////////////////////////////////////////////////

reg [7:0] b_mem_access_counter;

always @(posedge clk) begin
    if (reset || ~start_mat_mul) begin
        b_mem_access_counter <= 0;
    end
    else if (b_mem_access == 1) begin
        b_mem_access_counter <= b_mem_access_counter + 1;  
    end
    else begin
        b_mem_access_counter <= 0;
    end
end

assign b_data_valid = 
       ((validity_mask_a_cols_b_rows[0]==1'b0 && b_mem_access_counter==1) ||
        % for i in range(1,mat_mul_size-1):
        (validity_mask_a_cols_b_rows[${i}]==1'b0 && b_mem_access_counter==${i+1}) ||
        % endfor
        (validity_mask_a_cols_b_rows[${mat_mul_size-1}]==1'b0 && b_mem_access_counter==${mat_mul_size})) ?
        1'b0 : (b_mem_access_counter >= `MEM_ACCESS_LATENCY);   

//////////////////////////////////////////////////////////////////////////
// Logic to delay certain parts of the data received from BRAM B (systolic data setup)
//////////////////////////////////////////////////////////////////////////

// Slice data into chunks and qualify it with whether it is valid or not
assign b0_data = b_data[`DWIDTH-1:0] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[0]}};
% for i in range(1,mat_mul_size):
assign b${i}_data = b_data[${i+1}*`DWIDTH-1:${i}*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[${i}]}};
% endfor

// For larger matmuls, more such delaying flops will be needed
% for i in range(1,mat_mul_size):
%   for j in range(1,i+1):
reg [`DWIDTH-1:0] b${i}_data_delayed_${j};
%   endfor
% endfor

always @(posedge clk) begin
  if (reset || ~start_mat_mul || clk_cnt==0) begin
  % for i in range(1,mat_mul_size):
  %     for j in range(1,i+1):
    b${i}_data_delayed_${j} <= 0;
  %     endfor
  % endfor
  end
  else begin
  % for i in range(mat_mul_size):
  %     for j in range (1,i+1):
  %         if (j == 1):
    b${i}_data_delayed_${j} <= b${i}_data;
  %         else:
    b${i}_data_delayed_${j} <= b${i}_data_delayed_${j-1};
  %         endif
  %     endfor
  % endfor
  end
end
  
endmodule

//////////////////////////////////////////////////////////////////////////
// Systolically connected PEs
//////////////////////////////////////////////////////////////////////////

module systolic_pe_matrix(
    reset,
    clk,
    pe_reset,
    b_data_sel,
    % for i in range(mat_mul_size-1):
    a${i},\
    % endfor
    a${mat_mul_size-1},
    % for i in range(mat_mul_size-1):
    b${i},\
    % endfor
    b${mat_mul_size-1},
    % for i in range(mat_mul_size-1):
    c${i},\
    % endfor
    c${mat_mul_size-1},
    % for i in range(mat_mul_size):
    %   for j in range(mat_mul_size):
    matrixC${i}_${j},
    %   endfor
    % endfor
    a_data_out,
    b_data_out,
    b_data_valid_ping,
    b_data_valid_pong
);

input clk;
input reset;
input pe_reset;
input b_data_sel;
input b_data_valid_ping;
input b_data_valid_pong;
% for i in range(mat_mul_size):
input [`DWIDTH-1:0] a${i};
% endfor
% for i in range(mat_mul_size):
input [`DWIDTH-1:0] b${i};
% endfor
% for i in range(mat_mul_size):
input [`DWIDTH-1:0] c${i};
% endfor
% for i in range(mat_mul_size):
%   for j in range(mat_mul_size):
output [`DWIDTH-1:0] matrixC${i}_${j};
%   endfor
% endfor
output [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out;
  

% for  i in range(mat_mul_size):
wire [`DWIDTH-1:0] \
%   for j in range(mat_mul_size-1):
a${i}_${j}to${i}_${j+1}, \
%   endfor 
a${i}_${mat_mul_size-1}to${i}_${mat_mul_size};
% endfor

% for  i in range(mat_mul_size):
wire [`DWIDTH-1:0] \
%   for j in range(mat_mul_size-1):
b${j}_${i}to${j+1}_${i}, \
%   endfor 
b${mat_mul_size-1}_${i}to${mat_mul_size}_${i};
% endfor

% for  i in range(mat_mul_size):
wire [`DWIDTH-1:0] \
%   for j in range(mat_mul_size-1):
b${j}_${i}to${j+1}_${i}_ping, \
%   endfor 
b${mat_mul_size-1}_${i}to${mat_mul_size}_${i}_ping;
% endfor

% for  i in range(mat_mul_size):
wire [`DWIDTH-1:0] \
%   for j in range(mat_mul_size-1):
b${j}_${i}to${j+1}_${i}_pong, \
%   endfor 
b${mat_mul_size-1}_${i}to${mat_mul_size}_${i}_pong;
% endfor

reg [`DWIDTH-1:0] \
% for i in range(mat_mul_size-1):
b${i}_data, \
% endfor
b${mat_mul_size-1}_data; 

wire effective_rst;
assign effective_rst = reset | pe_reset;

% for i in range(1,2*mat_mul_size-1):
reg b_data_sel_delay${i};
% endfor

always @ (posedge clk) begin
    if (reset) begin
        % for i in range(1,2*mat_mul_size-1):
        b_data_sel_delay${i} <= 0;
        % endfor
    end
    else begin
        b_data_sel_delay1 <= b_data_sel;
        % for i in range(2,2*mat_mul_size-1):
        b_data_sel_delay${i} <= b_data_sel_delay${i-1};
        % endfor
  	end
end

// Signals for Each PONG buffer

% for i in range(1,2*mat_mul_size-1):
reg b_data_valid_pong_delay0_${i};
% endfor
% for i in range(mat_mul_size):
%   for j in range(1,mat_mul_size):
wire b_data_valid_pong_delay${j}_${i};
%   endfor
% endfor
  
always @ (posedge clk) begin
    b_data_valid_pong_delay0_1 <= b_data_valid_pong;
    % for i in range(2,2*mat_mul_size-1):
    b_data_valid_pong_delay0_${i} <= b_data_valid_pong_delay0_${i-1};
    % endfor
end

% for i in range(mat_mul_size):
%   for j in range(1,mat_mul_size):
%       if (i == 0):
assign b_data_valid_pong_delay${j}_${i} = b_data_valid_pong & b_data_valid_pong_delay0_${i+j};
%       else:
assign b_data_valid_pong_delay${j}_${i} = b_data_valid_pong_delay0_${i} & b_data_valid_pong_delay0_${i+j};
%       endif
%   endfor
% endfor

// Signals for Each PING buffer

% for i in range(1,2*mat_mul_size-1):
reg b_data_valid_ping_delay0_${i};
% endfor
% for i in range(mat_mul_size):
%   for j in range(1,mat_mul_size):
wire b_data_valid_ping_delay${j}_${i};
%   endfor
% endfor
  
always @ (posedge clk) begin
    b_data_valid_ping_delay0_1 <= b_data_valid_ping;
    % for i in range(2,2*mat_mul_size-1):
    b_data_valid_ping_delay0_${i} <= b_data_valid_ping_delay0_${i-1};
    % endfor
end

% for i in range(mat_mul_size):
%   for j in range(1,mat_mul_size):
%       if (i == 0):
assign b_data_valid_ping_delay${j}_${i} = b_data_valid_ping & b_data_valid_ping_delay0_${i+j};
%       else:
assign b_data_valid_ping_delay${j}_${i} = b_data_valid_ping_delay0_${i} & b_data_valid_ping_delay0_${i+j};
%       endif
%   endfor
% endfor

% for i in range(mat_mul_size):
%   for j in range(mat_mul_size):
%       if (i+j == 0):
processing_element pe${i}_${j}(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel),        .in_a(a${i}),      .in_b(b${i}),      .in_c(c${i}),        .out_a(a${i}_${j}to${i}_${j+1}), .out_b(b${i}_${j}to${i+1}_${j}), .out_b0(b${i}_${j}to${i+1}_${j}_ping), .out_b1(b${i}_${j}to${i+1}_${j}_pong), .out_c(matrixC${i}_${j}), .b_data_valid_ping(b_data_valid_ping),         .b_data_valid_pong(b_data_valid_pong        ));
%       elif (i == 0):
processing_element pe${i}_${j}(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay${i+j}), .in_a(a${i}_${j-1}to${i}_${j}), .in_b(b${j}),      .in_c(c${j}),        .out_a(a${i}_${j}to${i}_${j+1}), .out_b(b${i}_${j}to${i+1}_${j}), .out_b0(b${i}_${j}to${i+1}_${j}_ping), .out_b1(b${i}_${j}to${i+1}_${j}_pong), .out_c(matrixC${i}_${j}), .b_data_valid_ping(b_data_valid_ping_delay${i}_${j}), .b_data_valid_pong(b_data_valid_pong_delay${i}_${j}));
%       elif (j == 0):
processing_element pe${i}_${j}(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay${i+j}), .in_a(a${i}),      .in_b(b${i-1}_${j}to${i}_${j}), .in_c(matrixC${i-1}_${j}), .out_a(a${i}_${j}to${i}_${j+1}), .out_b(b${i}_${j}to${i+1}_${j}), .out_b0(b${i}_${j}to${i+1}_${j}_ping), .out_b1(b${i}_${j}to${i+1}_${j}_pong), .out_c(matrixC${i}_${j}), .b_data_valid_ping(b_data_valid_ping_delay${i}_${j}), .b_data_valid_pong(b_data_valid_pong_delay${i}_${j}));
%       else:
processing_element pe${i}_${j}(.reset(effective_rst), .clk(clk), .b_data_sel(b_data_sel_delay${i+j}), .in_a(a${i}_${j-1}to${i}_${j}), .in_b(b${i-1}_${j}to${i}_${j}), .in_c(matrixC${i-1}_${j}), .out_a(a${i}_${j}to${i}_${j+1}), .out_b(b${i}_${j}to${i+1}_${j}), .out_b0(b${i}_${j}to${i+1}_${j}_ping), .out_b1(b${i}_${j}to${i+1}_${j}_pong), .out_c(matrixC${i}_${j}), .b_data_valid_ping(b_data_valid_ping_delay${i}_${j}), .b_data_valid_pong(b_data_valid_pong_delay${i}_${j}));
%       endif
%   endfor

% endfor  
  
assign a_data_out = {\
% for i in range(mat_mul_size-1,0,-1):
a${i}_${mat_mul_size-1}to${i}_${mat_mul_size}, \
% endfor
a0_${mat_mul_size-1}to0_${mat_mul_size}};
assign b_data_out = {\
% for i in range(mat_mul_size-1,0,-1):
b${mat_mul_size-1}_${i}to${mat_mul_size}_${i}, \
% endfor
b${mat_mul_size-1}_0to${mat_mul_size}_0};

endmodule

//////////////////////////////////////////////////////////////////////////
// Processing element (PE)
//////////////////////////////////////////////////////////////////////////

module processing_element(
    reset, 
    clk, 
    b_data_sel,
    in_a,
    in_b,
    in_c,
    out_a,
    out_b, 
    out_b0,
    out_b1,
    out_c,
    b_data_valid_ping,
    b_data_valid_pong
 );

input reset;
input clk;
input b_data_sel;
input b_data_valid_ping;
input b_data_valid_pong;
input  [`DWIDTH-1:0] in_a;
input  [`DWIDTH-1:0] in_b; 
input  [`DWIDTH-1:0] in_c; 
output [`DWIDTH-1:0] out_a;
output [`DWIDTH-1:0] out_b;
output [`DWIDTH-1:0] out_b0;
output [`DWIDTH-1:0] out_b1;
output [`DWIDTH-1:0] out_c;  // reduced precision

reg [`DWIDTH-1:0] out_a;
reg [`DWIDTH-1:0] out_b;
reg [`DWIDTH-1:0] out_b0;
reg [`DWIDTH-1:0] out_b1;

wire [`DWIDTH-1:0] in_mac;
wire [`DWIDTH-1:0] out_c;
wire [`DWIDTH-1:0] out_mac;

assign out_c = out_mac;
assign in_mac = (b_data_sel==0)? out_b0 : out_b1;
        
seq_mac u_mac(.a(out_a), .b(in_mac), .c(in_c), .out(out_mac), .reset(reset), .clk(clk));

always @(posedge clk)begin
    if(reset) begin
        out_a<=0;
    end
    else begin  
        out_a<=in_a;
    end
end

always @(posedge clk)begin
    if(reset) begin
        out_b<=0;
    end
    else begin  
        out_b<=in_b;
    end
end

always @(posedge clk)begin 
    if (reset) begin
        out_b0<=0;
    end
    if(b_data_valid_ping == 1) begin
        out_b0<=in_b;
    end
end

always @(posedge clk)begin 
    if (reset) begin
        out_b1<=0;
    end
    if(b_data_valid_pong == 1) begin
        out_b1<=in_b;
    end
end

endmodule

//////////////////////////////////////////////////////////////////////////
// Multiply-and-accumulate (MAC) block
//////////////////////////////////////////////////////////////////////////

module seq_mac(a, b, c, out, reset, clk);

input [`DWIDTH-1:0] a;
input [`DWIDTH-1:0] b;
input [`DWIDTH-1:0] c;
input reset;
input clk;
output [`DWIDTH-1:0] out;

wire [`DWIDTH-1:0] mul_out;
wire [`DWIDTH-1:0] add_out;

reg [`DWIDTH-1:0] a_flopped;
reg [`DWIDTH-1:0] b_flopped;
reg [`DWIDTH-1:0] c_flopped;

wire [2*`DWIDTH-1:0] mul_out_temp;
wire [2*`DWIDTH-1:0] mul_out_temp_reg;

always @(posedge clk) begin
  if (reset) begin
    a_flopped <= 0;
    b_flopped <= 0;
    c_flopped <= 0;
  end else begin
    a_flopped <= a;
    b_flopped <= b;
    c_flopped <= c;
  end
end
  
// assign mul_out = a * b;
qmult mult_u1(.i_multiplicand(a_flopped), .i_multiplier(b_flopped), .o_result(mul_out_temp));


// down cast the result
// todo: do a fused multiply add. Truncate only once after the accumulation is complete
assign mul_out = 
    (mul_out_temp[2*`DWIDTH-1] == 0) ?  //positive number
        (
           (|(mul_out_temp[2*`DWIDTH-2 : `DWIDTH-1])) ?  //is any bit from 14:7 is 1, that means overlfow
             {mul_out_temp[2*`DWIDTH-1] , {(`DWIDTH-1){1'b1}}} : //sign bit and then all 1s
             {mul_out_temp[2*`DWIDTH-1] , mul_out_temp[`DWIDTH-2:0]} 
        )
        : //negative number
        (
           (|(mul_out_temp[2*`DWIDTH-2 : `DWIDTH-1])) ?  //is any bit from 14:7 is 0, that means overlfow
             {mul_out_temp[2*`DWIDTH-1] , mul_out_temp[`DWIDTH-2:0]} :
             {mul_out_temp[2*`DWIDTH-1] , {(`DWIDTH-1){1'b0}}} //sign bit and then all 0s
        );


// we just truncate the higher bits of the product
// assign out = mul_out + c_flopped;
qadd add_u1(.a(c_flopped), .b(mul_out), .c(out));

endmodule


//////////////////////////////////////////////////////////////////////////
// Multiplier
//////////////////////////////////////////////////////////////////////////

module qmult(i_multiplicand,i_multiplier,o_result);

input [`DWIDTH-1:0] i_multiplicand;
input [`DWIDTH-1:0] i_multiplier;
output [2*`DWIDTH-1:0] o_result;

assign o_result = i_multiplicand * i_multiplier;
//DW02_mult #(`DWIDTH,`DWIDTH) u_mult(.A(i_multiplicand), .B(i_multiplier), .TC(1'b1), .PRODUCT(o_result));

endmodule


//////////////////////////////////////////////////////////////////////////
// Adder
//////////////////////////////////////////////////////////////////////////
// todo: Output should have one extra bit as compared to the inputs

module qadd(a,b,c);

input [`DWIDTH-1:0] a;
input [`DWIDTH-1:0] b;
output [`DWIDTH-1:0] c;

assign c = a + b;
// DW01_add #(`DWIDTH) u_add(.A(a), .B(b), .CI(1'b0), .SUM(c), .CO());

endmodule

