#!/bin/tcsh
\rm one_file_design.v
touch one_file_design.v

foreach i (defines.v 4x4.v cfg.v norm.v ram.v control.v pool.v activation.v top.v)
echo "//////////////////////////\n" >> one_file_design.v
echo "//$i \n" >> one_file_design.v
echo "//////////////////////////\n" >> one_file_design.v
cat $i >> one_file_design.v
echo "\n" >> one_file_design.v
end

