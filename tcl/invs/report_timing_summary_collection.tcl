proc timing_path_summary_print_both_slack {rpt {file_name "timing_summary.rpt"}} {
	set header_printed 0
	foreach_in_collection one $rpt {
		set startpoint ""
		set endpoint [get_object_name [get_property $one capturing_point]]
		set timing_points [get_object_name [get_property [get_property $one timing_points] pin]]
		if {[sizeof_collection [get_ports -quiet [get_property $one launching_point]]] != 0} {
			set startpoint [get_object_name [get_ports -quiet [get_property $one launching_point]]]
		} elseif {[sizeof_collection [get_pins -quiet [get_property $one launching_point]]] != 0} {
			set startpoint [lindex $timing_points 1]
		} else {
			set startpoint [get_object_name [get_property $one launching_point]]
		}
		set startpoint_index [lsearch -exact $timing_points "$startpoint"] 
		set bufinv 0
		set comb 0
		foreach point $timing_points {
			set point_idx [lsearch -exact $timing_points $point]
			if {$point_idx > $startpoint_index && $point_idx < [expr [llength $timing_points] - 1]} {
				if {[get_property [get_pins $point] object_type]=="pin" } {
					if {[sizeof_collection [filter_collection [get_cells -of_object $point] "is_buffer==true||is_inverter==true"]]} {
						incr bufinv
					} elseif {[sizeof_collection [filter_collection [get_cells -of_object $point] "is_buffer==false||is_inverter==false"]]} {
						incr comb
					}
				}
			}
		}
		set buf_inv [expr $bufinv/2]
		set comb_count [expr $comb/2]
		set startpoint_clock [get_object_name [get_property $one launching_clock]]
		set endpoint_clock [get_object_name [get_property $one capturing_clock]]
		# Common Section for both setup and hold
		set clock_uncertanity [get_property $one clock_uncertainty]
		set slack [get_property $one slack]
		set launchingClockLatency [get_property $one launching_clock_latency]
		set capturingClockLatency [get_property $one capturing_clock_latency]
		set skew [expr $capturingClockLatency - $launchingClockLatency]	
		set required_time [get_property $one required_time]
		set arrival_time [get_property $one arrival]
		set check_type [get_property $one check_type]

		set opposite_slack 0

		if {$check_type == "setup"} {
			set opposite_slack [get_property [report_timing -collection -from $startpoint -to $endpoint -early] slack]
		} elseif {$check_type == "hold"} {
			set opposite_slack [get_property [report_timing -collection -from $startpoint -to $endpoint -late] slack]
		}

		if {!$header_printed} {
			if {$check_type == "setup"} {
			    puts "Startpoint(1) Endpoint(2) StartClock(3) EndClock(4) Period(5) Uncertainty(6) SetupCheck(7) CaptureLat(8) LaunchLat(9) Skew(10) ReqTime(11) ArrTime(12) BuffersInv(13) Comb(14) Slack(15) HoldSlack(16)"
			} elseif {$check_type == "hold"} {
			    puts "Startpoint(1) Endpoint(2) StartClock(3) EndClock(4) Uncertainty(5) HoldCheck(6) CaptureLat(7) LaunchLat(8) Skew(9) ReqTime(10) ArrTime(11) BuffersInv(12) Comb(13) Slack(14) SetupSlack(15)"
			} else {
			    puts "Startpoint(1) Endpoint(2) StartClock(3) EndClock(4) ReqTime(5) ArrTime(6) BuffersInv(7) Comb(8) Slack(9)"
			}
			set header_printed 1
		}
		if {$check_type == "setup"} {
			set clock_period [get_property $one period]
			set setup_check [get_property $one setup]
			puts "$startpoint $endpoint $startpoint_clock $endpoint_clock $clock_period $clock_uncertanity $setup_check $capturingClockLatency $launchingClockLatency $skew $required_time $arrival_time $buf_inv $comb_count $slack $opposite_slack"
		} elseif {$check_type == "hold"} {
			set hold_check [get_property $one hold]
			puts "$startpoint $endpoint $startpoint_clock $endpoint_clock $clock_uncertanity $hold_check $capturingClockLatency $launchingClockLatency $skew $required_time $arrival_time $buf_inv $comb_count $slack $opposite_slack"
		} else {
			puts "$startpoint $endpoint $startpoint_clock $endpoint_clock $required_time $arrival_time $buf_inv $comb_count $slack" 
		}
	}
}

