module conv_test_no_padding();

task run();
begin
  initialize_brams();
  convolution_test();
  //compare_outputs();
end
endtask

reg done;
reg [`REG_DATAWIDTH-1:0] rdata;
reg [`REG_DATAWIDTH-1:0] wdata;
integer mean = 1;
integer inv_var = 1;

integer a_start_addr = 0;
integer b_start_addr = 0;
integer c_start_addr = 800;

reg [31:0] batch_size = 1;
reg [15:0] inp_channels = 3;
reg [15:0] out_channels = 2;
reg [15:0] inp_height = 8;
reg [15:0] inp_width = 8;
reg [15:0] out_height = 7;
reg [15:0] out_width = 7;
reg [3:0] filter_height = 2;
reg [3:0] filter_width = 2;
reg [3:0] stride_horizontal = 1;
reg [3:0] stride_vertical = 1;
reg [3:0] pad_left = 0;
reg [3:0] pad_right = 0;
reg [3:0] pad_top = 0;
reg [3:0] pad_bottom = 0;


////////////////////////////////////////////
// Note: Data layout is NCHW
// This means that the fastest changing dimension
// is W. That is, as address increases, we first change
// W, then H, then C and then N.
// Note: Layout is NT
// Matrix A (input activations) is N (not-transposed)
// Matrix B (weights) is T (transposed)
////////////////////////////////////////////

////////////////////////////////////////////
// 4D input matrix
////////////////////////////////////////////

/*
>>> a = np.random.randint(low=0, high=3,size=(1,3,8,8), dtype=np.uint8)
>>> a
array([[[[1, 1, 1, 1, 1, 1, 2, 0],
         [0, 1, 1, 1, 1, 2, 2, 1],
         [0, 0, 0, 2, 2, 0, 0, 2],
         [1, 0, 0, 2, 2, 2, 0, 1],
         [2, 2, 2, 2, 0, 2, 1, 1],
         [2, 1, 1, 2, 2, 1, 0, 0],
         [0, 0, 0, 0, 0, 1, 2, 2],
         [0, 2, 0, 2, 1, 0, 2, 1]],

        [[0, 1, 2, 2, 1, 0, 2, 0],
         [2, 0, 1, 1, 2, 0, 0, 2],
         [1, 1, 1, 0, 1, 0, 1, 1],
         [1, 0, 0, 0, 1, 2, 0, 2],
         [0, 1, 0, 2, 0, 1, 1, 1],
         [0, 2, 0, 1, 1, 0, 0, 0],
         [2, 0, 1, 1, 1, 0, 0, 2],
         [1, 2, 1, 0, 0, 0, 0, 1]],

        [[2, 0, 0, 2, 2, 2, 1, 2],
         [2, 2, 1, 1, 0, 1, 1, 0],
         [2, 2, 2, 0, 0, 1, 2, 2],
         [2, 2, 2, 0, 1, 1, 1, 1],
         [2, 0, 0, 0, 1, 0, 2, 2],
         [2, 1, 0, 1, 1, 0, 0, 2],
         [1, 2, 1, 1, 0, 0, 1, 2],
         [2, 0, 2, 1, 2, 1, 0, 1]]]], dtype=uint8)


*/


