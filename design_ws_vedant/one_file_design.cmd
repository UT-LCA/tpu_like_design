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

echo '`define MATMUL_SIZE_8\n`define DESIGN_SIZE_8\n' >> $output_file
foreach i (defines.v 8x8.organized.no_conv.no_accum.gen.v cfg.v norm.v ram.v control.v pool.v activation.v top.v)
echo "//////////////////////////\n" >> $output_file
echo "//$i \n" >> $output_file
echo "//////////////////////////\n" >> $output_file
cat $i >> $output_file
echo "\n" >> $output_file
perl -i -pe 's/d`MAT_MUL_SIZE/d8/g;' $output_file
perl -i -pe 's/d`DESIGN_SIZE/d8/g;' $output_file
end


set output_file = "one_file_design_16x16.v"

\rm -f $output_file
touch $output_file

echo '`define MATMUL_SIZE_16\n`define DESIGN_SIZE_16\n' >> $output_file
foreach i (defines.v 16x16.organized.no_conv.no_accum.gen.v cfg.v norm.v ram.v control.v pool.v activation.v top.v)
echo "//////////////////////////\n" >> $output_file
echo "//$i \n" >> $output_file
echo "//////////////////////////\n" >> $output_file
cat $i >> $output_file
echo "\n" >> $output_file
perl -i -pe 's/d`MAT_MUL_SIZE/d16/g;' $output_file
perl -i -pe 's/d`DESIGN_SIZE/d16/g;' $output_file
end


set output_file = "one_file_design_32x32.v"

\rm -f $output_file
touch $output_file

echo '`define MATMUL_SIZE_32\n`define DESIGN_SIZE_32\n' >> $output_file
foreach i (defines.v 32x32.organized.no_conv.no_accum.gen.v cfg.v norm.v ram.v control.v pool.v activation.v top.v)
echo "//////////////////////////\n" >> $output_file
echo "//$i \n" >> $output_file
echo "//////////////////////////\n" >> $output_file
cat $i >> $output_file
echo "\n" >> $output_file
perl -i -pe 's/d`MAT_MUL_SIZE/d32/g;' $output_file
perl -i -pe 's/d`DESIGN_SIZE/d32/g;' $output_file
end




