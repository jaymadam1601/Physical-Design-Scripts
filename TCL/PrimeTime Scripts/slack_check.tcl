proc get_cell_name_from_pin {pin_path} {
    set parts [split $pin_path "/"]
    set len [llength $parts]
    return [join [lrange $parts 0 [expr {$len-2}]] "/"]
}

proc setup_timing_path_slack_check {path_collection {to_file ""}} {
	if {$to_file != ""} {
        set fp [open $to_file w]
		puts $fp "StartPoint EndPoint N-1SetupSlack SetupSlack HoldCellSlack HoldSlack N+1SetupSlack"
    } else {
		puts "StartPoint EndPoint N-1SetupSlack SetupSlack HoldCellSlack HoldSlack N+1SetupSlack"
	}
	foreach_in_collection path $path_collection {
		set path_points [get_object_name [get_attribute [get_attribute $path points] object]]
		set setup_slack [get_attribute $path slack]
		set start_point [lindex $path_points 1]
		set end_point   [lindex $path_points end]
		set start_point_cell [get_cell_name_from_pin $start_point]
		set end_point_cell   [get_cell_name_from_pin $end_point]
		
		set hold_path [get_timing_paths -from $start_point -to $end_point -delay_type min -attributes slack]
		set hold_slack [get_attribute $hold_path slack]
	
		set hold_path_cell [get_timing_paths -from $start_point_cell -to $end_point_cell -delay_type min -attributes slack]
		set hold_slack_cell [get_attribute $hold_path_cell slack]

		set Nminu1setup_path [get_timing_paths -to $start_point_cell -attributes slack]
		set Nminu1setup_slack [get_attribute $Nminu1setup_path slack]
		
		set Nplus1setup_path [get_timing_paths -from $end_point_cell -attributes slack]
		set Nplus1setup_slack [get_attribute  $Nplus1setup_path slack]
		if {$to_file != ""} {
			puts $fp "$start_point $end_point $Nminu1setup_slack $setup_slack $hold_slack_cell $hold_slack $Nplus1setup_slack"
		} else {
			puts "$start_point $end_point $Nminu1setup_slack $setup_slack $hold_slack_cell $hold_slack $Nplus1setup_slack"
		}
	}
	if {$to_file != ""} {
        close $fp
    }
}

proc hold_timing_path_slack_check {path_collection {to_file ""}} {
	if {$to_file != ""} {
		set fp [open $to_file w]
		puts $fp "StartPoint Endpoint N-1HoldSlack SetupSlack SetupCellSlack Holdslack N+1HoldSlack"
	} else {
		puts "StartPoint Endpoint N-1HoldSlack SetupSlack SetupCellSlack Holdslack N+1HoldSlack"
	}
	foreach_in_collection path $path_collection {
		set path_points [get_object_name [get_attribute [get_attribute $path points] object]]
		set hold_slack [get_attribute $path slack]
		set start_point [lindex $path_points 1]
		set end_point   [lindex $path_points end]
		set start_point_cell [get_cell_name_from_pin $start_point]
		set end_point_cell   [get_cell_name_from_pin $end_point]

		set setup_path [get_timing_paths -from $start_point -to $end_point -attributes slack]
		set setup_slack [get_attribute $setup_path slack]

		set setup_path_cell [get_timing_paths -from $start_point_cell -to $end_point_cell -attributes slack]
        set setup_slack_cell [get_attribute $setup_path_cell slack]

		set Nminu1hold_path [get_timing_paths -to $start_point_cell -delay_type min -attributes slack]
    	set Nminu1hold_slack [get_attribute $Nminu1hold_path slack]

    	set Nplus1hold_path [get_timing_paths -from $end_point_cell -delay_type min -attributes slack]
    	set Nplus1hold_slack [get_attribute  $Nplus1hold_path slack]
		if {$to_file != ""} {
			puts $fp "$start_point $end_point $Nminu1hold_slack $setup_slack $setup_slack_cell $hold_slack $Nplus1hold_slack"
		} else {
			puts "$start_point $end_point $Nminu1hold_slack $setup_slack $setup_slack_cell $hold_slack $Nplus1hold_slack"
		}
	}
	if {$to_file != ""} {
		close $fp
	}
}

proc timing_slack_check_sp_ep {file_name} {

}	

puts "Usage:"
puts "	For checking Hold slack on Setup violated path"
puts "		setup_timing_path_slack_check \[get_timing_path -from start_point -to end_point\]"
puts ""
puts "	For checking Setup slack on Hold violated path"
puts "		hold_timing_path_slack_check \[get_timing_path -from start_point -to end_point\]"
puts ""
puts "	And to save result in to file give file name after get_timing_path command (this is optinal)"
puts "		setup_timing_path_slack_check \[get_timing_path\] <file_name>"
puts "		hold_timing_path_slack_check \[get_timing_path\] <file_name>"
