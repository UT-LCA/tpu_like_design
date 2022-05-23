module accum_test();

reg done;
reg [`REG_DATAWIDTH-1:0] rdata;
reg [`REG_DATAWIDTH-1:0] wdata;

task run();
begin
  initialize_brams();
  accumulator_test();
  compare_outputs();
end
endtask

integer mean = 1;
integer inv_var = 1;

`ifdef DESIGN_SIZE_4
integer a_start_addr = 0;
integer b_start_addr = 0;
integer c_start_addr = 200;//TODO: Need to fix this based on the updated matmul that takes c_addr from the last column
integer problem_size = 12;

//////////////////////////////////////////////
//Initialize BRAMs A and B
//////////////////////////////////////////////
//>>> print(a)
//[[2 2 1 0 2 0 1 0 2 1 2 2]
// [0 1 1 2 0 2 0 1 2 2 1 2]
// [1 1 2 1 2 2 2 2 2 0 2 1]
// [1 0 0 2 0 1 1 0 2 1 2 0]
// [2 2 0 0 2 1 2 1 1 2 2 1]
// [1 2 0 0 0 0 2 0 0 1 1 0]
// [0 1 0 2 1 2 1 1 0 1 2 2]
// [0 0 0 1 2 1 1 1 1 2 1 2]
// [2 0 0 1 1 1 1 1 2 2 1 0]
// [2 0 0 1 2 2 1 0 1 1 0 2]
// [2 1 2 0 1 1 0 0 0 0 0 1]
// [1 2 1 0 2 2 0 1 0 0 0 1]]
//>>> print(b)
//[[0 0 0 2 0 1 2 1 2 0 0 2]
// [1 1 1 2 2 2 1 2 2 2 0 0]
// [0 0 0 0 0 1 2 0 0 0 1 0]
// [0 1 2 1 0 1 1 2 0 2 2 1]
// [0 0 0 1 0 1 0 2 2 1 2 2]
// [0 1 0 2 1 1 0 0 2 2 2 0]
// [2 0 1 2 2 0 1 0 1 2 2 0]
// [2 2 1 0 2 1 1 0 0 1 0 1]
// [0 0 0 1 1 1 0 2 1 0 0 1]
// [0 1 1 0 1 2 1 0 1 0 1 1]
// [1 0 1 1 0 1 2 2 1 1 0 2]
// [0 0 1 1 0 2 1 0 1 0 2 1]]
//>>> print(c)
//[[ 6  3  8 18  9 19 16 18 20 10 12 17]
// [ 4  9 11 13 10 19 12 12 13 12 15 11]
// [11  8 10 20 14 18 17 17 19 18 18 16]
// [ 4  4  8 12  6 10 10 13 10 10  9 11]
// [10  7 10 20 14 19 16 16 22 15 14 17]
// [ 7  3  6 11  9  8  9  7 10  9  5  5]
// [ 7  8 12 15  9 16 12 12 14 16 17 12]
// [ 5  6  9 11  8 15  9 10 13 10 16 13]
// [ 5  6  7 13  9 13 11 12 14  9 10 14]
// [ 2  4  6 16  6 14  9 10 17 10 17 13]
// [ 1  2  2 10  3 10 10  6 11  5  8  7]
// [ 4  6  4 13  8 13  8  9 15 11 11  8]]
//>>> np.set_printoptions(formatter={'int':hex})
//>>> print(c)
//[[0x6 0x3 0x8 0x12 0x9 0x13 0x10 0x12 0x14 0xa 0xc 0x11]
// [0x4 0x9 0xb 0xd 0xa 0x13 0xc 0xc 0xd 0xc 0xf 0xb]
// [0xb 0x8 0xa 0x14 0xe 0x12 0x11 0x11 0x13 0x12 0x12 0x10]
// [0x4 0x4 0x8 0xc 0x6 0xa 0xa 0xd 0xa 0xa 0x9 0xb]
// [0xa 0x7 0xa 0x14 0xe 0x13 0x10 0x10 0x16 0xf 0xe 0x11]
// [0x7 0x3 0x6 0xb 0x9 0x8 0x9 0x7 0xa 0x9 0x5 0x5]
// [0x7 0x8 0xc 0xf 0x9 0x10 0xc 0xc 0xe 0x10 0x11 0xc]
// [0x5 0x6 0x9 0xb 0x8 0xf 0x9 0xa 0xd 0xa 0x10 0xd]
// [0x5 0x6 0x7 0xd 0x9 0xd 0xb 0xc 0xe 0x9 0xa 0xe]
// [0x2 0x4 0x6 0x10 0x6 0xe 0x9 0xa 0x11 0xa 0x11 0xd]
// [0x1 0x2 0x2 0xa 0x3 0xa 0xa 0x6 0xb 0x5 0x8 0x7]
// [0x4 0x6 0x4 0xd 0x8 0xd 0x8 0x9 0xf 0xb 0xb 0x8]]
//
reg [`DWIDTH-1:0] a[12][12] = 
'{{8'd2,8'd2,8'd1,8'd0,8'd2,8'd0,8'd1,8'd0,8'd2,8'd1,8'd2,8'd2},
  {8'd0,8'd1,8'd1,8'd2,8'd0,8'd2,8'd0,8'd1,8'd2,8'd2,8'd1,8'd2},
  {8'd1,8'd1,8'd2,8'd1,8'd2,8'd2,8'd2,8'd2,8'd2,8'd0,8'd2,8'd1},
  {8'd1,8'd0,8'd0,8'd2,8'd0,8'd1,8'd1,8'd0,8'd2,8'd1,8'd2,8'd0},
  {8'd2,8'd2,8'd0,8'd0,8'd2,8'd1,8'd2,8'd1,8'd1,8'd2,8'd2,8'd1},
  {8'd1,8'd2,8'd0,8'd0,8'd0,8'd0,8'd2,8'd0,8'd0,8'd1,8'd1,8'd0},
  {8'd0,8'd1,8'd0,8'd2,8'd1,8'd2,8'd1,8'd1,8'd0,8'd1,8'd2,8'd2},
  {8'd0,8'd0,8'd0,8'd1,8'd2,8'd1,8'd1,8'd1,8'd1,8'd2,8'd1,8'd2},
  {8'd2,8'd0,8'd0,8'd1,8'd1,8'd1,8'd1,8'd1,8'd2,8'd2,8'd1,8'd0},
  {8'd2,8'd0,8'd0,8'd1,8'd2,8'd2,8'd1,8'd0,8'd1,8'd1,8'd0,8'd2},
  {8'd2,8'd1,8'd2,8'd0,8'd1,8'd1,8'd0,8'd0,8'd0,8'd0,8'd0,8'd1},
  {8'd1,8'd2,8'd1,8'd0,8'd2,8'd2,8'd0,8'd1,8'd0,8'd0,8'd0,8'd1}};

