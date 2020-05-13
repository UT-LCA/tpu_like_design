# Begin_DVE_Session_Save_Info
# DVE view(Wave.1 ) session
# Saved on Tue May 12 23:11:54 2020
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Wave.1: 31 signals
# End_DVE_Session_Save_Info

# DVE version: O-2018.09-SP1_Full64
# DVE build date: Nov 29 2018 21:20:12


#<Session mode="View" path="/home/projects/ljohn/aarora1/tpu_like_design/verif/session.vcdplus.vpd.tcl" type="Debug">

#<Database>

gui_set_time_units 1ps
#</Database>

# DVE View/pane content session: 

# Begin_DVE_Session_Save_Info (Wave.1)
# DVE wave signals session
# Saved on Tue May 12 23:11:54 2020
# 31 signals
# End_DVE_Session_Save_Info

# DVE version: O-2018.09-SP1_Full64
# DVE build date: Nov 29 2018 21:20:12


#Add ncecessay scopes
gui_load_child_values {top_tb.u_top.u_control}
gui_load_child_values {top_tb.u_top.u_norm}
gui_load_child_values {top_tb.u_top}
gui_load_child_values {top_tb.u_top.u_pool}
gui_load_child_values {top_tb.u_top.u_cfg}
gui_load_child_values {top_tb.u_top.u_matmul}

gui_set_time_units 1ps

set _wave_session_group_1 Group2
if {[gui_sg_is_group -name "$_wave_session_group_1"]} {
    set _wave_session_group_1 [gui_sg_generate_new_name]
}
set Group1 "$_wave_session_group_1"

gui_sg_addsignal -group "$_wave_session_group_1" { {V1:top_tb.u_top.clk} {V1:top_tb.u_top.reset} {V1:top_tb.u_top.u_cfg.PADDR} {V1:top_tb.u_top.u_cfg.PWRITE} {V1:top_tb.u_top.u_cfg.PWDATA} {V1:top_tb.u_top.u_cfg.PRDATA} {V1:top_tb.u_top.u_cfg.PENABLE} }

set _wave_session_group_2 Group3
if {[gui_sg_is_group -name "$_wave_session_group_2"]} {
    set _wave_session_group_2 [gui_sg_generate_new_name]
}
set Group2 "$_wave_session_group_2"

gui_sg_addsignal -group "$_wave_session_group_2" { {V1:top_tb.u_top.u_matmul.start_mat_mul} {V1:top_tb.u_top.u_matmul.address_mat_a} {V1:top_tb.u_top.u_matmul.address_mat_b} {V1:top_tb.u_top.u_matmul.a_data} {V1:top_tb.u_top.u_matmul.b_data} {V1:top_tb.u_top.u_matmul.done_mat_mul} {V1:top_tb.u_top.u_matmul.c_data_out} {V1:top_tb.u_top.u_matmul.c_data_available} }

set _wave_session_group_3 Group4
if {[gui_sg_is_group -name "$_wave_session_group_3"]} {
    set _wave_session_group_3 [gui_sg_generate_new_name]
}
set Group3 "$_wave_session_group_3"

gui_sg_addsignal -group "$_wave_session_group_3" { {V1:top_tb.u_top.u_norm.enable_norm} {V1:top_tb.u_top.u_norm.out_data} {V1:top_tb.u_top.u_norm.out_data_available} {V1:top_tb.u_top.u_norm.done_norm} }

set _wave_session_group_4 Group5
if {[gui_sg_is_group -name "$_wave_session_group_4"]} {
    set _wave_session_group_4 [gui_sg_generate_new_name]
}
set Group4 "$_wave_session_group_4"

gui_sg_addsignal -group "$_wave_session_group_4" { {V1:top_tb.u_top.u_pool.enable_pool} {V1:top_tb.u_top.u_pool.kernel_size} {V1:top_tb.u_top.u_pool.out_data} {V1:top_tb.u_top.u_pool.out_data_available} {V1:top_tb.u_top.u_pool.done_pool} }

set _wave_session_group_5 Group6
if {[gui_sg_is_group -name "$_wave_session_group_5"]} {
    set _wave_session_group_5 [gui_sg_generate_new_name]
}
set Group5 "$_wave_session_group_5"

gui_sg_addsignal -group "$_wave_session_group_5" { {V1:top_tb.u_top.u_activation.activation_type} {V1:top_tb.u_top.u_activation.enable_activation} {V1:top_tb.u_top.u_activation.out_data} {V1:top_tb.u_top.u_activation.out_data_available} {V1:top_tb.u_top.u_activation.done_activation} }

set _wave_session_group_6 Group7
if {[gui_sg_is_group -name "$_wave_session_group_6"]} {
    set _wave_session_group_6 [gui_sg_generate_new_name]
}
set Group6 "$_wave_session_group_6"

gui_sg_addsignal -group "$_wave_session_group_6" { {V1:top_tb.u_top.u_control.start_tpu} {V1:top_tb.u_top.u_control.done_tpu} }
if {![info exists useOldWindow]} { 
	set useOldWindow true
}
if {$useOldWindow && [string first "Wave" [gui_get_current_window -view]]==0} { 
	set Wave.1 [gui_get_current_window -view] 
} else {
	set Wave.1 [lindex [gui_get_window_ids -type Wave] 0]
if {[string first "Wave" ${Wave.1}]!=0} {
gui_open_window Wave
set Wave.1 [ gui_get_current_window -view ]
}
}

set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 0 2200000
gui_list_add_group -id ${Wave.1} -after {New Group} [list ${Group1}]
gui_list_add_group -id ${Wave.1} -after {New Group} [list ${Group2}]
gui_list_add_group -id ${Wave.1} -after {New Group} [list ${Group3}]
gui_list_add_group -id ${Wave.1} -after {New Group} [list ${Group4}]
gui_list_add_group -id ${Wave.1} -after {New Group} [list ${Group5}]
gui_list_add_group -id ${Wave.1} -after {New Group} [list ${Group6}]
gui_seek_criteria -id ${Wave.1} {Any Edge}


gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group ${Group6}  -position in

gui_marker_move -id ${Wave.1} {C1} 950000
gui_view_scroll -id ${Wave.1} -vertical -set 0
gui_show_grid -id ${Wave.1} -enable false
#</Session>