proc timing_path_summary_both_slack {rpt {file_name "timing_summary.rpt"}} {
	set fp [open "${file_name}" w]
	set header_printed 0
	foreach_in_collection one $rpt {
		set startpoint ""
		set endpoint [get_object_name [get_property $one capturing_point]]
		set timing_points [get_object_name [get_property [get_property $one timing_points] pin]]
		if {[sizeof_collection [get_ports -quiet [get_property $one launching_point]]] != 0} {
			set startpoint [get_object_name [get_ports -quiet [get_property $one launching_point]]]
		} elseif {[sizeof_collection [get_pins -quiet [get_property $one launching_point]]] != 0} {
			set startpoint [lindex $timing_points 1]
		} else {
			set startpoint [get_object_name [get_property $one launching_point]]
		}
		set startpoint_index [lsearch -exact $timing_points "$startpoint"] 
		set bufinv 0
		set comb 0
		foreach point $timing_points {
			set point_idx [lsearch -exact $timing_points $point]
			if {$point_idx > $startpoint_index && $point_idx < [expr [llength $timing_points] - 1]} {
				if {[get_property [get_pins $point] object_type]=="pin" } {
					if {[sizeof_collection [filter_collection [get_cells -of_object $point] "is_buffer==true||is_inverter==true"]]} {
						incr bufinv
					} elseif {[sizeof_collection [filter_collection [get_cells -of_object $point] "is_buffer==false||is_inverter==false"]]} {
						incr comb
					}
				}
			}
		}
		set buf_inv [expr $bufinv/2]
		set comb_count [expr $comb/2]
		set startpoint_clock [get_object_name [get_property $one launching_clock]]
		set endpoint_clock [get_object_name [get_property $one capturing_clock]]
		# Common Section for both setup and hold
		set clock_uncertanity [get_property $one clock_uncertainty]
		set slack [get_property $one slack]
		set launchingClockLatency [get_property $one launching_clock_latency]
		set capturingClockLatency [get_property $one capturing_clock_latency]
		set skew [expr $capturingClockLatency - $launchingClockLatency]	
		set required_time [get_property $one required_time]
		set arrival_time [get_property $one arrival]
		set check_type [get_property $one check_type]

		set opposite_slack 0

		if {$check_type == "setup"} {
			set opposite_slack [get_property [report_timing -collection -from $startpoint -to $endpoint -early] slack]
		} elseif {$check_type == "hold"} {
			set opposite_slack [get_property [report_timing -collection -from $startpoint -to $endpoint -late] slack]
		}

		if {!$header_printed} {
			if {$check_type == "setup"} {
			    puts $fp "Startpoint(1) Endpoint(2) StartClock(3) EndClock(4) Period(5) Uncertainty(6) SetupCheck(7) CaptureLat(8) LaunchLat(9) Skew(10) ReqTime(11) ArrTime(12) BuffersInv(13) Comb(14) Slack(15) HoldSlack(16)"
			} elseif {$check_type == "hold"} {
			    puts $fp "Startpoint(1) Endpoint(2) StartClock(3) EndClock(4) Uncertainty(5) HoldCheck(6) CaptureLat(7) LaunchLat(8) Skew(9) ReqTime(10) ArrTime(11) BuffersInv(12) Comb(13) Slack(14) SetupSlack(15)"
			} else {
			    puts $fp "Startpoint(1) Endpoint(2) StartClock(3) EndClock(4) ReqTime(5) ArrTime(6) BuffersInv(7) Comb(8) Slack(9)"
			}
			set header_printed 1
		}
		if {$check_type == "setup"} {
			set clock_period [get_property $one period]
			set setup_check [get_property $one setup]
			puts $fp "$startpoint $endpoint $startpoint_clock $endpoint_clock $clock_period $clock_uncertanity $setup_check $capturingClockLatency $launchingClockLatency $skew $required_time $arrival_time $buf_inv $comb_count $slack $opposite_slack"
		} elseif {$check_type == "hold"} {
			set hold_check [get_property $one hold]
			puts $fp "$startpoint $endpoint $startpoint_clock $endpoint_clock $clock_uncertanity $hold_check $capturingClockLatency $launchingClockLatency $skew $required_time $arrival_time $buf_inv $comb_count $slack $opposite_slack"
		} else {
			puts $fp "$startpoint $endpoint $startpoint_clock $endpoint_clock $required_time $arrival_time $buf_inv $comb_count $slack" 
		}
	}
	close $fp
}


