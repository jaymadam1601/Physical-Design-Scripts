proc report_pathgroup_summary {path_group max_paths} {

	set fp [open "${path_group}_timing_summary.csv" w]
	foreach_in_collection one [report_timing -path_group $path_group -max_paths $max_paths -collection] {
		set startpoint [get_object_name [get_property $one launching_point]]
		set endpoint [get_object_name [get_property $one capturing_point]]
		set phase_shift [get_property $one phase_shift]
		set uncertainty [get_property $one clock_uncertainty]
		set required_time [get_property $one required_time]
		set arrival [get_property $one arrival]
		set slack [get_property $one slack]
		set launching_input_delay [get_property $one launching_input_delay]
		puts $fp "$startpoint,$endpoint,$phase_shift,$uncertainty,$required_time,$arrival,$slack,$launching_input_delay"
	}
	close $fp
}
