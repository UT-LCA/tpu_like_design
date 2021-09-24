# Introduction
This repo contains a parameterizable TPU-like design (in Verilog) that will be overlayed onto an FPGA (probably PYNQ). We plan to add this design to VTR to serve as a benchmark for FPGA architecture exploration. 

This TPU-like design was designed as a part of a class project (for the class: Hardware Architectures for Machine Learning by Prof. Lizy John) in Spring 2020 semester by Aman Arora, Bagus Hanindhito, Harsh Gugale. An existing matmul design (from Aman's previous research) was used as the basis of the design. 

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
where N is the size of the matmul (only square matmuls are supported. So, this is really NxNxN matmul). Currently (as of May 2020) only 4 and 8 are supported.

There are 2 tests currently (as of May 2020) in the testbench:
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

# Updates to TPU design and verif
Since May 2020, there have been many updates to the design. The instructions above still work but there have been many updates. Here's
* Adding larger sizes like 16x16, 32x32
* Adding native convolution support
* Adding support for non-square problem sizes, non-power-of-2 problem sizes, problem sizes smaller than matmul size
* Adding convolution tests (conv_test_no_padding, conv_test_with_padding, conv_test_padding_stride)
* Organizing matmul design into sub-blocks
* Removing accumulator block that was not required
* Adding versions of the design where the matmul design is composed of smaller building block matmuls
* Adding versions of the design using a building block matmul is a "combined" matmul (see definition of "combined" below)
* Adding versions of the design for an FPGA with tensor slices and an FPGA with dsp slices (this is related to some other research work)

# Editing 
This README file requires using markdown to express rich text and formatting. I found this cheatsheet helpful: https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet

# Directories
## design
Contains files from the original implementation. There are 3 matmul sizes here: 4x4, 8x8, 16x16. Each matmul is a full matmul i.e. it is not composed of smaller matmuls. They are either handcoded (4x4) or generated using matmul/create_mat_mul.py (8x8, 16x16).

One file designs just concatenate all Verilog files into one so that it can be used in VTR.

The corresponding verif directory is called verif/.

## design_organized
Second iteration of the design. Using the organized matmul. Organized means that the various blocks inside the matmul (PE matrix, output logic, systolic data setup) are separate modules.

There are a few matmul sizes: 8x8, 16x16 and 32x32. The matmuls are not composed from small matmuls. They are generated using matmul/create_mat_mul.organized.py

The corresponding verif directory is called verif_organized/. Look at Makefiles in this directory to see all files that are actually used because some files are picked from directories other than design_organized.

## design_composed
TPU design containing larger matmuls that are composed using smaller matmuls. There are a few variations of two sizes: 16x16 and 32x32.

These are generated using matmul/matmul_compose.py or matmul/matmul_compose.combined.py

There are variations for fpga with matmul and fpga with DSP slices. The only difference really is the inclusion/exclusion of the definition of the building block matmul.

The corresponding verif directory is called verif_composed/. Look at Makefiles in this directory to see all files that are actually used because some files are picked from directories other than design_composed/.

## matmul
The directory matmul/ contains various variations of the matmul design. This could have been it's own repo actually.
There are some other designs in the matmul directory other than matrix multiplication units. Examples are:
* convolution (conv*)
* elementwise addition (eltwise_add*)
* elementwise multiplication (eltwise_mul*)

# Matmul design
## Scripts 
The matmul designs are not all handcoded. Only the 4x4 designs are. Others are generated using scripts. The scripts are located inside the matmul/ directory.
* create_mat_mul.py : This script is the original script to generate matmul designs > 4x4. No composition is used. The designs are monolithic.
* create_mat_mul.organized.py : This script generates matmul designs without using composition of smaller matmuls. The designs have submodules inside them like PE matrix, systolic data setup and output logic.
* matmul_compose.py : This script generates matmuls composed from smaller matmuls.
* matmul_compose.combined.py : This script generates matmuls composed from smaller matmuls, but the smaller matmul block here supports more modes like fp16 and int8 precisions, individual PE mode, eltwise matrix addition mode, etc.

## Keywords
* "composed" - refers to when multiple smaller blocks (matmuls) are connected to form a larger matmul
* "combined" - refers to a matmul that supports multiple modes in addition to just matrix multiplication. these modes are eltwise add, eltwise mult, indiv pe mode, etc. these designs also support both precisions (int8 and fp16).
* "noconv" - refers to a matmul that doesn't support convolution natively. convolution can still be done by expressing it as a matrix multiplication
* "noaccum" - refers to a matmul design that doesn't have explicit accumulator module. we had this module in earlier implementations, but then later realized that this wasn't required in our matmul (which is output stationary). The PEs themselves serve as accumulators.
* "organized" - refers to a matmul that is organized into sub-modules (like PE matrix, output logic, systolic data setup) instead of being one monolithic module

## Convolution support
### Native support
I added native convolution support into the matmul design. But discontinued it after some time. So, there are many files that say "noconv" that don't have that native convolution support. Later I stopped using that string (noconv) in the filenames, as well. 

By native support, I mean a user won't have to express convolution as matrix multiplication by presenting the matrix multiplier design with matrices that contain the duplicated data. Native support means that there are additional pins on the matmul design (like conv_filter*, conv_stride*, conv_padding*, num_channels*, inp_img*, etc). Using these inputs, the design constructs proper addresses that need to be read/written to at appropriate times. So, the input matrices are just images and weight matrices in NCHW format (no duplication of data) and the output matrix is the output image in NCHW format.

See conv_implementation*.jpg files in the design/ directory to see how this is set up. 

This native conv support had a limitation though. The design couldn't work with stride > 1. That's because of the discontinuity in the addresses along the vertical dimension of resulting matrix A. We rad 8 consecutive addresses from the start address provided. So, whenever there is a discontinuity, we start a new matmul. In the horizontal dimension, we have discontinuity in addresses as well, but we don't want it to be a problem. We can calculate addresses of first element in the a column given all input parameters and provide it to the matmul.

### Non-native support
Non native support just refers to no explicit support in the design to perform convolution. That doesn't mean convolution can't be done. A user will just express convolution as matrix multiplication and perform matrix multiplication using the design. Expressing conv as matmul (GEMM) requires some duplication of data to create the GEMM A and GEMM B matrices from input image and input weight matrices. 

### Alternative native support
The design can however support native support in all conditions (including when stride > 1) if implemented slightly differently. This approach involves changing the address_mat_a and address_stride_a (and address_mat_b and address_stride_b) every clock cycle. Look at the conv* design in the matmul/ directory. It uses this approach. Note that the conv design was not functionally verified (the intent was to have it strucurally have all components of a convolution design). Modifying the convolution support in the matmul design to use an approach like the conv* design in matmul/ directory requires changing the logic that generates address_mat_a/b and address_stride_a/b values from inside the matmul using the variuos convolution parameters.


## Known limitations/bugs/issues
* The matrix multiplication unit is not input stationary; it is output stationary instead
* The pooling block isn't completely functional. It just pools within a set of outputs coming out the matmul unit, but those values are not the correct values that we want to pool from.
* I think the precision game isn't correct either. The accumulation is done in the same precision as the operands.
Work is in progress to improve these things.

## Link to project report
This was a project done for the "Hardware Architectures for Machine Learning" class at UT Austin. The report can be found here: https://sites.google.com/view/amankbm/research (search for TPU)
