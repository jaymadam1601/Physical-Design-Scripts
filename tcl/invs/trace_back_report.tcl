proc trace_back_report {from to level} {	 
	global all_startpoints
	global all_endpoints
	global all_cells
	set tmp_level 0
	set port_reached 0
	
	set all_startpoints [list]
	set all_endpoints [list]
	set all_cells [list]
	set rpt_setup [report_timing -from $from -to $to -collection]
	set rpt_hold  [report_timing -from $from -to $to -check_type hold -collection]
	report_timing -from $from -to $to
	report_timing -from $from -to $to -check_type hold
	set rpt_setup_startpoint [lindex [get_object_name [get_property [get_property $rpt_setup timing_points] pin]] 1]
	set rpt_setup_startpoint_cell [get_object_name [get_cells -of_objects $rpt_setup_startpoint]]
	set rpt_setup_endpoint [lindex [get_object_name [get_property [get_property $rpt_setup timing_points] pin]] end]
	set rpt_setup_endpoint_cell [get_object_name [get_cells -of_objects $rpt_setup_endpoint]]
	set rpt_setup_path_group [get_property $rpt_setup path_group_name]
	set rpt_setup_slack [get_property $rpt_setup slack]
	set rpt_hold_slack [get_property $rpt_hold slack]
	
	lappend all_cells $rpt_setup_startpoint_cell
	lappend all_cells $rpt_setup_endpoint_cell


	puts "$tmp_level" 
	puts "Beginpoint: $rpt_setup_startpoint"
	puts "Endpoint: $rpt_setup_endpoint"
	puts "Path Group: $rpt_setup_path_group"
	puts "    Setup slack: $rpt_setup_slack"
	puts "    Hold slack: $rpt_hold_slack"
	lappend all_startpoints $rpt_setup_startpoint
	lappend all_endpoints $rpt_setup_endpoint
	set from_next_to $rpt_setup_startpoint_cell
	
	while {$tmp_level < $level && $port_reached != 1} {
		incr tmp_level
		puts "${tmp_level}."
		set rpt_setup [report_timing -to $from_next_to -collection]
		report_timing -to $from_next_to
		set rpt_setup_startpoint [lindex [get_object_name [get_property [get_property $rpt_setup timing_points] pin]] 1]
		set rpt_setup_endpoint [lindex [get_object_name [get_property [get_property $rpt_setup timing_points] pin]] end]
		set rpt_setup_startpoint_cell [get_property $rpt_setup launching_point_name]
		set rpt_setup_endpoint_cell [get_property $rpt_setup capturing_point_name]
		set rpt_setup_slack [get_property $rpt_setup slack]
		set rpt_setup_path_group [get_property $rpt_setup path_group_name]
		
		set rpt_hold  [report_timing -to $from_next_to -check_type hold -collection]
		report_timing -to $from_next_to -check_type hold
		set rpt_hold_startpoint [lindex [get_object_name [get_property [get_property $rpt_hold timing_points] pin]] 1]
		set rpt_hold_endpoint [lindex [get_object_name [get_property [get_property $rpt_hold timing_points] pin]] end]
		set rpt_hold_startpoint_cell [get_property $rpt_hold launching_point_name]
		set rpt_hold_endpoint_cell [get_property $rpt_hold capturing_point_name]
		set rpt_hold_slack [get_property $rpt_hold slack]
		set rpt_hold_path_group [get_property $rpt_hold path_group_name]
		
			
		lappend all_cells $rpt_setup_startpoint_cell
		lappend all_cells $rpt_setup_endpoint_cell

		lappend all_cells $rpt_hold_startpoint_cell
		lappend all_cells $rpt_hold_endpoint_cell
		if {"$rpt_setup_startpoint_cell" == "$rpt_hold_startpoint_cell"} {
			if {"$rpt_setup_startpoint" == "$rpt_hold_startpoint" && "$rpt_setup_endpoint" == "$rpt_hold_endpoint"} {
				puts "Beginpoint: $rpt_setup_startpoint"
				puts "Endpoint: $rpt_setup_endpoint"
				lappend all_startpoints $rpt_setup_startpoint
				lappend all_endpoints $rpt_end_startpoint
			} elseif {"$rpt_setup_startpoint" != "$rpt_hold_startpoint" && "$rpt_setup_endpoint" == "$rpt_hold_endpoint"} {
				puts "Setup Beginpoint: $rpt_setup_startpoint"
				puts "Hold Beginpoint: $rpt_hold_startpoint"
				puts "Endpoint: $rpt_hold_endpoint"
				lappend all_startpoints $rpt_setup_startpoint
				lappend all_startpoints $rpt_hold_startpoint
				lappend all_endpoints $rpt_hold_startpoint	
			} elseif {"$rpt_setup_startpoint" == "$rpt_hold_startpoint" && "$rpt_setup_endpoint" != "$rpt_hold_endpoint"} {
				puts "Beginpoint: $rpt_setup_startpoint"
				puts "Setup Endpoint: $rpt_setup_endpoint"
				puts "Hold Endpoint: $rpt_hold_endpoint"
				lappend all_startpoints $rpt_setup_startpoint
				lappend all_endpoints $rpt_setup_endpoint
				lappend all_endpoints $rpt_hold_endpoint
			} elseif {"$rpt_setup_startpoint" != "$rpt_hold_startpoint" && "$rpt_setup_endpoint" != "$rpt_hold_endpoint"} {
				puts "Setup Beginpoint: $rpt_setup_startpoint"
				puts "Setup Endpoint: $rpt_setup_endpoint"
				puts "Hold Beginpoint: $rpt_hold_startpoint"
				puts "Hold Endpoint: $rpt_hold_endpoint"
				
				lappend all_startpoints $rpt_setup_startpoint
				lappend all_startpoints $rpt_hold_startpoint

				lappend all_endpoints $rpt_setup_endpoint
				lappend all_endpoints $rpt_hold_endpoint
			}
			puts "Path Group:  $rpt_setup_path_group"
			puts "Setup slack: $rpt_setup_slack"
			puts "Hold slack:  $rpt_hold_slack"
			
			set check_port [dbget top.terms.name $rpt_setup_startpoint_cell -e]
			if {[llength $check_port] > 0} {
				puts "Reached port at level $tmp_level. Stopping...."
				set port_reached 1
				exit 1
			} else {
				set from_next_to [get_object_name [get_cells -of_objects $rpt_setup_startpoint_cell]]
			}
		} else {
			if {"$rpt_setup_endpoint" == "$rpt_hold_endpoint"} {
				puts "Setup Beginpoint: $rpt_setup_startpoint"
				puts "Hold Beginpoint: $rpt_hold_startpoint"
				puts "Endpoint: $rpt_setup_endpoint"
				lappend all_startpoints $rpt_setup_startpoint
				lappend all_startpoints $rpt_hold_startpoint
				lappend all_endpoints $rpt_setup_endpoint
			} elseif {"$rpt_setup_endpoint" != "$rpt_hold_endpoint"} {
				puts "Setup Beginpoint: $rpt_setup_startpoint"
				puts "Setup Endpoint: $rpt_setup_endpoint"
				puts "Hold Beginpoint: $rpt_hold_startpoint"
				puts "Hold Endpoint:  $rpt_hold_endpoint"
				lappend all_startpoints $rpt_setup_startpoint
				lappend all_endpoints $rpt_setup_endpoint
				lappend all_startpoints $rpt_hold_startpoint
				lappend all_endpoints $rpt_hold_endpoint
			}
			if {"$rpt_setup_path_group" == "$rpt_hold_path_group"} {
				puts "Path Group: $rpt_setup_path_group"
			} else {
				puts "Setup Path Group: $rpt_setup_path_group"
				puts "Hold Path Group: $rpt_hold_path_group"
			}
			puts "Setup slack: $rpt_setup_slack"
			puts "Hold slack:  $rpt_hold_slack"
			
			set check_port_setup [dbget top.terms.name $rpt_setup_startpoint_cell -e]
			set check_port_hold [dbget top.terms.name $rpt_hold_startpoint_cell -e]
			if {[llength $check_port_setup] > 0 && [llength $check_port_hold] > 0} {
				puts "Reached port at level $tmp_level. Stopping...."
				set port_reached 1
				exit 1
			} elseif {[llength $check_port_setup] == 0 && [llength $check_port_hold] > 0} {
				set from_next_to [get_object_name [get_cells -of_objects $rpt_setup_startpoint_cell]]
			} elseif {[llength $check_port_setup] > 0 && [llength $check_port_hold] == 0} {
				set from_next_to [get_object_name [get_cells -of_objects $rpt_hold_startpoint_cell]]
			} else {
				if {$rpt_setup_slack < $rpt_hold_slack} {
					set from_next_to [get_object_name [get_cells -of_objects $rpt_setup_startpoint_cell]]
				} else {
					set from_next_to [get_object_name [get_cells -of_objects $rpt_hold_startpoint_cell]]
				}
			}
		}
		puts ""

	}
}

