# Introduction
This repo contains a parameterizable TPU-like design (in Verilog) that will be overlayed onto an FPGA (probably PYNQ). We plan to add this design to VTR to serve as a benchmark for FPGA architecture exploration. 

# Instructions for the TPU design
I've compiled and tested the design with Synopsys VCS 2018 on UT ECE LRC machines. Use the following command to load the tool:
```
module load synopsys/2018
```
Note that this only works on CentOS7 machines. So, please ensure you are on the right LRC machine: https://www.ece.utexas.edu/it/virtual-linux-resources

Then, to compile and run the simple testbench, you can use:
```
cd verif
make -f Makefile.tpu
```

To run the TPU design with a specific size of the matrix multiplication unit, use:
```
make -f Makefile.tpu size=N
```
where N is the size of the matmul (only square matmuls are supported. So, this is really NxNxN matmul). Currently only 4 and 8 are supported.

There are 2 tests currently in the testbench:
1. Layer test: This test runs 2 layers back to back. Each layer's size matches the size of the matmul. 
2. Accumulator test: This test runs 1 layer, but the layer is larger in size than the matmul. So, this test uses accumulators.

By default, the layer test is run. To run the accumulator test, use:
```
make -f Makefile.tpu run_accumulator
```

This will also dump waveforms. To view waves using DVE, use:
```
make -f Makefile.tpu waves
```
Note that you'll need X server to be enabled to view waves. I use https://mobaxterm.mobatek.net/ for this. 
You can use `make -f Makefile.tpu clean` to remove temporary files and build products, and start fresh.

# Instructions for the 4x4 and 8x8 matrix multiplier designs
Same instructions as above, just change the Makefile's name to Makefile.4x4 or Makefile.8x8

# Submodules in this repo
I've added VTR and PYNQ are submodules to this repo. In the beginning, when we are just working on the design and verifying it, we won't need those. By default, these won't be cloned on cloning the repo. But later, we will need them and then we can do `git submodule update --init --recursive`. 

We will also need to make changes to the files under the submodules. This page clearly lists the steps required to make changes to the submodules: https://stackoverflow.com/questions/5814319/git-submodule-push

I found these helpful as well:
* https://chrisjean.com/git-submodules-adding-using-removing-and-updating/
* https://git-scm.com/book/en/v2/Git-Tools-Submodules

# Editing 
This README file requires using markdown to express rich text and formatting. I found this cheatsheet helpful: https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet

