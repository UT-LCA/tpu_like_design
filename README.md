# Introduction
This repo contains a parameterizable TPU-like design (in Verilog) that will be overlayed onto an FPGA (probably PYNQ). We plan to add this design to VTR to serve as a benchmark for FPGA architecture exploration. 

# Instructions for the 4x4 matrix multiplier
I've compiled and tested the design with Synopsys VCS 2018. Use the following command to load the tool:
```
module load synopsys/2018
```
Then, to compile and run the simple testbench, you can use:
```
cd verif
make
```
This will also dump waveforms. To view waves, use:
```
make waves
```
