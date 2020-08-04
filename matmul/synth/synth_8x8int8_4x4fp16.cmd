analyze -format verilog {
../8x8int8.4x4fp16.organized.combined.v
}
elaborate matmul_8x8_systolic -architecture verilog -library DEFAULT
link
#set_implementation pparch u_add
#set_implementation pparch u_mult
set_dp_smartgen_options -all_options auto -hierarchy -smart_compare true -optimize_for speed -sop2pos_transformation false
create_clock -name "clk" -period 3 -waveform { 0 1.5 }  { clk  }
set_operating_conditions -library gscl45nm typical
remove_wire_load_model
compile -exact_map
uplevel #0 { report_timing -path full -delay max -nworst 1 -max_paths 1 -significant_digits 2 -sort_by group } >> Report.8x8int8.4x4fp16.timing.max.txt
#uplevel #0 { report_timing -path_type end -from [all_inputs] } >> Report.8x8int8.4x4fp16.timing.all.txt
#uplevel #0 { report_timing -path_type end } >> Report.8x8int8.4x4fp16.timing.all.txt
#uplevel #0 { report_timing -path_type end -to [all_outputs] } >> Report.8x8int8.4x4fp16.timing.all.txt
uplevel #0 { report_area -hierarchy } >> Report.8x8int8.4x4fp16.area.txt
uplevel #0 { report_power -analysis_effort low } >> Report.8x8int8.4x4fp16.power.txt
uplevel #0 { report_design -nosplit } >> Report.8x8int8.4x4fp16.design.txt
exit
