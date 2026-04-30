proc ChangeNetName {net_name_change {new_name_prefix "NEW_Net_name_for_lvs"}} {
	set fp [open net_name_change.tcl w]
	set i 0 
	foreach one $net_name_change {                                                                                                                                       
		set net_pins [get_object_name [get_pins -of_objects $one -leaf -hierarchical ] ]
		set module_name [lindex [get_object_name [get_pins -of_objects $one]] 0]
		set module [split $module_name "/"]
		set m1 [lindex $module 0]
		set m2 [join [lrange $module 1 end] "/"]
		puts $fp "deleteModulePort $m1 $m2"
		puts $fp "deleteNet ${m1}/\\${one}"
		puts $fp "deleteNet $one"
		puts $fp "addNet ${new_name_prefix}_${i}"
		foreach pin $net_pins {
			set cell_name [get_object_name [get_cells -of_objects $pin]]
			set pin_end_name [lindex [split $pin "/"] end]
			puts $fp "attachTerm $cell_name $pin_end_name ${new_name_prefix}_${i}"
		}
		puts $fp ""
		incr i
	}
	close $fp
}
