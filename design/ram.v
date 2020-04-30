module ram (addr0, d0, we0, q0,  clk);

input [`AWIDTH-1:0] addr0;
input [`MASK_WIDTH*`DWIDTH-1:0] d0;
input [`MASK_WIDTH-1:0] we0;
output [`MASK_WIDTH*`DWIDTH-1:0] q0;
input clk;

reg [`MASK_WIDTH*`DWIDTH-1:0] q0;
reg [7:0] ram[((1<<`AWIDTH)-1):0];

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