reg [`DWIDTH-1:0] b[12][12] =   
'{{8'd0,8'd0,8'd0,8'd2,8'd0,8'd1,8'd2,8'd1,8'd2,8'd0,8'd0,8'd2},
  {8'd1,8'd1,8'd1,8'd2,8'd2,8'd2,8'd1,8'd2,8'd2,8'd2,8'd0,8'd0},
  {8'd0,8'd0,8'd0,8'd0,8'd0,8'd1,8'd2,8'd0,8'd0,8'd0,8'd1,8'd0},
  {8'd0,8'd1,8'd2,8'd1,8'd0,8'd1,8'd1,8'd2,8'd0,8'd2,8'd2,8'd1},
  {8'd0,8'd0,8'd0,8'd1,8'd0,8'd1,8'd0,8'd2,8'd2,8'd1,8'd2,8'd2},
  {8'd0,8'd1,8'd0,8'd2,8'd1,8'd1,8'd0,8'd0,8'd2,8'd2,8'd2,8'd0},
  {8'd2,8'd0,8'd1,8'd2,8'd2,8'd0,8'd1,8'd0,8'd1,8'd2,8'd2,8'd0},
  {8'd2,8'd2,8'd1,8'd0,8'd2,8'd1,8'd1,8'd0,8'd0,8'd1,8'd0,8'd1},
  {8'd0,8'd0,8'd0,8'd1,8'd1,8'd1,8'd0,8'd2,8'd1,8'd0,8'd0,8'd1},
  {8'd0,8'd1,8'd1,8'd0,8'd1,8'd2,8'd1,8'd0,8'd1,8'd0,8'd1,8'd1},
  {8'd1,8'd0,8'd1,8'd1,8'd0,8'd1,8'd2,8'd2,8'd1,8'd1,8'd0,8'd2},
  {8'd0,8'd0,8'd1,8'd1,8'd0,8'd2,8'd1,8'd0,8'd1,8'd0,8'd2,8'd1}};

reg [`DWIDTH-1:0] c[12][12] =   
'{{8'd06,8'd03,8'd08,8'd18,8'd09,8'd19,8'd16,8'd18,8'd20,8'd10,8'd12,8'd17},
  {8'd04,8'd09,8'd11,8'd13,8'd10,8'd19,8'd12,8'd12,8'd13,8'd12,8'd15,8'd11},
  {8'd11,8'd08,8'd10,8'd20,8'd14,8'd18,8'd17,8'd17,8'd19,8'd18,8'd18,8'd16},
  {8'd04,8'd04,8'd08,8'd12,8'd06,8'd10,8'd10,8'd13,8'd10,8'd10,8'd09,8'd11},
  {8'd10,8'd07,8'd10,8'd20,8'd14,8'd19,8'd16,8'd16,8'd22,8'd15,8'd14,8'd17},
  {8'd07,8'd03,8'd06,8'd11,8'd09,8'd08,8'd09,8'd07,8'd10,8'd09,8'd05,8'd05},
  {8'd07,8'd08,8'd12,8'd15,8'd09,8'd16,8'd12,8'd12,8'd14,8'd16,8'd17,8'd12},
  {8'd05,8'd06,8'd09,8'd11,8'd08,8'd15,8'd09,8'd10,8'd13,8'd10,8'd16,8'd13},
  {8'd05,8'd06,8'd07,8'd13,8'd09,8'd13,8'd11,8'd12,8'd14,8'd09,8'd10,8'd14},
  {8'd02,8'd04,8'd06,8'd16,8'd06,8'd14,8'd09,8'd10,8'd17,8'd10,8'd17,8'd13},
  {8'd01,8'd02,8'd02,8'd10,8'd03,8'd10,8'd10,8'd06,8'd11,8'd05,8'd08,8'd07},
  {8'd04,8'd06,8'd04,8'd13,8'd08,8'd13,8'd08,8'd09,8'd15,8'd11,8'd11,8'd8}};
`endif

`ifdef DESIGN_SIZE_8
integer a_start_addr = 0;
integer b_start_addr = 0;
integer c_start_addr = 600;//TODO: Need to fix this based on the updated matmul that takes c_addr from the last column
integer problem_size = 24;

