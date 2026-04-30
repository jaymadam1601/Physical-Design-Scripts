
proc n_minus_1_setup_slack {start_point} {
	set rpt [report_timing -to $start_point -collection]
	set slack [get_property $rpt slack]
	return $slack
}
proc n_minus_1_hold_slack {start_point} {
	set rpt [report_timing -to $start_point -collection -check_type hold]
	set slack [get_property $rpt slack]
	return $slack
}
proc n_minus_1_setup {rpt} {
	set timing_points [get_object_name [get_property [get_property $rpt timing_points] pin]]
	set start_point [lindex $timing_points 1]
	set new_rpt [report_timing -to $start_point]
	set slack [get_property $new_rpt slack]
	return $slack
}
proc n_minus_1_hold {rpt} {
	set timing_points [get_object_name [get_property [get_property $rpt timing_points] pin]]
	set start_point [lindex $timing_points 1]
	set new_rpt [report_timing -to $start_point -check_type hold]
	set slack [get_property $new_rpt slack]
	return $slack
}

proc n_plus_1_setup_slack {end_point} {
	set rpt [report_timing -from $end_point -collection]
	set slack [get_property $rpt slack]
	return $slack
}
proc n_plus_1_hold_slack {end_point} {
	set rpt [report_timing -from $end_point -collection -check_type hold]
	set slack [get_property $rpt slack]
	return $slack
}
proc n_plus_1_setup {rpt} {
	set timing_points [get_object_name [get_property [get_property $rpt timing_points] pin]]
	set end_point [lindex $timing_points end]
	set new_rpt [report_timing -from $end_point]
	set slack [get_property $new_rpt slack]
	return $slack
}
proc n_plus_1_hold {rpt} {
	set timing_points [get_object_name [get_property [get_property $rpt timing_points] pin]]
	set end_point [lindex $timing_points end]
	set new_rpt [report_timing -from $end_point -check_type hold]
	set slack [get_property $new_rpt slack]
	return $slack
}

proc setup_margin_check {rpt} {
    puts "Startpoint Endpoint Hold_slack Setup_slack Hold_skew Setup_skew"
    foreach_in_collection one $rpt {
        set timing_points [get_object_name [get_property [get_property $one timing_points] pin]]
        set start_point [lindex $timing_points 1]
        set end_point [lindex $timing_points end]
        set hold_slack [get_property $one slack]
        set hold_skew [get_property $one skew]
        set setup_path [report_timing -from $start_point -to $end_point -collection]
        set setup_slack [get_property $setup_path slack]
        set setup_skew [get_property $setup_path skew]
        puts "$start_point $end_point $hold_slack $setup_slack $hold_skew $setup_skew"
    }   
}

proc hold_margin_check {rpt} {
    puts "Startpoint Endpoint Setup_slack Hold_slack Setup_skew Hold_skew"
    foreach_in_collection one $rpt {
        set timing_points [get_object_name [get_property [get_property $one timing_points] pin]]
        set start_point [lindex $timing_points 1]
        set end_point [lindex $timing_points end]
        set setup_slack [get_property $one slack]
        set setup_skew [get_property $one skew]
        set hold_path [report_timing -from $start_point -to $end_point -check_type hold -collection]
        set hold_slack [get_property $hold_path slack]
        set hold_skew [get_property $hold_path skew]
        puts "$start_point $end_point $setup_slack $hold_slack $setup_skew $hold_skew"
    }   
}

proc setup_hold_prev_after_margin_check {rpt} {
	puts "Startpoint(1) Endpoint(2) N-1Setup(3) N-1Hold(4) NSetup(5) NHold(6) N+1Setup(7) N+1Hold(8)"
	foreach_in_collection one $rpt {
		# N part
		set n_timing_points [get_object_name [get_property [get_property $one timing_points] pin]]
		set n_start_point [lindex $n_timing_points 1]
        set n_end_point [lindex $n_timing_points end]
		set n_start_point_cell [dbget [dbget top.insts.instTerms.name $n_start_point -p2].name]
		set n_end_point_cell [dbget [dbget top.insts.instTerms.name $n_end_point -p2].name]
		set n_setup_slack [get_property $one slack]
		set n_hold_path [report_timing -from $n_start_point -to $n_end_point -check_type hold -collection]
		set n_hold_slack [get_property $n_hold_path slack]
		
		# N-1 part
		set n_minus_setup_rpt [report_timing -to $n_start_point_cell -collection]
		set n_minus_hold_rpt [report_timing -to $n_start_point_cell -collection -check_type hold]
		set n_minus_setup_slack [get_property $n_minus_setup_rpt slack]
		set n_minus_hold_slack [get_property $n_minus_hold_rpt slack]
		
		
		# N+1 part 
		set n_plus_setup_rpt [report_timing -from $n_end_point_cell -collection]
		set n_plus_hold_rpt [report_timing -from $n_end_point_cell -collection -check_type hold]
		set n_plus_setup_slack [get_property $n_plus_setup_rpt slack]
		set n_plus_hold_slack [get_property $n_plus_hold_rpt slack]
		
		puts "$n_start_point $n_end_point $n_minus_setup_slack $n_minus_hold_slack $n_setup_slack $n_hold_slack $n_plus_setup_slack $n_plus_hold_slack"
	}
}
proc hold_setup_prev_after_margin_check {rpt} {
	puts "Startpoint(1) Endpoint(2) N-1Setup(3) N-1Hold(4) NSetup(5) NHold(6) N+1Setup(7) N+1Hold(8)"
	foreach_in_collection one $rpt {
		# N part
		set n_timing_points [get_object_name [get_property [get_property $one timing_points] pin]]
		set n_start_point [lindex $n_timing_points 1]
        set n_end_point [lindex $n_timing_points end]
		set n_start_point_cell [dbget [dbget top.insts.instTerms.name $n_start_point -p2].name]
		set n_end_point_cell [dbget [dbget top.insts.instTerms.name $n_end_point -p2].name]
		set n_hold_slack [get_property $one slack]
		set n_setup_path [report_timing -from $n_start_point -to $n_end_point -collection]
		set n_setup_slack [get_property $n_setup_path slack]
		
		# N-1 part
		set n_minus_setup_rpt [report_timing -to $n_start_point_cell -collection]
		set n_minus_hold_rpt [report_timing -to $n_start_point_cell -collection -check_type hold]
		set n_minus_setup_slack [get_property $n_minus_setup_rpt slack]
		set n_minus_hold_slack [get_property $n_minus_hold_rpt slack]
		
		
		# N+1 part 
		set n_plus_setup_rpt [report_timing -from $n_end_point_cell -collection]
		set n_plus_hold_rpt [report_timing -from $n_end_point_cell -collection -check_type hold]
		set n_plus_setup_slack [get_property $n_plus_setup_rpt slack]
		set n_plus_hold_slack [get_property $n_plus_hold_rpt slack]
		
		puts "$n_start_point $n_end_point $n_minus_setup_slack $n_minus_hold_slack $n_setup_slack $n_hold_slack $n_plus_setup_slack $n_plus_hold_slack"
	}
}
