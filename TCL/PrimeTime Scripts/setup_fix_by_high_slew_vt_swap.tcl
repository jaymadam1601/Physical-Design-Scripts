set ::vt_swap_order {S8B L8B U8B}
proc vt_swap_cell {cell_ref_name} {
	set vt_list $::vt_swap_order
	set last_index [expr {[llength $vt_list] - 1}]
	set new_cell_ref_name $cell_ref_name
	foreach one $vt_list {
		if {[regexp $one $cell_ref_name]} {
			set idx [lsearch -exact $vt_list $one]
			if {$idx < $last_index} {
				set next [lindex $vt_list [expr {$idx + 1}]]
				regsub $one $cell_ref_name $next new_cell_ref_name
				if {[sizeof_collection [get_lib_cells */$new_cell_ref_name -quiet]] == 0} {
					puts "Warning: $new_cell_ref_name not found, keeping $cell_ref_name"
					set new_cell_ref_name $cell_ref_name
				}
			}
			break
		}
	}
	return $new_cell_ref_name
}
proc fix_setup_by_high_tran_cell_vt_swap {path_collection tran_value} {
	set fp_back [open "size_cell_back.tcl" w]
	set fp_new  [open "size_cell.tcl" w]
	array set seen {}
	foreach_in_collection one_path $path_collection {
		set first_point 0
		foreach_in_collection one_point [get_attribute $one_path points] {
			set point_name [get_object_name [get_attribute $one_point object]]
			set point_direction [get_attribute [get_attribute $one_point object] direction]
			set point_cell_name [get_object_name [get_cells -of_object $point_name]]
			set point_ref_name [get_attribute [get_cells $point_cell_name] ref_name]
			if {$point_direction == "out"} {
				if {$first_point == 0} {
					incr first_point
					continue
				}
				if {![regexp {U8B} $point_ref_name]} {
					set point_tran [get_attribute $one_point transition]
					if {$point_tran >= $tran_value} {
						if {![info exists seen($point_cell_name)]} {
							set new_cell_name [vt_swap_cell $point_ref_name]
							puts $fp_back "size_cell $point_cell_name $point_ref_name"
							puts $fp_new  "size_cell $point_cell_name $new_cell_name"
							set seen($point_cell_name) 1
						}
					}
				}
			}
		}
	}
	close $fp_back
	close $fp_new
}

proc get_lib_cell_dmsa {cell_ref_name} {
	set_distributed_variables cell_ref_name
	remote_execute {set ref_name [get_object_name [get_lib_cells */$cell_ref_name -quiet]]}
	if {[info exists ref_name]} { unset ref_name }
	get_distributed_variables ref_name -merge_type unique_list
	return $ref_name
}	
proc vt_swap_cell_dmsa {cell_ref_name} {
    set vt_list $::vt_swap_order
    set last_index [expr {[llength $vt_list] - 1}] 
    set new_cell_ref_name $cell_ref_name
    foreach one $vt_list {
        if {[regexp $one $cell_ref_name]} {
            set idx [lsearch -exact $vt_list $one]
            if {$idx < $last_index} {
                set next [lindex $vt_list [expr {$idx + 1}]]
                regsub $one $cell_ref_name $next new_cell_ref_name
                if {[llength [get_lib_cell_dmsa $new_cell_ref_name]] == 0} {
                    puts "Warning: $new_cell_ref_name not found, keeping $cell_ref_name"
                    set new_cell_ref_name $cell_ref_name
                }
            }
            break
        }
    }   
    return $new_cell_ref_name
}
proc get_cells_of_pin_dmsa {pin_name} {
	set_distributed_variables pin_name
	remote_execute {
		set cell_name [get_object_name [get_cells -of_object $pin_name -quiet]]
		set cell_ref_name [get_attribute [get_cells -of_object $pin_name -quiet] ref_name]
	}
	if {[info exists cell_name]} { unset cell_name }
	if {[info exists cell_ref_name]} { unset cell_ref_name }
	get_distributed_variables {cell_name cell_ref_name} -merge_type unique_list
	return [list $cell_name $cell_ref_name ]
}
proc fix_setup_by_high_tran_cell_vt_swap_dmsa {path_collection tran_value} {
	set fp_back [open "size_cell_back.tcl" w]
    set fp_new  [open "size_cell.tcl" w]
    array set seen {}
	foreach_in_collection one_path $path_collection {
		set first_point 0
		foreach_in_collection one_point [get_attribute $one_path points] {
			set point_name [get_object_name [get_attribute $one_point object]]
			set point_direction [get_attribute [get_attribute $one_point object] direction]
			if {$point_direction == "out"} {
				set point_cell_info [get_cells_of_pin_dmsa $point_name]
				set point_cell_name [lindex $point_cell_info 0]
				set point_ref_name [lindex $point_cell_info 1]
                if {$first_point == 0} {
                    incr first_point
                    continue
                }
                if {![regexp {U8B} $point_ref_name]} {
                    set point_tran [get_attribute $one_point transition]
                    if {$point_tran >= $tran_value} {
                        if {![info exists seen($point_cell_name)]} {
                            set new_cell_name [vt_swap_cell_dmsa $point_ref_name]
                            puts $fp_back "size_cell $point_cell_name $point_ref_name"
                            puts $fp_new  "size_cell $point_cell_name $new_cell_name"
                            set seen($point_cell_name) 1
                        }
                    }
                }
            }
		}
	}
	close $fp_back
    close $fp_new
}
