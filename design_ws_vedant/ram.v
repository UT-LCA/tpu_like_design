//////////////////////////////////
// Dual port RAM
//////////////////////////////////
module ram (
        addr0, 
        d0, 
        we0, 
        q0,  
        addr1,
        d1,
        we1,
        q1,
        clk);
  
parameter AW = 11;
parameter MW = 8;
parameter DW = 8;

input [AW-1:0] addr0;
input [AW-1:0] addr1;
input [MW*DW-1:0] d0;
input [MW*DW-1:0] d1;
input [MW-1:0] we0;
input [MW-1:0] we1;
output reg [MW*DW-1:0] q0;
output reg [MW*DW-1:0] q1;
input clk;

`ifndef hard_mem
reg [MW*DW-1:0] ram[((1 << AW)-1):0];
  
wire we0_coalesced;
assign we0_coalesced = |we0;
wire we1_coalesced;
assign we1_coalesced = |we1;

always @(posedge clk) begin 
    if (we0_coalesced) ram[addr0] <= d0; 
    q0 <= ram[addr0];    
end

always @(posedge clk) begin 
    if (we1_coalesced) ram[addr1] <= d1; 
    q1 <= ram[addr1];  
end
  
`else

defparam u_dual_port_ram.ADDR_WIDTH = AW;
defparam u_dual_port_ram.DATA_WIDTH = MW*DW;

dual_port_ram u_dual_port_ram(
.addr1(addr0),
.we1(we0_coalesced),
.data1(d0),
.out1(q0),
.addr2(addr1),
.we2(we1_coalesced),
.data2(d1),
.out2(q1),
.clk(clk)
);

`endif

endmodule

