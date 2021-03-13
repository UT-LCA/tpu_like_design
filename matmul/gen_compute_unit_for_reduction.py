import os
import re
import argparse
import math

#Only tested for the fixed16 dtype
class generate_compute_unit():
  def __init__(self, num_inputs, dtype="float16"):
    self.num_inputs = num_inputs
    self.dtype = dtype
    #find if the num_inputs is a power of 2
    if ((self.num_inputs-1) & self.num_inputs) != 0:
      raise SystemError("the design only supports number of inputs = power of 2")
    #Example num_inputs = 16, actual inputs = 17
    self.total_number_of_inps_for_reduction_unit = self.num_inputs + 1 #1 is for exp_inp
    #For num_inputs = 16, num_compute_stages_in_reduction_unit = 5 (5,4,3,2,1)
    self.num_compute_stages_in_reduction_unit = int(math.log(self.num_inputs,2)) + 1 
    #For num_inputs = 16, num_flop_stages_in_reduction_unit = 5 (includes the input stage. so really in this module, there should be only 4 set of flops generated)
    self.num_flop_stages_in_reduction_unit = self.num_compute_stages_in_reduction_unit
    self.printit()
  
  def printit(self):
    float_match = re.search(r'float', self.dtype)
    fixed_match = re.search(r'fixed', self.dtype)
    print("")
    print("module reduction_unit(")
    print("  clk,")
    print("  reset,")
    for iter in range(self.num_inputs):
      print("  inp%d, " % iter)
    print("")
    print("  mode,")
    print("  outp")
    print(");")
    print("")

    print("  input clk;")
    print("  input reset;")
    for iter in range(self.num_inputs):
      print("  input  [`DWIDTH-1 : 0] inp%d; " % iter)
    print("  input [1:0] mode;")
    print("  output [`DWIDTH+`LOGDWIDTH-1 : 0] outp;")
    print("")
   
    for i in reversed(range(self.num_compute_stages_in_reduction_unit)):
      stageN = i;
      if i == 0:
        print("  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute0_out_stage0;")
        break
      else:
        num_computers_in_stageN = int(1<<(i-1))
      for num_computer in range(num_computers_in_stageN):
        print("  wire   [`DWIDTH+`LOGDWIDTH-1 : 0] compute%d_out_stage%d;" % (num_computer, stageN))
        print("  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] compute%d_out_stage%d_reg;" % (num_computer, stageN))
      print("")
    print("  reg    [`DWIDTH+`LOGDWIDTH-1 : 0] outp;")
    print("")


#-----------------internal control logic------------------# 
    print("  always @(posedge clk) begin") 
    print("    if (reset) begin")
    print("      outp <= 0;")
    for i in reversed(range(self.num_compute_stages_in_reduction_unit)):
      stageN = i;
      if i == 0:
        break
      else:
        num_computers_in_stageN = int(1<<(i-1))
      for num_computer in range(num_computers_in_stageN):
        print("      compute%d_out_stage%d_reg <= 0;" % (num_computer, stageN))
    print("    end")
    print("")
    print("    else begin")
    for i in reversed(range(self.num_compute_stages_in_reduction_unit)):
      stageN = i;
      if i == 0:
        print("      outp <= compute0_out_stage0;")  
        print("")
      else:
        num_computers_in_stageN = int(1<<(i-1))
        for num_computer in range(num_computers_in_stageN):
          print("      compute%d_out_stage%d_reg <= compute%d_out_stage%d;" %(num_computer, stageN, num_computer, stageN))
        print("")
    print("    end")
    print("  end")
    print("")

