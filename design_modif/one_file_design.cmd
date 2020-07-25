#!/bin/tcsh

#set output_file = "one_file_design_4x4.v"
#
#\rm -f $output_file
#touch $output_file
#
#echo '`define MATMUL_SIZE_4\n\n' >> $output_file
#foreach i (defines.v 4x4.v cfg.v norm.v ram.v control.v pool.v activation.v top.v)
#echo "//////////////////////////\n" >> $output_file
#echo "//$i \n" >> $output_file
#echo "//////////////////////////\n" >> $output_file
#cat $i >> $output_file
#echo "\n" >> $output_file
#perl -i -pe 's/d`MAT_MUL_SIZE/d4/g;' $output_file
#end

set output_file = "one_file_design_8x8.v"

\rm -f $output_file
touch $output_file

echo '`define MATMUL_SIZE_8\n\n' >> $output_file
foreach i (../design/defines.v 8x8.organized.no_conv.no_accum.gen.v cfg.v ../design/norm.v ../design/ram.v ../design/control.v ../design/pool.v ../design/activation.v top.v)
echo "//////////////////////////\n" >> $output_file
echo "//$i \n" >> $output_file
echo "//////////////////////////\n" >> $output_file
cat $i >> $output_file
echo "\n" >> $output_file
perl -i -pe 's/d`MAT_MUL_SIZE/d8/g;' $output_file
end


set output_file = "one_file_design_16x16.v"

\rm -f $output_file
touch $output_file

echo '`define MATMUL_SIZE_16\n\n' >> $output_file
foreach i (../design/defines.v 16x16.organized.no_conv.no_accum.gen.v cfg.v ../design/norm.v ../design/ram.v ../design/control.v ../design/pool.v ../design/activation.v top.v)
echo "//////////////////////////\n" >> $output_file
echo "//$i \n" >> $output_file
echo "//////////////////////////\n" >> $output_file
cat $i >> $output_file
echo "\n" >> $output_file
perl -i -pe 's/d`MAT_MUL_SIZE/d16/g;' $output_file
end



