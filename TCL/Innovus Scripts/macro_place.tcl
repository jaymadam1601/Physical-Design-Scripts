proc place_macros_down {from to space_x space_y} {
    set point_for_dir_change 0
    for {set i [expr $from + 1]} {$i <= $to} {incr i} {
		# Get points of current macro for increment or decrement
		set macro_llx [dbget selected.box_llx]
		set tmp_macro_llx $macro_llx
		set macro_lly [dbget selected.box_lly]
		set macro_w [dbget selected.box_sizex]
		set macro_h [dbget selected.box_sizey]
		# If loop to inrement or decremetn the llx 
        if {$point_for_dir_change == 0} {
			set macro_llx [expr $macro_llx + $macro_w + $space_x]
        } else {
            set macro_llx [expr $macro_llx - $macro_w - $space_x ]
        }
		# If loop to decrement the lly
		if {[expr $i % 7] == 0} {
			set macro_lly [expr $macro_lly - $macro_h - $space_y]
			set point_for_dir_change [expr 1 - $point_for_dir_change]
			set macro_llx $tmp_macro_llx
		}
		deselectAll
		selectInst r9w6_wrap_inst_${i}__u_rf64x33_9r6w_wrapper__M2MP1596LC64X33_9r6w_inst
		placeInstance [dbget selected.name] $macro_llx $macro_lly
		 
    }
}


proc place_macros_up {from to space_x space_y} {
    set point_for_dir_change 0
    for {set i [expr $from + 1]} {$i <= $to} {incr i} {
		# Get points of current macro for increment or decrement
		set macro_llx [dbget selected.box_llx]
		set tmp_macro_llx $macro_llx
		set macro_lly [dbget selected.box_lly]
		set macro_w [dbget selected.box_sizex]
		set macro_h [dbget selected.box_sizey]
		# If loop to inrement or decremetn the llx 
        if {$point_for_dir_change == 0} {
			set macro_llx [expr $macro_llx + $macro_w + $space_x]
        } else {
            set macro_llx [expr $macro_llx - $macro_w - $space_x ]
        }
		# If loop to decrement the lly
		if {[expr $i % 7] == 0} {
			set macro_lly [expr $macro_lly + $macro_h + $space_y]
			set point_for_dir_change [expr 1 - $point_for_dir_change]
			set macro_llx $tmp_macro_llx
		}
		deselectAll
		selectInst r9w6_wrap_inst_${i}__u_rf64x33_9r6w_wrapper__M2MP1596LC64X33_9r6w_inst
		placeInstance [dbget selected.name] $macro_llx $macro_lly
		 
    }
}
