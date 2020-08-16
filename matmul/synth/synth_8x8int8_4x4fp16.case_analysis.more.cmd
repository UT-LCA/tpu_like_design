analyze -format verilog {
/home/projects/ljohn/aarora1/samidh_internship2020/Internship_2020/floating_point/16_bit/fp16_multiplier_modif.v \
/home/projects/ljohn/aarora1/samidh_internship2020/Internship_2020/floating_point/32_bit/Stratix10/DSP_Slice/FpAddSub_single.modif.v \
/home/projects/ljohn/aarora1/samidh_internship2020/Internship_2020/floating_point/converter_fp/fp16_to_fp32.v \
/home/projects/ljohn/aarora1/samidh_internship2020/Internship_2020/floating_point/converter_fp/fp32_to_fp16.v \
../8x8int8.4x4fp16.organized.combined.v
}
elaborate -architecture verilog -library DEFAULT

####################
#indiv pe fp16 mac comb
####################
#in indiv pe mode
set_case_analysis 1 slice_mode
#all pes in fp16 mode
set_case_analysis 1 address_mat_b[5]
set_case_analysis 1 address_mat_b[6]
set_case_analysis 1 address_mat_b[7]
set_case_analysis 1 address_mat_b[8]
set_case_analysis 1 address_mat_b[9]
set_case_analysis 1 address_mat_b[10]
set_case_analysis 1 address_mat_b[11]
#all pes in combinatorial mode
set_case_analysis 0 address_mat_c[2]
set_case_analysis 0 address_mat_c[5]
set_case_analysis 0 address_mat_c[8]
set_case_analysis 0 address_mat_c[11]
set_case_analysis 0 address_mat_c[14]
set_case_analysis 0 address_mat_b[1]
set_case_analysis 0 address_mat_b[4]
#all pes in mac mode
set_case_analysis 0 address_mat_c[1]
set_case_analysis 0 address_mat_c[4]
set_case_analysis 0 address_mat_c[7]
set_case_analysis 0 address_mat_c[10]
set_case_analysis 0 address_mat_c[13]
set_case_analysis 0 address_mat_b[0]
set_case_analysis 0 address_mat_b[3]

set_case_analysis 0 address_mat_c[0]
set_case_analysis 0 address_mat_c[3]
set_case_analysis 0 address_mat_c[6]
set_case_analysis 0 address_mat_c[9]
set_case_analysis 0 address_mat_c[12]
set_case_analysis 0 address_mat_c[15]
set_case_analysis 0 address_mat_b[2]

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
