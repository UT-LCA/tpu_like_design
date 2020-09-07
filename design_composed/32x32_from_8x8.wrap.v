module matmul_32x32_systolic(
 clk,
 reset,
 pe_reset,
 start_mat_mul,
 done_mat_mul,
 address_mat_a,
 address_mat_b,
 address_mat_c,
 address_stride_a,
 address_stride_b,
 address_stride_c,
 a_data,
 b_data,
 a_data_in, //Data values coming in from previous matmul - systolic connections
 b_data_in,
 c_data_in, //Data values coming in from previous matmul - systolic shifting
 c_data_out, //Data values going out to next matmul - systolic shifting
 a_data_out,
 b_data_out,
 a_addr,
 b_addr,
 c_addr,
 c_data_available,

 validity_mask_a_rows,
 validity_mask_a_cols,
 validity_mask_b_rows,
 validity_mask_b_cols,
  
final_mat_mul_size,
  
 a_loc,
 b_loc
);

 input clk;
 input reset;
 input pe_reset;
 input start_mat_mul;
 output done_mat_mul;
 input [`AWIDTH-1:0] address_mat_a;
 input [`AWIDTH-1:0] address_mat_b;
 input [`AWIDTH-1:0] address_mat_c;
 input [`ADDR_STRIDE_WIDTH-1:0] address_stride_a;
 input [`ADDR_STRIDE_WIDTH-1:0] address_stride_b;
 input [`ADDR_STRIDE_WIDTH-1:0] address_stride_c;
 input [`DESIGN_SIZE*`DWIDTH-1:0] a_data;
 input [`DESIGN_SIZE*`DWIDTH-1:0] b_data;
 input [`DESIGN_SIZE*`DWIDTH-1:0] a_data_in;
 input [`DESIGN_SIZE*`DWIDTH-1:0] b_data_in;
 input [`DESIGN_SIZE*`DWIDTH-1:0] c_data_in;
 output [`DESIGN_SIZE*`DWIDTH-1:0] c_data_out;
 output [`DESIGN_SIZE*`DWIDTH-1:0] a_data_out;
 output [`DESIGN_SIZE*`DWIDTH-1:0] b_data_out;
 output [`AWIDTH-1:0] a_addr;
 output [`AWIDTH-1:0] b_addr;
 output [`AWIDTH-1:0] c_addr;
 output c_data_available;

 input [`MASK_WIDTH-1:0] validity_mask_a_rows;
 input [`MASK_WIDTH-1:0] validity_mask_a_cols;
 input [`MASK_WIDTH-1:0] validity_mask_b_rows;
 input [`MASK_WIDTH-1:0] validity_mask_b_cols;

//7:0 is okay here. We aren't going to make a matmul larger than 128x128
//In fact, these will get optimized out by the synthesis tool, because
//we hardcode them at the instantiation level.
 input [7:0] final_mat_mul_size;
  
 input [7:0] a_loc;
 input [7:0] b_loc;


    wire [`AWIDTH-1:0] bram_addr_a_0_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_0_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_0_0;
	wire [`MASK_WIDTH-1:0] bram_we_a_0_0;
	wire bram_en_a_0_0;
    
	wire [`AWIDTH-1:0] bram_addr_a_1_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_1_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_1_0;
	wire [`MASK_WIDTH-1:0] bram_we_a_1_0;
	wire bram_en_a_1_0;
    
	wire [`AWIDTH-1:0] bram_addr_a_2_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_2_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_2_0;
	wire [`MASK_WIDTH-1:0] bram_we_a_2_0;
	wire bram_en_a_2_0;
    
	wire [`AWIDTH-1:0] bram_addr_a_3_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_3_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_3_0;
	wire [`MASK_WIDTH-1:0] bram_we_a_3_0;
	wire bram_en_a_3_0;
    
	wire [`AWIDTH-1:0] bram_addr_b_0_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_0_0;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_0_0;
	wire [`MASK_WIDTH-1:0] bram_we_b_0_0;
	wire bram_en_b_0_0;
    
	wire [`AWIDTH-1:0] bram_addr_b_0_1;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_0_1;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_0_1;
	wire [`MASK_WIDTH-1:0] bram_we_b_0_1;
	wire bram_en_b_0_1;
    
	wire [`AWIDTH-1:0] bram_addr_b_0_2;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_0_2;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_0_2;
	wire [`MASK_WIDTH-1:0] bram_we_b_0_2;
	wire bram_en_b_0_2;
    
	wire [`AWIDTH-1:0] bram_addr_b_0_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_0_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_0_3;
	wire [`MASK_WIDTH-1:0] bram_we_b_0_3;
	wire bram_en_b_0_3;
    
	wire [`AWIDTH-1:0] bram_addr_c_0_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_0_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_0_3;
	wire [`MASK_WIDTH-1:0] bram_we_c_0_3;
	wire bram_en_c_0_3;
    
	wire [`AWIDTH-1:0] bram_addr_c_1_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_1_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_1_3;
	wire [`MASK_WIDTH-1:0] bram_we_c_1_3;
	wire bram_en_c_1_3;
    
	wire [`AWIDTH-1:0] bram_addr_c_2_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_2_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_2_3;
	wire [`MASK_WIDTH-1:0] bram_we_c_2_3;
	wire bram_en_c_2_3;
    
	wire [`AWIDTH-1:0] bram_addr_c_3_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_3_3;
	wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_3_3;
	wire [`MASK_WIDTH-1:0] bram_we_c_3_3;
	wire bram_en_c_3_3;

    wire c_data_0_3_available;
    wire c_data_1_3_available;
    wire c_data_2_3_available;
    wire c_data_3_3_available;
    
    assign a_addr = bram_addr_a_0_0;
    assign b_addr = bram_addr_b_0_0;

	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_1;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_2;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_3;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_4;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_5;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_6;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_7;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_8;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_9;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_10;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_11;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_12;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_13;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_14;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_15;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_16;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_17;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_18;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_19;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_20;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_21;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_22;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_23;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_delayed_24;

    assign bram_rdata_a_0_0 = a_data[`MAT_MUL_SIZE*`DWIDTH-1:0];
    assign bram_rdata_a_1_0 = a_data_delayed_8;
    assign bram_rdata_a_2_0 = a_data_delayed_16;
    assign bram_rdata_a_3_0 = a_data_delayed_24;

    always @(posedge clk) begin
        if (reset) begin
            a_data_delayed_1 <= 0; 
            a_data_delayed_2 <= 0; 
            a_data_delayed_3 <= 0; 
            a_data_delayed_4 <= 0; 
            a_data_delayed_5 <= 0; 
            a_data_delayed_6 <= 0; 
            a_data_delayed_7 <= 0; 
            a_data_delayed_8 <= 0; 
            a_data_delayed_9 <= 0;
            a_data_delayed_10 <= 0;
            a_data_delayed_11 <= 0;
            a_data_delayed_12 <= 0;
            a_data_delayed_13 <= 0;
            a_data_delayed_14 <= 0;
            a_data_delayed_15 <= 0;
            a_data_delayed_16 <= 0;
            a_data_delayed_17 <= 0;
            a_data_delayed_18 <= 0;
            a_data_delayed_19 <= 0;
            a_data_delayed_20 <= 0;
            a_data_delayed_21 <= 0;
            a_data_delayed_22 <= 0;
            a_data_delayed_23 <= 0;
            a_data_delayed_24 <= 0;
        end
        else begin
            a_data_delayed_1 <= a_data[2*`MAT_MUL_SIZE*`DWIDTH-1:`MAT_MUL_SIZE*`DWIDTH];
            a_data_delayed_2 <= a_data_delayed_1;
            a_data_delayed_3 <= a_data_delayed_2;
            a_data_delayed_4 <= a_data_delayed_3;
            a_data_delayed_5 <= a_data_delayed_4;
            a_data_delayed_6 <= a_data_delayed_5;
            a_data_delayed_7 <= a_data_delayed_6;
            a_data_delayed_8 <= a_data_delayed_7;
            a_data_delayed_9 <= a_data_delayed_8;;
            a_data_delayed_10 <= a_data_delayed_9;;
            a_data_delayed_11 <= a_data_delayed_10;
            a_data_delayed_12 <= a_data_delayed_11;
            a_data_delayed_13 <= a_data_delayed_12;
            a_data_delayed_14 <= a_data_delayed_13;
            a_data_delayed_15 <= a_data_delayed_14;
            a_data_delayed_16 <= a_data_delayed_15;
            a_data_delayed_17 <= a_data_delayed_16;
            a_data_delayed_18 <= a_data_delayed_17;
            a_data_delayed_19 <= a_data_delayed_18;
            a_data_delayed_20 <= a_data_delayed_19;
            a_data_delayed_21 <= a_data_delayed_20;
            a_data_delayed_22 <= a_data_delayed_21;
            a_data_delayed_23 <= a_data_delayed_22;
            a_data_delayed_24 <= a_data_delayed_23;
        end
    end

	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_1;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_2;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_3;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_4;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_5;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_6;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_7;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_8;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_9;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_10;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_11;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_12;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_13;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_14;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_15;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_16;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_17;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_18;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_19;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_20;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_21;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_22;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_23;
	reg [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_delayed_24;

    assign bram_rdata_b_0_0 = b_data[`MAT_MUL_SIZE*`DWIDTH-1:0];
    assign bram_rdata_b_0_1 = b_data_delayed_8;
    assign bram_rdata_b_0_2 = b_data_delayed_16;
    assign bram_rdata_b_0_3 = b_data_delayed_24;

    always @(posedge clk) begin
        if (reset) begin
            b_data_delayed_1 <= 0; 
            b_data_delayed_2 <= 0; 
            b_data_delayed_3 <= 0; 
            b_data_delayed_4 <= 0; 
            b_data_delayed_5 <= 0; 
            b_data_delayed_6 <= 0; 
            b_data_delayed_7 <= 0; 
            b_data_delayed_8 <= 0; 
            b_data_delayed_9 <= 0;
            b_data_delayed_10 <= 0;
            b_data_delayed_11 <= 0;
            b_data_delayed_12 <= 0;
            b_data_delayed_13 <= 0;
            b_data_delayed_14 <= 0;
            b_data_delayed_15 <= 0;
            b_data_delayed_16 <= 0;
            b_data_delayed_17 <= 0;
            b_data_delayed_18 <= 0;
            b_data_delayed_19 <= 0;
            b_data_delayed_20 <= 0;
            b_data_delayed_21 <= 0;
            b_data_delayed_22 <= 0;
            b_data_delayed_23 <= 0;
            b_data_delayed_24 <= 0;
        end
        else begin
            b_data_delayed_1 <= b_data[2*`MAT_MUL_SIZE*`DWIDTH-1:`MAT_MUL_SIZE*`DWIDTH];
            b_data_delayed_2 <= b_data_delayed_1;
            b_data_delayed_3 <= b_data_delayed_2;
            b_data_delayed_4 <= b_data_delayed_3;
            b_data_delayed_5 <= b_data_delayed_4;
            b_data_delayed_6 <= b_data_delayed_5;
            b_data_delayed_7 <= b_data_delayed_6;
            b_data_delayed_8 <= b_data_delayed_7;
            b_data_delayed_9 <= b_data_delayed_8;;
            b_data_delayed_10 <= b_data_delayed_9;;
            b_data_delayed_11 <= b_data_delayed_10;
            b_data_delayed_12 <= b_data_delayed_11;
            b_data_delayed_13 <= b_data_delayed_12;
            b_data_delayed_14 <= b_data_delayed_13;
            b_data_delayed_15 <= b_data_delayed_14;
            b_data_delayed_16 <= b_data_delayed_15;
            b_data_delayed_17 <= b_data_delayed_16;
            b_data_delayed_18 <= b_data_delayed_17;
            b_data_delayed_19 <= b_data_delayed_18;
            b_data_delayed_20 <= b_data_delayed_19;
            b_data_delayed_21 <= b_data_delayed_20;
            b_data_delayed_22 <= b_data_delayed_21;
            b_data_delayed_23 <= b_data_delayed_22;
            b_data_delayed_24 <= b_data_delayed_23;
        end
    end



assign c_data_out = {bram_wdata_c_3_3, bram_wdata_c_2_3, bram_wdata_c_1_3, bram_wdata_c_0_3};
assign c_data_available = c_data_0_3_available;
assign c_addr = bram_addr_c_0_3;

 matmul_32x32_systolic_composed_from_8x8 u_matmul_32x32_systolic (
  .clk(clk),
  .reset(reset),
  .pe_reset(pe_reset),
  .start_mat_mul(start_mat_mul),
  .done_mat_mul(done_mat_mul),
  .address_mat_a(address_mat_a),
  .address_mat_b(address_mat_b),
  .address_mat_c(address_mat_c),
  .address_stride_a(address_stride_a),
  .address_stride_b(address_stride_b),
  .address_stride_c(address_stride_c),
  
  .a_data_0_0(bram_rdata_a_0_0),
  .b_data_0_0(bram_rdata_b_0_0),
  .a_addr_0_0(bram_addr_a_0_0),
  .b_addr_0_0(bram_addr_b_0_0),
  	
  .a_data_1_0(bram_rdata_a_1_0),
  .b_data_0_1(bram_rdata_b_0_1),
  .a_addr_1_0(bram_addr_a_1_0),
  .b_addr_0_1(bram_addr_b_0_1),
  	
  .a_data_2_0(bram_rdata_a_2_0),
  .b_data_0_2(bram_rdata_b_0_2),
  .a_addr_2_0(bram_addr_a_2_0),
  .b_addr_0_2(bram_addr_b_0_2),
  	
  .a_data_3_0(bram_rdata_a_3_0),
  .b_data_0_3(bram_rdata_b_0_3),
  .a_addr_3_0(bram_addr_a_3_0),
  .b_addr_0_3(bram_addr_b_0_3),
  	
  .c_data_0_3(bram_wdata_c_0_3),
  .c_addr_0_3(bram_addr_c_0_3),
  .c_data_0_3_available(c_data_0_3_available),
   		
  .c_data_1_3(bram_wdata_c_1_3),
  .c_addr_1_3(bram_addr_c_1_3),
  .c_data_1_3_available(c_data_1_3_available),
   		
  .c_data_2_3(bram_wdata_c_2_3),
  .c_addr_2_3(bram_addr_c_2_3),
  .c_data_2_3_available(c_data_2_3_available),
   		
  .c_data_3_3(bram_wdata_c_3_3),
  .c_addr_3_3(bram_addr_c_3_3),
  .c_data_3_3_available(c_data_3_3_available),
   		
  .validity_mask_a_rows(validity_mask_a_rows),
  .validity_mask_a_cols(validity_mask_a_cols),
  .validity_mask_b_rows(validity_mask_b_rows),
  .validity_mask_b_cols(validity_mask_b_cols)
);


endmodule
