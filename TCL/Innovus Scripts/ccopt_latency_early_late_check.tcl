proc get_latency_offset_for_hold_fix {startpoint endpoint} {
	set fp [open "clock_latency_ealty_late_hold_fix.tcl" w]
	set rpt [report_timing -from $startpoint -to $endpoint -early -collection]
	set n_timing_points [get_object_name [get_property [get_property $rpt timing_points] pin]]
    set n_start_point [lindex $n_timing_points 1]
    set n_end_point [lindex $n_timing_points end]
    set n_start_point_cell [dbget [dbget top.insts.instTerms.name $n_start_point -p2].name]
    set n_end_point_cell [dbget [dbget top.insts.instTerms.name $n_end_point -p2].name]
    set n_setup_slack [get_property $rpt slack]
    set n_hold_path [report_timing -from $n_start_point -to $n_end_point -check_type hold -collection]
    set n_hold_slack [get_property $n_hold_path slack]

	set n_minus_setup_rpt [report_timing -to $n_start_point_cell -collection]
    set n_minus_hold_rpt [report_timing -to $n_start_point_cell -collection -check_type hold]
    set n_minus_setup_slack [get_property $n_minus_setup_rpt slack]
    set n_minus_hold_slack [get_property $n_minus_hold_rpt slack]
	
	set n_plus_setup_rpt [report_timing -from $n_end_point_cell -collection]
    set n_plus_hold_rpt [report_timing -from $n_end_point_cell -collection -check_type hold]
    set n_plus_setup_slack [get_property $n_plus_setup_rpt slack]
    set n_plus_hold_slack [get_property $n_plus_hold_rpt slack]
	
	if {$n_hold_slack > 0} {
		puts $fp "# No need to fix hold for $n_start_point and $n_end_point as HoldSlack is $n_hold_slack"
		continue
	}


}
