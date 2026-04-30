
proc do_hold_fix_buffer_insertion {{cycle "0"}} {
	
	set base_dir "hold_fix_rpts"
	if {[file exists $base_dir]} {
    	file delete -force $base_dir
	}
	file mkdir $base_dir

	foreach dir_name {"global_timing" "buffer_insertion_tcl_script"} {
    	file mkdir [file join $base_dir $dir_name]
	}

	for {set i 0} {$i <= $cycle} {incr i} {
		redirect ./hold_fix_rpts/global_timing/rpt_global_timing_${i} {report_global_timing}
		set hold_num [exec awk {BEGIN{hold_num} /NUM/ {hold_num=$3} END{print hold_num}} ./hold_fix_rpts/global_timing/rpt_global_timing_${i}]
		puts $hold_num
		
		set report_min_paths [get_timing_paths -to [get_cells -filter "ref_name==M2MP1596LC64X33"] -start_end_type reg_to_reg -max_paths $hold_num -delay_type min]
			
		puts [sizeof_collection $report_min_paths]
		set fp [open "./hold_fix_rpts/buffer_insertion_tcl_script/buffer_insertion_${i}.tcl" w]
		foreach_in_collection one_path $report_min_paths {
			set startpoint [lindex [get_object_name [get_attribute [get_attribute $one_path points] object ]] 1]
			set endpoint [lindex [get_object_name [get_attribute [get_attribute $one_path points] object ]] end]
			set hold_slack [get_attribute $one_path slack]
			set setup_path [get_timing_paths -from $startpoint -to $endpoint] 
			set setup_slack [get_attribute $setup_path slack]
			if {$hold_slack < 0 && $setup_slack > 0} {
				puts $fp "insert_buffer $endpoint G5SUNAA_BUFX2"
			}
		}
		close $fp
		source ./hold_fix_rpts/buffer_insertion_tcl_script/buffer_insertion_${i}.tcl

	}
}

proc do_hold_fix_buffer_insertion_on_timing_path {{cycle "0"} {to ""}} {
    
    set base_dir "hold_fix_rpts"
    if {[file exists $base_dir]} {
        file rename -force $base_dir "bak.${base_dir}"
    }   
    file mkdir $base_dir

    foreach dir_name {"global_timing" "buffer_insertion_tcl_script"} {
        file mkdir [file join $base_dir $dir_name]
    }   

    for {set i 0} {$i <= $cycle} {incr i} {
        redirect ./hold_fix_rpts/global_timing/rpt_global_timing_${i} {report_global_timing}
        set hold_num [exec awk {BEGIN{hold_num} /NUM/ {hold_num=$3} END{print hold_num}} ./hold_fix_rpts/global_timing/rpt_global_timing_${i}]
        puts $hold_num
    	if {$to  == ""} {
        	set report_min_paths [get_timing_paths -start_end_type reg_to_reg -max_paths $hold_num -delay_type min]
    	} else {
			set report_min_paths [get_timing_paths -start_end_type reg_to_reg -max_paths $hold_num -delay_type min -to $to]
		}
        puts [sizeof_collection $report_min_paths]
        set fp [open "./hold_fix_rpts/buffer_insertion_tcl_script/buffer_insertion_${i}.tcl" w]
        foreach_in_collection one_path $report_min_paths {
            set startpoint [lindex [get_object_name [get_attribute [get_attribute $one_path points] object ]] 1]
            set endpoint [lindex [get_object_name [get_attribute [get_attribute $one_path points] object ]] end]
            set hold_slack [get_attribute $one_path slack]
            set setup_path [get_timing_paths -from $startpoint -to $endpoint] 
            set setup_slack [get_attribute $setup_path slack]
            if {$hold_slack < 0 && $setup_slack > 0} {
                puts $fp "insert_buffer $endpoint G5SUNAA_BUFX2"
            }
        }
        close $fp 
        source ./hold_fix_rpts/buffer_insertion_tcl_script/buffer_insertion_${i}.tcl

    }   
}
