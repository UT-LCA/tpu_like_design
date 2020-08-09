analyze -format verilog {
/home/projects/ljohn/aarora1/samidh_internship2020/Internship_2020/floating_point/16_bit/fp16_multiplier_modif.v \
/home/projects/ljohn/aarora1/samidh_internship2020/Internship_2020/floating_point/32_bit/Stratix10/DSP_Slice/FpAddSub_single.modif.v \
/home/projects/ljohn/aarora1/samidh_internship2020/Internship_2020/floating_point/converter_fp/fp16_to_fp32.v \
/home/projects/ljohn/aarora1/samidh_internship2020/Internship_2020/floating_point/converter_fp/fp32_to_fp16.v \
../8x8int8.4x4fp16.organized.combined.v
}
elaborate systolic_pe_matrix -architecture verilog -library DEFAULT
#set_case_analysis 1 slice_mode
#set_case_analysis 0 slice_dtype
#set_case_analysis 0 address_mat_b[5]
#set_case_analysis 0 address_mat_c[0]
#set_case_analysis 0 address_mat_c[1]
#set_case_analysis 1 address_mat_c[2]
#set_case_analysis 0 direct_dtype
set_case_analysis 0 input_list_to_pes[245]
set_case_analysis 0 input_list_to_pes[246]
set_case_analysis 0 input_list_to_pes[247]
set_case_analysis 0 input_list_to_pes[248]
set_case_analysis 0 input_list_to_pes[249]
set_case_analysis 0 input_list_to_pes[250]
set_case_analysis 0 input_list_to_pes[251]
set_case_analysis 1 slice_mode
link
#uniquify
#set_implementation pparch u_add
#set_implementation pparch u_mult
set_dp_smartgen_options -all_options auto -hierarchy -smart_compare true -optimize_for speed -sop2pos_transformation false
create_clock -name "clk" -period 3 -waveform { 0 1.5 }  { clk  }
#set_operating_conditions -library gscl45nm typical
#remove_wire_load_model
compile -exact_map
#compile_ultra
#uplevel #0 { check_design } >> Report.8x8int8.4x4fp16.check_design.txt
#link
#ungroup -all -flatten 
uplevel #0 { report_timing -path full -delay max -nworst 1 -max_paths 1 -significant_digits 2 -sort_by group } >> Report.8x8int8.4x4fp16.timing.max.3.txt
#uplevel #0 { report_area -hierarchy } >> Report.8x8int8.4x4fp16.area.2.txt
exit
