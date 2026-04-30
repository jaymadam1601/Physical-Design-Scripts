source /home/scripts/tcl/invs/path_group_wise_summary.tcl
proc timing_path_summary {args} {
    parse_proc_arguments -args $args options
    set rpt $options(-rpt)
    set file_name ""
    set include_opposite_slack 0
    set print_mode "terminal"
    set exclude_hold false
    if {[info exists options(-outfile)]} {
        set file_name $options(-outfile)
        set print_mode "file"
    }
    if {[info exists options(-both_slack)]} {
        set include_opposite_slack $options(-both_slack)
    }
    if {[info exists options(-exclude_hold)]} {
        set exclude_hold $options(-exclude_hold)
    }

    if {$print_mode eq "file"} {
        set fp [open $file_name w]
    }
    set header_printed 0
    foreach_in_collection one $rpt {
        set endpoint [get_object_name [get_property $one capturing_point]]
        set timing_points_obj [get_property $one timing_points]
        set timing_points [get_object_name [get_property $timing_points_obj pin]]
        set launching_point [get_property $one launching_point]

        set port_coll [get_ports -quiet $launching_point]
        set pin_coll [get_pins -quiet $launching_point]
        if {[sizeof_collection $port_coll]} {
            set startpoint [get_object_name $port_coll]
        } elseif {[sizeof_collection $pin_coll]} {
            set startpoint [lindex $timing_points 1]
        } else {
            set startpoint [get_object_name $launching_point]
        }

        foreach var {startpoint endpoint timing_points} {
            if {[set $var] eq ""} { set $var "-" }
        }

        set path_group [get_object_name [get_property $one path_group]]
        set check_type [get_property $one check_type]
        if {$path_group eq ""} { set path_group "-" }
        if {$check_type eq ""} { set check_type "-" }

        set cell_arcs [get_property $one num_cell_arcs]
        set start_clock [get_object_name [get_property $one launching_clock]]
        set end_clock [get_object_name [get_property $one capturing_clock]]

        set clock_uncertanity [get_property $one clock_uncertainty]
        set slack [get_property $one slack]
        set launch_lat [get_property $one launching_clock_latency]
        set capture_lat [get_property $one capturing_clock_latency]
        set skew [expr {$capture_lat - $launch_lat}]
        set req_time [get_property $one required_time]
        set arr_time [get_property $one arrival]
        set data_delay [get_property $one path_delay]

        foreach var {
            start_clock end_clock clock_uncertanity slack launch_lat
            capture_lat skew req_time arr_time data_delay cell_arcs
        } {
            if {[set $var] eq ""} { set $var "-" }
        }

        set delays [get_cell_delays $one]
        set buff_count [lindex $delays 0]
        set buff_delay [lindex $delays 1]
        set inv_count  [lindex $delays 2]
        set inv_delay  [lindex $delays 3]
        set comb_count_full [lindex $delays 4]
        set comb_delay [lindex $delays 5]

        foreach var {buff_count buff_delay inv_count inv_delay comb_count_full comb_delay} {
            if {[set $var] eq ""} { set $var "-" }
        }

		set opp_slack "-"; set opp_inst_slack "-"; set n_mins_slack "-"; set n_plus_slack "-"
		if {$include_opposite_slack} {
		    set is_start_port [expr {[get_property [get_ports $startpoint -quiet] object_type] eq "port"}]
		    set is_end_port   [expr {[get_property [get_ports $endpoint -quiet] object_type] eq "port"}]
		    set start_cell [expr {$is_start_port ? $startpoint : [get_object_name [get_cells -of $startpoint]]}]
		    set end_cell   [expr {$is_end_port   ? $endpoint   : [get_object_name [get_cells -of $endpoint]]}]
		    if {$check_type eq "setup"} {
		        if {!$exclude_hold} {
		            set opp_slack        [get_property [report_timing -collection -from $startpoint -to $endpoint -early] slack]
		            set opp_inst_slack   [get_property [report_timing -collection -from $start_cell -to $end_cell -early] slack]
		        }
		        if {!$is_start_port} { set n_mins_slack [get_property [report_timing -collection -to $start_cell] slack] }
		        if {!$is_end_port}   { set n_plus_slack [get_property [report_timing -collection -from $end_cell] slack] }
		    } elseif {$check_type eq "hold"} {
		        set opp_slack        [get_property [report_timing -collection -from $startpoint -to $endpoint -late] slack]
		        set opp_inst_slack   [get_property [report_timing -collection -from $start_cell -to $end_cell -late] slack]
		        if {!$is_start_port} { set n_mins_slack [get_property [report_timing -collection -early -to $start_cell] slack] }
		        if {!$is_end_port}   { set n_plus_slack [get_property [report_timing -collection -early -from $end_cell] slack] }
		    }
		    foreach var {opp_slack opp_inst_slack n_mins_slack n_plus_slack} {
		        if {[set $var] eq ""} { set $var "-" }
		    }
		}

        if {!$header_printed} {
            set hdr "Startpoint Endpoint StartClock EndClock PathGroup CheckType"
            if {$check_type eq "setup"} {
                append hdr " Period Uncertainty SetupCheck CaptureLat LaunchLat Skew DataPathDelay Buf(Delay) Inv(Delay) Comb(Delay) ReqTime ArrTime TotalCells Slack"
                if {$include_opposite_slack} {
                    append hdr " HoldSlack InstaceHoldSlack N-SetupSlack N+SetupSlack"
                }
            } elseif {$check_type eq "hold"} {
                append hdr " Uncertainty HoldCheck CaptureLat LaunchLat Skew DataPathDelay Buf(Delay) Inv(Delay) Comb(Delay) ReqTime ArrTime TotalCells Slack"
                if {$include_opposite_slack} {
                    append hdr " SetupSlack InstaceSetupSlack N-HoldSlack N+HoldSlack"
                }
            } else {
                append hdr " ReqTime ArrTime DataPathDelay Buf(Delay) Inv(Delay) Comb(Delay) TotalCells Slack"
            }

            if {$print_mode eq "file"} {
                set hdr [join $hdr ,]
                puts $fp $hdr
            } else {
                puts $hdr
            }
            set header_printed 1
        }

        if {$check_type eq "setup"} {
            set period [get_property $one period]
            set setup_check [get_property $one setup]
            if {$period eq ""} { set period "-" }
            if {$setup_check eq ""} { set setup_check "-" }

            set line "$startpoint $endpoint $start_clock $end_clock $path_group $check_type $period $clock_uncertanity $setup_check $capture_lat $launch_lat $skew $data_delay ${buff_count}([format %.3f $buff_delay]) ${inv_count}([format %.3f $inv_delay]) ${comb_count_full}([format %.3f $comb_delay]) $req_time $arr_time $cell_arcs $slack"
        } elseif {$check_type eq "hold"} {
            set hold_check [get_property $one hold]
            if {$hold_check eq ""} { set hold_check "-" }

            set line "$startpoint $endpoint $start_clock $end_clock $path_group $check_type $clock_uncertanity $hold_check $capture_lat $launch_lat $skew $data_delay ${buff_count}([format %.3f $buff_delay]) ${inv_count}([format %.3f $inv_delay]) ${comb_count_full}([format %.3f $comb_delay]) $req_time $arr_time $cell_arcs $slack"
        } else {
            set line "$startpoint $endpoint $start_clock $end_clock $path_group $check_type $req_time $arr_time $data_delay ${buff_count}([format %.3f $buff_delay]) ${inv_count}([format %.3f $inv_delay]) ${comb_count_full}([format %.3f $comb_delay]) $cell_arcs $slack"
        }

        if {$include_opposite_slack} {
            append line " $opp_slack $opp_inst_slack $n_mins_slack $n_plus_slack"
        }

        if {$print_mode eq "file"} {
            set line [join $line ,]
            puts $fp $line
        } else {
            puts $line
        }
    }

    if {$print_mode eq "file"} {
        close $fp
    }
}

