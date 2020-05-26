module top();

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

initial begin
   reset = 1; 
   #55 reset = 0; 
   #1000 $finish;
end

reg [3:0] c;
reg [3:0] r;
reg [3:0] s;
reg [3:0] C=4;
reg [3:0] R=3;
reg [3:0] S=3;


//This code is the Verilog eqivalent of a 3 tiered for loop:
// for (c = 0; c < C; c++) {
//    for (r = 0; r < R; r++) {
//        for (s = 0; s < S; s++) {
//            print (c,r,s)
//        }
//    }
//}
always @(posedge clk) begin
    if (reset) begin
        c <= 0;
        r <= 0;
        s <= 0;
    end 
    else begin
        if (s < (S-1)) begin
            s <= s + 1;
        end else begin
            s <= 0;
        end 

        if (s == (S-1)) begin
            if (r == (R-1)) begin
                r <= 0;
            end else begin
                r <= r + 1;
            end
        end 

        if ((r == (R-1)) && (s == (S-1))) begin
            if (c == (C-1)) begin
                c <= 0;
            end else begin
                c <= c + 1;
            end
        end
    end 
end

initial begin
  $vcdpluson;
  $vcdplusmemon;
end

endmodule