proc timing_path_summary_print {rpt {file_name "timing_summary.rpt"}} {
	set fp [open "${file_name}" w]
	set header_printed 0
	foreach_in_collection one $rpt {
		set startpoint ""
		set endpoint [get_object_name [get_property $one capturing_point]]
		set timing_points [get_object_name [get_property [get_property $one timing_points] pin]]
		if {[sizeof_collection [get_ports -quiet [get_property $one launching_point]]] != 0} {
			set startpoint [get_object_name [get_ports -quiet [get_property $one launching_point]]]
		} elseif {[sizeof_collection [get_pins -quiet [get_property $one launching_point]]] != 0} {
			set startpoint [lindex $timing_points 1]
		} else {
			set startpoint [get_object_name [get_property $one launching_point]]
		}
		set startpoint_index [lsearch -exact $timing_points "$startpoint"] 
		set bufinv 0
		set comb 0
		foreach point $timing_points {
			set point_idx [lsearch -exact $timing_points $point]
			if {$point_idx > $startpoint_index && $point_idx < [expr [llength $timing_points] - 1]} {
				if {[get_property [get_pins $point] object_type]=="pin" } {
					if {[sizeof_collection [filter_collection [get_cells -of_object $point] "is_buffer==true||is_inverter==true"]]} {
						incr bufinv
					} elseif {[sizeof_collection [filter_collection [get_cells -of_object $point] "is_buffer==false||is_inverter==false"]]} {
						incr comb
					}
				}
			}
		}
		set buf_inv [expr $bufinv/2]
		set comb_count [expr $comb/2]
		set startpoint_clock [get_object_name [get_property $one launching_clock]]
		set endpoint_clock [get_object_name [get_property $one capturing_clock]]
		# Common Section for both setup and hold
		set clock_uncertanity [get_property $one clock_uncertainty]
		set slack [get_property $one slack]
		set launchingClockLatency [get_property $one launching_clock_latency]
		set capturingClockLatency [get_property $one capturing_clock_latency]
		set skew [expr $capturingClockLatency - $launchingClockLatency]	
		set required_time [get_property $one required_time]
		set arrival_time [get_property $one arrival]
		set check_type [get_property $one check_type]


		if {!$header_printed} {
			if {$check_type == "setup"} {
			    puts "Startpoint(1) Endpoint(2) StartClock(3) EndClock(4) Period(5) Uncertainty(6) SetupCheck(7) CaptureLat(8) LaunchLat(9) Skew(10) ReqTime(11) ArrTime(12) BuffersInv(13) Comb(14) Slack(15)"
			} elseif {$check_type == "hold"} {
			    puts "Startpoint(1) Endpoint(2) StartClock(3) EndClock(4) Uncertainty(5) HoldCheck(6) CaptureLat(7) LaunchLat(8) Skew(9) ReqTime(10) ArrTime(11) BuffersInv(12) Comb(13) Slack(14)"
			} else {
			    puts "Startpoint(1) Endpoint(2) StartClock(3) EndClock(4) ReqTime(5) ArrTime(6) BuffersInv(7) Comb(8) Slack(9)"
			}
			set header_printed 1
		}
		if {$check_type == "setup"} {
			set clock_period [get_property $one period]
			set setup_check [get_property $one setup]
			puts "$startpoint $endpoint $startpoint_clock $endpoint_clock $clock_period $clock_uncertanity $setup_check $capturingClockLatency $launchingClockLatency $skew $required_time $arrival_time $buf_inv $comb_count $slack"
		} elseif {$check_type == "hold"} {
			set hold_check [get_property $one hold]
			puts "$startpoint $endpoint $startpoint_clock $endpoint_clock $clock_uncertanity $hold_check $capturingClockLatency $launchingClockLatency $skew $required_time $arrival_time $buf_inv $comb_count $slack"
		} else {
			puts "$startpoint $endpoint $startpoint_clock $endpoint_clock $required_time $arrival_time $buf_inv $comb_count $slack" 
		}
	}
	close $fp
}


