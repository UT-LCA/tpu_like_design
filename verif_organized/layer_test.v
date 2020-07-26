module layer_test();

reg done;
reg [`REG_DATAWIDTH-1:0] rdata;
reg [`REG_DATAWIDTH-1:0] wdata;

task run();
begin
    initialize_brams();
    layer_test();
    compare_outputs();
end
endtask

integer mean = 1;
integer inv_var = 1;

`ifdef DESIGN_SIZE_4
integer a_start_addr = 0;
integer b_start_addr = 0;
integer c_start_addr = 200;
integer problem_size = 4;

reg [`DWIDTH-1:0] a[4][4] = 
'{{8,4,6,8},
  {3,3,3,7},
  {5,2,1,6},
  {9,1,0,5}};

reg [`DWIDTH-1:0] b[4][4] = 
'{{1,1,3,0},
  {0,1,4,3},
  {3,5,3,1},
  {9,6,3,2}};

reg [`DWIDTH-1:0] c[4][4] = 
'{{98,90,82,34},
  {75,63,51,26},
  {62,48,44,19},
  {54,40,46,13}};

// c in hex  
//62 5a 52 22 
//4b 3f 33 1a
//3e 30 2c 13
//36 28 2e 0d
`endif

`ifdef DESIGN_SIZE_8
/*
>>> a = np.random.randint(low=0, high=5,size=(8,8), dtype=np.uint8)
>>> print(a)
[[4 0 2 0 3 2 2 0]
 [1 2 3 4 1 1 1 3]
 [0 2 2 1 0 3 2 2]
 [1 0 2 3 2 0 1 0]
 [4 2 1 1 3 2 1 4]
 [2 0 2 2 0 1 0 1]
 [0 1 1 3 2 4 4 4]
 [2 2 3 0 0 4 2 3]]
>>> b = np.random.randint(low=0, high=5,size=(8,8), dtype=np.uint8)
>>> print(b)
[[1 2 3 3 3 2 2 1]
 [0 0 3 2 1 3 4 2]
 [1 0 2 2 2 4 3 3]
 [2 4 3 2 0 0 3 3]
 [2 1 4 0 3 4 2 0]
 [0 2 2 3 1 2 1 0]
 [0 1 0 4 0 1 0 2]
 [3 2 1 0 3 4 2 2]]
>>> c=np.matmul(a,b)
>>> print(c)
[[12 17 32 30 27 34 22 14]
 [23 28 36 28 24 39 40 34]
 [10 16 21 27 15 30 24 21]
 [13 17 24 17 13 19 21 18]
 [25 28 43 30 39 51 38 24]
 [11 16 19 17 14 18 19 16]
 [23 34 34 38 25 43 32 30]
 [14 20 29 36 27 44 31 25]]
>>> np.set_printoptions(formatter={'int':hex})
>>> print(c)
[[0xc 0x11 0x20 0x1e 0x1b 0x22 0x16 0xe]
 [0x17 0x1c 0x24 0x1c 0x18 0x27 0x28 0x22]
 [0xa 0x10 0x15 0x1b 0xf 0x1e 0x18 0x15]
 [0xd 0x11 0x18 0x11 0xd 0x13 0x15 0x12]
 [0x19 0x1c 0x2b 0x1e 0x27 0x33 0x26 0x18]
 [0xb 0x10 0x13 0x11 0xe 0x12 0x13 0x10]
 [0x17 0x22 0x22 0x26 0x19 0x2b 0x20 0x1e]
 [0xe 0x14 0x1d 0x24 0x1b 0x2c 0x1f 0x19]]
*/

integer a_start_addr = 0;
integer b_start_addr = 150;
integer c_start_addr = 400;
integer problem_size = 8;

