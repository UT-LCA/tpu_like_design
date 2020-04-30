module cfg(
    output start,
    output enable_matmul,
    output enable_norm,
    output enable_activation,
    output enable_pool,
    //TODO: We need to change the precision of compute to a larger 
    //number. For now, using the DWIDTH variable, but we need a 
    //HIGH_PRECISION_DWIDTH kind of thing
    output [`DWIDTH-1:0] mean,
    output [`DWIDTH-1:0] inv_var,
    input done
);

//TODO: For now, I'll force the inputs and ouputs of this block from
//the testbench. When we add a register interface to this block
//then the outputs will come from registers and inputs will be sinked 
//into registers

endmodule