//////////////////////////////////////////////
//Initialize BRAMs A and B
//////////////////////////////////////////////
/*
>>> a = np.random.randint(low=0, high=3,size=(24,24), dtype=np.uint8)
>>> print(a)
[[1 2 2 1 0 0 2 0 0 0 1 1 0 1 1 2 1 2 1 0 0 1 2 1]
 [1 0 1 0 2 0 0 1 2 0 0 1 1 2 1 0 0 0 1 1 2 0 0 0]
 [2 0 0 2 0 1 1 0 0 2 0 1 1 1 1 1 0 2 1 1 0 1 1 0]
 [2 2 2 1 1 0 0 1 2 1 1 1 2 2 2 1 0 2 2 2 2 1 0 2]
 [0 0 2 0 1 0 2 1 1 1 2 0 0 2 0 0 0 2 2 0 1 1 0 0]
 [0 1 1 0 2 0 0 2 2 1 1 1 1 2 2 2 0 0 1 2 2 0 1 2]
 [2 0 1 1 1 1 1 0 1 0 2 1 0 0 1 0 1 2 2 0 0 0 0 0]
 [2 1 1 0 1 2 0 0 1 0 1 0 1 1 0 2 2 0 1 1 1 2 0 2]
 [2 0 1 2 0 0 1 1 0 1 0 1 2 0 2 1 1 1 0 0 0 0 0 2]
 [2 2 2 1 2 0 2 1 0 0 2 0 1 2 1 1 0 1 2 1 1 0 2 0]
 [2 0 0 2 2 2 2 0 0 0 1 2 2 0 2 2 0 2 0 2 0 1 0 2]
 [0 2 1 0 1 1 0 2 0 0 2 1 1 2 1 2 0 1 1 0 0 2 0 2]
 [0 1 2 1 1 0 2 0 0 1 1 1 1 0 2 2 2 1 1 1 1 1 2 1]
 [0 2 0 1 0 1 1 1 1 0 2 0 0 2 2 0 0 2 2 1 0 1 1 0]
 [2 1 2 1 0 0 0 0 1 0 2 0 0 2 0 2 2 1 0 2 1 0 2 1]
 [1 0 2 0 2 0 1 1 2 1 2 0 2 0 0 0 1 1 1 1 1 1 1 1]
 [2 0 2 1 1 0 1 0 0 1 0 0 0 1 2 1 2 2 1 2 0 1 1 1]
 [1 2 1 0 0 1 0 2 1 1 2 1 2 2 0 0 0 2 1 2 1 1 1 1]
 [2 2 0 2 0 1 2 0 2 2 1 2 1 1 0 1 2 2 0 1 2 2 1 0]
 [1 2 0 1 2 0 2 2 2 1 2 1 1 2 0 1 2 2 1 1 2 1 2 1]
 [0 1 2 1 0 1 2 1 2 2 2 2 2 2 0 1 2 1 1 1 2 0 0 0]
 [2 2 1 0 2 1 0 2 1 1 2 1 2 0 2 0 2 0 2 1 0 2 1 0]
 [0 0 1 2 0 2 1 2 2 2 2 0 2 1 0 0 0 1 1 0 2 2 0 2]
 [0 0 2 2 1 2 0 0 1 1 1 1 1 1 2 1 0 2 2 1 0 2 0 1]]
>>> b = np.random.randint(low=0, high=3,size=(24,24), dtype=np.uint8)
>>> print(b)
[[2 1 0 0 2 2 0 0 0 0 1 1 0 1 1 0 0 1 2 0 1 0 0 1]
 [2 2 0 2 0 2 0 2 2 0 0 1 0 2 1 2 1 2 0 2 2 0 2 1]
 [1 1 0 1 0 0 1 2 2 0 1 0 0 1 2 2 2 2 2 0 0 0 1 2]
 [1 0 1 1 2 0 1 1 2 1 2 0 2 1 1 2 2 1 1 2 2 0 0 1]
 [1 2 2 0 2 2 2 1 0 2 1 1 0 1 1 0 2 2 2 2 0 0 1 1]
 [1 2 0 1 2 0 1 2 2 1 2 2 0 1 1 0 1 1 2 0 1 1 0 2]
 [1 1 2 2 1 0 1 1 1 2 1 1 0 0 2 2 1 2 1 1 2 2 2 0]
 [1 1 0 2 0 2 0 0 1 2 0 2 0 2 2 1 1 0 0 0 0 0 2 2]
 [2 2 2 2 0 1 2 1 0 0 2 0 0 2 0 0 0 1 1 0 0 1 0 1]
 [2 1 2 1 1 2 0 0 2 0 0 2 1 0 2 0 1 0 2 2 0 2 1 0]
 [2 2 0 1 0 2 2 2 2 2 1 2 2 2 2 1 1 1 2 1 2 0 1 0]
 [0 1 0 1 2 2 2 2 0 1 1 2 1 2 0 2 1 1 2 1 1 1 0 0]
 [2 0 0 0 2 2 0 2 0 1 0 0 1 0 1 0 2 0 2 1 0 0 2 1]
 [0 0 0 0 2 0 0 2 1 1 0 0 2 1 2 1 0 1 2 2 0 1 1 1]
 [0 0 1 1 1 2 2 2 1 0 1 2 2 1 1 1 2 1 1 1 0 0 2 0]
 [0 1 1 0 2 2 1 1 0 0 2 1 2 0 1 1 2 1 2 2 0 1 1 2]
 [2 0 1 1 1 0 1 1 2 1 2 2 0 2 1 2 2 0 0 2 0 0 2 1]
 [2 1 0 2 2 2 0 2 0 0 0 2 1 0 1 1 1 1 0 0 0 1 1 1]
 [1 0 2 0 1 2 2 2 1 1 0 1 0 2 0 2 2 2 1 1 1 0 0 1]
 [0 0 2 0 1 0 0 1 2 0 0 1 1 0 1 0 0 2 2 0 2 2 2 2]
 [2 1 0 0 2 2 2 1 1 1 1 0 0 1 2 1 0 0 2 0 1 2 2 1]
 [0 0 1 2 0 2 2 0 1 2 0 2 0 1 2 2 0 1 1 2 1 2 1 2]
 [0 2 1 0 0 1 2 1 0 1 2 1 2 0 1 1 1 0 2 1 2 2 0 2]
 [1 2 1 1 0 1 1 2 0 1 1 0 2 0 2 1 0 2 2 1 0 2 2 1]]
>>> c=np.matmul(a,b)
>>> print(c)
[[21 22 15 22 21 27 23 32 20 16 21 24 21 19 28 32 26 27 28 25 20 18 23 24]
 [17 14 13  9 21 22 19 21 11 13 12 11  9 19 18 12 14 17 26 12  7 11 17 17]
 [19 13 16 15 28 25 15 22 17 12 15 23 19 12 22 18 20 18 28 20 16 18 15 19]
 [37 28 23 26 35 46 30 45 28 20 21 28 26 31 39 31 30 37 46 28 20 24 37 34]
 [22 17 15 19 17 23 20 25 19 19 10 19 11 19 27 22 18 22 24 16 12 15 19 17]
 [24 27 23 18 26 37 29 35 21 20 21 23 25 25 33 22 25 28 41 25 14 23 33 29]
 [23 17 13 16 21 23 21 25 16 14 17 22 11 21 17 19 21 21 22 13 14  7 12 14]
 [25 22 16 16 24 27 23 28 21 18 22 22 14 22 28 21 20 25 34 23 14 18 24 29]
 [21 13 12 16 23 24 14 23 14 12 17 18 19 13 23 19 23 17 25 18  9 11 22 16]
 [28 26 19 18 28 34 26 36 25 23 20 24 21 25 34 29 30 32 38 26 25 16 28 28]
 [24 24 21 21 38 34 26 36 19 22 25 30 26 17 30 23 29 32 41 25 21 22 28 26]
 [20 23 11 22 20 34 22 33 20 22 14 26 21 24 31 26 23 26 30 26 13 15 27 26]
 [24 22 23 21 25 31 30 34 25 20 25 28 23 20 32 32 33 27 35 29 20 22 31 26]
 [20 18 15 22 18 26 21 31 23 17 13 25 19 23 24 24 20 24 22 20 20 14 21 20]
 [24 22 14 14 22 22 20 29 23 13 24 19 23 20 29 23 20 23 34 21 19 18 23 28]
 [30 24 20 19 19 30 25 27 19 21 18 21 13 21 29 19 23 23 33 18 14 17 25 24]
 [21 15 21 17 25 24 20 27 22 13 19 25 19 16 28 24 25 26 30 22 14 18 25 25]
 [30 25 13 23 24 35 19 35 25 20 13 27 20 25 33 23 20 25 35 20 20 21 29 29]
 [37 27 22 30 35 37 28 33 29 22 27 33 20 28 35 32 25 26 38 31 27 29 29 28]
 [39 34 26 30 33 43 33 39 28 31 27 34 24 33 41 34 30 31 41 34 26 28 37 33]
 [36 25 20 26 32 32 27 39 32 23 24 28 20 30 36 31 30 26 40 27 20 23 32 26]
 [32 25 21 24 24 42 30 33 28 25 20 36 15 34 31 27 32 27 35 28 20 13 30 29]
 [33 25 18 27 24 32 26 31 27 26 20 24 19 24 37 24 22 22 36 22 17 24 27 27]
 [22 19 20 22 28 30 28 36 25 18 20 27 22 22 28 26 29 29 35 24 15 18 21 27]]
>>> np.set_printoptions(formatter={'int':hex})
>>> print(c)
[[0x15 0x16 0xf 0x16 0x15 0x1b 0x17 0x20 0x14 0x10 0x15 0x18 0x15 0x13 0x1c 0x20 0x1a 0x1b 0x1c 0x19 0x14 0x12 0x17 0x18]
 [0x11 0xe 0xd 0x9 0x15 0x16 0x13 0x15 0xb 0xd 0xc 0xb 0x9 0x13 0x12 0xc 0xe 0x11 0x1a 0xc 0x7 0xb 0x11 0x11]
 [0x13 0xd 0x10 0xf 0x1c 0x19 0xf 0x16 0x11 0xc 0xf 0x17 0x13 0xc 0x16 0x12 0x14 0x12 0x1c 0x14 0x10 0x12 0xf 0x13]
 [0x25 0x1c 0x17 0x1a 0x23 0x2e 0x1e 0x2d 0x1c 0x14 0x15 0x1c 0x1a 0x1f 0x27 0x1f 0x1e 0x25 0x2e 0x1c 0x14 0x18 0x25 0x22]
 [0x16 0x11 0xf 0x13 0x11 0x17 0x14 0x19 0x13 0x13 0xa 0x13 0xb 0x13 0x1b 0x16 0x12 0x16 0x18 0x10 0xc 0xf 0x13 0x11]
 [0x18 0x1b 0x17 0x12 0x1a 0x25 0x1d 0x23 0x15 0x14 0x15 0x17 0x19 0x19 0x21 0x16 0x19 0x1c 0x29 0x19 0xe 0x17 0x21 0x1d]
 [0x17 0x11 0xd 0x10 0x15 0x17 0x15 0x19 0x10 0xe 0x11 0x16 0xb 0x15 0x11 0x13 0x15 0x15 0x16 0xd 0xe 0x7 0xc 0xe]
 [0x19 0x16 0x10 0x10 0x18 0x1b 0x17 0x1c 0x15 0x12 0x16 0x16 0xe 0x16 0x1c 0x15 0x14 0x19 0x22 0x17 0xe 0x12 0x18 0x1d]
 [0x15 0xd 0xc 0x10 0x17 0x18 0xe 0x17 0xe 0xc 0x11 0x12 0x13 0xd 0x17 0x13 0x17 0x11 0x19 0x12 0x9 0xb 0x16 0x10]
 [0x1c 0x1a 0x13 0x12 0x1c 0x22 0x1a 0x24 0x19 0x17 0x14 0x18 0x15 0x19 0x22 0x1d 0x1e 0x20 0x26 0x1a 0x19 0x10 0x1c 0x1c]
 [0x18 0x18 0x15 0x15 0x26 0x22 0x1a 0x24 0x13 0x16 0x19 0x1e 0x1a 0x11 0x1e 0x17 0x1d 0x20 0x29 0x19 0x15 0x16 0x1c 0x1a]
 [0x14 0x17 0xb 0x16 0x14 0x22 0x16 0x21 0x14 0x16 0xe 0x1a 0x15 0x18 0x1f 0x1a 0x17 0x1a 0x1e 0x1a 0xd 0xf 0x1b 0x1a]
 [0x18 0x16 0x17 0x15 0x19 0x1f 0x1e 0x22 0x19 0x14 0x19 0x1c 0x17 0x14 0x20 0x20 0x21 0x1b 0x23 0x1d 0x14 0x16 0x1f 0x1a]
 [0x14 0x12 0xf 0x16 0x12 0x1a 0x15 0x1f 0x17 0x11 0xd 0x19 0x13 0x17 0x18 0x18 0x14 0x18 0x16 0x14 0x14 0xe 0x15 0x14]
 [0x18 0x16 0xe 0xe 0x16 0x16 0x14 0x1d 0x17 0xd 0x18 0x13 0x17 0x14 0x1d 0x17 0x14 0x17 0x22 0x15 0x13 0x12 0x17 0x1c]
 [0x1e 0x18 0x14 0x13 0x13 0x1e 0x19 0x1b 0x13 0x15 0x12 0x15 0xd 0x15 0x1d 0x13 0x17 0x17 0x21 0x12 0xe 0x11 0x19 0x18]
 [0x15 0xf 0x15 0x11 0x19 0x18 0x14 0x1b 0x16 0xd 0x13 0x19 0x13 0x10 0x1c 0x18 0x19 0x1a 0x1e 0x16 0xe 0x12 0x19 0x19]
 [0x1e 0x19 0xd 0x17 0x18 0x23 0x13 0x23 0x19 0x14 0xd 0x1b 0x14 0x19 0x21 0x17 0x14 0x19 0x23 0x14 0x14 0x15 0x1d 0x1d]
 [0x25 0x1b 0x16 0x1e 0x23 0x25 0x1c 0x21 0x1d 0x16 0x1b 0x21 0x14 0x1c 0x23 0x20 0x19 0x1a 0x26 0x1f 0x1b 0x1d 0x1d 0x1c]
 [0x27 0x22 0x1a 0x1e 0x21 0x2b 0x21 0x27 0x1c 0x1f 0x1b 0x22 0x18 0x21 0x29 0x22 0x1e 0x1f 0x29 0x22 0x1a 0x1c 0x25 0x21]
 [0x24 0x19 0x14 0x1a 0x20 0x20 0x1b 0x27 0x20 0x17 0x18 0x1c 0x14 0x1e 0x24 0x1f 0x1e 0x1a 0x28 0x1b 0x14 0x17 0x20 0x1a]
 [0x20 0x19 0x15 0x18 0x18 0x2a 0x1e 0x21 0x1c 0x19 0x14 0x24 0xf 0x22 0x1f 0x1b 0x20 0x1b 0x23 0x1c 0x14 0xd 0x1e 0x1d]
 [0x21 0x19 0x12 0x1b 0x18 0x20 0x1a 0x1f 0x1b 0x1a 0x14 0x18 0x13 0x18 0x25 0x18 0x16 0x16 0x24 0x16 0x11 0x18 0x1b 0x1b]
 [0x16 0x13 0x14 0x16 0x1c 0x1e 0x1c 0x24 0x19 0x12 0x14 0x1b 0x16 0x16 0x1c 0x1a 0x1d 0x1d 0x23 0x18 0xf 0x12 0x15 0x1b]]
>>>
*/
reg [`DWIDTH-1:0] a[24][24];
reg [`DWIDTH-1:0] b[24][24];
reg [`DWIDTH-1:0] c[24][24];
initial begin
for (i=0; i<24; i++) begin
       for (j=0; j<24; j++) begin
           a[i][j] = 8'd2;
           b[i][j] = 8'd4;
           c[i][j] = 8'd3;
       end
end
end
/*
reg [`DWIDTH-1:0] a[24][24] = 
'{{8'd1,8'd2,8'd2,8'd1,8'd0,8'd0,8'd2,8'd0,8'd0,8'd0,8'd1,8'd1,8'd0,8'd1,8'd1,8'd2,8'd1,8'd2,8'd1,8'd0,8'd0,8'd1,8'd2,8'd1},
  {8'd1,8'd0,8'd1,8'd0,8'd2,8'd0,8'd0,8'd1,8'd2,8'd0,8'd0,8'd1,8'd1,8'd2,8'd1,8'd0,8'd0,8'd0,8'd1,8'd1,8'd2,8'd0,8'd0,8'd0},
  {8'd2,8'd0,8'd0,8'd2,8'd0,8'd1,8'd1,8'd0,8'd0,8'd2,8'd0,8'd1,8'd1,8'd1,8'd1,8'd1,8'd0,8'd2,8'd1,8'd1,8'd0,8'd1,8'd1,8'd0},
  {8'd2,8'd2,8'd2,8'd1,8'd1,8'd0,8'd0,8'd1,8'd2,8'd1,8'd1,8'd1,8'd2,8'd2,8'd2,8'd1,8'd0,8'd2,8'd2,8'd2,8'd2,8'd1,8'd0,8'd2},
  {8'd0,8'd0,8'd2,8'd0,8'd1,8'd0,8'd2,8'd1,8'd1,8'd1,8'd2,8'd0,8'd0,8'd2,8'd0,8'd0,8'd0,8'd2,8'd2,8'd0,8'd1,8'd1,8'd0,8'd0},
  {8'd0,8'd1,8'd1,8'd0,8'd2,8'd0,8'd0,8'd2,8'd2,8'd1,8'd1,8'd1,8'd1,8'd2,8'd2,8'd2,8'd0,8'd0,8'd1,8'd2,8'd2,8'd0,8'd1,8'd2},
  {8'd2,8'd0,8'd1,8'd1,8'd1,8'd1,8'd1,8'd0,8'd1,8'd0,8'd2,8'd1,8'd0,8'd0,8'd1,8'd0,8'd1,8'd2,8'd2,8'd0,8'd0,8'd0,8'd0,8'd0},
  {8'd2,8'd1,8'd1,8'd0,8'd1,8'd2,8'd0,8'd0,8'd1,8'd0,8'd1,8'd0,8'd1,8'd1,8'd0,8'd2,8'd2,8'd0,8'd1,8'd1,8'd1,8'd2,8'd0,8'd2},
  {8'd2,8'd0,8'd1,8'd2,8'd0,8'd0,8'd1,8'd1,8'd0,8'd1,8'd0,8'd1,8'd2,8'd0,8'd2,8'd1,8'd1,8'd1,8'd0,8'd0,8'd0,8'd0,8'd0,8'd2},
  {8'd2,8'd2,8'd2,8'd1,8'd2,8'd0,8'd2,8'd1,8'd0,8'd0,8'd2,8'd0,8'd1,8'd2,8'd1,8'd1,8'd0,8'd1,8'd2,8'd1,8'd1,8'd0,8'd2,8'd0},
  {8'd2,8'd0,8'd0,8'd2,8'd2,8'd2,8'd2,8'd0,8'd0,8'd0,8'd1,8'd2,8'd2,8'd0,8'd2,8'd2,8'd0,8'd2,8'd0,8'd2,8'd0,8'd1,8'd0,8'd2},
  {8'd0,8'd2,8'd1,8'd0,8'd1,8'd1,8'd0,8'd2,8'd0,8'd0,8'd2,8'd1,8'd1,8'd2,8'd1,8'd2,8'd0,8'd1,8'd1,8'd0,8'd0,8'd2,8'd0,8'd2},
  {8'd0,8'd1,8'd2,8'd1,8'd1,8'd0,8'd2,8'd0,8'd0,8'd1,8'd1,8'd1,8'd1,8'd0,8'd2,8'd2,8'd2,8'd1,8'd1,8'd1,8'd1,8'd1,8'd2,8'd1},
  {8'd0,8'd2,8'd0,8'd1,8'd0,8'd1,8'd1,8'd1,8'd1,8'd0,8'd2,8'd0,8'd0,8'd2,8'd2,8'd0,8'd0,8'd2,8'd2,8'd1,8'd0,8'd1,8'd1,8'd0},
  {8'd2,8'd1,8'd2,8'd1,8'd0,8'd0,8'd0,8'd0,8'd1,8'd0,8'd2,8'd0,8'd0,8'd2,8'd0,8'd2,8'd2,8'd1,8'd0,8'd2,8'd1,8'd0,8'd2,8'd1},
  {8'd1,8'd0,8'd2,8'd0,8'd2,8'd0,8'd1,8'd1,8'd2,8'd1,8'd2,8'd0,8'd2,8'd0,8'd0,8'd0,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1},
  {8'd2,8'd0,8'd2,8'd1,8'd1,8'd0,8'd1,8'd0,8'd0,8'd1,8'd0,8'd0,8'd0,8'd1,8'd2,8'd1,8'd2,8'd2,8'd1,8'd2,8'd0,8'd1,8'd1,8'd1},
  {8'd1,8'd2,8'd1,8'd0,8'd0,8'd1,8'd0,8'd2,8'd1,8'd1,8'd2,8'd1,8'd2,8'd2,8'd0,8'd0,8'd0,8'd2,8'd1,8'd2,8'd1,8'd1,8'd1,8'd1},
  {8'd2,8'd2,8'd0,8'd2,8'd0,8'd1,8'd2,8'd0,8'd2,8'd2,8'd1,8'd2,8'd1,8'd1,8'd0,8'd1,8'd2,8'd2,8'd0,8'd1,8'd2,8'd2,8'd1,8'd0},
  {8'd1,8'd2,8'd0,8'd1,8'd2,8'd0,8'd2,8'd2,8'd2,8'd1,8'd2,8'd1,8'd1,8'd2,8'd0,8'd1,8'd2,8'd2,8'd1,8'd1,8'd2,8'd1,8'd2,8'd1},
  {8'd0,8'd1,8'd2,8'd1,8'd0,8'd1,8'd2,8'd1,8'd2,8'd2,8'd2,8'd2,8'd2,8'd2,8'd0,8'd1,8'd2,8'd1,8'd1,8'd1,8'd2,8'd0,8'd0,8'd0},
  {8'd2,8'd2,8'd1,8'd0,8'd2,8'd1,8'd0,8'd2,8'd1,8'd1,8'd2,8'd1,8'd2,8'd0,8'd2,8'd0,8'd2,8'd0,8'd2,8'd1,8'd0,8'd2,8'd1,8'd0},
  {8'd0,8'd0,8'd1,8'd2,8'd0,8'd2,8'd1,8'd2,8'd2,8'd2,8'd2,8'd0,8'd2,8'd1,8'd0,8'd0,8'd0,8'd1,8'd1,8'd0,8'd2,8'd2,8'd0,8'd2},
  {8'd0,8'd0,8'd2,8'd2,8'd1,8'd2,8'd0,8'd0,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd2,8'd1,8'd0,8'd2,8'd2,8'd1,8'd0,8'd2,8'd0,8'd1}};

reg [`DWIDTH-1:0] b[24][24] =   
'{{8'd2,8'd1,8'd0,8'd0,8'd2,8'd2,8'd0,8'd0,8'd0,8'd0,8'd1,8'd1,8'd0,8'd1,8'd1,8'd0,8'd0,8'd1,8'd2,8'd0,8'd1,8'd0,8'd0,8'd1},
  {8'd2,8'd2,8'd0,8'd2,8'd0,8'd2,8'd0,8'd2,8'd2,8'd0,8'd0,8'd1,8'd0,8'd2,8'd1,8'd2,8'd1,8'd2,8'd0,8'd2,8'd2,8'd0,8'd2,8'd1},
  {8'd1,8'd1,8'd0,8'd1,8'd0,8'd0,8'd1,8'd2,8'd2,8'd0,8'd1,8'd0,8'd0,8'd1,8'd2,8'd2,8'd2,8'd2,8'd2,8'd0,8'd0,8'd0,8'd1,8'd2},
  {8'd1,8'd0,8'd1,8'd1,8'd2,8'd0,8'd1,8'd1,8'd2,8'd1,8'd2,8'd0,8'd2,8'd1,8'd1,8'd2,8'd2,8'd1,8'd1,8'd2,8'd2,8'd0,8'd0,8'd1},
  {8'd1,8'd2,8'd2,8'd0,8'd2,8'd2,8'd2,8'd1,8'd0,8'd2,8'd1,8'd1,8'd0,8'd1,8'd1,8'd0,8'd2,8'd2,8'd2,8'd2,8'd0,8'd0,8'd1,8'd1},
  {8'd1,8'd2,8'd0,8'd1,8'd2,8'd0,8'd1,8'd2,8'd2,8'd1,8'd2,8'd2,8'd0,8'd1,8'd1,8'd0,8'd1,8'd1,8'd2,8'd0,8'd1,8'd1,8'd0,8'd2},
  {8'd1,8'd1,8'd2,8'd2,8'd1,8'd0,8'd1,8'd1,8'd1,8'd2,8'd1,8'd1,8'd0,8'd0,8'd2,8'd2,8'd1,8'd2,8'd1,8'd1,8'd2,8'd2,8'd2,8'd0},
  {8'd1,8'd1,8'd0,8'd2,8'd0,8'd2,8'd0,8'd0,8'd1,8'd2,8'd0,8'd2,8'd0,8'd2,8'd2,8'd1,8'd1,8'd0,8'd0,8'd0,8'd0,8'd0,8'd2,8'd2},
  {8'd2,8'd2,8'd2,8'd2,8'd0,8'd1,8'd2,8'd1,8'd0,8'd0,8'd2,8'd0,8'd0,8'd2,8'd0,8'd0,8'd0,8'd1,8'd1,8'd0,8'd0,8'd1,8'd0,8'd1},
  {8'd2,8'd1,8'd2,8'd1,8'd1,8'd2,8'd0,8'd0,8'd2,8'd0,8'd0,8'd2,8'd1,8'd0,8'd2,8'd0,8'd1,8'd0,8'd2,8'd2,8'd0,8'd2,8'd1,8'd0},
  {8'd2,8'd2,8'd0,8'd1,8'd0,8'd2,8'd2,8'd2,8'd2,8'd2,8'd1,8'd2,8'd2,8'd2,8'd2,8'd1,8'd1,8'd1,8'd2,8'd1,8'd2,8'd0,8'd1,8'd0},
  {8'd0,8'd1,8'd0,8'd1,8'd2,8'd2,8'd2,8'd2,8'd0,8'd1,8'd1,8'd2,8'd1,8'd2,8'd0,8'd2,8'd1,8'd1,8'd2,8'd1,8'd1,8'd1,8'd0,8'd0},
  {8'd2,8'd0,8'd0,8'd0,8'd2,8'd2,8'd0,8'd2,8'd0,8'd1,8'd0,8'd0,8'd1,8'd0,8'd1,8'd0,8'd2,8'd0,8'd2,8'd1,8'd0,8'd0,8'd2,8'd1},
  {8'd0,8'd0,8'd0,8'd0,8'd2,8'd0,8'd0,8'd2,8'd1,8'd1,8'd0,8'd0,8'd2,8'd1,8'd2,8'd1,8'd0,8'd1,8'd2,8'd2,8'd0,8'd1,8'd1,8'd1},
  {8'd0,8'd0,8'd1,8'd1,8'd1,8'd2,8'd2,8'd2,8'd1,8'd0,8'd1,8'd2,8'd2,8'd1,8'd1,8'd1,8'd2,8'd1,8'd1,8'd1,8'd0,8'd0,8'd2,8'd0},
  {8'd0,8'd1,8'd1,8'd0,8'd2,8'd2,8'd1,8'd1,8'd0,8'd0,8'd2,8'd1,8'd2,8'd0,8'd1,8'd1,8'd2,8'd1,8'd2,8'd2,8'd0,8'd1,8'd1,8'd2},
  {8'd2,8'd0,8'd1,8'd1,8'd1,8'd0,8'd1,8'd1,8'd2,8'd1,8'd2,8'd2,8'd0,8'd2,8'd1,8'd2,8'd2,8'd0,8'd0,8'd2,8'd0,8'd0,8'd2,8'd1},
  {8'd2,8'd1,8'd0,8'd2,8'd2,8'd2,8'd0,8'd2,8'd0,8'd0,8'd0,8'd2,8'd1,8'd0,8'd1,8'd1,8'd1,8'd1,8'd0,8'd0,8'd0,8'd1,8'd1,8'd1},
  {8'd1,8'd0,8'd2,8'd0,8'd1,8'd2,8'd2,8'd2,8'd1,8'd1,8'd0,8'd1,8'd0,8'd2,8'd0,8'd2,8'd2,8'd2,8'd1,8'd1,8'd1,8'd0,8'd0,8'd1},
  {8'd0,8'd0,8'd2,8'd0,8'd1,8'd0,8'd0,8'd1,8'd2,8'd0,8'd0,8'd1,8'd1,8'd0,8'd1,8'd0,8'd0,8'd2,8'd2,8'd0,8'd2,8'd2,8'd2,8'd2},
  {8'd2,8'd1,8'd0,8'd0,8'd2,8'd2,8'd2,8'd1,8'd1,8'd1,8'd1,8'd0,8'd0,8'd1,8'd2,8'd1,8'd0,8'd0,8'd2,8'd0,8'd1,8'd2,8'd2,8'd1},
  {8'd0,8'd0,8'd1,8'd2,8'd0,8'd2,8'd2,8'd0,8'd1,8'd2,8'd0,8'd2,8'd0,8'd1,8'd2,8'd2,8'd0,8'd1,8'd1,8'd2,8'd1,8'd2,8'd1,8'd2},
  {8'd0,8'd2,8'd1,8'd0,8'd0,8'd1,8'd2,8'd1,8'd0,8'd1,8'd2,8'd1,8'd2,8'd0,8'd1,8'd1,8'd1,8'd0,8'd2,8'd1,8'd2,8'd2,8'd0,8'd2},
  {8'd1,8'd2,8'd1,8'd1,8'd0,8'd1,8'd1,8'd2,8'd0,8'd1,8'd1,8'd0,8'd2,8'd0,8'd2,8'd1,8'd0,8'd2,8'd2,8'd1,8'd0,8'd2,8'd2,8'd1}};

reg [`DWIDTH-1:0] c[24][24] =   
'{{8'd21,8'd22,8'd15,8'd22,8'd21,8'd27,8'd23,8'd32,8'd20,8'd16,8'd21,8'd24,8'd21,8'd19,8'd28,8'd32,8'd26,8'd27,8'd28,8'd25,8'd20,8'd18,8'd23,8'd24},
  {8'd17,8'd14,8'd13,8'd09,8'd21,8'd22,8'd19,8'd21,8'd11,8'd13,8'd12,8'd11,8'd09,8'd19,8'd18,8'd12,8'd14,8'd17,8'd26,8'd12,8'd07,8'd11,8'd17,8'd17},
  {8'd19,8'd13,8'd16,8'd15,8'd28,8'd25,8'd15,8'd22,8'd17,8'd12,8'd15,8'd23,8'd19,8'd12,8'd22,8'd18,8'd20,8'd18,8'd28,8'd20,8'd16,8'd18,8'd15,8'd19},
  {8'd37,8'd28,8'd23,8'd26,8'd35,8'd46,8'd30,8'd45,8'd28,8'd20,8'd21,8'd28,8'd26,8'd31,8'd39,8'd31,8'd30,8'd37,8'd46,8'd28,8'd20,8'd24,8'd37,8'd34},
  {8'd22,8'd17,8'd15,8'd19,8'd17,8'd23,8'd20,8'd25,8'd19,8'd19,8'd10,8'd19,8'd11,8'd19,8'd27,8'd22,8'd18,8'd22,8'd24,8'd16,8'd12,8'd15,8'd19,8'd17},
  {8'd24,8'd27,8'd23,8'd18,8'd26,8'd37,8'd29,8'd35,8'd21,8'd20,8'd21,8'd23,8'd25,8'd25,8'd33,8'd22,8'd25,8'd28,8'd41,8'd25,8'd14,8'd23,8'd33,8'd29},
  {8'd23,8'd17,8'd13,8'd16,8'd21,8'd23,8'd21,8'd25,8'd16,8'd14,8'd17,8'd22,8'd11,8'd21,8'd17,8'd19,8'd21,8'd21,8'd22,8'd13,8'd14,8'd07,8'd12,8'd14},
  {8'd25,8'd22,8'd16,8'd16,8'd24,8'd27,8'd23,8'd28,8'd21,8'd18,8'd22,8'd22,8'd14,8'd22,8'd28,8'd21,8'd20,8'd25,8'd34,8'd23,8'd14,8'd18,8'd24,8'd29},
  {8'd21,8'd13,8'd12,8'd16,8'd23,8'd24,8'd14,8'd23,8'd14,8'd12,8'd17,8'd18,8'd19,8'd13,8'd23,8'd19,8'd23,8'd17,8'd25,8'd18,8'd09,8'd11,8'd22,8'd16},
  {8'd28,8'd26,8'd19,8'd18,8'd28,8'd34,8'd26,8'd36,8'd25,8'd23,8'd20,8'd24,8'd21,8'd25,8'd34,8'd29,8'd30,8'd32,8'd38,8'd26,8'd25,8'd16,8'd28,8'd28},
  {8'd24,8'd24,8'd21,8'd21,8'd38,8'd34,8'd26,8'd36,8'd19,8'd22,8'd25,8'd30,8'd26,8'd17,8'd30,8'd23,8'd29,8'd32,8'd41,8'd25,8'd21,8'd22,8'd28,8'd26},
  {8'd20,8'd23,8'd11,8'd22,8'd20,8'd34,8'd22,8'd33,8'd20,8'd22,8'd14,8'd26,8'd21,8'd24,8'd31,8'd26,8'd23,8'd26,8'd30,8'd26,8'd13,8'd15,8'd27,8'd26},
  {8'd24,8'd22,8'd23,8'd21,8'd25,8'd31,8'd30,8'd34,8'd25,8'd20,8'd25,8'd28,8'd23,8'd20,8'd32,8'd32,8'd33,8'd27,8'd35,8'd29,8'd20,8'd22,8'd31,8'd26},
  {8'd20,8'd18,8'd15,8'd22,8'd18,8'd26,8'd21,8'd31,8'd23,8'd17,8'd13,8'd25,8'd19,8'd23,8'd24,8'd24,8'd20,8'd24,8'd22,8'd20,8'd20,8'd14,8'd21,8'd20},
  {8'd24,8'd22,8'd14,8'd14,8'd22,8'd22,8'd20,8'd29,8'd23,8'd13,8'd24,8'd19,8'd23,8'd20,8'd29,8'd23,8'd20,8'd23,8'd34,8'd21,8'd19,8'd18,8'd23,8'd28},
  {8'd30,8'd24,8'd20,8'd19,8'd19,8'd30,8'd25,8'd27,8'd19,8'd21,8'd18,8'd21,8'd13,8'd21,8'd29,8'd19,8'd23,8'd23,8'd33,8'd18,8'd14,8'd17,8'd25,8'd24},
  {8'd21,8'd15,8'd21,8'd17,8'd25,8'd24,8'd20,8'd27,8'd22,8'd13,8'd19,8'd25,8'd19,8'd16,8'd28,8'd24,8'd25,8'd26,8'd30,8'd22,8'd14,8'd18,8'd25,8'd25},
  {8'd30,8'd25,8'd13,8'd23,8'd24,8'd35,8'd19,8'd35,8'd25,8'd20,8'd13,8'd27,8'd20,8'd25,8'd33,8'd23,8'd20,8'd25,8'd35,8'd20,8'd20,8'd21,8'd29,8'd29},
  {8'd37,8'd27,8'd22,8'd30,8'd35,8'd37,8'd28,8'd33,8'd29,8'd22,8'd27,8'd33,8'd20,8'd28,8'd35,8'd32,8'd25,8'd26,8'd38,8'd31,8'd27,8'd29,8'd29,8'd28},
  {8'd39,8'd34,8'd26,8'd30,8'd33,8'd43,8'd33,8'd39,8'd28,8'd31,8'd27,8'd34,8'd24,8'd33,8'd41,8'd34,8'd30,8'd31,8'd41,8'd34,8'd26,8'd28,8'd37,8'd33},
  {8'd36,8'd25,8'd20,8'd26,8'd32,8'd32,8'd27,8'd39,8'd32,8'd23,8'd24,8'd28,8'd20,8'd30,8'd36,8'd31,8'd30,8'd26,8'd40,8'd27,8'd20,8'd23,8'd32,8'd26},
  {8'd32,8'd25,8'd21,8'd24,8'd24,8'd42,8'd30,8'd33,8'd28,8'd25,8'd20,8'd36,8'd15,8'd34,8'd31,8'd27,8'd32,8'd27,8'd35,8'd28,8'd20,8'd13,8'd30,8'd29},
  {8'd33,8'd25,8'd18,8'd27,8'd24,8'd32,8'd26,8'd31,8'd27,8'd26,8'd20,8'd24,8'd19,8'd24,8'd37,8'd24,8'd22,8'd22,8'd36,8'd22,8'd17,8'd24,8'd27,8'd27},
  {8'd22,8'd19,8'd20,8'd22,8'd28,8'd30,8'd28,8'd36,8'd25,8'd18,8'd20,8'd27,8'd22,8'd22,8'd28,8'd26,8'd29,8'd29,8'd35,8'd24,8'd15,8'd18,8'd21,8'd27}};
