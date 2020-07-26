`timescale 1ns/1ns
module top_tb();

reg clk;
reg reset;
wire resetn;
assign resetn = ~reset;

////////////////////////////////////////////
//Clock generation logic
////////////////////////////////////////////
initial begin
  clk = 0;
  forever begin
    #10 clk = ~clk;
  end
end

reg  [`REG_ADDRWIDTH-1:0] PADDR;
reg  PWRITE;
reg  PSEL;
reg  PENABLE;
reg  [`REG_DATAWIDTH-1:0] PWDATA;
wire [`REG_DATAWIDTH-1:0] PRDATA;
wire PREADY;
wire [`AWIDTH-1:0] bram_addr_a_ext;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_a_ext;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_a_ext;
wire [`MASK_WIDTH-1:0] bram_we_a_ext;
wire [`AWIDTH-1:0] bram_addr_b_ext;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_b_ext;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_b_ext;
wire [`MASK_WIDTH-1:0] bram_we_b_ext;
wire [`AWIDTH-1:0] bram_addr_c_ext;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_rdata_c_ext;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] bram_wdata_c_ext;
wire [`MASK_WIDTH-1:0] bram_we_c_ext;

////////////////////////////////////////////
//Instance of the DUT
////////////////////////////////////////////
top u_top(
    .clk(clk),
    .clk_mem(clk),
    .reset(reset),
    .resetn(resetn),
    .PADDR(PADDR),
    .PWRITE(PWRITE),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .*
);

////////////////////////////////////////////
//Task to write into the configuration block of the DUT
////////////////////////////////////////////
task write(input [`REG_ADDRWIDTH-1:0] addr, input [`REG_DATAWIDTH-1:0] data);
 begin
  @(negedge clk);
  PSEL = 1;
  PWRITE = 1;
  PADDR = addr;
  PWDATA = data;
	@(negedge clk);
  PENABLE = 1;
	@(negedge clk);
  PSEL = 0;
  PENABLE = 0;
  PWRITE = 0;
  PADDR = 0;
  PWDATA = 0;
  $display("%t: PADDR %h, PWDATA %h", $time, addr, data);
 end  
endtask

////////////////////////////////////////////
//Task to read from the configuration block of the DUT
////////////////////////////////////////////
task read(input [`REG_ADDRWIDTH-1:0] addr, output [`REG_DATAWIDTH-1:0] data);
begin 
	@(negedge clk);
	PSEL = 1;
	PWRITE = 0;
  PADDR = addr;
	@(negedge clk);
  PENABLE = 1;
	@(negedge clk);
  PSEL = 0;
  PENABLE = 0;
  data = PRDATA;
  PADDR = 0;
	$display("%t: PADDR %h, PRDATA %h",$time, addr,data);
end
endtask

////////////////////////////////////////////
// Instantiate the test modules
////////////////////////////////////////////
layer_test u_layer_test();

//For now, for the 16x16, I'm only testing the basic layer test
`ifndef MATMUL_SIZE_16
accum_test u_accum_test();
npo2_test u_npo2_test();
`endif

////////////////////////////////////////////
// Main routine. Calls the appropriate task
////////////////////////////////////////////
initial begin
  //Reset conditions
  reset = 1;
	PSEL = 0;
	PWRITE = 0;
  PADDR = 0;
  PWDATA = 0;
  PENABLE = 0;

  $display("Starting simulation");

  //Bring the design out of reset
  #55 reset = 0;

  //Wait for a clock or two
  #30;

  //Call the respective task
  if ($test$plusargs("layer_test")) begin
    u_layer_test.run();
  end 
//For now, for the 16x16, I'm only testing the basic layer test
`ifndef MATMUL_SIZE_16
  else if ($test$plusargs("accum_test")) begin
	  u_accum_test.run();
  end else if ($test$plusargs("npo2_test")) begin
	  u_npo2_test.run();
  end 
 `endif 
 
  $display("Finishing simulation");
  //A little bit of drain time before we finish
  #200;
  $finish;
end


//////////////////////////////////////////////
//Dump waves
//////////////////////////////////////////////
initial begin
  $vcdpluson;
  $vcdplusmemon;
end

endmodule
