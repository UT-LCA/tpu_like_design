module top(
    input start,
    input clk,
    input reset,
    input enable_matmul,
    input enable_norm,
    input enable_activation,
    input enable_pool
);

`define STATE_RST  4'b0000
`define STATE_INIT 4'b0001
`define STATE_MATMUL 4'b0010
`define STATE_NORM 4'b0011
`define STATE_DONE 4'b0100

//Top level state machine
    always @( posedge clk) begin
      if (reset) begin
        state <= STATE_RST;
        start_mat_mul <= 1'b0;
      end else begin
        case (state)
        `STATE_INIT: begin
          start_mat_mul <= 1'b1;
          state <= `STATE_MATMUL;
        end
        
        `STATE_MATMUL: begin
          start_mat_mul <= 1'b1;	      
          if (done_mat_mul == 1'b1) begin
              start_mat_mul <= 1'b0;
              state <= `STATE_NORM;
          end 
        end      
        
        `STATE_NORM: begin                 
          if (done_norm == 1'b1) begin
            state <= `STATE_DONE;
          end
        end

       `STATE_DONE: begin
          done <= 1;
       end
      endcase  
	end 
  end

endmodule