//                  N  C  H  W
reg [`DWIDTH-1:0] a[1][3][8][8] =
'{     '{'{'{8'd1, 8'd1, 8'd1, 8'd1, 8'd1, 8'd1, 8'd2, 8'd0},
         '{8'd0, 8'd1, 8'd1, 8'd1, 8'd1, 8'd2, 8'd2, 8'd1},
         '{8'd0, 8'd0, 8'd0, 8'd2, 8'd2, 8'd0, 8'd0, 8'd2},
         '{8'd1, 8'd0, 8'd0, 8'd2, 8'd2, 8'd2, 8'd0, 8'd1},
         '{8'd2, 8'd2, 8'd2, 8'd2, 8'd0, 8'd2, 8'd1, 8'd1},
         '{8'd2, 8'd1, 8'd1, 8'd2, 8'd2, 8'd1, 8'd0, 8'd0},
         '{8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd1, 8'd2, 8'd2},
         '{8'd0, 8'd2, 8'd0, 8'd2, 8'd1, 8'd0, 8'd2, 8'd1}},

        '{'{8'd0, 8'd1, 8'd2, 8'd2, 8'd1, 8'd0, 8'd2, 8'd0},
         '{8'd2, 8'd0, 8'd1, 8'd1, 8'd2, 8'd0, 8'd0, 8'd2},
         '{8'd1, 8'd1, 8'd1, 8'd0, 8'd1, 8'd0, 8'd1, 8'd1},
         '{8'd1, 8'd0, 8'd0, 8'd0, 8'd1, 8'd2, 8'd0, 8'd2},
         '{8'd0, 8'd1, 8'd0, 8'd2, 8'd0, 8'd1, 8'd1, 8'd1},
         '{8'd0, 8'd2, 8'd0, 8'd1, 8'd1, 8'd0, 8'd0, 8'd0},
         '{8'd2, 8'd0, 8'd1, 8'd1, 8'd1, 8'd0, 8'd0, 8'd2},
         '{8'd1, 8'd2, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0, 8'd1}},

        '{'{8'd2, 8'd0, 8'd0, 8'd2, 8'd2, 8'd2, 8'd1, 8'd2},
         '{8'd2, 8'd2, 8'd1, 8'd1, 8'd0, 8'd1, 8'd1, 8'd0},
         '{8'd2, 8'd2, 8'd2, 8'd0, 8'd0, 8'd1, 8'd2, 8'd2},
         '{8'd2, 8'd2, 8'd2, 8'd0, 8'd1, 8'd1, 8'd1, 8'd1},
         '{8'd2, 8'd0, 8'd0, 8'd0, 8'd1, 8'd0, 8'd2, 8'd2},
         '{8'd2, 8'd1, 8'd0, 8'd1, 8'd1, 8'd0, 8'd0, 8'd2},
         '{8'd1, 8'd2, 8'd1, 8'd1, 8'd0, 8'd0, 8'd1, 8'd2},
         '{8'd2, 8'd0, 8'd2, 8'd1, 8'd2, 8'd1, 8'd0, 8'd1}}}};



////////////////////////////////////////////
// 4D weights matrix
////////////////////////////////////////////
/*
>>> b = np.random.randint(low=0, high=3,size=(2,3,2,2), dtype=np.uint8)
>>> b
array([[[[1, 0],
         [2, 0]],

        [[0, 2],
         [1, 2]],

        [[0, 0],
         [0, 0]]],


       [[[2, 1],
         [2, 2]],

        [[0, 2],
         [0, 0]],

        [[2, 0],
         [2, 1]]]], dtype=uint8)

*/
//                  K  C  H  W
reg [`DWIDTH-1:0] b[2][3][2][2] =
'{     '{'{'{8'd1, 8'd0},
         '{8'd2, 8'd0}},

        '{'{8'd0, 8'd2},
         '{8'd1, 8'd2}},

        '{'{8'd0, 8'd0},
         '{8'd0, 8'd0}}},


       '{'{'{8'd2, 8'd1},
         '{8'd2, 8'd2}},

        '{'{8'd0, 8'd2},
         '{8'd0, 8'd0}},

        '{'{8'd2, 8'd0},
         '{8'd2, 8'd1}}}};

////////////////////////////////////////////
//Task to initialize BRAMs
////////////////////////////////////////////
task initialize_brams();
begin
  //NCHW
    for (int n=0; n<batch_size; n++) begin
      for (int c=0; c<inp_channels; c++) begin
        for (int h=0; h<inp_height; h++) begin
          for (int w=0; w<inp_width; w++) begin
            u_top.matrix_A.ram[
                a_start_addr +
                n * inp_channels * inp_height * inp_width +
                c * inp_height * inp_width +
                h * inp_width +
                w
            ] = a[n][c][h][w];
          end
        end    
      end
    end
  
  //NCHW transposed
    for (int w=0; w<filter_width; w++) begin
      for (int h=0; h<filter_height; h++) begin
        for (int c=0; c<inp_channels; c++) begin
          for (int n=0; n<out_channels; n++) begin
            u_top.matrix_B.ram[
                b_start_addr +
                w * out_channels * inp_channels * filter_height +
                h * out_channels * inp_channels +
                c * out_channels +
                n
            ] = b[n][c][h][w];
          end
        end    
      end
    end

end
endtask

////////////////////////////////////////////
//Task to compare outputs with expected values
////////////////////////////////////////////
task compare_outputs();
begin

end
endtask

////////////////////////////////////////////
//The actual test
////////////////////////////////////////////
task convolution_test();
begin
   done = 0;
  //Start the actual test
  $display("Set enables to 1");
  //enable_matmul = 1;
  //enable_norm = 1;
  //enable_activation = 1;
  //enable_pool = 1;
  //enable_conv_mode = 1;

  //reg value to enable all blocks
  wdata = 32'h8000_000f;
  if ($test$plusargs("norm_disabled")) begin
    wdata &= 32'b1111_1111_1111_1111_1111_1111_1111_1101;
  end 
  if ($test$plusargs("pool_disabled")) begin
    wdata &= 32'b1111_1111_1111_1111_1111_1111_1111_1011;
  end 
  if ($test$plusargs("activation_disabled")) begin
    wdata &= 32'b1111_1111_1111_1111_1111_1111_1111_0111;
  end 
  write(`REG_ENABLES_ADDR, wdata);
  read(`REG_ENABLES_ADDR, rdata);

  $display("Configure the value of mean and inv_variance");
  write(`REG_MEAN_ADDR, mean);
  write(`REG_INV_VAR_ADDR, inv_var);

  $display("Configure the addresses of matrix A, B and C");
  write(`REG_MATRIX_A_ADDR, a_start_addr);
  write(`REG_MATRIX_B_ADDR, b_start_addr);
  write(`REG_MATRIX_C_ADDR, c_start_addr);

  $display("Configure the convolution parameters");
  write(`REG_CONV_PARAMS_1_ADDR, {
    pad_bottom,
    pad_top,
    pad_right,
    pad_left,
    stride_vertical,
    stride_horizontal,
    filter_width,
    filter_height
  });

  write(`REG_CONV_PARAMS_2_ADDR, {
    out_channels,
    inp_channels
  });

  write(`REG_CONV_PARAMS_3_ADDR, {
    inp_width,
    inp_height
  });

  write(`REG_CONV_PARAMS_4_ADDR, {
    out_width,
    out_height
  });

  write(`REG_BATCH_SIZE_ADDR, batch_size);

  $display("Start the TPU");
  //start = 1;
  write(`REG_STDN_TPU_ADDR, 32'h0000_0001);
  
  $display("Wait until TPU is done");
  do 
  begin
      read(`REG_STDN_TPU_ADDR, rdata);
      done = rdata[31];
  end 
  while (done == 0);
  
  $display("TPU operation is done now.");

  $display("Stop the TPU");
  //start = 0;
  write(`REG_STDN_TPU_ADDR, 32'h0000_0000);

end
endtask

endmodule
