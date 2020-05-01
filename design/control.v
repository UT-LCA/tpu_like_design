//Top level state machine
module control(
    input clk,
    input reset,
    input start_tpu,
    input enable_matmul,
    input enable_norm,
    input enable_activation,
    input enable_pool,
    output reg start_mat_mul,
    input done_mat_mul,
    input done_norm,
    output reg done_tpu
);

reg [3:0] state;

`define STATE_INIT 4'b0000
`define STATE_MATMUL 4'b0001
`define STATE_NORM 4'b0010
`define STATE_DONE 4'b0011

always @( posedge clk) begin
    if (reset) begin
      state <= `STATE_INIT;
      start_mat_mul <= 1'b0;
      done_tpu <= 1'b0;
    end else begin
      case (state)
      `STATE_INIT: begin
        if ((start_tpu == 1'b1) && (done_tpu == 1'b0)) begin
          if (enable_matmul == 1'b1) begin
            start_mat_mul <= 1'b1;
            state <= `STATE_MATMUL;
          end  
        end  
      end
      
      //start_mat_mul is kinda used as a reset in some logic
      //inside the matmul unit. So, we can't make it 0 right away after
      //asserting it.
      //TODO: I think we can change this behavior. This currently leads to 
      //one extra wasted cycle
      `STATE_MATMUL: begin
        start_mat_mul <= 1'b1;	      
        if (done_mat_mul == 1'b1) begin
            start_mat_mul <= 1'b0;
            if (enable_norm) begin
              //Currently there is no start_norm on the norm block.
              //It starts when the matmul's data_available signal becomes 1.
              //But we should have a consistent interface for all blocks.
              //TODO: Think about how to handle this
              //start_norm <= 1'b1;
              state <= `STATE_NORM;
            end 
            else begin
              state <= `STATE_DONE;
            end  
        end 
      end      
      
      `STATE_NORM: begin                 
        if (done_norm == 1'b1) begin
          state <= `STATE_DONE;
        end
      end

      `STATE_DONE: begin
        done_tpu <= 1;
        state <= `STATE_INIT;
      end
      endcase  
    end 
end
endmodule