#!/bin/tcsh

set output_file = "one_file_design_4x4.v"

\rm -f $output_file
touch $output_file

echo '`define MATMUL_SIZE_4\n\n' >> $output_file
foreach i (defines.v 4x4.v cfg.v norm.v ram.v control.v pool.v activation.v top.v)
echo "//////////////////////////\n" >> $output_file
echo "//$i \n" >> $output_file
echo "//////////////////////////\n" >> $output_file
cat $i >> $output_file
echo "\n" >> $output_file
end

set output_file = "one_file_design_8x8.v"

\rm -f $output_file
touch $output_file

echo '`define MATMUL_SIZE_8\n\n' >> $output_file
foreach i (defines.v 8x8_gen.v cfg.v norm.v ram.v control.v pool.v activation.v top.v)
echo "//////////////////////////\n" >> $output_file
echo "//$i \n" >> $output_file
echo "//////////////////////////\n" >> $output_file
cat $i >> $output_file
echo "\n" >> $output_file
end



