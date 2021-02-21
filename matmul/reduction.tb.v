
`timescale 1ns/1ns
module tb;

reg clk;
reg resetn;
reg start;

reduction_layer u_red(
  .clk(clk), 
  .resetn(resetn),
  .start(start),
  .start_addr(11'd0),
  .end_addr(11'd5),
  .reduction_type(2'd1),
  .reduced_out(),
  .done()
  );

initial begin
  clk = 0;
  forever begin
    #10 clk = ~clk;
  end
end

initial begin
  resetn = 0;
  #55 resetn = 1;
end


initial begin
  start = 0;
  #115 start = 1;
  #150 start = 0;
  #400;
  $finish;
end

//reg [19:0] data [0:3];
initial begin
  $readmemh("reduction_mem.txt", u_red.in_data.ram);
  //$readmemh("reduction_mem.txt", data);
end

initial begin
  $vcdpluson;
  $vcdplusmemon;
end

endmodule

