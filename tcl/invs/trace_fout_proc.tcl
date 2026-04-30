proc traceLogic_fout_mbit { {_pin} {level 1} } {

#set level 5
set color [list red blue green orange yellow cyan purple violet lightblue lightgreen]
#set _pin [get_pins u_stns_intf_cache_rsp__inso_mem_s2m_dh_chime_if__ccm_tic_ch_response_data_reg_2_/d]
#set _pin [get_pins u_cm_mem_m2s_dh_data_PB__genCacheM2SData_u_cm_mem_m2s_dh_data__genStns_6__u_m2s_rwd_data_ingr_fifo__genRamInst_3__u_m2s_rwd_data_ingr_ram__genWoBistMem_genRam_2__genLastRam_m2s_rwd_data_ram__u_mem/din[5]]
#set _pin [get_ports s0_ccm* -filter "direction==out"]
deselectAll
dehighlight -all
set clr 0
set lvl 0
set fout_prev_lvl []
global array set cell_list {}
global array set port_list {}

for {set lvl 0} {$lvl<$level} {incr lvl} {
	if { $lvl > 0} { 
	set _pin [get_pins -quiet $fout_prev_lvl -filter "full_name!~*_tessent_* && full_name!~ts_*"]
	}
	set fout_prev_lvl []
	set fout_cell [all_fanout -endpoints_only -only_cells -from [get_object_name $_pin]]
	set fout_cell_cnt [sizeof_collection [all_fanout -endpoints_only -only_cells -from [get_object_name $_pin]]]
	set fout_port [get_ports -quiet [all_fanout -endpoints_only -from [get_object_name $_pin]]]
	set fout_port_cnt [sizeof_collection [get_ports -quiet [all_fanout -endpoints_only -from [get_object_name $_pin]]]]
	set fout_d_nxt [get_pins -quiet [all_fanout -from [get_object_name $_pin]] -filter "full_name=~*/d*"]
	set fout_d_nxt_cnt [sizeof_collection [get_pins -quiet [all_fanout -from [get_object_name $_pin]] -filter "full_name=~*/d*"]]
	if { $fout_d_nxt_cnt > 0 } {
	foreach_in_collection _dpin [get_pins -quiet $fout_d_nxt] {
		set ddigit [string index [get_object_name $_dpin] end]
		if { [ regexp {^([0-9]+)$} $ddigit] } {
			set out_pin [get_pins -of [get_cells -of [get_pins -quiet $_dpin]] -filter "full_name=~*/q$ddigit"] 
			if { [ sizeof_collection $out_pin ] < 1 } {
			set out_pin [get_pins -of [get_cells -of [get_pins -quiet $_dpin]] -filter "full_name=~*/q"] 
			} 
		}
		if { ![ regexp {^([0-9]+)$} $ddigit] } {
			set out_pin [get_pins -of [get_cells -of [get_pins -quiet $_dpin]] -filter "full_name=~*/q"] 
		}
		lappend fout_prev_lvl [get_object_name $out_pin]
	}
	#selectInst [get_cells $fout_cell]
	set cell_list(${lvl}) [get_cells -quiet $fout_cell]
	}
	set port_list(${lvl}) [get_ports -quiet $fout_port]
	if { $fout_port_cnt > 0 } {
	#foreach_in_collection _prt [get_ports -quiet $fout_port] {
		#selectIOPin [get_object_name $_prt]
	#}
	set port_list(${lvl}) [get_ports -quiet $fout_port]
	}
#	highlight -color [lindex $color [expr $clr]]
#	deselectAll
	echo "Next Fout Count Level [expr $lvl+1] Color [lindex $color $clr] Fout_reg [sizeof_collection [get_pins -quiet $fout_prev_lvl]] PORT $fout_port_cnt]"
	set clr [expr $clr + 1]
}
#set tnt [expr $level - 1]
set clr $level
dehighlight -all
deselectAll
for {set tnt [expr $level - 1 ]} {$tnt > -1} {set tnt [expr $tnt - 1]} {
	deselectAll
	echo "Highlighting Level $tnt"
	set high_cell [get_cells -quiet $cell_list($tnt)]
	selectInst $high_cell
	if { [sizeof_collection [get_ports -quiet $port_list($tnt)]] > 0 } {
	foreach_in_collection _prt [get_ports -quiet $port_list($tnt)] {
		selectIOPin [get_object_name $_prt]
	}
	}
	highlight -color [lindex $color $tnt]
	#set clr [expr $clr - 1]
	deselectAll
}
}
#array unset cell_list
#array unset port_list
#unset lvl
#set array_size [array size cell_list]
