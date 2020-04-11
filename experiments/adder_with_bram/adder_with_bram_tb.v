module ram (addr0, d0, we0, q0,  clk);

input [14:0] addr0;
input [31:0] d0;
input [3:0] we0;
output [31:0] q0;
input clk;

reg [31:0] q0;
reg [7:0] ram[(1<<15-1):0];

always @(posedge clk)  
begin 
        if (we0[0]) ram[addr0+0] <= d0[7:0]; 
        if (we0[1]) ram[addr0+1] <= d0[15:8]; 
        if (we0[2]) ram[addr0+2] <= d0[23:16]; 
        if (we0[3]) ram[addr0+3] <= d0[31:24]; 
        q0 <= {ram[addr0+3], ram[addr0+2], ram[addr0+1], ram[addr0]};
end

//single_port_ram u_single_port_ram(
//  .data(d0),
//  .we(we0),
//  .addr(addr0),
//  .clk(clk),
//  .out(q0)
//);
endmodule

module top;

wire [31:0] bram_rdata;
wire [31:0] bram_wdata;
wire [14:0] bram_addr;
wire [3:0] bram_we;
reg start_add;
reg clear_done;

reg clk;
reg resetn;

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

adder_with_bram u_adder_with_bram(
  .clk(clk),
  .resetn(resetn),
  .start_add(start_add),
  .clear_done(clear_done),
  .bram_en(),
  .bram_we(bram_we),
  .bram_addr(bram_addr),
  .bram_rdata(bram_rdata),
  .bram_wdata(bram_wdata)
);

ram u_ram(.addr0(bram_addr), .d0(bram_wdata), .we0(bram_we), .q0(bram_rdata), .clk(clk));

initial begin
  $vcdpluson;
  $vcdplusmemon;
end

initial begin
  force u_ram.ram[0] = 8'd4;
  force u_ram.ram[1] = 8'd4;
  force u_ram.ram[2] = 8'd4;
  force u_ram.ram[3] = 8'd4;
  force u_ram.ram[4] = 8'd3;
  force u_ram.ram[5] = 8'd3;
  force u_ram.ram[6] = 8'd3;
  force u_ram.ram[7] = 8'd3;
  start_add = 1'b0;
  #105 start_add = 1'b1;
  #1000 $finish;
end

endmodule