#-----------------Instantiate and connect blocks------------------# 
    for stage in reversed(range(self.num_compute_stages_in_reduction_unit)):
      #for the right most stage
      if stage == 0:
        if(self.num_compute_stages_in_reduction_unit > 1):
          if float_match is not None:
            print("  float_compute #(`MANTISSA, `EXPONENT, `IEEE_COMPLIANCE) compute0_stage0(.a(outp),       .b(compute0_out_stage1_reg),      .z(compute0_out_stage0),     .status());")
          elif fixed_match is not None:
            print("  processing_element #(`DWIDTH+`LOGDWIDTH,`DWIDTH+`LOGDWIDTH) compute0_stage0(.A(outp),       .B(compute0_out_stage1_reg),     .OUT(compute0_out_stage0), .MODE(mode));")
          else:
            raise SystemExit("Incorrect value passed for dtype. Given = %s. Supported = float16, float32, fixed16, fixed32" % (self.dtype))
        else:
          if float_match is not None:
            print("  float_compute #(`MANTISSA, `EXPONENT, `IEEE_COMPLIANCE) compute0_stage0(.a(outp),       .b(inp0),      .z(compute0_out_stage0), .status());")
          elif fixed_match is not None:
            print("  processing_element #(`DWIDTH+`LOGDWIDTH,`DWIDTH+`LOGDWIDTH) compute0_stage0(.A(outp),       .B(inp0),     .OUT(compute0_out_stage0), .MODE(mode));")
          else:
            raise SystemExit("Incorrect value passed for dtype. Given = %s. Supported = float16, float32, fixed16, fixed32" % (self.dtype))
        print("")
        continue
     
      num_computers_in_current_stage = int(1<<(stage-1))
      num_computer_cur_stage = 0
      num_computer_last_stage = 0

      #for the left most stage
      if stage == self.num_compute_stages_in_reduction_unit - 1:
        inp_num = 0
        for num_computer in range(num_computers_in_current_stage):
          if float_match is not None:
            print("  float_compute #(`MANTISSA, `EXPONENT, `IEEE_COMPLIANCE) compute%d_stage%d(.a(inp%d),       .b(inp%d),      .z(compute%d_out_stage%d),     .status());" % (num_computer_cur_stage, stage, inp_num, inp_num+1, num_computer_cur_stage, stage))
          elif fixed_match is not None:
            print("  processing_element #(`DWIDTH,`DWIDTH+`LOGDWIDTH) compute%d_stage%d(.A(inp%d),       .B(inp%d),    .OUT(compute%d_out_stage%d), .MODE(mode));" % (num_computer_cur_stage, stage, inp_num, inp_num+1, num_computer_cur_stage, stage))
          else:
            raise SystemExit("Incorrect value passed for dtype. Given = %s. Supported = float16, float32, fixed16, fixed32" % (self.dtype))
          inp_num = inp_num + 2
          num_computer_cur_stage = num_computer_cur_stage + 1
        print("")
        continue

      #for the stages in the middle
      for num_computer in range(num_computers_in_current_stage):
        if float_match is not None:
          print("  float_compute #(`MANTISSA, `EXPONENT, `IEEE_COMPLIANCE) compute%d_stage%d(.a(compute%d_out_stage%d_reg),       .b(compute%d_out_stage%d_reg),      .z(compute%d_out_stage%d),    .status());" % (num_computer_cur_stage, stage, num_computer_last_stage, stage+1, num_computer_last_stage+1, stage+1, num_computer_cur_stage, stage))
        elif fixed_match is not None:
          print("  processing_element #(`DWIDTH+`LOGDWIDTH,`DWIDTH+`LOGDWIDTH) compute%d_stage%d(.A(compute%d_out_stage%d_reg),       .B(compute%d_out_stage%d_reg),    .OUT(compute%d_out_stage%d), .MODE(mode));" % (num_computer_cur_stage, stage, num_computer_last_stage, stage+1, num_computer_last_stage+1, stage+1, num_computer_cur_stage, stage))
        else:
          raise SystemExit("Incorrect value passed for dtype. Given = %s. Supported = float16, float32, fixed16, fixed32" % (self.dtype))
        num_computer_cur_stage = num_computer_cur_stage + 1
        num_computer_last_stage = num_computer_last_stage + 2
      print("")  
    print("endmodule")
    print("")

def generate_instance(num):
  for i in range(0,num):
    print(".inp{a}(bram_in_rdata[{b}*`DWIDTH-1:{a}*`DWIDTH]),".format(a=i, b=i+1))
#  .inp27(bram_in_rdata[28*`DWIDTH-1:27*`DWIDTH]), 

  
   
# ###############################################################
# main()
# ###############################################################
if __name__ == "__main__":
  generate_compute_unit(128, 'fixed16')
  generate_instance(128)
