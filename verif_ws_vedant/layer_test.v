module layer_test();

reg done;
reg [`REG_DATAWIDTH-1:0] rdata;
reg [`REG_DATAWIDTH-1:0] wdata;

task run();
begin
    initialize_brams();
    layer_test();
end
endtask

integer mean = 1;
integer inv_var = 1;


`ifdef DESIGN_SIZE_8

integer a_start_addr = 0;
integer b_start_addr = 0;
integer c_start_addr = 400;
integer problem_size = 8;
integer i;
integer j;

`endif


////////////////////////////////////////////
//Task to initialize BRAMs
////////////////////////////////////////////
task initialize_brams();
begin
	$readmemh ("matrixA.txt", u_top.matrix_A.ram);
	//force u_top.matrix_A.ram[`MEM_SIZE-1] = 64'b0;
	$readmemh ("matrixB.txt", u_top.matrix_B.ram);
  	//force u_top.matrix_B.ram[`MEM_SIZE-1] = 64'b0; 
end
endtask

////////////////////////////////////////////
//The actual test
////////////////////////////////////////////
task layer_test();
begin
  done = 0;
  //Start the actual test
  $display("Set enables to 1");
  //enable_matmul = 1;
  //enable_norm = 1;
  //enable_activation = 1;
  //enable_pool = 1;

  //reg value to enable all blocks (non conv mode)
  wdata = 32'h0000_000f;
  if ($test$plusargs("norm_disabled")) begin
    wdata &= 32'b1111_1111_1111_1111_1111_1111_1111_1101;
  end 
  if ($test$plusargs("pool_disabled")) begin
    wdata &= 32'b1111_1111_1111_1111_1111_1111_1111_1011;
  end 
  if ($test$plusargs("activation_disabled")) begin
    wdata &= 32'b1111_1111_1111_1111_1111_1111_1111_0111;
  end 
  write(`REG_ENABLES_ADDR, wdata);

  $display("Configure the value of mean and inv_variance");
  write(`REG_MEAN_ADDR, mean);
  write(`REG_INV_VAR_ADDR, inv_var);
  
  $display("Configure the value of num_matrices_A and num_matrices_B");
  write(`REG_NUM_MATRICES_A_ADDR, 32'h2);
  write(`REG_NUM_MATRICES_B_ADDR, 32'h2);
  
  $display("Configure the value of Pooling and Accumulator Signals");
  write(`REG_POOLING_ACCUM_ADDR, 32'b00000010000100000000100000000100);
  
  $display("-------------------------------------------");
  $display("Layer 0");
  $display("-------------------------------------------");
  $display("Configure the addresses of matrix A, B and C");
  write(`REG_MATRIX_A_ADDR, a_start_addr);
  write(`REG_MATRIX_B_ADDR, b_start_addr);
  //write(`REG_MATRIX_C_ADDR, c_start_addr); 
  //with this matmul, we need to enter the address of the last column
  write(`REG_MATRIX_C_ADDR, c_start_addr+((problem_size-1)*problem_size)); 

  $display("Start the TPU");
  //start = 1;
  write(`REG_STDN_TPU_ADDR, 32'h0000_0001);
  
  $display("Wait until TPU is done");
  
  while (done == 0)
  begin
      read(`REG_STDN_TPU_ADDR, rdata);
      done = rdata[31];
  end 
    
  $display("TPU operation is done now.");

end
endtask

endmodule
