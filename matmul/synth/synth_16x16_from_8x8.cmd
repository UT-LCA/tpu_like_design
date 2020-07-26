analyze -format verilog {
../16x16_from_8x8.with_ram.gen.v
../8x8.organized.no_conv.no_accum.gen.v
}
elaborate matmul_16x16_systolic -architecture verilog -library DEFAULT
link
#set_implementation pparch u_add
#set_implementation pparch u_mult
set_dp_smartgen_options -all_options auto -hierarchy -smart_compare true -optimize_for speed -sop2pos_transformation false
create_clock -name "clk" -period 3 -waveform { 0 1.5 }  { clk  }
set_operating_conditions -library gscl45nm typical
remove_wire_load_model
compile -exact_map
uplevel #0 { report_timing -path full -delay max -nworst 1 -max_paths 1 -significant_digits 2 -sort_by group } >> Report.16x16_from_8x8.timing.max.txt
#uplevel #0 { report_timing -path_type end -from [all_inputs] } >> Report.16x16_from_8x8.timing.all.txt
#uplevel #0 { report_timing -path_type end } >> Report.16x16_from_8x8.timing.all.txt
#uplevel #0 { report_timing -path_type end -to [all_outputs] } >> Report.16x16_from_8x8.timing.all.txt
uplevel #0 { report_area -hierarchy } >> Report.16x16_from_8x8.area.txt
uplevel #0 { report_power -analysis_effort low } >> Report.16x16_from_8x8.power.txt
uplevel #0 { report_design -nosplit } >> Report.16x16_from_8x8.design.txt
exit
