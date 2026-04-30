puts "Usage: dump_summary_for_path_group {path_group_list} setup/hold path_count exlude_hold:true/false"
proc dump_summary_for_path_group {path_group_list {check_type "setup"} {count "500"} {exlude_hold "false"}} {
	foreach one $path_group_list {
		if {$check_type == "setup"} {
			if {$exlude_hold} {
				timing_path_summary -rpt [report_timing -collection -path_group $one -max_paths $count -max_slack 0 ] -both_slack -outfile ${one}_setup_path_summary -exclude_hold
			} else {
				timing_path_summary -rpt [report_timing -collection -path_group $one -max_paths $count -max_slack 0 ] -both_slack -outfile ${one}_setup_path_summary
			}
		} elseif {$check_type == "hold"} {
			timing_path_summary -rpt [report_timing -collection -early -path_group $one -max_paths $count -max_slack 0 ] -both_slack -outfile ${one}_hold_path_summary
		}
	}
}