reg [`DWIDTH-1:0] a[8][8] = 
'{{8'd4,8'd0,8'd2,8'd0,8'd3,8'd2,8'd2,8'd0},
  {8'd1,8'd2,8'd3,8'd4,8'd1,8'd1,8'd1,8'd3},
  {8'd0,8'd2,8'd2,8'd1,8'd0,8'd3,8'd2,8'd2},
  {8'd1,8'd0,8'd2,8'd3,8'd2,8'd0,8'd1,8'd0},
  {8'd4,8'd2,8'd1,8'd1,8'd3,8'd2,8'd1,8'd4},
  {8'd2,8'd0,8'd2,8'd2,8'd0,8'd1,8'd0,8'd1},
  {8'd0,8'd1,8'd1,8'd3,8'd2,8'd4,8'd4,8'd4},
  {8'd2,8'd2,8'd3,8'd0,8'd0,8'd4,8'd2,8'd3}};

reg [`DWIDTH-1:0] b[8][8] = 
'{{8'd1,8'd2,8'd3,8'd3,8'd3,8'd2,8'd2,8'd1},
  {8'd0,8'd0,8'd3,8'd2,8'd1,8'd3,8'd4,8'd2},
  {8'd1,8'd0,8'd2,8'd2,8'd2,8'd4,8'd3,8'd3},
  {8'd2,8'd4,8'd3,8'd2,8'd0,8'd0,8'd3,8'd3},
  {8'd2,8'd1,8'd4,8'd0,8'd3,8'd4,8'd2,8'd0},
  {8'd0,8'd2,8'd2,8'd3,8'd1,8'd2,8'd1,8'd0},
  {8'd0,8'd1,8'd0,8'd4,8'd0,8'd1,8'd0,8'd2},
  {8'd3,8'd2,8'd1,8'd0,8'd3,8'd4,8'd2,8'd2}};

