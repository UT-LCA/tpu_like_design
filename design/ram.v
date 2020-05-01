//////////////////////////////////
//Dual port RAM
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

input [`AWIDTH-1:0] addr0;
input [`AWIDTH-1:0] addr1;
input [`MASK_WIDTH*`DWIDTH-1:0] d0;
input [`MASK_WIDTH*`DWIDTH-1:0] d1;
input [`MASK_WIDTH-1:0] we0;
input [`MASK_WIDTH-1:0] we1;
output reg [`MASK_WIDTH*`DWIDTH-1:0] q0;
output reg [`MASK_WIDTH*`DWIDTH-1:0] q1;
input clk;

reg [7:0] ram[((1<<`AWIDTH)-1):0];

always @(posedge clk)  
begin 
        if (we0[0]) ram[addr0+0] <= d0[7:0]; 
        if (we0[1]) ram[addr0+1] <= d0[15:8]; 
        if (we0[2]) ram[addr0+2] <= d0[23:16]; 
        if (we0[3]) ram[addr0+3] <= d0[31:24]; 
        q0 <= {ram[addr0+3], ram[addr0+2], ram[addr0+1], ram[addr0]};
end

always @(posedge clk)  
begin 
        if (we1[0]) ram[addr1+0] <= d1[7:0]; 
        if (we1[1]) ram[addr1+1] <= d1[15:8]; 
        if (we1[2]) ram[addr1+2] <= d1[23:16]; 
        if (we1[3]) ram[addr1+3] <= d1[31:24]; 
        q1 <= {ram[addr1+3], ram[addr1+2], ram[addr1+1], ram[addr1]};
end

endmodule