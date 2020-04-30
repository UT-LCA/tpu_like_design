module top(
    input clk,
    input clk_mem,
    input reset
//TODO: Add signals to interface with the cfg block
//TODO: Provide an interface to BRAM from the top-level 
//to avoid things getting optimized out
);

//TODO: Introduce the concept of addresses of each matrix.
//For now, I just read RAMs starting from address 0 and 
//write starting from address 0.

wire [`AWIDTH-1:0] bram_addr_a;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a;
wire [`MASK_WIDTH-1:0] bram_we_a;
wire bram_en_a;
wire [`AWIDTH-1:0] bram_addr_b;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b;
wire [`MASK_WIDTH-1:0] bram_we_b;
wire bram_en_b;
reg  [`AWIDTH-1:0] bram_addr_c;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c;
reg  [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c;
wire [`MASK_WIDTH-1:0] bram_we_c;
wire bram_en_c;
reg bram_c_data_available;
wire done_all;
wire start_mat_mul;
wire done_mat_mul;
wire norm_out_data_available;
wire done_norm;
wire enable_matmul;
wire enable_norm;
wire enable_activation;
wire enable_pool;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] matmul_c_data_out;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] norm_data_out;
wire matmul_c_data_available;
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out_NC;
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out_NC;
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in_NC;
wire [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in_NC;
wire [`AWIDTH-1:0] bram_addr_c_NC;
wire [`DWIDTH-1:0] mean;
wire [`DWIDTH-1:0] inv_var;

//Connections for bram c (output matrix)
//bram_addr_c -> connected to u_matmul_4x4 block
//bram_rdata_c -> not used
//bram_wdata_c -> Will come from the last block that is enabled
//bram_we_c -> Will be 1 when the last block's data is available
//bram_en_c -> hardcoded to 1 
assign bram_en_c = 1'b1;
assign bram_we_c = (bram_c_data_available) ? {`MASK_WIDTH{1'b1}} : {`MASK_WIDTH{1'b0}};  

//Connections for bram a (first input matrix)
//bram_addr_a -> connected to u_matmul_4x4
//bram_rdata_a -> connected to u_matmul_4x4
//bram_wdata_a -> hardcoded to 0 (this block only reads from bram a)
//bram_we_a -> hardcoded to 0 (this block only reads from bram a)
//bram_en_a -> hardcoded to 1
assign bram_wdata_a = {`BB_MAT_MUL_SIZE*`DWIDTH{1'b0}};
assign bram_en_a = 1'b1;
assign bram_we_a = {`MASK_WIDTH{1'b0}};
  
//Connections for bram b (second input matrix)
//bram_addr_b -> connected to u_matmul_4x4
//bram_rdata_b -> connected to u_matmul_4x4
//bram_wdata_b -> hardcoded to 0 (this block only reads from bram b)
//bram_we_b -> hardcoded to 0 (this block only reads from bram b)
//bram_en_b -> hardcoded to 1
assign bram_wdata_b = {`BB_MAT_MUL_SIZE*`DWIDTH{1'b0}};
assign bram_en_b = 1'b1;
assign bram_we_b = {`MASK_WIDTH{1'b0}};
  
// BRAM matrix A 
ram matrix_A (
  .addr0(bram_addr_a),
  .d0(bram_wdata_a), 
  .we0(bram_we_a), 
  .q0(bram_rdata_a), 
  .clk(clk_mem));

// BRAM matrix B
ram matrix_B (
  .addr0(bram_addr_b),
  .d0(bram_wdata_b), 
  .we0(bram_we_b), 
  .q0(bram_rdata_b), 
  .clk(clk_mem));

// BRAM matrix C
ram matrix_C (
  .addr0(bram_addr_c),
  .d0(bram_wdata_c),
  .we0(bram_we_c),
  .q0(bram_rdata_c),
  .clk(clk_mem));

// Control logic that directs all the operation
control u_control(
  .clk(clk),
  .reset(reset),
  .start(start),
  .enable_matmul(enable_matmul),
  .enable_norm(enable_norm),
  .enable_activation(enable_activation),
  .enable_pool(enable_pool),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul),
  .done_norm(done_norm),
  .done_all(done_all)
);

// Configuration (register) block
cfg u_cfg(
  .start(start),
  .enable_matmul(enable_matmul),
  .enable_norm(enable_norm),
  .enable_activation(enable_activation),
  .enable_pool(enable_pool),
  .mean(mean),
  .inv_var(inv_var),
  .done_all(done_all)
);

//TODO: We want to move the data setup part
//and the interface to BRAM_A and BRAM_B outside
//into its own modules. For now, it is all inside
//the matmul block

//Matrix multiplier
matmul_4x4 u_matmul_4x4(
  .clk(clk),
  .reset(reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul),
  .a_data(bram_rdata_a),
  .b_data(bram_rdata_b),
  .a_data_in(a_data_in_NC),
  .b_data_in(b_data_in_NC),
  .c_data_in({`BB_MAT_MUL_SIZE*`DWIDTH{1'b0}}),
  .c_data_out(matmul_c_data_out),
  .a_data_out(a_data_out_NC),
  .b_data_out(b_data_out_NC),
  .a_addr(bram_addr_a),
  .b_addr(bram_addr_b),
  .c_addr(bram_addr_c_NC),
  .c_data_available(matmul_c_data_available),
  .final_mat_mul_size(8'd4),
  .a_loc(8'd0),
  .b_loc(8'd0)
);

// Normalization module
//TODO: If norm is disabled, then connecting matmul_c_data_out to 
//norm is incorrect. Need to add muxing stucture (may be inside control block).
//A better approach is to just have the muxing inside each block (eg. we can loopback
//the input data back to output if norm is not enabled)
norm u_norm(
  .mean(mean),
  .inv_var(inv_var),
  .in_data_available(matmul_c_data_available),
  .inp_data(matmul_c_data_out),
  .out_data(norm_data_out),
  .out_data_available(norm_out_data_available),
  .done_norm(done_norm),
  .clk(clk),
  .reset(reset)
);

 //TODO: For now assigning output of NORM block
 //to the BRAM C data. This will change based on 
 //which other blocks (activation/pool/etc) are 
 //enabled. I expect some sort of a muxing structure.

//Interface to BRAM to write the output.
//Ideally, we could remove this flop stage. But then we'd
//have to generate the address for the output BRAM in each
//block that could potentially write the output.
always @(posedge clk) begin
  if (reset) begin
    bram_wdata_c <= 0;
    bram_addr_c <= `MEM_SIZE-`BB_MAT_MUL_SIZE; //last but 1 location
    bram_c_data_available <= 0;
  end
  else if (norm_out_data_available) begin
    bram_wdata_c <= norm_data_out;
    bram_addr_c <= bram_addr_c + `BB_MAT_MUL_SIZE;
    bram_c_data_available <= norm_out_data_available;
  end
  else begin
    bram_wdata_c <= 0;
    bram_addr_c <= `MEM_SIZE-`BB_MAT_MUL_SIZE; //last but 1 location
    bram_c_data_available <= 0;
  end
end  

endmodule