proc timing_path_summary {rpt {file_name "timing_summary.rpt"}} {
	set fp [open "${file_name}" w]
	set header_printed 0
	foreach_in_collection one $rpt {
		set startpoint ""
		set endpoint [get_object_name [get_property $one capturing_point]]
		set timing_points [get_object_name [get_property [get_property $one timing_points] pin]]
		if {[sizeof_collection [get_ports -quiet [get_property $one launching_point]]] != 0} {
			set startpoint [get_object_name [get_ports -quiet [get_property $one launching_point]]]
		} elseif {[sizeof_collection [get_pins -quiet [get_property $one launching_point]]] != 0} {
			set startpoint [lindex $timing_points 1]
		} else {
			set startpoint [get_object_name [get_property $one launching_point]]
		}
		set startpoint_index [lsearch -exact $timing_points "$startpoint"] 
		set bufinv 0
		set comb 0
		foreach point $timing_points {
			set point_idx [lsearch -exact $timing_points $point]
			if {$point_idx > $startpoint_index && $point_idx < [expr [llength $timing_points] - 1]} {
				if {[get_property [get_pins $point] object_type]=="pin" } {
					if {[sizeof_collection [filter_collection [get_cells -of_object $point] "is_buffer==true||is_inverter==true"]]} {
						incr bufinv
					} elseif {[sizeof_collection [filter_collection [get_cells -of_object $point] "is_buffer==false||is_inverter==false"]]} {
						incr comb
					}
				}
			}
		}
		set buf_inv [expr $bufinv/2]
		set comb_count [expr $comb/2]
		set startpoint_clock [get_object_name [get_property $one launching_clock]]
		set endpoint_clock [get_object_name [get_property $one capturing_clock]]
		# Common Section for both setup and hold
		set clock_uncertanity [get_property $one clock_uncertainty]
		set slack [get_property $one slack]
		set launchingClockLatency [get_property $one launching_clock_latency]
		set capturingClockLatency [get_property $one capturing_clock_latency]
		set skew [expr $capturingClockLatency - $launchingClockLatency]	
		set required_time [get_property $one required_time]
		set arrival_time [get_property $one arrival]
		set check_type [get_property $one check_type]


		if {!$header_printed} {
			if {$check_type == "setup"} {
			    puts $fp "Startpoint(1) Endpoint(2) StartClock(3) EndClock(4) Period(5) Uncertainty(6) SetupCheck(7) CaptureLat(8) LaunchLat(9) Skew(10) ReqTime(11) ArrTime(12) BuffersInv(13) Comb(14) Slack(15)"
			} elseif {$check_type == "hold"} {
			    puts $fp "Startpoint(1) Endpoint(2) StartClock(3) EndClock(4) Uncertainty(5) HoldCheck(6) CaptureLat(7) LaunchLat(8) Skew(9) ReqTime(10) ArrTime(11) BuffersInv(12) Comb(13) Slack(14)"
			} else {
			    puts $fp "Startpoint(1) Endpoint(2) StartClock(3) EndClock(4) ReqTime(5) ArrTime(6) BuffersInv(7) Comb(8) Slack(9)"
			}
			set header_printed 1
		}
		if {$check_type == "setup"} {
			set clock_period [get_property $one period]
			set setup_check [get_property $one setup]
			puts $fp "$startpoint $endpoint $startpoint_clock $endpoint_clock $clock_period $clock_uncertanity $setup_check $capturingClockLatency $launchingClockLatency $skew $required_time $arrival_time $buf_inv $comb_count $slack"
		} elseif {$check_type == "hold"} {
			set hold_check [get_property $one hold]
			puts $fp "$startpoint $endpoint $startpoint_clock $endpoint_clock $clock_uncertanity $hold_check $capturingClockLatency $launchingClockLatency $skew $required_time $arrival_time $buf_inv $comb_count $slack"
		} else {
			puts $fp "$startpoint $endpoint $startpoint_clock $endpoint_clock $required_time $arrival_time $buf_inv $comb_count $slack" 
		}
	}
	close $fp
}