define_proc_attributes timing_path_summary \
  -info "Unified setup/hold timing path summary reporter" \
  -define_args {
    {-rpt "Timing path collection input" timing_path_collection}
    {-outfile "Output file name (optional)" file_name string optional}
    {-both_slack "This will print opposite slack of path given e.x. it will print hold slack for same path if setup check is given and same for opposite (default: false)" "" boolean optional}
    {-exclude_hold "To exclude hold in place stage; use this option when Design is not loaded with hold slack calculation" "" boolean optional}
  }

proc get_cell_delays {rpt} {
    set comb_delay 0; set buff_delay 0; set inv_delay 0
    set comb_count 0; set buff_count 0; set inv_count 0
    foreach_in_collection one [get_property $rpt timing_points] {
        set pin_name [get_object_name [get_property $one pin]]
        set is_comb [dbget [dbget [dbget [dbget [dbget top.insts.instTerms.name $pin_name -p2].cell.isSequential 0 -p2].cell.isBuffer 0 -p2].cell.isInverter 0 -p2].name -e]
        set is_buff [dbget [dbget [dbget top.insts.instTerms.name $pin_name -p2].cell.isBuffer 1 -p2].name -e]
        set is_inv  [dbget [dbget [dbget top.insts.instTerms.name $pin_name -p2].cell.isInverter 1 -p2].name -e]
        set cell_delay [get_property $one delay]
        if {[llength $is_buff] == 1} {
            incr buff_count
            set buff_delay [expr {$buff_delay + $cell_delay}]
        } elseif {[llength $is_inv] == 1} {
            incr inv_count
            set inv_delay [expr {$inv_delay + $cell_delay}]
        } elseif {[llength $is_comb] == 1} {
            incr comb_count
            set comb_delay [expr {$comb_delay + $cell_delay}]
        }
    }
	set buff_count [expr $buff_count/2]
	set inv_count [expr $inv_count/2]
	set comb_count [expr $comb_count/2]
    return [list $buff_count $buff_delay $inv_count $inv_delay $comb_count $comb_delay]
}

