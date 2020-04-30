//Top level state machine
module control(
    input clk,
    input reset,
    input start,
    output reg start_mat_mul,
    input done_mat_mul,
    input done_norm,
    output reg done_all
);

reg [3:0] state;

`define STATE_INIT 4'b0000
`define STATE_MATMUL 4'b0010
`define STATE_NORM 4'b0011
`define STATE_DONE 4'b0100

always @( posedge clk) begin
    if (reset || ~start) begin
      state <= `STATE_INIT;
      start_mat_mul <= 1'b0;
      done_all <= 1'b0;
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
        done_all <= 1;
      end
      endcase  
    end 
end
endmodule