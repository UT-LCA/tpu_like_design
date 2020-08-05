
`timescale 1ns/1ns
module matmul_tb;

reg clk;
reg resetn;
reg start;
reg clear_done;
reg slice_dtype;
reg slice_mode;
reg [7:0] final_mat_mul_size;
reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_a;
reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_b;
reg [`ADDR_STRIDE_WIDTH-1:0] address_stride_c;
reg [15:0] address_mat_a;
reg [15:0] address_mat_b;
reg [15:0] address_mat_c;
reg [7:0] validity_mask_a_rows;
reg [7:0] validity_mask_a_cols_b_rows;
reg [7:0] validity_mask_b_cols;
reg [7:0] a_loc;
reg [7:0] b_loc;
reg [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in;
reg [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in;
reg [`BB_MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in;

matrix_multiplication u_matmul(
  .clk(clk), 
  .clk_mem(clk),
  .resetn(resetn), 
  .pe_resetn(resetn), 
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols),
  .start_reg(start),
  .clear_done_reg(clear_done),
  .slice_dtype(slice_dtype),
  .slice_mode(slice_mode),
  .final_mat_mul_size(final_mat_mul_size),
  .a_loc(a_loc),
  .b_loc(b_loc),
  .a_data_in(a_data_in),
  .b_data_in(b_data_in),
  .c_data_in(c_data_in));

initial begin
  clk = 0;
  forever begin
    #10 clk = ~clk;
  end
end

initial begin
  // MATMUL mode
  slice_mode = `SLICE_MODE_MATMUL;
  // Addresses
  address_mat_a = 16'b0;
  address_mat_b = 16'b0;
  address_mat_c = 16'b0;
  validity_mask_a_rows = 8'b11111111;
  validity_mask_a_cols_b_rows = 8'b11111111;
  validity_mask_b_cols = 8'b11111111;
  a_loc = 8'b0;
  b_loc = 8'b0;
  a_data_in = {`BB_MAT_MUL_SIZE*`DWIDTH{1'bz}};
  b_data_in = {`BB_MAT_MUL_SIZE*`DWIDTH{1'bz}};
  c_data_in = {`BB_MAT_MUL_SIZE*`DWIDTH{1'b0}};
  //First let's try int8 mode
  slice_dtype = `DTYPE_INT8;
  final_mat_mul_size = 8'd8;
  address_stride_a = 16'd8;
  address_stride_b = 16'd8;
  address_stride_c = 16'd8;
  resetn = 0;
  #55 resetn = 1;
  start = 0;
  #115 start = 1;
  @(posedge u_matmul.done_mat_mul);
  start = 0;
  clear_done = 1;
  #200;
  #115 start = 1;
  @(posedge u_matmul.done_mat_mul);
  start = 0;
  clear_done = 1;
  #200;

  //Next let's try fp16 mode
  slice_dtype = `DTYPE_FP16;
  final_mat_mul_size = 8'd4;
  address_stride_a = 16'd16;
  address_stride_b = 16'd16;
  address_stride_c = 16'd16;
  resetn = 0;
  #55 resetn = 1;
  start = 0;
  #115 start = 1;
  @(posedge u_matmul.done_mat_mul);
  start = 0;
  clear_done = 1;
  #200;
  #115 start = 1;
  @(posedge u_matmul.done_mat_mul);
  start = 0;
  clear_done = 1;
  #200;

  // Individual PE mode
  slice_mode = `SLICE_MODE_INDIV_PE;
  resetn = 0;
  #55 resetn = 1;
  // Let's try to use PE00
  // Specify data type as INT8
  address_mat_c[4] = `DTYPE_INT8; //this is bit 0 of direct_inputs_dtype
  // Specify using MAC mode
  address_stride_b[0] = 1'b0; //this is bit 0 of direct_inputs_mode. 
  address_stride_b[1] = 1'b0;
  // Specify using sequential mode
  address_stride_b[2] = 1'b1;
  // Let's say input_a is 2
  b_loc[7:0] = 8'd2; //this is bit 0 of direct_inputs_a
  // Let's say input_b is 3 
  a_data_in[23:16] = 8'd3; //this is bit 0 of direct_inputs_b
  // Observe output
  // c_data_out[7:0] //this is bit 0 of direct_output
  resetn = 0;
  #55 resetn = 1;
  #200;

  // Individual PE mode
  slice_mode = `SLICE_MODE_INDIV_PE;
  resetn = 0;
  #55 resetn = 1;
  // Let's try to use PE12 (7th PE 00->01->10->11->...)
  // Specify data type as FP16
  address_mat_c[10] = `DTYPE_FP16; //this is bit 6 of direct_inputs_dtype
  // Specify using MUL mode
  address_stride_a[2] = 1'b1; //this is bit 6 of direct_inputs_mode. 
  address_stride_a[3] = 1'b0;
  // Specify using combinatorial mode
  address_stride_a[4] = 1'b0;
  // Let's say input_a is 5
  c_data_in[63:48] = 16'd5; //this is bit 111:96 of direct_inputs_a
  // Let's say input_b is 9 
  // b_data[63:48] = 16'd9; //this is bit 111:96 of direct_inputs_b
  // The right thing would have been to expose b_data to the tb, but I am taking 
  // a shortcut by forcing it in the ram module
  force u_matmul.u_matmul_8x8.b_data[63:48] = 16'd9;
  // Observe output
  // a_data_out[47:32] //this is bit 111:96 of direct_output
  resetn = 0;
  #55 resetn = 1;
  #200;
  $finish;
end

//One column in this is really interpreted as 1 row in matrix A
//In the following, by changing the first column, I'm effectively changing the first row of matrix A.
reg [`DWIDTH-1:0] a[16][16] = 
'{{8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},  
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1}}; 

//One column in this is really interpreted as 1 column in matrix B. Transposed.
//In the following, by changing the first row, I'm effectively changing the last column of matrix B.
reg [`DWIDTH-1:0] b[16][16] = 
'{{8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1}};

initial begin

for (int i=0; i<16; i++) begin
  for (int j=0; j<16; j++) begin
    u_matmul.matrix_A.ram[16*i + j] = a[i][j];
  end
end

for (int j=0; j<16; j++) begin
  for (int i=0; i<16; i++) begin
    u_matmul.matrix_B.ram[16*j + i] = b[i][j];
  end
end

end
/*
reg [15:0] matA [15:0] = '{1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6};
reg [15:0] matB [15:0] = '{4,5,2,8,5,8,0,2,6,9,5,8,3,9,3,0};

initial begin
  enable_writing_to_mem = 0;
  we1 = 0;
  we2 = 0;
  data_pi = 0;
  addr_pi = 0;
  #65;

  enable_writing_to_mem = 1;

//write first memory
  for(int i=0; i<16; i++) begin
    we1 = 1;
    we2 = 0;
    addr_pi = i;
    data_pi = matA[i];
    @(posedge clk);
    #5;
  end

  we1 = 0;
  we2 = 0;
  data_pi = 0;
  addr_pi = 0;
  @(posedge clk);

//write second memory
  for(int i=0; i<16; i++) begin
    we1 = 0;
    we2 = 1;
    addr_pi = i;
    data_pi = matB[i];
    @(posedge clk);
    #5;
  end

  we1 = 0;
  we2 = 0;

  #25;
//start matrix multiplication process  
  enable_writing_to_mem = 0;
  addr_pi = 0;
  while(1) begin
    @(posedge clk);
    if (done_mat_mul == 1) begin
        break;
    end
  end

  for(int i=0; i<16; i++) begin
    out_sel = i;
    @(posedge clk);
  end

    @(posedge clk);

  $finish;
end
*/

initial begin
  $vcdpluson;
  $vcdplusmemon;
end

endmodule