reg [`DWIDTH-1:0] c[8][8] = 
'{{8'd12,8'd17,8'd32,8'd30,8'd27,8'd34,8'd22,8'd14},
  {8'd23,8'd28,8'd36,8'd28,8'd24,8'd39,8'd40,8'd34},
  {8'd10,8'd16,8'd21,8'd27,8'd15,8'd30,8'd24,8'd21},
  {8'd13,8'd17,8'd24,8'd17,8'd13,8'd19,8'd21,8'd18},
  {8'd25,8'd28,8'd43,8'd30,8'd39,8'd51,8'd38,8'd24},
  {8'd11,8'd16,8'd19,8'd17,8'd14,8'd18,8'd19,8'd16},
  {8'd23,8'd34,8'd34,8'd38,8'd25,8'd43,8'd32,8'd30},
  {8'd14,8'd20,8'd29,8'd36,8'd27,8'd44,8'd31,8'd25}};

`endif

`ifdef DESIGN_SIZE_16
/*
>>> a = np.random.randint(low=0, high=5,size=(16,16), dtype=np.uint8)
>>> print(a)
[[4 4 1 3 2 2 4 1 0 4 3 2 2 2 1 4]
 [2 4 3 0 2 1 1 2 3 3 2 2 4 2 3 2]
 [4 1 3 0 4 2 0 0 1 2 1 0 0 1 1 2]
 [0 4 0 0 1 3 4 4 1 3 3 0 4 3 4 0]
 [0 3 1 4 1 2 0 2 2 1 4 2 0 1 4 3]
 [3 4 1 0 2 3 0 4 4 1 3 4 2 1 2 4]
 [0 3 3 3 3 1 2 0 1 3 3 1 0 0 4 2]
 [4 4 0 2 0 2 2 3 4 4 3 4 1 2 4 4]
 [2 3 2 2 4 0 0 2 4 3 2 2 1 3 1 2]
 [4 1 0 1 2 1 2 2 1 4 3 2 0 0 4 0]
 [4 4 1 0 0 2 2 3 1 0 0 4 3 3 0 4]
 [3 1 3 4 0 0 2 3 1 0 3 1 0 0 2 4]
 [2 3 4 0 1 1 1 3 0 0 2 0 2 4 3 2]
 [1 2 4 2 4 3 2 4 2 1 0 1 4 1 1 4]
 [2 2 0 0 1 0 2 0 1 1 3 1 1 0 0 1]
 [0 1 2 2 4 1 0 1 3 3 3 2 1 3 1 0]]
>>> b = np.random.randint(low=0, high=5,size=(16,16), dtype=np.uint8)
>>> print(b)
[[2 3 2 4 3 0 0 1 4 1 0 1 2 3 3 1]
 [1 1 3 3 3 1 0 2 4 4 4 0 3 0 3 1]
 [3 1 0 3 2 4 1 3 1 4 1 0 2 3 0 2]
 [2 0 0 4 0 0 3 1 2 0 3 4 1 0 0 4]
 [1 3 1 2 2 2 4 2 1 0 1 1 3 4 1 1]
 [3 4 2 3 1 4 1 3 2 3 1 0 1 4 4 1]
 [1 3 4 0 1 3 2 0 0 4 0 4 4 3 4 3]
 [1 0 4 1 0 3 0 0 4 4 0 0 1 2 1 2]
 [0 3 2 2 0 1 4 3 1 3 0 3 2 2 4 0]
 [4 4 4 0 2 2 4 0 0 3 0 4 3 3 0 0]
 [2 2 2 4 4 4 4 0 3 4 1 4 2 4 1 4]
 [1 3 3 2 0 2 3 0 3 3 0 0 4 0 1 3]
 [3 4 3 4 0 1 3 4 3 2 1 0 1 0 3 1]
 [2 2 2 1 0 2 0 3 1 4 3 1 4 2 0 0]
 [0 2 2 1 3 1 2 0 1 0 2 1 0 1 3 3]
 [2 1 3 4 2 2 0 3 4 0 1 3 1 1 2 1]]
>>> c=np.matmul(a,b)
>>> print(c)
[[ 76  89  98  97  67  74  70  54  89  92  47  77  90  78  73  67]
 [ 63  85  88  85  57  69  70  63  79  93  42  48  76  66  71  51]
 [ 44  55  41  58  46  45  39  41  45  43  21  31  47  62  39  26]
 [ 58  82  97  64  51  75  63  47  68 101  44  51  71  69  76  56]
 [ 45  52  63  79  51  59  61  39  71  65  46  57  52  51  52  65]
 [ 58  84  96  99  58  76  66  62 103  95  38  48  76  71  82  58]
 [ 49  59  59  67  58  60  68  36  51  62  41  60  59  60  48  60]
 [ 68  96 113  99  68  76  79  54 102 104  46  78  90  76  89  71]
 [ 54  71  72  77  48  59  71  55  69  79  40  56  77  66  51  45]
 [ 44  68  69  54  54  50  62  17  54  60  21  53  57  64  52  52]
 [ 53  68  85  81  38  57  32  57  90  83  35  30  72  47  68  43]
 [ 44  39  56  77  46  53  42  33  70  57  30  56  46  50  45  63]
 [ 49  51  62  68  48  62  31  51  66  77  42  28  56  56  48  45]
 [ 66  76  81  91  43  77  62  73  81  82  38  45  68  71  69  54]
 [ 25  38  40  40  32  30  34  18  37  41  14  33  38  34  34  28]
 [ 48  64  54  59  37  57  72  43  45  69  32  49  65  62  35  42]]
>>> np.set_printoptions(formatter={'int':hex})
>>> print(c)
[[0x4c 0x59 0x62 0x61 0x43 0x4a 0x46 0x36 0x59 0x5c 0x2f 0x4d 0x5a 0x4e 0x49 0x43]
 [0x3f 0x55 0x58 0x55 0x39 0x45 0x46 0x3f 0x4f 0x5d 0x2a 0x30 0x4c 0x42 0x47 0x33]
 [0x2c 0x37 0x29 0x3a 0x2e 0x2d 0x27 0x29 0x2d 0x2b 0x15 0x1f 0x2f 0x3e 0x27 0x1a]
 [0x3a 0x52 0x61 0x40 0x33 0x4b 0x3f 0x2f 0x44 0x65 0x2c 0x33 0x47 0x45 0x4c 0x38]
 [0x2d 0x34 0x3f 0x4f 0x33 0x3b 0x3d 0x27 0x47 0x41 0x2e 0x39 0x34 0x33 0x34 0x41]
 [0x3a 0x54 0x60 0x63 0x3a 0x4c 0x42 0x3e 0x67 0x5f 0x26 0x30 0x4c 0x47 0x52 0x3a]
 [0x31 0x3b 0x3b 0x43 0x3a 0x3c 0x44 0x24 0x33 0x3e 0x29 0x3c 0x3b 0x3c 0x30 0x3c]
 [0x44 0x60 0x71 0x63 0x44 0x4c 0x4f 0x36 0x66 0x68 0x2e 0x4e 0x5a 0x4c 0x59 0x47]
 [0x36 0x47 0x48 0x4d 0x30 0x3b 0x47 0x37 0x45 0x4f 0x28 0x38 0x4d 0x42 0x33 0x2d]
 [0x2c 0x44 0x45 0x36 0x36 0x32 0x3e 0x11 0x36 0x3c 0x15 0x35 0x39 0x40 0x34 0x34]
 [0x35 0x44 0x55 0x51 0x26 0x39 0x20 0x39 0x5a 0x53 0x23 0x1e 0x48 0x2f 0x44 0x2b]
 [0x2c 0x27 0x38 0x4d 0x2e 0x35 0x2a 0x21 0x46 0x39 0x1e 0x38 0x2e 0x32 0x2d 0x3f]
 [0x31 0x33 0x3e 0x44 0x30 0x3e 0x1f 0x33 0x42 0x4d 0x2a 0x1c 0x38 0x38 0x30 0x2d]
 [0x42 0x4c 0x51 0x5b 0x2b 0x4d 0x3e 0x49 0x51 0x52 0x26 0x2d 0x44 0x47 0x45 0x36]
 [0x19 0x26 0x28 0x28 0x20 0x1e 0x22 0x12 0x25 0x29 0xe 0x21 0x26 0x22 0x22 0x1c]
 [0x30 0x40 0x36 0x3b 0x25 0x39 0x48 0x2b 0x2d 0x45 0x20 0x31 0x41 0x3e 0x23 0x2a]]
*/

integer a_start_addr = 0;
integer b_start_addr = 300;
integer c_start_addr = 700;
integer problem_size = 16;

reg [`DWIDTH-1:0] a[16][16] = 
'{{8'd4,8'd4,8'd1,8'd3,8'd2,8'd2,8'd4,8'd1,8'd0,8'd4,8'd3,8'd2,8'd2,8'd2,8'd1,8'd4},
  {8'd2,8'd4,8'd3,8'd0,8'd2,8'd1,8'd1,8'd2,8'd3,8'd3,8'd2,8'd2,8'd4,8'd2,8'd3,8'd2},
  {8'd4,8'd1,8'd3,8'd0,8'd4,8'd2,8'd0,8'd0,8'd1,8'd2,8'd1,8'd0,8'd0,8'd1,8'd1,8'd2},
  {8'd0,8'd4,8'd0,8'd0,8'd1,8'd3,8'd4,8'd4,8'd1,8'd3,8'd3,8'd0,8'd4,8'd3,8'd4,8'd0},
  {8'd0,8'd3,8'd1,8'd4,8'd1,8'd2,8'd0,8'd2,8'd2,8'd1,8'd4,8'd2,8'd0,8'd1,8'd4,8'd3},
  {8'd3,8'd4,8'd1,8'd0,8'd2,8'd3,8'd0,8'd4,8'd4,8'd1,8'd3,8'd4,8'd2,8'd1,8'd2,8'd4},
  {8'd0,8'd3,8'd3,8'd3,8'd3,8'd1,8'd2,8'd0,8'd1,8'd3,8'd3,8'd1,8'd0,8'd0,8'd4,8'd2},
  {8'd4,8'd4,8'd0,8'd2,8'd0,8'd2,8'd2,8'd3,8'd4,8'd4,8'd3,8'd4,8'd1,8'd2,8'd4,8'd4},
  {8'd2,8'd3,8'd2,8'd2,8'd4,8'd0,8'd0,8'd2,8'd4,8'd3,8'd2,8'd2,8'd1,8'd3,8'd1,8'd2},
  {8'd4,8'd1,8'd0,8'd1,8'd2,8'd1,8'd2,8'd2,8'd1,8'd4,8'd3,8'd2,8'd0,8'd0,8'd4,8'd0},
  {8'd4,8'd4,8'd1,8'd0,8'd0,8'd2,8'd2,8'd3,8'd1,8'd0,8'd0,8'd4,8'd3,8'd3,8'd0,8'd4},
  {8'd3,8'd1,8'd3,8'd4,8'd0,8'd0,8'd2,8'd3,8'd1,8'd0,8'd3,8'd1,8'd0,8'd0,8'd2,8'd4},
  {8'd2,8'd3,8'd4,8'd0,8'd1,8'd1,8'd1,8'd3,8'd0,8'd0,8'd2,8'd0,8'd2,8'd4,8'd3,8'd2},
  {8'd1,8'd2,8'd4,8'd2,8'd4,8'd3,8'd2,8'd4,8'd2,8'd1,8'd0,8'd1,8'd4,8'd1,8'd1,8'd4},
  {8'd2,8'd2,8'd0,8'd0,8'd1,8'd0,8'd2,8'd0,8'd1,8'd1,8'd3,8'd1,8'd1,8'd0,8'd0,8'd1},
  {8'd0,8'd1,8'd2,8'd2,8'd4,8'd1,8'd0,8'd1,8'd3,8'd3,8'd3,8'd2,8'd1,8'd3,8'd1,8'd0}};

