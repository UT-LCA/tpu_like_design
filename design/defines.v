`define DWIDTH 8
`define AWIDTH 13
`define MEM_SIZE 8192
`define MAT_MUL_SIZE 4
`define MASK_WIDTH 4
`define LOG2_MAT_MUL_SIZE 2
`define BB_MAT_MUL_SIZE `MAT_MUL_SIZE
`define NUM_CYCLES_IN_MAC 3

`define REG_DATAWIDTH 32
`define REG_ADDRWIDTH 8

/////////////////////////////////////////////////
//Register specification
/////////////////////////////////////////////////
//---------------------------------------
//Addr 0 : Register with enables for various blocks
//---------------------------------------
`define REG_ENABLES_ADDR 32'h0
//Bit 0: enable_matmul
//Bit 1: enable_norm
//Bit 2: enable_pool
//Bit 3: enable_activation

//---------------------------------------
//Addr 4: Register that triggers the whole TPU
//---------------------------------------
`define REG_STDN_TPU_ADDR 32'h4
//Bit 0: start_tpu
//Bit 31: done_tpu

//---------------------------------------
//Register that stores the mean of the values
//---------------------------------------
`define REG_MEAN_ADDR 32'h8
//Bit 7:0: mean

//---------------------------------------
//Register that stores the inverse variance of the values
//---------------------------------------
`define REG_INV_VAR_ADDR 32'hA
//Bit 7:0: inv_var