*/
`endif

integer i;
integer j;
integer tile_x;
integer tile_y;

////////////////////////////////////////////
//Task to initialize BRAMs
////////////////////////////////////////////
task initialize_brams();
begin
   //A is stored in col major format
   for (i=0; i<problem_size; i++) begin
       for (j=0; j<problem_size; j++) begin
           u_top.matrix_A.ram[a_start_addr+problem_size*i+j] = a[j][i];
       end
   end

  //B is stored in row major format
   for (i=0; i<problem_size; i++) begin
       for (j=0; j<problem_size; j++) begin
           u_top.matrix_B.ram[b_start_addr+problem_size*i+j] = b[i][j];
       end
    end

end
endtask

integer fail = 0;
integer address, observed, expected;
////////////////////////////////////////////
//Task to compare outputs with expected values
////////////////////////////////////////////
task compare_outputs();
begin
   //C is stored like A
   for (i=0; i<problem_size; i++) begin
       for (j=0; j<problem_size; j++) begin
           address = c_start_addr+problem_size*i+j;
           observed = u_top.matrix_A.ram[address];
           expected = c[j][i];
           if (expected != observed) begin
             $display("Mismatch found. Address = %0d, Expected = %0d, Observed = %0d", address, expected, observed);
             fail = 1;
           end
       end
   end
   if (fail == 0) begin
     $display("===============================");
     $display("Test passed");
     $display("===============================");
   end
end
endtask

////////////////////////////////////////////
//The actual test
////////////////////////////////////////////
task accumulator_test();
begin
  done = 0;
  //Start the actual test
  $display("Set enables to 1");
  //enable_matmul = 1;
  //enable_norm = 1;
  //enable_activation = 1;
  //enable_pool = 1;

  //reg value to enable all blocks (non conv mode)
  wdata = 32'h0000_000f;
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

  //Configure strides to 12 (because we have 3 tiles in each direction)
  write(`REG_MATRIX_A_STRIDE_ADDR, problem_size);
  write(`REG_MATRIX_B_STRIDE_ADDR, problem_size);
  write(`REG_MATRIX_C_STRIDE_ADDR, problem_size);

  //We have 12x12 matrices as inputs. Let's divide them into 9 tiles, each is 4x4.
  //For calculating each tile, we will invoke the matmul 3 times (3 passes).
  //Example: For calculating the tile 00 of matrix C, we will perform:
  //A00 * B00 -> First pass
  //A01 * B10 -> Second pass
  //A01 * B20 -> Third pass
  //Example: For calculating the tile 21 of matrix C, we will perform:
  //A10 * B01 -> First pass
  //A21 * B11 -> Second pass
  //A22 * B21 -> Third pass

  
  for (tile_x = 0; tile_x < problem_size/`MAT_MUL_SIZE; tile_x++) begin
  for (tile_y = 0; tile_y < problem_size/`MAT_MUL_SIZE; tile_y++) begin
  /////////////////////////////////////////////////////////////////
  //First pass
  /////////////////////////////////////////////////////////////////
  //Set save_output_to_accum = 1 and set add_accum_to_output = 1 (even though we don't need to add)
  //write(`REG_ACCUM_ACTIONS_ADDR, 32'h0000_0003);
  //Configure addresses
  //We don't need to configure C addr right now actually because output won't be written to bram
  //But it's okay. Let's do it now anyway.
  write(`REG_MATRIX_A_ADDR, a_start_addr + tile_x*`MAT_MUL_SIZE);
  write(`REG_MATRIX_B_ADDR, b_start_addr + tile_y*`MAT_MUL_SIZE);
  //TODO: Need to fix this based on the updated matmul that takes c_addr from the last column
  write(`REG_MATRIX_C_ADDR, c_start_addr + tile_x*`MAT_MUL_SIZE + tile_y*`MAT_MUL_SIZE*problem_size);

  $display("Start the TPU for first pass");
  //start = 1;
  //also pe_reset = 1
  write(`REG_STDN_TPU_ADDR, 32'h0000_8001);
  
  $display("Wait until TPU is done");
  while (done == 0)
  begin
      read(`REG_STDN_TPU_ADDR, rdata);
      done = rdata[31];
  end 
  

  $display("Stop the TPU");
  //start = 0;
  write(`REG_STDN_TPU_ADDR, 32'h0000_0000);

  /////////////////////////////////////////////////////////////////
  //Second pass
  /////////////////////////////////////////////////////////////////
  //Set save_output_to_accum = 1 and set add_accum_to_output = 1 
  //Already configured in step 1
  //Configure strides to 12 (because we have 3 tiles in each direction)
  //Already configured in step 1
  //Configure addresses. Matrix C address is already configured.
  write(`REG_MATRIX_A_ADDR, a_start_addr + problem_size * `MAT_MUL_SIZE + tile_x*`MAT_MUL_SIZE);
  write(`REG_MATRIX_B_ADDR, b_start_addr + problem_size * `MAT_MUL_SIZE + tile_y*`MAT_MUL_SIZE);

  $display("Start the TPU for second pass");
  //start = 1;
  write(`REG_STDN_TPU_ADDR, 32'h0000_0001);
  
  $display("Wait until TPU is done");
  while (done == 0)
  begin
      read(`REG_STDN_TPU_ADDR, rdata);
      done = rdata[31];
  end 
  

  $display("Stop the TPU");
  //start = 0;
  write(`REG_STDN_TPU_ADDR, 32'h0000_0000);

  /////////////////////////////////////////////////////////////////
  //Third pass
  /////////////////////////////////////////////////////////////////
  //Set save_output_to_accum = 0 and set add_accum_to_output = 1 
  //write(`REG_ACCUM_ACTIONS_ADDR, 32'h0000_0002);
  //Configure strides to 12 (because we have 3 tiles in each direction)
  //Already configured in step 1
  //Configure addresses. Matrix C address is already configured.
  write(`REG_MATRIX_A_ADDR, a_start_addr + problem_size * `MAT_MUL_SIZE * 2 + tile_x*`MAT_MUL_SIZE);
  write(`REG_MATRIX_B_ADDR, b_start_addr + problem_size * `MAT_MUL_SIZE * 2 + tile_y*`MAT_MUL_SIZE);

  $display("Start the TPU for third pass");
  //start = 1;
  write(`REG_STDN_TPU_ADDR, 32'h0000_0001);
  
  $display("Wait until TPU is done");
  while (done == 0)
  begin
      read(`REG_STDN_TPU_ADDR, rdata);
      done = rdata[31];
  end 
  
  
  $display("TPU operation is done now.");

  $display("Stop the TPU");
  //start = 0;
  write(`REG_STDN_TPU_ADDR, 32'h0000_0000);

end
end

end
endtask

endmodule
