proc setup_margin_check {rpt} {
    puts "Startpoint(1) Endpoint(2) Hold_slack(3) Setup_slack(4)"
    foreach_in_collection one $rpt {
        set timing_points [get_object_name [get_attribute [get_attribute $one points] object]]
        set start_point [lindex $timing_points 1]
        set end_point [lindex $timing_points end]
        set hold_slack [get_attribute $one slack]
        set setup_path [get_timing_paths -from $start_point -to $end_point]
        set setup_slack [get_attribute $setup_path slack]
        puts "$start_point $end_point $hold_slack $setup_slack"
    }    
}

proc hold_margin_check {rpt} {
    puts "Startpoint(1) Endpoint(2) Setup_slack(3) Hold_slack(4)"
    foreach_in_collection one $rpt {
        set timing_points [get_object_name [get_attribute [get_attribute $one points] object]]
        set start_point [lindex $timing_points 1]
        set end_point [lindex $timing_points end]
        set setup_slack [get_attribute $one slack]
        set hold_path [get_timing_paths -from $start_point -to $end_point -delay_type min]
        set hold_slack [get_attribute $hold_path slack]
        puts "$start_point $end_point $setup_slack $hold_slack"
    } 
}

