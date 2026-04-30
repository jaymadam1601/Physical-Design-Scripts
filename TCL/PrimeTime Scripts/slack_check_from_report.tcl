proc extract_sp_ep_from_gz {gz_file {out_file "sp_ep_slack.rpt"}} {
    set cmd "zcat -f $gz_file | awk '/Startpoint/{start=\$2} /Endpoint/ {line =start\" \"\$2} /slack \\(\[MV\].*\\)/ {print line,\$NF}'"
    set fp [open $out_file w]
    puts $fp [exec sh -c $cmd]
    close $fp
}

proc timing_slack_check_sp_ep {file_name {num_path "100"} {result_file "setup_hold_margin_check.rpt"}} {
	extract_sp_ep_from_gz $file_name  "sp_ep_slack.rpt"
	set fp [open "sp_ep_slack.rpt" r]
	set fp1 [open $result_file w]
	set count 0
	puts $fp1 "Startpoint Endpoint N-1SetupSlack N-1HoldSlack SetupSlack HoldSlack N+1SetupSlack N+1HoldSlack"
	while {[gets $fp line] >= 0} {
		puts $count
		if {$count >= $num_path} {
			break
		}
		set fields [split $line " "]
		set start_point	[lindex $fields 0]
		set end_point	[lindex $fields 1]
		set start_point_cell $start_point
		set end_point_cell   $end_point

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

		incr count
	}

	close $fp1
	close $fp
}
puts "Usage:"
puts "timing_slack_check_sp_ep <sp_ep_file> <number of path, default:100> <output_file optinal>"
puts "default output_file: setup_hold_margin_check.rpt"