reg [`DWIDTH-1:0] b[16][16] = 
'{{8'd2,8'd3,8'd2,8'd4,8'd3,8'd0,8'd0,8'd1,8'd4,8'd1,8'd0,8'd1,8'd2,8'd3,8'd3,8'd1},
  {8'd1,8'd1,8'd3,8'd3,8'd3,8'd1,8'd0,8'd2,8'd4,8'd4,8'd4,8'd0,8'd3,8'd0,8'd3,8'd1},
  {8'd3,8'd1,8'd0,8'd3,8'd2,8'd4,8'd1,8'd3,8'd1,8'd4,8'd1,8'd0,8'd2,8'd3,8'd0,8'd2},
  {8'd2,8'd0,8'd0,8'd4,8'd0,8'd0,8'd3,8'd1,8'd2,8'd0,8'd3,8'd4,8'd1,8'd0,8'd0,8'd4},
  {8'd1,8'd3,8'd1,8'd2,8'd2,8'd2,8'd4,8'd2,8'd1,8'd0,8'd1,8'd1,8'd3,8'd4,8'd1,8'd1},
  {8'd3,8'd4,8'd2,8'd3,8'd1,8'd4,8'd1,8'd3,8'd2,8'd3,8'd1,8'd0,8'd1,8'd4,8'd4,8'd1},
  {8'd1,8'd3,8'd4,8'd0,8'd1,8'd3,8'd2,8'd0,8'd0,8'd4,8'd0,8'd4,8'd4,8'd3,8'd4,8'd3},
  {8'd1,8'd0,8'd4,8'd1,8'd0,8'd3,8'd0,8'd0,8'd4,8'd4,8'd0,8'd0,8'd1,8'd2,8'd1,8'd2},
  {8'd0,8'd3,8'd2,8'd2,8'd0,8'd1,8'd4,8'd3,8'd1,8'd3,8'd0,8'd3,8'd2,8'd2,8'd4,8'd0},
  {8'd4,8'd4,8'd4,8'd0,8'd2,8'd2,8'd4,8'd0,8'd0,8'd3,8'd0,8'd4,8'd3,8'd3,8'd0,8'd0},
  {8'd2,8'd2,8'd2,8'd4,8'd4,8'd4,8'd4,8'd0,8'd3,8'd4,8'd1,8'd4,8'd2,8'd4,8'd1,8'd4},
  {8'd1,8'd3,8'd3,8'd2,8'd0,8'd2,8'd3,8'd0,8'd3,8'd3,8'd0,8'd0,8'd4,8'd0,8'd1,8'd3},
  {8'd3,8'd4,8'd3,8'd4,8'd0,8'd1,8'd3,8'd4,8'd3,8'd2,8'd1,8'd0,8'd1,8'd0,8'd3,8'd1},
  {8'd2,8'd2,8'd2,8'd1,8'd0,8'd2,8'd0,8'd3,8'd1,8'd4,8'd3,8'd1,8'd4,8'd2,8'd0,8'd0},
  {8'd0,8'd2,8'd2,8'd1,8'd3,8'd1,8'd2,8'd0,8'd1,8'd0,8'd2,8'd1,8'd0,8'd1,8'd3,8'd3},
  {8'd2,8'd1,8'd3,8'd4,8'd2,8'd2,8'd0,8'd3,8'd4,8'd0,8'd1,8'd3,8'd1,8'd1,8'd2,8'd1}};

reg [`DWIDTH-1:0] c[16][16] = 
'{{ 8'd76,8'd89,8'd98,8'd97,8'd67,8'd74,8'd70,8'd54,8'd89,8'd92,8'd47,8'd77,8'd90,8'd78,8'd73,8'd67},
  { 8'd63,8'd85,8'd88,8'd85,8'd57,8'd69,8'd70,8'd63,8'd79,8'd93,8'd42,8'd48,8'd76,8'd66,8'd71,8'd51},
  { 8'd44,8'd55,8'd41,8'd58,8'd46,8'd45,8'd39,8'd41,8'd45,8'd43,8'd21,8'd31,8'd47,8'd62,8'd39,8'd26},
  { 8'd58,8'd82,8'd97,8'd64,8'd51,8'd75,8'd63,8'd47,8'd68,8'd101,8'd44,8'd51,8'd71,8'd69,8'd76,8'd56},
  { 8'd45,8'd52,8'd63,8'd79,8'd51,8'd59,8'd61,8'd39,8'd71,8'd65,8'd46,8'd57,8'd52,8'd51,8'd52,8'd65},
  { 8'd58,8'd84,8'd96,8'd99,8'd58,8'd76,8'd66,8'd62,8'd103,8'd95,8'd38,8'd48,8'd76,8'd71,8'd82,8'd58},
  { 8'd49,8'd59,8'd59,8'd67,8'd58,8'd60,8'd68,8'd36,8'd51,8'd62,8'd41,8'd60,8'd59,8'd60,8'd48,8'd60},
  { 8'd68,8'd96,8'd113,8'd99,8'd68,8'd76,8'd79,8'd54,8'd102,8'd104,8'd46,8'd78,8'd90,8'd76,8'd89,8'd71},
  { 8'd54,8'd71,8'd72,8'd77,8'd48,8'd59,8'd71,8'd55,8'd69,8'd79,8'd40,8'd56,8'd77,8'd66,8'd51,8'd45},
  { 8'd44,8'd68,8'd69,8'd54,8'd54,8'd50,8'd62,8'd17,8'd54,8'd60,8'd21,8'd53,8'd57,8'd64,8'd52,8'd52},
  { 8'd53,8'd68,8'd85,8'd81,8'd38,8'd57,8'd32,8'd57,8'd90,8'd83,8'd35,8'd30,8'd72,8'd47,8'd68,8'd43},
  { 8'd44,8'd39,8'd56,8'd77,8'd46,8'd53,8'd42,8'd33,8'd70,8'd57,8'd30,8'd56,8'd46,8'd50,8'd45,8'd63},
  { 8'd49,8'd51,8'd62,8'd68,8'd48,8'd62,8'd31,8'd51,8'd66,8'd77,8'd42,8'd28,8'd56,8'd56,8'd48,8'd45},
  { 8'd66,8'd76,8'd81,8'd91,8'd43,8'd77,8'd62,8'd73,8'd81,8'd82,8'd38,8'd45,8'd68,8'd71,8'd69,8'd54},
  { 8'd25,8'd38,8'd40,8'd40,8'd32,8'd30,8'd34,8'd18,8'd37,8'd41,8'd14,8'd33,8'd38,8'd34,8'd34,8'd28},
  { 8'd48,8'd64,8'd54,8'd59,8'd37,8'd57,8'd72,8'd43,8'd45,8'd69,8'd32,8'd49,8'd65,8'd62,8'd35,8'd42}};

