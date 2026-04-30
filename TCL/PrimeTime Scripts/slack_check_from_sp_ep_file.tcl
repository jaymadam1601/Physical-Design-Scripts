proc get_cell_name_from_pin {pin_path} {
	set parts [split $pin_path "/"]
	set len [llength $parts]
	return [join [lrange $parts 0 [expr {$len-2}]] "/"]
}


proc timing_slack_check_sp_ep {file_name {input_type "cells"} {result_file "setup_hold_margin_check.rpt"}} {
	if {$input_type != "pins" && $input_type != "cells"} {error "input_type should be pins or cells only"}
	set fp [open $file_name r]
	set fp1 [open $result_file w]
	puts $fp1 "Startpoint Endpoint N-1SetupSlack N-1HoldSlack SetupSlack HoldSlack N+1SetupSlack N+1HoldSlack"
	while {[gets $fp line] >= 0} {
		set fields [split $line " "]
		set start_point  [lindex $fields 0]
		set end_point	[lindex $fields 1]
		if {$input_type == "pins"} {
			set start_point_cell [get_cell_name_from_pin $start_point]
			set end_point_cell   [get_cell_name_from_pin $end_point]
		} elseif {$input_type == "cells"} {
			set start_point_cell $start_point
			set end_point_cell   $end_point
		} else {
			error "input_type should be pins or cells only"
		}
		set setup_path [get_timing_paths -from $start_point -to $end_point -attributes slack]
		if {[sizeof_collection $setup_path] > 0} {
			set setup_slack [get_attribute $setup_path slack]
		} else {
			set setup_slack NA
		}

		set Nminu1setup_path [get_timing_paths -to $start_point_cell -attributes slack]
		if {[sizeof_collection $Nminu1setup_path] > 0} {
			set Nminu1setup_slack [get_attribute $Nminu1setup_path slack]
		} else {
			set Nminu1setup_slack NA
		}

		set Nplus1setup_path [get_timing_paths -from $end_point_cell -attributes slack]
		if {[sizeof_collection $Nplus1setup_path] > 0} {
			set Nplus1setup_slack [get_attribute $Nplus1setup_path slack]
		} else {
			set Nplus1setup_slack NA
		}

		set hold_path [get_timing_paths -from $start_point -to $end_point -delay_type min -attributes slack]
		if {[sizeof_collection $hold_path] > 0} {
			set hold_slack [get_attribute $hold_path slack]
		} else {
			set hold_slack NA
		}

		set Nminu1hold_path [get_timing_paths -to $start_point_cell -delay_type min -attributes slack]
		if {[sizeof_collection $Nminu1hold_path] > 0} {
			set Nminu1hold_slack [get_attribute $Nminu1hold_path slack]
		} else {
			set Nminu1hold_slack NA
		}

		set Nplus1hold_path [get_timing_paths -from $end_point_cell -delay_type min -attributes slack]
		if {[sizeof_collection $Nplus1hold_path] > 0} {
			set Nplus1hold_slack [get_attribute $Nplus1hold_path slack]
		} else {
			set Nplus1hold_slack NA
		}

		puts $fp1 "$start_point $end_point $Nminu1setup_slack $Nminu1hold_slack $setup_slack $hold_slack $Nplus1setup_slack $Nplus1hold_slack"
	}

	close $fp1
	close $fp
}


puts "Usage:"
puts "timing_slack_check_sp_ep <sp_ep_file> <sp_ep_type cells/pins default:cells> <output_file optinal>"
puts "default output_file: setup_hold_margin_check.rpt"
