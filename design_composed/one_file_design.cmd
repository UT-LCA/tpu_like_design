#!/bin/tcsh

#set output_file = "tpu_16x16.int8.fpga_with_matmul.v"
#
#\rm -f $output_file
#touch $output_file
#
#echo '`define MATMUL_SIZE_8\n\n' >> $output_file
#echo '`define DESIGN_SIZE_16\n\n' >> $output_file
#foreach i (\
#../design_organized/defines.v \
#../design_composed/16x16_from_8x8.int8.no_ram.gen.for_combined_matmul.v \
#../design_composed/16x16_from_8x8.wrap.v \
#../design_organized/cfg.v \
#../design_organized/norm.v \
#../design_organized/ram.v \
#../design_organized/control.v \
#../design_organized/pool.v \
#../design_organized/activation.v \
#../design_organized/top.v \
#)
#
#echo "//////////////////////////\n" >> $output_file
#echo "//$i \n" >> $output_file
#echo "//////////////////////////\n" >> $output_file
#cat $i >> $output_file
#echo "\n" >> $output_file
#perl -i -pe 's/d`DESIGN_SIZE/d16/g;' $output_file
#perl -i -pe 's/matmul_slice/matmul_int8/g;' $output_file
#end
#
#
#set output_file = "tpu_16x16.int8.fpga_with_dsp.v"
#
#\rm -f $output_file
#touch $output_file
#
#echo '`define MATMUL_SIZE_8\n\n' >> $output_file
#echo '`define DESIGN_SIZE_16\n\n' >> $output_file
#foreach i (\
#../design_organized/defines.v \
#../design_composed/16x16_from_8x8.no_ram.gen.v \
#../design_composed/16x16_from_8x8.wrap.v \
#../design_organized/8x8.organized.no_conv.no_accum.gen.v \
#../design_organized/cfg.v \
#../design_organized/norm.v \
#../design_organized/ram.v \
#../design_organized/control.v \
#../design_organized/pool.v \
#../design_organized/activation.v \
#../design_organized/top.v \
#)
#
#echo "//////////////////////////\n" >> $output_file
#echo "//$i \n" >> $output_file
#echo "//////////////////////////\n" >> $output_file
#cat $i >> $output_file
#echo "\n" >> $output_file
#perl -i -pe 's/d`DESIGN_SIZE/d16/g;' $output_file
#end




set output_file = "tpu_32x32.int8.fpga_with_matmul.v"

\rm -f $output_file
touch $output_file

echo '`define MATMUL_SIZE_8\n\n' >> $output_file
echo '`define DESIGN_SIZE_32\n\n' >> $output_file
foreach i (\
../design_organized/defines.v \
../design_composed/32x32_from_8x8.int8.no_ram.gen.for_combined_matmul.v \
../design_composed/32x32_from_8x8.wrap.v \
../design_organized/cfg.v \
../design_organized/norm.v \
../design_organized/ram.v \
../design_organized/control.v \
../design_organized/pool.v \
../design_organized/activation.v \
../design_organized/top.v \
)

echo "//////////////////////////\n" >> $output_file
echo "//$i \n" >> $output_file
echo "//////////////////////////\n" >> $output_file
cat $i >> $output_file
echo "\n" >> $output_file
perl -i -pe 's/d`DESIGN_SIZE/d32/g;' $output_file
perl -i -pe 's/matmul_slice/matmul_int8/g;' $output_file
end


set output_file = "tpu_32x32.int8.fpga_with_dsp.v"

\rm -f $output_file
touch $output_file

echo '`define MATMUL_SIZE_8\n\n' >> $output_file
echo '`define DESIGN_SIZE_32\n\n' >> $output_file
foreach i (\
../design_organized/defines.v \
../design_composed/32x32_from_8x8.no_ram.gen.v \
../design_composed/32x32_from_8x8.wrap.v \
../design_organized/8x8.organized.no_conv.no_accum.gen.v \
../design_organized/cfg.v \
../design_organized/norm.v \
../design_organized/ram.v \
../design_organized/control.v \
../design_organized/pool.v \
../design_organized/activation.v \
../design_organized/top.v \
)

echo "//////////////////////////\n" >> $output_file
echo "//$i \n" >> $output_file
echo "//////////////////////////\n" >> $output_file
cat $i >> $output_file
echo "\n" >> $output_file
perl -i -pe 's/d`DESIGN_SIZE/d32/g;' $output_file
end




