module adder_with_bram(
  input wire clk,
  input wire resetn,
  input wire start_add,
  input wire clear_done,
  output reg bram_en,
  output reg [3:0] bram_we,
  output reg [14:0] bram_addr,
  input wire [31:0] bram_rdata,
  output reg [31:0] bram_wdata
);

	reg [31:0] adder_ina;
	reg [31:0] adder_inb;
	reg [31:0] adder_out;
	reg [3:0] state;
	reg done_add;
	
	always @( posedge clk) begin
      if (resetn == 1'b0) begin
        state <= 4'b0000;
      end else begin
        case (state)
        4'b0000: begin 
	        bram_en <= 1'b0;
          adder_ina <= 32'b0;
          adder_inb <= 32'b0;
          adder_out <= 32'b0;
          done_add <= 1'b0;
          bram_wdata <= 32'b0;
          bram_addr <= 15'b0;
          if (start_add == 1'b1) begin
            state <= 4'b0001;
          end else begin
            state <= 4'b0000;
          end
        end
        
        4'b0001: begin
	        bram_en <= 1'b1;
          bram_we <= 4'b0000;
          bram_addr <= 15'h0;
          state <= 4'b1010;                    
        end    
        
        4'b1010: begin
          //just wait
	        bram_en <= 1'b1;
          state <= 4'b0010;   
        end
        
        4'b0010: begin
	        bram_en <= 1'b1;
          adder_ina <= bram_rdata;
          bram_we <= 4'b0000;
          bram_addr <= 15'h4;
          state <= 4'b1011;
        end    
        
        4'b1011: begin
          //just wait
	        bram_en <= 1'b1;
          state <= 4'b0011;
        end
        
        4'b0011: begin
	        bram_en <= 1'b1;
          adder_inb <= bram_rdata;
          state <= 4'b0100;
        end    
        
	      4'b0100: begin
          bram_en <= 1'b1;          
          adder_out <= adder_ina + adder_inb;
          state <= 4'b0101;
        end
        
        4'b0101: begin
          bram_en <= 1'b1;          
          bram_addr <= 15'h8;
          bram_wdata <= adder_out;
          bram_we <= 4'b1111;          
          state <= 4'b1110;
        end    

        4'b1110: begin
          //just wait
          bram_en <= 1'b1;          
          state <= 4'b0110;
        end
        
        4'b0110: begin
          bram_en <= 1'b1;
          bram_we <= 4'b0000; 
          done_add <= 1'b1;
          state <= 4'b0111;
        end 
        
        4'b0111: begin
          bram_en <= 1'b0;          
          if (clear_done == 1'b1) begin
            done_add <= 1'b0;
            state <= 4'b0000;
          end
          else begin
            state <= 4'b0111;
          end
        end
      endcase  
	end 
end

endmodule	