`endif

////////////////////////////////////////////
//Task to initialize BRAMs
////////////////////////////////////////////
task initialize_brams();
begin
   //A is stored in col major format
   for (int i=0; i<problem_size; i++) begin
       for (int j=0; j<problem_size; j++) begin
           u_top.matrix_A.ram[a_start_addr+problem_size*i+j] = a[j][i];
       end
   end

  //B is stored in row major format
   for (int i=0; i<problem_size; i++) begin
       for (int j=0; j<problem_size; j++) begin
           u_top.matrix_B.ram[b_start_addr+problem_size*i+j] = b[i][j];
       end
    end

end
endtask


////////////////////////////////////////////
//Task to compare outputs with expected values
////////////////////////////////////////////
task compare_outputs();
begin
   integer fail = 0;
   integer address, observed, expected;
   //C is stored like A
   ////////Note that this is only testing first layer
   for (int i=0; i<problem_size; i++) begin
       for (int j=0; j<problem_size; j++) begin
           address = c_start_addr+problem_size*i+j;
           observed = u_top.matrix_A.ram[address];
           expected = (c[j][i] - mean) * inv_var;
           if (expected != observed) begin
             $display("Mismatch found. Address = %0d, Expected = %0d, Observed = %0d", address, expected, observed);
             fail = 1;
           end
       end
   end
   if (fail == 0) begin
     $display("===============================");
     $display("Test passed (only first layer's output was compared)");
     $display("===============================");
   end
end
endtask

////////////////////////////////////////////
//The actual test
////////////////////////////////////////////
task layer_test();
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

  $display("Configure the value of mean and inv_variance");
  write(`REG_MEAN_ADDR, mean);
  write(`REG_INV_VAR_ADDR, inv_var);

  $display("-------------------------------------------");
  $display("Layer 0");
  $display("-------------------------------------------");
  $display("Configure the addresses of matrix A, B and C");
  write(`REG_MATRIX_A_ADDR, a_start_addr);
  write(`REG_MATRIX_B_ADDR, b_start_addr);
  //write(`REG_MATRIX_C_ADDR, c_start_addr); 
  //with this matmul, we need to enter the address of the last column
  write(`REG_MATRIX_C_ADDR, c_start_addr+((problem_size-1)*problem_size)); 

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

  $display("-------------------------------------------");
  $display("Layer 1");
  $display("-------------------------------------------");
  $display("Configure the addresses of matrix A, B and C");
  //matrix A -> addr_mat_c (the last layer wrote output here)
  write(`REG_MATRIX_A_ADDR, c_start_addr); //
  write(`REG_MATRIX_B_ADDR, b_start_addr);
  write(`REG_MATRIX_C_ADDR, c_start_addr+500);

  $display("Restart the TPU");
  //start = 1; //also pe_reset = 1, because this is a fresh layer
  write(`REG_STDN_TPU_ADDR, 32'h0000_8001);
  
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
